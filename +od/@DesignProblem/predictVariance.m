% BUG: Will be slightly off with center point added

function V = predictVariance(obj, u_dim)
  U = obj.gridPoints(u_dim); % cover the design space
  B = obj.basisMatrix(U); % calculate basis vectors
  [u_cov, p] = size(B);

  r = obj.range;
  v = obj.num_variables;
  cell_vol = (2 * r / (u_dim - 1))^v; % calcaulte cell volume

  V = zeros(p, p);
  for i = 1:u_cov
    fi = B(i, :).';
    V = V + cell_vol * (fi * fi.');
  end
end
