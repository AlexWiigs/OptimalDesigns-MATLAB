function gamma = fisherWeights(obj, B)
  N = size(B, 1);
    switch string(obj.model)

      case "polynomial"
        gamma = ones(N, 1);

      case "logistic"
        if isempty(obj.pilot_beta) % if no pilot beta is provided use zero vector
          beta = zeros(size(B,2), 1);
        else
          beta = obj.pilot_beta(:);
        end
        eta = B * beta;
        mu_vec = 1 ./ (1 + exp(-eta));
        gamma = mu_vec .* (1 - mu_vec);

      case "poisson"
        if isempty(obj.pilot_beta)
          beta = zeros(size(B,2), 1);
        else
          beta = obj.pilot_beta(:);
        end

        eta = B * beta;
        mu_vec = exp(eta);
        gamma = mu_vec;

      otherwise
        error("Model must be 'logistic', 'polynomial', or 'poisson'. Got: %s", obj.model);
    end
end

