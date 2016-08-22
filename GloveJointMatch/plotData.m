function plotData(mapping, data)

for i = 1:22
    Ax(i) = subplot(4,6,i);
    plot(data(:,i)-81)    
    title(mapping(i))
    
end

%set(Ax,'YLim',[min(min(data)), max(max(data))]);