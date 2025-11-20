function gamma = fisherWeights(obj, B)
  N = size(B, 1);
  p = size(B, 2);

  switch string(obj.model)
    case "polynomial"
      gamma = ones(N, 1);

    case {"logistic","poisson"}
      % choose beta
      if isempty(obj.pilot_beta)
        beta = zeros(p, 1);
      else
        beta = obj.pilot_beta(:);
        if numel(beta) ~= p
          error("pilot_beta must have length %d to match the regression basis, got %d.", ...
                p, numel(beta));
        end
      end

      % linear predictor and weights
      eta    = B * beta;
      if obj.model == "logistic"
        mu_vec = 1 ./ (1 + exp(-eta));
        gamma  = mu_vec .* (1 - mu_vec);
      else % poisson
        mu_vec = exp(eta);
        gamma  = mu_vec;
      end

    otherwise
      error("Model must be 'logistic', 'polynomial', or 'poisson'. Got: %s", obj.model);
  end
end
