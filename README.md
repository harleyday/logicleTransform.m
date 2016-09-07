# LogicleTransform
MATLAB functions to calculate internal variables and apply the logicle transformation to a matrix of data.

To apply the logicle transform, the parameters of the transformation must first be set. There are four parameters:

T = "top of scale" value
W = number of approximately linear decades
M = number of approximately logarithmic decades
A = number of additional decades of negative data values to be included

These parameters are specified when creating a new LogicleTransform object:

obj = LogicleTransform(T,W,M,A,varargin);

The varargin is an optional parameter specifying the number of bins to be included if the fast logicle transform algorithm is used.

The object stores internal variables for later calculations based on data. In this way, the object guides the calculation of many data points efficiently.

Once the object is created, the data can be tranformed as follows:

%%

transformed_data = obj.transform(data);

%%

The inverse operation can be carried out as follows:

%%

data = obj.inverse(transformed_data);

%%

The variable data can be a matrix of any number of dimensions. The logicle_transform function calculates the transformed value of each element in turn, and returns a matrix of the same dimention as the input.

Axes ticks amd labels can be set by acessing the Tick and TickLabel properties of the LogicleTransform object. See example below:

%%

obj = LogicleTransform(10000,2,4,0);

x = linspace(obj.inverse(0),10000,1000);

y = obj.transform(x);

plot(x,y);

ax = gca;

ax.YTick = obj.Tick;

ax.YTickLabel = obj.TickLabel;

%%
