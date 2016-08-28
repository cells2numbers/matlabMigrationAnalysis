
V = [];

filelist  = dir('/media/beckert/My Passport/2015_daten_migration/');
indExp = find([filelist.isdir]);


for i=indExp
    
    disp('next experiment');
    
    expPath = [];
    expPath.path = ['/media/beckert/My Passport/2015_daten_migration/' filelist(i).name ];
    fprintf('analysing %s \n',expPath.path);
    expPath.name = [];
    expPath.type = [];
    cd(expPath.path);
    
    dirList = dir('*');
    count = 1;
    
    for i=1:length(dirList)
        if ~isempty( strfind(dirList(i).name,'run_A') ) && ...
                isempty( strfind(dirList(i).name,'tif') )
            expPath(count).name = dirList(i).name;
            expPath(count).type = 1; % control
            count = count +1 ;
        end
        if ~isempty( strfind(dirList(i).name,'run_B') ) && ...
                isempty( strfind(dirList(i).name,'tif') )
            expPath(count).name = dirList(i).name;
            expPath(count).type = 2; % pred
            count = count +1 ;
        end
        if ~isempty( strfind(dirList(i).name,'run_C') ) && ...
                isempty( strfind(dirList(i).name,'tif') )
            expPath(count).name = dirList(i).name;
            expPath(count).type = 3; % vehicel
            count = count +1 ;
        end
    end
    
    %%
    
    
    
    
    V = [];
    if ~isempty(expPath(1).name)
        
        
        
        
        
        for iExp = 1:length(expPath)
            
            file = [expPath.path filesep expPath(iExp).name filesep 'results' filesep 'migrationData.mat'];
            load(file)
            V = [V;velocity',X_FMI',Y_FMI',D',repmat(expPath(iExp).type,size(D'))];
            
            tLngfile = ([expPath.path filesep  expPath(iExp).name filesep 'results' filesep 'image_tLng.mat']);
            
            switch expPath(iExp).type
                case 1
                    disp('data control');
                case 2
                    disp('data pred');
                case 3
                    disp('data vehicel');
            end
            h = showTrajectoryAndAngle(tLngfile,validPaths);           
        end
        
        indA = find(V(:,5) == 1);
        indB = find(V(:,5) == 2);
        indC = find(V(:,5) == 3);
        
        
        figure();
        plot(V(indA,2),V(indA,1),'x');
        hold on;
        plot(V(indB,2),V(indB,1),'go');
        plot(V(indC,2),V(indC,1),'r*');
        hold off;
        xlabel('X-FMI');
        ylabel('velocity');
        legend('control','pred','vehicel')
        axis square
        
        figure()
        h = histfit(V(indA,2));
        set(h(2),'color','b')
        delete(h(1))
        hold on;
        h = histfit(V(indB,2));
        set(h(2),'color','g')
        delete(h(1))
        h = histfit(V(indC,2));
        set(h(2),'color','r')
        delete(h(1))
        title('distribution of x-fmi');
        axis square
        
        
        figure();
        plot(V(indA,2),V(indA,1),'x');
        hold on;
        plot(V(indB,2),V(indB,1),'go');
        plot(V(indC,2),V(indC,1),'r*');
        hold off;
        xlabel('X-FMI');
        ylabel('velocity');
        legend('control','pred','vehicel')
        axis square
        
        figure()
        h = histfit(V(indA,3));
        set(h(2),'color','b')
        delete(h(1))
        hold on;
        h = histfit(V(indB,3));
        set(h(2),'color','g')
        delete(h(1))
        h = histfit(V(indC,3));
        set(h(2),'color','r')
        delete(h(1))
        title('distribution of y-fmi');
        axis square
        
        
        figure();
        boxplot(V(:,1),V(:,5));
        title('velocity');
        
        figure();
        boxplot(V(:,2),V(:,5));
        title('X-FMI');
        
        figure();
        boxplot(V(:,3),V(:,5));
        title('Y-FMI');
        
        figure();
        boxplot(V(:,4),V(:,5));
        title('directness');
        csvwrite('migrationData.csv',V)
    end
end
