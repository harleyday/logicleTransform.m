classdef test_hds_model < matlab.unittest.TestCase
    
    properties
        test_model
    end

    methods(TestClassSetup)
        function testHDSModelConstructor(testCase)
            % check that the constructor throws an error if we give it
            % incorrectly defined inputs
            % 1. check error if parameters given as separate arguments
            testCase.verifyError(@() HDSModel(1, 2, 3, 4, 5, 6), 'MATLAB:TooManyInputs');
            % 2. check error if wrong number of parameters
            testCase.verifyError(@() HDSModel([1, 2, 3, 4, 5, 6, 7]), 'MATLAB:validation:IncompatibleSize');
            % 3. check error if parameters table missing some values
            testCase.verifyError(@() HDSModel(table(1, 2, 3, 4, 5, 'VariableNames',{'a', 'b', 'c', 'd', 'e'})), 'MATLAB:validation:IncompatibleSize');
            
            % define the parameter values a, b, c, d, e, f
            parameter_values = [-1, 0.1, 0.2, -4, 1, 4];
            testCase.test_model = HDSModel(parameter_values);
        end
    end
    
    methods(Test)
        % Test methods
        function testClass(testCase)
            testCase.verifyClass(testCase.test_model, 'HDSModel');
        end

        function testSize(testCase)
            testCase.verifySize(testCase.test_model, [1,1]);
        end

        function testSolver(testCase)
            % define the times we wish to sample the solution
            t_samples = linspace(0, 10, 1000);
            % define the initial conditions for our test
            y0 = [1, 1];
            sw0 = [1, 1];

            [t, y, t_sw, y_sw] = testCase.test_model.solve_ivp(t_samples, y0, sw0);

            testCase.verifyEqual(t, t_samples)
            testCase.verifySize(y, [1000,2]);
            testCase.verifySize(t_sw, [16,1]);
            testCase.verifySize(y_sw, [16,2]);
        end
    end
    
end