clear
%% INFO

% CHRISTIAN: WRITE DOCUMENTATION FOR THIS

% (1) is weak signal
% 

% steps for testing using the non RT method
% specify an audio recording



%% get the system running
load('Detector3\configSettings_alternate.mat')
% c, a struct, will hold the constants
c = configSettings_alternate.constants;

%% single channel detector tests
configSettings_alternate.constants.NUM_CHANNELS = 1;
system1 = DroneSystem(configSettings_alternate);
%% weak signal test(s)
disp('single channel weak signal test:')
filename = 'Sample Audio/Our Recordings/Scarlett 18i8/4 3-Audio-1, background noise.wav';
[audio, Fs] = audioread(filename);
audioFrameMatrix = frameSegment(audio,c.FRAME_SIZE);

failedDecisionIndexes = [];
correct = 1;
decisions = cell(size(audioFrameMatrix,2),1);
fluxes = zeros(1,size(audioFrameMatrix,2));
energies = zeros(1,size(audioFrameMatrix,2));
for i = 1:size(audioFrameMatrix,2)
    [decisions(i),curFlux,curEnergy] = system1.test(audioFrameMatrix(:,i));
    fluxes(i) = curFlux;
    energies(i) = curEnergy;
    if(decisions{i}~=correct)
        failedDecisionIndexes = [failedDecisionIndexes; i];
    end
end

if(~isempty(failedDecisionIndexes))
    disp(['Failed weak signal test at indicies: ', num2str(failedDecisionIndexes)]);
end
disp(['mean/max energy: ', num2str(mean(energies)),'/', num2str(max(energies))])

%% Drone test(s)
disp('single channel drone signal test:')
filename = '9 6-Audio, steady whistling.wav';
[audio, Fs] = audioread(filename);
audioFrameMatrix = frameSegment(audio,c.FRAME_SIZE);

decisions = cell(size(audioFrameMatrix,2),1);
fluxes = zeros(1,size(audioFrameMatrix,2));
energies = zeros(1,size(audioFrameMatrix,2));
for i = 1:size(audioFrameMatrix,2)
    [decisions(i),fluxes(i),energies(i)] = system1.test(audioFrameMatrix(:,i));
end
disp(['mean/max energy: ', num2str(mean(energies)),'/', num2str(max(energies))])
