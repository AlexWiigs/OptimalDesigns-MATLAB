classdef PSOSolver < handle
  properties
    problem
    max_support
    lb
    ub
    nvars
    options
  end

  methods
    function obj = PSOSolver(problem, max_support, options)
      obj.problem     = problem;
      obj.max_support = max_support;

      if nargin < 3 || isempty(options)
        obj.options = optimoptions('particleswarm');
      else
        obj.options = options;
      end
      obj.computeBounds();
    end

    function result = solve(obj)
      lb    = obj.lb;
      ub    = obj.ub;
      nvars = obj.nvars;

      crit = @(x) obj.objectiveFunction(x);

      [x_opt, fval, exitflag, output] = particleswarm( ...
        crit, nvars, lb, ub, obj.options);

      v = obj.problem.num_variables;
      k = obj.max_support;

      support_points = reshape(x_opt(1 : v * k), [k, v]);   % k×v

      weights = x_opt(v * k + 1 : v * k + k);          % k×1
      weights = weights(1:end) / sum(weights(1:end));

      result = struct();
      result.solver          = "PSO";
      result.criterion       = "D";
      result.status          = exitflag;
      result.criterion_value = fval;
      result.support_points  = support_points;
      result.weights         = weights;
      result.lb              = lb;
      result.ub              = ub;
      result.nvars           = nvars;
      result.output          = output;
      result.raw_solution    = x_opt;
    end
  end

  methods (Access = private)
    function computeBounds(obj)
      v     = obj.problem.num_variables;
      k     = obj.max_support;
      range = obj.problem.range;

      lb_coords   = -range * ones(v * k, 1);
      ub_coords   =  range * ones(v * k, 1);
      lb_weights  = zeros(k, 1);
      ub_weights  = ones(k, 1);

      obj.lb    = [lb_coords; lb_weights];
      obj.ub    = [ub_coords; ub_weights];
      obj.nvars = v * k + k;
    end

    function val = objectiveFunction(obj, x)
      % --- Unpack x into points and weights ---
      v = obj.problem.num_variables;
      k = obj.max_support;

      support_points = reshape(x(1 : v * k), [k, v]);   % k×v
      weights        = x(v * k + 1 : v * k + k);        % k×1
      weights(1:end) = weights(1:end) / sum( weights(1:end));
      Mi_tensor = obj.problem.informationTensor(support_points);  

      % Combine: M = sum_j w_j * M_j
      [m1, m2, kk] = size(Mi_tensor);
      M = zeros(m1, m2);
      for j = 1:kk
          M = M + weights(j) * Mi_tensor(:, :, j);
      end

      % --- Evaluate D‐optimal criterion ---
      d = det(M);

      % Debug friendliness: show actual numerical pathologies
      if d <= 0 || ~isfinite(d)
          val = 1e12;   % very large penalty
          return;
      end

      val = -log(d);
    end
  end
end
