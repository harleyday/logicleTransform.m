classdef LogicleTransform
    
    properties (Access = public)
        T
        W
        M
        A
        Tick
        TickLabel
    end
    
    properties (Access = private)
        % variables used by numerical methods which calculate logicle
        % transform
        w
        x2
        x1
        x0
        b
        d
        a
        c
        f
        xTaylor
        taylor
        % fast logicle transform properties
        n_bins
        lookup
    end
    
    methods (Access = public)
        function obj = LogicleTransform(T, W, M, A, varargin)
            % allocate the parameter structure
            if (T <= 0)
                error('We require T > 0');
            end
            if (W < 0)
                error('We require W >= 0');
            end
            if (M <= 0)
                error('We require M > 0');
            end
            if (2*W > M)
                error('We require W <= M/2');
            end
            if (A > M - 2*W)||(A < -W)
                error('We require -W <= A <= (M - 2*W)');
            end
            
            obj.T = T;
            obj.W = W;
            obj.M = M;
            obj.A = A;
            % if we're going to bin the data make sure that zero is on a bin boundary by adjusting A
            if (nargin ==5)
                zero = (W + A)/(M + A);
                zero = floor(zero*varargin{1} + 0.5)/varargin{1};
                A = (M*zero - W)/(1 - zero);
            end
            %%
            % actual parameters formulas from biexponential paper
            obj.w = W/(M+A);
            obj.x2 = A/(M+A);
            obj.x1 = obj.x2 + obj.w;
            obj.x0 = obj.x2 + 2*obj.w;
            obj.b = (M+A)*log(10);
            obj.d = solve_RTSAFE(obj.b,obj.w);
            c_a = exp(obj.x0*(obj.b+obj.d));
            mf_a = exp(obj.b*obj.x1) - c_a/exp(obj.d*obj.x1);
            obj.a = T/((exp(obj.b) - mf_a) - c_a/exp(obj.d));
            obj.c = c_a*obj.a;
            obj.f = -mf_a*obj.a;
            %% use Taylor series near x1, i.e., data zero to avoid round off problems of formal definition
            obj.xTaylor = obj.x1 + obj.w/4;
            % compute coefficients of the Taylor series
            posCoef = obj.a*exp(obj.b*obj.x1);
            negCoef = -obj.c/exp(obj.d*obj.x1);
            % 16 is enough for full precision of typical scales
            obj.taylor = zeros(16,1);
            for p=1:16
                posCoef = posCoef*obj.b/p;
                negCoef = -negCoef*obj.d/p;
                obj.taylor(p) = posCoef + negCoef;
            end
            obj.taylor(2) = 0;
            if (nargin == 5)
                if isscalar(varargin{1}) && round(varargin{1})==varargin{1}
                    obj.n_bins = varargin{1};
                    obj.lookup = inverse(obj,linspace(0,1,obj.n_bins+1));
                else
                    error('Number of bins must be a scalar integar. We advise between 2^5 and 2^10 bins for high resolution and speed.')
                end
            end
            %% set axes tick and label properties
            minimum = obj.inverse(0);
            maximum = obj.T;
            log_min = sign(minimum)*ceil(log10(abs(minimum)));
            log_max = sign(maximum)*ceil(log10(abs(maximum)));
            power = log_min:log_max;
            sn = sign(power);
            pow = abs(power);
            
            decades = sn.*10.^pow; % node that decades includes 0. e.g.: -100, -10, -1, 0, 1, 10.
            % put some linearly-separated axes labels within each decade to visually
            % demonstrate the logicle scaling when on axes
            n_decades = length(decades);
            n_ticks = (n_decades-1)*9 + 1 + 2*sum(decades==0); % if we have 0 included in our decades, add 2 to the number of ticks because we will tick at -1 and 1
            obj.Tick = zeros(1,n_ticks);
            obj.TickLabel = cell(1,n_ticks);
            tick_index = 1;
            previous_labeled_decade = -Inf;
            for k=1:n_decades
                % write TickLabel for the bottom of this decade
                if obj.transform(decades(k))-obj.transform(previous_labeled_decade)<0.02 % if the distance between this decade and the last is less than 0.02, do not label this decade because we may overlap the labels
                    obj.TickLabel{tick_index} = '';
                else
                    if sn(k)==0
                        obj.TickLabel{tick_index-1} = '0';
                        obj.TickLabel{tick_index} = '';
                    else
                        if sn(k)==-1
                            sign_string = '-';
                        else
                            sign_string = '';
                        end
                        obj.TickLabel{tick_index} = [sign_string,'10^{',num2str(pow(k)),'}'];
                    end
                    previous_labeled_decade = decades(k);
                end
                
                if k==n_decades
                    % write Tick for final decade
                    obj.Tick(tick_index) = obj.transform(decades(k));
                    break;
                end
                
                % write Tick for this decade in 9 increments if the ends of
                % the decades are powers of 10 increments if the
                % right hand end of the gap is 0 (i.e.10^{-inf})
                if decades(k+1)==0
                    n_increments = 11;
                    lhs = decades(k);
                    rhs = decades(k+1) - min(abs([lhs,decades(k+1)]));
                elseif decades(k)==0
                    n_increments = 9;
                    lhs = 1;
                    rhs = decades(k+1) - min(abs([lhs,decades(k+1)]));
                else
                    n_increments = 9;
                    lhs = decades(k);
                    rhs = decades(k+1) - min(abs([lhs,decades(k+1)]));
                end
                obj.Tick(tick_index:tick_index+n_increments-1) = obj.transform(linspace(lhs,rhs,n_increments));
                % write empty TickLabel for the next 8 or 9 linear increments
                % within this decade
                for i=tick_index+1:tick_index+n_increments-1
                    obj.TickLabel{i} = '';
                end
                
                tick_index = tick_index + n_increments;
            end
            
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
            
        end
        
        function data_out = transform(obj,data_in)
            % Paraphrasing of c++ implementation by Wayne A. Moore found at
            % http://onlinelibrary.wiley.com/doi/10.1002/cyto.a.22030/full
            %% preable to determine how to treat multidimensional input
            szo = size(obj);
            szd = size(data_in);
            if szo==[1 1] % if scalar object, apply this to the whole data_in array
                obji = @(i) 1;
            elseif szo==szd % if size of object is the same as that of data_in, apply each object to it's corresponding element in the array
                obji = @(i) i;
            elseif szo(2)==szd(2)&&szo(1)==1
                obji = @(i) mod(floor(i/szd(1)),szd(2))+1;
            else
                error('Size of LogicleTransform object must be scalar, vector or same size as data_in');
            end
            %%
            data_out = zeros(size(data_in));
            for i = 1:length(data_in(:))
                if ~isempty(obj(obji(i)).n_bins)
                    % lookup the bin into which this data point falls and return the left edge of the bin
                    index = obj(obji(i)).n_bins; % linear search
                    while obj(obji(i)).lookup(index)>data_in(i)&&(index>1) % while lower edge is greater than this data point and we're not in the bottom-most bin, decrement the index
                        index = index - 1;
                    end
                    
                    % inverse interpolate the table linearly
                    delta = (data_in(i)-obj(obji(i)).lookup(index))./(obj(obji(i)).lookup(index+1)-obj(obji(i)).lookup(index));
                    data_out(i) = (index-1+delta)/obj(obji(i)).n_bins;
                else
                    data_out(i) = numerically_invert(obj(obji(i)),data_in(i));
                end
            end
        end
        
        function out = inverse(obj,data_in)
            % Paraphrasing of c++ implementation by Wayne A. Moore found at
            % http://onlinelibrary.wiley.com/doi/10.1002/cyto.a.22030/full
            %% preable to determine how to treat multidimensional input
            szo = size(obj);
            szd = size(data_in);
            if szo==[1 1] % if scalar object, apply this to the whole data_in array
                obji = @(i) 1;
            elseif szo==szd % if size of object is the same as that of data_in, apply each object to it's corresponding element in the array
                obji = @(i) i;
            elseif szo(2)==szd(2)&&szo(1)==1
                obji = @(i) mod(floor(i/szd(1)),szd(2))+1;
            else
                error('Size of LogicleTransform object must be scalar, vector or same size as data_in');
            end
            %%
            out = zeros(size(data_in));
            for i = 1:length(data_in(:))
                negative = data_in(i) < obj(obji(i)).x1;
                if (negative)
                    data_in(i) = 2*obj(obji(i)).x1 - data_in(i);
                end
                % compute the biexponential
                if (data_in(i) < obj(obji(i)).xTaylor)
                    % near x1, i.e., data zero use the series expansion
                    inverse = seriesBiexponential(obj(obji(i)),data_in(i));
                else
                    % this formulation has better roundoff behavior
                    inverse = (obj(obji(i)).a*exp(obj(obji(i)).b*data_in(i)) + obj(obji(i)).f) - obj(obji(i)).c/exp(obj(obji(i)).d*data_in(i));
                end
                
                % handle scale(i) for negative values
                if (negative)
                    out(i) = -inverse;
                else
                    out(i) = inverse;
                end
            end
        end
    end
    
    methods (Access = private)
        
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
        
        function out = seriesBiexponential(obj,scale)
            % Paraphrasing of c++ implementation by Wayne A. Moore found at
            % http://onlinelibrary.wiley.com/doi/10.1002/cyto.a.22030/full
            % Taylor series is around x1
            x = scale - obj.x1;
            % note that taylor(2) should be identically zero according
            % to the Logicle condition so skip it here
            sum = obj.taylor(16)*x; % TAYLOR_LENGTH = 16
            for i = 16:(-1):3
                sum = (sum + obj.taylor(i))*x;
            end
            out = (sum*x + obj.taylor(1))*x;
        end
    end
end
