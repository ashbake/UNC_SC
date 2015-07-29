PRO galex_embedded


;NUV
readcol,'SC_UVcat.txt',f='X,f,f,X,X,X,f,X,f',ra_nuv,dec_nuv,fluxUV,sn,/silent
restore,'repeats.sav'
ra_nuv=ra_nuv[where(repeats eq 0)] ;remove repeats
dec_nuv=dec_nuv[where(repeats eq 0)]
glactc,ra_nuv,dec_nuv,2000,long_nuv,lat_nuv,1,/DEGREE


;2MASS
readcol,'entiresc_2mass.tbl',f='X,f,f,X,X,X,X,X,f,X,X,X,f,X,X,X,f',ra_2mass,dec_2mass,j,h,k,/silent
glactc,ra_2mass,dec_2mass,2000,long_2mass,lat_2mass,1,/DEGREE

;(FUTURE)APPLY LUM CUTS HERE

obindex=where((j-h) lt -.01 and (h-k) lt .02) ;pick out O,B stars
j_ob=j[obindex]
h_ob=h[obindex]
k_ob=k[obindex]
long_2mass_ob=long_2mass[obindex]
lat_2mass_ob=lat_2mass[obindex]

;WISE
readcol,'entiresc_wise2.tbl',f='X,f,f,X,X,X,f,X,X,X,f,X,X,X,f,X,X,X,f',ra_wise,dec_wise,w1,w2,w3,w4,/silent
glactc,ra_wise,dec_wise,2000,long_wise,lat_wise,1,/DEGREE

;(FUTURE) APPLY LUM CUTS HERE
;match OB stars and plot
srcor,long_wise,lat_wise,long_2mass_ob,lat_2mass_ob,10,ind_wise,ind_2mass,spherical=2,option=1
;;match wise data for 2mass sources
;restore,'ind_wise.sav'
;restore,'ind_2mass.sav'
stop
window,2
plot,w2-w1,w2,psym=3,xtitle='w2-w1',ytitle='w2' ;create wise color diagram
plotsym,0,.4,/fill

;color and plot
jtemp=fltarr(n_elements(w1))
htemp=fltarr(n_elements(w1))
jtemp[ind_wise]=j_ob[ind_2mass]
htemp[ind_wise]=h_ob[ind_2mass]
diff=(jtemp[ind_wise]-htemp[ind_wise])+abs(min(jtemp[ind_wise]-htemp[ind_wise]));shift it so all is positive. define based on j-h  
coloring=255*(diff)/(max(diff))
;higher color value => higher j-h and so cooler star
loadct,1

for i=0,n_elements(ind_wise)-1 do begin
plots,w2[ind_wise[i]]-w1[ind_wise[i]],w2[ind_wise[i]],psym=8,symsize=3,color=coloring[i] 
endfor ;the darker the color, the hotter the star

stop



;SHOW WHERE DATA USED LIES
im=readfits('smithmoment.sin.fits',hdr)
plotfits,im,hdr,title='smithcloud',/decima
;plots,long_wise,lat_wise,psym=3,color=255
;plots,long_2mass,lat_2mass,psym=3,color=100
;plots,long_nuv,lat_nuv,psym=3,color=40
;legend,['wise','2mass','nuv'],psym=[2,2,2],colors=[255,100,40]
;plots,long_wise[ind_wise],lat_wise[ind_wise],psym=2,color=160
ob_long=long_wise[ind_wise]
ob_lat=lat_wise[ind_wise]
srcor,ob_long,ob_lat,long_nuv,lat_nuv,10,uvbright_ob_ind,uvbright_nuv_ind,SPHERICAL=2
plots,ob_long[uvbright_ob_ind],ob_lat[uvbright_ob_ind],psym=2,color=100
stop

END
