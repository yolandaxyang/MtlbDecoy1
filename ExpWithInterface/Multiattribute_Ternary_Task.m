%%%%%%%%%%% TERNARY CHOICE TASK
%%
Ratings = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18' ,'19', '20'};
money = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20];


%%

Screen('FillRect', mainwin ,bgcolor);
Screen('TextSize', mainwin, 18);
Screen('DrawText',mainwin,['Press any key to start.'] ,center(1)-350,center(2)-70,textcolor);
Screen('Flip',mainwin );

KbStrokeWait;

for t=1:n_t ;
    
    
    tcash1 = money(randi([1,15]) );
    tcash2 = 1;
    
    tidx_1 = randi([7,19]);
    tidx_2 = randi([1,15]);
    
    tratings1 = Ratings{tidx_1};
    tratings1_s = num2str(tratings1);
    tratings1_n = str2num(tratings1_s);
    
    tratings2 = Ratings{tidx_2};
    tratings2_s = num2str(tratings2);
    tratings2_n = str2num(tratings2_s);
    
    V1 = b(1) + b(2)*tratings1_n + b(3)*tcash1;
    V2 = b(1) + b(2)*tratings2_n + b(3)*tcash2;
    
    P = exp(V1) /(exp(V1)+ exp(V2));
    
    while P > 0.5
        tcash2 = tcash2+1;
        V1 = b(1) + b(2)*tratings1_n + b(3)*tcash1;
        V2 = b(1) + b(2)*tratings2_n + b(3)*tcash2;
        P = exp(V1) /(exp(V1)+ exp(V2));
    end
    

    idx_3 = randi([1,2]);
    
    
    if idx_3 ==1;
        ttcash1 = tcash1;
        ttratings1 = tratings1_n;
        ttcash2 = tcash2;
        ttratings2 = tratings2_n;
    elseif idx_3 ==2;
        ttcash1 = tcash2;
        ttratings1 = tratings2_n;
        ttcash2 = tcash1;
        ttratings2 = tratings1_n;
    end
    
    ttcash1_s = num2str(ttcash1);
    ttratings1_s = num2str(ttratings1);
    ttcash2_s = num2str(ttcash2);
    ttratings2_s = num2str(ttratings2);
    
    %this is the first decoy. Note that this is a decoy on tcash1, not on
    %ttcash1. THIS IS IMPORTANT for starts work later.
    
    decoy = randi([1,2]);
    
    if decoy == 1
        d1cash1 = tcash1-1;
        d1cash1_s = num2str(d1cash1);
        d1ratings1 = tratings1_n-1;
        d1ratings1_s = num2str(d1ratings1);
        d1ratings1_n = d1ratings1;
    elseif decoy == 2;
        d1cash1 = randi([1,9]);
        d1cash1_s = num2str(d1cash1);
        d1ratings1 = Ratings{(tidx_1 - tidx_2)};
        d1ratings1_s = num2str(d1ratings1);
        d1ratings1_n = str2num(d1ratings1);
    end
    
    Screen('TextSize', mainwin, 18);
    Screen('DrawText',mainwin,'Sound Quality',center(3),center(2)-75,textcolor);
    Screen('DrawText',mainwin,ttratings1_s,center(3),center(2)-25,textcolor);
    Screen('DrawText',mainwin,'Loudness',center(3),center(2)+25,textcolor);
    Screen('DrawText',mainwin,ttcash1_s,center(3),center(2)+75,textcolor);
    
    Screen('TextSize', mainwin, 18);
    Screen('DrawText',mainwin,'Sound Quality',center(1),center(5)-75,textcolor);
    Screen('DrawText',mainwin,d1ratings1_s,center(1),center(5)-25,textcolor);
    Screen('DrawText',mainwin,'Loudness',center(1),center(5)+25,textcolor);
    Screen('DrawText',mainwin,d1cash1_s,center(1),center(5)+75,textcolor);
    
    Screen('TextSize', mainwin, 18);
    Screen('DrawText',mainwin,'Sound Quality',center(4),center(2)-75,textcolor);
    Screen('DrawText',mainwin,ttratings2_s,center(4),center(2)-25,textcolor);
    Screen('DrawText',mainwin,'Loudness',center(4),center(2)+25,textcolor)
    Screen('DrawText',mainwin,ttcash2_s,center(4),center(2)+75,textcolor);
    Screen('Flip',mainwin);
    
    respToBeMade = true;
    tic
    
    
    %trandomization(t) = 1 implies tcash1, tratings1 corresponds to response 1
    
    while respToBeMade
        
        trandomization(t) = idx_3; %this variable determines which tcash was presented on left
        tdecoy(t) = decoy;  %this variable determines whether d1cash1 is randomized or decoy
        t_cash1(t) = tcash1;
        tt_cash1(t) = ttcash1;
        t_cash2(t) = tcash2;
        tt_cash2(t) = ttcash2;
        t_ratings1(t) = tratings1_n;
        tt_ratings1(t) = ttratings1;
        t_ratings2(t) = tratings2_n;
        tt_ratings2(t) = ttratings2;
        t_d1cash1(t) = d1cash1;
        t_d1ratings1(t) = d1ratings1_n;
        P_(t) = P;
        
        [keyIsDown,secs, keyCode] = KbCheck;
        
        
        if  keyCode(LeftKey)
            tresponse(t) = 1;
            respToBeMade = false;
        elseif keyCode(UpKey)
            tresponse(t) = 0;
            respToBeMade = false;
        elseif keyCode(RightKey)
            tresponse(t)=-1;
            respToBeMade = false;
        elseif keyCode(escKey)
            sca;
            error('exiting experiment before completion.')
        end
        
        
    end
    t_time(t)=toc;
    WaitSecs(0.3);
    
    
end

    Screen('TextSize', mainwin, 18);
    Screen('DrawText',mainwin,'Thank you',center(1),center(2),textcolor)
    Screen('Flip',mainwin);
    
KbStrokeWait;
sca;

filename2 = ['DataPart-' num2str(subid)];
save(filename2);