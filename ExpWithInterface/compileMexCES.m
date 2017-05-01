%% CES
clear functions

if exist('updatePriorCES.mexw64.manifest', 'file')==2
  delete('updatePriorCES.mexw64.manifest');
end
if exist('updatePriorCES.mexw64', 'file')==2
  delete('updatePriorCES.mexw64');
end
mex -g -lgsl -lgslcblas -LD:\Dropbox\Dev\Matlab\RyanCliveGitHub\ExpWithInterface updatePriorCES.c

clear functions

%% EU
clear functions

if exist('updatePriorEU.mexw64.manifest', 'file')==2
  delete('updatePriorEU.mexw64.manifest');
end
if exist('updatePriorEU.mexw64', 'file')==2
  delete('updatePriorEU.mexw64');
end
mex -g -lgsl -lgslcblas -LD:\Dropbox\Dev\Matlab\RyanCliveGitHub\ExpWithInterface updatePriorEU.c

if exist('evalObjectiveFunctionEU.mexw64.manifest', 'file')==2
  delete('evalObjectiveFunctionEU.mexw64.manifest');
end
if exist('evalObjectiveFunctionEU.mexw64', 'file')==2
  delete('evalObjectiveFunctionEU.mexw64');
end
mex -g -lgsl -lgslcblas -LD:\Dropbox\Dev\Matlab\RyanCliveGitHub\ExpWithInterface evalObjectiveFunctionEU.c