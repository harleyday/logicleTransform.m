classdef logicleTransformTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        type = {'logicleTransform'};
    end
    
    properties
        obj;
        expectedRelTol
    end
    
    properties (ClassSetupParameter)
        inputs = struct('transform_parameters', struct('T',1e4,'W',2,'M',4,'A',0),...
            'transform_parameters_and_n_bins', struct('T',1e4,'W',1,'M',4.5,'A',0.4,'n_bins',2^6));
        torance = struct ( 'high', 1e-10, 'low', 1e-2);
    end
    
    methods(TestClassSetup, ParameterCombination='sequential')
        function testLogicTranformConstructor ( testCase, inputs, torance )
            inputs = struct2cell(inputs);
            testCase.obj = logicleTransform(inputs{:});
            testCase.expectedRelTol = torance;
        end
    end
    
    methods (Test, ParameterCombination='sequential')
        function testTransformation ( testCase )
            x = linspace(testCase.obj.inverse(0),testCase.obj.T,1000);
            y = testCase.obj.transform(x);
            xRecover = testCase.obj.inverse(y);
            testCase.verifyEqual(xRecover, x, 'RelTol', testCase.expectedRelTol);
        end
    end
    
    methods (Test)
        
        function testClass(testCase, type)
            testCase.verifyClass(testCase.obj, type);
        end
        
        function testSize(testCase)
            testCase.verifySize(testCase.obj, [1,1]);
        end
        
    end
end