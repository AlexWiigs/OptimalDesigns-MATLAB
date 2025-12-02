classdef CVXSolver < od.Solver

  properties
    u_dim
    quiet logical = true
    precision string = "default"
  end

  methods
    function obj = CVXSolver(problem, u_dim, options)
      arguments
        problem
        u_dim (1,1) double {mustBePositive}
        options.precision string = "default"
        options.quiet logical   = true
      end

      obj@od.Solver(problem, "CVX");
      obj.u_dim    = u_dim;
      obj.quiet    = options.quiet;
      obj.precision = options.precision;
    end
  end

  methods (Access = protected)
    function [X, w, M, crit, runtime] = solve_core(obj)
      X  = obj.problem.gridPoints(obj.u_dim);   % candidate points (k x v)
      Mi = obj.problem.informationTensor(X);    % info tensors (p x p x k)
      k  = size(X, 1);                          % number of candidate points

      start_timer = tic;
      if obj.quiet
        cvx_begin quiet
      else
        cvx_begin
      end

        mode = char(obj.precision);
        if ~strcmp(mode, "default")
          cvx_precision(mode);
        end

        variable w(k)                           % design weights
        M = 0;
        for i = 1:k
          M = M + w(i) * Mi(:, :, i);          % information matrix
        end
        M = 0.5 * (M + M');                    % enforce symmetry numerically

        switch upper(obj.problem.criteria)
          case "D"
            maximize( log_det(M) )
            subject to
              0 <= w <= 1;
              sum(w) == 1;

          case "A"
            minimize( trace_inv(M) )
            subject to
              0 <= w <= 1;
              sum(w) == 1;

          case "E"
            % E-optimality via SDP: maximize t s.t. M - t I is PSD
            n = size(M, 1);
            variable t
            maximize( t )
            subject to
              0 <= w <= 1;
              sum(w) == 1;
              M - t * eye(n) == semidefinite(n);   % ensures lambda_min(M) >= t

          case "I"
            V     = obj.problem.predictVariance(obj.u_dim);
            Vsym  = 0.5 * (V + V.');
            Vsqrt = sqrtm(Vsym);
            Vsqrt_inv = inv(Vsqrt);

            MV = Vsqrt_inv * M * Vsqrt_inv';
            MV = 0.5 * (MV + MV');                 % symmetrize transformed matrix
            minimize( trace_inv(MV) )
            subject to
              0 <= w <= 1;
              sum(w) == 1;

          otherwise
            error("Unknown optimality criterion: %s", obj.problem.criteria);
        end

      cvx_end
      runtime = toc(start_timer);

      crit = cvx_optval;
    end
  end
end
