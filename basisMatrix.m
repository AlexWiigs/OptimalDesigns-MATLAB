function result = basisMatrix(solver, x, d, v, k)
  p = nchoosek(v + d, d);
  switch lower(string(solver))
    case 'pso'
      if ~isvector(x) || numel(x) ~= k*v
        error('PSO expects x as a stacked vector of length k*v.');
      end
      result = zeros(k, p);
      for i = 1:k
        xi = x((i-1)*v + 1 : i*v);
        result(i, :) = calculateBasis(xi, v, d);
      end

    case 'cvx'
      if size(x,2) ~= v
        error('CVX expects x as an u_cov-by-v matrix, where u_cov is number of Grid points.');
      end
      u_cov = size(x, 1);                                                                   % Number of grid points
      result = zeros(u_cov, p);
      for i = 1:u_cov
        result(i, :) = calculateBasis(x(i, :), v, d);
      end

    otherwise
      error('cfg.solver must be "PSO" or "CVX".');
  end
end
