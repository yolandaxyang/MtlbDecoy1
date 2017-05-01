function [ proba ] = LogitProbaChoice1( u1,u2 )
%LOGITPROBACHOICE1 returns logit probability when the deterministic parts
%of the utilities are u1 and u2
    proba = 0.0;
    max_u = max([u1 u2]);
    u1 = u1 - max_u;
    u2 = u2 - max_u;
    if isinf(exp(u1)) || isinf(exp(u2))
        if u1 > u2
            proba = 1.0;
        end
    else
        proba = exp(u1) / (exp(u1)+exp(u2));
    end
end

