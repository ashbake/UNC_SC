springrarange=(15.75-8.75)*15. ; in deg
springdecrange=5. ; in deg
fallrarange=(24.-22.+3.)*15. ; in deg
falldecrange=2.*1.25 ; in deg
mpcperdegree = 2.*!pi*5750./70./360.
depth=(7000.-4500.)/70. ; in Mpc

springvol=springrarange*springdecrange*(mpcperdegree^2)*depth
fallvol=fallrarange*falldecrange*(mpcperdegree^2)*depth

totalvol_approx=springvol+fallvol
print,'total RESOLVE volume approx = ', totalvol_approx

;*********************************************************

sphere1volume=(4./3.)*!pi*(7000./70.)^3
sphere2volume=(4./3.)*!pi*(4500./70.)^3
sphere1filamentvolume=(4./3.)*!pi*(6600./70.)^3
sphere2filamentvolume=(4./3.)*!pi*(6400./70.)^3
falldecarray=dindgen(550)*0.005-1.25
fallraarray=dindgen(7501)*0.01d
springdecarray=dindgen(1000)*0.005d
springraarray=dindgen(10501)*0.01d
filamentraarray=dindgen(301)*0.01d
filamentdecarray=dindgen(1000)*0.005d
;check for area we know like half sphere/quarter sphere
;fallraarray=dindgen(18001)*.01d
;falldecarray=dindgen(18000)*.005d
;dec2dcorr=transpose(rebin(cos(falldecarray*!pi/180.),18000,18001))
;fallra2darray=rebin(fallraarray,18001,18000)*dec2dcorr

falldec2dcorr=transpose(rebin(cos(falldecarray*!pi/180.),550,7501))
fallra2darray=rebin(fallraarray,7501,550)*falldec2dcorr
springdec2dcorr=transpose(rebin(cos(springdecarray*!pi/180.),1000,10501))
springra2darray=rebin(springraarray,10501,1000)*springdec2dcorr
filamentdec2dcorr=transpose(rebin(cos(filamentdecarray*!pi/180.),1000,301))
filamentra2darray=rebin(filamentraarray,301,1000)*filamentdec2dcorr


;; collapse this over ra
;;dy=FLTARR(N_ELEMENTS(fallraarray),N_ELEMENTS(falldecarray)) ;
;;don't need this
falldx=DBLARR(N_ELEMENTS(fallraarray)-1,N_ELEMENTS(falldecarray))
springdx=DBLARR(N_ELEMENTS(springraarray),N_ELEMENTS(springdecarray))
filamentdx=DBLARR(N_ELEMENTS(filamentraarray),N_ELEMENTS(filamentdecarray))
FOR i=0,N_ELEMENTS(fallraarray)-2 DO BEGIN
   falldx[i,*]=fallra2darray[i+1,*]-fallra2darray[i,*]

ENDFOR

FOR i=0,N_ELEMENTS(springraarray)-2 DO BEGIN
   springdx[i,*]=springra2darray[i+1,*]-springra2darray[i,*]
ENDFOR

FOR i=0,N_ELEMENTS(filamentraarray)-2 DO BEGIN
   filamentdx[i,*]=filamentra2darray[i+1,*]-filamentra2darray[i,*]
ENDFOR
 
;FOR i=1,N_ELEMENTS(falldecarray)-2 DO BEGIN
;   dy[*,i]=-(fallra2darray[*,i+1]-fallra2darray[*,i])

;ENDFOR
;print,total(dx*.01)/(4.*!pi*3282.)
;stop

fallsolidangle=total(falldx*.005d)  ; deg
springsolidangle=total(springdx*.005d)  ; deg
filamentsolidangle=total(filamentdx*.005d)  ; deg
stop
; need conversion from deg to rad in solid angle
;totalvol_real=(sphere1volume-sphere2volume)*solidangle/(4.*!pi)
totalvol_real=(sphere1volume-sphere2volume)*(fallsolidangle/(4.*!pi*3282.) +springsolidangle/(4.*!pi*3282.)); steradian in deg
fallvol_real=(sphere1volume-sphere2volume)*(fallsolidangle/(4.*!pi*3282.)); steradian in deg
filamentvol_real=(sphere1filamentvolume-sphere2filamentvolume)*(filamentsolidangle/(4.*!pi*3282.)); steradian in deg

print,'Total RESOLVE volume method 1 = ', totalvol_real
print,'Fall RESOLVE volume method 1 = ', fallvol_real
print,'Filament volume method 1 = ', filamentvol_real

; need to add fall


;;;*******************************************************
falldec1=1.25
falldec2=-1.25
springdec1=5.0
springdec2=0.0
fallcirclefrac=5.*15./360. ; degrees of RA 22-3
springcirclefrac=7.*15./360. ; degrees of RA 8.75-15.75

distance=DINDGEN(103)*.35+4500./70.
surfaceareafall=2.*!PI*distance^2*(SIN(falldec1*!pi/180.)-SIN(falldec2*!pi/180.))*fallcirclefrac
surfaceareaspring=2.*!PI*distance^2*(SIN(springdec1*!pi/180.)-SIN(springdec2*!pi/180.))*springcirclefrac
ddistance=FLTARR(103)+.35
fallvol_2=TOTAL(surfaceareafall*ddistance)
springvol_2=TOTAL(surfaceareaspring*ddistance)
totalvol_2=fallvol_2+springvol_2
print,'total RESOLVE 2nd method  = ',totalvol_2


;jushrdec1=49.9452
;jushrdec2=-0.997650

;jushrcirclefrac=7.15*15./360. ; degrees of RA 22-3


;distance=FINDGEN(1000)*.071+2530./70.
;surfaceareajushr=2.*!PI*distance^2*(SIN(jushrdec1*!pi/180.)-SIN(jushrdec2*!pi/180.))*jushrcirclefrac
;ddistance=FLTARR(1000)+.071
;jushrvol_2=total(surfaceareajushr*ddistance)
;print,'total JUSHR 2nd method = ',jushrvol_2


;;;;;;;;;;;;;;;;;;;calculate JUSHR volume -> -17.5 limit for now
sphere1volume=(4./3.)*!pi*(7470./70.)^3
sphere2volume=(4./3.)*!pi*(2530./70.)^3
decarray=dindgen(10171)*0.005-1.d
raarray=dindgen(10741)*0.01d

;check for area we know like half sphere/quarter sphere
;fallraarray=dindgen(18001)*.01d
;falldecarray=dindgen(18000)*.005d
;dec2dcorr=transpose(rebin(cos(falldecarray*!pi/180.),18000,18001))
;fallra2darray=rebin(fallraarray,18001,18000)*dec2dcorr

dec2dcorr=transpose(rebin(cos(decarray*!pi/180.),10171,10741))
ra2darray=rebin(raarray,10741,10171)*dec2dcorr



;; collapse this over ra
dx=DBLARR(N_ELEMENTS(raarray)-1,N_ELEMENTS(decarray))

FOR i=0,N_ELEMENTS(raarray)-2 DO BEGIN
   dx[i,*]=ra2darray[i+1,*]-ra2darray[i,*]

ENDFOR
solidangle=total(dx*.005d)  ; deg
; need conversion from deg to rad in solid angle
totalvol_real=(sphere1volume-sphere2volume)*solidangle/(4.*!pi*3282.)
print,'JUSHR total volume = ', totalvol_real

end
