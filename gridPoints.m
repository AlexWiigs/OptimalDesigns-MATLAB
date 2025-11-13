function points = gridPoints(R, u_dim, v)

grid_1d = linspace(-R, R, u_dim);
grids = cell(1, v);
[grids{:}] = ndgrid(grid_1d);
points = zeros(u_dim^v, v);
for i = 1:v
  points(:, i) = grids{i}(:);
end

% Add a center point if not already present
if ~ismember(zeros(1, v), points, 'rows')
  points = [points; zeros(1, v)];
end
