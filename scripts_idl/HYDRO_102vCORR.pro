pro HYDRO_102vCORR

;the regional water balance
; 8/8/16
; 8/22/16 replotting ratios with colorbars and country boundaries
; 8/30/16 add timeseries for regions of interest
; 9/01/16 try to fix crashing problems by not using ide
; 6/06/17 check the water balance at Thika
; 7/06/17 add extract data by HYMAP basin (readin_HYMAP_basin.pro)
; 9/14/17 update with the basins from Kris (do this in readin_HYMAP_basin.pro)
; 9/15 make this a separate script just to compute Noah (RFE2, CHIRPS) ET vs SSEB correlation and bias
;      for the different basins of interest.

;readin CHIRPS ET, RFE2 ET, SSEB ET 2003-2017
;chirps_ET=evap

;ET=SSEB and which is Evap=Noah
HELP, ET, chirps_ET, rfe_et, gvf
help, bnile_mask, nile_mask, jsb_mask, rufi_mask, tana_mask, luku_mask
help, zamb_mask, limp_mask,  rufi_mask, orng_mask, pag_mask, inco_mask, hwan_mask
help, mana_mask

;;plot the SM01 time series for the zambiezi basin & write out csv
;help, sm01
;sm01_v = reform(sm01[*,*,*,0:32],nx, ny, 33*nmos) & help, sm01_v
;zmask396 = rebin(zamb_mask, nx, ny, 396)
;p1 = plot(mean(mean(sm01_v*zmask396,dimension=1,/nan),dimension=1,/nan), /overplot, 'b')
;z_sm01_ts = mean(mean(sm01_v*zmask396,dimension=1,/nan),dimension=1,/nan) & help, z_sm01_ts


;;plot the rainfall and ET time series for the blue nile basin
HELP, ET, chirps_ET

BN_mask432 = rebin(bnile_mask, nx, ny, nyrs*nmos)
N_mask432 = rebin(nile_mask, nx, ny, nyrs*nmos)
R_mask432 = rebin(rufi_mask, nx, ny, nyrs*nmos)
T_mask432 = rebin(tana_mask, nx, ny, nyrs*nmos)
JB_mask432 = rebin(jsb_mask, nx, ny, nyrs*nmos)
L_mask432 = rebin(luku_mask, nx, ny, nyrs*nmos)

;R_mask432 = rebin(rufi_mask, nx, ny, nyrs*nmos)
;O_mask432 = rebin(orng_mask, nx, ny, nyrs*nmos)
;Z_mask432 = rebin(zamb_mask, nx, ny, nyrs*nmos)
;L_mask432 = rebin(limp_mask, nx, ny, nyrs*nmos)
;mask432 = rebin(pag_mask, nx, ny, 432)
;mask432 = rebin(inco_mask, nx, ny, 432)
;mask432 = rebin(mana_mask, nx, ny, 432)

;V_mask432 = rebin(volt_mask, nx, ny, nyrs*nmos)
;N_mask432 = rebin(nig_mask, nx, ny, nyrs*nmos)

mask432 = L_mask432

;apply the mask, get the time series and the monthly average
evapC_cube = mean(mean(chirps_et*mask432,dimension=1,/nan),dimension=1,/nan)*86400*30 & help, evapC_cube
evapC_ts = reform(evapC_cube,nmos*nyrs)
evapC_avg = mean(evapC_cube[*,0:13],dimension=2,/nan)
evapC_avg180 = reform(rebin(evapc_avg,nmos,nyrs),nmos*nyrs) ;repeat the avg for differencing

et_cube = mean(mean(et*mask432,dimension=1,/nan),dimension=1,/nan) & help, et_cube
et_ts = reform(et_cube,nmos*nyrs)
et_avg = mean(et_cube[*,0:13],dimension=2,/nan)
et_avg180 = reform(rebin(et_avg,nmos,nyrs),nmos*nyrs) ;repeat the avg for differencing

;evapR_cube = mean(mean(rfe_et*mask432,dimension=1,/nan),dimension=1,/nan)*86400*30 & help, evapC_cube
;evapR_ts = reform(evapR_cube,nmos*nyrs)
;evapR_avg = mean(evapR_cube[*,0:13],dimension=2,/nan)
;evapR_avg180 = reform(rebin(evapr_avg,nmos,nyrs),nmos*nyrs) ;repeat the avg for differencing

;;get the mean bias, ;compute the bias ratio instead of total or annual ET?
;biasR = mean(et_ts-evapR_ts, /nan) & print, biasR
;biasC = mean(et_ts-evapC_ts, /nan) & print, biasC

;biasRr = total(et_ts)/total(evapR_ts) & print, biasRr
;biasCr = 1-(mean(et_ts, /nan)/mean(evapC_ts, /nan))*100 & print, biasCr

biasRE = (total(evapC_ts, /nan)-total(et_ts, /nan))/total(et_ts, /nan) & print, biasRE


;get the monthly anomaly...this isn't really taking out the signal, check these.
;etR_cube_avg = REFORM(REBIN(mean(reform(evapR_ts,nmos,nyrs),dimension=2,/nan), NMOS,NYRS), NMOS*NYRS) & help, etR_cube_avg
;etR_anom = evapR_ts-etR_cube_avg  & help, etR_anom

et_anom = et_ts[0:174]-et_avg180[0:174]  & help, et_anom
evapC_anom = evapC_ts[0:174]-evapC_avg180[0:174] & help, evapC_anom
;evapR_anom = evapR_ts[0:174]-evapR_avg180[0:174] & help, evapR_anom

;annomaly correlations.....p-correlation, r-correlation
NCvS = r_correlate(evapC_anom,et_anom) & print, NCvS
NRvS = r_correlate(evapR_anom,et_anom) & print, NRvS
;SvA =  r_correlate(et_anom,alexi_anom) & print, SvA



;gvf_cum = total(mean(mean(gvf*mask432,dimension=1,/nan),dimension=1,/nan),  /cumulative) & help, gvf_cum

;evapR_mon = mean(mean(mean(rfe_et[*,*,*,0:13]*mask432,dimension=1,/nan),dimension=1,/nan), dimension=2,/nan)*86400*30 & help, evapR_mon
;evapC_mon = mean(mean(mean(chirps_et[*,*,*,0:13]*mask432,dimension=1,/nan),dimension=1,/nan), dimension=2,/nan)*86400*30 & help, evapC_mon
;et_mon = mean(mean(mean(et[*,*,*,0:13]*mask432,dimension=1,/nan),dimension=1,/nan), dimension=2) & help, et_mon
;alexi_mon = mean(mean(mean(eacube01*mask432,dimension=1,/nan),dimension=1,/nan), dimension=2) & help, alexi_mon

;gvf_mon =  mean(mean(gvf*mask432,dimension=1,/nan),dimension=1,/nan) & help, gvf_mon

;evap_cum = total(mean(mean(mean(evap*mask432,dimension=1,/nan),dimension=1,/nan), dimension=2,/nan)*86400*30, /cumulative) & help, evap_cum
;et_cum = total(mean(mean(mean(et*mask432,dimension=1, /nan),dimension=1, /nan), dimension=2), /cumulative) & help, et_cum
;alexi_cum = total(mean(mean(mean(eacube01*mask432,dimension=1, /nan),dimension=1, /nan), dimension=2), /cumulative) & help, alexi_cum

;linestly 2 = dash 0=solid
linestyle = 2
;w=window()
;p1 = plot(evapR_mon, 'b', /overplot, thick=2)
;p1 = plot(evapC_mon,'b',linestyle=linestyle, thick=2, /overplot)
;p1 = plot(et_mon,'c',thick=2, /overplot)
;p1.title = 'Lukuga ET Cyan = SSEBopv4, Blue-dash = CHIRPS-MERRA2, Blue=RFE2-GDAS'

w=window()
dummy = LABEL_DATE(DATE_FORMAT=['%Y-%M'])
time82 = TIMEGEN(START=JULDAY(1,1,2003), FINAL=JULDAY(12,31,2017), units='months')

p1=plot(time82,evapR_ts, /current, xrange=[min(time82),max(time82)], xtickformat='label_date') & p1.yrange=[0,140]
p1=plot(time82,evapC_ts, /current, xrange=[min(time82),max(time82)], xtickformat='label_date', font_size=12, 'c')  & p1.yrange=[0,140]
p1=plot(time82,et_ts, /current, xrange=[min(time82),max(time82)], xtickformat='label_date', font_size=12, 'orange')  & p1.yrange=[0,140]
p1.title = 'Lukuga basin ssebop=orange, chirps=cyan, rfe=black'

;;;anoms;;;;;;
w=window()
dummy = LABEL_DATE(DATE_FORMAT=['%Y-%M'])
time82 = TIMEGEN(START=JULDAY(1,1,2003), FINAL=JULDAY(12,31,2017), units='months')

;p1=plot(time82,etR_anom, /current, xrange=[min(time82),max(time82)], xtickformat='label_date') & p1.yrange = [-60,60]
p1=plot(time82,evapC_anom, /current, xrange=[min(time82),max(time82)], xtickformat='label_date', font_size=12, 'c')  & p1.yrange = [-60,60]
p1=plot(time82,et_anom, /current, xrange=[min(time82),max(time82)], xtickformat='label_date', font_size=12, 'orange')  & p1.yrange = [-60,60]
p1.title = 'Orange basin ssebop=orange, chirps=cyan'

