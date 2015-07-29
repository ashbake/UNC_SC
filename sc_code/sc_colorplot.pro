PRO sc_colorplot

;.r ../plotfits

;device,decompose=0
;window,1,xsize=700,ysize=500
;
;set_plot,'ps'
;device,decompose=1
;DEVICE, /encapsul,FILE='halomasslum.eps', /COLOR,font_size=14,/bold

;device,/CLOSE
;set_plot,'x'

;apply luminosity cuts: 7<nuvmago<16.43
;obc=where((nuvmag - w1 le 1.8) and (w1-w2 le -.04)); and (j-h lt .07) and (h-k lt .07))


;RESTORE FILES

restore,'dec_nuv_all.sav'
restore,'ra_nuv_all.sav'
restore,'nuvmag_all.sav'

restore,filename='ra_wise_all.sav'
restore,filename='dec_wise_all.sav'
restore,filename='w1_all.sav'      
restore,filename='w2_all.sav'
restore,filename='w3_all.sav'
restore,filename='w4_all.sav'
restore,filename='j_all.sav'    
restore,filename='h_all.sav'
restore,filename='k_all.sav'
;redefine variables so I don't have to rename all variables in program
dec_nuv  =  dec_nuv_all
ra_nuv   =  ra_nuv_all
nuvmag   =  nuvmag_all
ra_wise  =  ra_wise_all
dec_wise =  dec_wise_all
w1       =  w1_all    
w2       =  w2_all
w3       =  w3_all
w4       =  w4_all
j        =  j_all     
h        =  h_all
k        =  k_all
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DUST CORRECTION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLACTC,ra_wise,dec_wise,2000,gl,gb,1,/DEGREE
ebv=dust_getval(gl,gb,ipath='.././schlegel/',/interp)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;APPLY FIRST COLOR CUT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

obc=where((nuvmag - w1 le 1.8) and (w1-w2 le -.0) and (j-h lt 0) and (h-k lt .02))
;select objects w/ correct color. add o to name
    jo=j[obc]
    ho=h[obc]
    ko=k[obc]
    w1o=w1[obc]
    w2o=w2[obc]
    nuvmago=nuvmag[obc]
;z: j, h, k color cut   zz: objects w/ no j,h,k measurements
z=where(jo-ho lt .0 and ho-ko lt .02 and jo gt 0 and ho gt 0 and ko gt 0) 
zz=where(jo lt 0 or ho lt 0 or ko lt 0)

;plot sources that have right color
    plot,w1-w2,nuvmag-w1,psym=3,xtitle='W1-W2',ytitle='NUV - W1',       $
         title='Applied Color Cuts',xrange=[-1.5,.5],yrange=[-3.0,15],  $
         ystyle=1,font=0,thick=1,charsize=1.2,/xthick,/ythick
    device,decompose=0
    loadct,39
    plotsym,0,1.4,/fill
    plots,w1[obc]-w2[obc],nuvmag[obc]-w1[obc],psym=2
    plots,w1o[zz]-w2o[zz],nuvmago[zz]-w1o[zz],psym=2,color=254
    plotsym,0,2
    plots,w1o[z]-w2o[z],nuvmago[z]-w1o[z],psym=8,color=80
    legend,['GALEX/WISE Source','OB Candidate - GALEX/WISE cut',$
            'OB Candidate - Lacking 2MASS data',                $
            'OB Candidate - GALEX/WISE/2MASS cut'],             $
           psym=[3,2,2,8],/left,colors=[0,0,244,80],            $
           charsize=.8,charthick=1.3
stop
;;;;;;;;;;;;;;;;;;;;;;;;LUMINOSITY CUTS;;;;;;;;;;;;;;;;;;;;;;;;;;
; from dwarftest.pro 7<nuvmago<16.43

cuts=where(nuvmago lt 16.44 and nuvmago gt 7 and w1o lt 15.86 and jo lt 14.16); and jo gt 0)
     ;apply cuts. also fix ra,dec,gl,gb
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
     ;z - stars that are bright enough in J band
     ;zz - stars that don't have J band measurement
     z=where(jc lt 14.16 and jc gt 0)
     zz=where(jc lt 0)

;plot
plotsym,0,2
plot,w1-w2,nuvmag-w1,psym=3,xtitle='W1-W2',ytitle='NUV-W1', $
     title='Post Luminosity Cuts',xrange=[-1.0,0.5],        $
     yrange=[-3.0,13],ystyle=1,font=0,                      $
     thick=1,charsize=1.2,/xthick,/ythick

device,decompose=0
loadct,39
oplot,w1o-w2o,nuvmago-w1o,psym=1,color=254,symsize=1
oplot,w1c-w2c,nuvmagc-w1c,psym=4,color=75

;oplot,w1c[zz]-w2c[zz],nuvmagc[zz]-w1c[zz],psym=2
;plots,w1c[z]-w2c[z],nuvmagc[z]-w1c[z],psym=8
legend,['WISE/GALEX Source','OB Candidates Post Color Cuts','OB Candidates Post Luminosity Cuts'],psym=[3,1,4],/left,colors=[0,254,75],charsize=.8
stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;OVERPLOT ON SC;;;;;;;;;;;;;;;;;;;;;;;;;;


im=readfits('../smithmoment.sin.fits',hdr)
;.r ../plotfits            (MUST COMPILE THIS FIRST!)
plotfits,im,hdr,title='smithcloud',/decima,/logari,ctable=0,xrange=[42.8,36.8],yrange=[-15.6,-11.5]
plotsym,3,2,/fill
;readcol,'../hotstars.txt',gl_fin,gb_fin,numline=33,skipline=56
;plots,gl_fin,gb_fin,psym=8,symsize=2,color=254
plots,glc,gbc,psym=8,symsize=2,color=200
stop
readcol,'../hotstars.txt',gl_cut,gb_cut,numline=23,skipline=91

plotfits,im,hdr,title='smithcloud',/decima,/logari,ctable=0,xrange=[42.8,36.8],yrange=[-15.6,-11]
plots,gl_cut,gb_cut,psym=8,symsize=2,color=200





 RAs=[296.518,      298.000 ,     297.152   ,   297.880    ,  299.632   ,   297.809,      297.152]
DECs=[ -1.43800 ,    -1.55100   ,  -2.05294 ,   -0.302000 ,    0.131059 ,    -2.44514,     -1.01294]
GLACTC,ras,decs,2000,gls,gbs,1,/DEGREE

stop
;#####################color plot synthetic in AB#############?????
readcol,'../BaSeL2.2/W1_lbc96_m01.cor',f='X,f,X,f',w1mag,temp
readcol,'../BaSeL2.2/W2_lbc96_m01.cor',f='X,f,X,f',w2mag,temp
readcol,'../BaSeL2.2/gal_lbc96_m01.cor',f='X,X,f,f',galmag,temp
readcol,'../BaSeL2.2/R_lbc96_m01.cor',f='X,X,f,f',Rmag,temp
readcol,'../BaSeL2.2/J_lbc96_m01.cor',f='X,X,f,f',Jmag,temp
device,decompose=1
y=where(temp gt 4400)
x=where(temp eq 10000)
z=453
plot,w1-w2,nuvmag-w1,psym=3,xtitle='W1-W2',ytitle='NUV-W1', $
     title='GALEX-WISE Color Plot with Model Colors',       $
     xrange=[-1.5,1],                                       $
     yrange=[-3,15],ystyle=1,font=0,                        $
     thick=1,charsize=1.2,/xthick,/ythick

plotsym,0
plots,w1mag-w2mag,galmag-w1mag,psym=8,color=230

for j=0,(n_elements(y)-1)/3 do begin
plots,w1mag[z-3*j-1]-w2mag[z-3*j-1],galmag[z-3*j-1]-w1mag[z-3*j-1],psym=8,color=240;[(j*255.)/z +50]
 plots,w1mag[x]-w2mag[x],galmag[x]-w1mag[x],psym=1,color=255
endfor
legend,['WISE/GALEX Source','Model Stars'],psym=[3,8],/left,colors=[0,240]

device,/close
set_plot,'x'

stop
plot,galmag[x]-rmag[x],rmag[x]-jmag[x],psym=3
plot,galmag-rmag,rmag-jmag,psym=3


readcol,'kurucz_models/mnrj_fm20k2.dat',f='f,X,X,X,X,f,f,f',temp,nuv,r,j
plot,nuv-r,r-j,psym=3
plot,nuv[x]-r[x],r[x]-j[x],psym=3

END
