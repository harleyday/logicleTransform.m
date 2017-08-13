function out = inverse(obj,data_in)
% Paraphrasing of c++ implementation by Wayne A. Moore found at
% http://onlinelibrary.wiley.com/doi/10.1002/cyto.a.22030/full
%% preable to determine how to treat multidimensional input
szo = size(obj);
szd = size(data_in);
if szo==[1,1] % if scalar object, apply this to the whole data_in array
    obji = @(i) 1;
elseif szo==szd % if size of object is the same as that of data_in, apply each object to it's corresponding element in the array
    obji = @(i) i;
elseif szo(2)==szd(2)&&szo(1)==1
    obji = @(i) mod(floor((i-1)/szd(1)),szd(2))+1;
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
        inverse = obj(obji(i)).seriesBiexponential(data_in(i));
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