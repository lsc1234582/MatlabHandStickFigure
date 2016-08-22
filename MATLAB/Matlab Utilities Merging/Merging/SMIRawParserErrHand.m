function data= SMIRawParserErrHand(filename)
data=[];
for i=1:numel(filename)
file = fopen(filename{i}, 'r');

C =textscan(file, '%s','delimiter','\n','MultipleDelimsAsOne', 1);
C=C{1};
fclose(file);
i=1;

header=true

while header
    
    row=C{i};
    
    if strcmp(row(1:2),'##')
        header=true;
        i=i+1;
    else
        header=false;
    end
    
    
end

dataLabels=textscan(C{i},'%s','delimiter','\t');
dataLabels=dataLabels{1};

numCols=length(dataLabels);

tmp=cell(length(C)-i,numCols);

for colctr = 1:numCols
    tmp(1,colctr) = {char(dataLabels(colctr))};
end



for dl=i+1:length(C)
    row=textscan(C{dl},'%s','delimiter','\t');
    row=row{1}';
    if length(row)==size(tmp,2)
        tmp(dl-i+1,:)=row;
    else if length(row)==size(tmp,2)+11
            warning('data with known corruption, cleaning data.')
            cleanRow=[row(1:15),row(26:27),row(28),row(30)];
            tmp(dl-i+1,:)=row;
        else
            error('Unknown corruption')
        end
        
    end
end

[r c]=size(tmp);
if c==32
    if strcmp(tmp(1,16),'B Object Hit')
       tmp(:,16)=[];
    end
end

if i==1
    data=[data;tmp(1:end,1:30)];
else
    data=[data;tmp(2:end,1:30)];
end
    

end