import matlab.unittest.TestSuite;

suite = TestSuite.fromClass ( ?logicleTransformTest );
results = run ( suite );
display ( table ( results ) );
exit(any([results.Failed]));
