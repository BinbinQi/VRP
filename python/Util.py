import math
from abc import ABCMeta, abstractmethod, ABC
from gurobipy import *
from pylab import *
from enum import Enum
from ortools.constraint_solver import routing_enums_pb2, pywrapcp
import random


class VRP(Enum):
    Dantzig_Fulkerson_Johnson = 1
    Miller_Tucker_Zemlin = 2
    Simple_Integer_Model = 3
    Simulated_Annealing = 4
    Ortools_method = 5


class ActionBase(metaclass=ABCMeta):
    @abstractmethod
    def action(self, *param):
        pass


# 数据读入类
class VrpData(ActionBase):
    def __init__(self):
        self.name: str = ""
        self.comment = ""
        self.type = ""
        self.dimension = 0
        self.edge_weight_type = ""
        self.capacity = 0
        self.node_coord = {}
        self.demand = {}
        self.depot = []
        self.trucks = 0
        self.dist = None

    def action(self, file_path):
        fid = open(file_path)
        flag = 0
        while True:
            line_ex = fid.readline().strip()
            if line_ex == "EOF":
                break
            if line_ex.startswith("NAME"):
                str_sp = line_ex.split(":", 1)
                self.name = str_sp[-1]
                self.trucks = int(self.name.split("k")[-1])
            elif line_ex.startswith("COMMENT"):
                str_sp = line_ex.split(":", 1)
                self.comment = str_sp[-1]
            elif line_ex.startswith("TYPE"):
                str_sp = line_ex.split(":", 1)
                self.type = str_sp[-1]
            elif line_ex.startswith("DIMENSION"):
                str_sp = line_ex.split(":", 1)
                self.dimension = int(str_sp[-1])
            elif line_ex.startswith("EDGE_WEIGHT_TYPE"):
                str_sp = line_ex.split(":", 1)
                self.edge_weight_type = str_sp[-1]
            elif line_ex.startswith("CAPACITY"):
                str_sp = line_ex.split(":", 1)
                self.capacity = int(str_sp[-1])
            elif line_ex.startswith("NODE_COORD_SECTION"):
                flag = 1
            elif line_ex.startswith("DEMAND_SECTION"):
                flag = 2
            elif line_ex.startswith("DEPOT_SECTION"):
                flag = 3
            else:
                str_sp = line_ex.split()
                if flag == 1:
                    self.node_coord[int(str_sp[0]) - 1] = (int(str_sp[1]), int(str_sp[2]))
                elif flag == 2:
                    self.demand[int(str_sp[0]) - 1] = int(str_sp[1])
                elif flag == 3:
                    self.depot.append(int(str_sp[0]) - 1)
        self.dist = {(i, j): math.sqrt((self.node_coord[i][0] - self.node_coord[j][0]) ** 2
                                       + (self.node_coord[i][1] - self.node_coord[j][1]) ** 2)
                     for i in range(self.dimension) for j in range(self.dimension)}


# 基本的VRP整数规划模型
class VrpModel(object):
    def __init__(self):
        self.vrp_data = None
        self.model = None
        self.X = None
        self.u = None

    def build_model(self):
        p = self.vrp_data.trucks
        n = self.vrp_data.dimension
        self.model = Model("VRP")
        # 决策变量
        self.X = self.model.addVars(n, n, p, vtype=GRB.BINARY, name="x")
        # 目标函数
        self.model.setObjective(quicksum(self.vrp_data.dist[i, j] * self.X[i, j, k]
                                         for i in range(n) for j in range(n) for k in range(p)),
                                sense=GRB.MINIMIZE)
        # 约束条件1
        self.model.addConstrs((self.X[i, i, k] == 0
                               for i in range(n) for k in range(p)), "no to itself")
        # 约束条件2
        self.model.addConstrs((self.X.sum(i, "*", k) == self.X.sum("*", i, k)
                               for i in range(n) for k in range(p)), "in out balance")
        # 约束条件3
        self.model.addConstrs((self.X.sum("*", i, "*") == 1
                               for i in range(1, n)), "enter once")
        # 约束条件4
        self.model.addConstrs((quicksum(self.X[0, j, k] for j in range(1, n)) == 1
                               for k in range(p)), "leave depot")
        # 约束条件5
        self.model.addConstrs((self.X[i, j, k] + self.X[j, i, k] <= 1
                               for i in range(1, n) for j in range(1, n) for k in range(p)), "no two node link")
        # 约束条件6
        self.model.addConstrs((quicksum(self.X[i, j, k] * self.vrp_data.demand[j]
                                        for i in range(n) for j in range(1, n)) <= self.vrp_data.capacity
                               for k in range(p)), "capacity constraint")

    def addMillerTuckerZemlinContraint(self):
        p = self.vrp_data.trucks
        n = self.vrp_data.dimension
        q = self.vrp_data.demand
        Q = self.vrp_data.capacity
        self.u = self.model.addVars(n - 1, vtype=GRB.CONTINUOUS, ub=Q, name="u")
        self.model.addConstrs((self.u[i] >= q[i + 1] for i in range(n - 1)), "low bound")
        self.model.addConstrs((self.u[j - 1] - self.u[i - 1] >= q[j] - Q * (1 - self.X[i, j, k])
                               for i in range(1, n) for j in range(1, n)
                               for k in range(p) if i != j), "Eliminate subtours")


# 求解整数规划
class VrpSolverM(ActionBase):
    def action(self, vrp_model, vrp_data):
        vrp_model.addMillerTuckerZemlinContraint()
        vrp_model.model.optimize()
        # 添加无解和无界的逻辑
        self.Sol["X"] = vrp_model.model.getAttr("X", vrp_model.X)
        self.fvl = vrp_model.model.objVal

    def __init__(self):
        self.Sol = {}
        self.fvl = 0


# 结果显示
class IntegerProgramDisplay(ActionBase):
    def action(self, vrp_data, solver):
        xv = solver.vrp_solver.Sol["X"]
        colors = ["red", "green", "blue", "black"]
        figure(1)
        for k in range(vrp_data.trucks):
            for i in range(vrp_data.dimension):
                for j in range(vrp_data.dimension):
                    if xv[i, j, k] > .5:
                        plot([vrp_data.node_coord[i][0], vrp_data.node_coord[j][0]],
                             [vrp_data.node_coord[i][1], vrp_data.node_coord[j][1]],
                             linewidth=2, color=colors[k])
        for i in range(vrp_data.dimension):
            scatter(vrp_data.node_coord[i][0],
                    vrp_data.node_coord[i][1],
                    c="k", marker="o")
        title("optimal value = " + str(round(solver.vrp_solver.fvl, 2)))

        show()

        pass

    def __init__(self):
        pass


class IntegerProgrammer(ActionBase):
    def __init__(self, method):
        if method == VRP.Miller_Tucker_Zemlin:
            self.vrp_solver = VrpSolverM()
            self.vrp_modeler = VrpModel()
        elif method == VRP.Ortools_method:
            self.vrp_solver = VrpSolverO()
            self.vrp_modeler = OrToolModel()
        else:
            self.vrp_solver = None
            self.vrp_modeler = None

    def action(self, vrp_data):
        self.vrp_modeler.vrp_data = vrp_data
        self.vrp_modeler.build_model()
        self.vrp_solver.action(self.vrp_modeler, vrp_data)


class VrpProblemSolver(object):
    def __init__(self, file_path):
        self.filePath = file_path
        self.fileParser = None
        self.solver = None
        self.displayer = None

    def parseFile(self):
        self.fileParser.action(self.filePath)

    def solve(self):
        self.solver.action(self.fileParser)

    def displayResult(self):
        self.displayer.action(self.fileParser, self.solver)


class Factory(object):
    @staticmethod
    def CreateProblem(method, file_path):
        if method == VRP.Miller_Tucker_Zemlin:
            vrp = VrpProblemSolver(file_path)
            vrp.fileParser = VrpData()
            vrp.solver = IntegerProgrammer(method)
            vrp.displayer = IntegerProgramDisplay()
        elif method == VRP.Ortools_method:
            vrp = VrpProblemSolver(file_path)
            vrp.fileParser = VrpData()
            vrp.solver = IntegerProgrammer(method)
            vrp.displayer = RoutingDisplay()
        return vrp


# 基本的VRP整数规划模型
class OrToolModel(object):
    def __init__(self):
        self.vrp_data = None
        self.model = None
        self.X = None
        self.u = None
        self.param = None
        self.manager = None

    def build_model(self):
        manager = pywrapcp.RoutingIndexManager(self.vrp_data.dimension, self.vrp_data.trucks, self.vrp_data.depot[0])
        routing = pywrapcp.RoutingModel(manager)
        capacity = [self.vrp_data.capacity] * self.vrp_data.trucks

        def distance_callback(from_index, to_index):
            from_node = manager.IndexToNode(from_index)
            to_node = manager.IndexToNode(to_index)
            return self.vrp_data.dist[(from_node, to_node)]

        transit_callback_index = routing.RegisterTransitCallback(distance_callback)
        routing.SetArcCostEvaluatorOfAllVehicles(transit_callback_index)

        def demand_callback(from_index):
            from_node = manager.IndexToNode(from_index)
            return self.vrp_data.demand[from_node]

        demand_callback_index = routing.RegisterUnaryTransitCallback(demand_callback)
        routing.AddDimensionWithVehicleCapacity(
            demand_callback_index,
            0,
            capacity,
            True,
            'Capacity'
        )

        search_parameters = pywrapcp.DefaultRoutingSearchParameters()
        # search_parameters.first_solution_strategy(
        #     routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC
        # )
        self.model = routing
        self.param = search_parameters
        self.manager = manager


class VrpSolverO(ActionBase):
    def action(self, vrp_model, vrp_data):
        assignment = vrp_model.model.SolveWithParameters(vrp_model.param)
        # 添加无解和无界的逻辑
        results = {}
        manager = vrp_model.manager
        for vehicle in range(vrp_data.trucks):
            idx = vrp_model.model.Start(vehicle)
            route = [manager.IndexToNode(idx)]
            while not vrp_model.model.IsEnd(idx):
                idx = assignment.Value(vrp_model.model.NextVar(idx))
                route.append(manager.IndexToNode(idx))
            results[vehicle] = route

        self.Sol = results
        self.fvl = 0

    def __init__(self):
        self.Sol = {}
        self.fvl = 0


class RoutingDisplay(ActionBase):
    def action(self, vrp_data, solver):
        total_dist = 0
        xv = solver.vrp_solver.Sol
        colors_already = ["red", "green", "blue", "black", "yellow"]
        figure(1)
        for k in range(vrp_data.trucks):
            route = xv[k]
            color = [random.random(), random.random(), random.random()]
            for i in range(len(route) - 1):
                plot([vrp_data.node_coord[route[i]][0], vrp_data.node_coord[route[i + 1]][0]],
                     [vrp_data.node_coord[route[i]][1], vrp_data.node_coord[route[i + 1]][1]],
                     linewidth=2, color=color)
                total_dist += vrp_data.dist[route[i], route[i + 1]]

        for i in range(vrp_data.dimension):
            scatter(vrp_data.node_coord[i][0],
                    vrp_data.node_coord[i][1],
                    c="k", marker="o")
        title("optimal value = " + str(round(total_dist, 2)))

        show()

        pass

    def __init__(self):
        pass
