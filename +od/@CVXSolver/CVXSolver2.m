classdef CVXSolver < od.Solver

    properties
        precision   % "high", "default", "low", etc.
        verbose     % true/false to control CVX output
        max_iters   % optional override for CVX max iterations
        u_dim       % support points per dimension for covering the design space
    end

    methods

        function obj = CVXSolver(problem, u_dim, precision, verbose, max_iters)

            obj@od.Solver(problem, "CVX"); % call parent constructor
            if nargin < 2, u_dim = 5; end % default values
            if nargin < 3, precision = "default"; end
            if nargin < 4, verbose = false; end
            if nargin < 5, max_iters = []; end

            % Assign to properties
            obj.u_dim     = u_dim;
            obj.precision = precision;
            obj.verbose   = verbose;
            obj.max_iters = max_iters;
        end
    end

    methods (Access = protected)

        function [x, w, M, crit] = solve_core(obj)

            U     = obj.problem.gridPoints(obj.u_dim);
            B     = obj.problem.basisMatrix(U);
            k     = size(B, 1);
            gamma = obj.problem.fisherWeights(B);
            Mi = obj.informationTensor(gamma, B);
            if obj.criterion_value == "I"
              V = obj.problem.predictVariance(obj.u_dim);
            end

            cvx_begin quiet% cvx block starts
              cvx_precision high
              variable w(k);
              M = 0;
              V = 1;
              for i = 1:k
                M = M + w(i) * Mi(:, :, i);
              end 

              switch string(obj.problem.optimality_criteria)
                case "D"
                  maximize(log_det(M))
                case "A"
                  minimize( trace_inv(M))
                case "E"
                  maximize(lambda_min(M))
                case "I" 
                  MV = V * M * V; % BUG: I-optimal designs don't work
                  minimize(trace_inv(MV))
              end

              subject to
              0 <= w <= 1;
              sum(w) == 1
            cvx_end % cvx block ends

            x = U; %% FIXME: switch to keep once bugs are fixed
            M = double(M); %% change back
            w = double(w);
            crit = cvx_optval;
        end

        function Mi = informationTensor(obj, gamma, B)

          k =  size(B, 1);
          h = size(B, 2);
          Mi = zeros(h, h, k);
          for i = 1:k
            Mi(:, :, i) = gamma(i) * B(i,:)' * B(i,:);
          end
        end
    end
end
