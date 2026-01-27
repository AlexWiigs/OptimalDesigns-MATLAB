classdef PSOSolver < od.Solver

  properties
    max_support              % maximum number of support points
    u_dim                    % integration grid dimension for I-optimality
    options                  % optimoptions(@particleswarm)
  end

  methods
    function obj = PSOSolver(problem, max_support, opts)

      arguments
        problem
        max_support (1,1) double {mustBePositive}
        opts.u_dim      (1,1) double {mustBePositive} = 5
        opts.options                                  = []
      end

      % superclass ctor
      obj@od.Solver(problem, "PSO");
      obj.max_support = max_support;
      obj.u_dim       = opts.u_dim;

      % default PSO options if none supplied
      if isempty(opts.options)
        obj.options = optimoptions(@particleswarm, ...
                                   "Display", "off");
      else
        obj.options = opts.options;
      end
    end
  end

  methods (Access = protected)
    function [X, w, M, crit, runtime] = solve_core(obj)
      v     = obj.problem.num_variables;
      k     = obj.max_support;
      range = obj.problem.range;
      nvars = v * k + k;

      % bounds for coordinates and weights
      lb_coords  = -range * ones(v * k, 1);
      ub_coords  =  range * ones(v * k, 1);
      lb_weights = zeros(k, 1);
      ub_weights = ones(k, 1);
      lb = [lb_coords; lb_weights];
      ub = [ub_coords; ub_weights];

      % PSO call
      objective    = @(x) obj.objectiveFunction(x);
      start_timer  = tic;
      [x_opt, fval] = particleswarm(objective, nvars, lb, ub, obj.options);
      runtime = toc(start_timer);

      % extract optimal particle into support points and weights
      support_points = reshape(x_opt(1 : v * k), [k, v]);
      weights        = x_opt(v * k + 1 : v * k + k);
      weights        = weights(1:k) / sum(weights(1:k));

      % compute optimal information matrix
      Mi = obj.problem.informationTensor(support_points);
      h  = size(Mi, 1);
      M  = zeros(h, h);
      for i = 1:k
        M = M + weights(i) * Mi(:, :, i);
      end
      M = 0.5 * (M + M'); % symmetrize for numerical stability

      % outputs
      X = support_points;
      w = weights;

      switch upper(obj.problem.criteria)

        case "D"
          % Report det(M)
          [R, pflag] = chol(M);
          if pflag ~= 0
            % not positive definite => undefined determinant for D-opt reporting
            crit = NaN;
          else
            crit = exp(2 * sum(log(diag(R))));
          end

        case "A"
          crit = fval;

        case "E"
          % Report lambda_min(M)
          eigvals = eig(M);
          crit    = min(eigvals);

        case "I"
          crit = fval;

        otherwise
          error("Unknown criterion: %s", obj.problem.criteria);
      end
    end

    function phi = objectiveFunction(obj, x)
      v = obj.problem.num_variables;
      k = obj.max_support;
      d = obj.problem.max_degree;
      h = nchoosek(v + d, d);
      M = zeros(h, h);

      % unpack particle into support points and weights
      support_points = reshape(x(1 : v * k), [k, v]);
      weights        = x(v * k + 1 : v * k + k);

      % normalize weights and penalize degenerate particles
      s = sum(weights);
      if s <= 0 || ~isfinite(s)
        phi = 1e12;              % big penalty
        return;
      end
      weights = weights / s;

      % build information matrix
      Mi = obj.problem.informationTensor(support_points);
      for i = 1:k
        M = M + weights(i) * Mi(:, :, i);
      end
      M = 0.5 * (M + M'); % symmetrize for numerical stability

      % evaluate optimality criterion
      switch upper(obj.problem.criteria)
        case "D"
          detM = det(M);
          if detM <= 0 || ~isfinite(detM)
            phi = 1e12;
          else
            phi = -log(detM);    % maximize det(M) via minimizing -log det(M)
          end

        case "A"
          % A-optimal: minimize trace(M^{-1})
          phi = trace(inv(M)); %% NOTE: less stable

        case "E"
          % E-optimal: minimize 1 / lambda_min(M)
          lambda_min = min(eig(M));
          if lambda_min <= 0 || ~isfinite(lambda_min)
            phi = 1e12;
          else
            phi = 1 / lambda_min;
          end

        case "I"
          % I-optimal: average prediction variance on integration grid
          V        = obj.problem.predictVariance(obj.u_dim);
          Vsym     = 0.5 * (V + V.');
          Vsqrt    = sqrtm(Vsym);
          Vsqrt    = 0.5 * (Vsqrt + Vsqrt.');
          VsqrtInv = inv(Vsqrt);

          MV  = VsqrtInv * M * VsqrtInv';
          MV  = 0.5 * (MV + MV.');
          phi = trace(inv(MV));

        otherwise
          error("Unknown criterion: %s", obj.problem.criteria);
      end
    end

  end
end
