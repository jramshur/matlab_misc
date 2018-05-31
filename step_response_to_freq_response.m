% Compute Freq Response from Step Response Data

%% Parameters
rate=15000;     % sample rate (Hz)
dt=1/rate;      % dt (s)
fH=1000;        % high cutoff freq (Hz)
fL=250;         % low cutoff freq (Hz)
dsp_fL=318;       % low cutoff for dap hpf (0=disabled)

%% Import data

fn='stepresponse2.txt';
stepResponse=importdata(fn,',',5);
stepResponse=stepResponse.data(:,1);
N = length(stepResponse);
time=[0:dt:dt*(N-1)]';

%% plot
%figure;
%subplot(211); plot (time,stepResponse)

%% compute impulse response
ImpulseResponse = diff(stepResponse)./dt; 
time2 = time(1:end-1); 
%subplot(212); 
%plot(time2,ImpulseResponse./max(range(ImpulseResponse))) % plot normalized imp response...not sure if normalization is correct or nesseccary 

%% COMPUTE EXPERIMENTAL FREQ RESPONSE
Q = ceil((N+1)/2);
magExp = abs(fft(ImpulseResponse)*dt); %compute magnitude response
magExp = magExp(1:Q);   %only keep half
magExp=magExp./max(magExp);
magExp=mag2db(magExp);    % convert to DB and normalize to max, not sure if normalize is correct
fExp = [0:N-2]'/(N*dt); % create freq data
fExp=fExp(1:Q); %keep half


%% COMPUTE IDEAL FREQ RESPONSE
fIdeal = logspace(log10(0.1), log10(100e3), 50); %create freq data
[gainIdeal, phaseIdeal] = ideal_transfer_function(fIdeal, fL, fH, dsp_fL); %compute gain and phase
fIdeal=fIdeal'; gainIdeal=gainIdeal'; phaseIdeal=phaseIdeal';

%% PLOT MAG RESPONSES
figure; 
subplot(211);
semilogx(fIdeal, gainIdeal);
hold on;
semilogx(fExp,magExp,'r')

subplot(212);
semilogx(fIdeal, phaseIdeal);

%% draw filter cutoffs for gain
subplot(211);
line([fL fL],[-100 10],'LineStyle',':','color','k'); %draw filter cutoff
line([fH fH],[-100 10],'LineStyle',':','color','k'); %draw filter cutoff
line([10 100000],[-3 -3],'LineStyle',':','color','k'); %draw -3db line
% set some axis limits
ylim([-20 10]);
xlim([50 10000]);
legend('Ideal','Experimental')


%% draw filter cutoffs for phase
subplot(212); 
xlim([10 100000]);
line([fL fL],[-300 200],'LineStyle',':','color','k'); %draw filter cutoff
line([fH fH],[-300 200],'LineStyle',':','color','k'); %draw filter cutoff
 