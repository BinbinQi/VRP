classdef CommonTool
    properties(Constant)
        SA_params = struct("MaxIt", 1200,...
            "MaxIt2", 80,...
            "T0", 100,...
            "alpha", 0.98);
    end
    methods(Static)
        function tourIdxs = find_sub_tours(x)
            Gsol = digraph(x);
            tourIdxs = conncomp(Gsol, "OutputForm","cell");
            tourIdxs = tourIdxs(cellfun(@(x)length(x)>=3, tourIdxs));
        end
    end

    methods(Static)
        function sol = create_random_solution(vrp_data)
            sol = 1 + randperm(vrp_data.dimension +  vrp_data.trucks - 2);
        end

        function sol = parse_solution(vrp_data, pos)
            % 解码
            n = vrp_data.dimension;
            m = vrp_data.trucks;
            del_pos = find(pos > n);
            from = [0 del_pos] + 1;
            to = [del_pos n+m-1] - 1;
            L = arrayfun(@(s,e)pos(s:e), from, to, "UniformOutput", false);
            [D, UC] = deal(zeros(m,1));
            for k = 1 : m
                if isempty(L{k})
                    continue
                end
                R = L{k};
                D(k) = vrp_data.dist(1, R(1)) + vrp_data.dist(R(end), 1);
                for j = 1 : length(R)-1
                    D(k) = D(k) + vrp_data.dist(R(j), R(j+1));
                end
                UC(k) = sum(vrp_data.demand(R,2));
            end
            CV = max(UC./vrp_data.capacity-1, 0);
            MeanCV = mean(CV);
            sol.L = L;
            sol.D = D;
            sol.MaxD = max(D);
            sol.TotalD = sum(D);
            sol.UC = UC;
            sol.CV = CV;
            sol.MeanCV = MeanCV;
            sol.IsFeasible = MeanCV ==0;
        end

        function [fvl, sol] = fitness_value(vrp_data, pos, sa)
            sol = CommonTool.parse_solution(vrp_data, pos);
            dist_value = sa.eta*sol.TotalD+(1-sa.eta)*sol.MaxD;
            fvl = dist_value*(1+sa.beta*sol.MeanCV);
        end

    end

    methods(Static)
        function q = swap(q)
            pos = randsample(numel(q), 2);
            q(pos) = q(flip(pos));
        end

        function q = reverse(q)
            pos = sort(randsample(numel(q), 2));
            q(pos(1):pos(2)) = q(pos(2):-1:pos(1));
        end

        function q = insert(q)
            pos = sort(randsample(numel(q), 2));
            q = [q(1:pos(1)-1), q(pos(1)+1:pos(2)), q(pos(1)), q(pos(2)+1:end)];
        end
    end

    methods(Static)
        function q = creat_random_neightbor(q)
            m = randi([1 3]);
            switch m
                case 1
                    q = CommonTool.swap(q);
                case 2
                    q = CommonTool.reverse(q);
                case 3
                    q = CommonTool.insert(q);
            end
        end
    end
end

