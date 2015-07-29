PRO SC_CONTOUR

xvec=findgen(500)
yvec=findgen(500)


;matrix of x values
xmat=fltarr(500,500)
ymat=fltarr(500,500)
for i=0,n_elements(xvec)-1 do xmat[*,i]=xvec
for i=0,n_elements(yvec)-1 do ymat[i,*]=yvec

;define a 2d gaussian or something..
zmat=exp(-((xmat-250)^2+(ymat-250)^2)/2/20.^2)

fits_read,'/srv/two/ashbake/smithcloud/smithmoment.sin.fits',im,hdr
;plotfits,im,hdr,title='smithcloud',/decima,/logari,invers,encaps,ctable=0,xrange=[42.8,36.8],yrange=[-15.6,-12]
contour,im,nlevels=15,path_xy=xy,PATH_INFO=info,closed=0

;run contour command.  path_xy is variable that holds x,y coordinates for all contours,
;path_info holds info such as: contour level, length of each contour
;in path_xy, etc.

imcontour,im,hdr,nlevels=25,path_xy=xy,PATH_INFO=info;,xmid=xmid,ymid=ymid

;this loop just shows how to get the x,y coordinates to an individual
;contour, then plots that contour.

FOR I = 0, (N_ELEMENTS(info) - 1 ) DO BEGIN $
   S = [INDGEN(info(I).N), 0] & $
   PLOTS, xy(*,INFO(I).OFFSET + S ), /NORM,thick=1.5
ENDFOR

   S = [INDGEN(INFO(3).N), 0]
   myim=xy(*,INFO(3).OFFSET + S ) ;contour of interest
   xc=myim[0,*]
   yc=myim[1,*]
;define perpendicular slope
   myim_rshift = shift(myim,0,1)
   myim_lshift = shift(myim,0,-1)
   slope = (myim_rshift[1,*] - myim_lshift[1,*]) / (myim_rshift[0,*] - myim_lshift[0,*])
   normal = -1/slope
   xb=(myim_rshift[0,*] + myim_lshift[0,*])/2
   yb=(myim_rshift[1,*] + myim_lshift[1,*])/2
;equation of lines
   x=indgen(10)*.1-0.3
   size=size(myim)
   plot,myim[0,*],myim[1,*],psym=3,yrange=[0.4,0.75]

pixelscale=2.916666679000E-02  ;pix/deg
driftrad = 0.0348112   ;0.5 degree drift radius assumed (you'd put whatever here)
;driftrad = driftrad/pixelscale  ;use the pixel scale to turn the radius unto pix
 line = fltarr(2,size[2])

FOR i=0,42 DO  line[0,i] = driftrad/sqrt(1+(normal[0,i])^2) + xb[i] & $
 line[1,i] = (driftrad^2)/sqrt(1+(normal[0,i])^2) + yb[i]

 PLOT,myim[0,*],myim[1,*],psym=3,yrange=[0.4,0.75]
 
 PLOTS,line[0,*],line[1,*],psym=2
 ;PLOTS,x,normal[1]*(x-xc[1]) + yc[1]

;circ=ellipse(xc,yc,major=0.5)


stop


image=im
N=5  ;(chose to make skynoise * N about the pixel level once on the cloud)
skynoise=9 ;(determined by looking at fits file of image)
sz=size(image)  ;I'm assuming 'image'  is the Smith Cloud 0-moment map
oncloud=image gt N*skynoise ;just says the region on the cloud is > some value 

pixelscale=2.916666679000E-02  ;pix/deg

driftrad = 0.5  ;degrees
driftrad = driftrad/pixelscale  ;use the pixel scale to turn the radius unto pixels

for i=0,n_elements(xc)-1 do begin
    ;for each point on the contour, define a circle...the dist_ellipse routine works here
    dist_ellipse,circle,sz[1:2],xc[i],yc[i],1,0
    oncloud[where(circle lt driftrad)]=1   ;add region the star could drift to into the "on" region
 endfor


 ;tvscl,sqrt(alog10(1+im/threshold/rms)),channel=1
 ;tvscl,sqrt(alog10(1+maskim/threshold/rms)),channel=3



stop
END
