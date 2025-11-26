classdef Solver
  properties
    problem
    solver_name
  end

  methods
    function obj = Solver(problem, solver_name)
      obj.problem     = problem;
      obj.solver_name = solver_name;
    end

    function result = solve(obj)
      [X, w, M, crit, runtime] = obj.solve_core();
      result = od.DesignResult(X, w, M, crit, obj.solver_name, obj.problem);
      result.runtime = runtime;
    end
  end

  methods (Access = protected, Abstract)
    [X, w, M, crit, runtime] = solve_core(obj)
  end
end
