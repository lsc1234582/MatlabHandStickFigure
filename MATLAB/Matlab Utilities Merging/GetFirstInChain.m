function firstdBEntry =GetFirstInChain(dBEntry,dB_)

while ~isempty(dBEntry.prevFile)
    dBEntry = getEntries( dB_, [], @(x) strcmp( x.FileName, dBEntry.prevFile ) );
end

firstdBEntry=dBEntry;
    