function lintree =  lintreeInit()
	%
	% lintree =  lintreeInit()
    %
    % function to initialize an empty lintree
    %
    % INPUT
    %
    % OUTPUT
    %
    % lintree = lineagetree struct, consisting of: name, infos, status,
    % cellcoordinates, mitosis, father (lt), son (lt), sonpath (int), 
    % daughter (lt), daughterpath (int)
    %
    % Example: lintree = lintreeInit()
	%
	% Copyright M.B. 04.2009

% create new lintree
lintree = struct('type', 'linagenode', ...
    'name', [], ...
    'infos', [], ...
	'status', 0, ...
    'cellcoordinates', [], ...
    'mitosis', [], ...
	'father', [], ...
	'son', [], ...
	'sonpath', [], ...
	'daughter', [], ...
	'daughterpath', []);
