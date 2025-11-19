%%%%%%%%%%%%%%%%%%%% Constructor %%%%%%%%%%%%%%%%%%%%%%%

problem = od.DesignProblem("polynomial", 5, 2, 2, "D"); % model, r, v, d, criteria
disp(problem)

%%%%%%%%%%%%%%%%%%% Public Methods %%%%%%%%%%%%%%%%%%%%%%

gridpoints = problem.gridPoints(3);
disp(gridpoints')

basis_vectors = problem.basisMatrix(gridpoints);
disp(basis_vectors)

problem.generateMonomialExponents() %% TODO: Add to public functions README.md

problem = od.DesignProblem("logistic", 5, 2, 2, "D"); % model, r, v, d, criteria
gridpoints = problem.gridPoints(3);
basis_vectors = problem.basisMatrix(gridpoints);
fisherweights = problem.fisherWeights(basis_vectors);
disp(fisherweights')




variance = problem.predictVariance(3); % TODO: Add these public functions to the README.md
disp(variance)




variance = problem.predictVariance(3);
disp(variance)
% disp(problem)
X = problem.gridPoints(11);
problem.calculateBasis()
problem.basisMatrix(X);




