function modifiedCh = modifyChannel2(ch)
ch_size = size(ch);
padding = zeros(ch_size(1), 10);

modifiedCh = [ch(:,21:22), ...
    padding(:,1:3), ch(:,1), padding(:,1), ...
    ch(:,2), ...
    ch(:,3), ...
    padding(:,1:3), ch(:,5), padding(:,1)...
    ch(:,6), ...
    ch(:,7), ...
    padding(:,1:3), ch(:,8), padding(:,1), ...
    ch(:,9), ...
    ch(:,10), ...
    padding(:,1:3), ch(:,12), padding(:,1), ...
    ch(:,13), ...
    ch(:,14), ...
    padding(:,1:3), ch(:,16), padding(:,1), ...
    ch(:,17), ...
    ch(:,18),];