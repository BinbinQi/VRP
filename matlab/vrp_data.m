classdef vrp_data < handle
    properties
        name
        comment
        type
        dimension
        edge_weight_type
        capacity
        node_coord
        demand
        depot
        trucks
    end

    properties
        dist
    end

    methods
        
        function action(obj, file_path)
            fid = fopen(file_path);
            flag = 0;
            obj.node_coord = [];
            obj.demand = [];
            obj.depot = [];
            while true
                line_ex = strtrim(fgetl(fid));
                if isequal(line_ex, "EOF")
                    break
                end
                if startsWith(line_ex, "NAME")
                    str_split = split(line_ex, ":");
                    obj.name = strtrim(str_split{end});
                    obj.trucks = str2double(regexp(obj.name,"\d+$","match","once"));
                elseif startsWith(line_ex, "COMMENT")
                    str_split = split(line_ex, ":");
                    obj.comment = strtrim(str_split{end});
                elseif startsWith(line_ex, "TYPE")
                    str_split = split(line_ex, ":");
                    obj.type = strtrim(str_split{end});
                elseif startsWith(line_ex, "DIMENSION")
                    str_split = split(line_ex, ":");
                    obj.dimension = str2double(str_split{end});
                elseif startsWith(line_ex, "EDGE_WEIGHT_TYPE")
                    str_split = split(line_ex, ":");
                    obj.edge_weight_type = strtrim(str_split{end});
                elseif startsWith(line_ex, "CAPACITY")
                    str_split = split(line_ex, ":");
                    obj.capacity = str2double(str_split{end});
                elseif startsWith(line_ex, "NODE_COORD_SECTION")
                    flag = 1;
                elseif startsWith(line_ex, "DEMAND_SECTION")
                    flag = 2;
                elseif startsWith(line_ex, "DEPOT_SECTION")
                    flag = 3;
                else
                    d = sscanf(line_ex,'%d')';
                    if flag == 1
                        obj.node_coord = [obj.node_coord; d];
                    elseif flag == 2
                        obj.demand = [obj.demand; d];
                    elseif flag == 3
                        obj.depot = [obj.depot; d];
                    end
                end

            end
            obj.dist = dist(obj.node_coord(:,2:end), obj.node_coord(:,2:end)'); %#ok<CPROPLC> 
        end
    end
end