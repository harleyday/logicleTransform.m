function [t_sample, y, t_sw, y_sw] = solve_ivp(obj, t_sample, y0, sw0)
% solve the initial value problem for this hybrid dynamical system.
% t_sample: a vector specifying the times when we wish to sample the
% solution. Always ensure this has length>2. If it is length 2, the ode45
% function interprets this as a time range rather than a series of sample
% points.
% y0: initial conditions of the continuous-valued state variables. I've
% defined an ODE with two state variables, so make this a vector of length
% 2.
% sw0: initial conditions of the discrete-valued state variables (i.e. the
% switches)

%% optional code which can check if your initial condition specification makes sense
% is_valid = m.verifyInitialConditions(y0, sw0);
% if ~is_valid
%     error('The intitial conditions violate one of the switches');
% end

%% simulation starts here
next_index_to_evaluate = 1; % matlab indexes from 1 which is irritating
num_samples_to_eval = length(t_sample); % number of times requested for evaluation

if num_samples_to_eval==2 % we need to make sure the t_sample vector is interpreted as a sequence of sample points rather than as a range by ode45.
    error('Please ensure the t_sample vector is longer than 2 elements.');
end

% record the times we will be evaluating, and place these at the output of
% this function
t_sample_in_while_loop = t_sample;

t = t_sample_in_while_loop(next_index_to_evaluate); % start at t = t_sample(1);
t_end = t_sample_in_while_loop(num_samples_to_eval); % the desired end time

% preallocate a storage output for the state variables. Each row represents
% a point in time, and each column, one of the continuous state variables
% of our system.
y = NaN(num_samples_to_eval, length(y0));

% preallocate the storage output for the switch states
% we will concatenate the solution to these vectors as we calculate it.
t_sw = t;
y_sw = sw0;
switch_states = sw0;

% some annoying features of MATLAB's event solver mean we need to keep
% track of the first event slightly differently. These things help achieve
% this subtle change.
ignore_first_sample = 0;
extra_time_appended = false;

%% this while loop breaks the process of numerical integration into parts
% we integrate until either: 1. we find a switch threshold has been crossed
% or
% 2. we reach the specified end time (t_end in this function)
while t < t_end
    % first, specify the differential equation and events function for this
    % configuration of the switches. These definitions will be used by the
    % ode45 solver until a switch changes state, at which point we change
    % their definitions accordingly.
    diff_eqn   = @(t,y) obj.diff_eqn(t, y, switch_states);
    % optional jacobian function definition in case you need it
    % jac_fun = @(t,y) m.jac_eqn(t, y, switch_states);
    events_fun = @(t,y) obj.events_fun(t, y, switch_states); % string-separated variables can also be added to the eventsFun input to specify the external forcing.
    
    % set our tolerances here.
    options = odeset('Events', events_fun,...% 'Jacobian', jac_fun,...
                    'RelTol', 1e-8,...
                    'AbsTol', 1e-8);
    
    [t_out, y_out, time_event, ~, index_event] = ode45(diff_eqn, t_sample_in_while_loop, y0, options); % We currently use ode45 not ode15s, which has adaptive timestepping for stiff systems. We are therefore assuming that the system is not stiff which is usually reasonable.
    
    % this if statement solves a specific problem which we can encounter
    % when t_sample has been erroded down to a vector of length 2. If this
    % occurs, the ode45 function interprets the two values as inital and
    % final times in a range, and returns solution values at intermediate
    % points between the two. We really don't want that to happen, so we
    % have some code at the bottom of this while loop which appends a third
    % "fake" end point we don't need so that the solver just gives us three
    % solution points. This if statement just throws away the final "fake"
    % point we don't care about.
    if extra_time_appended==true
        t_out(3) = [];
        y_out(3, :) = [];
    end
    
    if ~isempty(time_event) % we stopped early because an event occured; we must deal with the switches
        % first, we're going to work out how many points we've managed to
        % evaluate. The ODE solver will return values evaluated at each
        % sample point we specified, plus the values at the time when the
        % switches change state. We need to be able to trim away that
        % "value when the switches change state" value, so that we can
        % store our result in the y output matrix. This is fiddly, so
        % apologies for the nasty indexing below. It's about as neat as
        % it'll get.

        % Step 1: work out if the final sample in ode45 output is a
        % switching event. It can sometimes occur that the ODE solver finds
        % an event at the t_end timepoint, in which case we just store it
        % as normal.
        % Step 2: remember if the first sample in our ode45 output is just
        % the previous switching event. In those cases, we
        % "ignore_first_sample" as it's already in the solution matrix y.

        if t_out(end)==t_end % if the ode solver returned because it reached the final timepoint
            final_is_event = 0;
        else
            final_is_event = 1;
        end

        % now we calculate the number of new samples evaluated.
        n_new_samples = length(t_out) - final_is_event - ignore_first_sample;
        
        rows_where_samples_are_found = (1:n_new_samples) + ignore_first_sample;
        storage_rows = next_index_to_evaluate - 1 + (1:n_new_samples); % note the -1 here results from matlab indexing all vectors from 1 (yep, annoying)
        
        if n_new_samples > 0 % if we have found any new sample
            y(storage_rows,:) = y_out(rows_where_samples_are_found,:);
        end
        
        next_index_to_evaluate = next_index_to_evaluate + n_new_samples; % increment the index denoting the next timepoint to be evaluated
        
        %% setup for the next round of integration
        t = t_out(end); % start time is now set to the final time recorded by the solver. This is the time when the switching event occured
        
        % adjust the configuration of the switches so the diff_eqn and
        % events_fun become updated for the next round of integration.
        
        switch index_event(end)
            case 1 % switch 1 making transition
                switch_states(1) = ~switch_states(1);
            case 2 % switch 2 making transition
                switch_states(2) = ~switch_states(2);
        end
        
        y0 = y_out(end,:);
        
        %%
        % make a record of the switch configuration in the time range we've
        % been integrating through.
        t_sw = vertcat(t_sw, time_event); % vertically concatenate the switching time to the end of the record.
        y_sw = vertcat(y_sw, switch_states ); % vertically concatenate the new switch states to the end of the record.
        
        % set the next t_sample times for ode45
        if next_index_to_evaluate == num_samples_to_eval
            % If the next index to evaluate is the final sample requested,
            % we'd end up with a t_sample of length=2. In this case, we
            % must trick the ODE solver into not regarding t_sample as an
            % "interval" of integration, but as a list of times to be
            % evaluated. This can be achieved by appending (end time + 1)
            % to make the t_sample vector length=3.
            % Yes it's a nasty hack, but it is the only way I can find
            % which works.
            extra_time_appended = true;
            t_sample_in_while_loop = [t, t_end, t_end + 1];
        else
            extra_time_appended = false;
            t_sample_in_while_loop = [t, t_sample(next_index_to_evaluate:num_samples_to_eval)];
        end
        
        % because the final sample in y_out is a switching event, and we'll
        % be integrating from that sample in the next round of integration,
        % we need to make a note that we've already recorded that sample so
        % it doesn't end up in our solution matrix y.
        ignore_first_sample = 1;
    else % the ode45 did not detect any events. We simply record the remaining samples to the solution matrix y. The while loop will not run again.
        t = t_out(end);

        n_new_samples = length(t_out) - ignore_first_sample;
        
        rows_where_samples_are_found = (1:n_new_samples) + ignore_first_sample;
        storage_rows = next_index_to_evaluate - 1 + (1:n_new_samples); % note the -1 here results from matlab indexing all vectors from 1 (yep, annoying)
        
        y(storage_rows,:) = y_out(rows_where_samples_are_found,:);

        t_sw = vertcat(t_sw, t_out(end) ); % vetically concatenate the switching time to the end of the record.
        y_sw = vertcat(y_sw, switch_states); % vertically concatenate the new switch states to the end of the record.
    end
end
end