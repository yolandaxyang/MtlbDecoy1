function [ x1, x2 ] = OptimQuestionCES( particles )
%Returns optimal question using CES utility. The CES utility uses 
%normalized x11 and x2 values. The function returns the denormalized 
%x1 and x2 values.

    %Define starting normalized points for maximization
    run('NormalizeVars.m');
    x_norm = [NormalizeU([0.6,0.4]);NormalizeU([0.4,0.6])]; %line 1 = x1_norm, line 2 = x2_norm



    objective = @(x_norm) -evalObjectiveFunction(particles,x_norm);
    %find normalized bounds
    bounds = NormalizeU([0 1]);
    LowerBounds = zeros(4,1) + bounds(1);
    UpperBounds = zeros(4,1) + bounds(2);

    options = optimset('Display','off');
    [x_norm,fval,exitflag,output] = fmincon(objective,x_norm,[],[],[],[],LowerBounds,UpperBounds,[],options);

    x1 = DenormalizeX(x_norm(1,:));
    x2 = DenormalizeX(x_norm(2,:));
end

