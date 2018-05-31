function detectFileAndPlot(dirName)
%% detectFileAndPlot(dirName): Function that monitors a directory for new files.
%% When a new file is detected the file is read and data within it is plotted.

  period = 1; %seconds between directory checks
  timeout = 2000; %seconds before function termination

  dirName=uigetdir('C:\Users\John\Desktop\filterresponse\'); % get dir path
  if dirName==0; exit; end; % check returned dir

  dirLength = length(dir(fullfile(dirName,'*.csv')));
  t = timer('TimerFcn', {@timerCallback, dirName, dirLength}, 'Period', period,'TaskstoExecute', uint8(timeout/period), 'executionmode', 'fixedrate');
  start(t) % start timer
    f=figure; % create empty figure
    clear;
end

%% calback for timer. This is run when the timer hits "period"
function timerCallback(src, eventdata, dirName, dirLength)
  persistent my_dirLength;
  persistent my_beginFlag;
  if isempty(my_beginFlag)
        my_dirLength = dirLength;
        my_beginFlag = 0;
  end
  if length(dir(fullfile(dirName,'*.csv'))) > my_dirLength % if num of files has increased
      disp('A new file is available.')
      my_dirLength = length(dir(fullfile(dirName,'*.csv')));

      pause(0.1); %pause, maybe this can prevent me from reading in-progress files
      d=dir(fullfile(dirName,'*.csv')); % get list of csv files
      dates=[d.datenum]; % get dates from file list
      [~,newestIndex]=max(dates); % get newest date index
      srd_quickread(fullfile(dirName,d(newestIndex).name),3); % read newest file
  else
      disp('No new files.  Use "delete(timerfind)" to stop and clear timers.')
  end
end


function srd=srd_quickread(fn,minDist)
% fxn to quickly import a selected SRD data file
% and get mean signal frquency and magnitude

    % Parameters
    rate=15000;     % sample rate (Hz)
    dt=1/rate;      % dt (s)
    %cfactor=0.38;   % conversion factor for ADC unit to uV
    cfactor=1;

    % Import data
    data=importdata(fn,',',7);
    data=data.data(:,1)*cfactor;

    %data=smooth(data,5);

    % find peak 2 peak magnitude
    %[u_pks u_loc]  = findpeaks(data,'minpeakdistance',10); %find upper peaks
    %[l_pks l_loc]  = findpeaks(-data,'minpeakdistance',10); %find lower peaks
    [u_pks u_loc]  = findpeaks(data); %find upper peaks
    [l_pks l_loc]  = findpeaks(-data); %find lower peaks

    %filter peaks
    u_loc_orig=u_loc; %save original for later;
    i= ( abs(u_pks-mean(u_pks)) >= 3*std(u_pks) );
    u_pks(i)=[]; u_loc(i)=[]; %remove any >= 2std from mean
    i= ( abs(l_pks-mean(l_pks)) >= 3*std(l_pks) );
    l_pks(i)=[]; l_loc(i)=[]; %remove any >= 2std from mean
    mag = mean(u_pks) + mean(l_pks); % peak to peak mag


    % filter and compute freq
    dSamp=diff(u_loc_orig);
    i= ( abs(dSamp-mean(dSamp)) >= 3*std(dSamp) ); %find any diffs >3std from mean
    dSamp(i)=[];         %remove any >= 3std from mean
    meanf=1/mean(dSamp*dt);

    %outputs
    srd.f=meanf;
    srd.mag=mag;
    srd.max=max(u_pks);
    srd.min=min(-l_pks);
    srd.upk=u_pks; srd.uloc=u_loc;
    srd.lpk=-l_pks; srd.lloc=l_loc;
    srd.data=data;

    %reduce data for plotting
    n=20; %keep <20 peaks
    if length(srd.upk) > length(srd.lpk)
        l=length(srd.lpk); %number of cycles, choose lowest
    else
        l=length(srd.upk); %number of cycles
    end

    if l>20 %if more than 20 pks
        i=20;
    else
        i=l; %else i=last peak index
    end
    N=max([srd.uloc(i) srd.lloc(i)]); %get max sample number to use

    % plot data
    plot(data(1:N));
    hold on; plot(srd.uloc(1:i),srd.upk(1:i),'ro',srd.lloc(1:i),srd.lpk(1:i),'ro'); hold off;
    title(sprintf('F = %.2f || Mag = %.2f || Max = %.1f || Min = %.1f',srd.f,srd.mag,srd.max,srd.min))
    %text(0.1,0.9,['f=' num2str(srd.f)],'units','normalized')
    %text(0.1,0.85,['mag=' num2str(srd.mag)],'units','normalized')
    %text(0.1,0.8,['max=' num2str(srd.max)],'units','normalized')
    %text(0.1,0.75,['min=' num2str(srd.min)],'units','normalized')
    ylabel('Amp (uV)');
    xlabel('Time (samples)');
end
