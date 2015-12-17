% post processing correlation
load('CorrTemplates_44100Hz.mat')
% CORRELATION_TEMPLATE = Templates_DJIPhantom3.singleSpike;
WINDOW_SIZE = 4096;
LOWEST_FREQ_BIN = 5;
HIGHEST_FREQ_BIN = 100;

audioClip = audioread('Sample Audio/13 Internet_DJIPhantom3.wav');
%audioClip = audioread('Sample Audio/cheapDrone_50feet.wav');
%audioClip = audioread('Sample Audio/Phantom 3 (#2).wav');

figure();
[S,F,T] = spectrogram(audioClip,WINDOW_SIZE,WINDOW_SIZE/2);
S = S(LOWEST_FREQ_BIN:HIGHEST_FREQ_BIN,:);
subplot(3,1,1)
%surf(FIndices,TIndicies,abs(S_db), 'EdgeColor','none')
surf(10.*log10(abs(S')), 'EdgeColor','none')
title(['Spectrogram, window size: ', num2str(WINDOW_SIZE)])

% threshold out little signals (so we don't end up blowing up something
% insignificant)



% local normalization (divide local sections by their sum)



% smooth things out in frequency (averaging filter with length of 4)
S_smooth = zeros(size(S,1),size(S,2));
for i = 1:size(S,2)
    S_smooth(:,i) = filter2(1/4*ones(4,1), abs(S(:,i)));
    %S_smooth(:,i) = abs(S(:,i));
end
%subplot(3,1,2)
%surf(10.*log10(S_smooth'), 'EdgeColor','none')

% smooth things out in time
for i = 1:size(S,1)
    S_smooth(i,:) = medfilt1(S_smooth(i,:),16);
    %S_smooth(i,:) = filter2(1/3*ones(1,3),S_smooth(i,:));
end
subplot(3,1,2)
surf(10.*log10(S_smooth'), 'EdgeColor','none')

% correlation and binary image generation
CORRELATION_THRESHOLD = 0;
subplot(3,1,3)
correlationResult = normxcorr2(template,S_smooth);
correlationResult(correlationResult<CORRELATION_THRESHOLD) = 0;
correlationResult(correlationResult>0) = 1;
% correlationResult = bwulterode(correlationResult); % erosion is difficult
surf(double(correlationResult)', 'EdgeColor','none')

% I need to come up with a good way to threshold
% look at more data and determine the best way to do this
% taking the local mean and subtracting by it would work for a stationary
% DJI 3


% think about correlating a 2D peak kernal with a small chunk of a
% spectrogram




