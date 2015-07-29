FUNCTION PLANCKUV,l,freq,T

;l can be in terms of frequency or wavelength

;100,10000,20000
;0 - 1210

pi=3.1415926
h=6.626d-34  ;m^2 kg/s
c=3d08 ;m/s
k=1.38d-23 ;m^2 kg s^-2 K^-1
;v=3.29d15 ;s^-1
;T=1000  ;vary temeperature

Blambda=dblarr(n_elements(T),n_elements(l))
Bfreq=dblarr(n_elements(T),n_elements(l))
for i=0,n_elements(T)-1 do begin
for j=0,n_elements(l)-1 do begin
Blambda[i,j]=(2*h*c^2)/(l[j]^5)*(exp(h*c/(l[j]*k*T[i]))-1)^(-1) ;for flux l space
;Buv=(2*c)/(l^4)*(exp(h*c/(l[j]*k*T))-1)^(-1) ;n photons for stromgren
;sphere calculation
Bfreq[i,j]=((2*h*freq[j]^3)/(c^2))*(1/(exp(h*freq[j]/(k*T[i]))-1)) ;for flux in v space
endfor
endfor

RETURN,[Blambda,Bfreq] ;UNITS  W/(m2 sr Hz) or W/(m2 sr m)

END
