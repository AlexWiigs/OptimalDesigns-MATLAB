function comp = compare(obj, other, q_d, u_cvx)

  arguments
    obj   (1,1) od.DesignResult
    other (1,1) od.DesignResult
    q_d   string
    u_cvx (1,1) double
  end

  same_design = localSameProblem(obj.problem, other.problem);

  crit = upper(string(obj.problem.criteria));

  switch crit
    case "D"
      p  = size(obj.M, 1);
      RE = (obj.criterion_value / other.criterion_value)^(1/p);

    case {"A","E","I"}
      RE = obj.criterion_value / other.criterion_value;

    otherwise
      error("Unsupported criterion '%s'.", crit);
  end

  t_diff = obj.runtime - other.runtime;

  comp = struct();
  comp.same_design = same_design;
  comp.RE          = RE;
  comp.t_diff      = t_diff;

  % number of PSO support points
  u_pso = size(obj.X,1);

  % print LaTeX table row
  fprintf("%s & %.4g & %.4g & %d & %d & %.4f & %.4f & %.4f & %.4f \\\\\n", ...
      q_d, ...
      other.criterion_value, ...
      obj.criterion_value, ...
      u_cvx, ...
      u_pso, ...
      other.runtime, ...
      obj.runtime, ...
      RE, ...
      t_diff);

end

function tf = localSameProblem(p1, p2)

  tf = strcmp(string(p1.model), string(p2.model))                  && ...
       isequal(p1.range, p2.range)                                 && ...
       isequal(p1.num_variables, p2.num_variables)                 && ...
       isequal(p1.max_degree, p2.max_degree)                       && ...
       strcmp(string(p1.criteria), string(p2.criteria))            && ...
       isequaln(p1.pilot_beta, p2.pilot_beta);

end
