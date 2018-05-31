function  fig2myaaimg(K)
% Generates antialias image of current fig using Myaa function from file exchange
% Then save it to a file

    if nargin<1; K=4; end

    set(gcf,'color','w'); %set(gcf,'color','none'); 
    disp('Processing image...');
    [f1, cdata] = myaa(K); % use myaa to create antialiased file
    close(f1);

    %get file name and path
    [fn fp fi]=uiputfile( ...
      {'*.png', 'PNG (*.png)';...
      '*.jpeg','JPEG (*.jpeg)';...
      '*.bmp','Bitmap (*.bmp)';...
      '*.tif','TIFF (*.tif)'},...
      'Save Figure As Anti-aliased Image'); 

    if ~fi; return; end %Check if filename was seleted...must select a file

    [a b ext]=fileparts(fn); %get file extension
    clear a b; % clear some data

    imwrite(cdata, fullfile(fp,fn), ext(2:end)); % write to file
    winopen(fullfile(fp,fn));   % open it for review

end

