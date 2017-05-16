clear all;
if(exist('data')==0)
   mkdir('data') 
end

%%start parallel pool
poolobj = gcp;

%%Experiment Parameters
global Attribute1Bounds Attribute2Bounds AttributeSpan
Debug = 1;
Attribute1Name = 'Winning probability (%): ';
Attribute2Name = 'Prize value ($): ';
Attribute1Bounds = [30 , 70];
Attribute2Bounds = [5 , 19.5];
AttributeSpan = [Attribute1Bounds(2)-Attribute1Bounds(1),Attribute2Bounds(2)-Attribute2Bounds(1)];
DecoyDistance = [2;2]; %Decoy will be xi - Decoydistance;

Model = 'EU'; %Use expected Utility with CRRA. Otherwise use 'CES' for CES with rescaling.

%%Base functions
run('NormalizeVars.m');

%% Subject info
%Prompt to enter subject's details, which will later be used in the save
%file.

prompt = {'Subject''s number:', 'age', 'gender'};
defaults = {'0', '0', 'F'};
answer = inputdlg(prompt, 'ChoiceRT', 2, defaults);
[subid, subage, gender] = deal(answer{:}); % all inputs are strings

%create data folder if doesnt exist
if ~exist('data', 'dir')
  mkdir('data');
end

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

%Binary Task
n = 5;
run('Multiattribute_Binary_Task.m');

%Ternary Task
n_t= 3;
run('Multiattribute_Ternary_Task.m');
sca;

%Double Decoy Task
run('Multiattribute_DoubleDecoy_Task.m');
sca;

%Stop Parallel Pool
delete(poolobj);

blott= ceil(1 + (length(b_probchosen))*rand(1));
tlott = ceil(1+(n_t - 1)*rand(1));
ddlott = ceil(1 + (n_t - 1)*rand(1)); 

b_gamble = [b_probchosen(blott), b_payoff(blott)];
t_gamble = [t_probchosen(tlott), t_payoff(tlott)];
dd_gamble = [dd_probchosen(ddlott), dd_payoff(ddlott)];

lott_gen = randi(3);

if lott_gen == 1
    play = b_gamble
elseif lott_gen == 2
    play = t_gamble
elseif lott_gen == 3
    play = dd_gamble
end
