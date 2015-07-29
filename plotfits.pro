;+
; NAME:
;       PLOTFITS
;
; PURPOSE:
;       Make a plot of FITS imaging data.
;
; CATEGORY:
;       Plotting tools.
;
; CALLING SEQUENCE:1
;       plotfits, fitsim [, header] [, minmax=minmax], [, /linear] ...
;
; REQUIRED INPUTS:
;       fitsim      either a string with the name of a FITS file or a 2D array
;
; OPTIONAL INPUTS:
;       header      FITS header if a 2D array is provided to the procedure
;
; KEYWORDS:
;       minmax      minimum and maximum data value used for scaling the plot
;       linear      use    linear   scaling of the color map
;       sqroot      use square root scaling of the color map
;       logari      use logarithmic scaling of the color map
;       asinhy      use inverse hyperbolic sine scaling of the color map
;       ctable      number of the color table to be used
;       invers      invert the color map
;       factor      factor for scaling the size of the plot
;       pixels      label the axis with pixel values
;       decima      label the axis with   decimal   coordinates
;       sexage      label the axis with sexagesimal coordinates
;       xrange      xrange for plotting a subsection of the image
;       yrange      yrange for plotting a subsection of the image
;       offset      plot offset coordinates instead of absolute coordinates
;       psfile      name of the PS file for PS output
;       encaps      make encapsulated PS (EPS) output
;       titles      title string for the plot
;       colbar      axis title and switch for plotting a colour bar
;       bargap      gap between the colour bar and the main plot
;
; OUTPUTS:
;       pltset      backup of the original IDL plot settings
;       positi      position of the plot in device coordinates
;       barpos      position of the colour bar in device coordinates
;       colmap      return the forward mapping of the colours
;       colinv      return the inverse mapping of the colours
;
; DESCRIPTION AND EXAMPLE:
;       The procedure automatically plots a FITS image. Either a file name of
;       a FITS file or both a 2D array and a corresponding FITS header have
;       to be provided to the procedure. With the XRANGE and YRANGE keywords
;       specified, only a subsection of the entire image is selected for the
;       plot. The keywords LINEAR, SQROOT, LOGARI, CTABLE and INVERS customise
;       the color table and scaling of the data. The keyword FACTOR scales the
;       size of the plot with respect to the default size. The default size
;       of the plot is 920px x 920px for output on screen and 18cm x 24cm for
;       output as a PS file. By default, the image is scaled to fit within
;       these sizes. For output into a PS file, FACTOR may be an array of 2
;       values, where the second value specifies by which factor the original
;       array is to be rebinned. Properties of the axes can be selected using
;       the keywords PIXELS, DECIMA, SEXAGE and OFFSET. By default the axes
;       are labelled with absolute coordinates in astronomical (i.e. sexa-
;       gesimal) notation. The keyword pltset can be used to leave a plot
;       open (e.g. to not close the open PS file) and to return the backup
;       of the original IDL plot settings to the caller. Similarly the
;       position keyword allows to obtain the position of the plot in device
;       coordinates, e.g. for overplotting the image by a contour plot. If
;       not provided with an image name or array and called with the keyword
;       PLTSET then the procedure will simply close the still open plot
;       associated with the PLTSET variable.
;       Example for plotting an image, contours and annotations:
;          imgdat = readfits('~/.idl/plotfits.fits', header)
;          plotfits, imgdat, header, xrange=[123, 522], yrange=[54, 453], $
;                    title='NGC 1068, V Band', factor=0.75, /invers, $
;                    pltset=pltset, positi=positi, psfile='ngc1068'
;          contour, imgdat[123:522, 54:453], levels=1000*[2, 3, 5, 15], $
;                   positi=positi, xstyle=4, ystyle=4, color=150, $
;                   /noerase, /device
;          plots, 200, 200, psym=1, thick=2, color=80
;          xyouts, 206, 206, align=0.0, 'NGC1068 nucleus', color=80
;          usersym, cos(findgen(17)*(!pi*2/16.)), sin(findgen(17)*(!pi*2/16.))
;          plots, 150, 179, psym=8, thick=2, color=80
;          xyouts, 144, 185, align=1.0, 'HIP 12668', color=80
;          plotfits, pltset=pltset
;
; CALLED BY:
;       none
;
; CALLING:
;       Makes extensive use of routines in the ASTROLIB library.
;       plotcbar
;
; MODIFICATION HISTORY:
;       2008-11-11 Written by Konrad R. Tristram
;       2008-11-27 Konrad R. Tristram: Added/changed keywords ENCAPS & LINEAR.
;       2009-01-20 Konrad R. Tristram: Added output of a colour bar.
;       2009-01-20 Konrad R. Tristram: Changes in logarithmic scaling part.
;       2009-02-10 Konrad R. Tristram: Added inverse hyperbolic sine scaling.
;       2009-02-20 Konrad R. Tristram: Use external routine for the colour bar.
;       2009-07-08 Konrad R. Tristram: Remove space at top if no title present.
;

PRO PLOTFITS, FITSIM, HEADER, MINMAX=MINMAX, LINEAR=LINEAR, SQROOT=SQROOT, $
              LOGARI=LOGARI, ASINHY=ASINHY, CTABLE=CTABLE, INVERS=INVERS, $
              FACTOR=FACTOR, PIXELS=PIXELS, DECIMA=DECIMA, SEXAGE=SEXAGE, $
              XRANGE=XRANGE, YRANGE=YRANGE, OFFSET=OFFSET, PSFILE=PSFILE, $
              ENCAPS=ENCAPS, PLTSET=PLTSET, TITLES=TITLES, POSITI=POSITI, $
              BARPOS=BARPOS, BARGAP=BARGAP, COLBAR=COLBAR, COLMAP=COLMAP, $
              COLINV=COLINV

; CLOSE THE FILE IF PROGRAMME IS CALLED WITH A VALID PLTSET
;-------------------------------------------------------------------------------
if (~ arg_present(fitsim)) and (size(pltset, /type) eq 8) then begin
	; CLOSE THE FILE IF A PS PLOT IS GENERATED
	;-----------------------------------------------------------------------
	if (pltset.d_new eq 'PS') then device, /close
	; RESET THE ORIGINAL PLOT DEVICE AND SETTINGS
	;-----------------------------------------------------------------------
	set_plot, pltset.d_old
	!p = pltset.p
	; DELETE THE VARIABLE PLTSET
	;-----------------------------------------------------------------------
	pltset = -1
	; RETURN TO CALLER LEVEL
	;-----------------------------------------------------------------------
	return
endif

; SAVE CURRENT PLOT SETTINGS
;-------------------------------------------------------------------------------
plttmp = {d_old:!d.name, p:!p, d_new:''}

; SET DEFAULT VALUES FOR VARIABLES IF NOT PROVIDED BY THE USER
;-------------------------------------------------------------------------------
if n_elements(ctable) eq 0 then ctable = 3b $
                           else ctable = (byte(ctable))[0] < 45b
if n_elements(bargap) eq 0 then bargap = 0.0 $
                           else bargap = (float(bargap))[0]

; FIND OUT IF THE DATA HAS TO BE LOADED OR IF IT IS A FITS STRUCT
;-------------------------------------------------------------------------------
if size(fitsim, /type) eq 7 then begin
	imgdat = float(readfits(fitsim, header))
endif else imgdat = float(fitsim)

; GET THE ARRAY SIZE OF THE FULL IMAGE
;-------------------------------------------------------------------------------
arrsiz = size(imgdat)

; CALCULATE THE SECTION TO BE PLOTTED
;-------------------------------------------------------------------------------
if (n_elements(xrange) eq 2) and (n_elements(yrange) eq 2) then begin
	if keyword_set(decima) then begin
		adxy, header, xrange, yrange, xnewra, ynewra
		xrange = fix(xnewra)
		yrange = fix(ynewra)
	endif
	xrange = fix(xrange) > 0 < (arrsiz[1]-1)
	yrange = fix(yrange) > 0 < (arrsiz[2]-1)
endif else begin
	xrange = [0, arrsiz[1]-1]
	yrange = [0, arrsiz[2]-1]
endelse

; GET THE ACTUAL SIZE OF THE IMAGE SECTION
;-------------------------------------------------------------------------------
xysize = [xrange[1]-xrange[0]+1, yrange[1]-yrange[0]+1]

; SET UP PLOT ENVIRONMENT DEPEDING ON PLOTTING DEVICE
;-------------------------------------------------------------------------------
if keyword_set(psfile) then begin
	; SET CHARACTER SIZE
	;-----------------------------------------------------------------------
	!p.charsize=0.75
	; CALCULATE THE FACTOR FOR RESIZING THE ARRAY AND FOR THE PLOT SIZE
	;-----------------------------------------------------------------------
	scafac = 1. / (max(xysize)/1000 > 1)
	if n_elements(factor) ge 2 then begin
		scafac = factor[1]
		factor = factor[0]
	endif else if n_elements(factor) eq 0 then factor = 1
	; DEFINE THE MAXIMUM WITDH AND HEIGHT OF THE PLOT
	;-----------------------------------------------------------------------
	x_maxi = 18.0 ; A&A full width of page
	y_maxi = 24.0 ; height of an A4 page
	; CALCULATE THE SIZE OF THE PLOT AFTER SUBTRACTING THE EDGES
	;-----------------------------------------------------------------------
	x_size = x_maxi - 1.1 - 0.3
	if keyword_set(colbar) then x_size = (x_size - 0.8 - bargap) / 1.05
	; CHECK IF THE PLOT IS ACTUALLY LIMITED BY ITS HEIGHT
	;-----------------------------------------------------------------------
	if (x_size/xysize[0]*xysize[1] + 0.9 + 0.5) gt y_maxi then begin
		; CALCULATE SIZE AND POSITION FROM THE HEIGHT CONSTRAINT
		;---------------------------------------------------------------
		y_size = factor * 1000. * (y_maxi - 0.9 - 0.5)
		x_size = y_size / xysize[1] * xysize[0]
		positi = [1100., 900., 1100.+x_size, 900.+y_size]
	endif else begin
		; CALCULATE SIZE AND POSITION FROM THE WIDTH CONSTRAINT
		;---------------------------------------------------------------
		x_size = factor * 1000. * x_size
		y_size = x_size / xysize[0] * xysize[1]
		positi = [1100., 900., 1100.+x_size, 900.+y_size]
	endelse
	; CALCULATE THE POSITION OF THE COLOUR BAR
	;-----------------------------------------------------------------------
	barpos = [positi[2], positi[1], positi[2]+0.05*x_size, positi[3]]
	barpos += 1000. * bargap * [1,0,1,0]
	; CALCULATE THE SIZE OF THE BOUNDING BOX
	;-----------------------------------------------------------------------
	if keyword_set(colbar) then x_size = (barpos[2])/1000. + 1.1 $
	                       else x_size = (positi[2])/1000. + 0.3
	y_size = (barpos[3])/1000. + 0.1
	; ADD A LITTLE SPACE FOR THE TITLE
	;-----------------------------------------------------------------------
	if titles ne '' then y_size += 0.4
	; OPEN THE PS FILE AND SET THE PLOT AREA
	;-----------------------------------------------------------------------
	set_plot, 'PS'
	psstri = 'systemdict /setdistillerparams known { ' + string(10b) + $
	         '<< /AutoFilterColorImages false /ColorImageFilter ' + $
	         string(10b) + '/FlateEncode >> setdistillerparams} if'
	device, file=psfile+'.ps', xsize=x_size, ysize=y_size, $
	        xoffset=10.4-0.5*x_size, yoffset=15.0-0.5*y_size, $
	        bits_per_pixel=8, /portrait, color=1, output=psstri, $
	        encaps=encaps
endif else begin
	; SET CHARACTER SIZE
	;-----------------------------------------------------------------------
	!p.charsize=1.25
	; CALCULATE THE FACTOR FOR RESIZING THE ARRAY, I.E. THE PLOT SIZE
	;-----------------------------------------------------------------------
	if n_elements(factor) eq 0 then factor = 920. / max(xysize) $
	                           else factor = factor[0]
	scafac = factor
	; SET THE LOCATION OF THE PLOT
	;-----------------------------------------------------------------------
	positi = fix([60, 50, xysize[0]*factor+60, xysize[1]*factor+50])
	; SET THE LOCATION OF THE COLOUR BAR
	;-----------------------------------------------------------------------
	barpos = [positi[2]+bargap, positi[1], $
	          fix(1.05*positi[2]-0.05*positi[0])+bargap, positi[3]]
	; CALCULATE THE X AND Y-SIZES OF THE PLOT
	;-----------------------------------------------------------------------
	if keyword_set(colbar) then x_size = barpos[2] + 40 else $
	                            x_size = positi[2]
	x_size = x_size + 20
	y_size = positi[3] + 10
	; ADD A LITTLE SPACE FOR THE TITLE
	;-----------------------------------------------------------------------
	if titles ne '' then y_size += 20
	; OPEN A NEW WINDOW FOR THE PLOT
	;-----------------------------------------------------------------------
	set_plot, 'x'
	window, /free, xsize=x_size, ysize=y_size
	device, decompose=0
endelse
plttmp.d_new = !d.name

; CHECK IF A SECTION OF THE IMAGE HAS TO BE CUT OUT
;-------------------------------------------------------------------------------
if array_equal(xysize, arrsiz[1:2]) then begin
	; DIRECTLY RESCALE THE FULL IMAGE (FAST)
	;-----------------------------------------------------------------------
	pltarr = congrid(imgdat, xysize[0]*scafac, xysize[1]*scafac)
endif else begin
	; FIRST CUT OUT A SECTION AND THEN RESCALE IT (TAKES LONGER)
	;-----------------------------------------------------------------------
	pltarr = imgdat[xrange[0]:xrange[1], yrange[0]:yrange[1]]
	pltarr = congrid(pltarr, xysize[0]*scafac, xysize[1]*scafac)
endelse

; FIND THE MINIMUM AND THE MAXIMUM OF THE DATA IF VALUES NOT PROVIDED
;-------------------------------------------------------------------------------
finidx = where(finite(pltarr))
srtdat = pltarr[finidx]
srtdat = srtdat[sort(srtdat)]
if n_elements(minmax) lt 2 then minmax = srtdat[[0.20,0.996]*n_elements(srtdat)]

; NORMALISE THE DATA TO [0,1] AND ONLY SELECT THE FIRST FRAME
;-------------------------------------------------------------------------------
pltarr[finidx] = (pltarr[finidx] - minmax[0]) / (minmax[1] - minmax[0]) > 0 < 1
nanidx = where(finite(pltarr, /nan))
if nanidx[0] ge 0 then pltarr[nanidx] = 0

; CREATE NORMALISED ARRAY FOR THE COLOR MAP AND INVERSE MAP
;-------------------------------------------------------------------------------
colmap = findgen(2551)/2550
colinv = findgen(2551)/2550

; APPLY TRANSFORMATION OF THE COLOUR MAPPING, DEFAULT IS SQUARE ROOT
;-------------------------------------------------------------------------------
if keyword_set(linear) then expone = float(linear[0]) else expone = 0.5
if keyword_set(asinhy) then begin
	if n_elements(asinhy) lt 2 then begin
		asinhy = [asinhy, median(pltarr)]
	endif else begin
		asinhy[1] = (asinhy[1] - minmax[0]) / (minmax[1] - minmax[0])
	endelse
	pltarr = asinh((pltarr-asinhy[1]) * 10.^asinhy[0])
	tmpvar = [asinh((0.0-asinhy[1]) * 10.^asinhy[0]), $
	          asinh((1.0-asinhy[1]) * 10.^asinhy[0])]
	pltarr = (pltarr - tmpvar[0]) / (tmpvar[1] - tmpvar[0])
	colmap = asinh((colmap-asinhy[1]) * 10.^asinhy[0])
	colmap = (colmap - tmpvar[0]) / (tmpvar[1] - tmpvar[0])
	colinv = colinv * (tmpvar[1] - tmpvar[0]) + tmpvar[0]
	colinv = sinh(colinv) / 10.^asinhy[0] + asinhy[1]
endif else if keyword_set(logari) then begin
	pltarr = alog10((pltarr * (10.^logari-1.)) + 1.) / logari
	colmap = alog10((colmap * (10.^logari-1.)) + 1.) / logari
	colinv = (10.^(colinv * logari) - 1.)/(10.^logari-1.)
endif else begin
	pltarr = (pltarr)^(expone)
	colmap = (colmap)^(expone)
	colinv = (colinv)^(1.0/expone)
endelse

; SCALE TO THE FINAL VALUE RANGE
;-------------------------------------------------------------------------------
pltarr = 255. * pltarr
colmap = 255. * colmap
colinv = colinv * (minmax[1] - minmax[0]) + minmax[0]

; INVERT THE ARRAY RANGE IF CORRESPONDING KEYWORD IS SET
;-------------------------------------------------------------------------------
if keyword_set(invers) then begin
	pltarr = 255. - pltarr
	colmap = 255. - colmap
endif

; PLOT THE COLOR BAR IF THE KEYWORD IS SET
;-------------------------------------------------------------------------------
if keyword_set(colbar) then if (colbar ne 'nocolbar') then begin
	plotcbar, minmax, colmap, barpos, ctable, barlab=colbar
endif

; LOAD THE COLOUR TABLE AND PLOT THE ARRAY
;-------------------------------------------------------------------------------
loadct, ctable, /silent
xyouts, positi[0], positi[1], 'Plot produced with the IDL procedure ' + $
        'PLOTFITS by Konrad R. W. Tristram', charsize=0.1, /device
tv, pltarr, positi[0], positi[1], xsize=positi[2]-positi[0], $
                                  ysize=positi[3]-positi[1]
loadct, 39, /silent

; IF NO TITLE IS PROVIDED, THEN CREATE ONE
;-------------------------------------------------------------------------------
if n_elements(titles) lt 1 then begin
	; PUT OBJECT AND INSTRUMENT INFORMATION FROM THE HEADER INTO THE TITLE
	;-----------------------------------------------------------------------
	titles = strtrim(sxpar(header, 'OBJECT'), 2) + ' with ' + $
	         strtrim(sxpar(header, 'INSTRUME'), 2)
	; TRY TO FIND DATE OF OBSERVATION AND ADD IT TO THE TITLE
	;-----------------------------------------------------------------------
	datobs = sxpar(header, 'DATE_OBS', count=count)
	if count gt 0 then titles += ' on ' + datobs else begin
		datobs = sxpar(header, 'DATE-OBS', count=count)
		if count gt 0 then titles += ' on ' + datobs
	endelse
endif

; PLOT THE AXES
;-------------------------------------------------------------------------------
if keyword_set(pixels) then begin
	; SHIFT THE PIXEL VALUES IF AN OFFSET IS SPECIFIED
	;-----------------------------------------------------------------------
	if n_elements(offset) eq 2 then begin
		xrange -= offset[0]
		yrange -= offset[1]
	endif
	; PLOT THE AXIS
	;-----------------------------------------------------------------------
	plot, [0,0], [0,0], xrange=[xrange[0]-0.5, xrange[1]+0.5], $
	                    yrange=[yrange[0]-0.5, yrange[1]+0.5], $
	      xstyle=1, ystyle=1, xtitle='pixels', ytitle='pixels', $
	      title=titles, position=positi, /nodata, /noerase, /device
endif else if n_elements(offset) eq 2 then begin
	; GET THE PIXEL SCALE
	;-----------------------------------------------------------------------
	getrot, header, tmpvar, cdelta
	; CALCULATE THE PLOT RANGE
	;-----------------------------------------------------------------------
	xrange = 3600.*cdelta[0] * ([xrange[0]-0.5, xrange[1]+0.5] - offset[0])
	yrange = 3600.*cdelta[1] * ([yrange[0]-0.5, yrange[1]+0.5] - offset[1])
	; PLOT THE AXIS
	;-----------------------------------------------------------------------
;	plot, [0,0], [0,0], xrange=xrange, yrange=yrange, xstyle=1, ystyle=1, $
;	      xtitle='!4D!X RA [arcsec]', ytitle='!4D!X DEC [arcsec]', $
	plot, [0,0], [0,0], xrange=xrange*1000., yrange=yrange*1000., $
	      xstyle=1, ystyle=1, xtitle='!4D!X RA [mas]', $
	      ytitle='!4D!X DEC [mas]', $
;	      xtickinterval=1, ytickinterval=1, $
	      title=titles, position=positi, /nodata, /noerase, /device
endif else begin
	; GET THE RA AND DEC OF THE CORNERS OF THE IMAGE
	;-----------------------------------------------------------------------
	xyad, header, [xrange[0]-0.5, xrange[1]+0.5], $
	                     [yrange[0]-0.5, yrange[1]+0.5], rascen, declin
	; SET THE DEFAULT NUMBER OF MAJOR AND MINOR TICKS
	;-----------------------------------------------------------------------
	xticks = !X.TICKS EQ 0 ? 8 : !X.TICKS
	yticks = !Y.TICKS EQ 0 ? 8 : !Y.TICKS
	xminor = !X.MINOR EQ 0 ? 5 : !X.MINOR
	yminor = !Y.MINOR EQ 0 ? 5 : !Y.MINOR
	; CALCULATE THE INITIAL ESTIMATE FOR THE NUMBER OF PIXELS BETWEEN TICKS
	;-----------------------------------------------------------------------
	pixtix = float(xrange[1]-xrange[0]-1) / xticks
	pixtiy = float(yrange[1]-yrange[0]-1) / yticks
	; DETERMINE INCREMENTS IN RA AND DEC (FOR RA CHECK CROSSING OF 0 HOURS)
	;-----------------------------------------------------------------------
	getrot, header, tmpvar, cdelta
	case 1 of
		(rascen[1] GT rascen[0]) and (cdelta[0] LT 0): $
			tics, rascen[0], rascen[1]-360.0d, xysize[0], $
			      pixtix, raincr, /ra
		(rascen[1] LT rascen[0]) and (cdelta[0] GT 0): $
			tics, rascen[0], rascen[1]+360.0d, xysize[0], $
			      pixtix, raincr, /ra
		else:   tics, rascen[0], rascen[1],        xysize[0], $
			      pixtix, raincr, /ra
	endcase
	tics, declin[0], declin[1], xysize[1], pixtiy, deincr
	; DETERMINE POSITION OF FIRST MAJOR TICK ON EACH AXIS
	;-----------------------------------------------------------------------
	tic_one, rascen[0], pixtix, raincr, raval1, xtick1, /ra
	tic_one, declin[0], pixtiy, deincr, deval1, ytick1
	; DETERMINE NUMBER OF TICK MARKS
	;-----------------------------------------------------------------------
	xticks = fix((xysize[0]-1-xtick1)/pixtix)
	yticks = fix((xysize[1]-1-ytick1)/pixtiy)
	; GENERATE THE LABELS FOR THE TICKS
	;-----------------------------------------------------------------------
	ticlabels, raval1, xticks+1, raincr, xtickn, delta=1, /ra
	ticlabels, deval1, yticks+1, deincr, ytickn, delta=1
	; CALCULATE THE POSITIONS OF THE OTHER MAJOR TICKS
	;-----------------------------------------------------------------------
	extast, header, astrom, noparams
	xtickv = cons_ra( raval1 + findgen(xticks+1)*raincr/4. , $
	                  yrange[0]-0.5, astrom)
	ytickv = cons_dec(deval1 + findgen(yticks+1)*deincr/60., $
	                  xrange[0]-0.5, astrom)
	; GET THE EQUINOX OF THE REFERENCE COORDINATE SYSTEM FROM THE HEADER
	;-----------------------------------------------------------------------
	equino = sxpar(header, 'EQUINOX', count=count)
	; IF AN EQUINOX WAS FOUND MAKE A AXIS LABEL STRING FROM IT
	;-----------------------------------------------------------------------
	if count gt 0 then begin
		case 1 of
			(equino eq 2000): equino = ' (J2000)'
			(equino eq 1950): equino = ' (B1950)'
			else            : equino = ' ('+strtrim(equino, 2)+')'
		endcase
	; IF AN EQUINOX WAS FOUND MAKE A AXIS LABEL STRING FROM IT
	;-----------------------------------------------------------------------
	endif else begin
		print, 'Attention! EQUINOX keyword not present in FITS header.'
		equino = ''
	endelse
	; ALTERNATIVELY PLOT THE AXIS USING DECIMAL LABELS
	;-----------------------------------------------------------------------
	if keyword_set(decima) then begin
		plot, [0,0], [0,0], xrange=rascen, yrange=declin, $
		      xstyle=1, ystyle=1, title=titles, $
		      xtitle='RA'  + equino + ' [deg]', $
	              ytitle='DEC' + equino + ' [deg]', $
		      position=positi, /nodata, /noerase, /device
	; BY DEFAULT PLOT THE AXIS USING SEXAGESIMAL LABELS
	;-----------------------------------------------------------------------
	endif else begin
		plot, [0,0], [0,0], xrange=[xrange[0]-0.5, xrange[1]+0.5], $
		                    yrange=[yrange[0]-0.5, yrange[1]+0.5], $
		      xstyle=1, ystyle=1, xticks=xticks, yticks=yticks, $
		      xminor=xminor, yminor=yminor, xtickv=xtickv, $
		      ytickv=ytickv, xtickna=xtickn, ytickna=ytickn, $
		      xtitle='RA' + equino, ytitle='DEC' + equino, $
	              title=titles, position=positi, /nodata, /noerase, /device
	endelse
endelse

; CLOSE THE FILE AND RESET THE PLOT STATUS
;-------------------------------------------------------------------------------
if arg_present(pltset) then pltset = plttmp else plotfits, pltset=plttmp

END
