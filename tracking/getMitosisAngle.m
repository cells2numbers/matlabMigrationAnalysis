function [ mitosisAngle ] = getMitosisAngle(am,pm,fm,varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


minLengthParent = 10;
minLengthDaughter = 10;

PLOT = 0;

i=1;
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            % argument IDs
            case 'minLengthParent',   i=i+1; minLengthParent = varargin{i};
            case 'minLengthDaughter', i=i+1; minLengthDaughter = varargin{i};
            case 'PLOT',              i=i+1; PLOT = varargin{1}; 
            case 'plot',              i=i+1; PLOT = varargin{1};
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    
    if ~argok,
        disp(['getMitosisAngle.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
    end
    i = i+1;
end


[r,s,d,cellRelation ] = getMitosisMovement( am,pm,fm,'minLengthParent',minLengthParent,...
    'minLengthDaughter',minLengthDaughter);


% die matrix mitosisAngle speichert fünf Winkel:
%
% mitosisAngle(1,:)    Richtung der Mutterzelle, die weiteren Winkel
%                      werden relativ zu diesem Winkel gemessen, d.h.
%                      es wird der Winkel zwischen den Tochterzellen 
%                      und der Mutterzelle gemessen. 
% mitosisAngle(2,:)    Winkel zwischen Tochter 1 und der Mutterzelle 
% mitosisAngle(3,:)    Winkel zwischen Tochter 2 und der Mutterzelle 
% mitosisAngle(4,:)    Winkel zwischen Tochter 1 und Tochter 2 
%
% Die Winkel bisherigen Winkel 1,2,3,4 werden über einen Zeitraum von n
% Bildern berechnet (n kann als Variable pathlength angegeben werden, s.u.)
% Im Gegensatz dazu wird Winkel 5 direkt nach der Teilung bestimmt 
% 
% mitosisAngle(5,:)    Richtung bzw. Winkel zwischen den Zellkonturen
%                      beider Tochterzellen nach der Teilung

for i = 1:length(r)
    
    %% calculate mitosisAngle for mother and both daughter cells
    % and scale it to [0 2pi]
    
    
    
    mitosisAngle(2,i) = acos( dot(-r{1,i},r{2,i}) / (norm(r{1,i})*norm(r{2,i})  ));
    mitosisAngle(3,i) = acos( dot(-r{1,i},r{3,i}) / (norm(r{1,i})*norm(r{3,i})  ));
    mitosisAngle(4,i) = acos( dot(r{2,i},r{3,i}) / (norm(r{2,i})*norm(r{3,i})  ));

    p1 = cellRelation(i,2);
    p2 = cellRelation(i,3);
    
    pathinfo1 = pm{p1,3}(1,:);
    pathinfo2 = pm{p2,3}(1,:);
    
    pos1 = fm{pathinfo1(1)}(pathinfo1(2),1:2);
    pos2 = fm{pathinfo2(1)}(pathinfo2(2),1:2);
    diff = pos1 - pos2;
    mitosisAngle(5,i) = acos( dot(diff,-r{1,i}) / (norm(diff)*norm(r{1,i})  ));
    
%     %mitosisAngle(5,i) = atan2(diff(1),diff(2)) -  mitosisAngle(1,i) + pi/2;
%     
%      if mitosisAngle(5,i) > pi
%         mitosisAngle(5,i) = mitosisAngle(5,i) - 2*pi;
%     elseif mitosisAngle(5,i) < -pi
%         mitosisAngle(5,i) = mitosisAngle(5,i) + 2*pi;
%     end
    
end



if PLOT
    nbins = 36;
    figure();
    subplot(2,2,1);
    rose(mitosisAngle(2,:),nbins)
    title('Tochter1 - Mutterzelle');
    subplot(2,2,2);
    rose(mitosisAngle(3,:),nbins)
    title('Tochter2 - Mutterzelle');
    subplot(2,2,3);
    rose(mitosisAngle(4,:),nbins)
    title('Tochter1 - Tochter2');
    subplot(2,2,4);
    rose(mitosisAngle(5,:),nbins)
    title('Zelle - Zelle ');
    %legend(sprintf('(Pfadlänge Mutter / Tochter: %i /  %i )',minLengthParent,minLengthDaughter));
end
end

