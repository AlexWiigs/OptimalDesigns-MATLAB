function [X_out, w_out] = filterSmallWeights(obj, X_in, w_in, options)
  arguments
    obj
    X_in
    w_in
    options.threshold   double = 0.01
    options.renormalize logical = false
  end

  threshold   = options.threshold;
  renormalize = options.renormalize;

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
