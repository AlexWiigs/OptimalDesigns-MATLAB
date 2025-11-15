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

    function points = gridPoints(obj, u_dim) % calcaulte grid points for prediction variance and CVX
      grid_1d = linspace(-obj.range, obj.range, u_dim);
      grids = cell(1, obj.num_variables);
      [grids{:}] = ndgrid(grid_1d);
      points = zeros(u_dim^obj.num_variables, obj.num_variables);
      for i = 1:obj.num_variables
        points(:, i) = grids{i}(:);
      end

      if ~ismember(zeros(1, obj.num_variables), points, 'rows') % add a center point if not already present
        points = [points; zeros(1, obj.num_variables)];
      end
    end

    function B = basisMatrix(obj, X)
      if size(X, 2) ~= obj.num_variables
        error("basisMatrix expects a k-by-%d matix of points.", obj.num_variables);
      end

      k = size(X, 1);
      v = obj.num_variables;
      d = obj.max_degree;
      p = nchoosek(v + d, d);

      exponents = obj.generateMonomialExponents();
      B = zeros(k, p);
      for i = 1:k
        xi = X(i, :);
        B(i, :) = obj.calculateBasis(xi, exponents);
      end
    end
 
    function gamma = fisherWeights(obj, B)
    N = size(B, 1);
      switch string(obj.model)

        case "polynomial"
          gamma = ones(N, 1);

        case "logistic"
          if isempty(obj.pilot_beta) % if no pilot beta is provided use zero vector
            beta = zeros(size(B,2), 1);
          else
            beta = obj.pilot_beta(:);
          end
          eta = B * beta;
          mu_vec = 1 ./ (1 + exp(-eta));
          gamma = mu_vec .* (1 - mu_vec);

        case "poisson"
          if isempty(obj.pilot_beta)
            beta = zeros(size(B,2), 1);
          else
            beta = obj.pilot_beta(:);
          end

          eta = B * beta;
          mu_vec = exp(eta);
          gamma = mu_vec;

        otherwise
          error("Model must be 'logistic', 'polynomial', or 'poisson'. Got: %s", obj.model);
      end
    end
  end

  methods (Access = private)

    function result = calculateBasis(obj, xi, exponents)
      result = prod(xi(:)'.^exponents, 2)';
    end

    function result = generateMonomialExponents(obj)
      v = obj.num_variables;
      d = obj.max_degree;
      numExponents = nchoosek(v + d, d);
      result = zeros(numExponents, v);
      count = 1;
      for alpha = 0:d
        temp = obj.generateDegreeExponents(alpha, v);
        numRows = size(temp, 1);
        if size(temp, 2) ~= v
          error('Mismatch: temp has %d columns, expected %d', size(temp, 2), v);
        end
        result(count:count+numRows-1, :) = temp;
        count = count + numRows;
      end
    end

    function result = generateDegreeExponents(obj, alpha, v)
      if v == 1
        result = alpha;
      else
        result = [];
        for i = 0:alpha
          subparts = obj.generateDegreeExponents(alpha - i, v - 1);
          result = [result; i * ones(size(subparts,1),1), subparts];
        end
      end
    end
  end

end

