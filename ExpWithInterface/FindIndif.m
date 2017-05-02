function [ x1 , x2 , sd ] = FindIndif(u11, u21, particles , Model )
%FINDINDIF find denormalized indiference choice set from 1st attributes on [0,1]
%attributes
    run('NormalizeVars.m');
    if strcmp(Model,'EU')
        tmp = UtoX([u11 0]);
        x_11 = tmp(1);
        tmp = UtoX([u21 0.5]);
        x_21 = tmp(1);
        objective = @(attr2) (ExpectedChoiceProba([x_11,attr2(1)],[x_21,attr2(2)],particles,Model)-0.5)^2;
        attr2 = [tmp(2) tmp(2)];
    else
        tmp = NormalizeU([u11 0]);
        x_norm11 = tmp(1);
        tmp = NormalizeU([u21 0]);
        x_norm21 = tmp(1);
        objective = @(attr2) (ExpectedChoiceProba([x_norm11,attr2(1)],[x_norm21,attr2(2)],particles,Model)-0.5)^2;
        attr2 = NormalizeU([0.5,0.5]);
    end
        
        options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton','UseParallel',true);
        [attr2,fval,exitflag,output] = fminunc(objective,attr2,options);
        
    if strcmp(Model,'EU')
        x1 = [x_11,attr2(1)];
        x2 = [x_21,attr2(2)];
        [proba,sd] = ExpectedChoiceProba([x_11,attr2(1)],[x_21,attr2(2)],particles,Model);
    else
        [proba,sd] = ExpectedChoiceProba([x_norm11,attr2(1)],[x_norm21,attr2(2)],particles,Model);
        x1 = DenormalizeX([x_norm11,attr2(1)]);
        x2 = DenormalizeX([x_norm21,attr2(2)]);
    end
end

