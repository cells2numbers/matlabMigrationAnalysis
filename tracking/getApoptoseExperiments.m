
% folder containing all experiments
Exp.path = '/home/beckert/Desktop/samba_network/technologie/celltracking/data/';
Exp.dataPath = '/home/beckert/Desktop/data/';


% Experiment names for the control group experiments + outliers
Exp.group{1} = {
    [ 'timelapse2011' filesep '20111214_hela_P5X'],...
    [ 'timelapse2012' filesep '20120123_HeLa_P63_Kontrolle'],...
    [ 'timelapse2012' filesep '20120125_HeLa_P64_Kontrolle']  };
Exp.out{1} = {[],[],[],[]};

% sts induced apoptose incl. outliers 
Exp.group{2} = {
    [ 'timelapse2011' filesep '20111221_Hela_P5X'],...
    [ 'timelapse2011' filesep '20120103_Hela_P60'],...
    [ 'timelapse2012' filesep  '20120119_HeLa_P62_STS']
    };
Exp.out{2} = {[],[],[],[]};

% H2O2 necrosis
Exp.group{3} = {
    [ 'timelapse2012' filesep '20120109_Hela_P60_H2O2'],...
    [ 'timelapse2012' filesep '20120127_HeLa_P64_H2O2'],...
    [ 'timelapse2012' filesep '20120130_HeLa_P64_H2O2'],...
    [ 'timelapse2012' filesep '20120203_HeLaP65_H2O2']
};
Exp.out{3}= {4,[1,3],[],[]};

Exp.label = {'control','apoptosis','necrosis'};

Exp.pLength = [6];
Exp.tWindow = [6];

calculateExpData(Exp);