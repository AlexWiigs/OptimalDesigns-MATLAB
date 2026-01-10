classdef CVXSolver < od.Solver

  properties
    u_dim
    quiet     logical = true
    precision string  = "default"
    d_delta (1,1) double {mustBePositive} = 1e-8   % D-opt regularization (adds delta*I)
  end

  methods
    function obj = CVXSolver(problem, u_dim, options)
      arguments
        problem
        u_dim (1,1) double {mustBePositive}
        options.precision string = "default"
        options.quiet     logical = true
        options.d_delta (1,1) double {mustBePositive} = 1e-8
      end

      obj@od.Solver(problem, "CVX");
      obj.u_dim     = u_dim;
      obj.quiet     = options.quiet;
      obj.precision = options.precision;
      obj.d_delta   = options.d_delta;
    end
  end

  methods (Access = protected)
    function [X, w, M, crit, runtime] = solve_core(obj)

      % Candidate set and information tensor
      X  = obj.problem.gridPoints(obj.u_dim);   % (k x v)
      Mi = obj.problem.informationTensor(X);    % (p x p x k)
      k  = size(X, 1);

      start_timer = tic;

      if obj.quiet
        cvx_begin quiet
      else
        cvx_begin
      end

        % CVX precision
        mode = char(obj.precision);
        if ~strcmp(mode, "default")
          cvx_precision(mode);
        end

        % Design weights
        variable w(k)

        % Information matrix
        M = 0;
        for i = 1:k
          M = M + w(i) * Mi(:, :, i);
        end
        M = 0.5 * (M + M');   % numerical symmetrization

        switch upper(obj.problem.criteria)

          case "D"
            % D-optimality: maximize det_rootn(M + delta*I)
            % This avoids log_det's successive-approximation / exponential cones
            % and removes the auxiliary L/Schur-complement constraint.
            p = size(M, 1);
            maximize( det_rootn( M + obj.d_delta * eye(p) ) )
            subject to
              0 <= w <= 1;
              sum(w) == 1;

          case "A"
            minimize( trace_inv(M) )
            subject to
              0 <= w <= 1;
              sum(w) == 1;

          case "E"
            n = size(M, 1);
            variable t
            maximize( t )
            subject to
              0 <= w <= 1;
              sum(w) == 1;
              M - t * eye(n) == semidefinite(n);

          case "I"
            V         = obj.problem.predictVariance(obj.u_dim);
            Vsym      = 0.5 * (V + V.');
            Vsqrt     = sqrtm(Vsym);
            Vsqrt_inv = inv(Vsqrt);

            MV = Vsqrt_inv * M * Vsqrt_inv';
            MV = 0.5 * (MV + MV');
            minimize( trace_inv(MV) )
            subject to
              0 <= w <= 1;
              sum(w) == 1;

          otherwise
            error("Unknown optimality criterion: %s", obj.problem.criteria);
        end

      cvx_end

      runtime = toc(start_timer);
      crit    = cvx_optval;   % for D: det_rootn(M + delta*I), monotone w.r.t. logdet
    end
  end
end
