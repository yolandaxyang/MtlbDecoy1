function [ particles ] = UpdatePriorDistCES( obsChoice, obsX, particles )
%UPDATEPRIORDISTCES
    particles = updatePriorCES(obsChoice, obsX, particles);

end

