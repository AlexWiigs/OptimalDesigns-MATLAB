classdef DesignResult
  properties
    X                 % support points
    w                 % weights
    M                 % information matrix
    criterion_value   % scalar criterion (e.g. log det M)
    solver_name       % e.g. "CVX"
    problem           % handle back to the DesignProblem (optional)
  end

  methods
    function obj = DesignResult(X, w, M, crit, solver_name, problem)
      obj.X               = X;
      obj.w               = w;
      obj.M               = M;
      obj.criterion_value = crit;
      if nargin >= 5
        obj.solver_name = solver_name;
      end
      if nargin >= 6
        obj.problem = problem;
      end
    end

    function [X_out, w_out] = filterWeights(obj, options)

      arguments
        obj
        options.threshold   double  = 0.01
        options.renormalize logical = false
      end

      threshold   = options.threshold;
      renormalize = options.renormalize;

      X_in = obj.X;
      w_in = obj.w;

      % filter
      mask  = (w_in >= threshold);
      X_out = X_in(mask, :);
      w_out = w_in(mask);

      % optional renormalization
      if renormalize && ~isempty(w_out)
        total = sum(w_out);
        if total > 0
          w_out = w_out ./ total;
        end
      end
    end
  end
end
