function fig = lintreePlot3D(lt,pm,varargin)
%  function to display a lnitree in 3d (returns the figure handle)
%
%  h = lintreePlot3D(lt,varargin)
%
%  (you can choose spline interpolated data)
%	%  optional arguments:
%
%  plot_style     1 :  no spline-approximation
%                 2 :  exact spline approx. (all data-points)
%                 3 :  spline approx. on a  grid
%                        (if none is set,  type 1 is choosen )
%                 4 :  pipe plot (3d-pipes using surfaces, spline
%                      interpolation is forced
%
%  smooth      double       this this gives the 'smooth'-factor
%                        (exactly this value gives the number of
%                        frames to which the bigger appr. gridsize is
%                        set). if no smooth value is given but
%                        plot_style 3 is choosen, smooth is set to 8
%
%
%  spline_dist  double   this gives the distant between the
%                        approx. points
%                        (if 2 or 3 is choosen without setting spline_dist
%                        it's set to a default-value of 0.5)
%
%
%
% Example:
% if you want to see the lintree:
%
%  h = lintreePlot3Ds(lt,pm);
%
%  using some more options:
%
%  h= lintreePlot3D(lt1.son,pm,'plot_style',3,'smooth',2,...
%                    'delay',1,'figure',1,'spline_dist',0.1);
%
%
% REMARK: this version is for use with automaticaly created lineage's.
%         the first version, which was for use with manual created
%         lineages, differs only in the way to get the
%         x,y,z-coordinates.
%
%
%
%  See also pipe_plot, lintreePlot, lintreePlot3Dml
%
% tim becker 03.2009
%
% TODO:
%       -need a help-function to create the x- and y- coordinates
%
%       -transparent visual. and a better color

%
% set standard values
%


% choose a color to plot
clr = [.15,.25,.5] + .35*rand(1,3);
clr = [1 0 0 ];

% plot paramter for pipe_plot
pipe_radius = 2;

fig = [];
delay = 0;
spline_dist = .5;   % this gives the distant between the
% approx. points

PLOTMITOSIS = 1;

smooth = 8;         % this this gives the 'smooth'-factor
% (exactly this value gives the number of
% frames to which the bigger appr. gridsize is
% set)

plot_style = 1;      % plot types:
% type 1   =   no spline-approximation
% type 2   =   spline approx. off all data-points
% type 3   =   spline approx. on a bigger grid
%              (only each 'smooth' point is
%              taken)



% evaluate (optional) input arguments
i=1;
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            % argument IDs
            case 'plot_style',       i=i+1; plot_style = varargin{i};
            case 'smooth',           i=i+1; smooth = varargin{i};
            case 'delay',            i=i+1; delay = varargin{i};
            case 'spline_dist',      i=i+1; spline_dist = varargin{i};
            case 'figure',           i=i+1; fig = varargin{i};
            case 'plotmitosis',      i=i+1; PLOTMITOSIS = varargin{i};
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    
    if ~argok,
        disp(['lintreePlot3D.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
    end
    i = i+1;
end

% first we take care about the figure
% ( we create a new one if none is given)
if isempty(fig)
    fig = figure();
    grid on;
    xlabel('x coordinates');
    ylabel('y coordinate');
    zlabel('cellcoordinates(1)');
end
%	%elseif length(varargin)==1
%		fig = varargin{1};
%	elseif length(varargin)==2
%		fig = varargin{1};
%		delay = varargin{2};
%	end



% select figure
if 	isequal(get(fig,'Type'),'axes')
    axes(fig);
elseif isequal(get(fig,'Type'),'figure')
    figure(fig);
else
    disp('wrong figure/axes');
end
pause(delay);

if isstruct(lt)&&(strcmp(lt.type,'linagenode'))
    
    if ~isempty(lt.son)
        % connection between node and first frame (cell)
        coord = pm{lt.sonpath,3};
        x = [lt.cellcoordinates(2);coord(:,2)];
        y = [lt.cellcoordinates(3);coord(:,3)];
        z = [lt.cellcoordinates(1);coord(:,1)];
        % is spline interpolation choosen?
        if plot_style > 1
            [z,ind] = unique(z);
            x = x([1;ind(2:end)]);  % this indexing  is needed to get the
            % cellcoordinates(1) and position of the starting
            % node
            y = y([1;ind(2:end)]);
            
            %x = cx(ind);
            %y = cy(ind);
            
            sz = lt.cellcoordinates(1):spline_dist:lt.son.cellcoordinates(1);
            x = spline(z,x,sz);
            y = spline(z,y,sz);
            z = sz;
            
            % is a smoother spline-interpolation choosen?
            if plot_style > 2
                % some more smoother
                ssz = lt.cellcoordinates(1):smooth:lt.son.cellcoordinates(1);
                
                if ssz(end)~=lt.son.cellcoordinates(1)
                    ssz(end+1) = lt.son.cellcoordinates(1);
                end
                
                % get the 'bigger' interpolation
                ssx = spline(z,x,ssz);
                ssy = spline(z,y,ssz);
                
                % the bigger is ugly, not smooth.
                % we get the smoothness by interpolating
                % the big grid on the original spline-grid-size
                % given by 'spline_dist'
                x = spline(ssz,ssx,z);
                y = spline(ssz,ssy,z);
                
            end
            
        end
        % now we plot the edge
        hold on;
        if plot_style < 4
            plot3(x,y,z,'Linewidth',1,'Color',clr);
            if PLOTMITOSIS
                plot3(lt.cellcoordinates(2),lt.cellcoordinates(3),lt.cellcoordinates(1),'.','Markersize',10);
            end
        else
            pipe_plot(x,y,z,pipe_radius);
            if PLOTMITOSIS
                plot3(lt.cellcoordinates(2),lt.cellcoordinates(3),lt.cellcoordinates(1),'.','Markersize',10);
            end
        end
        
        hold off;
        
        % now we plot the son-edge
        fig =  lintreePlot3D(lt.son,pm,'plot_style',plot_style,'smooth',smooth,'delay',delay,'figure',fig,'spline_dist',spline_dist,'plotmitosis',PLOTMITOSIS);
    end
    
    % the daughter will follow as well
    
    if ~isempty(lt.daughter)
        % connection between node and first frame (cell)
        coord = pm{lt.daughterpath,3};
        x = [lt.cellcoordinates(2);coord(:,2)];
        y = [lt.cellcoordinates(3);coord(:,3)];
        z = [lt.cellcoordinates(1);coord(:,1)];
        
        % is spline interpolation choosen?
        if plot_style > 1
            [z,ind] = unique(z);
            x = x([1;ind(2:end)]);  % this indexing  is needed to get the
            % cellcoordinates(1) and position of the starting
            % node
            y = y([1;ind(2:end)]);
            
            % we do some spline-interpolation of all data-points with
            % grid-size   "spline_dist"
            sz = lt.cellcoordinates(1):spline_dist:lt.daughter.cellcoordinates(1);
            x = spline(z,x,sz);
            y = spline(z,y,sz);
            z = sz;
            
            % is a smoother spline-interpolation choosen?
            if plot_style > 2
                ssz = lt.cellcoordinates(1):smooth:lt.daughter.cellcoordinates(1);
                
                % we have to make sure, the ending node is included
                if ssz(end)~=lt.daughter.cellcoordinates(1)
                    ssz(end+1) = lt.daughter.cellcoordinates(1);
                end
                
                % get the 'bigger' interpolation
                ssx = spline(z,x,ssz);
                ssy = spline(z,y,ssz);
                
                % the bigger is ugly, not smooth.
                % we get the smoothness by interpolating
                % the big grid on the original spline-grid-size
                % given by 'spline_dist'
                x = spline(ssz,ssx,z);
                y = spline(ssz,ssy,z);
                
            end
            
        end
        % now we plot the edges ( depends on the choosen plot-style)
        hold on;
        if plot_style < 4
            plot3(x,y,z,'Linewidth',1,'Color',clr);
        else
            pipe_plot(x,y,z,pipe_radius);
        end
        if PLOTMITOSIS
            plot3(lt.cellcoordinates(2),lt.cellcoordinates(3),lt.cellcoordinates(1),'.','Markersize',10);
        end
        hold off;
        
        % now we plot the the daughter-edge
        fig =  lintreePlot3D(lt.daughter,pm,'plot_style',plot_style,'smooth',smooth,'delay',delay,'figure',fig,'spline_dist',spline_dist,'plotmitosis',PLOTMITOSIS);
    end
    
end
