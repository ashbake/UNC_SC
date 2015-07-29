PRO test

;plotfits,im,hdr,title='smithcloud',/decima,/logari,ctable=0,xrange=[42.8,36.8],yrange=[-15.6,-11]
;contour,image,nlevels=15,path_xy=xy,PATH_INFO=info;,xmid=xmid,ymid=ymid
fits_read,'smithmoment.sin.fits',im,hdr

sz=size(im)   ;im is your HI map

;possible x and y values:
xarr=findgen(sz[1])
yarr=findgen(sz[2])

;turn these into x and y values at each grid point

xmatrix=fltarr(sz[1],sz[2])
ymatrix=fltarr(sz[1],sz[2])
for i=0,sz[2]-1 do xmatrix[*,i]=xarr
for i=0,sz[1]-1 do ymatrix[i,*]=yarr
;double check these to see if they are working right

N = 5
rms = 9.
oncloud = im gt N*rms
sel=where(oncloud)
pixelscale=.03
driftrad = 0.5   ;0.5 degree drift radius assumed (you'd put whatever here)
driftrad = driftrad/pixelscale  ;use the pixel scale to turn the radius unto pixels

for i=0,n_elements(sel)-1 do begin
dist_ellipse,circle,sz[1:2],xmatrix[sel[i]],ymatrix[sel[i]],1,0
oncloud[where(circle lt driftrad)]=1   ;remember drift rad should be in pixels
endfor

stop

;this loop just shows how to get the x,y coordinates to an individual
;contour, then plots that contour.



FOR I = 0, (N_ELEMENTS(info) - 1) DO BEGIN $
   S = [INDGEN(info(I).N), 0] & $
   PLOTS, xy(*,INFO(I).OFFSET + S ), /NORM,thick=1.5
ENDFOR

   S = [INDGEN(INFO(3).N), 0]
   myim=xy(*,INFO(3).OFFSET + S ) ;contour of interest
   xc=myim[0,*]
   yc=myim[1,*]

stop
N=5
skynoise=9
pixelscale=.03 ;deg/pix
sz=size(image)  ;I'm assuming 'image'  is the Smith Cloud 0-moment map
oncloud=image gt N*skynoise ;just says the region on the cloud is > some value 

driftrad = 10   ;0.5 degree drift radius assumed (you'd put whatever here)
driftrad = driftrad/pixelscale  ;use the pixel scale to turn the radius unto pixels

for i=0,n_elements(xc)-1 do begin
    ;for each point on the contour, define a circle...the dist_ellipse routine works here
    dist_ellipse,circle,sz[1:2],xc[i],yc[i],1,0
    oncloud[where(circle lt driftrad)]=1   ;add region the star could drift to into the "on" region
endfor
    


stop
END
