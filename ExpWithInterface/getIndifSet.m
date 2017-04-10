function [ x1out,x2out ] = getIndifSet( theta )
%GETINDIFSET Finds 2 options x1 and x2 with expected indiference
%(denormalized)

    run('NormalizeVars.m');
    x1_norm = NormalizeU([0.4 0.4]);
    x2_norm = NormalizeU([0.5 0.5]);
    Lbounds = NormalizeU([0 0]);
    Ubounds = NormalizeU([1 1]);
    while prod(x1_norm-x2_norm) > 0
        %pick u1 randomly on [0,0.5]x[0.5,1] or [0.5,1]x[0,0.5];
        u1 = rand(1,2) .* 0.5 + [0 0.5];
        u1 = u1(randperm(2));
        x1_norm =  NormalizeU(u1);
        x_norm21  = NormalizeU([1 1] - u1);
        x_norm21 = x_norm21(1);
        
        %solve first using 128 particles
        options = optimoptions(@fmincon,'Display','off','Algorithm','interior-point','OptimalityTolerance',0.01,'MaxFunctionEvaluations',50);
        objective = @(x21) (indifAreaRatio(x1_norm(1),x1_norm(2),x21,theta(1:128,1:end))-0.4)^2;
        [x_norm21,fval,exitflag,output] = fmincon(objective,x_norm21,[],[],[],[],Lbounds(1),Ubounds(1),[],options);

        %solve with full particles set
        options = optimoptions(@fmincon,'Display','off','Algorithm','sqp','OptimalityTolerance',0.01,'MaxFunctionEvaluations',20);
        objective = @(x21) (indifAreaRatio(x1_norm(1),x1_norm(2),x21,theta)-0.4)^2;
        [x_norm21,fval,exitflag,output] = fmincon(objective,x_norm21,[],[],[],[],Lbounds(1),Ubounds(1),[],options);
        
        [arearatio,x22] = indifAreaRatio(x1_norm(1),x1_norm(2),x_norm21,theta);
        x2_norm = [x_norm21,x22];
    end

    [proba,sd] = ExpectedChoiceProba(x1_norm,x2_norm,theta);

    if rand()>0.5
        x1out = DenormalizeX(x1_norm);
        x2out = DenormalizeX(x2_norm);
    else
        x2out = DenormalizeX(x1_norm);
        x1out = DenormalizeX(x2_norm);
    end
        
end

