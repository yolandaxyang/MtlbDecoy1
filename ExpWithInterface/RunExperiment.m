clear all;
if(~isdeployed)
  cd(fileparts(which(mfilename)));
end

%%Experiment Parameters
Debug = 1;
Attribute1Name = 'Sound Quality : ';
Attribute2Name = 'Loudness : ';

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
ErrorDelay=1; interTrialInterval = .5; n = 20;
run('Multiattribute_Binary_Task.m');
%Ternary Task
n_t= 10;
run('Multiattribute_Ternary_Task.m');
