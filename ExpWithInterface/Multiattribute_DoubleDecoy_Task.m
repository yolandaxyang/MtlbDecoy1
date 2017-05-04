%% Run Experiments
rand('state', sum(100*clock));
Screen('Preference', 'SkipSyncTests', 1);

KbName('UnifyKeyNames');
LeftKey=KbName('LeftArrow'); UpKey=KbName('UpArrow'); RightKey = KbName('RightArrow'); DownKey = KbName('DownArrow');
spaceKey = KbName('space'); escKey = KbName('ESCAPE');
% corrkey = [37,38,39]; % left up and right arrow, I dont actually know if this bit of code is necessary.
gray = [127 127 127 ]; white = [ 255 255 255]; black = [ 0 0 0];
bgcolor = white; textcolor = black;

%   Screen parameters
screens = Screen('Screens');
screenNumber = max(screens);
[mainwin, screenrect] =  Screen(screenNumber, 'OpenWindow');
Screen('FillRect', mainwin, bgcolor);
center = [screenrect(3)/2 screenrect(4)/2];

%%%%%%%%%%% DOUBLE DECOY TASK

%% Compute text positions
hShiftFromCenter = 400;
vShiftFromCenter = 250;
rectWidth = 500;
rectHeight = 200;
leftRect = [center - [hShiftFromCenter+(rectWidth/2) (rectHeight/2)], center - [hShiftFromCenter-(rectWidth/2) (-rectHeight/2)]];
rightRect = [center + [hShiftFromCenter+(rectWidth/2) (rectHeight/2)], center + [hShiftFromCenter-(rectWidth/2) (-rectHeight/2)]];
topRect = [ center - [(rectWidth/2) , vShiftFromCenter+(rectHeight/2)] , center + [(rectWidth/2) , -vShiftFromCenter+(rectHeight/2)] ];
centerRect = [center - [(rectWidth/2) (rectHeight/2)], center + [(rectWidth/2) (rectHeight/2)]];
botRect = [ center + [(rectWidth/2) , vShiftFromCenter+(rectHeight/2)] , center - [(rectWidth/2) , -vShiftFromCenter+(rectHeight/2)] ];

Screen('TextSize', mainwin, 25);
[nx, ny, bbox] = DrawFormattedText(mainwin,'Loading', 'center', 'center', 0, [], [], [], [1.5], [],centerRect);
Screen('Flip',mainwin);


%%

%these are now the indifference pairs used in ternary task listed in vector form

x_1 = [x_11;x_12];
x_2 = [x_21;x_22];
decoy = [decoy_1; decoy_2];

%to scramble into a random new order  (_1s) just refers to x_1 scrambled
ix = randperm(n_t); 

x_1s = x_1(:,ix);
x_2s = x_2(:,ix);
decoy_s = decoy(:,ix);



% to generate a second decoy halfway (rounded up) between decoy_s and x1_s
doubledecoy_s = ((x_1s - decoy_s)/2 + decoy_s);

dd_choiceset = zeros(n_t,8);

for t = 1:n_t
   
    x_1 = x_1s(:,t);
    x_2 = x_2s(:,t);
    decoy = decoy_s(:,t);
    ddecoy = doubledecoy_s(:,t);

    x = [x_1, x_2, decoy, ddecoy];
   
    %draw order
    order = randperm(4); 
    dd_choiceset(t,1:8) = ([x(:,order(1)); x(:,order(2)); x(:,order(3)); x(:,order(4))]);
   
end

    %show alternatives
    Screen('TextSize', mainwin, 20);
    textLeft = [Attribute1Name  num2str(x(1,order(1)),'%.2f') '\n' Attribute2Name num2str(x(2,order(1)),'%.2f') '\nPress Left'];
    textTop = [Attribute1Name  num2str(x(1,order(2)),'%.2f') '\n' Attribute2Name num2str(x(2,order(2)),'%.2f') '\nPress Top'];
    textRight = [Attribute1Name  num2str(x(1,order(3)),'%.2f') '\n' Attribute2Name num2str(x(2,order(3)),'%.2f') '\nPress Right'];
    textDown = [Attribute1Name  num2str(x(1,order(4)),'%.2f') '\n' Attribute2Name num2str(x(2,order(4)),'%.2f') '\nPress Down'];
    
    [nx, ny, bbox] = DrawFormattedText(mainwin,textLeft, 'center', 'center', 0, [], [], [], [1.5], [],leftRect);
    [nx, ny, bbox] = DrawFormattedText(mainwin,textTop, 'center', 'center', 0, [], [], [], [1.5], [],topRect);
    [nx, ny, bbox] = DrawFormattedText(mainwin,textRight, 'center', 'center', 0, [], [], [], [1.5], [],rightRect);
    [nx, ny, bbox] = DrawFormattedText(mainwin,textDown, 'center', 'center', 0, [], [], [], [1.5], [],botRect);
    
    
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
            dd_choice(t) = 1;
            respToBeMade = false;
        elseif keyCode(UpKey)
            dd_choice(t) = 2;
            respToBeMade = false;
        elseif keyCode(RightKey)
            dd_choice(t)= 3;
            respToBeMade = false;
        elseif keyCode(DownKey)
            dd_choice(t)= 4;
            respToBeMade = false;
        elseif keyCode(escKey)
            sca;
            error('leaving experiment before completion.')
        end
        
        
    end
    dd_time(t)=toc;
    

    
    WaitSecs(0.5);
    
    Screen('TextSize', mainwin, 25);
    [nx, ny, bbox] = DrawFormattedText(mainwin,'Loading', 'center', 'center', 0, [], [], [], [1.5], [],centerRect);
    Screen('Flip',mainwin);
    
    WaitSecs(0.5);
    
end

    dd_choiceset = xg'; 

    Screen('TextSize', mainwin, 18);
    Screen('DrawText',mainwin,'Thank you!',center(1),center(2),textcolor)
    Screen('Flip',mainwin);
    
KbStrokeWait;
sca;

save(['data' filesep 'Ternary-' num2str(subid) '-' datestr(datetime('now'),'yyyy-mm-dd-HH.MM.SS') '.mat'],'dd_choiceset','dd_choice','dd_time', 'ix',);