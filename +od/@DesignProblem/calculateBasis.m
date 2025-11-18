function result = calculateBasis(obj, xi, exponents)
  result = prod(xi(:)'.^exponents, 2)';
end

