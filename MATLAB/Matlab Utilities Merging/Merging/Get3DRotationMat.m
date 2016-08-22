function rotationDat=Get3DRotationMat(vector,initVect)

rotationMat=nan(3,3,size(vector,2));

for i=1:size(vector,2)
    
    if sum(isnan(vector(:,i)))==0
        r=vrrotvec(vector(:,i),initVect);
        rotationMat(:,:,i)=vrrotvec2mat(r);
        [yawEye(i) pitchEye(i) rollEye(i)]=dcm2angle(rotationMat(:,:,i),'YXZ');
        
    else
        yawEye(i)=nan;
        pitchEye(i)=nan;
        rollEye(i)=nan;
    end
    
    
end

rotationDat.rotMat=rotationMat;
rotationDat.rotEuler.pitch=pitchEye;
rotationDat.rotEuler.yaw=yawEye;
rotationDat.rotEuler.roll=rollEye;


end