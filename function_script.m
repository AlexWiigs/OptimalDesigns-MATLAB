% Initialize a design problem as an object:

%% Problem Parameters
model = "polynomial";
r = 1;
v = 2;
d = 2;
% pilot_beta = [1, 1, 1, 1, 1, 1];
criteria = "E";
problem = od.DesignProblem(model, r, v, d, criteria);
% disp(problem)

%% Solver Parameters:
u_dim = 11;
solver = od.CVXSolver(problem, u_dim);
result = solver.solve();

disp(result)
disp(result.info_matrix)
disp(result.weights)
disp(sum(result.weights))


%% Function Tests:


% Test gridPoints

u_dim = 5;
points = gridPoints(r, u_dim, v);
disp(points(1:5, :))

% test calcaulteBasis

format bank % changes display not stored values
first_point = points(1, :);
numTerms = nchoosek(v + d, d);
disp(numTerms)
disp("Output order is Graded lexicographic")
for i = 1:5
  disp(calculateBasis(points(i, :), v, d))
end

% Test the informaiton matrix here
