% load data
uiopen()

if strfind(pathList{1},'FN')
    class_names = {'kontr','pred','vehi','dmso'};   
    disp('Matrix: FN');
else
    class_names = {'kontr','pred','vehicle'};
     disp('Matrix: HEM');
end
    

class_id = cell(size(class_names));

for iFile=1:length(fileList)
    for iClass =1:length(class_names)
        if strfind(fileList{iFile},class_names{iClass})
            class_id{iClass}(end+1) = iFile;
        end
    end
end

% remove double entries introduced by the pattern the classes are 
% identified 
if strfind(pathList{1},'FN')
    class_id{2} = setdiff(class_id{2},class_id{3}); 
end
    
fprintf('mean number of paths and SEM \n');
fprintf('_________________________________\n');
for iClass=1:length(class_names)
    fprintf('class %s \t',class_names{iClass});
    fprintf('%6.2f \t', mean(migrationData(class_id{iClass},2)))
    fprintf('%6.2f \n', std(migrationData(class_id{iClass},2))/sqrt(length(class_id{iClass})))
end