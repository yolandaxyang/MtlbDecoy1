function [ particles ] = UpdatePriorDistCES( obsChoice, obsX, particles )
%UPDATEPRIORDISTCES update prior with observed choice and normalized x
%values
    particles = updatePriorCES(obsChoice, obsX, particles);

end

