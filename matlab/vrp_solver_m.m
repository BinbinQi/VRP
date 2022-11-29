classdef vrp_solver_m < actionBase
    properties
        sol
        fvl
    end

    methods
        function action(obj, vrp_model, ~)
            addpath("C:\gurobi951\win64\matlab");
            addpath("C:\gurobi951\win64\examples\matlab");
            vrp_model.add_miller_tucker_zemlin_contraints;
            [obj.sol, obj.fvl,~,~,~] = vrp_model.model.solve;               
            rmpath("C:\gurobi951\win64\matlab");
            rmpath("C:\gurobi951\win64\examples\matlab");
        end
    
    end

end