function calculateExpData(Exp,force)
% 
%  
%  function calculateExpData(Exp)
%
%
%  each group consists of different experiments  
%     (Exp.label, Exp.group{iGroup}) 
%     
%  each experiment consists of different position  
%     (Exp.group)
%  
%
% Exp =
%
%         path: '/home/beckert/Desktop/samba_network/technologie/celltracking/data/'
%     dataPath: '/home/beckert/Desktop/data/'
%        group: {{1x3 cell}  {1x3 cell}  {1x4 cell}}
%          out: {{1x4 cell}  {1x4 cell}  {1x4 cell}}
%        label: {'control'  'apoptosis'  'necrosis'}
%      pLength: 6
%      tWindow: 6
%
% 
% Exp.group{1}       [1x31 char]    [1x41 char]    [1x41 char]
% Exp.group{1}{1}    timelapse2011/20111214_hela_P5X
% Exp.out{1}         []    []    []    []
% 
% 04.2012 tb

VERBOSE = 0;

data = [];

if ~exist('force','var')
   force = 0; 
end


% loop over all groups
for iGroup=1:length(Exp.label)
    % we calculate  the data for each experiment
    % 
    % needed for compatib. with tLng_analyze_gui
    tLngFiles = Exp.group{iGroup};
    outlier = Exp.out{iGroup};
    tLngFiles = {};
    
    for i=1:size(Exp.group{iGroup},2)
       tLngFiles{i}  = [Exp.path Exp.out{iGroup}{i}];
    end
    
    for iExp = 1: size(Exp.group{iGroup},2)
        pathname = [ Exp.path Exp.group{iGroup}{iExp}];
        % for all given pLength and tWindow combinations
        for pLength = Exp.pLength
            for tWindow = Exp.tWindow
                % create the name to save data
                saveName = getExpDataSavename(Exp,iGroup,iExp,pLength,tWindow);
                % if such a file exist, we assume it has been
                % calculated before -> we skip this file 
                if ~force || exist(saveName,'file')
                    if VERBOSE
                    fprintf('experiment already analyzed, skipping %s \n',...
                        Exp.group{iGroup}{iExp});
                    end
                else
                    % now we calculate the data with given para. 
                    % and store the file
                    data = getValidatedExperiment(pathname,pLength,...
                        tWindow,Exp.out{iGroup}{iExp});
                    data.saveName = saveName;
                    
                    save(saveName,'data','pLength','tWindow','tLngFiles','Exp');
                end
            end
        end
    end
end