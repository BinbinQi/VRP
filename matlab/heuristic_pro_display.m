classdef heuristic_pro_display < actionBase
    methods
        function action(~, vrp_data, solver)
            figure;
            L = solver.vrp_solver.solution.Sol.L;
            Colors = hsv(vrp_data.trucks);
            for j = 1 : vrp_data.trucks
                if isempty(L{j})
                    continue;
                end
                X = vrp_data.node_coord([1, L{j}, 1], 2);
                Y = vrp_data.node_coord([1, L{j}, 1], 3);
                Color = 0.8*Colors(j,:);
                plot(X,Y,'-o',...
                    'Color',Color,...
                    'LineWidth',2,...
                    'MarkerSize',10,...
                    'MarkerFaceColor','white');
                hold on;
            end
            plot(vrp_data.node_coord(1, 2), ...
                 vrp_data.node_coord(1, 3),'ks',...
                'LineWidth',2,...
                'MarkerSize',18,...
                'MarkerFaceColor','yellow');
            title("optimal value: " + solver.vrp_solver.solution.Sol.TotalD)
            hold off;
            grid on;
            axis equal;
        end
    end
end