%%%%%%%%%%%%%%%%%%%% Constructor %%%%%%%%%%%%%%%%%%%%%%%

covering = problem.gridPoints(5);
Mi = problem.informationTensor(covering);
M = sum(Mi, 3);
disp(M)



problem = od.DesignProblem("polynomial", 5, 2, 1, "D"); % model, r, v, d, criteria
solver = od.CVXSolver(problem, 10);
result = solver.solve();
disp(result)

solver.filterSmallWeights()


%%%% New %%%%

problem = od.DesignProblem("logistic", 5, 2, 1, "A"); % model, r, v, d, criteria
disp(problem)
solver = od.CVXSolver(problem, 10);
result = solver.solve();
disp(result)
[X_small, w_small] = result.filterSmallWeights();
disp(X_small')
disp(w_small')
