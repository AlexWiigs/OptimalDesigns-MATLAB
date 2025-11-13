function A =  predictVariance(R, u_dim, v, d)

%% Create Points

U = gridPoints(R, u_dim, v);
if mod(R, 2) == 0                                              % Remove the extra point if necessary
  U(~any(U,2), :) = [];
end
u_cov = size(U, 1);
h = nchoosek(v+d, d);

%% Create basis vector

B = zeros(u_cov, h);
for i = 1:u_cov
  B(i, :) = basis(U(i, :), v, d);
end

%% Predict the variance

delta = (2 * R / (u_dim-1))^v;
A = zeros(h);
for j = 1:u_cov
  A = A + delta * (B(j, :)' * B(j, :));
end
A = A / u_cov;
end
