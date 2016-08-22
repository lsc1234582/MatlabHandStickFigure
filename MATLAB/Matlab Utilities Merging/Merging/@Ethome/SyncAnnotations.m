function SyncAnnotations(E)


E.Annotation.toVector;
annotCodes=unique(E.Annotation.Data);

AnnotationMarkers=-ones(numel(E.Time),1);

for i=1:numel(annotCodes)
    eventTimeStamps=E.Annotation.Time(find(E.Annotation.Data==annotCodes(i)));
    for evInsti=1:numel(eventTimeStamps)
        [m,tId]=min(abs(eventTimeStamps(evInsti)-E.Time-60*60*1000));
        if m<30
            AnnotationMarkers(tId)=annotCodes(i);
            if annotCodes(i)==0
                AnnotationLabels{tId,1}='no action';
            else
                AnnotationLabels{tId,1}=E.Annotation.EventMap.ActionMap( annotCodes(i),2);
            end
                
            
        else
            error('Annotation time not found correctly')
        end

    end
end


E.AnnotationMarkers=AnnotationMarkers;
