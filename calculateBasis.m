% Function takes in v variables and d degrees and creates a basis vector (gradient
% of the regression function w.r.t. linear predictor).

function result = calculateBasis(x, v, d)

  exponents = generateMonomialExponents(v, d);
  result = prod(x(:)'.^exponents, 2)';
end

function result = generateMonomialExponents(v, d)

  numExponents = nchoosek(v + d, d);
  result = zeros(numExponents, v);
  count = 1;
  for alpha = 0:d
    temp = generateDegreeExponents(alpha, v);
    numRows = size(temp, 1);
    if size(temp, 2) ~= v
      error('Mismatch: temp has %d columns, expected %d', size(temp, 2), v);
    end
    result(count:count+numRows-1, :) = temp;
    count = count + numRows;
  end
end

function result = generateDegreeExponents(alpha, v)

  if v == 1
    result = alpha;
  else
    result = [];
    for i = 0:alpha
      subparts = generateDegreeExponents(alpha - i, v - 1);
      result = [result; i * ones(size(subparts,1),1), subparts];
    end
  end
end
