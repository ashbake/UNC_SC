

im=readfits('smithmoment.sin.fits',hdr)
plotfits,im,hdr,title='smithcloud',/decima,/logari,ctable=0,xrange=[42.8,36.8],yrange=[-15.6,-12]

restore,'dec_nuv.sav'
restore,'ra_nuv.sav'
GLACTC,ra_nuv,dec_nuv,2000,gl,gb,1,/DEGREE

;plots,gl,gb,psym=3

readcol,'hotstars.txt',gl,gb,numline=30,skipline=91   ;read in 15 'good' star candidates (these are in galactic coordinates already)
;GLACTC,ra,dec,2000,gl,gb,1,/DEGREE       ;if read in ra & dec, need to convert

plotsym,3,2,/fill
plots,gl,gb,psym=8,symsize=2,color=254

;plotfits,im,hdr,title='smithcloud',/decima,/logari,ctable=0,xrange=[40,35],yrange=[-16,-11]

END
