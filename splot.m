function plotHandle=splot(x,y,initialScale)
% splot: function to plot x,y data and allow user to scale
%        and scroll through the data
%
%   h=splot(x,y,initialScale) plots x vs y with an initial window size
%       of initialScale (1-100%)    
%
%   <INPUTS>
%       x: x data
%       y: y data
%       initialScale (%): initial percent of data you want to display in a
%           in a window/plot
%   <OUTPUT> 
%       plotHandle: handle of plot figure

%%  Verify Input
    if nargin < 2        
        y=x;
        x=1:length(x);
    end
    if nargin < 3
        initialScale=10;
    end
    if isempty(x)
        error('Too few input arguments')
        return
    end

%%  Initialize
    % dx is the width of the axis 'window'
    global sldStep
    global dx
    global dIndex %number of x values in plot window
    sldStep = initialScale/100;
    %dx = sldStep*max(x);
    dx=floor(sldStep*length(x));
%%  Construct the components

    %Main Figure
    h.MainFigure = figure('Name','splot - Data preview','MenuBar','none', ...
                    'Toolbar','none', ...
                    'HandleVisibility','callback', ...
                    'Toolbar','figure','Menubar','figure',...
                    'Position',[20 50 900 500 ]);

    %background panel
    h.container1 = uipanel('Parent',h.MainFigure,...
             'Position',[.005 .005 .99 .99]);              
    %---------------------------------------------
    %container for controls
    h.containerX = uipanel('Parent',h.container1,...
             'Position',[.06 .05 .85 .12]);
         
    %axes handle        
    h.plotAxes = axes('Parent', h.container1, ...
                 'HandleVisibility','callback', ...
                 'Units', 'normalized', ...
                 'Position',[.06 0.27 0.85 0.65]);
    plotHandle=h.plotAxes;
    %slider
    h.slider = uicontrol(h.containerX,'Style','slider',...
                'Max',length(x)-dx,'Min',1,'Value',1,...%max(x)-dx,'Min',min(x),'Value',min(x),...
                'SliderStep',[sldStep 0.2],...
                'Units', 'normalized', ...
                'Position',[.105 .6 .788 .3],...
                'BackgroundColor','white',...
                'Callback', @hSlider_Callback);
    %Label: min
    h.txtWinMin=uicontrol(h.containerX,'Style','edit',...
                'String',min(x),...%min(x),...
                'Value',1,...
                'Units', 'normalized', ...
                'Position',[.003 .6 .1 .3],...
                'HorizontalAlignment','center');
    %Label: max
    h.txtWinMax=uicontrol(h.containerX,'Style','edit',...
                'String',max(x),...%min(x)+dx,...
                'Value',dx,...
                'Units', 'normalized', ...
                'Position',[.895 .6 .1 .3],...
                'HorizontalAlignment','center');

            
    %textBox: current position
    h.txtWinCurrent=uicontrol(h.containerX,'Style','edit',...
                'String',x(1),...
                'Units', 'normalized', ...
                'Position',[.793 .2 .1 .3],...
                'Enable','inactive');
    %Lable: current position
    h.lblWinCurrent=uicontrol(h.containerX,'Style','text',...
                'String','Current Position >> ',...
                'Units', 'normalized', ...
                'Position',[.661 .13 .13 .3],...
                'HorizontalAlignment','right');


    %Label: window size
    h.lblWinSize=uicontrol(h.containerX,'Style','text',...
                'String',' << Window Size (%)',...
                'Units', 'normalized', ...
                'Position',[.207 .13 .15 .3],...
                'HorizontalAlignment','left');
    %Button: reduce window size
    h.btnWinSizeDown=uicontrol(h.containerX,'Style','pushbutton',...
                'String','<',...
                'Units', 'normalized', ...
                'Position',[.105 .2 .02 .3],...
                'Callback',@btnWinSizeDown_Callback);
    %Textbox: window size
    h.txtWinSize=uicontrol(h.containerX,'Style','edit',...
                'String','',...
                'Units', 'normalized', ...
                'Value', initialScale,...
                'String',initialScale,...
                'Visible','on',...
                'Position',[.125 .2 .06 .3],...
                'BackgroundColor','white',...
                'Callback', @txtWinSize_Callback);
    %Button: increase window size
    h.btnWinSizeUp=uicontrol(h.containerX,'Style','pushbutton',...
                'String','>',...
                'Units', 'normalized', ...
                'Position',[.185 .2 .02 .3],...
                'Callback', @btnWinSizeUp_Callback);
    %--------------------------------------------------
    %Textbox: Lower y limit
    h.txtYlimit1=uicontrol(h.container1,'Style','edit',...
                'String',num2str(min(y)),...
                'Units', 'normalized', ...
                'Value', min(y),...
                'Visible','on',...
                'Position',[.915 .27 .065 .034],...
                'BackgroundColor','white',...
                'Callback', @txtYlimit1_Callback);
    %Textbox: Upper y limit
    h.txtYlimit2=uicontrol(h.container1,'Style','edit',...
                'String',num2str(max(y)),...
                'Units', 'normalized', ...
                'Value', max(y),...
                'Visible','on',...
                'Position',[.915 .886 .065 .034],...
                'BackgroundColor','white',...
                'Callback',@txtYlimit2_Callback);
    %btn: auto scale y limit
    h.btnYlimitAuto=uicontrol(h.container1,'Style','pushbutton',...
                'String','Auto Scale',...
                'Units', 'normalized', ...
                'Position',[.915 .578 .065 .034],...
                'Callback', @btnYlimitAuto_Callback);
            
            
%%  Initialization tasks

    %PLOT DATA
    plot(h.plotAxes,x,y);
    xlabel(h.plotAxes,'x'),ylabel(h.plotAxes,'y');
    %set axes limits
    set(h.plotAxes,'xlim',[x(1) x(dx)])

%%  Callbacks for SPLOT

    function hSlider_Callback(hObject, eventdata)
    % Callback function run when the slider is moved
        set(h.slider,'value',ceil(get(h.slider,'value')))
        updatePreview();
    end

    function btnWinSizeUp_Callback(hObject, eventdata)
    % Callback function run when the window size button is pressed
        s=str2double(get(h.txtWinSize,'String'));
        if s < 99.99
            set(h.txtWinSize,'String',num2str(s+0.01))
        end
        txtWinSize_Callback();
    end

    function btnWinSizeDown_Callback(hObject, eventdata)
        s=str2double(get(h.txtWinSize,'String'));
        if s > 0.01
            set(h.txtWinSize,'String',num2str(s-0.01))
        end
        txtWinSize_Callback();
    end

    function txtWinSize_Callback(hObject, eventdata)
        % dx is the width of the axis 'window'
        sldStep = str2double(get(h.txtWinSize,'String'))/100;
        dx = floor(sldStep*length(x));%max(x);

        %change slider steps
        set(h.slider,'SliderStep',[sldStep 0.1]);
        updatePreview();
    end

    function txtYlimit1_Callback(hObject, eventdata)
    % Callback function run when the lower ylimit
    % textbox is changed
        updatePreview();
    end

    function txtYlimit2_Callback(hObject, eventdata)
    % Callback function run when the upper ylimit
    % textbox is changed
        updatePreview();
    end

    function btnYlimitAuto_Callback(hObject, eventdata)
    % Callback function run when the auto ylimit
    % btn is pressed
        x1=get(h.txtWinMin,'Value');
        x2=get(h.txtWinMax,'Value');
        set(h.txtYlimit1,'String',num2str(min(y(x1:x2))));
        set(h.txtYlimit2,'String',num2str(max(y(x1:x2))));
        updatePreview();
    end
%%  Utility functions for SPLOT

    function updatePreview
    %helper function that updates gui
        
        %get slider value
        sv=ceil(get(h.slider,'value'));
        %determine plot x axes limits
        if sv > (length(x)-dx)
            lim=[length(x)-dx length(x)];
        else
            lim=sv+[0 dx];
        end
        limX=[x(lim(1)) x(lim(2))];
        %set x axes limits
        set(h.plotAxes,'xlim',limX);
        %show current position
        set(h.txtWinCurrent,'String',num2str(x(sv)))
        %set min and max values, but not strings
        set(h.txtWinMax,'Value',lim(2));
        set(h.txtWinMin,'Value',lim(1));
        
        %get y Limit values
        y2=str2double(get(h.txtYlimit2,'String')); 
        y1=str2double(get(h.txtYlimit1,'String'));
        %verify y limits
        if (y2>y1) && ~isnan(y2) && ~isnan(y1)
            set(h.plotAxes,'ylim',[y1 y2]);
        else
            error('Invalid y limits')
        end
    end

%     function updatePreview
%     %helper function that updates gui
%         
%         %change axes current possition
%         sv=get(h.slider,'value');
%         %determine plot x axes limits
%         if sv>(max(x)-dx)
%             lim=[max(x)-dx max(x)];
%         else
%             lim=sv+[0 dx];
%         end
%         %set x axes limits
%         set(h.plotAxes,'xlim',lim);
%         %set min and max strings
%         set(h.txtWinMax,'String',num2str(lim(2)));
%         set(h.txtWinMin,'String',num2str(lim(1)));
%         
%         %get y Limit values
%         y2=str2double(get(h.txtYlimit2,'String')); 
%         y1=str2double(get(h.txtYlimit1,'String'));
%         %verify y limits
%         if (y2>y1) && ~isnan(y2) && ~isnan(y1)
%             set(h.plotAxes,'ylim',[y1 y2]);
%         else
%             error('Invalid y limits')
%         end
%     end
end