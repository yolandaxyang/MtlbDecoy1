
%%%%%%%%%%% TERNARY CHOICE TASK
%% Compute text positions
hShiftFromCenter = 400;
vShiftFromCenter = 250;
rectWidth = 500;
rectHeight = 200;
leftRect = [center - [hShiftFromCenter+(rectWidth/2) (rectHeight/2)], center - [hShiftFromCenter-(rectWidth/2) (-rectHeight/2)]];
rightRect = [center + [hShiftFromCenter+(rectWidth/2) (rectHeight/2)], center + [hShiftFromCenter-(rectWidth/2) (-rectHeight/2)]];
topRect = [ center - [(rectWidth/2) , vShiftFromCenter+(rectHeight/2)] , center + [(rectWidth/2) , -vShiftFromCenter+(rectHeight/2)] ];
centerRect = [center - [(rectWidth/2) (rectHeight/2)], center + [(rectWidth/2) (rectHeight/2)]];

Screen('TextSize', mainwin, 25);
[nx, ny, bbox] = DrawFormattedText(mainwin,'Loading', 'center', 'center', 0, [], [], [], [1.5], [],centerRect);
Screen('Flip',mainwin);


%%
t_choiceset = zeros(n_t,6);


%%


for t=1:n_t ;
    
    
    %draw an indifference set:
    [x1,x2] = getIndifSet(theta,Model);
    x1 = ceil(x1');
    x2 = ceil(x2');
    %decoy on x1
    d_min = 0.8;
    d_max = 0.9;
    decoydist = (d_max - d_min).*rand(1) + d_min;
    decoy = ceil((decoydist*x1));
    
    x = [x1, x2, decoy];
   
    %keep choices stored to be used in double-decoy task
    x_11(t) = x1(1);
    x_12(t) = x1(2);
    x_21(t) = x2(1);
    x_22(t) = x2(2);
    decoy_1(t)= decoy(1);
    decoy_2(t)= decoy(2);
    
    x_1 = [x_11', x_12'];
    x_2 = [x_21', x_22'];
    decoy = [decoy_1', decoy_2'];
    

    %draw order
    order = randperm(3);
    t_choiceset(t,1:6)=round([x(1:2,order(1))',x(1:2,order(2))',x(1:2,order(3))'],2);
    
    %show alternatives
    Screen('TextSize', mainwin, 20);
    textLeft = [Attribute1Name  num2str(x(1,order(1)),'%.0f') '\n' Attribute2Name num2str(x(2,order(1)),'%.0f') '\nPress Left'];
    textTop = [Attribute1Name  num2str(x(1,order(2)),'%.0f') '\n' Attribute2Name num2str(x(2,order(2)),'%.0f') '\nPress Top'];
    textRight = [Attribute1Name  num2str(x(1,order(3)),'%.0f') '\n' Attribute2Name num2str(x(2,order(3)),'%.0f') '\nPress Right'];
    [nx, ny, bbox] = DrawFormattedText(mainwin,textLeft, 'center', 'center', 0, [], [], [], [1.5], [],leftRect);
    [nx, ny, bbox] = DrawFormattedText(mainwin,textTop, 'center', 'center', 0, [], [], [], [1.5], [],topRect);
    [nx, ny, bbox] = DrawFormattedText(mainwin,textRight, 'center', 'center', 0, [], [], [], [1.5], [],rightRect);

    
    if Debug==1
        Screen('FrameRect', mainwin ,[0 0 255],[leftRect;rightRect;topRect]',1);
        Screen('FillOval', mainwin ,[0 0 255],[center-[2 2] center+[2 2]]);
        Screen('DrawText',mainwin,'Debug is on',10,10,textcolor);
    end
    
    Screen('Flip',mainwin);
    
    respToBeMade = true;
    tic
    
    
    while respToBeMade
        
        [keyIsDown,secs, keyCode] = KbCheck;
        
        
        if  keyCode(LeftKey)
            t_choice(t) = 1;
            respToBeMade = false;
        elseif keyCode(UpKey)
            t_choice(t) = 2;
            respToBeMade = false;
        elseif keyCode(RightKey)
            t_choice(t)= 3;
            respToBeMade = false;
        elseif keyCode(escKey)
            sca;
            error('leaving experiment before completion.')
        end
        
        
    end
    
    t_time(t)=toc;
    t_target(t) = find(order==1);
    t_comp(t) = find(order==2);
    t_probchosen(t) = x(1,order(t_choice(t)));
    t_payoff(t) = x(2, order(t_choice(t)));
    
    Screen('TextSize', mainwin, 25);
    [nx, ny, bbox] = DrawFormattedText(mainwin,'Loading', 'center', 'center', 0, [], [], [], [1.5], [],centerRect);
    Screen('Flip',mainwin);
    
    
    
end

    Screen('TextSize', mainwin, 18);
    Screen('DrawText',mainwin,'Thank you!',center(1),center(2),textcolor)
    Screen('Flip',mainwin);
    
KbStrokeWait;
sca;


save(['C:\Users\Yolanda Yang\Desktop\data' filesep 'Ternary-' num2str(subid) '-' datestr(datetime('now'),'yyyy-mm-dd-HH.MM.SS') '.mat'],'t_choiceset','t_choice','t_time','t_target','t_comp', 't_probchosen','t_payoff');