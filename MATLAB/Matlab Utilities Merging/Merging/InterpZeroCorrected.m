function iData = InterpZeroCorrected( time, data,newTime, interpMethod) % data

[r, c]=size(data);



for i=1:c
    goodDat=abs(data(:,i))>0;
    iData(:,i)=interp1( time(goodDat), data(goodDat,i), newTime, interpMethod );
end



