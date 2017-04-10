function [ x1 , x2 , sd ] = FindIndif(u11, u21, particles )
%FINDINDIF find denormalized indiference choice set from 1st attributes on [0,1]
%attributes
    run('NormalizeVars.m');
    tmp = NormalizeU([u11 0]);
    x_norm11 = tmp(1);
    tmp = NormalizeU([u21 0]);
    x_norm21 = tmp(1);
    objective = @(attr2) (ExpectedChoiceProba([x_norm11,attr2(1)],[x_norm21,attr2(2)],particles)-0.5)^2;
    attr2 = NormalizeU([0.5,0.5]);
    options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton');
    [attr2,fval,exitflag,output] = fminunc(objective,attr2,options);

    [proba,sd] = ExpectedChoiceProba([x_norm11,attr2(1)],[x_norm21,attr2(2)],particles);

    x1 = DenormalizeX([x_norm11,attr2(1)]);
    x2 = DenormalizeX([x_norm21,attr2(2)]);
end

