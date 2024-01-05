% define the parameter values a, b, c, d, e, f
parameter_values = [-1, 0.1, 0.2, -4, 1, 4];

% make a model object
model = HDSModel(parameter_values);

% print the parameters for inspection
disp(model.parameters);

%% solve the initial value problem, sampling at 10 points between 0 and 10.
% initial conditions: y0 = [1, 2]
%                     sw0 = [0, 1]
[t, y, t_sw, y_sw] = model.solve_ivp(linspace(0, 10, 1000), [1,1], [1, 1]);

%% plot continuous-valued and discrete-valued state variables
figure(1);
plot(t, y(:,1), ...
    t, y(:,2));
legend({'y1', 'y2'}, 'Location','eastoutside');

figure(2);
stairs(t_sw, y_sw);
legend({'sw1', 'sw2'}, 'Location','eastoutside');



%% Hi Hannah. I haven't been able to write a sensible ODE system for this
% yet, so the one in there just flies off to inifinity. However, the code
% itself looks like it's working okay, so perhaps you can just edit the
% diff_eqn method to incorporate your model and get some more sensible
% results.