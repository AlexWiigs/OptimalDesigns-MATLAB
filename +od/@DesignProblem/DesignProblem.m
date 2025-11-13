classdef DesignProblem
  properties
    model
    range
    variable
    degree
    criteria
  end

  methods
    function obj = DesignProblem(model, range, variable, degree, criteria)
      obj.model = model;
      obj.range = range;
      obj.variable = variable;
      obj.degree = degree;
      obj.criteria = criteria;
    end
  end

end
    
