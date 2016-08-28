function [cellpara,label] = getExpDataGroup(Exp,frames,pLength,tWindow)
% function to create labeled data using Exp-struct
%
%
%  [cellpara,label] = getExpDataGroup(Exp,frames,pLength,tWindow)
%
%
%  frames     different time frames can be chosen for data creation
%
% input pLength + tWindow is optional (extracted from Exp-struct if
% not given)
%
% tb 04.2012


% check for input pLength + tWindow, if they are not given, the first 
% values stored in Exp are chosen
if ~exist('pLength','var')
    pLength = Exp.pLength(1);
end 

if ~exist('tWindow','var')
    tWindow = Exp.tWindow(1);
end

% init output vars
cellpara = [];
label = {};

% first, we need to evaluate the data. this function will skip each
% experiment with existing data
calculateExpData(Exp)



for iGroup = 1:length(Exp.label)
    for iExp = 1: size(Exp.group{iGroup},2)
        % avoid outliers
        if isempty(Exp.out{iGroup}{iExp}) || ~sum((Exp.out{iGroup}{iExp} == iExp))
            saveName = getExpDataSavename(Exp,iGroup,iExp,pLength,tWindow);
            load(saveName);
            
            cellpara = [cellpara; data.mean(frames,:)];
            for i=1:length(frames)
                label{end+1} = Exp.label{iGroup};
            end
            
        end
    end
end

    