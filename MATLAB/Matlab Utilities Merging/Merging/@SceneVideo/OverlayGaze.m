function OverlayGaze(V,G,outputFileName)

%Note: this function will create a video with a frame for each row of data
%so there will be duplicate frames when more than one row associated with
%frame
info.FileName=[outputFileName,'.mp4'];
V.SetOverlayFileName(info);
OverlayVidWriter=VideoWriter(outputFileName,'MPEG-4')
OverlayVidWriter.FrameRate=G.Fs;
open(OverlayVidWriter)
 

disp=0;
   
V.LoadRawVideoReader;

firstFrame= read(V.RawVidReader,1);

count=0
noFrameNumIndex=find(G.Data(:,3)>1e9);
firstCorrectDataRow=noFrameNumIndex(end)+1;


frameNumOffest=G.Data(firstCorrectDataRow,3)-1;  %this removes dodgy stuff at beginning and makes first coherent data entry frame number 1 in correspondance with the video.

reallignedFrameNums=G.Data(:,3)-frameNumOffest;

%startRow=firstCorrectDataRow;
%endRow=500;


padR=50;
padC=50;

for i=firstCorrectDataRow:size(G.Data,1)    % i corresponds to E.Data row.
     
    
    frameNum= reallignedFrameNums(i);
    if ~isnan(frameNum)
    
    frame=read(V.RawVidReader,frameNum);       
    i
        
    
    [vr vc vcolour]=size(frame);
    %vi=i-startFrame+1;
    
    %frame=vid;
    padFrame=padarray(frame,[padR padC],255);
    %vidPad=padframe;
    
    
%     %%% for detecting marker, only relevent for SMI overlayed vid.
%          binIm=((vidPad(:,:,1)==255)&((vidPad(:,:,2)>=135)&(vidPad(:,:,2)<=140))&((vidPad(:,:,3)>=73)&(vidPad(:,:,3)<=80)));
%             labels=bwlabel(binIm);
%             props=regionprops(labels);
%             for pi=1:length(props)
%                 if props(pi).Area>1500
%                     posOverlay(1,vi)=props(pi).Centroid(1);
%                     posOverlay(2,vi)=props(pi).Centroid(2);
%                 end
%             end
            

        % for si=1:numel(frameDatIds)
        %si=frameDatIds;  
        
        if G.Data(i,54)==0 % unidentified
            colour=4;
        else
            colour=G.Data(i,54); 
        end
        
        
            
            rangeR=[1 vr+2*padR];
            rangeC=[1 vc+2*padC];
            
            %overlayDat=[G.Data(i,37:38)];
            overlayDat=[G.Data(i,35:36)];%feb16
        for ovi=1 % only add number for multiple markers
            
            minR=int16(SetToRange(padR+round(overlayDat((ovi-1)*2+2))-10,rangeR));
            maxR=int16(SetToRange(padR+round(overlayDat((ovi-1)*2+2))+10,rangeR));
            minC=int16(SetToRange(padC+round(overlayDat((ovi-1)*2+1))-10,rangeC));
            maxC=int16(SetToRange(padC+round(overlayDat((ovi-1)*2+1))+10,rangeC));
            
            
            padFrame(minR:maxR,minC:maxC,1)=(ovi-1)*100; % makes second overlay light colour
            padFrame(minR:maxR,minC:maxC,2)=(ovi-1)*100;
            padFrame(minR:maxR,minC:maxC,3)=(ovi-1)*100;
            
            if colour~=4
                padFrame(minR:maxR,minC:maxC,colour)=255;
            end
        end
         
            if(disp==1)
                figure(1)
                imshow(padFrame(:,:,:));
                hold on
                xlabel('pix');
                ylabel('pix');
                %axis([-10 c+10 -10 r+10])
                title(['R-fix G-sac B-bl. Timestamp IDF: ' gazeIDF(i+1,1)]); % ' frame estimated stamp
                drawnow
                disp
                pause 
            end
            
            writeVideo(OverlayVidWriter,padFrame(:,:,:));
    end
    
    
end

close(OverlayVidWriter)

LoadOverlayVideoReader(V)


