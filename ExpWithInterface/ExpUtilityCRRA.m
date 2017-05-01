function [ eu ] = ExpUtilityCRRA( x , beta )
%CRRAEXPUTILITY returns expected utility for a CRRA utility
%   for only one non zero outcome.
    eu = 0.0;
    if beta(2) < 1.0001 && beta(2) > 0.9999
        eu = beta(1) * (x(1)/100) * log(x(2));
    else
        eu = beta(1) * (x(1)/100) * (x(2)^(1-beta(2))-1) / (1-beta(2));
    end
end

