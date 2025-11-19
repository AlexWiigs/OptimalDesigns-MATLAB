classdef DesignProblem
  properties
    model
    range
    num_variables
    max_degree
    criteria
    pilot_beta
  end

  methods
    function obj = DesignProblem(model, range, num_variables, max_degree, criteria, options)
      arguments
        model
        range
        num_variables
        max_degree
        criteria
        options.pilot_beta = []   % optional
      end

      % Required fields
      obj.model         = model;
      obj.range         = range;
      obj.num_variables = num_variables;
      obj.max_degree    = max_degree;
      obj.criteria      = criteria;

      % Pilot_beta logic
      if ~isempty(options.pilot_beta)
        obj.pilot_beta = options.pilot_beta;
      else
        switch lower(string(model))
          case "polynomial"
            obj.pilot_beta = [];  % no pilot needed
          case {"logistic", "poisson"}
            p = nchoosek(obj.num_variables + obj.max_degree, obj.max_degree);
            obj.pilot_beta = zeros(p, 1);
          otherwise
            obj.pilot_beta = [];
        end
      end
    end

    gridpoints = gridPoints(obj, u_dim)

  end
end
