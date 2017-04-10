%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Textboxes sizes and position
hShiftFromCenter = 400;
rectWidth = 300;
rectHeight = 200;
leftRect = [center - [hShiftFromCenter+(rectWidth/2) (rectHeight/2)], center - [hShiftFromCenter-(rectWidth/2) (-rectHeight/2)]];
rightRect = [center + [hShiftFromCenter+(rectWidth/2) (rectHeight/2)], center + [hShiftFromCenter-(rectWidth/2) (-rectHeight/2)]];
centerRect = [center - [(rectWidth/2) (rectHeight/2)], center + [(rectWidth/2) (rectHeight/2)]];

Screen('TextSize', mainwin, 25);
[nx, ny, bbox] = DrawFormattedText(mainwin,'Loading', 'center', 'center', 0, [], [], [], [1.5], [],centerRect);
Screen('Flip',mainwin);


Chosen = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Draw 512 particles from prior
theta = chi2rnd(2,512,3); %chi2(2) distributed
avg_theta = mean(theta);
avg_hist = avg_theta;
sd_theta = std(theta);
sd_hist = sd_theta;
[xind1,xind2,indifsd] = FindIndif(0.6,0.4,theta);


%% Begin experiment

for t = 1:n;   
    %optimal design
    [x1,x2] = OptimQuestionCES(theta);
    x1 = round(x1,1);
    x2 = round(x2,1);
    
    str_obj1_attr1 = num2str(x1(1));
    str_obj2_attr1 = num2str(x2(1));
    str_obj1_attr2 = num2str(x1(2));
    str_obj2_attr2 = num2str(x2(2));
    
    

    
    Screen('TextSize', mainwin, 20);
    textLeft = [Attribute1Name  str_obj1_attr1 '\n' Attribute2Name  str_obj1_attr2 '\nPress Left'];
    textRight = [Attribute1Name  str_obj2_attr1 '\n' Attribute2Name  str_obj2_attr2 '\nPress Right'];
    [nx, ny, bbox] = DrawFormattedText(mainwin,textLeft, 'center', 'center', 0, [], [], [], [1.5], [],leftRect);
    [nx, ny, bbox] = DrawFormattedText(mainwin,textRight, 'center', 'center', 0, [], [], [], [1.5], [],rightRect);

    
    if Debug==1
        Screen('FrameRect', mainwin ,[0 0 255],[leftRect;rightRect]',1);
        Screen('FillOval', mainwin ,[0 0 255],[center-[2 2] center+[2 2]]);
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
            Chosen(t) = 1;
            respToBeMade = false;
        elseif keyCode(RightKey)
            response(t)= 1;
            Chosen(t) = 2;
            respToBeMade = false;
        elseif keyCode(escKey)
            sca;
            error('exiting experiment before completion.')
        end
        
        time(t)=toc;
        WaitSecs(0.1);
        
    end
    
    Screen('TextSize', mainwin, 25);
    [nx, ny, bbox] = DrawFormattedText(mainwin,'Loading', 'center', 'center', 0, [], [], [], [1.5], [],centerRect);
    Screen('Flip',mainwin);
    
    %Compute posterior
    choice_set = [x1,x2];
    x1_norm = NormalizeX(x1);
    x2_norm = NormalizeX(x2);
    theta = UpdatePriorDistCES( response(t), [x1_norm,x2_norm] , theta );
    avg_theta = mean(theta);
    avg_hist = [avg_hist;avg_theta];
    sd_theta = std(theta);
    sd_hist = [sd_hist;sd_theta];
    fprintf('AVG(theta) %.2f %.2f %.2f\n', avg_theta(1), avg_theta(2), avg_theta(3));
    fprintf('SD(theta) %.2f %.2f %.2f\n', sd_theta(1), sd_theta(2), sd_theta(3));
    
    %find some indiference value for attr2 given the normalized attr1 values are .6 and .4 
    [xind1,xind2,indifsd] = FindIndif(0.6,0.4,theta);
    fprintf('SD(probachoice) for [%.2f,%.2f] vs [%.2f,%2f] is %4f \n', xind1(1),xind1(2),xind2(1),xind2(2), indifsd);
    
end

    Screen('TextSize', mainwin, 25);
    Screen('DrawText',mainwin,'Loading',center(1),center(2),textcolor);
    Screen('Flip',mainwin);
    

save BinaryTask.mat 

%% Compute indif curve for u1 = [0.4 0.6]
u_indif = [0.4 0.6];
x_norm_indif = NormalizeU(u_indif);
tmp = NormalizeU([0 0.9]);
x_norm22_start = tmp(2);

logLogitNum = @(x,beta)(x.^beta(3) * beta(1:2)')^(1/beta(3));
logProbaChoice1 = @(x1,x2,beta) logLogitNum(x1,beta) - log( exp(logLogitNum(x1,beta))+exp(logLogitNum(x2,beta)) );

for j=1:20
    for u21=0.05:0.05:0.95
        tmp =  NormalizeU([u21 0.9]);
        x_norm21 = tmp(1);
        objective = @(x22) (logProbaChoice1( x_norm_indif(1,:),[x_norm21 x22],theta(j,:))-log(0.5))^2;
        if isinf(objective(x_norm22_start)) == 0
            options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton');
            [x_norm22,fval,exitflag,output] = fminunc(objective,x_norm22_start,options);
            x_norm_indif = [x_norm_indif;x_norm21 x_norm22];
        else
            fprintf('Particle %d is inf at [%.1f,9]\n',j,x_norm22);
        end
    end
end
scatter(x_norm_indif(:,1),x_norm_indif(:,2),'x')
save(['data' filesep 'Binary-' num2str(subid) '-' datestr(datetime('now'),'yyyy-mm-dd-HH.MM.SS') '.mat'],'Choice_*','Chosen','time');
save(['data' filesep 'Theta-' num2str(subid) '-' datestr(datetime('now'),'yyyy-mm-dd-HH.MM.SS') '.mat'],'theta');