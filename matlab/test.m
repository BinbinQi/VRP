clear;clc;close all
%% 基于求解的线性规划
f = [15 11 18];
A = [2 4 2
    4 3 1];
b = [310 450]';
Aeq = [1 1 1];
beq = 150;
lb = zeros(1, 3);
[x,fval,exitflag,output,lambda] = linprog(f, A, b, Aeq, beq, lb); %#ok<*ASGLU> 

%% 基于求解的整数规划
f = [15 11 18];
A = [2 4 2
    4 3 1];
b = [310 450]';
Aeq = [1 1 1];
beq = 150;
[x,fval,exitflag,output] = intlinprog(f, 1:3, A, b, Aeq, beq, lb);

%% 基于问题的线性规划
x1 = optimvar("x"+1, Type="continuous", LowerBound=0);
x2 = optimvar("x"+2, Type="continuous", LowerBound=0);
x3 = optimvar("x"+3, Type="continuous", LowerBound=0);
prob = optimproblem("Description", "ex1");
prob.Constraints.("C1") = x1 + x2 + x3 == 150;
prob.Constraints.("C2") = 2*x1 + 4*x2 + 2*x3 <= 310;
prob.Constraints.("C3") = 4*x1 + 3*x2 + x3 <= 450;
prob.ObjectiveSense = "min";
prob.Objective = 15*x1 + 11*x2 + 18*x3;
[sol, fvl] = prob.solve

%% 基于问题的线性规划
x1 = optimvar("x"+1, Type="integer", LowerBound=0);
x2 = optimvar("x"+2, Type="integer", LowerBound=0);
x3 = optimvar("x"+3, Type="integer", LowerBound=0);
prob = optimproblem("Description", "ex1");
prob.Constraints.("C1") = x1 + x2 + x3 == 150;
prob.Constraints.("C2") = 2*x1 + 4*x2 + 2*x3 <= 310;
prob.Constraints.("C3") = 4*x1 + 3*x2 + x3 <= 450;
prob.ObjectiveSense = "min";
prob.Objective = 15*x1 + 11*x2 + 18*x3;
[sol, fvl] = prob.solve;

%% MATLAB调用Gurobi
addpath("C:\gurobi951\win64\matlab");
addpath("C:\gurobi951\win64\examples\matlab");
x1 = optimvar("x"+1, Type="integer", LowerBound=0);
x2 = optimvar("x"+2, Type="integer", LowerBound=0);
x3 = optimvar("x"+3, Type="integer", LowerBound=0);
prob = optimproblem("Description", "ex1");
prob.Constraints.("C1") = x1 + x2 + x3 == 150;
prob.Constraints.("C2") = 2*x1 + 4*x2 + 2*x3 <= 310;
prob.Constraints.("C3") = 4*x1 + 3*x2 + x3 <= 450;
prob.ObjectiveSense = "min";
prob.Objective = 15*x1 + 11*x2 + 18*x3;
[sol, fvl] = prob.solve

rmpath("C:\gurobi951\win64\matlab");
rmpath("C:\gurobi951\win64\examples\matlab");

