function [w f ff]=fatfraction(W,F)
f=F;
w=W;
f(isnan(f))=0;
w(isnan(w))=0;
denom=(abs(f)+abs(w));
denom2=denom;
denom2(denom==0)=1;
ff=(100*abs(f))./denom2;
ffParams.noise_bias_correction=1;
if ffParams.noise_bias_correction>0
  fatregions = ff>50;
  watregions = ff<=50;
  denom2 = abs(f + w);
  denom2(denom==0) = 1; % To avoid divide-by-zero issues
  ff(watregions) = 100 - 100*abs(w(watregions))./denom2(watregions);
  ff(fatregions) = 100*abs(f(fatregions))./denom2(fatregions);
end
end