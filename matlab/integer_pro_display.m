classdef integer_pro_display < actionBase
    methods
        function action(~, vrp_data, solver)
            figure;
            rng(1);
            colormaps = hsv(vrp_data.trucks);
            scatter(vrp_data.node_coord(:,2), vrp_data.node_coord(:,3));
            text(vrp_data.node_coord(:,2)+.5, vrp_data.node_coord(:,3)+.5,...
                string(1:vrp_data.dimension));
            hold on
            plot(vrp_data.node_coord(1,2), vrp_data.node_coord(1,3), "d", "MarkerSize",10);
            for k = 1 : vrp_data.trucks
                sol_truck = solver.vrp_solver.sol.x(:,:, k);
                [i,j] = find(sol_truck > .5);
                line([vrp_data.node_coord(i,2),vrp_data.node_coord(j,2)]',...
                    [vrp_data.node_coord(i,3),vrp_data.node_coord(j,3)]',...
                    "Color", 0.8*colormaps(k,:),...
                    "LineWidth", 2);
            end
            title("optimal value: " + solver.vrp_solver.fvl);
            hold off
        end
    end
end