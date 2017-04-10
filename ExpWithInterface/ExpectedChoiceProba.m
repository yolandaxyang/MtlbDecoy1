function [ proba , sd ] = ExpectedChoiceProba( x1,x2,theta )
%EXPECTEDCHOICEPROBA Expected choice probability from normalized x
NumP = size(theta,1);

LogitNum = @(x,beta) min(max([exp(  (x.^beta(3) * beta(1:2)')^(1/beta(3)) ),0.0000000000000001]),1e+99);
ProbaChoice1 = @(x1,x2,beta) LogitNum(x1,beta)/ (LogitNum(x1,beta)+LogitNum(x2,beta));

proba = 0;
sd = 0;
for i=1:NumP
    proba = proba + ProbaChoice1(x1,x2,theta(i,:));
    sd = sd + ProbaChoice1(x1,x2,theta(i,:))^2;
end
proba = proba / NumP;
sd = sqrt(sd/NumP - proba^2);

end

