fallraarray=dindgen(802)*0.006 + 295.5
falldecarray=dindgen(766)*0.005d - 3.05

falldec2dcorr=transpose(rebin(cos(falldecarray*!pi/180.),766,802))
fallra2darray=rebin(fallraarray,802,766)*falldec2dcorr

falldx=DBLARR(N_ELEMENTS(fallraarray)-1,N_ELEMENTS(falldecarray))

FOR i=0,N_ELEMENTS(fallraarray)-2 DO BEGIN
   falldx[i,*]=fallra2darray[i+1,*]-fallra2darray[i,*]
ENDFOR

fallsolidangle=total(falldx*.005d)  ; deg

;18.399927
;w/out cosine 18.3830
END
