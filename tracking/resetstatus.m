function tLng = resetstatus(tLng)
	% reset the status-vectors for a tLng-struct 
    %
    %  tLng = resetstatus(tLng)
    %
	%  this is a helper function needed if we want to calculate a new
	%  bloddline / lineage
	% 
    % no optional arguments
    %
    % Example
    %  to reset the status, simply call
    %  tLng = resetstatus(tLng)
    %
    % See also fillLineage.m
    %
    % 
	%  
    % @ t.b. 03.2009
	% !!ATTENTION, STATUS CHANGED!!!
    % DO NOT USE THIS FUNCTION WITH AN TIMLINE / PM 
    % CREATED LATER THAN 2009!!!!
for time=1:tLng.time_max
	status = zeros(tLng.cell(time).number,1);
	tLng = modTimestampNG(tLng,time,'status',status);
end