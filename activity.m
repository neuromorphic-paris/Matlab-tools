function events = activity(recording, timeconst, growconst, splitOnAndOffActivity, type)
%ACTIVITY Summary of this function goes here
%   Detailed explanation goes here
if ~exist('growconst', 'var')
    growconst = 1;
end
if ~exist('splitOnAndOffActivity','var')
    splitOnAndOffActivity = true;
end
if ~exist('type', 'var')
    type  = 'exponential';
end

events = recording; 

if ~splitOnAndOffActivity
    events.activity = zeros(1, length(recording.ts));
    events.activity(1) = 1;
    for i = 2:length(recording.ts)
        events.activity(i) = events.activity(i-1) * exp(-(events.ts(i) - events.ts(i-1)) / timeconst) + growconst;
    end
elseif splitOnAndOffActivity && strcmp(type, 'exponential') % two activities for ON and OFF events respectively
    events.activityOn = zeros(1, length(recording.ts));
    events.activityOff = zeros(1, length(recording.ts));
    [lastOnIndex, lastOffIndex] = deal(1);
    for i = 1:length(recording.ts)
        if events.p(i) == 1
            events.activityOn(i) = events.activityOn(lastOnIndex) * exp(-(events.ts(i) - events.ts(lastOnIndex)) / timeconst) + growconst;
            lastOnIndex = i;
        else
            events.activityOff(i) = events.activityOff(lastOffIndex) * exp(-(events.ts(i) - events.ts(lastOffIndex)) / timeconst) + growconst;
            lastOffIndex = i;
        end
    end
    events.activityOn(events.activityOn == 0) = NaN;
    events.activityOff(events.activityOff == 0) = NaN;
elseif splitOnAndOffActivity && strcmp(type, 'linear')
    events.activityOn = nan(1, length(recording.ts));
    events.activityOff = nan(1, length(recording.ts));
    [lastOnIndex, lastOffIndex] = deal(0);
    for i = 1:length(recording.ts)
        if events.p(i) == 1 && lastOnIndex == 0
            events.activityOn(i) = growconst;
            lastOnIndex = i;
        elseif events.p(i) == 1
            value = -((events.ts(i) - events.ts(lastOnIndex)) / timeconst)  + events.activityOn(lastOnIndex) + growconst;
            if value < 0
                events.activityOn(i) = 0;
            else
                events.activityOn(i) = value;
            end
            lastOnIndex = i;
        elseif events.p(i) == 0 && lastOffIndex == 0
            events.activityOff(i) = growconst;
            lastOffIndex = i;
        elseif events.p(i) == 0
            value = -((events.ts(i) - events.ts(lastOffIndex)) / timeconst) + events.activityOff(lastOffIndex) + growconst;
            if value < 0
                events.activityOff(i) = 0;
            else
                events.activityOff(i) = value;
            end
            lastOffIndex = i;
        end
    end
end