function [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,pNr)
%  getNodeInfo collects and returns information about a node
%
%  [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,pNr)
%
%  INPUT: 
%
%    am      adjacency matrix  (see createGraph2.m)
%    pNr     path-number (int. value < length(am) 
%
%  OUTPUT:
%
%    dIn     degree of incoming edges
%    dOut    degree of outgoing edges
%
%    cNIn    information about all Connected Nodes that of the  Incoming
%             edges 
%    cNOut   same with all outgoing edges
%
%    
%    cNIn has the size [dIn,4], 
%           and cNOut [dOut,4]
%
%    cNIn / cNOut store in each row information about one connected
%    vertex / node.  you find the following information
%
%    [nodeNr, weightIn, weightOut, degree]
%
%    with 
%       -nodeNr is the nr. of the connected node
%       -weightIn is the weight (overlap) from cell nodeNr to the 
%        actual cell pNr
%       -weightOut is the weight (overlap) from the actual cell pNr to 
%        the connected cell nodeNr
%       -the last column stores the in/out-degree of the node nodeNr
%        (in-degree in cNOut and out-degree in cNIn)
%  
%
% tim becker july 2009

% we find all incoming and outgoing cells
cellsIn  = find(am(pNr,:)<0);
cellsOut = find(am(pNr,:)>0);



% we store the incoming / outgoing degree of node pNr
dIn  = length(cellsIn);
dOut = length(cellsOut);

if dIn || dOut
    
    % we init the output var's
    cNIn  = zeros(dIn,4);
    cNOut = zeros(dOut,4);
    
    % we can write the cell-nr of all incoming / outgoing cells
    cNIn(:,1)  = cellsIn';
    cNOut(:,1) = cellsOut';
    
    % now we deal with all incoming cells
    for i=1:dIn
        iNr = cellsIn(i);
        cNIn(i,2) = am(iNr,pNr);
        cNIn(i,3) = am(pNr,iNr);
        cNIn(i,4) = length(find(am(iNr,:)>0)); % out-degree
        %( number of connected paths, the actual path pNr is
        % one of them
        
    end
    
    % the same with all outgoing cells
    for i=1:dOut
        oNr = cellsOut(i);
        cNOut(i,2) = am(oNr,pNr);
        cNOut(i,3) = am(pNr,oNr);
        cNOut(i,4) = length(find(am(oNr,:)<0));
    end
    
else
    cNIn  = zeros(1,4);
    cNOut = zeros(1,4);
end