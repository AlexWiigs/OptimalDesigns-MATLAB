classdef (Abstract) Solver < handle
    %SOLVER Abstract parent for all design solvers (CVX, PSO, ...).

    properties
        problem            % DesignProblem associated with this solver
        algorithm          % "CVX", "PSO", etc.

        criterion_value    % value of D/A/E/I criterion at the solution
        support_points     % matrix of support points
        weights            % corresponding weights
        info_matrix        % final information matrix
        status             % solver status / message
        runtime            % wall-clock time in seconds
    end

    methods
        function obj = Solver(problem, algorithm)
            % Constructor with default settings.
            obj.problem = problem;
            if nargin < 2, algorithm = class(obj); end
            obj.algorithm = algorithm;
            obj.status    = "not run";
            obj.runtime   = NaN;
        end

        function result = solve(obj)
            % High-level template: timing + core algorithm.
            t_start = tic;
            try
                % Child returns *all* final quantities.
                [obj.support_points, obj.weights, ...
                 obj.info_matrix, obj.criterion_value] = obj.solve_core();

                obj.status = "ok";
            catch ME
                obj.status          = "failed: " + string(ME.message);
                obj.support_points  = [];
                obj.weights         = [];
                obj.info_matrix     = [];
                obj.criterion_value = NaN;
            end
            obj.runtime = toc(t_start);

            % Pack a simple result struct to return.
            result = struct( ...
                'solver',          obj.algorithm, ...
                'status',          obj.status, ...
                'support_points',  obj.support_points, ...
                'weights',         obj.weights, ...
                'info_matrix',     obj.info_matrix, ...
                'criterion_value', obj.criterion_value, ...
                'runtime',         obj.runtime );
        end
    end

    methods (Abstract, Access = protected)
        % Each child must implement this and is responsible for computing
        % the information matrix and the criterion however it likes.
        [x, w, M, crit] = solve_core(obj)
    end
end
