function [Wmslice,Fmslice]=magn_fit(Wc,Fc,S0,a,reltol,max_iter,matrix_size,slicenum)
%for slicenum=1:matrix_size(3)
MIms=permute(S0(:,:,slicenum,:),[1 2 3 5 4]);


for kx=1:matrix_size(1)
    for ky=1:matrix_size(2)
        B=[ones(6,1) a];
        s=reshape(squeeze(MIms(kx,ky,:,:)),[1 6]).';
        amps0(1,:)=Wc(kx,ky,slicenum);
        amps0(2,:)=Fc(kx,ky,slicenum);
        magn0 = abs(amps0);
        [maxval,maxi] = max(magn0);
        phi0 = angle(amps0(maxi));
        magn0 = real(amps0*exp(-i*phi0));
        amps(1,:)=magn0(1);
        amps(2,:)=magn0(2);
        for k=1:max_iter
        C=zeros(6,2);
        for t=1:6
            Magn(t,:)=amps(1).^2+amps(2).^2*abs(a(t)).^2+2.*amps(1).*amps(2)*real(a(t));
            C(t,1)=2*amps(1)+2*real(a(t))*amps(2);
            C(t,2)=2*abs(a(t)).^2*amps(2)+2*real(a(t))*amps(1);
            CC=pinv(C);
        end
        Wer=CC(1,:)*(abs(s(1:end))-abs(Magn(1:end)));
        Fer=CC(2,:)*(abs(s(1:end))-abs(Magn(1:end)));
        ampshat(1,:)=Wer;
        ampshat(2,:)=Fer;
        remerror= norm(abs(s) - abs(B*squeeze(amps)),'fro');
        amps=amps+ampshat;
        if (remerror <= reltol); %if less than tolerance break
            break
        end
        end
        Wmslice(kx,ky)=amps(1);
        Fmslice(kx,ky)=amps(2);
    end
end
end