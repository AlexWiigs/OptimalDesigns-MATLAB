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
