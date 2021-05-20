function fmmapslice=unwrapped(S0,matrix_size,fmmapslice);
iField = double(S0); %% SH hanning filtered, S no filtering

%%
nEchos = size(iField,4);
%clear nn a b c fn pn SS e
m=sum(abs(iField),4);

%% Find threshold using Otsu's method:
m=m/max(reshape(m,[],1)); %Normalize magnitude
mt = graythresh(m);                                                         

%% Find mean value of foreground voxels:
mf = mean(mean(m(m>mt)));

%% Calculate magnitude weight according to Eq. 6:
mw=1.0./(1+exp(3*(m-mt)/(mt-mf)));
iMag=mw;
%%
maxiMag=max(iMag,[],'all');
[x,y]=find(iMag==maxiMag);
%%
x0=x;y0=y;
%%
Gxr=matrix_size(1)-x0-1;
Gyd=matrix_size(2)-y0-1;
Gxl=x0-2;
Gyu=y0-2;
rrr=1;
%%
%%rightdown
for shift=0:min(Gxr,Gyd)
for gx=0:(Gxr-shift)%%xdirection
voxelfm=fmmapslice(x-rrr+gx:x+rrr+gx,y-rrr:y+rrr);
voxeliMag=iMag(x-rrr+gx:x+rrr+gx,y-rrr:y+rrr);
maxvoxeliMag=max(voxeliMag,[],'all');
[mx,my]=find(voxeliMag==maxvoxeliMag);
diffvoxel=zeros(size(voxelfm));
[sx,sy]=size(voxelfm);
fmr=voxeliMag(mx(1),my(1));

for pkx=1:sx
    for pky=1:sy
diff=voxelfm(pkx,pky)-fmr;
if diff>-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky);%2*pi;
    diffvoxel(pkx,pky)=diff;
    br=0;
elseif diff<-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky)+2*pi;
     diffvoxel(pkx,pky)=diff;
    br=1;
end
    end
end
fmmap(x-rrr+gx:x+rrr+gx,y-rrr:y+rrr)=voxelfm;
fmmapslice(x-rrr+gx:x+rrr+gx,y-rrr:y+rrr)=fmmap(x-rrr+gx:x+rrr+gx,y-rrr:y+rrr);
diffphase(x-rrr+gx:x+rrr+gx,y-rrr:y+rrr)=diffvoxel;
end
for gy=0:(Gyd-shift)%ydirection
voxelfm=fmmapslice(x-rrr:x+rrr,y-rrr+gy:y+rrr+gy);
voxeliMag=iMag(x-rrr:x+rrr,y-rrr+gy:y+rrr+gy);
maxvoxeliMag=max(voxeliMag,[],'all');
[mx,my]=find(voxeliMag==maxvoxeliMag);
diffvoxel=zeros(size(voxelfm));
[sx,sy]=size(voxelfm);
fmr=voxeliMag(mx(1),my(1));

for pkx=1:sx
    for pky=1:sy
diff=voxelfm(pkx,pky)-fmr;
if diff>-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky);%2*pi;
    diffvoxel(pkx,pky)=diff;
    br=0;
elseif diff<-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky)+2*pi;
     diffvoxel(pkx,pky)=diff;
    br=1;
end
    end
end
fmmap(x-rrr:x+rrr,y-rrr+gy:y+rrr+gy)=voxelfm;
fmmapslice(x-rrr:x+rrr,y-rrr+gy:y+rrr+gy)=fmmap(x-rrr:x+rrr,y-rrr+gy:y+rrr+gy);
diffphase(x-rrr:x+rrr,y-rrr+gy:y+rrr+gy)=diffvoxel;
end
x=x+1;
y=y+1;
end
%%
maxiMag=max(iMag,[],'all');
[x,y]=find(iMag==maxiMag);
%%
%%lefttop
for shift=0:min(Gxl,Gyu)
for gx=0:(Gxl-shift)
voxelfm=fmmapslice(x-rrr-gx:x+rrr-gx,y-rrr:y+rrr);
voxeliMag=iMag(x-rrr-gx:x+rrr-gx,y-rrr:y+rrr);
maxvoxeliMag=max(voxeliMag,[],'all');
[mx,my]=find(voxeliMag==maxvoxeliMag);
diffvoxel=zeros(size(voxelfm));
[sx,sy]=size(voxelfm);
fmr=voxeliMag(mx(1),my(1));

for pkx=1:sx
    for pky=1:sy
diff=voxelfm(pkx,pky)-fmr;
if diff>-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky);%%-2*pi;
    diffvoxel(pkx,pky)=diff;
    br=0;
elseif diff<-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky)+2*pi;
     diffvoxel(pkx,pky)=diff;
    br=1;
end
    end
end
fmmap(x-rrr-gx:x+rrr-gx,y-rrr:y+rrr)=voxelfm;
fmmapslice(x-rrr-gx:x+rrr-gx,y-rrr:y+rrr)=fmmap(x-rrr-gx:x+rrr-gx,y-rrr:y+rrr);
diffphase(x-rrr-gx:x+rrr-gx,y-rrr:y+rrr)=diffvoxel;
end
for gy=0:(Gyu-shift)
voxelfm=fmmapslice(x-rrr:x+rrr,y-rrr-gy:y+rrr-gy);
voxeliMag=iMag(x-rrr:x+rrr,y-rrr-gy:y+rrr-gy);
maxvoxeliMag=max(voxeliMag,[],'all');
[mx,my]=find(voxeliMag==maxvoxeliMag);
diffvoxel=zeros(size(voxelfm));
[sx,sy]=size(voxelfm);
fmr=voxeliMag(mx(1),my(1));

for pkx=1:sx
    for pky=1:sy
diff=voxelfm(pkx,pky)-fmr;
if diff>-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky);%-2*pi;
    diffvoxel(pkx,pky)=diff;
    br=0;
elseif diff<-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky)+2*pi;
     diffvoxel(pkx,pky)=diff;
    br=1;
end
    end
end
fmmap(x-rrr:x+rrr,y-rrr-gy:y+rrr-gy)=voxelfm;
fmmapslice(x-rrr:x+rrr,y-rrr-gy:y+rrr-gy)=fmmap(x-rrr:x+rrr,y-rrr-gy:y+rrr-gy);
diffphase(x-rrr:x+rrr,y-rrr-gy:y+rrr-gy)=diffvoxel;
end
x=x-1;
y=y-1;
end
%%
maxiMag=max(iMag,[],'all');
[x,y]=find(iMag==maxiMag);
%%
for shift=0:min(Gxr,Gyu)
for gx=0:(Gxr-shift)
voxelfm=fmmapslice(x-rrr+gx:x+rrr+gx,y-rrr:y+rrr);
voxeliMag=iMag(x-rrr+gx:x+rrr+gx,y-rrr:y+rrr);
maxvoxeliMag=max(voxeliMag,[],'all');
[mx,my]=find(voxeliMag==maxvoxeliMag);
diffvoxel=zeros(size(voxelfm));
[sx,sy]=size(voxelfm);
fmr=voxeliMag(mx(1),my(1));

for pkx=1:sx
    for pky=1:sy
diff=voxelfm(pkx,pky)-fmr;
if diff>-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky);%-2*pi;
    diffvoxel(pkx,pky)=diff;
    br=0;
elseif diff<-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky)+2*pi;
     diffvoxel(pkx,pky)=diff;
    br=1;
end
    end
end
fmmap(x-rrr+gx:x+rrr+gx,y-rrr:y+rrr)=voxelfm;
fmmapslice(x-rrr+gx:x+rrr+gx,y-rrr:y+rrr)=fmmap(x-rrr+gx:x+rrr+gx,y-rrr:y+rrr);
diffphase(x-rrr+gx:x+rrr+gx,y-rrr:y+rrr)=diffvoxel;
end
for gy=0:(Gyu-shift)
voxelfm=fmmapslice(x-rrr:x+rrr,y-rrr-gy:y+rrr-gy);
voxeliMag=iMag(x-rrr:x+rrr,y-rrr-gy:y+rrr-gy);
maxvoxeliMag=max(voxeliMag,[],'all');
[mx,my]=find(voxeliMag==maxvoxeliMag);
diffvoxel=zeros(size(voxelfm));
[sx,sy]=size(voxelfm);
fmr=voxeliMag(mx(1),my(1));

for pkx=1:sx
    for pky=1:sy
diff=voxelfm(pkx,pky)-fmr;
if diff>-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky);%-2*pi;
    diffvoxel(pkx,pky)=diff;
    br=0;
elseif diff<-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky)+2*pi;
     diffvoxel(pkx,pky)=diff;
    br=1;
end
    end
end
fmmap(x-rrr:x+rrr,y-rrr-gy:y+rrr-gy)=voxelfm;
fmmapslice(x-rrr:x+rrr,y-rrr-gy:y+rrr-gy)=fmmap(x-rrr:x+rrr,y-rrr-gy:y+rrr-gy);
diffphase(x-rrr:x+rrr,y-rrr-gy:y+rrr-gy)=diffvoxel;
end
x=x+1;
y=y-1;
end
%%
maxiMag=max(iMag,[],'all');
[x,y]=find(iMag==maxiMag);
%%
for shift=0:min(Gxl,Gyd)
for gx=0:(Gxl-shift)
voxelfm=fmmapslice(x-rrr-gx:x+rrr-gx,y-rrr:y+rrr);
voxeliMag=iMag(x-rrr-gx:x+rrr-gx,y-rrr:y+rrr);
maxvoxeliMag=max(voxeliMag,[],'all');
[mx,my]=find(voxeliMag==maxvoxeliMag);
diffvoxel=zeros(size(voxelfm));
[sx,sy]=size(voxelfm);
fmr=voxeliMag(mx(1),my(1));

for pkx=1:sx
    for pky=1:sy
diff=voxelfm(pkx,pky)-fmr;
if diff>-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky);%-2*pi;
    diffvoxel(pkx,pky)=diff;
    br=0;
elseif diff<-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky)+2*pi;
     diffvoxel(pkx,pky)=diff;
    br=1;
end
    end
end
fmmap(x-rrr-gx:x+rrr-gx,y-rrr:y+rrr)=voxelfm;
fmmapslice(x-rrr-gx:x+rrr-gx,y-rrr:y+rrr)=fmmap(x-rrr-gx:x+rrr-gx,y-rrr:y+rrr);
diffphase(x-rrr-gx:x+rrr-gx,y-rrr:y+rrr)=diffvoxel;
end
for gy=0:(Gyd-shift)
voxelfm=fmmapslice(x-rrr:x+rrr,y-rrr+gy:y+rrr+gy);
voxeliMag=iMag(x-rrr:x+rrr,y-rrr+gy:y+rrr+gy);
maxvoxeliMag=max(voxeliMag,[],'all');
[mx,my]=find(voxeliMag==maxvoxeliMag);
diffvoxel=zeros(size(voxelfm));
[sx,sy]=size(voxelfm);
fmr=voxeliMag(mx(1),my(1));

for pkx=1:sx
    for pky=1:sy
diff=voxelfm(pkx,pky)-fmr;
if diff>-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky);%-2*pi;
    diffvoxel(pkx,pky)=diff;
    br=0;
elseif diff<-pi
    voxelfm(pkx,pky)=voxelfm(pkx,pky)+2*pi;
     diffvoxel(pkx,pky)=diff;
    br=1;
end
    end
end
fmmap(x-rrr:x+rrr,y-rrr+gy:y+rrr+gy)=voxelfm;
fmmapslice(x-rrr:x+rrr,y-rrr+gy:y+rrr+gy)=fmmap(x-rrr:x+rrr,y-rrr+gy:y+rrr+gy);
diffphase(x-rrr:x+rrr,y-rrr+gy:y+rrr+gy)=diffvoxel;
end
x=x-1;
y=y+1;
end
end