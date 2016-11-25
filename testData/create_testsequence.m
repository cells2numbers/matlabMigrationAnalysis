figure()
count = 1;
for posX=2:10:990
    I = zeros(1000,1000);
    
    for posY=30:70:870
        I((posY - 8):(posY + 7),posX:(posX+16)) = 1;
    end

    I(950:965,(1000-posX-15):(1000-(posX))) = 1;
    
    fileName = sprintf('testsequence_%03i.tif',count);
    imagesc(I);
    count = count +1;
    drawnow;
    imwrite(I,fileName,'tif');
end

!convert *tif testsequence.tif
!rm testsequence_0*