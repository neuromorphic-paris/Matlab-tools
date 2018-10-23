function events = shannonise(recording, timeconst, timeStep)
arrayLength = floor((recording.ts(end)-recording.ts(1))/timeStep);

events.activityOn = zeros(1, arrayLength+1);
events.activityOff = zeros(1, arrayLength+1);

factor = exp(-timeStep/timeconst);
starttime = recording.ts(end) - arrayLength * timeStep;
returnTimestamps = linspace(starttime, recording.ts(end), arrayLength+1);

% ON
tOn = recording.ts(recording.p == 1);
recording.activityOn = recording.activityOn(recording.p == 1);
i = 1;
while returnTimestamps(i) < tOn(1)
    events.activityOn(i) = (recording.activityOn(1)-1)/exp(-(tOn(1)-starttime)/timeconst);
    i = i + 1;
end
for j = 1:length(tOn)
    regularTS = tOn(j);

    while regularTS > starttime + (i+1) * timeStep
        if i == 1
            events.activityOn(i) = recording.activityOn(j-1) * exp(-(starttime - tOn(j-1))/timeconst);
        else
            events.activityOn(i) = events.activityOn(i-1) * factor;
        end
        i = i + 1; 
    end
    
    scaledTS = starttime + (i-1) * timeStep;
    if scaledTS > regularTS
        continue
    elseif scaledTS == regularTS
        events.activityOn(i) = recording.activityOn(j);
        i = i + 1;
    else
        events.activityOn(i) = recording.activityOn(j-1) * exp(-(scaledTS - tOn(j-1))/timeconst);
        i = i + 1;
    end
end
while i <= arrayLength + 1 && returnTimestamps(i) > tOn(end)
    events.activityOn(i) = recording.activityOn(end) * exp(-((starttime + i*timeStep) - tOn(end))/timeconst);
    i = i + 1;
end
        
% OFF
tOff = recording.ts(recording.p == 0);
recording.activityOff = recording.activityOff(recording.p == 0);
i = 1;
while returnTimestamps(i) < tOff(1)
    events.activityOff(i) = (recording.activityOff(1)-1)/exp(-(tOff(1)-starttime)/timeconst);
    i = i + 1;
end
for j = 1:length(tOff)
    regularTS = tOff(j);

    while regularTS > starttime + (i+1) * timeStep
        if i == 1
            events.activityOff(i) = recording.activityOff(j-1) * exp(-(starttime - tOff(j-1))/timeconst);
        else
            events.activityOff(i) = events.activityOff(i-1) * factor;
        end
        i = i + 1;
    end
    
    scaledTS = starttime + (i-1) * timeStep;
    if scaledTS > regularTS
        continue
    elseif scaledTS == regularTS
        events.activityOff(i) = recording.activityOff(j);
        i = i + 1;
    else
        events.activityOff(i) = recording.activityOff(j-1) * exp(-(scaledTS - tOff(j-1))/timeconst);
        i = i + 1;
    end
end
while i <= arrayLength + 1 && returnTimestamps(i) > tOff(end)
    events.activityOff(i) = recording.activityOff(end) * exp(-((starttime + i*timeStep) - tOff(end))/timeconst);
    i = i + 1;
end
events.ts = returnTimestamps;
end