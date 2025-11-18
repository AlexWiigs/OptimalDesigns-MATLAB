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
