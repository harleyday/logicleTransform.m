function data_out = logicle_transform(p,data_in)
% Paraphrasing of c++ implementation by Wayne A. Moore found at
% http://onlinelibrary.wiley.com/doi/10.1002/cyto.a.22030/full
% handle true zero separately
if(isfield(p,'bins'))
    index = zeros(size(data_in));
    for i = 1:length(data_in(:))
        % lookup the nearest value;
        index(i) = intScale(p.bins,p.lookup,data_in(i));
    end
    % inverse interpolate the table linearly
    delta = (data_in - p.lookup(index))./(p.lookup(index+1)-p.lookup(index));
    data_out = (index+delta)/p.bins;
else
    data_out = zeros(size(data_in));
    for i = 1:length(data_in(:))
        data_out(i) = numerically_invert(p,data_in(i));
    end
end
end

function out = numerically_invert(p,value)
if (value == 0)
    out = p.x1;
    return;
end

% reflect negative values
negative = value < 0;
if (negative)
    value = -value;
end

% initial guess at solution
if(value < p.f)
    % use linear approximation in the quasi linear region
    x = p.x1 + value/p.taylor(1);
else
    % otherwise use ordinary logarithm
    x = log(value/p.a)/p.b;
end

% try for precision unless in extended range
tolerance = 3*eps(1);
if(x > 1)
    tolerance = 3*eps(x);
end

for i=0:10
    % compute the function and its first two derivatives
    ae2bx = p.a*exp(p.b*x);
    ce2mdx = p.c/exp(p.d*x);
    if (x < p.xTaylor)
        % near zero use the Taylor series
        y = seriesBiexponential(p,x) - value;
    else
        % this formulation has better roundoff behavior
        y = ae2bx - ce2mdx + p.f - value;
    end
    abe2bx = p.b*ae2bx;
    cde2mdx = p.d*ce2mdx;
    dy = abe2bx + cde2mdx;
    ddy = p.b*abe2bx - p.d*cde2mdx;
    
    % this is Halley's method with cubic convergence
    delta = y/(dy*(1 - y*ddy/(2*dy^2)));
    x = x - delta;
    
    % if we've reached the desired precision we're done
    if(abs(delta)<tolerance)
        % handle negative arguments
        if(negative)
            out = 2*p.x1 - x;
            return;
        else
            out = x;
            return;
        end
    end
end
if(negative)
    out = 2*p.x1 - x;
    return;
else
    out = x;
    return;
end
end

function out = seriesBiexponential(p,scale)
% Paraphrasing of c++ implementation by Wayne A. Moore found at
% http://onlinelibrary.wiley.com/doi/10.1002/cyto.a.22030/full
% Taylor series is around x1
x = scale - p.x1;
% note that taylor(2) should be identically zero according
% to the Logicle condition so skip it here
sum = p.taylor(16)*x; % TAYLOR_LENGTH = 16
for i = (16-1):3
    sum = (sum + p.taylor(i))*x;
end
out = (sum*x + p.taylor(1))*x;
end

function out = intScale(n_bins,lookup_vector,val)
lo = 1;
hi = n_bins;
while(lo<=hi)
    mid = bitshift(lo+hi,-1);
    key = lookup_vector(mid);
    if(val<key)
        hi = mid - 1;
    elseif(val>key)
        lo = mid + 1;
    else
        out = mid;
        return
    end
end
out = mid;
end