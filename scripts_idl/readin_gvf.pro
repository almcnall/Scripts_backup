pro readin_gvf
;7/10/17 incomplete, but can fill in...
.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro

indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/'
ifileS = file_search(indir+'lis_input_sa_elev_hymap_test.nc')

ifileE = file_search(indir+'lis_input_ea_elev_hymapv2.nc')

;VOI = 'HYMAP_basin' &$ ;
VOI = 'GREENNESS' &$ ;
  gvf = get_nc(VOI, ifileE)
gvf(where(gvf lt 0)) = !values.f_nan