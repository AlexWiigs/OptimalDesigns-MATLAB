
# OptimalDesign (MATLAB) Software

This software provides the user with a flexible way to find a variety of
optimal designs using both PSO and CVX-based algorithms. See the
installation guide and usage notes below for setup information.

## Example

```{matlab}
# Example goes here.
```

## Installation Guide

In addition to a working MATLAB licence, This software requires:

- [CVX](https://github.com/cvxr/CVX) which provides access to solvers such as Mosek and Gurobi.
- The MATLAB function [particleswarm](https://www.mathworks.com/help/gads/particleswarm.html?utm_source=chatgpt.com), available through the [Global Optimization Toolbox](https://www.mathworks.com/help/gads/index.html).

## Usage

OptimalDesign works by creating two objects and returns a new third object as a
solution. The two objects which we specify are:

1. The design problem to solve.
2. The solver algorithm we would like to utilize and it's settings

These objects get past into a solution class which returns the optimal design as
an object.

```{matlab}
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
