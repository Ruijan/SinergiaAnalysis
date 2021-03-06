classdef SpectrogramDisplayer < handle
    properties
        boundaries = [-15 15],
    end
    methods
        function plotGrandAverage(obj, EEG, classes, psdProperties, channelLabels)
            global verbose;
            if verbose, disp('Plot Spectrogram'); end
            epochPSD = obj.normalizeEpochPSD(EEG, psdProperties);
            class1PSD = 10*log10(squeeze(median(epochPSD(:,EEG.labels == classes(1),:,:),2)));
            class2PSD = 10*log10(squeeze(median(epochPSD(:,EEG.labels == classes(2),:,:),2)));
            obj.plotSpectrogramForTwoClasses(class1PSD, class2PSD, psdProperties, channelLabels);
        end
        
        function epochPSD = normalizeEpochPSD(obj, EEG, psdProperties)
           epochPSD = reshape(EEG.psdEpochs,...
                EEG.epochs/EEG.trials,...
                EEG.trials,...
                length(psdProperties.frequencies),...
                EEG.nbChannels);
            for trial = 1:EEG.trials
                for epoch = 1:EEG.epochs/EEG.trials
                    epochPSD(epoch,trial,:,:) = ...
                        squeeze(epochPSD(epoch,trial,:,:))./...
                        squeeze(EEG.psdBaseline(trial,:,:));
                end
            end 
        end
        
        function plotSpectrogramForTwoClasses(obj, class1PSD, class2PSD, psdProperties, channelLabels, events, eventLabels, classLabels)
            diffClassPSD = class2PSD - class1PSD;
            figure('Name', ['Spectrogram ' classLabels{1}], 'WindowStyle', 'docked');
            obj.plotAllChannelsWithEvents(permute(class1PSD,[3,2,1]), psdProperties, channelLabels, events, eventLabels)
            figure('Name', ['Spectrogram ' classLabels{2}], 'WindowStyle', 'docked');
            obj.plotAllChannelsWithEvents(permute(class2PSD,[3,2,1]), psdProperties, channelLabels, events, eventLabels)
            figure('Name', 'Spectrogram Class difference', 'WindowStyle', 'docked');  
            obj.plotAllChannelsWithEvents(permute(diffClassPSD,[3,2,1]), psdProperties, channelLabels, events, eventLabels) 
        end

        function plotAllChannels(obj, allChannelPSD, properties, channelLabels)
            for channel = 1:length(channelLabels)
                obj.selectSubplotFromChannel(channel)
                obj.plot(allChannelPSD(:,:,channel), properties, channelLabels(channel));
                obj.displayTicksAndLabelForChannel(channel);
            end
            obj.plotColorBar();
        end
        
        function plotAllChannelsWithEvents(obj, allChannelPSD, properties, ...
                channelLabels, events, eventLabels)
            shortEventLabels = cell(length(eventLabels),1);
            for eventIndex = 1:length(eventLabels)
                currentLabel = eventLabels{eventIndex};
                shortEventLabels{eventIndex} = currentLabel(1);
            end
            for channel = 1:length(channelLabels)
                obj.selectSubplotFromChannel(channel)
                obj.plotWithEvents(allChannelPSD(:,:,channel), properties, ...
                    channelLabels(channel),events, shortEventLabels);
                currentPlot = gca;
                currentFigure = gcf;
                set(currentPlot,'ButtonDownFcn',@(~,~)SpectrogramDisplayer.plotSpectrogramInSeparateFigure(...
                    allChannelPSD(:,:,channel), ...
                    properties, ...
                    channelLabels{channel},...
                    events, ...
                    eventLabels, ...
                    currentFigure));
                obj.displayTicksAndLabelForChannel(channel);
                
            end
            obj.plotLegendInformation(eventLabels, shortEventLabels);
            obj.plotColorBar();
        end
    end
    methods(Static)
        function plotSpectrogramInSeparateFigure(channelPSD, properties, channelLabel, events, eventLabels, currentFigure)
            figure('Name', ['Average Spectrogram ' ...
                channelLabel], ...
                'WindowStyle', 'docked');
            SpectrogramDisplayer.plotWithEvents(...
                channelPSD, ...
                properties,...
                channelLabel,...
                events, ...
                eventLabels); 
            ylabel('Frequency (Hz)')
            xlabel('Times (s)')
            hold on;
            figure(currentFigure)
        end
        
        function plot(timeFrequenciesSeries, properties, channelLabel)
            im = imagesc('XData', properties.time, 'YData', properties.frequencies, 'CData', timeFrequenciesSeries);
            set(im,'hittest','off'); % so you can click on the Markers
            title(channelLabel);
            caxis([-5 5])
            xlim([min(properties.time) max(properties.time)])
            ylim([min(properties.frequencies) max(properties.frequencies)])
            line([0 0], [min(properties.frequencies) max(properties.frequencies)],'LineWidth',3);
            colormap jet;
            set(gca, 'FontSize', 20)
        end
        
        function plotWithEvents(timeFrequenciesSeries, properties, channelLabel, events, eventsLabel)
            SpectrogramDisplayer.plot(timeFrequenciesSeries', properties, channelLabel);
            SpectrogramDisplayer.plotEvents(events, eventsLabel, 'k', properties.frequencies);
        end
        
        function plotWithTwoSetsOfEvents(timeFrequenciesSeries, properties, ...
                channelLabel, eventSet1, eventSet2, labels)
            SpectrogramDisplayer.plotWithEvents(timeFrequenciesSeries, ...
                properties, channelLabel, eventSet1, labels);
            SpectrogramDisplayer.plotEvents(eventSet2, [], 'b', properties.frequencies)
        end

        function selectSubplotFromChannel(channel)
            if channel == 1
                subplot(4,5,3);
            else
                subplot(4,5,4+channel);
            end
        end
        
        function plotLegendInformation(labels, shortLabels)
            subplot(4,5,1);
            axis off
            xl = xlim;
            yl = ylim;
            for labelIndex = 1:length(labels)
                text(xl(1),yl(2)*(0.75 - (labelIndex-1)*0.5), [shortLabels{labelIndex} ' = ' labels{labelIndex}],'FontSize',25);
            end
            set(gca, 'FontSize', 15)
        end
        
        function plotColorBar()
            subplot(4,5,5);
            axis off
            xl = xlim;
            c = colorbar;
            c.Position(1) = (xl(2) + xl(1)) / 2 + 0.1 * 2; % centered
            c.Position(3) = (xl(2)-xl(1)) * 0.1; % width
            caxis([-5 5])
        end
        
        function plotEvents(events, labels, color, frequencies)
           for index = 1:length(events)
                line([events(index).start events(index).start],...
                    [min(frequencies) max(frequencies)*1.1], ...
                    'Linestyle','--','Color',color, 'LineWidth',3)
                line([events(index).stop events(index).stop],...
                    [min(frequencies) max(frequencies)*1.1], ...
                    'Linestyle','--','Color',color, 'LineWidth',3)
                if ~isempty(labels)
                    alignement = 'center';
                    testXPosition = (events(index).start + events(index).stop)/2;
                    text(testXPosition, max(frequencies)*0.9, labels{index},...
                        'HorizontalAlignment',alignement, 'FontSize', 20);
                end
            end 
        end

        function displayTicksAndLabelForChannel(channel)
            if channel == 1 || channel == 2 || channel == 7 || channel == 12
                ylabel('Frequency (Hz)') 
            else
                set(gca,'yticklabel',[])
            end
            if channel == 12 || channel == 13 || channel == 14 || channel == 15 || channel == 16
                xlabel('Times (s)')
            else
                set(gca,'xticklabel',[])
            end
        end
    end
end