function [ x1, x2 ] = OptimQuestionCES( particles )
%Define starting points for maximization
x = [5,5;5,5]; %line 1 = x1, line 2 = x2



objective = @(x) -evalObjectiveFunction(particles,x);

options = optimset('Display','off');
[x,fval,exitflag,output] = fmincon(objective,x,[],[],[],[],[1;1;1;1],[10;10;10;10],[],options);

x1 = x(1,:);
x2 = x(2,:);
end

