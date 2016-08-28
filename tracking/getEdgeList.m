function edgeList = getEdgeList(am)
% getEdgeList returns the number of incoming and outgoing edges
%  edgeList = getEdgeList(am)
%  
%  edgeList is a vector with size nx2 where n is the size of 
%  the adjaceny matrix ( to be more precisely am has a size of 
%  nxn). the first row contain the number of incoming edges,
%  the second contains the number of outgoing connections
%
% tim becker 06.2009

N = size(am,2);

edgeList = zeros(N,2);

for i=1:N
    % the actual row
    v = am(i,:);
    
    % we count all positive
    edgeList(i,1) = size(v(v>0),2);
    
    % and the negative ones
    edgeList(i,2) = size(v(v<0),2);
end
