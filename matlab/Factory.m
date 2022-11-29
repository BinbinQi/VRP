classdef Factory < handle
    methods(Static)
        function vrp = CreateProblem(method, file_path)
            switch method
                case VRP.Dantzig_Fulkerson_Johnson
                    vrp = vrp_problem_solver(file_path);
                    vrp.fileParser = vrp_data;
                    vrp.solver = integer_programmer(VRP.Dantzig_Fulkerson_Johnson);
                    vrp.displayer = integer_pro_display;
                case VRP.Miller_Tucker_Zemlin
                    vrp = vrp_problem_solver(file_path);
                    vrp.fileParser = vrp_data;
                    vrp.solver = integer_programmer(VRP.Miller_Tucker_Zemlin);
                    vrp.displayer = integer_pro_display;
                case VRP.Simulated_Annealing
                    vrp = vrp_problem_solver(file_path);
                    vrp.fileParser = vrp_data;
                    vrp.solver = heuristic_programmer(VRP.Simulated_Annealing);
                    vrp.displayer = heuristic_pro_display;
                case VRP.Simple_Integer_Model
                    vrp = vrp_problem_solver(file_path);
                    vrp.fileParser = vrp_data;
                    vrp.solver = integer_programmer(VRP.Simple_Integer_Model);
                    vrp.displayer = integer_pro_display_s;
            end
        end
    end
end