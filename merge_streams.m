function stream = merge_streams(stream1, stream2)
% merge two event streams and sort all events by timestamp

    ts = horzcat(stream1.ts, stream2.ts);
    x = horzcat(stream1.x, stream2.x);
    y = horzcat(stream1.y, stream2.y);
    corr = horzcat(stream1.patternCorrelation, stream2.patternCorrelation);
    
    fusion = [ts; x; y; corr]';
    fusion = sortrows(fusion);
    stream.ts = fusion(:,1)';
    stream.x = fusion(:,2)';
    stream.y = fusion(:,3)';
    stream.patternCorrelation = fusion(:,4)';
end

