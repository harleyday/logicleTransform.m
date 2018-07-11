function data_out = transform(obj,data_in)
% Paraphrasing of c++ implementation by Wayne A. Moore found at
% http://onlinelibrary.wiley.com/doi/10.1002/cyto.a.22030/full
%% preable to determine how to treat multidimensional input
% szo = size(obj);
% szd = size(data_in);
% if szo==[1,1] % if scalar object, apply this to the whole data_in array
%     obji = @(i) 1;
% elseif szo==szd % if size of object is the same as that of data_in, apply each object to it's corresponding element in the array
%     obji = @(i) i;
% elseif szo(2)==szd(2)&&szo(1)==1
%     obji = @(i) mod(floor((i-1)/szd(1)),szd(2))+1;
% else
%     error('Size of LogicleTransform object must be scalar, vector or same size as data_in');
% end
%%
data_out = zeros(size(data_in));
for i = 1:length(data_in(:))
    if ~isempty(obj.n_bins)
        % lookup the bin into which this data point falls and return the left edge of the bin
        index = BinSearch(obj.lookup,data_in(i));
        
        % inverse interpolate the table linearly
        delta = (data_in(i)-obj.lookup(index))./(obj.lookup(index+1)-obj.lookup(index));
        data_out(i) = (index-1+delta)/obj.n_bins;
    else
        data_out(i) = numerically_invert(obj,data_in(i));
    end
end

    function ind = BinSearch(lookup,value) % binary search algorithm to find the left bin edge of the lookup vector into which data falls
        lo = 1;
        hi = length(lookup);
        
        while hi-lo>1
            mid = bitshift(lo+hi,-1);
            key = lookup(mid);
            if value>=key
                lo = mid;
            elseif value<key
                hi = mid;
            end
        end
        ind = lo;
    end
end