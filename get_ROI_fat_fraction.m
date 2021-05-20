
%clear
%clc
%%
%[fn pn] = uigetfile('*ff*.mat');
%cd(pn);
%load([pn fn]);
%% upscale resolution
for n=1:20
ff2=ffc(:,:,n);
temp = imresize(ff2,[512 512],'bilinear');
clear ff2; ff2 = temp; clear temp
clear temp
temp = isnan(ff2);
ff2(temp) = 0;
clear temp
idx = find(ff2== 100);
ff2(idx) = 0;
ff2(isinf(ff2))=0;
ffslicec(:,:,n)=ff2;
end
%% get inhouse

%figure(1); clf
%imagesc(ff,[0 100]); axis image; colormap(gray); axis off
%[x y] = ginput(1);
%x = round(x);
%y = round(y);
%%
N=10;
Imc = ffslicec(:,:,N);
for point=1:4
    N=10;
%x=139;
%y=258;
figure(1); clf
imagesc(ffslicec(:,:,N),[0 100]); axis image; colormap(gray); axis off
[x y] = ginput(1);
x = round(x);
y = round(y);
[rNum,cNum,~] = size(Imc);
%// Define coordinates and radius
x1= x;
y1= y;
radius = 15;
%// Generate grid with binary mask representing the circle. Credit to Jonas for original code.
[xx,yy] = ndgrid((1:rNum)-y1,(1:cNum)-x1);
tol = 2;
mask1 = (xx.^2 + yy.^2)<radius^2;
mask = (xx.^2 + yy.^2)<radius^2 & (xx.^2 + yy.^2)>(radius-tol)^2;
%// Mask the original image
Imc(mask) = uint8(1000);
%Imm(:,:,N)=Im;
%figure;imagesc(Im,[0 100]); axis image; colormap(gray); axis off
temp = mask1.*ffslicec(:,:,N);
[I J K] = find(temp);
commandwindow; clc
K;
ff_roic(:,point) = mean(K)
strc(1,point)=ff_roic(1,point);
X(1,point)=x1;
Y(1,point)=y1;
end
%%
figure;imagesc(Imc,[0 100]); axis equal tight off; colormap gray;
str2c = {strc(1,1),strc(1,2),strc(1,3),strc(1,4)};
text(X(1,:),Y(1,:),str2c(1,:));
hold on
%%
for n=1:1
ff2=ffm(:,:,n);
temp = imresize(ff2,[512 512],'bilinear');
clear ff2; ff2 = temp; clear temp
clear temp
temp = isnan(ff2);
ff2(temp) = 0;
clear temp
idx = find(ff2== 100);
ff2(idx) = 0;
ff2(isinf(ff2))=0;
ffslicem(:,:,n)=ff2;
end
Imm = ffslicem(:,:,N);
for point=1:4
    N=1;
%// Define coordinates and radius
%// Generate grid with binary mask representing the circle. Credit to Jonas for original code.
[xx,yy] = ndgrid((1:rNum)-Y(:,point),(1:cNum)-X(:,point));
tol = 2;
mask1 = (xx.^2 + yy.^2)<radius^2;
mask = (xx.^2 + yy.^2)<radius^2 & (xx.^2 + yy.^2)>(radius-tol)^2;
%// Mask the original image
Imm(mask) = uint8(1000);
%Imm(:,:,N)=Im;
%figure;imagesc(Im,[0 100]); axis image; colormap(gray); axis off
temp = mask1.*ffslicem(:,:,N);
[I J K] = find(temp);
commandwindow; clc
K;
ff_roim(:,point) = mean(K)
strm(1,point)=ff_roim(1,point);
end
%%
figure;imagesc(Imm,[0 100]); axis equal tight off; colormap gray;
str2m = {strm(1,1),strm(1,2),strm(1,3),strm(1,4)};
text(X(1,:),Y(1,:),str2m(1,:));
hold on
%%
for n=1:1
ff2=ff(:,:,n);
temp = imresize(ff2,[512 512],'bilinear');
clear ff2; ff2 = temp; clear temp
clear temp
temp = isnan(ff2);
ff2(temp) = 0;
clear temp
idx = find(ff2== 100);
ff2(idx) = 0;
ff2(isinf(ff2))=0;
ffslice(:,:,n)=ff2;
end
Im = ffslice(:,:,N);
for point=1:4
    N=1;
%// Define coordinates and radius
%// Generate grid with binary mask representing the circle. Credit to Jonas for original code.
[xx,yy] = ndgrid((1:rNum)-Y(:,point),(1:cNum)-X(:,point));
tol = 2;
mask1 = (xx.^2 + yy.^2)<radius^2;
mask = (xx.^2 + yy.^2)<radius^2 & (xx.^2 + yy.^2)>(radius-tol)^2;
%// Mask the original image
Im(mask) = uint8(1000);
%Imm(:,:,N)=Im;
%figure;imagesc(Im,[0 100]); axis image; colormap(gray); axis off
temp = mask1.*ffslice(:,:,N);
[I J K] = find(temp);
commandwindow; clc
K;
ff_roi(:,point) = mean(K)
str(1,point)=ff_roi(1,point);
end
%%
figure;imagesc(Im,[0 100]); axis equal tight off; colormap gray;
str2 = {str(1,1),str(1,2),str(1,3),str(1,4)};
text(X(1,:),Y(1,:),str2(1,:));
hold on


