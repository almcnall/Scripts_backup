;readin CSV files that are also exported to google drive
;
indir = '/home/almcnall/IDLplots/SERVIR_csv/'

;;cumulative ESP mean 2009&2012 Tana
ifile = file_search(indir+'*RO_mean_med.csv') & print, transpose(ifile)

RO_R09 = read_csv(ifile[0])
RO_T09 = read_csv(ifile[1])
RO_R12 = read_csv(ifile[2])
RO_T12 = read_csv(ifile[3])


dummy = LABEL_DATE(DATE_FORMAT=['%N-%D'])

timez = TIMEGEN(START=JULDAY(10,1,2009), FINAL=JULDAY(4,1,2010), units='days')

p1=plot(timez, total(ro_t09.field1, /cumulative),'b', thick=3, /buffer, name = '2009',$
        title = 'Tana Basin mean ESP cumulative runoff scenarios', ytitle='mm')
p2=plot(timez, total(ro_t12.field1,/cumulative),'r', thick=3, /buffer, /current, /overplot, $
        name = '2012', xrange=[min(timez), max(timez)], xtickformat='label_date', xtickinterval=30)
!null = legend(target=[p1,p2], position=[0.6,0.3]) 
p2.save, '/home/almcnall/IDLplots/TS_temp.png'

;;time series, not cumulative
p1=plot(timez, ro_t09.field1,'b', thick=3, /buffer, name = '2009',$
  title = 'Tana Basin mean ESP runoff scenarios', ytitle='mm')
p2=plot(timez, ro_t12.field1,'r', thick=3, /buffer, /current, /overplot, $
  name = '2012', xrange=[min(timez), max(timez)], xtickformat='label_date', xtickinterval=30)
!null = legend(target=[p1,p2], position=[0.6,0.3])
p2.save, '/home/almcnall/IDLplots/TS_temp.png'

;read in the observations
;;plot of the "observed" runoff (OL not ens. mean)
ifile = file_search(indir+'Tana_RO*') & print, transpose(ifile)

ROobs_T = read_csv(ifile)
ROobs_T09 = ROobs_T.field1 * 86400
ROobs_T10 = ROobs_T.field2 * 84600
ROobs_T11 = ROobs_T.field3 * 84600
ROobs_T12 = ROobs_T.field4 * 84600
ROobs_T13 = ROobs_T.field5 * 84600

;make a plot from Oct1-April1
Tan0910 = [ROobs_T09[273:364],ROobs_T10[0:90]] & help, Tan0910
Tan1213 = [ROobs_T12[273:364],ROobs_T13[0:90]] & help, Tan1213

p1=plot(timez, total(tan0910, /cumulative),'b', thick=3, /buffer, name = '2009', title = 'Tana Basin obs-modeled runoff',$
        xrange=[min(timez), max(timez)], xtickformat='label_date', xtickinterval=30, ytitle = 'mm', yrange=[0,60])
p2=plot(timez, total(tan1213,/cumulative),'r', thick=3, /buffer, /current, /overplot, name = '2012')
!null = legend(target=[p1,p2], position=[0.6,0.3])
p2.save, '/home/almcnall/IDLplots/TS_temp.png'

;;re-do the esp spegetti plots here, rainfall
ifile = file_search(indir+'/20121001_Tana_P_ens.csv')
Pens = read_csv(ifile)

p1 = plot(timez,total(pens.(0),/cumulative), 'grey', /buffer, $
          xrange=[min(timez), max(timez)], xtickformat='label_date', xtickinterval=30, ytitle = 'mm',$
          title = 'ESP rainfall scenarios (observed 1982-2015)')
for i = 0,33 do begin &$
  p1 = plot(timez,total(pens.(i),/cumulative),'grey',/buffer, /overplot, /current) &$
endfor
p1.save, '/home/almcnall/IDLplots/TS_temp.png'

;;;and for soil moisture!
timez = TIMEGEN(START=JULDAY(1,1,2009), FINAL=JULDAY(10,1,2009), units='days')
;timez = TIMEGEN(START=JULDAY(10,1,2009), FINAL=JULDAY(4,1,2010), units='days')


ifile = file_search(indir+'Tana_SM*') & print, transpose(ifile)

SMobs_T = read_csv(ifile)
SMobs_T09 = SMobs_T.field1 ; or call via SMobs_T09 = SMobs_T.(0)
SMobs_T10 = SMobs_T.field2
SMobs_T11 = SMobs_T.field3
SMobs_T12 = SMobs_T.field4
SMobs_T13 = SMobs_T.field5

;make a plot from Oct1-April1...why does this one look different funny?
;Tan0910 = [ROobs_T09[273:364],ROobs_T10[0:90]] & help, Tan0910
;Tan1213 = [ROobs_T12[273:364],ROobs_T13[0:90]] & help, Tan1213

p1=plot(timez, SMobs_T09[0:272]*100,'b', thick=3, /buffer, name = '2009', title = 'Tana Basin obs-modeled soil moisture (0-2m)')
p2=plot(timez, SMobs_T12[0:272]*100,'r', thick=2, /buffer, /current, /overplot, name = '2012', ytitle = '% VWC',$
         xrange=[min(timez), max(timez)], xtickformat='label_date', xtickinterval=30)
!null = legend(target=[p1,p2], position=[0.6,0.3])
p2.save, '/home/almcnall/IDLplots/TS_temp.png'

;;;and soil moisture from Oct1-April1
;make a plot from Oct1-April1
Tan0910 = [SMobs_T09[273:364],SMobs_T10[0:90]] & help, Tan0910
Tan1213 = [SMobs_T12[273:364],SMobs_T13[0:90]] & help, Tan1213

p1=plot(timez, tan0910,'b', thick=3, /buffer, name = '2009', title = 'Tana Basin obs-modeled SM (0-2m)',$
  xrange=[min(timez), max(timez)], xtickformat='label_date', xtickinterval=30, ytitle = '%VWC')
p2=plot(timez, tan1213,'r', thick=3, /buffer, /current, /overplot, name = '2012')
!null = legend(target=[p1,p2], position=[0.6,0.3])
p2.save, '/home/almcnall/IDLplots/TS_temp.png'




