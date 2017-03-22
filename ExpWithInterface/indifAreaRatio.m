function [ arearatio , x22 ] = indifAreaRatio( x11,x12,x21,theta )
%INDIFAREARATIO first solves for x22. thenr eturns the ratio of the 
%intersection over the unnion of the areas covered by x1 and x2.
%   Detailed explanation goes here
    x1_area = x11 * x12;
    objective = @(x22) (ExpectedChoiceProba([x11,x12],[x21,x22],theta)-0.5)^2;
    options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton','OptimalityTolerance',0.0001);
    [x22,fval,exitflag,output] = fminunc(objective,5,options);

    %compute union and intersection of x1 area and x2 area
    x2_area = x21 * x22;
    inter = min([x11,x21])* min([x12,x22]);
    union = x1_area + x2_area - inter;
    arearatio = inter / union;
    fprintf('area ratio: %.2f , with x2=(%.2f,%.2f) \n',arearatio,x21,x22);
    
end

