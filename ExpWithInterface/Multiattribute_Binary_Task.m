%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experimental parameters
clear all;
rand('state', sum(100*clock));
Screen('Preference', 'SkipSyncTests', 1);

ErrorDelay=1; interTrialInterval = .5; n = 20;  %NB: n here stands for total number of trials and t is used for each individual trial. So there are 1:n trials t.
Debug = 1;

KbName('UnifyKeyNames');
LeftKey=KbName('LeftArrow'); UpKey=KbName('UpArrow'); RightKey = KbName('RightArrow');
spaceKey = KbName('space'); escKey = KbName('ESCAPE');
% corrkey = [37,38,39]; % left up and right arrow, I dont actually know if this bit of code is necessary.
gray = [127 127 127 ]; white = [ 255 255 255]; black = [ 0 0 0];
bgcolor = white; textcolor = black;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Screen parameters
[mainwin, screenrect] =  Screen(0, 'OpenWindow');
Screen('FillRect', mainwin, bgcolor);
%screenrect = Screen('Rect', 1);
center = [screenrect(3)/2 screenrect(4)/2];
Screen(mainwin, 'Flip');
screens = Screen('Screens');
screenNumber = max(screens);

%Listz 
Titles = {'1', '2', '3', '4', '5', '6', '7', '8', '9'};
Ratings = {'1', '1.5', '2', '2.5', '3', '3.5', '4', '4.5', '5'};
money = [1 2 3 4 5 6 7 8 9 10];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Draw 1024 particles from prior
theta = chi2rnd(4,1024,3); %chi2(1) distributed
avg_theta = mean(theta);
avg_hist = avg_theta;
sd_theta = std(theta);
sd_hist = sd_theta;
[xind1,xind2,indifsd] = FindIndif(2,3,theta);


%% Begin experiment


for t = 1:n;
    books = numel(Titles);
    
    idx_1 = randi(books);
    idx_2 = randi(books);
    
    if idx_2 == idx_1;
        idx_2 = randi(books);
    end
    
    idx = [idx_1, idx_2];
    ix = randperm(2);
    idx_s = idx(ix);
    
    obj1_attr2 = money(randi([1,10]));
    obj2_attr2 = money(randi([1,10]));
    
    if obj1_attr2 == obj2_attr2;
        obj2_attr2 = money(randi([2,10]));
    end
    
    
    %optimal design
    [x1,x2] = OptimQuestionCES(theta);
    x1 = round(x1,1);
    x2 = round(x2,1);
    
    str_obj1_attr1 = num2str(x1(1));
    str_obj2_attr1 = num2str(x2(1));
    str_obj1_attr2 = num2str(x1(2));
    str_obj2_attr2 = num2str(x2(2));

    
    Screen('TextSize', mainwin, 25);
    Screen('DrawText',mainwin,'Press Left',center(1)-400,center(2)-100,textcolor);
    Screen('DrawText',mainwin,['Power : ' str_obj1_attr1],center(1)-400,center(2)-250,textcolor);
    Screen('DrawText',mainwin,['Quality : ' str_obj1_attr2],center(1)-400,center(2)-200,textcolor);
    
    Screen('TextSize', mainwin, 25);
    Screen('DrawText',mainwin,'Press Right',center(1)+400,center(2)-100,textcolor);
    Screen('DrawText',mainwin,['Power : ' str_obj2_attr1],center(1)+400,center(2)-250,textcolor);
    Screen('DrawText',mainwin,['Quality : ' str_obj2_attr2],center(1)+400,center(2)-200,textcolor);
    
    if Debug==1
        Screen('TextSize', mainwin, 25);
        Screen('DrawText',mainwin,'Debug is on',10,10,textcolor);
        Screen('DrawText',mainwin,['Posterior mean : ' ,num2str(avg_theta(1)),' / ',num2str(avg_theta(2)),' / ',num2str(avg_theta(3)) ],10,40,textcolor);
        Screen('DrawText',mainwin,['Posterior sd : ' ,num2str(sd_theta(1)),' / ',num2str(sd_theta(2)),' / ',num2str(sd_theta(3)) ],10,70,textcolor);
        Screen('DrawText',mainwin,sprintf('Expected indif for: for [%.2f,%.2f] vs [%.2f,%2f]\n', xind1(1),xind1(2),xind2(1),xind2(2)),10,100,textcolor);
        Screen('DrawText',mainwin,sprintf('Sd of predicted choice proba: %.4f \n', indifsd),10,130,textcolor);
    end
    
    Screen('Flip',mainwin);
    
   
    
    respToBeMade = true;
    tic
    while respToBeMade
        
        Choice_1_Attr1(t) = x1(1);
        Choice_2_Attr1(t) = x2(1);
        Choice_1_Attr2(t) = x1(2);
        Choice_2_Attr2(t) = x2(2);
        
        keyIsDown=0;
        [keyIsDown,secs, keyCode] = KbCheck;
        if  keyCode(LeftKey)
            response(t) = 0;
            chosen(:,t) = [Choice_1_Attr1(t);Choice_1_Attr2(t); 'L'];
            notchosen(:,t)=[Choice_2_Attr1(t);Choice_2_Attr2(t); 'R'];
            respToBeMade = false;
        elseif keyCode(RightKey)
            response(t)= 1;
            chosen(:,t) = [Choice_2_Attr1(t);Choice_2_Attr2(t); 'R'];
            notchosen(:,t)=[Choice_1_Attr1(t);Choice_1_Attr2(t); 'L'];
            respToBeMade = false;
        elseif keyCode(KbName('q'))
            sca;
            error('exiting experiment before completion.')
        end
        
        time(t)=toc;
        WaitSecs(0.1);
        
    end
    
    Screen('TextSize', mainwin, 25);
    Screen('DrawText',mainwin,'Loading',center(1),center(2),textcolor);
    Screen('Flip',mainwin);
    
    %Compute posterior
    choice_set = [x1,x2];
    theta = UpdatePriorDistCES( response(t), choice_set , theta );
    avg_theta = mean(theta);
    avg_hist = [avg_hist;avg_theta];
    sd_theta = std(theta);
    sd_hist = [sd_hist;sd_theta];
    fprintf('AVG(theta) %.2f %.2f %.2f\n', avg_theta(1), avg_theta(2), avg_theta(3));
    fprintf('SD(theta) %.2f %.2f %.2f\n', sd_theta(1), sd_theta(2), sd_theta(3));
    
    %find some indiference value for attr2 given the attr1 are 2 and 3
    [xind1,xind2,indifsd] = FindIndif(3,6,theta);
    fprintf('SD(probachoice) for [%.2f,%.2f] vs [%.2f,%2f] is %4f \n', xind1(1),xind1(2),xind2(1),xind2(2), indifsd);
    
end

    Screen('TextSize', mainwin, 25);
    Screen('DrawText',mainwin,'Thank you',center(1),center(2),textcolor);
    Screen('Flip',mainwin);
    

KbStrokeWait;
sca;
save BinaryTask.mat 

%% Compute indif curve for x= [3 6]
x_indif = [3 6];

logLogitNum = @(x,beta)(x.^beta(3) * beta(1:2)')^(1/beta(3));
logProbaChoice1 = @(x1,x2,beta) logLogitNum(x1,beta) - log( exp(logLogitNum(x1,beta))+exp(logLogitNum(x2,beta)) );

for j=1:20
    for x2_attr1=1:0.2:9
        objective = @(x22) (logProbaChoice1( x_indif(1,:),[x2_attr1 x22],theta(j,:))-log(0.5))^2;
        if isinf(objective(9)) == 0
            options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton');
            [x2_attr2,fval,exitflag,output] = fminunc(objective,9,options);
            x_indif = [x_indif;x2_attr1 x2_attr2];
        else
            fprintf('Particle %d is inf at [%.1f,9]\n',j,x2_attr1);
        end
    end
end
scatter(x_indif(:,1),x_indif(:,2),'x')
