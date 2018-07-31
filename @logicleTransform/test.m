function results = test()
% static method to show unit testing results to the user.
% >> results = logicleTransform.test;
% this can be called without instantiating a logicleTransform object.
disp('Checking logicleTransform.m toolbox performance using the packaged test suite.');
%% run the unit test suite
import matlab.unittest.TestSuite;

try
    suite = TestSuite.fromClass ( ?logicleTransformTest );
    results = run ( suite );
    display ( results );
    disp( 'Tests passed with no errors. Enjoy!' );
    disp( 'User manual can be found at the <a href="https://harleyday.github.io/logicleTransform.m/">GitHub Pages site</a>.' );
catch e
    display ( results );
    display( getReport ( e, 'extended' ) );
    disp( 'Logicle Transform toolbox contains errors. Please register an issue at the <a href="https://github.com/harleyday/logicleTransform.m">GitHub repository</a>.' );
    disp( 'Thank you for your time, and sorry for the inconvenience.' );
end
end