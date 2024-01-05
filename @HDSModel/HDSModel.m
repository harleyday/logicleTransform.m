classdef HDSModel
    % a class defining your model system. It stores the ODEs, the switches,
    % parameter names and values
    properties ( Constant = true, Access = public ) % these properties will be publicly visible but unchangeable
        parameter_names = {'a','b','c','d','e','f'}
    end
    
    properties ( Access = public )
        parameters (1,6) {istable}

        % Here are two switches for simplicity
        switch_1 {istable} = table ( 0, 1, 'VariableNames', {'off', 'on'} )
        switch_2 {istable} = table ( 1, 0, 'VariableNames', {'off', 'on'} )
    end
    
    methods ( Access = public )
        % constructor function
        function obj = HDSModel(parameter_values)
            % Constructor function for this class. It creates instances
            % "YourModel" class. Each instance will show up as an object in
            % the workspace.

            % we expect a vector of four parameter values, corresponding to
            % a, b, c and d respectively
            obj.parameters = parameter_values;
        end
        
        %% method to numerically integrate from an initial value. (solve initial value problem)
        [t, y, t_sw, y_sw] = solve_ivp(obj, t_sample, y0, sw0)
    end
    
    methods ( Access = private )
        % These methods are hidden from the user of the object to keep it
        % as simple as possible. You can still access them as normal for
        % debugging purposes.

        % this method keeps track of the events
        [value, isterminal, direction] = events_fun ( m, t, y, switch_states )
        
        dydt = diff_eqn ( m, t, y, switch_states )
        % jac  = jac_eqn  ( m, t, y, switch_states ) % again, you probably won't need to specify the jacobian, but here's where you'd do it.
    end

    methods
        function obj = set.parameters(obj, parameter_valuess)
            % set the parameters property. Every time we try to set the
            % parameter property, this "setting method" is called.

            n_parameters = length(obj.parameter_names);
            if isnumeric(parameter_valuess)
                if length(parameter_valuess)~=n_parameters % if the vector is of the wrong length
                    error('HDSModel:ParameterError','We expect %i parameters in the vector.', n_parameters)
                end
                obj.parameters = array2table(parameter_valuess, 'VariableNames', obj.parameter_names);
            elseif istable(parameter_valuess)
                % check the names of the parameters in the incoming table
                % all match up with those we expect in the parameter_names
                % property
                present = ismember(obj.parameter_names, parameter_valuess.Properties.VariableNames );
                if ( sum(present) ~= n_parameters ) % if not all parameters are accounted for
                    error('HDSModel:ParameterError',['Parameter(s) [', strjoin(m.parameter_names(~present),', '), '] did not appear in the parameter table you provided. Please provide these.']);
                end
                obj.parameters = parameter_valuess;
            else
                error('We expect parameters specified as either a vector or table.')
            end
        end
    end
end
