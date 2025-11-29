
# OptimalDesign (MATLAB) Software

This software provides the user with a flexible way to find a variety of optimal
designs using both PSO and CVX-based algorithms in a few lines of code. See the
installation guide and usage notes below for setup information.

## Features

- Integrates both CVX and PSO solvers
- Define regression models with \(v\) variables and degree \(d\), symmetric about the origin within a specified range \(r\)
- Automatically constructs basis vectors, information matrices, and optimality criteria
- Supports polynomial, logistic, and Poisson models
- Handles D-, A-, E-, and I-optimality
- Clear result objects with support points, weights, criterion value, and runtime
- Optional post-processing tools including weight filtering, point merging, and
  equivalence theorem analysis on weights

## Example

Define a design problem and select a solver method:
```matlab
% model, range about origin, variables, degrees, optimality criteria
>> problem = od.DesignProblem("polynomial", 5, 2, 1, "D"); 
>> solver = od.CVXSolver(problem, 11); % support points per dimension

```

Find the optimal design and extract relevant properties:
```matlab

>> result = solver.solve();
>> disp(result)
  DesignResult with properties:

    criterion_value: 6.4378
        solver_name: "CVX"
            runtime: 0.7940
                  X: [121×2 double]
                  w: [121×1 double]
                  M: [3×3 double]
            problem: [1×1 od.DesignProblem]

>> [support_points, weights] = result.filterWeights();
>> disp(result.criterion_value)
    6.4378

>> disp(support_points')
    -5     5    -5     5
    -5    -5     5     5

>> disp(weights')
    0.2500    0.2500    0.2500    0.2500

```


## Installation Guide

### Requirements

This software requires:

- **MATLAB R2024a** (earlier versions may work but have not been tested).
- [CVX (latest version)](https://github.com/cvxr/CVX) which provides access to solvers such as SDPT3 and SeDuMi.
- [Global Optimization Toolbox](https://www.mathworks.com/help/gads/index.html) which provides the function [particleswarm](https://www.mathworks.com/help/gads/particleswarm.html?utm_source=chatgpt.com).

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/AlexWiigs/OptimalDesigns-MATLAB.git
```
2. **Add project to your MATLAB path**

In MATLAB run:
```matlab
addpath(genpath('/path/to/OptimalDesigns-MATLAB'));
savepath
```

The package is ready to use!

## Quickstart Guide

For a complete treatment of each classes' properties and methods, please see the
documentation:

- [DesignProblem](/docs/DesignProblem.md)
- [CVXSolver](/docs/CVXSolver.md)
- [PSOSolver](/docs/PSOSolver.md)
- [DesignResult](/docs/DesignResult.md)

OptimalDesign works by defining two objects, one where you specify an optimal
design problem that you would like to be solved and one specifying how you would
like the solver to calculate the solution. 

**DesignProblem**

- Holds the regression model
- Holds the design space
- Specifies the optimality criteria

**Solver (parent class)**

- Has a common interface for each solver
- Stores the final design, weights, status, timing, etc
- Uses children to implement the solve method
