% Initialize a design problem as an object:

model = "polynomial";
r = 2;
v = 2;
d = 2;
criteria = "D";

problem = od.DesignProblem(model, r, v, d, criteria);
disp(problem)

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


