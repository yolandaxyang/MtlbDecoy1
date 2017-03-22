if(~isdeployed)
  cd(fileparts(which(mfilename)));
end

mcc -mv RunExperiment.m -a Multiattribute_Binary_Task.m -a Multiattribute_Ternary_Task.m