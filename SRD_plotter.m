function SRD_plotter(flagRMS, RMSWin)
% SRD Plotter
% This functions plots traces recorded from the SRD for publication
% purposes. All traces found within the chosen folder are plotted.

    if isempty(flagRMS)
       flagRMS=1; % default option is to display windowed rms signal
    end
    if isempty(RMSWin)
        RMSWin=50; % set default RMS window size
    end

    % get list of files
    fp=what;
    fp=fp.path;
    fp = uigetdir(fp, ...
            'Select directory containing exported Igor text files:');
        
    if (all(fp)~=0) && (~exist(fp,'dir'))
        disp([fp ' not a valth directory.'])        
        return;
    end

    % get list of files
    fileList = dir(fullfile(fp,'*.csv')); %get list of files            
    fileList(any([fileList.isdir],1))=[]; %remove any folder/dir from the list        
    nfiles=size(fileList,1); %number of files    
    strList=cell(nfiles,1);  %initilize cell array of strings for completed file list

    for f=1:nfiles %loop through files to create a proper cell array
        strList{f}=fullfile(fp,fileList(f).name);
    end    
    
    
    % loop though all files
    for i=1:nfiles
        tmp=readSRD(strList{i});
        n=size(tmp.data,1);
        if i==1
            nmax=n; %for not we will truncate all files to this length
        end
        if n>nmax %if data too long...truncate
            SRD(:,i)=tmp.data(1:nmax);
        elseif n<nmax % if data too short pad with zeros
            SRD(1:n,i)=tmp.data;
            SRD(n+1:nmax)=zeros(nmax-n,1);
        else % else do nothing
            SRD(:,i)=tmp.data;
        end
        rmsSRD(:,i) = fastrms(SRD(:,i),RMSWin,[],1);    
    end

    rate=15000;
    t=0:1/rate:(nmax-1)/rate;
    t=t*1000; %convert to ms
    
    % Plot data
    f=figure;
    hLines = plot(t,SRD,'Color','b'); hold on;
    
    %RMS
    if flagRMS
        hRMS = plot(t,mean(rmsSRD,2),'r','linewidth',2); hold off;

        %Setup group legend
        hGroup = hggroup;
        set(hLines,'Parent',hGroup);
        set(hRMS,'Parent',gca);
        set(get(get(hGroup,'Annotation'),'LegendInformation'),...
            'IconDisplayStyle','on');
         uistack(hRMS, 'top'); %move rms to top
    end
    
    % setup figure  
    xlim([0 100]); ylim([-150 150]);
    hTitle=title('Cortico-Cortical Evoked Responses');
    hXlabel=xlabel('Time (ms)'); 
    hYlabel=ylabel('Amplitude (\muV)');
    
    if flagRMS
        hLegend=legend([num2str(nfiles) ' Traces'],'Mean RMS');
    else
        hLegend=legend([num2str(nfiles) ' Traces']);
    end

    % adjust font and axes properties
    set(f,'position',[100 100 800 300]);
    set(gca,'FontName', 'Arial' );
    set([hTitle, hXlabel, hYlabel],'FontName', 'Arial');
    set([hLegend, gca],'FontSize',8);
    set([hXlabel, hYlabel],'FontSize', 10);
    set( [hTitle]        , ...
        'FontSize'   , 12          , ...
        'FontWeight' , 'bold'      );
    set(gca, ...
      'Box'         , 'on'     , ...
      'TickDir'     , 'in'     , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'YGrid'       , 'off'      , ...
      'XGrid'       , 'off'      , ...
      'XColor'      , [.3 .3 .3], ...
      'YColor'      , [.3 .3 .3], ...
      'LineWidth'   , 1         ,...
      'gridlinestyle',':',      ...
      'gridcolor', [.8 .8 .8]   );
    
end