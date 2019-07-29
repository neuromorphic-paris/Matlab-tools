function event_data = load_eventstream(filename, mirrorX, mirrorY)
% event_data = load_eventstream(filename, mirrorX=false, mirrorY=false)
%
% loads DVS and ATIS files (however no grey level events) from .es files that have been recorded with version 2 of the ES format.

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

if type == 2 %ATIS file
    data = fread(f, 'uint8');
    fclose(f);

    index = 1;
    pmask = bin2dec('00000010');
    thresholdmask = bin2dec('00000001');

    overflow = 0;
    skiploop = 0;
    t = 0;
    start_t = zeros(width, height);

    max = length(data);
    for i = 1:max
        if skiploop > 0
            skiploop = skiploop - 1;
            continue;
        end

        if bitand(data(i), 252) == 252
            if data(i) == 252 %reset byte
                continue;
            else
                overflow = overflow + bitand(data(i), 3);
            end
        else
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
            
            if i < (max - 3) && bitand(data(i), thresholdmask) == thresholdmask
                event_data.tc(index) = 1;
                if p == 0
                    event_data.delta_t(index) = 0;
                    start_t(x+1,y+1) = t;
                elseif p == 1 && start_t(x+1,y+1) ~= 0 % OFF threshold crossing after ON threshold crossing
                    event_data.delta_t(index) = t - start_t(x+1,y+1);
                    start_t(x+1,y+1) = 0;
                else % we ignore an OFF threshold crossing event after another one
                    event_data.delta_t(index) = 0;
                end
            else
                event_data.tc(index) = 0;
                event_data.delta_t(index) = 0;
            end
            index = index + 1;
            
            skiploop = 4;
        end
    end
    
elseif type == 1 %DVS file
    data = fread(f, 'uint8');
    fclose(f);

    index = 1;
    pmask = bin2dec('00000001');

    overflow = 0;
    skiploop = 0;
    t = 0;

    max = length(data);
    for i = 1:max
        if skiploop > 0
            skiploop = skiploop - 1;
            continue;
        end
        
        if bitand(data(i), 254) == 254
            if data(i) == 254 %reset byte
                continue;
            else
                overflow = overflow + 1;
            end
        else
            t = t + bitshift(data(i), -1) + overflow * 127;
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
            skiploop = 4;
        end
    end
else
    disp 'unsupported version'
    fclose(f);
    return;
end


if mirrorX
    event_data.x = (width - 1) - event_data.x;
end
if mirrorY
    event_data.y = (height - 1) - event_data.y;
end

end