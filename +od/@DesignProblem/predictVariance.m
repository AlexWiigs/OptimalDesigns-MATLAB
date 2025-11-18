function V2 = predictVariance(obj, u_dim) % FIXME: This might not be the correct formula
  U = obj.gridPoints(u_dim); % cover the design space
  B = obj.basisMatrix(U); % calculate basis vectors
  [u_cov, p] = size(B);
  V = zeros(p ,p);

  for i = 1:u_cov
    fi = B(i, :).';
    V = V + fi * fi.';
  end
  V2 = V / u_cov;

  V = V / (2 * obj.range)^obj.num_variables;
  V = inv(sqrtm((V + V') / 2));
end
