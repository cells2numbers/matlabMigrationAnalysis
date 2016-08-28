function [number,time] = lintreeCreateBinaryList(lt,generation,index,number,time)
% lintreeGetEdges collects all edges of an given lintree
%
% index        1 1 2 1 2 3 4 1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8 9 10 11 12 13 
%  
% generation   1 2 2 3 3 3 3 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5  5  5  5  5
% 
% one complete 
% branch       1 1 0 1 2 0 0 1 2 3 4 0 0 0 0 1 2 3 4 5 6 7 8 0 0  0  0  0  0
%
%
% 
%  t.b. 01.2013

% when lintreeCreateBinaryList is called, no number and time are given
% 
if ~exist('number','var')
    number = [];
end

if ~exist('time','var')
    time = [];
end


if ~exist('index','var')
    index = 1;
end

if ~exist('generation','var')
    generation = 1;
end



if isstruct(lt)&&(strcmp(lt.type,'linagenode'))
    
    % if we have a leaf, we return nothing
    if index == 1 && generation == 1
        number(1) = 1;
        time(1) = lt.cellcoordinates(1);
    end
    
   
    
    if ~isempty(lt.son)
        % initialze all indices for the next generation
        number(2^generation -1 + 2^generation) = 0;
        time(2^generation -1 + 2^generation) = 0;
        
        number(2^generation -1 + 2*index-1) = 2*index -1;
        time(2^generation -1 + 2*index-1) = lt.son.cellcoordinates(1);
        [number,time] = lintreeCreateBinaryList(lt.son,generation+1,2*index-1,number,time);
    end
    
    if ~isempty(lt.daughter)
        % initialze all indices for the next generation
        number(2^generation -1 + 2^generation) = 0;
        time(2^generation -1 + 2^generation) = 0;
        % set the index
        number(2^generation -1 + 2*index) = 2*index;
        time(2^generation -1 + 2*index) = lt.daughter.cellcoordinates(1);
        [number,time] = lintreeCreateBinaryList(lt.daughter,generation+1,2*index,number,time);
    end
    
else
    disp('wrong input, collectEdges expects an lineagenode as input');
end

