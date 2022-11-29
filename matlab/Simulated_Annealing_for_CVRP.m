classdef Simulated_Annealing_for_CVRP < actionBase
    properties
        eta
        beta
    end
    properties
        solution
    end

    methods
        function obj = Simulated_Annealing_for_CVRP(eta, beta)
            obj.eta = eta;
            obj.beta = beta;
        end
        function action(obj,vrp_data)
            % 初始解的生成
            x.Position = CommonTool.create_random_solution(vrp_data);
            [x.Cost, x.Sol] = CommonTool.fitness_value(vrp_data, x.Position, obj);
            % 更新最优解
            best_sol = x;
            best_cost_list = zeros(CommonTool.SA_params.MaxIt, 1);
            % 初始温度
            T = CommonTool.SA_params.T0;
            % 迭代计算
            for it = 1 : CommonTool.SA_params.MaxIt
                for inner_it = 1 : CommonTool.SA_params.MaxIt2
                    xnew.Position = CommonTool.creat_random_neightbor(x.Position);
                    [xnew.Cost, xnew.Sol] = CommonTool.fitness_value(vrp_data, xnew.Position, obj);
                    if xnew.Cost <= x.Cost
                        x = xnew;
                    else
                        delta = xnew.Cost - x.Cost;
                        p = exp(-delta/T);
                        if rand <= p
                            x = xnew;
                        end
                    end

                    if x.Cost <= best_sol.Cost
                        best_sol = x;
                    end
                end
                best_cost_list(it) = best_sol.Cost;
                T = T*CommonTool.SA_params.alpha;
                if best_sol.Sol.IsFeasible
                    obj.solution = best_sol;                    
%                     fprintf("%d:%f *\n",it, best_sol.Cost);
%                 else
%                     fprintf("%d:%f\n",it, best_sol.Cost);
                end
            end
            
        end
    end
end