classdef vrp_model < handle
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
            x = optimvar("x", n, n, p, Type="integer", LowerBound=0, UpperBound=1);
            obj.model = optimproblem("Description","CVRP Model");
            dijk = repmat(obj.vrp_data.dist,1,1,p);
            obj.model.Objective = sum(dijk.*x, "all");
            obj.model.ObjectiveSense = "min";
            obj.model.Constraints.("no_itself") = sum(repmat(eye(n),1,1,p).*x,"all")==0;
            obj.model.Constraints.("leave_node_it_enters") = squeeze(sum(x,1)) == squeeze(sum(x,2));
            obj.model.Constraints.("every_node_enter_once") = sum(sum(x(:,2:end,:),1),3) == 1;
            obj.model.Constraints.("every_vehicle_leaves_depot") = sum(x(1,2:end,:),2) == 1;
            expr = optimexpr(p);
            for k = 1 : p
                expr(k) = sum(x(:,2:end,k)*obj.vrp_data.demand(2:end,2));
                obj.model.Constraints.("Two_node_tour_constraint_"+k) = x(2:end, 2:end, k) + x(2:end, 2:end, k)' <= 1; 
            end
            obj.model.Constraints.("Capacity_constraint") = expr <= obj.vrp_data.capacity;
            obj.X = x;
        end

        function add_subtour_contraints_method_2(obj, t, k, tourIdx)
            for i = 1 : length(tourIdx)
                node_in_S = tourIdx{i}+1;
                node_not_in_S = setdiff(1:obj.vrp_data.dimension, node_in_S);
                obj.model.Constraints.("Capacity_constraint_"+t+"_"+k+"_"+i) = sum(sum(obj.X(node_in_S, node_not_in_S,k), 1))>=2;
            end
        end

        function add_subtour_contraints_method_1(obj, t, k, tourIdx)
            for i = 1 : length(tourIdx)
                node_in_S = tourIdx{i}+1;
                obj.model.Constraints.("Capacity_constraint_"+t+"_"+k+"_"+i) = sum(obj.X(node_in_S, node_in_S,k), "all")<=length(node_in_S)-1;
            end
        end

        function add_miller_tucker_zemlin_contraints(obj)
            n = obj.vrp_data.dimension;
            u = optimvar("u", n-1);
            obj.model.Constraints.("lowBounds") = u >= obj.vrp_data.demand(2:end,2);
            obj.model.Constraints.("uppBounds") = u <= obj.vrp_data.capacity;
            for k = 1 : obj.vrp_data.trucks
                for i = 2 : n
                    for j = 2 : n
                        if i == j
                            continue
                        end
                        obj.model.Constraints.("Eliminate_SubTours_"+k+"_"+i+"_"+j) = u(j-1)-u(i-1) >= obj.vrp_data.demand(j,2)-obj.vrp_data.capacity*(1-obj.X(i,j,k));
                    end
                end
            end
        end
    end
end