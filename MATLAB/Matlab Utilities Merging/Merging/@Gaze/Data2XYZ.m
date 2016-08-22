function xyzData = Data2XYZ( G )

% if ~isempty( G.xyzData )
%     xyzData = G.xyzData;
%     return
% end



L0=[G.Data(:,4) G.Data(:,5) G.Data(:,6)]; %mm
R0=[G.Data(:,16) G.Data(:,17) G.Data(:,18)];



directionL =[G.Data(:,7) G.Data(:,8) G.Data(:,9)]';%[(cosd(gammaLErr))*(sind(thetaLErr)); (sind(gammaLErr))*(sind(thetaLErr)); cosd(thetaLErr)];

directionR = [G.Data(:,19) G.Data(:,20) G.Data(:,21)]';

xyzData = Get3DGaze(directionL,directionR,L0,R0);

initVect=[0,0,1];

rotationDataL=Get3DRotationMat(directionL,initVect);
rotationDataR=Get3DRotationMat(directionR,initVect);


G.xyzData.endPoint=xyzData(1:3,:);

G.xyzData.Left.endPoint=xyzData(7:9,:);
G.xyzData.Right.endPoint=xyzData(4:6,:);

G.xyzData.Left.rotationMat=rotationDataL.rotMat;
G.xyzData.Right.rotationMat=rotationDataR.rotMat;


G.xyzData.Left.rotEuler.pitch=  rotationDataL.rotEuler.pitch;
G.xyzData.Left.rotEuler.yaw=  rotationDataL.rotEuler.yaw;
G.xyzData.Left.rotEuler.roll=  rotationDataL.rotEuler.roll;

G.xyzData.Right.rotEuler.pitch=  rotationDataR.rotEuler.pitch;
G.xyzData.Right.rotEuler.yaw=  rotationDataR.rotEuler.yaw;
G.xyzData.Right.rotEuler.roll=  rotationDataR.rotEuler.roll;





end



