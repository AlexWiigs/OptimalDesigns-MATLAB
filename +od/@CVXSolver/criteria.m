function phi = criteria(obj, M)
  arguments
    obj
    M
  end

  criteria   = options.criterion;

  switch string(criteria)
    case "D"
      phi = - log_det(M);
    case "A"
      phi = trace_inv(M);V

  

  % filter
  mask  = (w_in >= threshold);
  X_out = X_in(mask, :);
  w_out = w_in(mask);

  % renormalize if requested
  if renormalize && ~isempty(w_out)
      total = sum(w_out);
      if total > 0
          w_out = w_out ./ total;
      end
  end
end
