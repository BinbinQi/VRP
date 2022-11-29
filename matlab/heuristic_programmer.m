classdef heuristic_programmer < actionBase
    properties
        vrp_solver
    end

    methods
        function obj = heuristic_programmer(method)
            if method == VRP.Simulated_Annealing  
                obj.vrp_solver = Simulated_Annealing_for_CVRP(0.5, 5);
            else
                
            end
            
        end

        function action(obj, vrp_data)
            obj.vrp_solver.action(vrp_data);            
        end
    end
end