function serialPortPlot2()
% serialPortPlot2: This function opens the serial port, waits for data, and plots it.
%
% Instructions: Setup the parameters, start the function, each time data is
% detected in the buffer it is plotted. Choose the appropriate buffer size
% and delay
%
% Author: John Ramshur


    % Port Parameters
    serialPort='COM10'; % com port
    baudRate=500000;
    bufferSize=1000;   % input serial buffer size

    loopDelay = .1; % time (s) to delay before checking for new data at port buffer

    % display parameters
    sampleRate=10000;
    bitRes=8;       %8 bit resolution
    maxRange=1.024; %2*vref
    minRange=0;
    offset=0;       %-2*.55; % vdda/2
    buffThresh=0.9; %don't read and plot data until buffer is at least to
                    %threshold percentage (buffThresh). 0.9 is 90 percent

    dropNSamples=0; % number of samples to drop from begining of data.
                     % This is useful beause the reset button on the PSoC
                     % dev board can cause some spikes of zero value.


    % check for open serial ports and close them
    objs=instrfind;
    if ~isempty(objs); fclose(instrfind); end;


    % Create the serial object
    s = serial(serialPort);
    set(s,'BaudRate',baudRate,'Parity','None',...
        'Databits',8,'InputBufferSize',bufferSize);
    fopen(s);

    %give user instructions
    disp('Press Ctrl+c from MATLAB to exit the loop. Then, close any serial ports using fclose(instrfind).')

    figure; drawnow; %creat a figure and "draw it now"

    i=1;
    while(1)

        if s.BytesAvailable > buffThresh*bufferSize %if buffer is 90% full
            out = fread(s,s.BytesAvailable,'uint8'); %get data
            if dropNSamples > 0
                out=out(dropNSamples:end); % remove first n samples.
            end
            %v=((maxRange-minRange)/2^bitRes).*out+offset; %convert to voltage
            v=out;
            plot(v)
            title(sprintf('Bits used: %d, P-P: %.2f V , Max: %.2f V , Min: %.2f V, Mean: %.2f V', ...
                range(out),range(v),max(v),min(v),mean(v)))
            xlabel('Sample Number')
            ylabel('Voltage')
        end

        pause(loopDelay);
        fprintf('.');
        i=i+1; if rem(i,50)==0; fprintf('\n'); end;
    end

end
