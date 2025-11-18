classdef DesignProblem
  properties
    model
    range
    num_variables
    max_degree
    optimality_criteria
    pilot_beta
  end

  methods

    function obj = DesignProblem(model, range, num_variables, max_degree, optimality_criteria) % constructor
      obj.model = model;
      obj.range = range;
      obj.num_variables = num_variables;
      obj.max_degree = max_degree;
      obj.optimality_criteria = optimality_criteria;
    end

  end

end

