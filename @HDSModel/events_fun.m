function [value,isterminal,direction] = events_fun(obj, t, y, switch_states)
% function to detect events of interest in our simulations, such as switch
% changes, or forced changes such to switch states at specified times

% ODE parameters
a  = obj.parameters.a;
b  = obj.parameters.b;
c  = obj.parameters.c;
d  = obj.parameters.d;

% I'm just going to define the threshold values of the switches here. You
% can pass them as arguments or incorporate them into the parameters vector
% if you wish
sw_1_minus = 0.2;
sw_1_plus  = 0.8;

sw_2_minus = 0.3;
sw_2_plus  = 0.7;

%% calculate the threshold value and direction of change for each switch.
if switch_states(1)==false
    sw_1_switching_value = y(2) - sw_1_plus;
    sw_1_direction = 1; % stop only if going in positive direction
    sw_1_isterminal = 1; % we always set these to 1, so that the solver stops after each switch transition to record what happened
else
    sw_1_switching_value = y(2) - sw_1_minus;
    sw_1_direction = -1; % stop only if going in negative direction
    sw_1_isterminal = 1;
end

if switch_states(2)==false
    sw_2_switching_value = y(1) - sw_2_plus;
    sw_2_direction = 1; % stop only if going in positive direction
    sw_2_isterminal = 1;
else
    sw_2_switching_value = y(1) - sw_2_minus;
    sw_2_direction = -1; % stop only if going in negative direction
    sw_2_isterminal = 1;
end

% value: the threshold value(s) for each switch.
value = [sw_1_switching_value, sw_2_switching_value];

% isterminal: 1 = do stop. 0 = don't stop. We always set this to be 1 since
% we need to stop to recalculate the switch thresholds
isterminal = [sw_1_isterminal, sw_2_isterminal];

% direction: which direction of crossing are we interested in detecting.
% 1 = increasing, -1 = decreasing, 0 = either direction.
direction = [sw_1_direction, sw_2_direction];
end