classdef logicleTransform
    
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
        function obj = logicleTransform(T, W, M, A, varargin)
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
            % if we're going to bin the data make sure that zero is on a
            % bin boundary by adjusting A
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
            % This function is only used by the constructor once
            function d = solve_RTSAFE(b,w)
                % Paraphrasing of c++ implementation by Wayne A. Moore
                % found at
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
                    % evaluate the f(w,b) = 2 * (ln(d) - ln(b)) + w * (b +
                    % d) and its derrivative
                    f_b = -2*log(b) + w*b;
                    f = 2*log(d) + w*d + f_b;
                    last_f = NaN; % storage of last value of f
                    for itratn=1:20
                        df = 2/d + w;
                        % if Newton's method would step outside the bracke
                        % or if it isn't converging quickly enough
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
            
            %% set axes tick and label properties
            minimum = obj.inverse(0);
            maximum = obj.T;
            log_min = sign(minimum)*ceil(log10(abs(minimum)));
            log_max = sign(maximum)*ceil(log10(abs(maximum)));
            power = log_min:log_max;
            sn = sign(power);
            pow = abs(power);
            
            decades = sn.*10.^pow; % node that decades includes 0. e.g.: -100, -10, -1, 0, 1, 10.
            % put some linearly-separated axes labels within each decade to
            % visually demonstrate the logicle scaling when on axes
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
                % the decades are powers of 10 increments if the right hand
                % end of the gap is 0 (i.e.10^{-inf})
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
                % write empty TickLabel for the next 8 or 9 linear
                % increments within this decade
                for i=tick_index+1:tick_index+n_increments-1
                    obj.TickLabel{i} = '';
                end
                
                tick_index = tick_index + n_increments;
            end
        end
        
        data_out = transform(obj,data_in)
        
        data_out = inverse(obj,data_in)
        
        ax_obj_out = labelAxes(obj,ax_obj_in)
    end
    
    methods (Access = private)
        out = numerically_invert(obj,value)
        
        out = seriesBiexponential(obj,scale)
    end
    
    methods (Static)
        results = test (obj);
    end
end
