function saveName = getExpDataSavename(Exp,iGroup,iExp,pLength,tWindow)
% function to return the savename (mat-file) for an evaluated experiment
%
% function is only needed to get an easier access to the correct 
% mat-files 
%
%
%  04.2012 tb

saveName = [Exp.dataPath sprintf('%s_%02i_%02i_%02i.mat',...
    Exp.label{iGroup},iExp,pLength,tWindow)];