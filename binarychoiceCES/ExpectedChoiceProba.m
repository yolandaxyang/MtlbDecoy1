function [ proba , sd ] = ExpectedChoiceProba( x1,x2,particles )
%EXPECTEDCHOICEPROBA Summary of this function goes here
NumP = size(particles,1);
LogitNum = @(x,b) exp(  (x.^b(3) * b(1:2)')^(1/b(3)) );
ProbaChoice1 = @(x1,x2,beta) LogitNum(x1,beta)/ (LogitNum(x1,beta)+LogitNum(x2,beta));

proba = 0;
sd = 0;
for i=1:NumP
    proba = proba + ProbaChoice1(x1,x2,particles(i,:));
    sd = sd + ProbaChoice1(x1,x2,particles(i,:))^2;
end
proba = proba / NumP;
sd = sqrt(sd/NumP - proba^2);

end

