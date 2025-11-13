function result = informationMatrix(x, d, v, k, solver, model, pilot)

  switch lower(string(solver))
    case "pso"
      matrix = basisMatrix(solver, x(1:v*k), d, v, k);
      columns = size(matrix, 2);
      result = zeros(columns, columns);
      w = weights(x(v*k + 1 : end));

      switch lower(string(model))
        case {"logistic", "poisson"}
          beta = pilot(:);
          eta = matrix * beta;

          if strcmp(model, "logistic")
            pi_vec = 1 ./ (1 + exp(-eta));
            info_weights = pi_vec .* (1 - pi_vec);
          else
            mu_vec = exp(eta);
            info_weights = mu_vec;
          end

        case "polynomial"
          info_weights = ones(k, 1);

        otherwise
          error("Model must be 'logistic', 'poisson', or 'polynomial'. Got: %s", model);
      end

      % Accumulate weighted info contributions
      for i = 1:k
        point_info = w(i) * info_weights(i) * (matrix(i, :)' * matrix(i, :));
        result = information + point_info;
      end

    case "cvx"
      matrix = basisMatrix(solver, x, d, v, k);
      [u_cov, p] = size(matrix);

      switch lower(string(model))
        case {"logistic", "poisson"}
          beta = pilot(:);
          eta = matrix * beta;

          if strcmp(model, "logistic")
            pi_vec = 1 ./ (1 + exp(-eta));
            info_weights = pi_vec .* (1 - pi_vec);
          else
            mu_vec = exp(eta);
            info_weights = mu_vec;
          end

        case "polynomial"
          info_weights = ones(u_cov, 1);

        otherwise
          error("Model must be 'logistic', 'poisson', or 'polynomial'. Got: %s", model);
      end

      result = zeros(p, p, u_cov);
      for i = 1:u_cov
        result(:,:, i) = info_weights(i) * ( matrix(i,:)' * matrix(i,:));
      end

      otherwise
        error("solver must be 'pso', or 'cvx'. Got: %s", solver);
  end
end

function W = weights(x)
  W = x(1:end)/ sum(x(1:end));
end

