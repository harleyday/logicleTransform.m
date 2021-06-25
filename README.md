# logicleTransform

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/f6ed7da0587340e1bde5c0ce8bb5eb58)](https://app.codacy.com/app/harleyday/logicleTransform.m?utm_source=github.com&utm_medium=referral&utm_content=harleyday/logicleTransform.m&utm_campaign=Badge_Grade_Dashboard)
[![Unit Test](https://github.com/harleyday/logicleTransform.m/actions/workflows/main.yml/badge.svg)](https://github.com/harleyday/logicleTransform.m/actions/workflows/main.yml)
[![codecov](https://codecov.io/gh/harleyday/logicleTransform.m/branch/master/graph/badge.svg?token=07JG0AC4XA)](https://codecov.io/gh/harleyday/logicleTransform.m)
[![View logicleTransform.m on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://uk.mathworks.com/matlabcentral/fileexchange/68289-logicletransform-m)

**MATLAB class to apply the logicle transformation to a matrix and provide axes labels.**

----------------------------------------------------------------------------------------------------------------------------

## Installation
This call can be installed by any of the following methods:
<details id="direct-download">
  <summary>
    <strong>MATLAB IDE users. (Click to expand)</strong>
  </summary>
  Download the latest <code>logicleTransform.m.mltbx</code> file from the <a href="https://github.com/harleyday/logicleTransform.m/releases">releases page of this GitHub repository</a>. Install this from MATLAB by double-clicking on toolbox the file.
</details>

<details id="MATLAB-command-installation">
  <summary>
    <strong>For those with no MATLAB IDE  (perhaps running MATLAB kernel in Jupyter Notebook). (Click to expand)</strong>
  </summary>
  Once you've downloaded the <a href="https://harleyday.github.io/downloadGitHubRelease/"><code>downloadGitHubRelease</code></a> tool, you can install the <code>logicleTransform.m</code> toolbox file using the following at the MATLAB command line:<br>
  <code>downloadGitHubRelease ( 'harleyday/logicleTransform.m', 'install', true );</code>
</details>

<details id="source-installation">
  <summary>
    <strong>For developers wishing to edit the code. (Click to expand)</strong>
  </summary>
  These instructions will place the source code in your working directory so that you can edit it as you wish.<br>
  <strong>For linux users</strong>
  <br>
  Go to your working directory for your MATLAB project, and extract the <code>@logicleTransform</code> directory from the latest release archive. This can be done using a curl one-liner:
  <br>
  <pre><code>cd path/to/working/directory
curl -L https://github.com/harleyday/logicleTransform.m/archive/v1.3.tar.gz | tar -xzf - --strip-components=1 logicleTransform.m-1.3/@logicleTransform/</code></pre>

  <strong>For windows users</strong>
  <br>
  Download and extract the <a href="https://github.com/harleyday/logicleTransform.m/archive/v1.3.zip">zip archive</a>. The folder <code>@logicleTransform</code> should be placed into your working directory.
</details>

----------------------------------------------------------------------------------------------------------------------------

## Usage

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
![alt text](./img/Example_1_img.png?raw=true "transformation curve")

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
![alt text](./img/Example_2_img.png?raw=true "scattered transformed data")

---
## Run tests
<details id="results">
  <summary>
    You can run unit testing of this MATLAB class using the following static method. (Click to expand)
    <pre><code>result = logicleTransform.test;</code></pre>
  </summary>
  
  If the class is working, this will yield the following:
  <pre><code>Checking logicleTransform.m class performance using the packaged test suite.
  Running logicleTransformTest
  ......
  Done logicleTransformTest
  __________

    6×6 table

                                                         Name                                                        Passed    Failed    Incomplete    Duration       Details   
      ___________________________________________________________________________________________________________    ______    ______    __________    _________    ____________

      'logicleTransformTest[inputs=transform_parameters,torance=high]/testClass(type=logicleTransform)'              true      false       false        0.015385    [1×1 struct]
      'logicleTransformTest[inputs=transform_parameters,torance=high]/testSize'                                      true      false       false       0.0015229    [1×1 struct]
      'logicleTransformTest[inputs=transform_parameters,torance=high]/testTransformation'                            true      false       false         0.04154    [1×1 struct]
      'logicleTransformTest[inputs=transform_parameters_and_n_bins,torance=low]/testClass(type=logicleTransform)'    true      false       false       0.0061918    [1×1 struct]
      'logicleTransformTest[inputs=transform_parameters_and_n_bins,torance=low]/testSize'                            true      false       false       0.0012439    [1×1 struct]
      'logicleTransformTest[inputs=transform_parameters_and_n_bins,torance=low]/testTransformation'                  true      false       false        0.028712    [1×1 struct]

  Tests passed with no errors. Enjoy!
  User manual can be found at the <a href="https://harleyday.github.io/logicleTransform.m/">GitHub Pages site</a>.</code></pre>
  
  If there is a bug somewhere, this test suite might detect it and return something like:
  <pre><code>Checking logicleTransform.m class performance using the packaged test suite.
  Running logicleTransformTest

  ================================================================================
  SOME ERROR DETAILS
  <span>================================================================================</span><!--the spans prevent the === being interpreted as underligning a title-->

  Done logicleTransformTest
  <span>__________</span>

  Failure Summary:

       Name                                                                                                       Failed  Incomplete  Reason(s)
      ==========================================================================================================================================
       logicleTransformTest[inputs=transform_parameters,torance=high]/testClass(type=logicleTransform)              X         X       Errored.
      ------------------------------------------------------------------------------------------------------------------------------------------
       logicleTransformTest[inputs=transform_parameters,torance=high]/testSize                                      X         X       Errored.
      ------------------------------------------------------------------------------------------------------------------------------------------
       logicleTransformTest[inputs=transform_parameters,torance=high]/testTransformation                            X         X       Errored.
      ------------------------------------------------------------------------------------------------------------------------------------------
       logicleTransformTest[inputs=transform_parameters_and_n_bins,torance=low]/testClass(type=logicleTransform)    X         X       Errored.
      ------------------------------------------------------------------------------------------------------------------------------------------
       logicleTransformTest[inputs=transform_parameters_and_n_bins,torance=low]/testSize                            X         X       Errored.
      ------------------------------------------------------------------------------------------------------------------------------------------
       logicleTransformTest[inputs=transform_parameters_and_n_bins,torance=low]/testTransformation                  X         X       Errored.

    6×6 table

                                                         Name                                                        Passed    Failed    Incomplete     Duration       Details   
      ___________________________________________________________________________________________________________    ______    ______    __________    __________    ____________

      'logicleTransformTest[inputs=transform_parameters,torance=high]/testClass(type=logicleTransform)'              false     true        true         0.0016833    [1×1 struct]
      'logicleTransformTest[inputs=transform_parameters,torance=high]/testSize'                                      false     true        true                 0    [1×1 struct]
      'logicleTransformTest[inputs=transform_parameters,torance=high]/testTransformation'                            false     true        true                 0    [1×1 struct]
      'logicleTransformTest[inputs=transform_parameters_and_n_bins,torance=low]/testClass(type=logicleTransform)'    false     true        true        0.00072476    [1×1 struct]
      'logicleTransformTest[inputs=transform_parameters_and_n_bins,torance=low]/testSize'                            false     true        true                 0    [1×1 struct]
      'logicleTransformTest[inputs=transform_parameters_and_n_bins,torance=low]/testTransformation'                  false     true        true                 0    [1×1 struct]

  Logicle Transform class contains errors. Please register this issue at the <a href="https://github.com/harleyday/logicleTransform.m/issues/new/choose">GitHub repository issues page</a>.
  Thank you for your time, and sorry for the inconvenience.</code></pre>
</details>

---
## USEFUL TIP

Using class folders as [documented here](https://uk.mathworks.com/help/matlab/matlab_oop/organizing-classes-in-folders.html) is a useful way to keep this (and other classes you may have written) separated in your filesystem to prevent confusion. In this case, download this repository, and place it in a folder called ``@logicleTransform`` in your working directory. This can be achieved using the [command above](#source-installation).

---
Algorithms were developed by:  
Moore WA, Parks DR. Update for the Logicle Data Scale Including Operational Code Implementations. Cytometry Part A : the journal of the International Society for Analytical Cytology. 2012;81(4):273-277. [doi:10.1002/cyto.a.22030](http://onlinelibrary.wiley.com/doi/10.1002/cyto.a.22030/abstract).

An implementation in R (which actually uses the compiled C/C++ code by the above authors) is [available from Bioconductor, in the "flowCore" package](https://www.bioconductor.org/packages/release/bioc/html/flowCore.html). To install this package in R, use the commands:
```R
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("flowCore", version = "3.8")
```
