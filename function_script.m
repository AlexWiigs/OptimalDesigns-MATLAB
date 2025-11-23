%%% Test PSO %%%

problem = od.DesignProblem("polynomial", 5, 3, 3, "A");
solver = od.CVXSolver(problem, 15);
result = solver.solve();
disp(result)

[support_points, weights] = result.filterWeights2(threshold = 0.01, renormalize=true, merge_radius = 5);
disp(support_points')
disp(weights')
sum(weights)
