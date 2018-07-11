function out = numerically_invert(obj,value)
if (value == 0)
    out = obj.x1;
    return;
end
% reflect negative values
negative = value < 0;
if (negative)
    value = -value;
end

% initial guess at solution
if (value < obj.f)
    % use linear approximation in the quasi linear region
    x = obj.x1 + value/obj.taylor(1);
else
    % otherwise use ordinary logarithm
    x = log(value/obj.a)/obj.b;
end

% try for precision unless in extended range
tolerance = 3*eps(1);
if (x > 1)
    tolerance = 3*eps(x);
end

for i=0:10
    % compute the function and its first two derivatives
    ae2bx = obj.a*exp(obj.b*x);
    ce2mdx = obj.c/exp(obj.d*x);
    if (x < obj.xTaylor)
        % near zero use the Taylor series
        y = seriesBiexponential(obj,x) - value;
    else
        % this formulation has better roundoff behavior
        y = ae2bx - ce2mdx + obj.f - value;
    end
    abe2bx = obj.b*ae2bx;
    cde2mdx = obj.d*ce2mdx;
    dy = abe2bx + cde2mdx;
    ddy = obj.b*abe2bx - obj.d*cde2mdx;
    
    % this is Halley's method with cubic convergence
    delta = y/(dy*(1 - y*ddy/(2*dy^2)));
    x = x - delta;
    
    % if we've reached the desired precision we're done
    if (abs(delta)<tolerance)
        % handle negative arguments
        if (negative)
            out = 2*obj.x1 - x;
            return;
        else
            out = x;
            return;
        end
    end
end
if (negative)
    out = 2*obj.x1 - x;
    return;
else
    out = x;
    return;
end
end