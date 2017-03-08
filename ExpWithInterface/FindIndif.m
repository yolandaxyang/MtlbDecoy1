function [ x1 , x2 , sd ] = FindIndifCoupon(x11, x21, particles )
%FINDINDIFCOUPON

objective = @(attr2) (ExpectedChoiceProba([x11,attr2(1)],[x21,attr2(2)],particles)-0.5)^2;
attr2 = [5,5];
options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton');
[attr2,fval,exitflag,output] = fminunc(objective,attr2,options);

[proba,sd] = ExpectedChoiceProba([x11,attr2(1)],[x21,attr2(2)],particles);

x1 = [x11,attr2(1)];
x2 = [x21,attr2(2)];
end

