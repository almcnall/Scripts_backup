function get_domain001, domain

    ;this function cleans up the parameters for the different
    ;domains at 0.01 degrees.
    
    ;Central Asia (21.005 N - 55.995 N; 30.005-99.995E)
   
    ; west africa domain
    if domain eq 'CA' then begin
      map_ulx = 30.005
      map_lrx = 99.995
      map_uly = 55.995
      map_lry = 21.005
    endif
    

    ulx = (180.+ map_ulx)*100.
    lrx = (180.+ map_lrx)*100.-1
    uly = (50.- map_uly)*100. 
    lry = (50.- map_lry)*100.-1
    NX = floor(lrx - ulx + 2)
    NY = floor(lry - uly + 2)
    
    params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry, ulx, lrx, uly, lry]
    return, params

END