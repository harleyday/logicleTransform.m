function d = solve_RTSAFE(b,w)
% Paraphrasing of c++ implementation by Wayne A. Moore found at
% http://onlinelibrary.wiley.com/doi/10.1002/cyto.a.22030/full
% w == 0 means its really arcsinh
if (w==0)
    d = b;
    return;
else
    % Precision is the same as that of b
    tolerance = 2*eps(b);
    % Based on RTSAFE from Numerical Recepies 1st Edition
    % Bracket the root
    d_lo = 0;
    d_hi = b;
    % Bisection first step
    d = (d_lo+d_hi)/2;
    last_delta = d_hi - d_lo;
    % evaluate the f(w,b) = 2 * (ln(d) - ln(b)) + w * (b + d) and its
    % derrivative
    f_b = -2*log(b) + w*b;
    f = 2*log(d) + w*d + f_b;
    last_f = NaN; % storage of last value of f
    for itratn=1:20
        df = 2/d + w;
        % if Newton's method would step outside the bracke or if it isn't converging quickly enough
        if (((d - d_hi) * df - f) * ((d - d_lo) * df - f) >= 0 || abs(1.9 * f) > abs(last_delta * df))
            % take a bisection step
            delta = (d_hi - d_lo)/2;
            d = d_lo + delta;
            if (d==d_lo)
                return; % nothing changed, we're done
            end
        else
            % otherwise take a Newton's method step
            delta = f/df;
            t = d;
            d = d - delta;
            if (d == t)
                return; % nothing changed, we're done
            end
        end
        % if we've reached the desired precision we're done
        if (abs(delta)<tolerance)
            return;
        end
        last_delta = delta;
        % recompute the function
        f = 2 * log(d) + w * d + f_b;
        if (f == 0 || f == last_f)
            return; % found the root or are not going to get any closer
        end
        last_f = f;
        % update the bracketing interval
        if (f < 0)
            d_lo = d;
        else
            d_hi = d;
        end
    end
    error('exceeded maximum iterations in solve()');
end
end