function frameRate = getFrameRate(time)
frameGaps = time(2:end) - time(1:end-1);
meanFrameGap = mean(frameGaps);
frameGapErrorSum = sum(frameGaps - meanFrameGap);
disp(['Frame Gap Error Sum: ', num2str(frameGapErrorSum)]);
frameRate = 1000/meanFrameGap
end