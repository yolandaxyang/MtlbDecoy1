function [ arearatio , x22_norm ] = indifAreaRatio( x11_norm,x12_norm,x21_norm,theta , Model )
%INDIFAREARATIO first solves for x22. then returns the ratio of the 
%intersection over the unnion of the areas covered by x1 and x2. Everything
%is normalized.
    run('NormalizeVars.m');
    x1_area = x11_norm * x12_norm;
    options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton','OptimalityTolerance',0.0001,'UseParallel',true);
    if strcmp(Model,'EU')
        objective = @(x22_norm) (ExpectedChoiceProba(DenormalizeX([x11_norm,x12_norm]),DenormalizeX([x21_norm,x22_norm]),theta,Model)-0.5)^2;
    else
        objective = @(x22_norm) (ExpectedChoiceProba([x11_norm,x12_norm],[x21_norm,x22_norm],theta,Model)-0.5)^2;
    end
    [x22_norm,fval,exitflag,output] = fminunc(objective,x12_norm,options);

    %compute union and intersection of x1 area and x2 area
    x2_area = x21_norm * x22_norm;
    inter = min([x11_norm,x21_norm])* min([x12_norm,x22_norm]);
    union = x1_area + x2_area - inter;
    arearatio = inter / union;
    fprintf('area ratio: %.2f , with x2=(%.2f,%.2f) \n',arearatio,x21_norm,x22_norm);
    
end

