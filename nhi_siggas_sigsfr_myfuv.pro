pro nhi_siggas_sigsfr_mufuv,nhi,incl

;INPUTS:
;nhi = N(HI) [cm^-2]
;incl= inclination [deg]

;conversion of N(HI) to Sigma(gas), applying 1.36 factor to allow for
;Helium, but no molecular contribution here
sighi=nhi/1.823d18*cos(incl/180.*acos(-1.))*0.02 ; msun pc^-2

;Schmidt law (Sigma(gas)-->Sigma(SFR))
sigsfr=2.5d-4*(sighi^1.4) ;from Kennicutt 1998 (Global Schmidt law paper)
logsigsfr=alog10(sigsfr) ;log10(msun yr^-1 kpc^-2)

;fold in the GALEX calibration and SFR conversion
;assumes SFR conversion factor of 1.4d-28 for K89 (ARA&A article)
mufuv=-2.5*(logsigsfr-7.413) 

print,'N(HI) = ',nhi,' cm^-2'
print,'inclination = ',incl,' deg'
print,'Sigma(HI) = ',sighi,' Msun pc^-2'
print,'Sigma(SFR) = ',sigsfr,' Msun yr^-1 kpc^-2'
print,'FUV s.b. = ',mufuv,' ABmag arcsec^-2'

end
