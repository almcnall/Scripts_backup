;;;WORKSHEET FOR ANALYSIS OF SCENARIOS
;; greg husak's original code in worksheet.pro
;; 1/30/17 revisit for routine ESP...get countmap from make_countmap.pro, or readin.

   ; get counts of different thresholds
;   lo_thresh = 0.85		; set low threshold
;   hi_thresh = 1.15		; set high threshold
;   NumBelow,sim_pon,lo_thresh,lo_count,lo_cube		; get count below lo_thresh
;   NumAbove,sim_pon,hi_thresh,hi_count,hi_cube		; get count above hi_thresh
;   mid_count = nsims - (lo_count + hi_count) 		; get count between the two
;   ; cancel out years without a defined LGP
;   lo_count(where(cur_gt eq 60)) = !VALUES.F_NAN
;   mid_count(where(cur_gt eq 60)) = !VALUES.F_NAN
;   hi_count(where(cur_gt eq 60)) = !VALUES.F_NAN

;should have domain parameters from readin_FLDAS_noah_sm.pro
; not if i am starting from 'count_map'
params = get_domain01('EA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;this number varies based
;e.g. CHIRPS January = 1054 = 31days*34yrs
nsims = n_elements(ifile)  

;;;read in landcover MODE to grab sparse veg mask;;;
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/'
ifile = file_search(indir+'lis_input.MODISmode_ea.nc')
VOI = 'LANDCOVER'
LC = get_nc(VOI, ifile)
bare = where(LC[*,*,15] eq 1, complement=other)
water = where(LC[*,*,16] eq 1, complement=other)

mask = bytarr(NX,NY)+1
mask(bare) = 0
mask(water) = 0

mask3 = rebin(mask,nx,ny,3)

;;; classify the counts in to the triangles and make an image

   p_most = 2./3.		; hi probability for legend division
   p_least = 1./3.		; lo probability for legend division
   most_cut = p_most * nsims	; hi number cutoff
   least_cut = p_least * nsims	; lo number cutoff
   ct_cube = FLTARR(NX,NY,3)

   ; some mapping stuff
   t_colors = [[232, 232,  54],[235, 125, 134],[243, 243, 147], $
               [133, 197, 156],[221,  17,  86],[227,  64, 139], $
               [138, 127, 183],[ 79, 177, 202],[ 25, 106, 154]]
 ;  map_ulx = -20.05 + (ulx * 0.1)
 ;  map_lrx = -20.05 + (lrx * 0.1)
 ;  map_uly = 40.05 - (uly * 0.1)
 ;  map_lry = 40.05 - (lry * 0.1)

   ; now read in the data and map it
   help, countmap
;   ifile = '/home/almcnall/IDLplots/countmap_294_348_3_SM01.bin'
;   openr,1,ifile
;   readu,1,ct_cube
;   close,1
   
   ct_cube = countmap
   t_class = BYTARR(NX,NY)
   
   ; set the triangle for each class
   t_class(where(ct_cube[*,*,1] ge most_cut)) = 1
   t_class(where(ct_cube[*,*,1] lt most_cut AND ct_cube[*,*,1] ge least_cut AND $
                 ct_cube[*,*,0] lt most_cut AND ct_cube[*,*,0] ge least_cut AND $
		 ct_cube[*,*,2] lt least_cut)) = 2
   t_class(where(ct_cube[*,*,1] lt most_cut AND ct_cube[*,*,1] ge least_cut AND $
                 ct_cube[*,*,0] lt least_cut AND ct_cube[*,*,2] lt least_cut)) = 3
   t_class(where(ct_cube[*,*,1] lt most_cut AND ct_cube[*,*,1] ge least_cut AND $
                 ct_cube[*,*,2] lt most_cut AND ct_cube[*,*,2] ge least_cut AND $
                 ct_cube[*,*,0] lt least_cut)) = 4
   t_class(where(ct_cube[*,*,0] ge most_cut)) = 5
   t_class(where(ct_cube[*,*,0] lt most_cut AND ct_cube[*,*,0] ge least_cut AND $
                 ct_cube[*,*,1] lt least_cut AND ct_cube[*,*,2] lt least_cut)) = 6
   t_class(where(ct_cube[*,*,0] lt most_cut AND ct_cube[*,*,0] ge least_cut AND $
                 ct_cube[*,*,2] lt most_cut AND ct_cube[*,*,2] ge least_cut AND $
                 ct_cube[*,*,1] lt least_cut)) = 7
   t_class(where(ct_cube[*,*,2] lt most_cut AND ct_cube[*,*,2] ge least_cut AND $
                 ct_cube[*,*,0] lt least_cut AND ct_cube[*,*,1] lt least_cut)) = 8
   t_class(where(ct_cube[*,*,2] ge most_cut)) = 9

;;can this be plotted with the EA_plots script?
   wmap = IMAGE(CONGRID(t_class,2*NX,2*NY), $
             IMAGE_DIMENSIONS=[FLOAT(NX)/10.0,FLOAT(NY)/10.0], IMAGE_LOCATION=[map_ulx,map_lry], $
             DIMENSIONS=[2.5*NX,2.5*NY],AXIS_STYLE=2,GRID_UNITS=2, $
             RGB_TABLE=[[255,255,255],[t_colors]], $
             FONT_SIZE=2, /buffer)
   map = MAP('Geographic', $
     LIMIT = [map_lry, map_ulx, map_uly, map_lrx], $
     ;LIMIT = [-35.0, map_ulx, map_uly, map_lrx], $
     /OVERPLOT)
   map.mapgrid.linestyle = 6; 'dotted'
   map.mapgrid.label_show = 0;	turn off labels
   ;map.mapgrid.color = [150, 150, 150]
   ;map.mapgrid.label_position = 0
   ;map.mapgrid.label_color = 'black'
   ;map.mapgrid.FONT_SIZE = 10

   m1 = MAPCONTINENTS(/COUNTRIES, $
     COLOR = [0, 0, 0], THICK=2, $
     FILL_BACKGROUND = 0)

   wmap.save, '/home/almcnall/IDLplots/test_ESP.png'
endfor

wmap.title = 'prob of wet/avg/dry June1, intialized Mar15'

