PRO galex_exposed

;NUV
readcol,'SC_UVcat.txt',f='X,f,f,X,X,X,f,X,f',ra_nuv,dec_nuv,fluxUV,sn,/silent
restore,'repeats.sav'
ra_nuv=ra_nuv[where(repeats eq 0)] ;remove repeats
dec_nuv=dec_nuv[where(repeats eq 0)]
glactc,ra_nuv,dec_nuv,2000,long_nuv,lat_nuv,1,/DEGREE

;select uv bright ones
fluxUV=fluxUV[where(fluxUV gt 0)]
fluxunits=fluxUV*(2312)*10d-3 ;gives SI units
lum=fluxunits*4*!pi*(3.39d20)^2 ;gives luminosity. distance of smith cloud is 4.27d20m
index=where(lum gt 2d27)
long_nuv=long_nuv[index]
lat_nuv=lat_nuv[index]
sn=sn[index]
fluxUV=fluxUV[index]

;WISE
readcol,'star_tables/entiresc_wise2.tbl',f='X,f,f',ra_wise,dec_wise,/silent
glactc,ra_wise,dec_wise,2000,long_wise,lat_wise,1,/DEGREE
srcor,r,d,r[i],d[i],dcr,i1,i2,spherical=1,/silent

;2MASS
readcol,'star_tables/entiresc_2mass.tbl',f='X,f,f,X,X,X,X,X,f,X,X,X,f,X,X,X,f',ra_2mass,dec_2mass,j,h,k,/silent
glactc,ra_2mass,dec_2mass,2000,long_2mass,lat_2mass,1,/DEGREE

;select only UV bright ones/cross match with UV bright
;srcor,long_2mass,lat_2mass,long_nuv,lat_nuv,10,obind_2mass,obind_nuv,spherical=2,option=1
restore,'obind_2mass.sav'
long_2mass=long_2mass[obind_2mass]
lat_2mass=lat_2mass[obind_2mass]

;select O & B stars
obindex=where((j-h) lt -.04); and (h-k) lt .02) ;pick out O,B stars
j_ob=j[obindex]
h_ob=h[obindex]
k_ob=k[obindex]
long_2mass_ob=long_2mass[obindex]
lat_2mass_ob=lat_2mass[obindex]

im=readfits('smithmoment.sin.fits',hdr)
plotfits,im,hdr,title='smithcloud',/decima,/logari,ctable=0
plotsym,3,1.5,/fill
plots,long_2mass_ob,lat_2mass_ob,psym=8,color=80



stop


END
