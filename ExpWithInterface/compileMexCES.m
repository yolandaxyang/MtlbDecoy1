clear functions
if exist('updatePriorCES.mexw64.manifest', 'file')==2
  delete('updatePriorCES.mexw64.manifest');
end
if exist('updatePriorCES.mexw64', 'file')==2
  delete('updatePriorCES.mexw64');
end
mex -g -lgsl -lgslcblas -LD:\Dropbox\Dev\Matlab\RyanCliveGitHub\ExpWithInterface updatePriorCES.c