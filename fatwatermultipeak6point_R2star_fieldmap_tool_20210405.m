%%
clc
clear
%imDataParams
BASEPATH='./';
addpath([BASEPATH '70047/']);
addpath([BASEPATH 'Selena_ff_functions/']);
[fn pn] = uigetfile('*bb*');
cd(pn); load(fn); clear fn pn
%[fn pn] = uigetfile('*zz_2*');
%cd(pn); load(fn); clear fn pn
%%
%%algoParams_9_peaks
algoParams.species(1).name = 'water';
algoParams.species(1).frequency = 0;
algoParams.species(1).relAmps = 1;
algoParams.species(2).name = 'fat';
algoParams.species(2).frequency = [3.80, 3.40, 3.10 2.680, 2.50, 1.94, 0.50, -0.49, -0.60 ];
algoParams.species(2).relAmps = [0.095 0.678 0.063 0.068 0.063 0.008 0.042 0.011 0.042];
%%
%%chose the slice
while(1)
oneslice_msg= sprintf('Just one slice or all (1-one 0-all)=')
oneslice= input(oneslice_msg);
if oneslice==1
while(1)
    slice_msg = sprintf('Enter the slice number = ')
    slice= input(slice_msg);
    if ~isempty(slice)
        break
    end
end
images=imDataParams.images(:,:,slice,:,:);
Imsize=size(images);
matrix_size=[Imsize(1) Imsize(2) 1];
break
elseif oneslice==0
images=imDataParams.images(:,:,:,:,:);
Imsize=size(images);
matrix_size=[Imsize(1) Imsize(2) Imsize(3)];
break
end
end
%% Check validity of params, and set default algorithm parameters if not provided
if ~strcmp(class(images),'single')
    images=single(images);
    disp('WARNING: image data converted to single precision')
end
try
  imDataParams.voxelSize=imDataParams.voxelSize;
catch 
  imDataParams.voxelSize=[3.5 3.5 3.5];
end
%% create linear model matrix_real_imag
%gyromagnetic ratio for hydrogen [MHz/T]
gyro = 42.58;
%resonance frequency vector [in radians]:
if (imDataParams.PrecessionIsClockwise>0) %if not clockwise, (most) fat frequencies will be negative
    omega_p = -2*pi*gyro*imDataParams.FieldStrength*(algoParams.species(1).frequency-algoParams.species(2).frequency);
else %if clockwise, (most) fat frequencies will be positive
    omega_p = +2*pi*gyro*imDataParams.FieldStrength*(algoParams.species(1).frequency-algoParams.species(2).frequency);
end
a=exp(complex(0,imDataParams.TE(1:6)*omega_p))*algoParams.species(2).relAmps';
%A=[ones(6,1) a];
A=[ones(6,1) zeros(6,1) real(a) imag(a);zeros(6,1) ones(6,1) -imag(a) real(a)];
%% DH*: Combine multiple coils (replaced dummyCoilCombine)
if size(images,4) > 1
  S0 = (permute(coilCombine3D( images(:,:,:,:,1:6) ),[1 2 3 5 4]));
else
  S0 = (permute( images(:,:,:,:,1:6),[1 2 3 5 4]));
end
%%
while(1)
    iter_msg = sprintf('Enter the max_iter = ')
    max_iter= input(iter_msg);
    if ~isempty(max_iter)
        break
    end
end
%%
%complex_fitting
disp('complex_fitting:');
tic
for slicenum=1:matrix_size(3)
    reltol=1e-4;
    if matrix_size(3)==1
        S0slice=S0;
        [Wcfmslice,Fcfmslice,fmmapslice]=fm_complex_fit(S0slice,a,reltol,max_iter,matrix_size,imDataParams);
        fmmapsliceun=unwrapped(S0slice,matrix_size,fmmapslice);%phase
        fmmapslicef=fmmapsliceun/(gyro*(-imDataParams.FieldStrength)*imDataParams.delta_TE);%radians
        [Wcslice,Fcslice,R2mapslice,error]=R2_complex_fit(S0slice,fmmapslicef,a,reltol,max_iter,imDataParams,matrix_size);
        Wc=Wcslice;
        Fc=Fcslice;
        Error=error;
    else
        S0slice=S0(:,:,slicenum,:);
        [Wcfmslice,Fcfmslice,fmmapslice]=fm_complex_fit(S0slice,a,reltol,max_iter,matrix_size,imDataParams);
        fmmapsliceun=unwrapped(S0slice,matrix_size,fmmapslice);
        fmmapslicef=fmmapsliceun/(gyro*(-imDataParams.FieldStrength)*imDataParams.delta_TE);%radians
        [Wcslice,Fcslice,R2mapslice,error]=R2_complex_fit(S0slice,fmmapslicef,a,reltol,max_iter,imDataParams,matrix_size);
        Wc(:,:,slicenum)=Wcslice;
        Fc(:,:,slicenum)=Fcslice;
        R2(:,:,slicenum)=R2mapslice;
        Fmmap(:,:,slicenum)=fmmapslicef;
        Error(:,:,slicenum,:)=error;
    end
end
toc
%%
%magnitude_fitting
disp('magnitu_fitting:');
tic
for slicenum=1:matrix_size(3)
    if matrix_size(3)==1
        slicenum=1;
        [Wmslice,Fmslice]=magn_fit(double(Wc),double(Fc),double(S0),a,reltol,max_iter,matrix_size,slicenum);
        Wm=Wmslice;
        Fm=Fmslice;
    else
        [Wmslice,Fmslice]=magn_fit(Wc,Fc,S0,a,reltol,max_iter,matrix_size,slicenum);
        Wm(:,:,slicenum)=Wmslice;
        Fm(:,:,slicenum)=Fmslice;
    end
end
toc
%%
[wc fc ffc]=fatfraction(Wc,Fc);
imlook3d(abs(wc));
imlook3d(abs(fc));
figure;imshow3D(abs(ffc),[0 100]);axis equal tight off;colormap(gray);colorbar; 
%%
[wm fm ffm]=fatfraction(Wm,Fm);
imlook3d(abs(wm));
imlook3d(abs(fm));
figure;imshow3D(abs(ffm),[0 100]);axis equal tight off;colormap(gray);colorbar;
%%
re=floor(log10(real(max(Wc,[],'all')/max(Wm,[],'all'))));
for slicenum=1:matrix_size(3)
for i=1:matrix_size(1)
        for j=1:matrix_size(2)
            ffp=abs(ffc(i,j,slicenum));
                weight(i,j,slicenum)=exp((-(ffp-50).^2)/100);
                W(i,j,slicenum)=weight(i,j,slicenum)*abs(Wc(i,j,slicenum))+(1-weight(i,j,slicenum))*Wm(i,j,slicenum)*10^(re);
                F(i,j,slicenum)=weight(i,j,slicenum)*abs(Fc(i,j,slicenum))+(1-weight(i,j,slicenum))*Fm(i,j,slicenum)*10^(re);   
        end
end        
end
%%
%f=f0;
%w=w0;
[w f ff]=fatfraction(W,F);
%%
figure;imshow3D(abs(w));axis equal tight off;colormap(gray);
figure;imshow3D(abs(f));axis equal tight off;colormap(gray);
figure;imshow3D(abs(squeeze(ff)),[0 100]);axis equal tight off;colormap(gray);colorbar;
%%
%figure;imagesc(abs(w(:,:,slice)),[0 40]);axis equal tight off;colormap(gray);colorbar;title('combined fit water liver image');
%figure;imagesc(abs(f(:,:,slice)),[0 40]);axis equal tight off;colormap(gray);colorbar;title('combined fit fat liver image');
%figure;imagesc(abs(ff(:,:,slice)),[0 100]);axis equal tight off;colormap(gray);colorbar;title('combined fit fat fraction liver image');
%%
%fc=abs(fc);
%wc=abs(wc);
%ffc=abs(ffc);
%%
%save ff_pennington_698_S_mask_6point_mw_realimag_eachslice_R2star_fieldmap_freqfit_ppm_FWtool.mat fc wc ffc