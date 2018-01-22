pro CSV_for_SERVIR

;write out the daily files for 2009-10 and 2012-13

;readin file from readin_FLDAS_noah_daily
help, Pday, ETday, ROday, SMday, SM2day
pday(where(pday lt 0)) = !values.f_nan
etday(where(etday lt 0)) = !values.f_nan
roday(where(roday lt 0)) = !values.f_nan
smday(where(smday lt 0)) = !values.f_nan
sm2day(where(sm2day lt 0)) = !values.f_nan

;readin basins of interest from pfaf2
help, rufi_mask, tana_mask

;take the mean of all layers
SM = mean(smday,dimension=5,/nan)

;layer 1 10cm = 0.1/2   = 0.05
; layer 2 10-40 = 0.3/2 = 0.15
;layer 3 40-100 = 0.6/2 = 0.3
;100-200 = 1.0/2        = 0.5

w = [0.05, 0.15, 0.3, 0.5]
w2 = rebin(reform(w,1,1,1,1,4),NX,NY,366,5,4) & help, w2
smw = total(smday*w2,5) & help, smw

R_P = reform(mean(mean(pday*rebin(rufi_mask,nx,ny,366,5),dimension=1, /nan), dimension=1, /nan)) & help, R_P
T_P = reform(mean(mean(pday*rebin(tana_mask,nx,ny,366,5),dimension=1, /nan), dimension=1, /nan)) & help, T_P

ofile =  '/home/almcnall/IDLplots/Rufuji_P_2009_2013.csv'
write_csv, ofile, transpose(r_p)
ofile =  '/home/almcnall/IDLplots/Tana_P_2009_2013.csv'
write_csv, ofile, transpose(t_p)

R_ET = reform(mean(mean(etday*rebin(rufi_mask,nx,ny,366,5),dimension=1, /nan), dimension=1, /nan)) & help, R_ET
T_ET = reform(mean(mean(etday*rebin(tana_mask,nx,ny,366,5),dimension=1, /nan), dimension=1, /nan)) & help, T_ET

ofile =  '/home/almcnall/IDLplots/Rufuji_ET_2009_2013.csv'
write_csv, ofile, transpose(r_et)
ofile =  '/home/almcnall/IDLplots/Tana_ET_2009_2013.csv'
write_csv, ofile, transpose(t_et)

;;;;;transposed and written out 1/20/18 7:50am
R_RO = reform(mean(mean(roday*rebin(rufi_mask,nx,ny,366,5),dimension=1, /nan), dimension=1, /nan)) & help, R_RO
T_RO = reform(mean(mean(roday*rebin(tana_mask,nx,ny,366,5),dimension=1, /nan), dimension=1, /nan)) & help, T_RO

ofile =  '/home/almcnall/IDLplots/Rufiji_RO_2009_2013.csv'
write_csv, ofile, transpose(r_ro)
ofile =  '/home/almcnall/IDLplots/Tana_RO_2009_2013.csv'
write_csv, ofile, transpose(t_ro)

;;;;;transposed and written out 1/20/18 7:50am
R_SM = reform(mean(mean(smw*rebin(rufi_mask,nx,ny,366,5),dimension=1, /nan), dimension=1, /nan)) & help, R_SM
T_SM = reform(mean(mean(smw*rebin(tana_mask,nx,ny,366,5),dimension=1, /nan), dimension=1, /nan)) & help, T_SM

ofile =  '/home/almcnall/IDLplots/Rufiji_SM_2009_2013.csv'
write_csv, ofile, transpose(r_sm)
ofile =  '/home/almcnall/IDLplots/Tana_SM_2009_2013.csv'
write_csv, ofile, transpose(t_sm)

multarr = fltarr(nx,ny,366,5,4)+1

T_SM4 = reform(mean(mean(smday[*,*,*,*,3]*rebin(tana_mask,nx,ny,366,5),dimension=1, /nan), dimension=1, /nan)) & help, T_SM4

ofile =  '/home/almcnall/IDLplots/Tana_SM04_2009_2013.csv'
write_csv, ofile, transpose(t_sm4)
;take a look before writing it out..looks fine
;p1=plot(total(T_RO[*,0]*86400,/cumulative),'r', thick=3, /buffer, name = 'tana 2009')
;p1=plot(total(R_RO[*,0]*86400,/cumulative),'b', /overplot,thick=3, /buffer, name = 'rufiji 2009')
;
;!null = legend(target=[p1], position=[0.6,0.3])
;p1.save, '/home/almcnall/IDLplots/TS_temp.png'



