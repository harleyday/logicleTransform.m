function dydt = diffEqn ( obj, t, y, switch_states )
% define the differential equations of your model


% ODE parameters
a  = obj.parameters.a;
b  = obj.parameters.b;
c  = obj.parameters.c;
d  = obj.parameters.d;
e  = obj.parameters.e;
f  = obj.parameters.f;

% I'm just going to define the threshold values of the switches here. You
% can pass them as arguments or incorporate them into the parameters vector
% if you wish
sw_1_minus = 0.2;
sw_1_plus  = 0.8;

sw_2_minus = 0.3;
sw_2_plus  = 0.7;


% calculate the value of each switch given their current states.
% we pass in the table defining the switch values as the first argument.
sw_1 = sw_1_fun(obj.switch_1, switch_states(1));
sw_2 = sw_2_fun(obj.switch_2, switch_states(2));

% for simplicity, I'm defining a 2*2 linear differential equation with the
% switches sw_1 and sw_2 added as a vector to the end.
dydt = [a, b;
        c, d] * y + [e*sw_1;
                     f*sw_2];
end

function sw_value = sw_1_fun (switch_1, sw_state )
% function which looks for the value of the switch given it's current state
if sw_state == false
    sw_value = switch_1.off;
else
    sw_value = switch_1.on;
end
end

function sw_value = sw_2_fun(switch_2, sw_state )
% function which looks for the value of the switch given it's current state
if sw_state == false
    sw_value = switch_2.off;
else
    sw_value = switch_2.on;
end
end