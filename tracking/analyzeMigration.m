%% Analyzed data 
% the following data were analyzed
load migrationData;
for i=1:length(fileList)
    disp(fileList{i});
end

%---------------------------------------------------------
% paths 	 valid 	 ratio 	 X-FMI 	 Y-FMI 	 D 	 
%---------------------------------------------------------

indexA = findInCell(strfind(fileList,'run_A'));
indexB = findInCell(strfind(fileList,'run_B'));
indexC = findInCell(strfind(fileList,'run_C'));
indexD = findInCell(strfind(fileList,'run_D'));
indexE = findInCell(strfind(fileList,'run_E'));
indexF = findInCell(strfind(fileList,'run_F'));
indexG = findInCell(strfind(fileList,'run_G'));

%% plot xfmi against yfmi for all data 
figure();
indexX = 4;
indexY = 5;
plot(migrationData(indexA,indexX), migrationData(indexA,indexY),'rx');
hold on;
plot(migrationData(indexB,indexX), migrationData(indexB,indexY),'g*');
plot(migrationData(indexC,indexX), migrationData(indexC,indexY),'b.');
hold off; 

legend('runA','runB','runC');
xlabel('x fmi');
ylabel('y fmi');


%% plot normalized data (x-fmi against distance travelled)

indexX = 4;
indexY = 5;

figure();
indexNormalize = indexA;
plot(migrationData(indexA,indexX)./migrationData(indexNormalize,indexX),...
    migrationData(indexA,indexY)./migrationData(indexNormalize,indexY),'rx');
hold on;
plot(migrationData(indexB,indexX)./migrationData(indexNormalize,indexX),...
    migrationData(indexB,indexY)./migrationData(indexNormalize,indexY),'g*');
plot(migrationData(indexC,indexX)./migrationData(indexNormalize,indexX),...
    migrationData(indexC,indexY)./migrationData(indexNormalize,indexY),'b.');
legend('runA','runB','runC');
xlabel('x fmi');
ylabel('y fmi');
hold off;
%
figure();
indexNormalize = indexB;
plot(migrationData(indexA,indexX)./migrationData(indexNormalize,indexX),...
    migrationData(indexA,indexY)./migrationData(indexNormalize,indexY),'rx');
hold on;
plot(migrationData(indexB,indexX)./migrationData(indexNormalize,indexX),...
    migrationData(indexB,indexY)./migrationData(indexNormalize,indexY),'g*');
plot(migrationData(indexC,indexX)./migrationData(indexNormalize,indexX),...
    migrationData(indexC,indexY)./migrationData(indexNormalize,indexY),'b.');
legend('runA','runB','runC');
xlabel('x fmi');
ylabel('y fmi');
hold off;
%
figure();

indexNormalize = indexC;
plot(migrationData(indexA,indexX)./migrationData(indexNormalize,indexX),...
    migrationData(indexA,indexY)./migrationData(indexNormalize,indexY),'rx');
hold on;
plot(migrationData(indexB,indexX)./migrationData(indexNormalize,indexX),...
    migrationData(indexB,indexY)./migrationData(indexNormalize,indexY),'g*');
plot(migrationData(indexC,indexX)./migrationData(indexNormalize,indexX),...
    migrationData(indexC,indexY)./migrationData(indexNormalize,indexY),'b.');
legend('runA','runB','runC');
xlabel('x fmi');
ylabel('y fmi');
hold off;
