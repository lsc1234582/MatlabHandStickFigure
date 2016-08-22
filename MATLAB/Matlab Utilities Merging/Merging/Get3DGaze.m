
function PQ=Get3DGaze(directionL,directionR,L0,R0)

failed=zeros(1,size(directionL,2));

w0=(L0-R0)';

u=directionL;

v=directionR;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perpendicular dist method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a=dot(u,u);

b=dot(u,v);

c=dot(v,v);


d=dot(u,w0);

e=dot(v,w0);

s=(b.*e-c.*d)./(a.*c-(b.^2));
t=(a.*e-b.*d)./(a.*c-(b.^2));

P=[s;s;s].*u+L0';
Q=[t;t;t].*v+R0';
w=P-Q;


for i=1:size(u,2)
    lengthW(i)=norm(w(:,i));
    check(i)=dot(w(:,i)/norm(w(:,i)),u(:,i)); %w should be perpendicular to u and v
end



checkPerp=sum(abs(check(~isnan(check)))/sum(~isnan(check)));
if checkPerp>1e-5
    warning('3D calc failed')
    failed=ones(1,size(meanPQ,2));
end

meanWLength=mean(lengthW(~isnan(lengthW)));
meanPQ=(P+Q)./2;
PQ=[meanPQ;P;Q;failed];
end

%%
% figure
% plot3(L0(1),L0(3),L0(2),'or');hold on
% plot3(R0(1),R0(3),R0(2),'ob')
% 
% plot3(P(1),P(3),P(2),'rx')
% plot3(Q(1),Q(3),Q(2),'bx')
% 
% sc=1000
% line([L0(1) L0(1)+sc*u(1)],[L0(3) L0(3)+sc*u(3)],[L0(2) L0(2)+sc*u(2)])
% line([R0(1) R0(1)+sc*v(1)],[R0(3) R0(3)+sc*v(3)],[R0(2) R0(2)+sc*v(2)])
% 
% line([Q(1) Q(1)+w(1)],[Q(3) Q(3)+w(3)],[Q(2) Q(2)+w(2)])



