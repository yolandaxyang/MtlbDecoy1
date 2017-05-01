function [ particles ] = UpdatePriorDist( obsChoice, obsX, particles , Model )
%UPDATEPRIORDISTCES update prior with observed choice and normalized x
%values
    if strcmp(Model,'EU')
        particles = updatePriorEU(obsChoice, obsX, particles);
    else
        particles = updatePriorCES(obsChoice, obsX, particles);
    end

end

