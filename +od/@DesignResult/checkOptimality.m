function stats = checkOptimality(obj, u_dim, options)

  arguments
    obj
    u_dim (1,1) double {mustBeInteger, mustBePositive} = 21
    options.tol    (1,1) double = 1e-6
  end

  % Only meaningful for D-criterion
  crit = upper(string(obj.problem.criteria));
  if crit ~= "D"
    error("checkOptimality is only implemented for D-optimal designs.");
  end

  M = obj.M;
  M = 0.5 * (M + M.');           % symmetrize defensively

  [p, q] = size(M);
  if p ~= q
    error("DesignResult:checkOptimality: M must be square.");
  end

  invM = inv(M);
  p_dim = p;                     % number of parameters

  % Build regular covering grid in [-range, range]^v
  v   = obj.problem.num_variables;
  R   = obj.problem.range;
  grid1d = linspace(-R, R, u_dim);

  % ndgrid to build full tensor product grid
  switch v
    case 1
      Xgrid = grid1d(:);
    case 2
      [X1, X2] = ndgrid(grid1d, grid1d);
      Xgrid = [X1(:), X2(:)];
    case 3
      [X1, X2, X3] = ndgrid(grid1d, grid1d, grid1d);
      Xgrid = [X1(:), X2(:), X3(:)];
    otherwise
      error("checkOptimality: v = %d too large for tensor grid.", v);
  end

  n = size(Xgrid, 1);
  sens = zeros(n,1);

  for i = 1:n
    x_i = Xgrid(i, :);

    % informationTensor for a single point: h x h x 1
    Mi = obj.problem.informationTensor(x_i);
    Mi = Mi(:, :, 1);
    Mi = 0.5 * (Mi + Mi.');

    % D-sensitivity: psi_D(x) = trace(invM * Mi) - p
    sens(i) = trace(invM * Mi) - p_dim;
  end

  max_val = max(sens);
  is_opt  = (max_val <= options.tol);

  stats = struct();
  stats.criterion   = "D";
  stats.sensitivity = sens;
  stats.max_value   = max_val;
  stats.is_optimal  = is_opt;
  stats.tol         = options.tol;
  stats.Xgrid       = Xgrid;
end
