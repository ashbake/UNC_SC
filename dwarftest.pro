PRO DWARFTEST 

;to predict the magnitude of stars at smith cloud 
;to find the magnitude of a star of known distance and temp if at S.C.
;compile: 
; .r planckUV
; .r trap

radius=[.4,.82,1.4,2.5,3.,3.8,5.,7.4,10.,12.,35.] ;in solar radii
temp=[3000,5000.,7000.,10000,12000.,17000.,25150.,30000.,38000.,43600.,50000.] ;Kelvin
radius=radius*6.95d8 ;in meters
sarea=4*!pi*radius^2    ;in meters squared
trap,temp,Blambda,Bfreq,fluxdenslambda,fluxdensfreq

lumdens=sarea*fluxdensfreq
flux_si=lumdens/(4*!pi*(3.39d20)^2) ;find fluxdens as if from smith cloud
flux=flux_si*10^3 ;go from SI to units of erg/sec cm2 Hz

abmag=-2.5*alog10(flux)-48.6
vegamag=-2.5*alog10(flux_si/(729.9d-26)) ;convert to Jansky

;hd 23471 
p=58.17d-3 ;arcsec
j=5.053
h=8.368
k=8.336
d=1./p ;parsec
dsc=11000. ;pc dist to smith cloud

  ;absolute magnitude
  jabs=j-5.*(alog10(d)-1.)
  habs=h-5.*(alog10(d)-1.)
  kabs=k-5.*(alog10(d)-1.)

  ;apparent from S.C.
  jsc=jabs-5*(1.-alog10(dsc))
  hsc=habs-5*(1.-alog10(dsc))
  ksc=kabs-5*(1.-alog10(dsc))

print,'jsc' , jsc
print,'temp',temp
print,'abmag',abmag
print,'vegamag', vegamag

stop
forprint,temp,vegamag,abmag,textout='Ks_mags.txt',comment='Ks magnitudes using dwarftest for a range of temperatures'

stop



END
