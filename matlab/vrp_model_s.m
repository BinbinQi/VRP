classdef vrp_model_s < handle
    properties
        vrp_data
        model
    end
    properties
        X
    end
    methods
        function build_model(obj)
            p = obj.vrp_data.trucks;
            n = obj.vrp_data.dimension;

            x = optimvar("x", n+1, n+1, Type="integer", LowerBound=0, UpperBound=1);
            obj.model = optimproblem("Description","CVRP Model");
            dij = [[obj.vrp_data.dist;obj.vrp_data.dist(1,:)],[obj.vrp_data.dist(:,1);0]];
            obj.model.Objective = sum(dij.*x, "all");
            obj.model.ObjectiveSense = "min";
            
            obj.model.Constraints.("no_to_itself") = trace(x) == 0;
            obj.model.Constraints.("out_once") = sum(x(2:n, 2:end), 2) == 1;
            obj.model.Constraints.("leave_node_it_enters") = sum(x(2:n, 2:end), 2) == sum(x(1:n, 2:n), 1)';
            obj.model.Constraints.("trucks") = sum(x(1,2:n)) <= p;

            u = optimvar("u", n+1);
            q = obj.vrp_data.demand([1:end,1],2);
            Q = obj.vrp_data.capacity;
            obj.model.Constraints.("lowBounds") = u >= q;
            obj.model.Constraints.("uppBounds") = u <= Q;            
            for i = 1 : n+1
                for j = 1 : n+1
                    if i == j
                        continue
                    end
                obj.model.Constraints.("Eliminate_SubTours_"+i+"_"+j) = u(j)-u(i) >= q(j)*x(i,j)-Q*(1-x(i,j));
                end
            end

            obj.X = x;
        end

    end
end