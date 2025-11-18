function points = gridPoints(obj, u_dim) % calcaulte grid points for prediction variance and CVX
  grid_1d = linspace(-obj.range, obj.range, u_dim);
  grids = cell(1, obj.num_variables);
  [grids{:}] = ndgrid(grid_1d);
  points = zeros(u_dim^obj.num_variables, obj.num_variables);
  for i = 1:obj.num_variables
    points(:, i) = grids{i}(:);
  end

  if ~ismember(zeros(1, obj.num_variables), points, 'rows') % add a center point if not already present
    points = [points; zeros(1, obj.num_variables)];
  end
end
