function SyncIDF(G)

if ~isempty(G.Data)
    gaze=G.Data;
    
    % sort out IDF class so can be merged with gazedata
    frNumWeirdFormat=str2mat(G.IDFData{2:end,28});

    frameNumWeirdFormatMat(:,1)=str2num(frNumWeirdFormat(:,1:2));
    frameNumWeirdFormatMat(:,2)=str2num(frNumWeirdFormat(:,4:5));
    frameNumWeirdFormatMat(:,3)=str2num(frNumWeirdFormat(:,7:8));
    frameNumWeirdFormatMat(:,4)=str2num(frNumWeirdFormat(:,10:11));

    frNum=frameNumWeirdFormatMat(:,4)+frameNumWeirdFormatMat(:,3)*24 +frameNumWeirdFormatMat(:,2)*60*24+frameNumWeirdFormatMat(:,1)*60*60*24;

    
    gazeIDF=[cellfun(@str2num,G.IDFData(2:end,4:27)),frNum,(1*strcmp(G.IDFData(2:end,30),'Fixation')+2*strcmp(G.IDFData(2:end,30),'Saccade')+3*strcmp(G.IDFData(2:end,30),'Blink')) ];
    
    gazeServerTime=G.serverTime;
    gazeIDFServerTime=(cellfun(@str2num,G.IDFData(2:end,1))/1000);
    offsetIDF=0; % will increase when frame of gaze dropped
    offsetGaze=0;
    data=nan(size(gazeIDF,1),size(gaze,2)+size(gazeIDF,2));
    time=nan(size(gazeIDF,1),1);
    % to combine gaze and IDF, adding nans for gaze where frame dropped
    for i=1:size(gaze,1)
        
    if ((i+offsetGaze)<size(gaze,1)) & ((i+offsetIDF)<size(gazeIDFServerTime,1))

     
        %check time stamp matches
        if abs((gazeServerTime(i+offsetGaze)-gazeIDFServerTime(i+offsetIDF)))<1e-3
            data(i+offsetIDF+offsetGaze,:)=[gaze(i+offsetGaze,:),gazeIDF(i+offsetIDF,:)];
            time(i+offsetIDF+offsetGaze)=G.Time(i+offsetGaze);
        else % fill in IDF rows until gaze picks up again
            
            while abs((gazeServerTime(i+offsetGaze)-gazeIDFServerTime(i+offsetIDF)))>1e-3
                data(i+offsetIDF+offsetGaze,:)=[nan(1,28),gazeIDF(i+offsetIDF,:)];
                if (i+offsetIDF-1)>0 
                    time(i+offsetIDF+offsetGaze)=time(i+offsetIDF+offsetGaze-1)+(gazeIDFServerTime(i+offsetIDF)-gazeIDFServerTime(i+offsetIDF-1));
                end
                 offsetIDF=offsetIDF+1;
                 
                 if abs((gazeServerTime(i+offsetGaze)-gazeIDFServerTime(i+offsetIDF)))<1e-3
                     data(i+offsetIDF+offsetGaze,:)=[gaze(i+offsetGaze,:),gazeIDF(i+offsetIDF,:)];
                     time(i+offsetIDF+offsetGaze)=G.Time(i+offsetGaze);
                 end
                 
                
                if offsetIDF>100
                    offsetGaze=0;
                    offsetIDF=0;
               
                     while abs((gazeServerTime(i+offsetGaze)-gazeIDFServerTime(i+offsetIDF)))>1e-3
                            data(i+offsetGaze+offsetGaze,:)=[gaze(i+offsetGaze+offsetGaze,:),nan(1,26)];
                            time(i+offsetGaze+offsetGaze)=G.Time(i+offsetGaze+offsetGaze);
                                             
                            offsetGaze=offsetGaze+1;
                            if offsetGaze>100
                                error('something went wrong matchin gaze data and idf')
                            end
                     end
                     if abs((gazeServerTime(i+offsetGaze)-gazeIDFServerTime(i+offsetIDF)))<1e-3
                         data(i+offsetIDF+offsetGaze,:)=[gaze(i+offsetGaze,:),gazeIDF(i+offsetIDF,:)];
                         time(i+offsetIDF+offsetGaze)=G.Time(i+offsetGaze);
                     end
                         
                end
            end
            
            
            
        end
    end
    end
    
    % to add any remaining rows of IDF
    if i+offsetIDF<size(gazeIDF,1)
        for iEx=1:size(gazeIDF,1)-i-offsetIDF+1
            data(i+offsetIDF+iEx-1,:)=[nan(1,28),gazeIDF(i+offsetIDF+iEx-1,:)];
            time(i+offsetIDF+iEx-1)=time(i+offsetIDF+iEx-2)+(gazeIDFServerTime(i+offsetIDF+iEx-1,:)-gazeIDFServerTime(i+offsetIDF+iEx-2,:));

        end
    end
    
    if i+offsetGaze<size(gaze,1)
        for iEx=1:size(gaze,1)-i-offsetGaze
            data(i+offsetGaze+iEx,:)=[gaze(i+offsetGaze+iEx,:),nan(1,26)];
            time(i+offsetGaze+iEx)=G.Time(i+offsetIDF+iEx);

        end
    end
    
    G.Data=data;
    G.Time=time;%G.Time(1)+gazeIDFServerTime-gazeIDFServerTime(1); G.Time is
    %already the server time modified
        
       
else
    
    frNumWeirdFormat=str2mat(G.IDFData{2:end,28});

    frameNumWeirdFormatMat(:,1)=str2num(frNumWeirdFormat(:,1:2));
    frameNumWeirdFormatMat(:,2)=str2num(frNumWeirdFormat(:,4:5));
    frameNumWeirdFormatMat(:,3)=str2num(frNumWeirdFormat(:,7:8));
    frameNumWeirdFormatMat(:,4)=str2num(frNumWeirdFormat(:,10:11));

    frNum=frameNumWeirdFormatMat(:,4)+frameNumWeirdFormatMat(:,3)*24 +frameNumWeirdFormatMat(:,2)*60*24+frameNumWeirdFormatMat(:,1)*60*60*24;

    
    gazeIDF=[cellfun(@str2num,G.IDFData(2:end,4:27)),frNum,(1*strcmp(G.IDFData(2:end,30),'Fixation')+2*strcmp(G.IDFData(2:end,30),'Saccade')+3*strcmp(G.IDFData(2:end,30),'Blink')) ];
    
    gazeIDFServerTime=(cellfun(@str2num,G.IDFData(2:end,1))/1000);
    
    data=[nan(size(gazeIDF(1:end,:),1),28),gazeIDF(1:end,:)];
    
    G.Data=data;
    G.Time=gazeIDFServerTime;
end
    
    
    
    
