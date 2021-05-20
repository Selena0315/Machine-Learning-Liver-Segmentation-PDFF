function [Wcslice,Fcslice,R2mapslice,error]=R2_complex_fit(S0slice,fmmapslicef,a,reltol,max_iter,imDataParams,matrix_size)
for kx=1:matrix_size(1)
    for ky=1:matrix_size(2)
        Ims=squeeze(S0slice(kx,ky,1,:));
        %background_correction-use the fmmap(frequency shift due to B0 field inhomogeneity) obtained by the fm_complex_fit
        %to remove phase error
        gyro=42.58;
        s=Ims./exp(1i*fmmapslicef(kx,ky)*imDataParams.TE);
        shat=zeros(6,1);
        for k=1:max_iter
            y = abs(s);
            te=imDataParams.TE;
            nte = length(te);
            yy=0;
            yx=0;
            beta_yx=0;
            beta_xx=0;
        for j=1:nte-2
            alpha = (te(j+2)-te(j))*(te(j+2)-te(j))/2/(te(j+1)-te(j));
            tmp = (2*te(j+2)*te(j+2) - te(j)*te(j+2) - te(j)*te(j) + 3*te(j)*te(j+1) -3*te(j+1)*te(j+2))/6; 
            beta = tmp/(te(j+2)-te(j+1)); 
            gamma = tmp/(te(j+1)-te(j));
            y1 = y(j)*(te(j+2)-te(j)-alpha+gamma)+y(j+1)*(alpha-beta-gamma)+y(j+2)*beta;
            x1 = y(j)-y(j+2);
            yy=yy+y1.*y1;
            yx=yx+y1.*x1;
            beta_yx=beta_yx+beta*y1.*x1;
            beta_xx=beta_xx+beta*x1.*x1;
        end
        r2 = (yx + beta_xx)./(beta_yx + yy);
        r2(isnan(r2)) = 0;r2(isinf(r2)) = 0;
        R2fit=exp(-r2.*imDataParams.TE);
        a2=a.*exp(-r2.*imDataParams.TE);
        Bfit=[R2fit.*ones(6,1) zeros(6,1) real(a2) imag(a2);zeros(6,1) R2fit.*ones(6,1) -imag(a2) real(a2)];
        Bfitinv=pinv(Bfit);
        S_real=real(s)';
        S_imag=imag(s)';
        S_q=[S_real S_imag];
        W2=S_q*Bfitinv(1:2,:).';
        F2=S_q*Bfitinv(3:4,:).';
        W22=W2(1)+1i*W2(2);
        F22=F2(1)+1i*F2(2);
        amps=[W2,F2];
        S_hat=amps*Bfit';
        for nn=1:6
            shat(nn,:)=S_hat(nn)+1i*S_hat(nn+6);
        end
        error(kx,ky,:,k)=norm(s - shat,'fro');
        if (error(kx,ky,:,k) <= reltol); %if less than tolerance break
            br=1;
        end
        s=shat;
        end
        Wcslice(kx,ky)=W22;
        Fcslice(kx,ky)=F22;
        R2mapslice(kx,ky)=r2;
end
end
end
%%
%[wcr2 fcr2 ffcr2]=fatfraction(Wcr2,Fcr2);
%imlook3d(abs(wcr2));
%imlook3d(abs(fcr2));
%figure;imshow3D(abs(ffcr2),[0 100]);axis equal tight off;colormap(gray);colorbar; 