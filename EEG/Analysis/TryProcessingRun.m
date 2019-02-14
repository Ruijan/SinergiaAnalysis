function [eegRun, psdAnalysis] = TryProcessingRun(pathToRun, progress, message, handles, savingProperties)
    windowSize          = 1; % s
    frequenciesToStudy  = 4:0.1:30; %Hz
    frequenciesToPlot   = [8 12; 12 16; 16 20; 20 28]; %Hz
    epochFrequency      = 16; % Hz
    events = struct(...
        'Start',781, ...
        'Baseline',786, ...
        'Flexion',782,...
        'Extension',784, ...
        'OldExtension',781, ...
        'Rest', 783);
    overlap         = windowSize - 1/epochFrequency; % s
    spatialFilter   = SpatialFilterFactory.createSpatialFilter('CAR', 16);
    psdProperties   = PSDProperties(windowSize, overlap, frequenciesToStudy, epochFrequency);
    psdAnalysis = struct('mvt', [], 'rest', [], 'spectMvt', [], 'spectRest', []);
    
    message{4} = 'Loading data';
    set(handles.log, 'String', message);
    handles.bar.update(progress.current + progress.step * 0);
    if savingProperties.shouldRecompute || ~exist([savingProperties.folder '/' savingProperties.precomputedFile])
        eegRun = EEGRunData();
        eegRun.load(pathToRun);
        
        message{4} = 'Computing PSD';
        set(handles.log, 'String', message);
        handles.bar.update(progress.current + progress.step * 0.2);
        eegRun.computePSDForAllChannels(psdProperties, spatialFilter);
    else
        eegRun = load([savingProperties.folder '/' savingProperties.precomputedFile]);
        eegRun = eegRun.obj;
    end
    
    message{4} = 'Computing grand average';
    set(handles.log, 'String', message);
    handles.bar.update(progress.current + progress.step * 0.6);

    eegRun.extractEvents(events);
    eegRun.extractNormalizePSDPerTrial();
    [gaMvt, ~, frequencies] = eegRun.getAveragedPSDForMovementPerTrial(events);
    [gaRest, ~, ~] = eegRun.getAveragedPSDForRestPerTrial(events);
    properties = struct('time', [], 'frequencies', []);
    [gaSpectroMvt, properties.time, properties.frequencies] = ...
        eegRun.getSpectrogramForMovementPerTrial(events);
    [gaSpectroRest, ~, ~] = eegRun.getSpectrogramForRestPerTrial(events);

    message{4} = 'Visualizing';
    set(handles.log, 'String', message);
    handles.bar.update(progress.current + progress.step * 0.8);

    if get(handles.topoplot, 'Value') == 1
        EEGDisplayer.topoplotPSDOfTwoClasses(mean(gaMvt,2), ...
            mean(gaRest,2), ...
            frequencies, ...
            frequenciesToPlot, ...
            eegRun.channelsData64, ...
            eegRun.labels)
    end
    if get(handles.spectrogram, 'Value') == 1
        baseline = eegRun.getSpecificEventTypeTimes(events.Baseline, events.Baseline,1);
        trialStart = eegRun.getSpecificEventTypeTimes(events.Baseline, events.Start,1);
        events = horzcat(baseline, trialStart);
        eventLabels = {'Baseline', 'Start'};
        SpectrogramDisplayer().plotSpectrogramForTwoClasses(...
            squeeze(mean(gaSpectroMvt,2)),...
            squeeze(mean(gaSpectroRest,2)), ...
            properties, ...
            {eegRun.channelsData.labels},...
            events,...
            eventLabels,...
            eegRun.labels);
    end
    if get(handles.discriminancyMap, 'Value') == 1
        displayer = EEGDisplayer();
        resolution = 10;
        averagedMvt = zeros(size(gaMvt,1),size(gaMvt,2), floor(size(gaMvt,3)/resolution));
        averagedRest = zeros(size(gaRest,1),size(gaRest,2), floor(size(gaRest,3)/resolution));
        for frequencyIndex = 1:size(averagedMvt,1)
            averagedMvt(:,:,frequencyIndex) = mean(gaMvt(:,:,(frequencyIndex-1)*resolution+1:frequencyIndex*resolution),3);
            averagedRest(:,:,frequencyIndex) = mean(gaRest(:,:,(frequencyIndex-1)*resolution+1:frequencyIndex*resolution),3);
        end
        reshapedgaMvt = reshape(averagedMvt, size(averagedMvt,1) * size(averagedMvt,3),  size(averagedMvt,2));
        reshapedgaRest = reshape(averagedRest, size(averagedRest,1) * size(averagedRest,3),  size(averagedRest,2));
        newData = horzcat(reshapedgaMvt, reshapedgaRest);

        labels = {};
        for i = 1:size(newData,2)
            if i < size(newData,2) / 2
                labels{end+1} = 'Movement';
            else
                labels{end+1} = 'Rest';
            end
        end
        [index,featureScore] = feature_rank(newData, labels');
        featureScore = featureScore(index);
        discriminancyMap = reshape(featureScore, [size(averagedMvt,1), size(averagedMvt,3)]);
        EEGDisplayer.plotPDiscriminancyMap(discriminancyMap, 4:1:size(averagedMvt,3)+4, {eegRun.channelsData.labels})
    end
    handles.bar.update(progress.current + progress.step * 1);
    psdAnalysis.mvt     = gaMvt;
    psdAnalysis.rest    = gaRest;
    psdAnalysis.spectMvt    = gaSpectroMvt;
    psdAnalysis.spectRest   = gaSpectroRest;
    if savingProperties.shouldSave && ~exist([savingProperties.folder '/' savingProperties.precomputedFile])
        eegRun.saveRun(savingProperties.folder, savingProperties.precomputedFile);
    end
end