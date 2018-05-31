function serial_sendmulator2()
% serial_sendmulator2: send a simulated 8-bit sign wave to the serial port.
%                      Data is sent one byte at a time. 
% Author: John Ramshur
%
% Note: To SPEED UP the program try sending more than one byte at a time.
%       For example: fwrite(s,y(:),'uint8'); %send entire waveform

%% SIMULATION PARAMETERS

    nSim = 100; % number of times to send simulated waveform
    pTime = 0.001; % time in sec to pause between each data point. 
                   % Smaller number equals faster data rate.
                   % There is a limit.

    % Port Parameters
    serialPort='COM31'; % com port
    baudRate=115200;
    bufferSize=5000;   % input serial buffer size

    %% CREATE SERIAL PORT OBJECT
    % check to see if 'serialPort' is already open
    objs=instrfind; %get objects
    if ~isempty(objs);           
        i=strcmp(objs.Name,['Serial-' serialPort]) ...
            & strcmp(objs.status,'open'); %find open port with same port name
        if any(i); fclose(objs(i)); end; % close matching port if found
    end;

    % Create the serial object    
    s = serial(serialPort);
    set(s,'BaudRate',baudRate,'Parity','None',...
        'Databits',8,'InputBufferSize',bufferSize);
    fopen(s);

    %% CREATE SIMULATION DATA

    y = 0.5 + sin(0:.1:2*pi)./2; %create sine wave with values between 0 and 1
    y = floor(y.*255); % scale data between 0 and 255
    ny = length(y);

    %% SEND DATA TO PORT

    i = 1; % waveform index
    n = 1; % simulation count (each incriment = 1 full waveform)
    
    fprintf('\nSimulation will occur %d time(s).',nSim);
    fprintf('\nTotal data points = %d',nSim*ny);
    fprintf('\nPress "Ctl+c" to stop at any time.');
    fprintf('\n  Sim Count: ')
 
    while (n<=nSim)
        
        fwrite(s,y(i),'uint8'); % Send data to serial port

        if (i>=ny)
            i=1;
            fprintf('%d ',n); % update user of progress
            n=n+1;           
        else
            i=i+1;
        end

        pause(pTime)

    end

    %% CLEAN UP

    fclose(s);
    fprintf('\n');
end

