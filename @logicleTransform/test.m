function results = test()
% static method to show unit testing results to the user.
% >> results = logicleTransform.test;
% this can be called without instantiating a logicleTransform object.
disp ( 'Checking logicleTransform.m toolbox performance using the packaged test suite.' );
%% run the unit test suite
import matlab.unittest.TestSuite;

suite = TestSuite.fromClass ( ?logicleTransformTest );
results = run ( suite );
display ( table(results) );
if any ( [results.Failed] )
    disp( 'Logicle Transform toolbox contains errors. Please register this issue at the <a href="https://github.com/harleyday/logicleTransform.m/issues/new/choose">GitHub repository issues page</a>.' );
    disp( 'Thank you for your time, and sorry for the inconvenience.' );
else
    disp( 'Tests passed with no errors. Enjoy!' );
    disp( 'User manual can be found at the <a href="https://harleyday.github.io/logicleTransform.m/">GitHub Pages site</a>.' );
end
end
