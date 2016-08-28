

getApoptoseExperiments;


[cellPara,label] = getExpDataGroup(Exp,1);

[cellPara2,label2] = getExpDataGroup(Exp,200:220);


    
nbayesTest = NaiveBayes.fit(cellPara,label);
    
C1 = nbayesTest.predict(cellPara2);
    



confusionmat(label2,C1)


perfcurve(label2,nbayesTest.posterior(cellPara2) ,C1)

%%

[x,y] = meshgrid(0:1:100,1:2:100);
x = x(:);
y = y(:);
figure
j = classify([x y],cellPara2(:,[6,7]),label2,'linear');
gscatter(x,y,j,'grb','sod')
xlabel('speed');
ylabel('migration');