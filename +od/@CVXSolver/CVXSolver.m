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
        options.quiet logical = true
      end

      obj@od.Solver(problem, "CVX");
      obj.u_dim = u_dim;
      obj.quiet = options.quiet;
      obj.precision = options.precision;
    end
  end

  methods (Access = protected)
    function [X, w, M, crit] = solve_core(obj)
      X  = obj.problem.gridPoints(obj.u_dim);
      Mi = obj.problem.informationTensor(X);
      k  = size(X, 1);

      if obj.quiet                                        % CVX control output
        cvx_begin quiet
      else
        cvx_begin
      end

        mode = char(obj.precision);                       % specify precision
        if ~strcmp(mode, "default")
          cvx_precision(mode)
        end

        variable w(k)
        M = 0;
        for i = 1:k
          M = M + w(i) * Mi(:, :, i);                     % calcualte information matrix
        end

        switch upper(obj.problem.criteria)
          case "D"
            maximize( log_det(M) )

          case "A"
            minimize( trace_inv(M) )

          case "E"
            maximize( lambda_min(M) )

          case "I"
            V = obj.problem.I_matrix;   % you define this in DesignProblem
            minimize( trace(V * inv(M)) )

          otherwise
            error("Unknown optimality criterion: %s", ...
                obj.problem.optimality_criteria);
        end

        % minimize( -log_det(M) )                
        % minimize()
        subject to
          0 <= w <= 1;
          sum(w) == 1;
      cvx_end

      crit = log_det(M);
    end
  end
end
