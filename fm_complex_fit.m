function [Wcfmslice,Fcfmslice,fmmapslice]=fm_complex_fit(S0slice,a,reltol,max_iter,matrix_size,imDataParams)
for kx=1:matrix_size(1)
            for ky=1:matrix_size(2)
         Ims=squeeze(S0slice(kx,ky,1,:));
         s=Ims;
         shat=zeros(6,1);
         nechos=6;
         M=Ims.';
         M= conj(M);%complex conjugate of signal
         Msize=size(M);
         Y=angle(M(:,1:min(3,nechos)));%phase_TE1_TE2_TE3
         c=((Y(:,2)-Y(:,1)));
         [m ind]=min([abs(c-2*pi),abs(c),abs(c+2*pi)],[],2);
         c(ind==1)=c(ind==1)-2*pi;
         c(ind==3)=c(ind==3)+2*pi;
         for n=1:min(2,nechos-1)
             cd=((Y(:,n+1)-Y(:,n)))-c;
             Y(cd<-pi,(n+1):end)=Y(cd<-pi,n+1:end)+2*pi;
             Y(cd>pi,(n+1):end)=Y(cd>pi,n+1:end)-2*pi;
         end
         Afm = [1 0 ;1 1;1 2 ];
         ip = Afm(1:min(3,nechos),:)\Y(:,1:min(3,nechos))';
         p0 = ip(1,:);
         p1 = ip(2,:);
         dp1 = p1;
         tol = norm(p1(:))*reltol;%threshold
         iter = 0;
         % weigthed least square
         % calculation of WA'*WA
         v1=ones(1,nechos);
         v2=[0:(nechos-1)];
         a11=sum(abs(M).^2.*(ones(Msize(1),1)*(v1.^2)));%M^2
         a12=sum(abs(M).^2.*(ones(Msize(1),1)*(v1.*v2)));%MTE1^2*0+MTE2^2*1+MTE3^2*2+MTE4^2*3+MTE5^2*4+MTE6^2*5
         a22=sum(abs(M).^2.*(ones(Msize(1),1)*(v2.^2)));%MTE1^2*0+MTE2^2*(1^2)+MTE3^2*(2^2)+MTE4^2*(3^2)+MTE5^2*(4^2)+MTE6^2*(5^2)
         % inversion
         d=a11.*a22-a12.^2;
         ai11=a22./d;
         ai12=-a12./d;
         ai22=a11./d;
         for k=1:max_iter%linear fit
            W = abs(M).*exp(1i*(p0*v1 + p1*v2));%p0-initial phase;p1-first phase map
            % projection
            pr1=sum(conj(1i*W).*(ones(Msize(1),1)*v1).*(M-W));
            pr2=sum(conj(1i*W).*(ones(Msize(1),1)*v2).*(M-W));
            dp0=real(ai11.*pr1+ai12.*pr2);
            dp1=real(ai12.*pr1+ai22.*pr2);
            dp1(isnan(dp1))=0;
            dp0(isnan(dp0))=0;
            %update
            p1 = p1+dp1;
            p0 = p0+dp0;
            if norm(dp1)<tol
                break
            end
         end
         fmfit=exp(1i*2*pi*p1.*imDataParams.TE);
         a2=a.*exp(1i*2*pi*p1.*imDataParams.TE);
         Bfitfm=[fmfit.*ones(6,1) zeros(6,1) real(a2) imag(a2);zeros(6,1) fmfit.*ones(6,1) -imag(a2) real(a2)];
         Bfitinvfm=pinv(Bfitfm);
         S_real=real(s)';
         S_imag=imag(s)';
         S_q=[S_real S_imag];
         W2=S_q*Bfitinvfm(1:2,:).';
         F2=S_q*Bfitinvfm(3:4,:).';
         W22=W2(1)+1i*W2(2);
         F22=F2(1)+1i*F2(2);
         Wcfmslice(kx,ky)=W22;
         Fcfmslice(kx,ky)=F22;
         fmmapslice(kx,ky)=p1;
         end
end
end
%%
%[wcfm fcfm ffcfm]=fatfraction(Wcfm,Fcfm);
%imlook3d(abs(wcfm));
%imlook3d(abs(fcfm));
%figure;imshow3D(abs(ffcfm),[0 100]);axis equal tight off;colormap(gray);colorbar; 