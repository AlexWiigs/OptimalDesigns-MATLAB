
function B = basisMatrix(obj, X)
  if size(X, 2) ~= obj.num_variables
    error("basisMatrix expects a k-by-%d matix of points.", obj.num_variables);
  end

  k = size(X, 1);
  v = obj.num_variables;
  d = obj.max_degree;
  p = nchoosek(v + d, d);

  exponents = obj.generateMonomialExponents();
  B = zeros(k, p);
  for i = 1:k
    xi = X(i, :);
    B(i, :) = obj.calculateBasis(xi, exponents);
  end
end
