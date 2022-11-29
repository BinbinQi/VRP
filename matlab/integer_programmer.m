classdef integer_programmer < actionBase
    properties
        vrp_solver
        vrp_modeler
    end

    methods
        function obj = integer_programmer(method)
            if method == VRP.Dantzig_Fulkerson_Johnson
                obj.vrp_solver = vrp_solver_d;
                obj.vrp_modeler = vrp_model;
            elseif method == VRP.Miller_Tucker_Zemlin
                obj.vrp_solver = vrp_solver_m;
                obj.vrp_modeler = vrp_model;
            else 
                obj.vrp_solver = vrp_solver_s;
                obj.vrp_modeler = vrp_model_s;
            end
            
        end

        function action(obj, vrp_data)
            obj.vrp_modeler.vrp_data = vrp_data;
            obj.vrp_modeler.build_model;
            obj.vrp_solver.action(obj.vrp_modeler, vrp_data);            
        end
    end
end