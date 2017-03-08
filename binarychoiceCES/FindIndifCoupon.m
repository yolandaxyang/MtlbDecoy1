function [ x1 , x2 , sd ] = FindIndifCoupon(x11, x21, particles )
%FINDINDIFCOUPON

objective = @(prices) (ExpectedChoiceProba([x11,prices(1)],[x21,prices(2)],particles)-0.5)^2;
prices = [10,10];
options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton');
[prices,fval,exitflag,output] = fminunc(objective,prices,options);

[proba,sd] = ExpectedChoiceProba([x11,prices(1)],[x21,prices(2)],particles);

x1 = [x11,prices(1)];
x2 = [x21,prices(2)];
end

