classdef DesignResult
  properties
    criterion_value      % scalar criterion (e.g. log det M)
    solver_name          % e.g. "CVX", "PSO"
    runtime double = NaN % computation time in seconds
    X                    % unfiltered support points (k x v)
    w                    % unfiltered weights (k x 1)
    M                    % information matrix
    problem              % handle back to the DesignProblem
  end

  methods
    function obj = DesignResult(X, w, M, crit, solver_name, problem, runtime)
      arguments
        X
        w
        M
        crit
        solver_name = ""
        problem     = []
        runtime     double = NaN
      end

      obj.X               = X;
      obj.w               = w(:);    % ensure column
      obj.M               = M;
      obj.criterion_value = crit;
      obj.solver_name     = solver_name;
      obj.problem         = problem;
      obj.runtime         = runtime;
    end

    % Implemented in @DesignResult/filterWeights.m
    [X_out, w_out] = filterWeights(obj, options)
    stats          = checkOptimality(obj, u_dim, options)
  end
end
