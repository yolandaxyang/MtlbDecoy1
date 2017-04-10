%%%%%%%%%%% TERNARY CHOICE TASK
%% Compute text positions
hShiftFromCenter = 400;
vShiftFromCenter = 250;
rectWidth = 300;
rectHeight = 200;
leftRect = [center - [hShiftFromCenter+(rectWidth/2) (rectHeight/2)], center - [hShiftFromCenter-(rectWidth/2) (-rectHeight/2)]];
rightRect = [center + [hShiftFromCenter+(rectWidth/2) (rectHeight/2)], center + [hShiftFromCenter-(rectWidth/2) (-rectHeight/2)]];
topRect = [ center - [(rectWidth/2) , vShiftFromCenter+(rectHeight/2)] , center + [(rectWidth/2) , -vShiftFromCenter+(rectHeight/2)] ];
centerRect = [center - [(rectWidth/2) (rectHeight/2)], center + [(rectWidth/2) (rectHeight/2)]];

Screen('TextSize', mainwin, 25);
[nx, ny, bbox] = DrawFormattedText(mainwin,'Loading', 'center', 'center', 0, [], [], [], [1.5], [],centerRect);
Screen('Flip',mainwin);


%%
t_choiceset = ones(n_t,6) * NaN;
t_choice = 1:n_t * NaN;


%%

Screen('FillRect', mainwin ,bgcolor);
Screen('TextSize', mainwin, 18);
Screen('DrawText',mainwin,['Press any key to start.'] ,center(1)-350,center(2)-70,textcolor);
Screen('Flip',mainwin );

KbStrokeWait;

for t=1:n_t ;
    
    
    %draw an indifference set:
    [x1,x2] = getIndifSet(theta);
    x1 = x1';
    x2 = x2';
    %decoy on x1
    decoy = x1 - DecoyDistance;
    x = [x1,x2,decoy];
    
    %draw order
    order = randperm(3);
    t_choiceset(t,1:6)=round([x(1:2,order(1))',x(1:2,order(2))',x(1:2,order(3))'],2);
    
    %show alternatives
    Screen('TextSize', mainwin, 20);
    textLeft = [Attribute1Name  num2str(x(1,order(1)),'%.2f') '\n' Attribute2Name num2str(x(2,order(1)),'%.2f') '\nPress Left'];
    textTop = [Attribute1Name  num2str(x(1,order(2)),'%.2f') '\n' Attribute2Name num2str(x(2,order(2)),'%.2f') '\nPress Top'];
    textRight = [Attribute1Name  num2str(x(1,order(3)),'%.2f') '\n' Attribute2Name num2str(x(2,order(3)),'%.2f') '\nPress Right'];
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
    
    Screen('TextSize', mainwin, 25);
    [nx, ny, bbox] = DrawFormattedText(mainwin,'Loading', 'center', 'center', 0, [], [], [], [1.5], [],centerRect);
    Screen('Flip',mainwin);
    
    
end

    Screen('TextSize', mainwin, 18);
    Screen('DrawText',mainwin,'Thank you!',center(1),center(2),textcolor)
    Screen('Flip',mainwin);
    
KbStrokeWait;
sca;


save(['data' filesep 'Ternary-' num2str(subid) '-' datestr(datetime('now'),'yyyy-mm-dd-HH.MM.SS') '.mat'],'t_choiceset','t_choice','t_time');