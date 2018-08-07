%%
base_directory = '/Volumes/BackupTimBecker/2018_08_06_migration_perturbations_asthma/matlab/';

%%

dir_list = dir(base_directory);

for i = 4:length(dir_list)
    experiment_path = fullfile(base_directory, dir_list(i).name);
    number_of_images = length(dir(fullfile(experiment_path, 'images','*png')));
    fprintf('%i \n',i);
    mkdir(fullfile(experiment_path,'results'))
    cd(experiment_path);
    date_created =  datestr(now);
    save('expInfo.mat','date_created','number_of_images','experiment_path');
    
    copyfile(fullfile(base_directory,'image_parameters.mat'),fullfile(experiment_path, 'images','image_parameters.mat' ))
    
end

%%
dir(fullfile(base_directory, dir_list(i).name))