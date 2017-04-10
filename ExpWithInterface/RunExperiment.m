clear all;
if(~isdeployed)
  cd(fileparts(which(mfilename)));
end

if(exist('data')==0)
   mkdir('data') 
end

%%Experiment Parameters
global Attribute1Bounds Attribute2Bounds AttributeSpan
Debug = 1;
Attribute1Name = 'Winning probability (%): ';
Attribute2Name = 'Prize value ($): ';
Attribute1Bounds = [30 , 70];
Attribute2Bounds = [5 , 19.5];
AttributeSpan = [Attribute1Bounds(2)-Attribute1Bounds(1),Attribute2Bounds(2)-Attribute2Bounds(1)];
DecoyDistance = [2;2]; %Decoy will be xi - Decoydistance;

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
LeftKey=KbName('LeftArrow'); UpKey=KbName('UpArrow'); RightKey = KbName('RightArrow');
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
n = 20;
%run('Multiattribute_Binary_Task.m');

%Ternary Task
n_t= 10;
run('Multiattribute_Ternary_Task.m');
sca;
