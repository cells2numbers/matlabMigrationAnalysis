function [] = plotMigrationData(migrationData,header,dataLegend,dataIndex,indX,indY)


plotSymbols = {'go','k*','bs','+r'};

for i = 1:length(dataIndex)
    plot(migrationData(dataIndex{i},indX),migrationData(dataIndex{i},indY),plotSymbols{i})
    hold on
end 

xlabel(header{indX})
ylabel(header{indY})
legend(dataLegend)

hold off

end

%%


