%%%% New %%%%


% model, range about origin, variables, degrees, optimality criteria
problem = od.DesignProblem("polynomial", 5, 2, 1, "D"); 
solver = od.CVXSolver(problem, 11); % support points per dimension

result = solver.solve();
[support_points, weights] = result.filterWeights();
disp(result.criterion_value)
disp(support_points')
disp(weights')

