# Logicle_transform
MATLAB functions to calculate internal variables and apply the logicle transformation to a matrix of data.

To apply the logicle transform, the parameters of the transformation must forst be set. There are four parameters:

T = "top of scale" value
W = number of approximately linear decades
M = number of approximately logarithmic decades
A = number of additional decades of negative data values to be included

These parameters are fed into the initialize function as follows:

%%
param = initialize(T,W,M,A, varargin);
%%

The varargin is an optional parameter specifying the number of bins to be included if the fast logicle transform algorithm is used.

The param structure stores internal variables for later calculations based on data. In this way, a single call to the initialize function can guide the calculation of many data points efficiently.


Once the internal parameters have been initialized, the data can be tranformed as follows:

%%
transformed_data = logicle_transform(data);
%%

The variable data can be a matrix of any number of dimensions. The logicle_transform function calculates the transformed value of each element in turn, and returns a matrix of the same dimention as the input.
