function event_data = load_eventstream(filename, mirrorX, mirrorY)
% td_data = load_eventstream(filename, mirrorX=false, mirrorY=false)
%
% loads DVS events (but not grey level events) from .es files that have been recorded with version 2 of the ES format.

if ~exist('mirrorX','var')
    mirrorX = false;
end
if ~exist('mirrorY','var')
    mirrorY = false;
end

f=fopen(filename);

header = fgets(f, 12);
versions = fread(f, 3);
type = fread(f, 1);

width = fread(f,1) + bitshift(fread(f,1), 8);
height = fread(f,1) + bitshift(fread(f,1), 8);
disp(['width: ', int2str(width), ', height: ', int2str(height)])

if type ~= 2
    disp 'unsupported version'
    fclose(f);
    return;
end

data = fread(f, 'uint8');
fclose(f);

%arraySize = round(length(data)/3) + 1; %if all bytes were event bytes and no overflow or reset bytes
%events = zeros(1, arraySize);
index = 1;
pmask = bin2dec('00000010');
thresholdmask = bin2dec('00000001');

overflow = 0;
skiploop = 0;
t = 0;

max = length(data);
for i = 1:max
    if skiploop > 0
        skiploop = skiploop - 1;
        continue;
    end
    
    %b = bitshift(data(i), -2, 'uint8');
    
    if bitand(data(i), 252) == 252
        if data(i) == 252 %reset byte
            continue;
        else
            overflow = overflow + bitand(data(i), 3);
        end
    else
        % skip events that encode grey levels
        if i < (max - 3) && bitand(data(i), thresholdmask) ~= thresholdmask
            t = t + bitshift(data(i), -2) + overflow * 63;
            event_data.ts(index) = t;
            overflow = 0;

            x =  data(i+1) + bitshift(data(i+2), 8);
            event_data.x(index) = x;

            y = data(i+3) + bitshift(data(i+4), 8);
            event_data.y(index) = y;

            if bitand(data(i), pmask) == pmask
                p = 1;
            else
                p = 0;
            end
            event_data.p(index) = p;

            index = index + 1;
        else
            t = t + bitshift(data(i), -2);
        end
        skiploop = 4;
    end
end

if mirrorX
    event_data.x = (width - 1) - event_data.x;
end
if mirrorY
    event_data.y = (height - 1) - event_data.y;
end

end