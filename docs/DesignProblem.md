# DesignProblem

The DesignProblem class allows us to instantiate a optimal design problem
specified by its:
* Regression model
* Design space
* Optimality Criteria

## Constructor
```matlab
>> obj = DesignProblem(model, range, v, d, criterion)
```

* **model:** A string which represent the regression model type.
    Valid Inputs: "polynomial", "poisson", "logistic"
* **range:** length about each side of the origin each variable is defined.
    Valid Inputs: int $\geq 1$
* **v:** number of regressors in the model.
    Valid Inputs: int $\geq 1$
* **d:** max power of the monomials in regression model.
    Valid Inputs: int $\geq 1$
* **criterion:** A String which specifies criteria for an optimal design.
    Valid Inputs: "D", "A", "E", "I"

**Optimal parameters**
must be entered at after the mandatory parameters.

* **pilot_beta:** a vector of length $\binom{v +d}{d}$, which specifies the
initial estimates for linear parameters in a pilot study. These are necessary
for finding GLM optimal designs. If "polynomial" is picked an empty list will be
passed to the design object which is not used. If no pilot_beta is passed for a
GLm, a zero vector will be used instead.}

**Example:**

```matlab
>> model = "polynomial";
>> r = 5;
>> v = 2;
>> d = 2;
>> criteria = "D";

>> problem = od.DesignProblem(model, r, v, d, criteria);
>> Disp(problem)
  DesignProblem with properties:

                  model: "polynomial"
                  range: 5
          num_variables: 2
             max_degree: 2
    optimality_criteria: "D"
             pilot_beta: []

```

## Public Methods

DesignProblem contains many methods for calculating mathematical results
relevant to the optimization problem. The solvers are designed to use these values
automatically. Nevertheless, I have opted to keep most of these methods public to provide
the user with the ability to reference them for research or troubleshooting.

```matlab
>> methods('od.DesignProblem')

Methods for class od.DesignProblem:

DesignProblem              fisherWeights              predictVariance
basisMatrix                generateMonomialExponents
calculateBasis             gridPoints

```

### Cover DesignProblem with grid points

The `gridPoints()` method gets an integer, `u_dim` which represents the amount
of evenly spaced points to split each variable into and returns them as a
$u_{dim}^{v}$ matrix. Each row in the matrix represents a point in the resulting
lattice grid. This function is very useful for using CVXSolver or estimating the
response variance of the regression model.

**Example:**

Using the design problem specified under the constructor heading:
```matlab
>> u_dim = 3; % specify support points per dimension
>> grid_points = problem.gridPoints(3);
>> disp(grid_points') % transpose of gridpoints matrix
    -5     0     5    -5     0     5    -5     0     5
    -5    -5    -5     0     0     0     5     5     5

```

### Calculate basis vectors for each potential design point

The `basisMatrix()` method expects a $k \times v$ matrix, where each row
represents a support point in the design matrix and returns a basis vector
calculated at the point. These basis matrices are used to calculate the fisher
information matrix which are optimized differently depending on the design
criteria specified.

**Example:**

Using the design problem specified under the constructor heading, and the grid
points calculated in the `gridPoints()` example:
```matlab
>> basis_vectors = problem.basisMatrix(grid_points);
>> disp(basis_vectors)
    1    -5    -5    25    25    25
    1    -5     0    25     0     0
    1    -5     5    25   -25    25
    1     0    -5     0     0    25
    1     0     0     0     0     0
    1     0     5     0     0    25
    1     5    -5    25   -25    25
    1     5     0    25     0     0
    1     5     5    25    25    25

```

### Calculate Information matrix

ADD

### Calculate Fisher weights

When solving for a GLM regression model (logistic, Poisson, etc...) the mean
response changes with the linear predictor through the link function. Thus it is
necessary to calculate a calibration weight for each design points contribution
to the design problem. These weights require passing an optional list
`pilot_betas`, of preliminary estimates for the model linear parameters. If no
vector is passed a preliminary estimate of $0$ gets passed for each parameter
estimate.

**Example:**

```matlab
>> problem = od.DesignProblem("logistic", 5, 2, 2, "D"); % model, r, v, d, criteria
>> gridpoints = problem.gridPoints(3);
>> basis_vectors = problem.basisMatrix(gridpoints);
>> fisherweights = problem.fisherWeights(basis_vectors);
>> disp(fisherweights')
    0.2500    0.2500    0.2500    0.2500    0.2500    0.2500    0.2500    0.2500    0.2500

```

### Estimate the prediction variance of the response

For optimality criteria focused on reducing the response of the regression model,
such as I-optimality, it is necessary to estimate the predicted response
variance of the model. This can be done by covering the design surface with
points and using them to estimate the variance numerically. Much like
`gridPoints()`, `predictVariance()` requires passing an integer which represents
the points each variable gets split into, resulting a total design covering of
$u_{\text{dim}}^{v}$ points. The more points used to cover the design space, the
more accurate the prediction variance will become.

**Example:**

```matlab
>> prediction_variance = problem.predictVariance(3);
>> disp(prediction_variance)
    1.0000         0         0   16.6667         0   16.6667
         0   16.6667         0         0         0         0
         0         0   16.6667         0         0         0
   16.6667         0         0  416.6667         0  277.7778
         0         0         0         0  277.7778         0
   16.6667         0         0  277.7778         0  416.6667

```
