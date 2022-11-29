classdef vrp_solver_d < actionBase
    properties
        sol
        fvl
    end

    methods
        function action(obj, vrp_model, vrp_data)
            addpath("C:\gurobi952\win64\matlab");
            addpath("C:\gurobi952\win64\examples\matlab");
            t = 1;
            while true
                [obj.sol, obj.fvl,~,~,~] = vrp_model.model.solve;
                subtours = 0;
                for k = 1 : vrp_data.trucks
                    x = obj.sol.x(2:end,2:end,k) > 0.5;
                    tourIdxs = CommonTool.find_sub_tours(x);
                    if ~isempty(tourIdxs)
                        vrp_model.add_subtour_contraints_method_1(t, k, tourIdxs);
                    end
                    subtours = subtours + length(tourIdxs);
                end
                if subtours == 0
                    break
                end
                t = t + 1;
            end
            rmpath("C:\gurobi952\win64\matlab");
            rmpath("C:\gurobi952\win64\examples\matlab");
        end
    
    end

end