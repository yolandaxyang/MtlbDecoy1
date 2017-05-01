function [ proba , sd ] = ExpectedChoiceProba( x1,x2,theta , Model )
%EXPECTEDCHOICEPROBA Expected choice probability from normalized x
    NumP = size(theta,1);

    if strcmp(Model,'EU')
        u = @(x,beta) ExpUtilityCRRA( x , beta );
    else
        u = @(x,beta) (x.^beta(3) * beta(1:2)')^(1/beta(3));
    end
    ProbaChoice1 = @(x1,x2,beta) LogitProbaChoice1( u(x1,beta) ,u(x2,beta));

    proba = 0;
    sd = 0;
    for i=1:NumP
        proba = proba + ProbaChoice1(x1,x2,theta(i,:));
        sd = sd + ProbaChoice1(x1,x2,theta(i,:))^2;
    end
    proba = proba / NumP;
    sd = sqrt(sd/NumP - proba^2);

end

