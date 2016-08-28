
expPath = '/media/beckert/My Passport/2015_daten_migration/';
cd(expPath);
load('migrationData.mat');

for i=1:length(fileList)
    fprintf('%i \t %s \n',i,fileList{i});
end

%%
% runA = control 
%% define 
% indControl = [ 8 15 22 41 ];
% runB = Pred 
%indVehicel = [ 9  16 23 42 ];
% runC = vehicel
%indPred = [10  17 24 43 ];


%%or select all 
indControl = [];
indPred = [];
indVehicel = [];

for i=1:length(fileList)
   if ~isempty( strfind(fileList{i},'run_A') )
       indControl(end+1) = i;
   end
    if ~isempty( strfind(fileList{i},'run_B') )
       indPred(end+1) = i;
    end
    if ~isempty( strfind(fileList{i},'run_C') )
       indVehicel(end+1) = i;
   end
end

 
%% cell array containing all data 
XFMI = {};
VEL = {};

for i =1:length(indControl)
    load([pathList{indControl(i)} filesep 'results' filesep 'migrationDataValidPaths.mat']);
    XFMI{1,i} = X_FMI;
    VEL{1,i} = velocity;

    load([pathList{indPred(i)} filesep 'results' filesep 'migrationDataValidPaths.mat']);
    XFMI{2,i} = X_FMI;
    VEL{2,i} = velocity;
    
    load([pathList{indVehicel(i)} filesep 'results' filesep 'migrationDataValidPaths.mat']);
    XFMI{3,i} = X_FMI;
    VEL{3,i} = velocity;
    

end


%%
for i=1:length(indPred)
    disp('files:');
    disp(pathList{indControl(i)});
    disp(pathList{indPred(i)});
    disp(pathList{indVehicel(i)});
    figure();
    subplot(1,2,1)
    indFastCell_1 = find(VEL{1,i} > 5);
    indFastCell_2 = find(VEL{2,i} > 5);
    indFastCell_3 = find(VEL{3,i} > 5);
    label = [repmat(1,size(indFastCell_1)),repmat(2,size(indFastCell_2)),repmat(3,size(indFastCell_3))];
    boxplot([XFMI{1,i}(indFastCell_1),XFMI{2,i}(indFastCell_2),XFMI{3,i}(indFastCell_3)],label)
    title('xfmi');
     subplot(1,2,2)
    boxplot([VEL{1,i}(indFastCell_1),VEL{2,i}(indFastCell_2),VEL{3,i}(indFastCell_3)],label)
    title('velocity')
end