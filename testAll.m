import matlab.unittest.TestSuite;

try
    suite = TestSuite.fromClass ( ?logicleTransformTest );
    results = run ( suite );
    display ( results );
catch e
    disp ( getReport ( e, 'extended' ) );
    exit ( 1 );
end
exit(any([results.Failed]));