

%%%%%%%%%%%%%%%%%%%% Constructor %%%%%%%%%%%%%%%%%%%%%%%

model = "polynomial"; % Create a design problem
r = 5;
v = 2;
d = 2;
criteria = "D";
problem = od.DesignProblem(model, r, v, d, criteria);

disp(problem)

%%%%%%%%%%%%%%%%%%% Public Methods %%%%%%%%%%%%%%%%%%%%%%

gridpoints = problem.gridPoints(3);
disp(gridpoints')

basis_vectors = problem.basisMatrix(gridpoints)












variance = problem.predictVariance(3); % TODO: Add these public functions to the README.md
disp(variance)




variance = problem.predictVariance(3);
disp(variance)
% disp(problem)
X = problem.gridPoints(11);
problem.calculateBasis()
problem.basisMatrix(X);




