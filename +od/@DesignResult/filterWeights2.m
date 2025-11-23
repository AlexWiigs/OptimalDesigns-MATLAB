function [X_out, w_out] = filterWeights2(obj, options)
  % Usage:
  %   [X_out, w_out] = result.filterWeights2( ...
  %       threshold    = 0.05, ...
  %       renormalize  = true, ...
  %       merge_radius = 6 ...
  %   );

  arguments
    obj
    options.threshold    (1,1) double  = 0.01
    options.renormalize  (1,1) logical = false
    options.merge_radius (1,1) double  = 0      % 0 → no merging
  end

  % pull from result object
  X_in = obj.X;          % k × v
  w_in = obj.w(:);       % k × 1

  threshold    = options.threshold;
  renormalize  = options.renormalize;
  merge_radius = options.merge_radius;

  % ---------------------------
  % STEP 1 — MERGING (optional)
  % ---------------------------
  if merge_radius > 0 && ~isempty(X_in)
    [k, v] = size(X_in);

    used     = false(k,1);
    merged_X = [];
    merged_w = [];

    for i = 1:k
      if used(i)
        continue
      end

      % cluster indices: points within merge_radius of X_in(i,:)
      idx = i;
      for j = i+1:k
        if ~used(j)
          if norm(X_in(j,:) - X_in(i,:)) <= merge_radius
            idx(end+1) = j; %#ok<AGROW>
          end
        end
      end

      % combine weights
      w_cluster = w_in(idx);
      W = sum(w_cluster);

      % weighted centroid
      if W > 0
        X_cluster = X_in(idx,:);
        x_bar = (w_cluster.' * X_cluster) / W;  % 1 × v
      else
        x_bar = X_in(i,:);
        W = 0;
      end

      merged_X = [merged_X; x_bar]; %#ok<AGROW>
      merged_w = [merged_w; W];     %#ok<AGROW>

      used(idx) = true;
    end

    X_in = merged_X;
    w_in = merged_w;
  end

  % ---------------------------
  % STEP 2 — THRESHOLD
  % ---------------------------
  mask  = (w_in >= threshold);
  X_out = X_in(mask, :);
  w_out = w_in(mask);

  % ---------------------------
  % STEP 3 — RENORMALIZE (opt)
  % ---------------------------
  if renormalize && ~isempty(w_out)
    total = sum(w_out);
    if total > 0
      w_out = w_out ./ total;
    end
  end
end
