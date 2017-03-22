function [ x1out,x2out ] = getIndifSet( theta )
%GETINDIFSET Summary of this function goes here
%   Detailed explanation goes here

    x2 = [20;20];
    while max(x2 > [10;10])
        %pick x1 randomly on [2,5]x[5,9]
        x1 = [2;5] + rand(2,1) .* [3;4];
        x21  = 5;
        
        %solve first using 128 particles
        options = optimoptions(@fmincon,'Display','off','Algorithm','interior-point','OptimalityTolerance',0.01,'MaxFunctionEvaluations',50);
        objective = @(x21) (indifAreaRatio(x1(1),x1(2),x21,theta(1:128,1:end))-0.5)^2;
        [x21,fval,exitflag,output] = fmincon(objective,x21,[],[],[],[],0,10,[],options);

        %solve with full particles set
        options = optimoptions(@fmincon,'Display','off','Algorithm','sqp','OptimalityTolerance',0.01,'MaxFunctionEvaluations',20);
        objective = @(x21) (indifAreaRatio(x1(1),x1(2),x21,theta)-0.5)^2;
        [x21,fval,exitflag,output] = fmincon(objective,x21,[],[],[],[],0,10,[],options);
        
        [arearatio,x22] = indifAreaRatio(x1(1),x1(2),x21,theta);
        x2 = [x21;x22];
    end

    [proba,sd] = ExpectedChoiceProba([x1(1),x1(2)],[x21,x22],theta);

    if rand()>0.5
        x1out = x1;
        x2out = [x21;x22];
    else
        x2out = x1;
        x1out = [x21;x22];
    end
        
end

