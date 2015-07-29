PRO TRAP,T,Blambda,Bfreq,fluxdenslambda,fluxdensfreq

;compile .r planckUV.pro
;choose from GALEX_NUV.txt or WISE_W1/2/3/4.txt or 2MASS_Ks/H/J.txt
;convert Angstroms 1d-10 to meters NOTE wise in microns so use 1d-6

readcol,'txtfiles/2MASS_Ks.txt',f='f,f',wavelength,percent  ;

l=wavelength*1d-10 ;convert Angstroms 1d-10 to meters NOTE old wise in microns so use 1d-6 if using files in blackbody folder?
freq=(3d8)/l ;Hertz

B=planckUV(l,freq,T) ;result in dimensions: i(temp),j(wavelength)
sizet=n_elements(T)
Blambda=2*!Pi*B[0:sizeT-1,*] ;W m-2 m-1
Bfreq=2*!Pi*B[sizeT:2*sizeT-1,*] ;W m-2 Hz-1

      plot,l,Blambda[1,*],xtitle='wavelength (m)',  $
           ytitle='radiance (W/m^2 s)',title='Galex NUVfilter', $
           xmargin=[15,5],thick=3

ylambda=dblarr(n_elements(T),n_elements(wavelength))
yfreq=dblarr(n_elements(T),n_elements(wavelength))

for i=0,n_elements(T)-1 do begin
   ylambda(i,*)=Blambda(i,*)*percent ;planck function for range of l corrected
   yfreq(i,*)=Bfreq(i,*)*percent     ;planck function for range of l corrected
endfor

oplot,l,ylambda[0,*],thick=3

Blambda=0
Bfreq=0
Blambda=dblarr(n_elements(T))
Flambda=dblarr(n_elements(T))
Bfreq=dblarr(n_elements(T))
Ffreq=dblarr(n_elements(T))


for j=0,n_elements(T)-1 do begin
   for i=0,n_elements(wavelength)-2 do begin
      Blambda[j]=Blambda[j]+(l[i+1]-l[i])*(ylambda[j,i]+ylambda[j,i+1])/2 ;sum using trapezoids
      Flambda[j]=Flambda[j]+(l[i+1]-l[i])*(percent[i+1]+percent[i])/2

      Bfreq[j]=Bfreq[j]+(freq[i+1]-freq[i])*(yfreq[j,i]+yfreq[j,i+1])/2 
      Ffreq[j]=Ffreq[j]+(freq[i+1]-freq[i])*(percent[i+1]+percent[i])/2
   endfor
endfor
fluxdenslambda=Blambda/Flambda
      print,Blambda                   ;W m-2
      print,fluxdenslambda            ;W m-2 m-1
fluxdensfreq=Bfreq/Ffreq
      print,Bfreq                     ;W m-2
      print,fluxdensfreq              ;W m-2 Hz-1
;stop
END
