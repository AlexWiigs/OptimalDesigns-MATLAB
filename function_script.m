%%%% New %%%%

problem = od.DesignProblem("polynomial", 5, 2, 1, "I"); % model, r, v, d, criteria
V = problem.predictVariance(10);
solver = od.CVXSolver(problem, 10);
result = solver.solve();
disp(result)
disp(problem)



disp(V)
Vsym = (V + V.') / 2;
Vsqrt = sqrtm(Vsym);
Vsqrt_inv = inv(Vsqrt);
disp(Vsqrt_inv)
disp(Vsqrt_inv * V * Vsqrt_inv');



[X_small, w_small] = result.filterSmallWeights();
disp(X_small')
disp(w_small')
