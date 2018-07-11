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