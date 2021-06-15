classdef logicleTransformTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        type = {'logicleTransform'}
    end
    
    properties
        obj1d
        obj2d
        objNd
        expectedRelTol
    end
    
    properties (ClassSetupParameter)
        inputs_1 = struct('transform_parameters', struct('T',1e4,'W',2,'M',4,'A',0),...
            'transform_parameters_and_n_bins', struct('T',1e4,'W',1,'M',4.5,'A',0.4,'n_bins',2^6))
        inputs_2 = struct('transform_parameters', struct('T',1e4,'W',0,'M',4.2,'A',0.1),...
            'transform_parameters_and_n_bins', struct('T',1e3,'W',2,'M',4.8,'A',0.5,'n_bins',2^6))
        torance = struct ( 'high', 1e-10, 'low', 1e-2)
    end
    
    methods(TestClassSetup, ParameterCombination='sequential')
        function testLogicTranformConstructor ( testCase, inputs_1, inputs_2, torance )
            inputs_1 = struct2cell(inputs_1);
            inputs_2 = struct2cell(inputs_2);
            
            testCase.obj1d = logicleTransform(inputs_1{:});
            testCase.obj2d = [logicleTransform(inputs_1{:}),logicleTransform(inputs_2{:})];
            testCase.objNd = repmat(logicleTransform(inputs_1{:}),2,3);
            
            testCase.expectedRelTol = torance;
        end
    end
    
    methods (Test, ParameterCombination='sequential')
        function testTransformation1d ( testCase )
            x = linspace(testCase.obj1d.inverse(0),testCase.obj1d.T,1000);
            y = testCase.obj1d.transform(x);
            xRecover = testCase.obj1d.inverse(y);
            testCase.verifyEqual(xRecover, x, 'RelTol', testCase.expectedRelTol);
        end
        
        function testTransformation2d ( testCase )
            x = [linspace(testCase.obj2d(1).inverse(0),testCase.obj2d(1).T,1000)',...
                linspace(testCase.obj2d(2).inverse(0),testCase.obj2d(2).T,1000)'];
            y = testCase.obj2d.transform(x);
            xRecover = testCase.obj2d.inverse(y);
            testCase.verifyEqual(xRecover, x, 'RelTol', testCase.expectedRelTol);
        end
        
        function testTransformationNd ( testCase )
            x = rand(2,3);
            y = testCase.objNd.transform(x);
            xRecover = testCase.objNd.inverse(y);
            testCase.verifyEqual(xRecover, x, 'RelTol', testCase.expectedRelTol);
        end
    end
    
    methods (Test)
        
        function testClass(testCase, type)
            testCase.verifyClass(testCase.obj1d, type);
            testCase.verifyClass(testCase.obj2d, type);
        end
        
        function testSize(testCase)
            testCase.verifySize(testCase.obj1d, [1,1]);
            testCase.verifySize(testCase.obj2d, [1,2]);
        end
        
        function testRejectWrongInputSize(testCase)
            testCase.verifyError(@() testCase.obj2d.transform(0    ),'logicleTransform:InputSizeError');
        end
        
    end
end