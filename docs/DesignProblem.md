# DesignProblem

**Purpose:** Represents a regression model, design space, degree, and optimality criterion.

## Constructor
```matlab
>> obj = DesignProblem(model, range, v, d, criterion)
```

* **model:** A string which represent the regression model type. Options: "polynomial", "poisson", "binomial".
* **range:** length about each side of the origin each variable is defined. Must be $\geq 0$.
* **v:** number of regressors in the model. Must be $\geq 0$.
* **d:** max power of the monomials in regression model. Must be $\geq 0$
* **criterion:** specifies criteria for an optimal design. Options: "D", "A", "E", "I".

**Example**

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

### Cover DesignProblem with grid points

The `gridPoints()` method gets an integer which represents the amount of evenly
spaced points to split each variable into and returns them as a $v \times
\binom{v + d}{d}$ matrix. Each row in the matrix represents a point in the
resulting lattice grid. This function is very useful for using CVXSolver or
estimating the response variance of the regression model.

**Example:**
Using the design problem specified under the constructor heading:
```matlab
>> u_dim = 3; % specify support points per dimension
>> grid_points = problem.gridPoints(3);
>> disp(grid_points') % transpose of gridpoints matrix
    -5     0     5    -5     0     5    -5     0     5
    -5    -5    -5     0     0     0     5     5     5

```

### Calcaulate basis vectors for each potential design point

The `basisMatrix()` method expects a $k \times v$ matrix, where each row
represents a potential point in the design matrix and returns a basis vector
calculated at the point. These basis matrices are used to calculate the fisher
information matrix which are optimized differently depending on the design
criteria specified.

**Example**
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

