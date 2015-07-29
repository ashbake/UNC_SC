PRO getgif,ra,dec,size

;ra and dec both in degrees
;size in 
;;;;;;;;;;;;;;;;;;optical;;;;;;;;;;;;;


ra=strtrim(string(ra),2)
dec=strtrim(string(dec),2)
size=strtrim(string(size),2)
url="http://stdatu.stsci.edu/cgi-bin/dss_search?v=poss2ukstu_red&r="+ra+"&d="+dec+"&e=J2000&h="+size+"&w="+size+"&f=gif&c=none&fov=NONE&v3="

filename="junk.gif"

spawn, 'wget -q -O '+ filename + " '" + url + "'"

read_gif,filename,im
im=congrid(im,300,300)
sz=size(im)
window,0,xsize=sz[1],ysize=sz[2],title='0 dss'
tvscl,im

;draw circle around target
rad=40 ;pixels
theta=findgen(360*2)*0.5*!dtor
x=rad*cos(theta)+.5*sz[1]
y=rad*sin(theta)+.5*sz[2]

plots,x,y,/device,thick=3

;;;;;;;;;;;;;;;;;;;;;;;;WISE;;;;;;;;;;;;;;;;;;;;;;;;;;
;wiseframe 1
RA_CENT1  = 296.518
DEC_CENT1 = -1.438
path1='/srv/two/ashbake/smithcloud/WISE_fields/Any-Fits-irsasearchops1.ipac.caltech.edu-datawiseallsky4band_p3am_cdd2929642964m016_ab412964m016_ab41-w1-int-3.fitscenter=296.51800000000000,-1.4380000000000000-size=1.5deg-gzip=false.fits'


;wiseframe2 core02
RA_CENT2  = 298.
DEC_CENT2 = -1.551
path2='/srv/two/ashbake/smithcloud/WISE_fields/Any-Fits-irsasearchops1.ipac.caltech.edu-datawiseallsky4band_p3am_cdd2929792979m016_ab412979m016_ab41-w1-int-3.fitscenter=298.00,-1.5510000000000000-size=1.5deg-gzip=false.fits'


;wiseframe3 core03a
RA_CENT3  = 297.151673
DEC_CENT3 = -2.052941
path3="/srv/two/ashbake/smithcloud/WISE_fields/Any-Fits-irsasearchops1.ipac.caltech.edu-datawiseallsky4band_p3am_cdd2929642964m016_ab412964m016_ab41-w1-int-3.fitscenter=297.15167300000000,-2.0529410000000000-size=1.5deg-gzip=false.fits"

;wiseframe4 tail01
RA_CENT4  = 297.880375 
DEC_CENT4 = -0.302
path4="/srv/two/ashbake/smithcloud/WISE_fields/Any-Fits-irsasearchops1.ipac.caltech.edu-datawiseallsky4band_p3am_cdd2929792979p000_ab412979p000_ab41-w1-int-3.fitscenter=297.88037500000000,-0.30200000000000000-size=1.5deg-gzip=false.fits "

;wiseframe tail02
RA_CENT5  = 299.631704
DEC_CENT5 = 0.131059 
path5="/srv/two/ashbake/smithcloud/WISE_fields/Any-Fits-irsasearchops1.ipac.caltech.edu-datawiseallsky4band_p3am_cdd2929942994p000_ab412994p000_ab41-w1-int-3.fitscenter=299.63170400000000,0.13105900000000000-size=1.5deg-gzip=false.fits"

;galframe bkgd
RA_CENT6  = 297.808917
DEC_CENT6 = -2.445139
path6="/srv/two/ashbake/smithcloud/WISE_fields/Any-Fits-irsasearchops1.ipac.caltech.edu-datawiseallsky4band_p3am_cdd2929792979m031_ab412979m031_ab41-w1-int-3.fitscenter=297.80891700000000,-2.4451390000000000-size=1.5deg-gzip=false.fits"

;galframe core03b
RA_CENT7  = 297.151696
DEC_CENT7 = -1.012941
path7="/srv/two/ashbake/smithcloud/WISE_fields/Any-Fits-irsasearchops1.ipac.caltech.edu-datawiseallsky4band_p3am_cdd2929642964m016_ab412964m016_ab41-w1-int-3.fitscenter=297.15169600000000,-1.0129410000000000-size=1.5deg-gzip=false.fits"

RAs=[RA_CENT1,RA_CENT2,RA_CENT3,RA_CENT4,RA_CENT5,RA_CENT6,RA_CENT7]
DECs=[DEC_CENT1,DEC_CENT2,DEC_CENT3,DEC_CENT4,DEC_CENT5,DEC_CENT6,DEC_CENT7]
wisepaths=[path1,path2,path3,path4,path5,path6,path7]

;ira=where(abs(ra-RAs) eq min(abs(ra-RAs))) + 1
;idec=where(abs(dec-DECs) eq min(abs(dec-DECs))) + 1
;wisepath=wisepaths[idec -1]
dist=sqrt((ra - RAs)^2 + (dec-DECs)^2)
wisepath=wisepaths[where(dist eq min(dist))]

fits_read,wisepath,wiseim,wisehdr
adxy,wisehdr,ra,dec,x,y
sz=size(wiseim)
if x lt 0 or x gt sz[1] or y lt 0 or y gt sz[2] then print, 'object not in wise image' else begin
dx=size*22.
hextract,wiseim,wisehdr,newwiseim,newwisehdr,x-dx > 0,x+dx<sz[1] ,y-dx>0,y+dx<sz[2]
newwiseim=congrid(newwiseim,300,300)
sz=size(newwiseim)
window,1,xsize=sz[1],ysize=sz[2],title='1 wise'
tvscl,newwiseim^.5

;draw circle around target
rad=40 ;pixels
theta=findgen(360*2)*0.5*!dtor
x=rad*cos(theta)+.5*sz[1]
y=rad*sin(theta)+.5*sz[2]
plots,x,y,/device,thick=3
endelse

;;;;;;;;;;;;;;;;galex;;;;;;;;;;;;;;;

;galframe1 core01
RA_CENT1  = 296.518
DEC_CENT1 = -1.438
path1="/srv/two/ashbake/GALEX/26601-GI6_041001_SmithCloud_CORE01/d/01-main/0049-img/01-try/GI6_041001_SmithCloud_CORE01-nd-intbgsub.fits"

;galframe2 core02
RA_CENT2  = 298.
DEC_CENT2 = -1.551
path2="/srv/two/ashbake/GALEX/26602-GI6_041002_SmithCloud_CORE02/d/01-main/0049-img/01-try/GI6_041002_SmithCloud_CORE02-nd-intbgsub.fits"

;galframe3 core03a
RA_CENT3  = 297.151673
DEC_CENT3 = -2.052941
path3="/srv/two/ashbake/GALEX/26603-GI6_041003_SmithCloud_CORE03a/d/01-main/0049-img/01-try/GI6_041003_SmithCloud_CORE03a-nd-intbgsub.fits"

;galframe4 tail01
RA_CENT4  = 297.880375 
DEC_CENT4 = -0.302
path4="/srv/two/ashbake/GALEX/26604-GI6_041004_SmithCloud_TAIL01/d/01-main/0049-img/01-try/GI6_041004_SmithCloud_TAIL01-nd-intbgsub.fits"

;galframe tail02
RA_CENT5  = 299.631704
DEC_CENT5 = 0.131059 
path5="/srv/two/ashbake/GALEX/26605-GI6_041005_SmithCloud_TAIL02/d/01-main/0049-img/01-try/GI6_041005_SmithCloud_TAIL02-nd-intbgsub.fits"

;galframe bkgd
RA_CENT6  = 297.808917
DEC_CENT6 = -2.445139
path6="/srv/two/ashbake/GALEX/26606-GI6_041006_SmithCloud_BKGD/d/01-main/0049-img/01-try/GI6_041006_SmithCloud_BKGD-nd-intbgsub.fits"

;galframe core03b
RA_CENT7  = 297.151696
DEC_CENT7 = -1.012941
path7="/srv/two/ashbake/GALEX/26607-GI6_041007_SmithCloud_CORE03b/d/01-main/0049-img/01-try/GI6_041007_SmithCloud_CORE03b-nd-intbgsub.fits"

RAs=[RA_CENT1,RA_CENT2,RA_CENT3,RA_CENT4,RA_CENT5,RA_CENT6,RA_CENT7]
DECs=[DEC_CENT1,DEC_CENT2,DEC_CENT3,DEC_CENT4,DEC_CENT5,DEC_CENT6,DEC_CENT7]
paths=[path1,path2,path3,path4,path5,path6,path7]

dist=sqrt((ra - RAs)^2 + (dec-DECs)^2)
path=paths[where(dist eq min(dist))]


fits_read,path,im,hdr
sz=size(im)
adxy,hdr,ra,dec,x,y
if x lt 0 or x gt sz[1] or y lt 0 or y gt sz[2] then print, 'object not in galex image' else begin
dx=size*20.
hextract,im,hdr,newim,newhdr,x-dx>0,x+dx<sz[1],y-dx>0,y+dx<sz[2]
newim=congrid(newim,300,300)
sz=size(newim)
window,2,xsize=sz[1],ysize=sz[2],title='2 galex'

newim[where(newim lt 0)]=0
tvscl,newim^.4,0,0

;draw circle around target
rad=40 ;pixels
theta=findgen(360*2)*0.5*!dtor
x=rad*cos(theta)+.5*sz[1]
y=rad*sin(theta)+.5*sz[2]
plots,x,y,/device,thick=3
endelse
stop
END
