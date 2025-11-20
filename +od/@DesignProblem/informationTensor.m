function Mout = informationTensor(obj, X)
  B = obj.basisMatrix(X);
  [k, h] = size(B);
  Mi = zeros(h, h, k);
  for i = 1:k
    Mi(:, :, i) = B(i,:)' * B(i,:);
  end

  switch lower(string(obj.model))
    case {"logistic", "poisson"}
      gamma = obj.fisherWeights(B);
      Mout = Mi .* reshape(gamma, 1, 1, []);
    case "polynomial"
      Mout = Mi;

  end

end
