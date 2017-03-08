function [ x1, x2 ] = OptimQuestionCES( particles )
%Define starting points for maximization
x = [2.5,50;2.4,45]; %line 1 = x1, line 2 = x2



objective = @(x) -evalObjectiveFunction(particles,x);

options = optimset('Display','off');
[x,fval,exitflag,output] = fmincon(objective,x,[],[],[],[],[1;1;10;10],[5;5;50;50],[],options);

x1 = x(1,:);
x2 = x(2,:);
end

