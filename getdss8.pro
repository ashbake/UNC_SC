;+
; NAME:
;      getdss
; PURPOSE:
;       Widget based image display for DSS 2 Blue and Sloan images
;
; EXPLANATION:
;
;       Calls DSS 2 Blue via querydss.pro and Sloan via wget.  Allows
;       user to recenter image and choose image size interactively.
;       Can be called from other programs as it is stand alone.
;
;
; CALLING SEQUENCE:
;       getdss, ra,dec, imagesize=imagesize
; INPUTS:
;       ra -  J2000 right ascension in decimal hours
;       dec - J2000 declination in decimal degrees
;
;
; OPTIONAL INPUT:
;
;
; OPTIONAL INPUT KEYWORD:
;
;    imagesize - imagesize in arcminutes.  If left out, default is 6 arcminutes
;          
;
; OUTPUTS:
;       none
;
;
; RESTRICTIONS:
;
;        
;
; EXAMPLE:
;
;       Straight forward usage:  getdss, ra,dec, imagesize=6
;
; PROCEDURES USED:
;         QUERYDSS, GSFC IDL USER'S LIBRARY
;         TICLABELS, GSFC IDL USER'S LIBRARY
;         RADECCONVERT, written by B. Kent, Cornell Univ.
;         
;
;
;
; MODIFICATION HISTORY:
;       WRITTEN, June 29, 2005
;        August 22, 2005 - BK - error checking in case image is
;                                     not returned
;       January 17, 2006 - BK - major revamp to include Sloan and
;                          image size changes.
;
;       January 30, 2006 - BK - HMS and DMS coordinate labeling
;
;
;       October 11, 2006 - BK - added red cross hair to indicate image center
;
;	December 16, 2010 - BK - modified to use skvbatch_wget perl script for images.
;       June 11, 2012  -  MPH - modifies to retrieve images from DR8 not DR7
;            
;
;----------------------------------------------------------

;-------------------------------------------
; Initialize common blocks
pro getdss_initcommon

common getdss_info, dssinfo


dssinfo={baseID:0L, $
       fmenu:0L, $
       helpmenu:0L, $
       plotwindowone:0L, $
       ra:0.0D, $    ;IN HOURS!
       dec:0.0D, $   ;IN DEGREES!
       dsslabel:0L,$
       dsscoords:0L, $
       dss2blueimage:dblarr(561,561), $
       dss2redimage:dblarr(561,561), $
       sloanimage:dblarr(3,561,561), $
       currentlabel:'DSS 2 Blue', $
       imagedroplist:0L, $
       imagesizebox:0L, $
       imageoptions:['DSS 2 Blue', 'DSS 2 Red','Sloan']} 

end

;-------------------------------------------------------------
;Startup block
pro getdss_startup, imagesize

if (not (xregistered('getdss', /noshow))) then begin

;print, 'GET DSS startup'

common getdss_info

getdss_initcommon

loadct, 1, /silent
;stretch, 225,0

;Reset plots
!x.range=0
!y.range=0
!p.multi=0
device, decomposed=0

;Create widgets

;Top level base
tlb=widget_base(row=1, title='Image View', $
                tlb_frame_attr=1, xsize=710, ysize=800, mbar=top_menu, $
                uvalue='tlb', /base_align_center)

;Menu options
dssinfo.fmenu=widget_button(top_menu, value=' File ')
  ;buttonjpeg=widget_button(dssinfo.fmenu, value=' JPEG Output ', event_pro='getdss_event', uvalue='jpegoutput')
  buttonexit=widget_button(dssinfo.fmenu, value=' Exit ', /separator, $
                           event_pro='getdss_exit')

dssinfo.helpmenu=widget_button(top_menu, value=' Help ')
  buttonhelpfits=widget_button(dssinfo.helpmenu, value= ' About ', event_pro='getdss_help')
;-------------------------------------------------



;------------------------------------------------------------------------
;MAIN BASE - shows image

rightbase=widget_base(tlb, xsize=710, ysize=800, /column)
   titlebase=widget_base(rightbase, /row)
   dssinfo.dsslabel=widget_label(titlebase, value='                                                             ')
   dssinfo.dsscoords=widget_text(titlebase, xsize=25)
   button=widget_button(titlebase, value='Save Optical coordinates', event_pro='getdss_event', uvalue='save_coordinates')
   dssinfo.plotwindowone=widget_draw(rightbase, xsize=700, ysize=700, frame=1, /button_events, /motion_events,$
                                     uvalue='plotwindowone')
   
lowerbase=widget_base(rightbase, xsize=700, ysize=30, /row)
   
   dssinfo.imagedroplist=widget_droplist(lowerbase, value=dssinfo.imageoptions, event_pro='getdss_event', uvalue='imageoption')
   label=widget_label(lowerbase, value='  Left click image to recenter  ')
   label=widget_label(lowerbase, value='               Image Size: ')
   dssinfo.imagesizebox=widget_text(lowerbase, xsize=8, value=strcompress(imagesize, /remove_all), $
                                    /editable, uvalue='imagesizebox')
   label=widget_label(lowerbase, value=' arcminutes')

;Realization
widget_control, tlb, /realize

dssinfo.baseID=tlb

;Xmanager startup
xmanager, 'getdss', dssinfo.baseID, /no_block



endif

end


;Event handler - just one needed because this application is pretty
;                simple

pro getdss_event, event

common getdss_info
common galflux_state

widget_control, event.id, get_uvalue=uvalue



case uvalue of

    'plotwindowone': begin

        rahr=dssinfo.ra
        decdeg=dssinfo.dec

          widget_control, dssinfo.imagesizebox, get_value=imagesizestring
        imagesize=double(imagesizestring)
        
        xrange=[rahr+(imagesize/2.0)/60.0/15.0/cos(decdeg*!dpi/180.0), rahr-(imagesize/2.0)/60.0/15.0/cos(decdeg*!dpi/180.0)]
        yrange=[decdeg-(imagesize/2.0)/60.0, decdeg+(imagesize/2.0)/60.0]
        widget_control, dssinfo.plotwindowone, get_value=index
        wset, index
        
      

        !x.range=[xrange[0], xrange[1]]
        !y.range=[yrange[0], yrange[1]]

        result=convert_coord(event.x, event.y, /device, /double, /to_data)

        rapoint=result[0]
        decpoint=result[1]

        ;Mouse button comes up - reload
        if (event.type eq 1) then begin
           ;print, rapoint, decpoint
           dssinfo.ra=rapoint
           dssinfo.dec=decpoint
           getdss_reload
        endif



     end   ;end of plotwindowone case


     'imagesizebox': begin

         getdss_reload

      
     end



     ;Allows user to switch between DSS 2 Blue and Sloan
     'imageoption':  begin

       

         dssinfo.currentlabel = dssinfo.imageoptions[event.index]

         
        
        currentlabel=dssinfo.currentlabel
        widget_control, dssinfo.plotwindowone, get_value=index
        wset, index
            ra=dssinfo.ra
            dec=dssinfo.dec
            rahr=ra
            decdeg=dec
            widget_control, dssinfo.imagesizebox, get_value=imagesizestring

            imagesize=double(imagesizestring)


            radecconvert, ra, dec, rastring, decstring
            rastring=rastring[0]
            decstring=decstring[0]

            outstring=strcompress(imagesize, /remove_all)+' arcmin optical image centered at '
            widget_control, dssinfo.dsslabel, set_value=outstring[0]
            widget_control, dssinfo.dsscoords, set_value=strcompress(string(strcompress(rastring, /remove_all), format='(a8)')+string(strcompress(decstring, /remove_all), format='(a9)'), /remove_all)
        
         xrange=[rahr+(imagesize/2.0)/60.0/15.0/cos(decdeg*!dpi/180.0), rahr-(imagesize/2.0)/60.0/15.0/cos(decdeg*!dpi/180.0)]   
         yrange=[decdeg-(imagesize/2.0)/60.0, decdeg+(imagesize/2.0)/60.0]
         ticklen=-0.01
         posarray=[0.15,0.15,0.95,0.95]

         device,decomposed=1
         color='00FFFF'XL    ;YELLOW

         plot, [0,0], /nodata, xrange=xrange, yrange=yrange, $
               title=strcompress(long(imagesize), /remove_all)+' arcminute optical image centered at RA: '+$
               strcompress(rahr, /remove_all)+' hours, Dec: '+strcompress(decdeg, /remove_all)+' degrees', $
               xtitle='Right Ascension [hms]', ytitle='Declination [dms]', xstyle=1, ystyle=1, position=posarray, $               
               xtick_get=xvals, ytick_get=yvals, ticklen=ticklen, color=color, charsize=1.0

         nxticklabels=n_elements(xvals)
         nyticklabels=n_elements(yvals)

         xspacing=((xvals[n_elements(xvals)-1]-xvals[0])*60.0)/(nxticklabels-1)
         yspacing=((yvals[n_elements(yvals)-1]-yvals[0])*60.0)/(nyticklabels-1)

         ticlabels, xvals[0]*15.0, nxticklabels, xspacing, xticlabs,/ra,delta=1
         ticlabels, yvals[0], nyticklabels, yspacing, yticlabs, delta=1

         ;Added Jan 30, 2006
         xticlabs=ratickname(xvals*15.0)
         yticlabs=dectickname(yvals)

         PX = !X.WINDOW * !D.X_VSIZE 
         PY = !Y.WINDOW * !D.Y_VSIZE 
         SX = PX[1] - PX[0] + 1 
         SY = PY[1] - PY[0] + 1

         
         erase

            if (currentlabel eq 'DSS 2 Blue') then begin
           
            opticaldssimage=dssinfo.dss2blueimage

            if (opticaldssimage[0] ne 0) then begin
    
                widget_control, dssinfo.plotwindowone, get_value=index
                wset, index
    
    

         
                 device, decomposed=0
                 loadct, 1, /silent
                 stretch, 225,0
                 tvscl, opticaldssimage, px[0], py[0]
         
                 device, decomposed=1
                 plots, ra, dec, color='0000FF'XL, psym=1
                

             endif else begin
                 widget_control, dssinfo.plotwindowone, get_value=index
                 wset, index
                 plot,[0,0],xstyle=4, ystyle=4
                 xyouts, 150,250, 'Image not available', /device, charsize=2.0
                 xyouts, 180, 220, 'at this time', /device, charsize=2.0
              endelse   

            

          endif

          if (currentlabel eq 'DSS 2 Red') then begin
           
            opticaldssimage=dssinfo.dss2redimage

            if (opticaldssimage[0] ne 0) then begin
    
                widget_control, dssinfo.plotwindowone, get_value=index
                wset, index
    
    

         
                 device, decomposed=0
                 loadct, 1, /silent
                 stretch, 225,0
                 tvscl, opticaldssimage, px[0], py[0]
         
                 device, decomposed=1
                 plots, ra, dec, color='0000FF'XL, psym=1
                

             endif else begin
                 widget_control, dssinfo.plotwindowone, get_value=index
                 wset, index
                 plot,[0,0],xstyle=4, ystyle=4
                 xyouts, 150,250, 'Image not available', /device, charsize=2.0
                 xyouts, 180, 220, 'at this time', /device, charsize=2.0
              endelse   

          
          endif
          


        if (currentlabel eq 'Sloan') then begin

         sloanimage=dssinfo.sloanimage
               tv,sloanimage, px[0], py[0], true=1 
                device, decomposed=1
               plots, ra, dec, color='0000FF'XL, psym=1
              
            
            
            
           endif

      


         ;Reverse RA values now that tick labels have been set
         xrange=[rahr+(imagesize/2.0)/60.0/15.0/cos(decdeg*!dpi/180.0), rahr-(imagesize/2.0)/60.0/15.0/cos(decdeg*!dpi/180.0)]
         plot, [0,0], /nodata, xrange=xrange, yrange=yrange, $
               title=strcompress(long(imagesize), /remove_all)+' arcminute optical image centered at RA: '+$
               strcompress(rahr, /remove_all)+' hours, Dec: '+strcompress(decdeg, /remove_all)+' degrees', $
               xtitle='Right Ascension [hms]', ytitle='Declination [dms]', xstyle=1, ystyle=1, position=posarray, $
               xtickn=xticlabs, ytickn=yticlabs, ticklen=ticklen, color=color, charsize=1.0, /NOERASE
        

         device, decomposed=0

     end ;end of image option


'jpegoutput':begin

     widget_control, dssinfo.plotwindowone, get_value=index
     wset, index

     jpegout, 'imageoutput.jpg', window=index
     status=dialog_message('JPEG file written to ~/imageoutput.jpg')

 end

'save_coordinates':begin

gfstate.RA_opt=dssinfo.ra
gfstate.Dec_opt=dssinfo.dec
print, ' '
print, 'Optical coordinates save to GALflux common block structure.'
print, ' '

end


else:

endcase




end


;-----------------------------------------------------
;Exit event handler and cleanup
pro getdss_exit, event

common getdss_info
common atv_state, state


!x.range=0
!y.range=0
!p.multi=0

widget_control, dssinfo.baseID, /destroy
device, decomposed=0
loadct, 1, /silent
stretch, 0,100


delvarx, dssinfo

;;Debugging lines for use with the inspect4.pro procedure
siz=size(state)
if (siz[1] ne 0) then begin
 print, 'Variable check'
 wset, state.draw_window_id
 atv_resetwindow
endif



end

;------------------------------------------------------------
;Help
pro getdss_help, event

   common getdss_info

h=['GETDSS        ', $
   'B. Kent, Cornell Univ.', $
   'Small demo module to get DSS/Sloan images.', $
   ' ', $
   'November 2006']


if (not (xregistered('getdss_help', /noshow))) then begin

helptitle = strcompress('GETDSS HELP')

    help_base =  widget_base(group_leader = dssinfo.baseID, $
                             /column, /base_align_right, title = helptitle, $
                             uvalue = 'help_base')

    help_text = widget_text(help_base, /scroll, value = h, xsize = 85, ysize = 15)
    
    help_done = widget_button(help_base, value = ' Done ', uvalue = 'help_done')

    widget_control, help_base, /realize
    xmanager, 'getdss_help', help_base, /no_block
    
endif


end

;----------------------------------------------------------------------

pro getdss_help_event, event

widget_control, event.id, get_uvalue = uvalue

case uvalue of
    'help_done': widget_control, event.top, /destroy
    else:
endcase

end

;------------------------------------------------------------------
;RA dec conversion - takes ra in decimal hours, and dec in decimal degrees
;                    and converts to strings - uses adstring from GSFC
;                                              ASTRO LIB

pro radecconvert, rahr, decdeg, rastring, decstring

   radeg=(rahr/24.0)*360.0

   result=strtrim(adstring([radeg,decdeg], 2, /truncate))

;Use strmatch here?
;Get position of plus or minus sign for dec, and cut the string at
;that position

   signpos=strpos(result, '+')
   if (signpos eq -1) then signpos=strpos(result, '-')

   rastring=strmid(result, 0, signpos-1)
   decstring=strmid(result, signpos, strlen(result)-1)

end

;------------------------------DISPLAY PROCEDURE------------------
pro getdss_reload

common getdss_info
common agcshare, agcdir
 
        currentlabel=dssinfo.currentlabel


ra=dssinfo.ra
dec=dssinfo.dec
widget_control, dssinfo.imagesizebox, get_value=imagesizestring

imagesize=double(imagesizestring)


radecconvert, ra, dec, rastring, decstring
rastring=rastring[0]
decstring=decstring[0]

outstring=strcompress(imagesize, /remove_all)+' arcmin optical image centered at '
widget_control, dssinfo.dsslabel, set_value=outstring[0]
widget_control, dssinfo.dsscoords, set_value=strcompress(string(strcompress(rastring, /remove_all), format='(a8)')+string(strcompress(decstring, /remove_all), format='(a9)'), /remove_all)
        

widget_control, dssinfo.plotwindowone, get_value=index
    wset, index

erase

device, decomposed=1
xyouts, 100, 350, 'Image is loading...', /device, charsize=2.0
;xyouts, 200, 300, '(c) LOVEDATA, Inc.   Ithaca, NY', /device, charsize=2.0

  ;Query DSS at STSCI
   widget_control, dssinfo.baseID, hourglass=1

  
  ;Both coords must be in decimal degrees
  ;Get optical image from DSS 2 Blue
   coords=[ra*15.0,dec]

   	opticaldssimage=fltarr(210,210)           
	;queryDSS, [ra*15.0,dec], image, header, imsize=imagesize, survey='2b'
	radecconvert, ra, dec, rastring,decstring
	spawn, agcdir+"skvbatch_wget file=~/thx1138.fits position='"+$
		      rastring+","+decstring+"' Survey='Digitized Sky Survey' Size="+strcompress(imagesize/60.0, /remove_all)
	opticaldssimage=mrdfits('~/thx1138.fits', 0, header, /silent)
	opticalreddssimage=opticaldssimage
	

   ;querydss, coords, opticaldssimage, Hdr, survey='2b', imsize=imagesize
   ;querydss, coords, opticalreddssimage, Hdr, survey='2r', imsize=imagesize

   if (opticaldssimage[0] ne 0) then dssinfo.dss2blueimage=congrid(opticaldssimage, 561,561)
   if (opticalreddssimage[0] ne 0) then dssinfo.dss2redimage=congrid(opticalreddssimage, 561,561)
   rahr=dssinfo.ra
   decdeg=dssinfo.dec

   ;Get Sloan image using spawn
   osfamily = strupcase(!version.os_family)
   if (osfamily eq 'UNIX') then begin

;   url='http://casjobs.sdss.org/ImgCutoutDR6/getjpeg.aspx?ra='+$
    url='http://skyservice.pha.jhu.edu/DR8/ImgCutout/getjpeg.aspx?ra='+$
                    strcompress(rahr*15.0, /remove_all)+$
                    '&dec='+strcompress(decdeg, /remove_all)+$
                    '&scale='+strcompress(imagesize/6.67,/remove_all)+$
                    '&opt=I&width=400&height=400'

         filename='~/12junksdss.jpg'
         spawn, 'wget -q -O '+ filename + " '" + url + "'"
         spawn, 'convert '+filename+' '+filename
         read_jpeg, filename, sloanimage, true=1
         spawn, '/bin/rm -r ~/12junksdss.jpg'

   dssinfo.sloanimage=congrid(sloanimage,3,561,561)
   endif

   ;Done with sloan loading until user clicks the image


   if (opticaldssimage[0] ne 0) then begin
    
    widget_control, dssinfo.plotwindowone, get_value=index
    wset, index
    
    
         xrange=[rahr+(imagesize/2.0)/60.0/15.0/cos(decdeg*!dpi/180.0), rahr-(imagesize/2.0)/60.0/15.0/cos(decdeg*!dpi/180.0)]      
         yrange=[decdeg-(imagesize/2.0)/60.0, decdeg+(imagesize/2.0)/60.0]
         ticklen=-0.01
         posarray=[0.15,0.15,0.95,0.95]

         device,decomposed=1
         color='00FFFF'XL    ;YELLOW

         plot, [0,0], /nodata, xrange=xrange, yrange=yrange, $
               title=strcompress(long(imagesize), /remove_all)+' arcminute optical image centered at RA: '+$
               strcompress(rahr, /remove_all)+' hours, Dec: '+strcompress(decdeg, /remove_all)+' degrees', $
               xtitle='Right Ascension [hms]', ytitle='Declination [dms]', xstyle=1, ystyle=1, position=posarray, $            
               xtick_get=xvals, ytick_get=yvals, ticklen=ticklen, color=color, charsize=1.0

         nxticklabels=n_elements(xvals)
         nyticklabels=n_elements(yvals)

         xspacing=((xvals[n_elements(xvals)-1]-xvals[0])*60.0)/(nxticklabels-1)
         yspacing=((yvals[n_elements(yvals)-1]-yvals[0])*60.0)/(nyticklabels-1)

         ticlabels, xvals[0]*15.0, nxticklabels, xspacing, xticlabs,/ra,delta=1
         ticlabels, yvals[0], nyticklabels, yspacing, yticlabs, delta=1

         ;Added January 30, 2006
         xticlabs=ratickname(xvals*15.0)
         yticlabs=dectickname(yvals)

         PX = !X.WINDOW * !D.X_VSIZE 
         PY = !Y.WINDOW * !D.Y_VSIZE 
         SX = PX[1] - PX[0] + 1 
         SY = PY[1] - PY[0] + 1

         
         erase

        
          if (currentlabel eq 'DSS 2 Blue') then begin
           
            opticaldssimage=dssinfo.dss2blueimage

            if (opticaldssimage[0] ne 0) then begin
    
                widget_control, dssinfo.plotwindowone, get_value=index
                wset, index
    
    

         
                 device, decomposed=0
                 loadct, 1, /silent
                 stretch, 225,0
                 tvscl, opticaldssimage, px[0], py[0]
         
                 device, decomposed=1
                 plots, ra, dec, color='0000FF'XL, psym=1
                

             endif else begin
                 widget_control, dssinfo.plotwindowone, get_value=index
                 wset, index
                 plot,[0,0],xstyle=4, ystyle=4
                 xyouts, 150,250, 'Image not available', /device, charsize=2.0
                 xyouts, 180, 220, 'at this time', /device, charsize=2.0
              endelse   

            

          endif

          if (currentlabel eq 'DSS 2 Red') then begin
           
            opticaldssimage=dssinfo.dss2redimage

            if (opticaldssimage[0] ne 0) then begin
    
                widget_control, dssinfo.plotwindowone, get_value=index
                wset, index
    
    

         
                 device, decomposed=0
                 loadct, 1, /silent
                 stretch, 225,0
                 tvscl, opticaldssimage, px[0], py[0]
         
                 device, decomposed=1
                 plots, ra, dec, color='0000FF'XL, psym=1
                

             endif else begin
                 widget_control, dssinfo.plotwindowone, get_value=index
                 wset, index
                 plot,[0,0],xstyle=4, ystyle=4
                 xyouts, 150,250, 'Image not available', /device, charsize=2.0
                 xyouts, 180, 220, 'at this time', /device, charsize=2.0
              endelse   

            

          endif
          


        if (currentlabel eq 'Sloan') then begin

         sloanimage=dssinfo.sloanimage
               tv,sloanimage, px[0], py[0], true=1 
                device, decomposed=1
               plots, ra, dec, color='0000FF'XL, psym=1
              
            
            
            
           endif


         ;Reverse RA values now that tick labels have been set
         xrange=[rahr+(imagesize/2.0)/60.0/15.0/cos(decdeg*!dpi/180.0), rahr-(imagesize/2.0)/60.0/15.0/cos(decdeg*!dpi/180.0)]

         plot, [0,0], /nodata, xrange=xrange, yrange=yrange, $
               title=strcompress(long(imagesize), /remove_all)+' arcminute optical image centered at RA: '+$
               strcompress(rahr, /remove_all)+' hours, Dec: '+strcompress(decdeg, /remove_all)+' degrees', $
               xtitle='Right Ascension [hms]', ytitle='Declination [dms]', xstyle=1, ystyle=1, position=posarray, $
               xtickn=xticlabs, ytickn=yticlabs, ticklen=ticklen, color=color, charsize=1.0, /NOERASE
        

   endif
   
   device, decomposed=0
   widget_control, dssinfo.baseId, hourglass=0



end




;------MAIN PROGRAM BLOCK------------
pro getdss, ra, dec, imagesize=imagesize




if (n_elements(imagesize) eq 0) then imagesize=6.0

getdss_startup, imagesize

common getdss_info


dssinfo.ra=ra    ;IN HOURS
dssinfo.dec=dec

getdss_reload

end
