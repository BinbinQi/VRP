classdef vrp_solver_s < actionBase
    properties
        sol
        fvl
    end

    methods
        function action(obj, vrp_model, ~)
            addpath("C:\gurobi951\win64\matlab");
            addpath("C:\gurobi951\win64\examples\matlab");
            [obj.sol, obj.fvl,~,~,~] = vrp_model.model.solve;               
            rmpath("C:\gurobi951\win64\matlab");
            rmpath("C:\gurobi951\win64\examples\matlab");
        end
    
    end

end