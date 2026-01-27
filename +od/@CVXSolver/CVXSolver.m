classdef CVXSolver < od.Solver

  properties
    % covering is either:
    %  - scalar grid resolution (old u_dim)
    %  - k-by-v candidate matrix (custom covering)
    covering

    quiet     logical = true
    precision string  = "default"
  end

  methods
    function obj = CVXSolver(problem, covering, options)
      arguments
        problem
        covering {mustBeNumeric}
        options.precision string = "default"
        options.quiet     logical = true
      end

      obj@od.Solver(problem, "CVX");
      obj.covering  = covering;
      obj.quiet     = options.quiet;
      obj.precision = options.precision;

      % Validate covering
      if isscalar(covering)
        if ~(isfinite(covering) && covering > 0)
          error("covering scalar must be a positive finite grid resolution.");
        end
      else
        v = obj.problem.num_variables;
        if size(covering,2) ~= v
          error("Custom covering must be k-by-%d (num_variables).", v);
        end
      end
    end
  end

  methods (Access = protected)
    function [X, w, M, crit, runtime] = solve_core(obj)

      % Candidate set
      cov = obj.covering;
      if isscalar(cov)
        u_dim = cov;
        X = obj.problem.gridPoints(u_dim);   % (k x v)
      else
        u_dim = [];                          % not defined for custom covering
        X = cov;                             % (k x v)
      end

      X  = unique(X, "rows", "stable");
      Mi = obj.problem.informationTensor(X); % (p x p x k)
      k  = size(X, 1);

      start_timer = tic;

      if obj.quiet
        cvx_begin quiet
      else
        cvx_begin
      end

        % CVX precision (leave "default" alone)
        mode = char(obj.precision);
        if ~strcmp(mode, "default")
          cvx_precision(mode);
        end

        % Design weights
        variable w(k) nonnegative

        % Information matrix
        M = 0;
        for i = 1:k
          M = M + w(i) * Mi(:, :, i);
        end
        M = 0.5 * (M + M');   % numerical symmetrization

        switch upper(obj.problem.criteria)

          case "D"
            %maximize log_det(M)

            % p = size(M, 1);
            maximize det_rootn(M)
            subject to
              w <= 1;
              sum(w) == 1;

          case "A"
            minimize( trace_inv(M) )
            subject to
              w <= 1;
              sum(w) == 1;

          case "E"
            n = size(M, 1);
            variable t
            maximize( t )
            subject to
              w <= 1;
              sum(w) == 1;
              M - t * eye(n) == semidefinite(n);

          case "I"
            if isempty(u_dim)
              error("I-opt currently requires a scalar grid resolution covering, since predictVariance(u_dim) is used.");
            end

            V         = obj.problem.predictVariance(u_dim);
            Vsym      = 0.5 * (V + V.');
            Vsqrt     = sqrtm(Vsym);
            Vsqrt_inv = inv(Vsqrt);

            MV = Vsqrt_inv * M * Vsqrt_inv';
            MV = 0.5 * (MV + MV');
            minimize( trace_inv(MV) )
            subject to
              w <= 1;
              sum(w) == 1;

          otherwise
            error("Unknown optimality criterion: %s", obj.problem.criteria);
        end

      cvx_end

      runtime = toc(start_timer);

      % Report criterion_value on the table / RE scale
      if upper(obj.problem.criteria) == "D"
          % Stable computation of det(M) via Cholesky
          R    = chol(M);
          crit = exp(2 * sum(log(diag(R))));
      else
          crit = cvx_optval;
      end
    end
  end
end
