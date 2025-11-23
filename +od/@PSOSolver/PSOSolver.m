classdef PSOSolver < od.Solver

  properties
    max_support
    options
  end

  methods
    function obj = PSOSolver(problem, max_support, options)
      arguments
        problem
        max_support (1,1) double {mustBePositive}
        options.quiet logical = true   % placeholder; not used yet
      end

      % Call parent Solver constructor with solver name "PSO"
      obj@od.Solver(problem, "PSO");

      obj.max_support = max_support;
      obj.options     = options;  % stored for future use (PSO options later)
    end
  end

  methods (Access = protected)
    function [X, w, M, crit] = solve_core(obj)
      % TEMP: no PSO yet. Just compute lb, ub, nvars and return them.

      v     = obj.problem.num_variables;
      k     = obj.max_support;
      range = obj.problem.range;
      nvars = v * k + k;

      % Calculate the bounds
      lb_coords  = -range * ones(v * k, 1);
      ub_coords  =  range * ones(v * k, 1);
      lb_weights = zeros(k, 1);
      ub_weights = ones(k, 1);
      lb = [lb_coords; lb_weights];
      ub = [ub_coords; ub_weights];

      % Call particleswarm
      objective = @(x) obj.objectiveFunction(x);
      x_opt = particleswarm(objective, nvars, lb, ub);

      % extract information
      support_points = x_opt(1: v*k);
      support_points = reshape(support_points, [k, v]);
      weights = x_opt(v*k + 1 : v*k + k);
      weights = weights(1:k) / sum(weights(1:k));

      % Return them in the slots expected by Solver/DesignResult
      X    = support_points;      % so result.X = lb
      w    = weights;      % so result.w = ub
      M    = nvars;   % so result.M = nvars (scalar)
      crit = NaN;     % no criterion yet
    end

    function phi = objectiveFunction(obj, x)
      v = obj.problem.num_variables;
      k = obj.max_support;
      d = obj.problem.max_degree;
      h = nchoosek(v + d, d);
      M = zeros(h, h);

      % unpack
      support_points = reshape(x(1 : v * k), [k, v]);
      weights        = x(v * k + 1 : v * k + k);

      % safe normalize weights
      s = sum(weights);
      if s <= 0 || ~isfinite(s)
        phi = 1e12;    % big penalty for degenerate particle
        return;
      end
      weights = weights / s;

      % information matrix
      Mi = obj.problem.informationTensor(support_points);
      for i = 1:k
        M = M + weights(i) * Mi(:, :, i);
      end

      switch upper(obj.problem.criteria)
        case "D"
          detM = det(M);
          if detM <= 0 || ~isfinite(detM)
            phi = 1e12;
          else
            phi = -log(detM);
          end

        case "A"
          % A-optimal: minimize trace(inv(M))
          phi = trace(inv(M));

        case "E"
          % E-optimal: minimize 1 / lambda_min(M) or -lambda_min(M), your choice
          lambda_min = min(eig(M));
          if lambda_min <= 0 || ~isfinite(lambda_min)
            phi = 1e12;
          else
            phi = 1 / lambda_min;
          end

        case "I"
          % placeholder until you wire in your I-optimal stuff
          phi = 0;

        otherwise
          error("Unknown criterion: %s", obj.problem.criteria);
      end
    end

  end
end
