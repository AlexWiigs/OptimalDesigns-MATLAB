
# OptimalDesign (MATLAB) Software

This software provides the user with a flexible way to find a variety of
optimal designs using both PSO and CVX-based algorithms. See the
installation guide and usage notes below for setup information.

## Example

```matlab
% Example goes here.
```

## Installation Guide

### Requirements

This software requires:

- **MATLAB R2024a** (earlier versions may work but have not been tested).
- [CVX (latest version)](https://github.com/cvxr/CVX) which provides access to solvers such as Mosek and Gurobi.
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

## Usage

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

**CVXSolver < Solver**

- takes a DesignProblem
- Implements `solve()` using CVX
- Produces solver diagnostics

**PSOSolver < Solver**

- takes a DesignProblem
- Implements `solver()` using PSO

```matlab
classdef DesignProblem
  properties
    model
    range
    variable
    degree
    criteria
  end

  methods
    function obj = DesignProblem(model, range, variable, degree, criteria)
      obj.model = model;
      obj.range = range;
      obj.variable = variable;
      obj.degree = degree;
      obj.criteria = criteria;
    end
  end

end
```
