;PRO colorplot

;CORE OR CONTROL REGION??

want='core'
;want='core2'
;want='control'


;GALEX DATA

;readcol,'SC_UVcat.txt',f='X,d,d,X,X,X,f,f,f',ra_nuv,dec_nuv,fluxUV,nuvmag,sn,/silent
restore,'repeats.sav'
restore,'dec_nuv.sav'
restore,'ra_nuv.sav'
restore,'nuvmag.sav'

readcol,'ais_frames/ais_allframes.txt',f='D,D,X,X,X,X,X,D',ra,dec,nuv_mag,delimiter='|'
;ra_nuv=ra_nuv[where((repeats eq 0) and (nuvmag gt -100))] ;remove repeats
;dec_nuv=dec_nuv[where((repeats eq 0) and (nuvmag gt -100))]
;nuvmag=nuvmag[where((repeats eq 0) and (nuvmag gt -100))]

ra_nuv=[ra,ra_nuv]
dec_nuv=[dec,dec_nuv]
nuvmag=[nuv_mag,nuvmag]

;WISE NOT IN CORE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IF want EQ 'control' THEN BEGIN
;readcol,'wise_reg4.tbl',f='X,d,d,X,X,X,f,f,X,X,f,f,X,X,f,f,X,X,f,f,X,X,X,X,X,X,X,X,A,f,X,X,X,X,X,X,X,X,X,X,X,f,X,f,X,f,X',ra,dec,w1,w1sig,w2,w2sig,w3,w3sig,w4,w4sig,ccf,ex,J,H,K
;werr=sqrt(w1sig^2.+w2sig^2.)
;x=where(ccf eq '0000' and ex eq 0)
restore,filename='rac_wise.sav'
restore,filename='decc_wise.sav'
restore,filename='w1c.sav'      
restore,filename='w2c.sav'
restore,filename='w3c.sav'
restore,filename='w4c.sav'
restore,filename='jc.sav'    
restore,filename='hc.sav'
restore,filename='kc.sav'

;rac_wise=rac_wise/15.
;ra_nuv=ra_nuv/15.
;srcor,rac_wise,decc_wise,ra_nuv,dec_nuv,5,ind1c,ind2c,option=1,spherical=1
restore,filename='ind1c.sav'
restore,filename='ind2c.sav'

w1=w1c[ind1c]
w2=w2c[ind1c]
w3=w3c[ind1c]
w4=w4c[ind1c]
nuvmag=nuvmag[ind2c]
ra_wise=15*rac_wise[ind1c]
dec_wise=decc_wise[ind1c]
ra_nuv=15*ra_nuv[ind2c]
dec_nuv=dec_nuv[ind2c]
j=jc[ind1c]
h=hc[ind1c]
k=kc[ind1c]

ENDIF


;CORE2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



IF want EQ 'core2' THEN BEGIN
;readcol,'wise_reg2.tbl',f='X,d,d,X,X,X,f,f,X,X,f,f,X,X,f,f,X,X,f,f,X,X,X,X,X,X,X,X,A,f,X,X,X,X,X,X,X,X,X,X,X,f,X,f,X,f,X',ra2_wise,dec2_wise,w12,w1sig2,w22,w2sig2,w32,w3sig2,w42,w4sig2,ccf,ex,J2,H2,K2
;readcol,'wise_reg1.tbl',f='X,d,d,X,X,X,f,f,X,X,f,f,X,X,f,f,X,X,f,f,X,X,X,X,X,X,X,X,A,f,X,X,X,X,X,X,X,X,X,X,X,f,X,f,X,f,X',ra1_wise,dec1_wise,w11,w1sig1,w21,w2sig1,w31,w3sig1,w41,w4sig1,ccf1,ex1,J1,H1,K1

;ra2_wise=[ra2_wise,ra1_wise]
;dec2_wise=[dec2_wise,dec1_wise]
;w12=[w12,w11]
;w22=[w22,w21]
;w32=[w32,w31]
;w42=[w42,w41]
;j2=[j2,j1]
;h2=[h2,h1]
;k2=[k2,k1]
;ccf=[ccf,ccf1]
;ex=[ex,ex1]

;werr=sqrt(w1sig^2.+w2sig^2.)
;x=where(ccf eq '0000' and ex eq 0)
restore,filename='ra2_wise.sav'
restore,filename='dec2_wise.sav'
restore,filename='w12.sav'      
restore,filename='w22.sav'
restore,filename='w32.sav'
restore,filename='w42.sav'
restore,filename='j2.sav'    
restore,filename='h2.sav'
restore,filename='k2.sav'

;;ra2_wise=ra2_wise/15.
;;ra_nuv=ra_nuv/15.
;srcor,ra2_wise,dec2_wise,ra_nuv,dec_nuv,5,ind12,ind22,option=1,spherical=1
;save,filename='ind12.sav'
;save,filename='ind22.sav'

restore,filename='ind1c2.sav'
restore,filename='ind2c2.sav'
ind1=ind12
ind2=ind22
ra2_wise=ra2_wise*15.
ra_nuv=ra_nuv*15.

w1=w12[ind1]
w2=w22[ind1]
w3=w32[ind1]
w4=w42[ind1]
nuvmag=nuvmag[ind2]
ra_wise=ra2_wise[ind1]
dec_wise=dec2_wise[ind1]
ra_nuv=ra_nuv[ind2]
dec_nuv=dec_nuv[ind2]
j=j2[ind1]
h=h2[ind1]
k=k2[ind1]

ENDIF





;VARIABLES WITH REMOVED CONFUSED SOURCES AND POSSIBLY EXTENDED

;CORE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IF want EQ 'core' THEN BEGIN
;readcol,'wise_reg3.tsv',f='X,d,d,X,X,X,X,X,X,X,f,f,f,f,f,f,f,f,f,X,f,X,f,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,A,f',ra,dec,w1,w1sig,w2,w2sig,w3,w3sig,w4,w4sig,J,H,K,ccf,ex
;werr=sqrt(w1sig^2.+w2sig^2.)
;x=where(ccf eq '0000')
;ex=ex[x]
;y=where(ex eq 0)
restore,filename='ra_wise.sav'
restore,filename='dec_wise.sav'
restore,filename='w1.sav'      
restore,filename='w2.sav'
restore,filename='w3.sav'
restore,filename='w4.sav'
restore,filename='w4sig.sav'
restore,filename='w3sig.sav'
restore,filename='w2sig.sav'
restore,filename='w1sig.sav'
restore,filename='j.sav'    
restore,filename='h.sav'
restore,filename='k.sav'

;ra_wise=ra_wise/15.
;ra_nuv=ra_nuv/15.
;srcor,ra_wise,dec_wise,ra_nuv,dec_nuv,5,ind1,ind2,option=1,spherical=1
;save,ind1,filename='ind1.sav'
;save,ind2,filename='ind2.sav'
restore,filename='ind1.sav'
restore,filename='ind2.sav'
;##to see discrepancy from srcor##
;plot,ra_wise[ind1]-ra_nuv[ind2]
;plot,dec_wise[ind1]-dec_nuv[ind2]

w1=w1[ind1]
w2=w2[ind1]
w3=w3[ind1]
w4=w4[ind1]
nuvmag=nuvmag[ind2]
ra_wise=ra_wise[ind1]
dec_wise=dec_wise[ind1]
ra_nuv=ra_nuv[ind2]
dec_nuv=dec_nuv[ind2]
j=j[ind1]
h=h[ind1]
k=k[ind1]

ENDIF



;######error on wise w1-w2#########
;######color cuts from sythetic data: gal-w1 < -1 and w1-w2 < -.6######

;plot,w1-w2,nuvmag-w1,psym=3,xtitle='w1-w2',ytitle='nuv - w1',xrange=[-2,3]
;obc=where((nuvmag - w1 le 1.8) and (w1-w2 le -.04))
;oplot,w1[obc]-w2[obc],nuvmag[obc]-w1[obc],color=255,psym=2
;plot,h[obc]-k[obc],j[obc]-h[obc],psym=2


;#####################DUST######################
GLACTC,ra_wise,dec_wise,2000,gl,gb,1,/DEGREE
ebv=dust_getval(gl,gb,ipath='./schlegel/',/interp)
;cardelli 1989
w1_x=1./3.4 ;um^-1
w2_x=1./4.6
w3_x=1./12.
w4_x=1./22.
nuv_x=1/.23157
;a coefficients
a_nuv=1.752-0.316*nuv_x-0.104/((nuv_x-4.67)^2 + 0.341)
a_w1=.574*w1_x^1.61
a_w2=.574*w2_x^1.61
a_w3=.574*w3_x^1.61
a_w4=.574*w4_x^1.61
;b coefficients
b_nuv=-3.09 + 1.825*nuv_x + 1.206/((nuv_x - 4.62)^2 + .263)
b_w1=-.527*w1_x^1.61
b_w2=-.527*w2_x^1.61
b_w3=-.527*w3_x^1.61
b_w4=-.527*w4_x^1.61
;A = Ebv ?
anuv_ebv=3.24*(a_nuv + b_nuv/3.1)
aw1_ebv=3.24*(a_w1 + b_w1/3.1)
aw2_ebv=3.24*(a_w2 + b_w2/3.1)
aw3_ebv=3.24*(a_w3 + b_w3/3.1)
aw4_ebv=3.24*(a_w4 + b_w4/3.1)
aj_ebv=0.902
ah_ebv=0.576
ak_ebv=0.367

anuv=ebv*anuv_ebv
aw1=ebv*aw1_ebv
aw2=ebv*aw2_ebv
aw3=ebv*aw3_ebv
aw4=ebv*aw4_ebv
aj=ebv*aj_ebv
ah=ebv*ah_ebv
ak=ebv*ak_ebv

;new corrected magnitudes
nuvmag=nuvmag-anuv
w1=w1-aw1
w2=w2-aw2
w3=w3-aw3
w4=w4-aw4
j=j-aj
h=h-ah
k=k-ak

;new unreddened plot

obc=where((nuvmag - w1 le 1.8) and (w1-w2 le -.04)); and (j-h lt .07) and (h-k lt .07))
;overplot 2mass bright ones
jo=j[obc]
ho=h[obc]
ko=k[obc]
w1o=w1[obc]
w2o=w2[obc]
nuvmago=nuvmag[obc]
z=where(jo-ho lt .07 and ho-ko lt .07 and jo gt 0 and ho gt 0 and ko gt 0) 
zz=where(jo lt 0 or ho lt 0 or ko lt 0)

;device,decompose=0
;window,1,xsize=700,ysize=500
stop
;set_plot,'ps'
device,decompose=1
;DEVICE, /encapsul,FILE='colorplot8.eps', /COLOR,font_size=14,/bold

plot,w1-w2,nuvmag-w1,psym=3,xtitle='W1-W2',ytitle='NUV - W1',title='Post Luminosity Cuts',xrange=[-1.5,1],yrange=[-3.0,15],ystyle=1,font=0,thick=1,charsize=1.2,/xthick,/ythick
device,decompose=0
loadct,39
plotsym,0,1.2,/fill
plots,w1[obc]-w2[obc],nuvmag[obc]-w1[obc],psym=8
plots,w1o[zz]-w2o[zz],nuvmago[zz]-w1o[zz],psym=8,color=254
plotsym,0,2
plots,w1o[z]-w2o[z],nuvmago[z]-w1o[z],psym=8

legend,['WISE Source','WISE Candidate','WISE source with 2MASS data','WISE & 2MASS Candidate'],psym=[3,2,2,88],/left,colors=[0,0,254,0]

;device,/CLOSE
;set_plot,'x'


stop
;apply luminosity cuts: 7<nuvmago<16.43
;set_plot,'ps'
;device,decompose=1
;DEVICE, /encapsul,FILE='colorplot8.eps', /COLOR,font_size=14,/bold


cuts=where(nuvmago lt 16.44 and nuvmago gt 7 and w1o lt 15.86); and jo lt 14.16); and jo gt 0)
w1c=w1o[cuts]
w2c=w2o[cuts]
nuvmagc=nuvmago[cuts]
jc=jo[cuts]
hc=ho[cuts]
kc=ko[cuts]
ra=ra_nuv[obc]
dec=dec_nuv[obc]
rac=ra[cuts]
decc=dec[cuts]
glo=gl[obc]
gbo=gb[obc]
glc=glo[cuts]
gbc=gbo[cuts]
z=where(jc lt 14.16 and jc gt 0)
zz=where(jc lt 0)
;window,2
plotsym,0,2

plot,w1-w2,nuvmag-w1,psym=3,xtitle='W1-W2',ytitle='NUV-W1',title='Candidate star colors after Luminosity Cuts',xrange=[-1.5,1],yrange=[-3.0,15],ystyle=1,font=0,thick=1,charsize=1.2,/xthick,/ythick
device,decompose=0
loadct,39
oplot,w1c-w2c,nuvmagc-w1c,color=250,psym=2

;oplot,w1c[zz]-w2c[zz],nuvmagc[zz]-w1c[zz],psym=2
;plots,w1c[z]-w2c[z],nuvmagc[z]-w1c[z],psym=8
legend,['WISE Source','Candidate Young Star'],psym=[3,2],/left,colors=[0,254]


stop
;#####################color plot synthetic in AB#############
readcol,'BaSeL2.2/W1_lbc96_m50.cor',f='X,f,X,f',w1mag,temp
readcol,'BaSeL2.2/W2_lbc96_m50.cor',f='X,f,X,f',w2mag,temp
readcol,'BaSeL2.2/GAL_lbc96_m50.cor',f='X,X,f,f',galmag,temp
readcol,'BaSeL2.2/R_lbc96_m01.cor',f='X,X,f,f',Rmag,temp
readcol,'BaSeL2.2/J_lbc96_m01.cor',f='X,X,f,f',Jmag,temp
device,decompose=1
y=where(temp gt 4400)
x=where(temp eq 10000)
z=483
for j=0,n_elements(y)-1 do begin
plots,w1mag[z-j-1]-w2mag[z-j-1],galmag[z-j-1]-w1mag[z-j-1],psym=2,color=[(j*255.)/z +50]
plots,w1mag[x]-w2mag[x],galmag[x]-w1mag[x],psym=7,color=255
endfor
legend,['WISE Source','Model Stars'],psym=[3,2],/left,colors=[0,0]

device,/close
set_plot,'x'

stop
plot,galmag[x]-rmag[x],rmag[x]-jmag[x],psym=3
plot,galmag-rmag,rmag-jmag,psym=3


readcol,'kurucz_models/mnrj_fm20k2.dat',f='f,X,X,X,X,f,f,f',temp,nuv,r,j
plot,nuv-r,r-j,psym=3
plot,nuv[x]-r[x],r[x]-j[x],psym=3

END
