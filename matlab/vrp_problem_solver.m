classdef vrp_problem_solver <  handle
    properties
        fileParser
        solver
        displayer
    end
    properties
        file_path
    end

    methods
        function obj = vrp_problem_solver(file_path)
            obj.file_path = file_path;
        end

        function parseFile(obj)
            obj.fileParser.action(obj.file_path);
        end

        function solve(obj)
            obj.solver.action(obj.fileParser);
        end

        function displayResult(obj)
            obj.displayer.action(obj.fileParser, obj.solver);
        end
    end
end