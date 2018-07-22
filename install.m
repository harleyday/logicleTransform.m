function install()
disp('Starting Logicle Transform app');
%% run the unit test suite
disp( 'Testing app performance.' );
import matlab.unittest.TestSuite;

try
    suite = TestSuite.fromClass ( ?logicleTransformTest );
    results = run ( suite );
    display ( results );
    disp( 'Tests passed with no errors. Enjoy!' );
    disp( 'User manual can be found at the <a href="https://harleyday.github.io/logicleTransform-for-MATLAB/">GitHub Pages site</a>.' );
catch e
    display( getReport ( e, 'extended' ) );
    disp( 'Logicle Transform app contains errors. Please register an issue at the <a href="https://github.com/harleyday/logicleTransform-for-MATLAB">GitHub repository</a>.' );
    disp( 'Thank you for your time, and sorry for the inconvenience.' );
    exit ( 1 );
end
end