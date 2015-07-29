;PRO montecarlo

;galframe1 core01
RA_CENT1  = 296.518
DEC_CENT1 = -1.438

;galframe2 core02
RA_CENT2  = 298.
DEC_CENT2 = -1.551

;galframe3 core03a
RA_CENT3  = 297.151673
DEC_CENT3 = -2.052941

;galframe4 tail01
RA_CENT4  = 297.880375 
DEC_CENT4 = -0.302

;galframe tail02
RA_CENT5  = 299.631704
DEC_CENT5 = 0.131059 

;galframe bkgd
RA_CENT6  = 297.808917
DEC_CENT6 = -2.445139

;galframe core03b
RA_CENT7  = 297.151696
DEC_CENT7 = -1.012941

RAs=[RA_CENT1,RA_CENT2,RA_CENT3,RA_CENT4,RA_CENT5,RA_CENT6,RA_CENT7]
DECs=[DEC_CENT1,DEC_CENT2,DEC_CENT3,DEC_CENT4,DEC_CENT5,DEC_CENT6,DEC_CENT7]

;dist=sqrt((ra - RAs)^2 + (dec-DECs)^2)

rando_ra=randomu(s,70000)*5.5+295.5
rando_dec=randomu(s,70000)*6.0-4.0

dist=findgen(n_elements(rando_ra),7)
for i=0,6 do begin
   dist[*,i] = sqrt((rando_ra - RAs[i])^2 + (rando_dec - DECs[i])^2)
endfor

;NORMAL REGION
newdist=findgen(n_elements(rando_ra))
for i=0,n_elements(rando_ra)-1 do begin
   newdist[i]=min(abs(dist[i,*]))
   index=where(newdist lt .6)
endfor

ra=rando_ra[index]
dec=rando_dec[index]

GLACTC,ra,dec,2000,gl,gb,1,/DEGREE

;NEW REGION
r1=39
d1=-14.32
r2=37.8
d2=-12.95
m=(d2-d1)/(r2-r1)
ind1=where(gb-d1 gt m*(gl-r1))
gl1=gl[ind1]
gb1=gb[ind1]

r1=37.8
d1=-12.95
r2=37.8
d2=-12.35
m=(d2-d1)/(r2-r1)
ind2=where(gb1-d1 lt m*(gl1-r1))
gl2=gl1[ind2]
gb2=gb1[ind2]

r1=38.4
d1=-12.4
r2=37.8
d2=-12.4
m=(d2-d1)/(r2-r1)
ind3=where(gb2-d1 lt m*(gl2-r1))
gl3=gl2[ind3]
gb3=gb2[ind3]

;drift region
r1=38.4
d1=-14.7
r2=37.3
d2=-13.2
m=(d2-d1)/(r2-r1)
ind4=where(gb-d1 gt m*(gl-r1))
gl4=gl[ind4]
gb4=gb[ind4]



area_deg=5.5*6
area_pc=1.0663d3 * 1.1635d3 ;whole area of box
area1=area_deg*float(n_elements(ra))/n_elements(rando_ra) ;area of whole galex field .204 ratio
area2=area1*float(n_elements(gl3))/n_elements(ra) ;area part over cloud, no drift .56ratio
area3=area1*float(n_elements(gl4))/n_elements(ra) ;off cloud 0.8125
stop
;.204
;6.73956 for whole

;3.80114 on
;2.93842
;5.421 for drift
;1.31859



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;After adding AIS data;;;;;;;;;;;;;;;;;;;;;;;;;

restore,'sc_code/dec_nuv_all.sav'
restore,'sc_code/ra_nuv_all.sav'

GLACTC,ra_nuv_all,dec_nuv_all,2000,gl,gb,1,/DEGREE     

rando_gl=randomu(s,70000)*(abs(max(gl)-min(gl))) + min((gl))
rando_gb=randomu(s,70000)*(abs(max(gb)-min(gb))) - max(abs(gb))

;srcor,rando_gl,rando_gb,gl,gb,40,ind_rando,ind,option=0,spherical=2

frac = double(n_elements(ind_rando))/n_elements(rando_gl)
totA = abs(max(rando_gl)-min(rando_gl)) * abs(max(rando_gb)-min(rando_gb))

area = frac * totA
print,'area of region = ', area , '   degrees^2'

;18.197512
;area 10.8 deg^2
;area 8.49
;frac 0.46651429

restore,'rando_gl.sav'
restore,'rando_gb.sav'
restore,'ind_rando.sav'

gl  =  rando_gl[ind_rando]
gb  =  rando_gb[ind_rando]

r1=39
d1=-14.32
r2=37.8
d2=-12.95
m=(d2-d1)/(r2-r1)
ind1=where(gb-d1 gt m*(gl-r1))
gl1=gl[ind1]
gb1=gb[ind1]

r1=37.8
d1=-12.95
r2=37.8
d2=-12.35
m=(d2-d1)/(r2-r1)
ind2=where(gb1-d1 lt m*(gl1-r1))
gl2=gl1[ind2]
gb2=gb1[ind2]

r1=38.4
d1=-12.4
r2=37.8
d2=-12.4
m=(d2-d1)/(r2-r1)
ind3=where(gb2-d1 lt m*(gl2-r1))
gl3=gl2[ind3]
gb3=gb2[ind3]

r1=38.5
d1=-12.5
r2=39.5
d2=-12.8
m=(d2-d1)/(r2-r1)
ind6=where(gb3-d1 lt m*(gl3 - r1))
gl6=gl3[ind6]
gb6=gb3[ind6]


;drift region
r1=38.4
d1=-14.7
r2=37.3
d2=-13.2
m=(d2-d1)/(r2-r1)
ind4=where(gb-d1 gt m*(gl-r1))
gl4=gl[ind4]
gb4=gb[ind4]




wut = -3*(gl - 39.5)*(gl - 40)*(gl - 39) - 12.7
ind5= where(gb gt wut)
gl5=gl[ind5]
gb5=gb[ind5]

area1=totA*float(n_elements(gl))/n_elements(rando_gl) ;area of whole galex field area1 = 18.2*.58
area6=area1*float(n_elements(gl6))/n_elements(gl)
 ;total area = 18.2
 ;area over cloud 10.6*.477 = 
 ;     5.062 deg^2
 ;area off  cloud 10.6 * .523 =
 ;     
;drift
 ;O star 16Msun at 10km/s (.2 deg)
 ;12/5.5 on ->1.9 - 2.2 -  2.4 
 ;2/5.1 off ->  .36 -  .39 - .45
;
 ;B star 8Msun at 5 km/s (almost 1 deg off)
 ;13/9 on -> 1.23 - 1.44 - 1.52
 ;1/1.6 off -> .587 - .625 - .716

im=readfits('smithmoment.sin.fits',hdr)
plotfits,im,hdr,title='smithcloud',/decima,/logari,ctable=0,xrange=[42.8,36.8],yrange=[-15.6,-12]

plots,gl,gb,psym=3

plots,gl1,gb1,psym=3,color=20
plots,gl3,gb3,psym=3,color=253
plots,gl6,gb6,psym=3,color=200
;plots,gl5,gb5,psym=3,color=251


;;;;;;;;;;;DRIFT;;;;;;;;;;;;;;
;lifetime, O - 10 million, t=10E6
;          B - 55 million, t=1.5E9
;velocity, lower limit - v = 5 km/s
;          upper limit,  v = 10 km/s

;B + lower 8M sun , 282 pc, 1.5 degrees ****
;O + upper 16M sun, 15 pc, .1 degrees ***

;drift region
r1=38.4
d1=-14.7
r2=37.3
d2=-13.2
m=(d2-d1)/(r2-r1)
ind4=where(gb-d1 gt m*(gl-r1))
gl4=gl[ind4]
gb4=gb[ind4]

plots,gl4,gb4,psym=3,color=251



stop
END
