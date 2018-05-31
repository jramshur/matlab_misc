function printAllFigures(layout)
%Prints all figures

%INPUT PARAMERTER:
%layout (optional): sets the print/page layout
%   layout = 'p' or 'portrait' for portrait prints
%   all other values print in landscape.

if nargin<1
    layout='l';
end

figH=get(0,'children'); %get handles for all figs
if isempty(figH) % if no figures
    disp('No figures to print!');
else
    for i=1:length(figH)
        figure(figH(i));
        if strcmp(layout,'p') || strcmp(layout,'portrait')
            orient portrait;
        else
            orient landscape;
        end
        margin = .25; % may need to be larger depending on PaperUnits
pSize = get(gcf, 'PaperSize');
ppos(1) = margin;
ppos(2) = margin;
ppos(3) = pSize(1) - 2*margin;
ppos(4) = pSize(2) - 2*margin;
set(gcf, 'PaperPosition', ppos);
        print(figH(i));
    end
end