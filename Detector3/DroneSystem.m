classdef DroneSystem
    %DRONESYSTEM This class builds up a drone system
    %   Detailed explanation goes here
    
    properties
        % c holds constants
        c;
        % initialize detector with a placeholder so that it can be made
        % into an array of detector objects later on
        detectors = Detector();
        localizer;
        audioRecorder;
        testVariable;
        F_AXIS;
    end
    
    methods
        function DS = DroneSystem(configSettings)
            DS.c = configSettings.constants;
            
            % initialize one detector for each channel
            for i = 1:DS.c.NUM_CHANNELS
                DS.detectors(i) = Detector(configSettings);
            end
            
            DS.audioRecorder = dsp.AudioRecorder('SamplesPerFrame', ...
                DS.c.FRAME_SIZE,'SampleRate',DS.c.Fs,'DeviceName', ...
                configSettings.audioDriver,'NumChannels', ...
                DS.c.NUM_CHANNELS);
            
            DS.testVariable = zeros(2049,1);
            DS.F_AXIS = linspace(0,DS.c.Fs/2,DS.c.WINDOW_SIZE/2+1);
        end
        
        % consider trying to make an event called stop
        
        function start(DS)
            % setup the live plots
            decisions = {'1'; '2'; '3'; '4'};
            
            [hFig, hp, ha, hTextBox] = DS.figureSetup(decisions); %#ok<*ASGLU>
            energies = zeros(10,1);
            fluxes = zeros(10,1);
            spectra = zeros(10, DS.c.WINDOW_SIZE/2+1);
            
            % MAIN LOOP
            while(1)
                audioFrame = step(DS.audioRecorder);
                for i = 1:DS.c.NUM_CHANNELS
                    decisions(i) = {DS.detectors(i).step(audioFrame(:,i))};
                    % decisions(i) = {};
                    stringOutput = [decisions{i}, ' E: ', ...
                        num2str(DS.detectors(i).getEnergy()), ' F: ', ...
                        num2str(DS.detectors(i).getFlux())];
                    set(hTextBox(i),'String',stringOutput);
                end
                energies = [DS.detectors(1).getEnergy; energies(1:(length(energies)-1))];
                fluxes = [DS.detectors(1).getFlux; fluxes(1:(length(energies)-1))];
                spectra = [DS.detectors(1).getPreviousSpectrum()'; spectra(1:(length(fluxes)-1),:)];
                
%                 set(hp(1),'YData',DS.detectors(1).getEnergy(),'XData',...
%                     DS.detectors(i).getFlux());
%                 set(hp(2),'YData',DS.detectors(1).getPreviousSpectrum());
                
                set(hp(1),'YData',energies,'XData', fluxes);
                set(hp(2),'XData',DS.F_AXIS,'YData',DS.detectors(1).getPreviousSpectrum());

                drawnow;
                DS.testVariable = DS.detectors(1).getPreviousSpectrum();
                
            end
        end
        
        function [decisionNums,fluxes,energies] = test(DS,singleAudioFrame)
            %TEST take a single audio frame and make a decision
            %   This function is meant to be called when there is a bunch
            %   of recorded data that the system is to be tested with.
            decisions = cell(DS.c.NUM_CHANNELS,1);
            decisionNums = zeros(DS.c.NUM_CHANNELS,1);
            fluxes = zeros(DS.c.NUM_CHANNELS,1);
            energies = zeros(DS.c.NUM_CHANNELS,1);
            for i = 1:DS.c.NUM_CHANNELS
                decisions(i) = {DS.detectors(i).step(singleAudioFrame(:,i))};
                decisionNumbers(i) = DS.classStringToNum(decisions(i));
                fluxes(i) = DS.detectors(i).getFlux();
                energies(i) = DS.detectors(i).getEnergy();
            end
            decisionNums = {decisionNumbers};
        end
        
        function localizerTest(DS,A1,A2,A3,A4)
            DS.localizer.direction(A1,A2,A3,A4);
        end
        
        function [hFig, hp, ha, hTextBox] = figureSetup(DS, decisions)
        %FIGURESETUP a function used to setup a figure for testing purposes
            hFig = figure();
            subplot(2,1,1);
            hp(1) = plot(1,1,'O');
            axis manual
            ha(1) = gca;
            set(ha(1),'YLimMode','manual')
%             set(ha(1),'YLim',[0 1000],'YScale','log','XLim',[0 1], ...
%                 'XScale','log')
            
            % this is a line of great interest when calibrating with the
            % hardware
            set(ha(1),'YLim',[0 1000],'XLim',[0 0.02])
            
            title('Feature space')
            subplot(2,1,2);
            hp(2) = plot(DS.F_AXIS,zeros(1,DS.c.WINDOW_SIZE/2+1));
            ha(2) = gca;
            set(ha(2),'YLimMode','manual')
            set(ha(2),'YLim',[0 2],'XLim',[150 20E3])
            set(ha(2),'Xscale','log')
            title('Current spectrum')
            
            % text boxes for displaying the output of each detector
            % (and information relevant to testing)
            for i = 1:DS.c.NUM_CHANNELS
                hTextBox(i) = uicontrol('style','text');
                set(hTextBox(i),'String',decisions(i));
                set(hTextBox(i),'Position',[0 30*i 300 25])
            end
        end
        
        function calibration(DS)
            
        end
        
        function classNum = classStringToNum(DS,classString)
            if(strcmp('weak signal',classString))
                classNum = 1;
                return;
            elseif(strcmp('highly non-stationary signal',classString))
                classNum = 2;
                return;
            elseif(strcmp('non-drone oscillator signal',classString))
                classNum = 3;
                return;
            elseif(strcmp('drone signal',classString))
                classNum = 4;
                return;
            else
                warning('class string input does not match existing strings')
                classNum = -1;
            end
        end
        
    end
    
end