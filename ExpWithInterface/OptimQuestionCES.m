function [ x1, x2 ] = OptimQuestionCES( particles , Model )
%Returns optimal question using CES utility. The CES utility uses 
%normalized x11 and x2 values. The function returns the denormalized 
%x1 and x2 values.
    %Define starting normalized points for maximization
    run('NormalizeVars.m');
    if strcmp(Model,'EU')
        x_norm = [UtoX([0.6,0.4]);UtoX([0.4,0.6])];
        objective = @(x) -evalObjectiveFunctionEU(particles,x);
        LowerBounds = [Attribute1Bounds(1)*[1;1];Attribute2Bounds(1)*[1;1]];
        UpperBounds = [Attribute1Bounds(2)*[1;1];Attribute2Bounds(2)*[1;1]];
    else
        x_norm = [NormalizeU([0.6,0.4]);NormalizeU([0.4,0.6])]; %line 1 = x1_norm, line 2 = x2_norm
        objective = @(x_norm) -evalObjectiveFunction(particles,x_norm);
        %find normalized bounds
        bounds = NormalizeU([0 1]);
        LowerBounds = zeros(4,1) + bounds(1);
        UpperBounds = zeros(4,1) + bounds(2);
    end
    
    %Test if parallel activated
    pool = gcp;
    if pool.NumWorkers > 1
        options = optimoptions(@fmincon,'UseParallel',true);%,'Display','off');
    else
        options = optimoptions(@fmincon,'Display','off');
    end
    A = [1 -1 0 0; 0 0 -1 1];
    b = [0 0];
    [x_norm,fval,exitflag,output] = fmincon(objective,x_norm,A,b,[],[],LowerBounds,UpperBounds,[],options);
    x_norm = x_norm(randperm(2),:); %randomize position 1 and 2
    
    if strcmp(Model,'EU')
        x1 = x_norm(1,:);
        x2 = x_norm(2,:);
    else
        x1 = DenormalizeX(x_norm(1,:));
        x2 = DenormalizeX(x_norm(2,:));
    end
end

