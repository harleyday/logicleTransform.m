# logicleTransform

## MATLAB class to apply the logicle transformation to a matrix and provide axes labels.

----------------------------------------------------------------------------------------------------------------------------

<details id="simple-installation">
  <summary>
    <strong>
      Simple installation (Click to expand)
    </strong>
  </summary>
  
  Go to your working directory for your MATLAB project, and clone this repository using <a href="https://git-scm.com/downloads"><code>git</code></a> command line:
  <br>
  <pre><code>cd path/to/working/directory
git clone https://github.com/harleyday/logicleTransform-for-MATLAB.git
mv logicleTransform-for-MATLAB/@logicleTransform .</code></pre>
</details>

----------------------------------------------------------------------------------------------------------------------------

To apply the logicle transform, the parameters of the transformation must first be set. There are four parameters:

* T = "top of scale" value
* W = number of approximately linear decades
* M = number of approximately logarithmic decades
* A = number of additional decades of negative data values to be included

These parameters are specified when creating a new logicleTransform object:
```MATLAB
obj = logicleTransform(T,W,M,A);
obj = logicleTransform(T,W,M,A,n_bins); % linear interpolation of transform with n_bins evaluated points
```
The optional `n_bins` parameter specifies the number of bins to be included in the fast logicle transform algorithm. When this parameter is specified, the fast logicle transform is used.

The object stores internal variables for later calculations based on data. In this way, the object guides the calculation of many data points efficiently.

The ``.transform()`` method calculates the transformed value of each element in turn, and returns a matrix of the same dimention as the input.
```MATLAB
transformed_data = obj.transform(data);
```

The ``.inverse()`` method performes the inverse operation.
```MATLAB
data = obj.inverse(transformed_data);
```

The variable `data` can be a matrix of any number of dimensions.

Axes ticks and labels can be set by acessing the Tick and TickLabel properties of the logicleTransform object.

---
## Example 1
```MATLAB
obj = logicleTransform(10000,2,4,0);
x = linspace(obj.inverse(0),obj.T,1000);
y = obj.transform(x);
plot(x,y);
ax = gca;
ax.YTick = obj.Tick;
ax.YTickLabel = obj.TickLabel;
```
![alt text](Example_1_img.png?raw=true "transformation curve")

## Example 2
MATLAB object arrays may be used to operate on each column of a matrix using different transform parameters. This is particularly useful for data intended for scatter plotting (as is generally the case when using a logicle transform).
```MATLAB
rng default; % for reproducability
obj = [logicleTransform(1000,2,4,0),logicleTransform(10000,1,4.5,0.4,2^6)];
x = randn(1000,2)*50 + 10;
y = obj.transform(x);
scatter(y(:,1),y(:,2),'.');
ax = gca;
ax.XTick = obj(1).Tick;
ax.XTickLabel = obj(1).TickLabel;
ax.YTick = obj(2).Tick;
ax.YTickLabel = obj(2).TickLabel;
```
![alt text](Example_2_img.png?raw=true "scattered transformed data")

---
## Class folders keep things neat and tidy

Using class folders as [documented here](https://uk.mathworks.com/help/matlab/matlab_oop/organizing-classes-in-folders.html) is a useful way to keep this (and other classes you may have written) separated in your filesystem to prevent confusion. In this case, download this repository, and move the folder called ``@logicleTransform`` to your working directory. This can be achieved using the [command above](#simple-installation).

---

## Unit testing

To perform the automated unit test on this code, run the following from the command line:
```shell
matlab -noFigureWindow -nosplash -nodesktop -wait -r "testAll"
```
The [`testAll.m`](testAll.m) script runs a suite of tests defined in the [`logicleTransformTest.m`](logicleTransformTest.m) [unit test class](https://uk.mathworks.com/help/matlab/class-based-unit-tests.html).

---
Algorithms were developed by:  
Moore WA, Parks DR. Update for the Logicle Data Scale Including Operational Code Implementations. Cytometry Part A : the journal of the International Society for Analytical Cytology. 2012;81(4):273-277. [doi:10.1002/cyto.a.22030](http://onlinelibrary.wiley.com/doi/10.1002/cyto.a.22030/abstract).

An implementation in R (which actually uses the compiled C/C++ code by the above authors) is available from Bioconductor, in the "flowCore" package. To install this package in R, use the commands:
```R
## try http:// if https:// URLs are not supported
source("https://bioconductor.org/biocLite.R")
biocLite("flowCore")
```
