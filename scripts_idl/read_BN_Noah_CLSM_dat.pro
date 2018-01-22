pro read_BN_Noah_CLSM_dat

;the purpose of this is to open the time series of the LVT outputs


indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/LVT_test/EGYPT/CLSMvNoahMP_ex1/STATS_CLSMvNoahMP/'
ifile = file_search(indir+'MEAN_FAME_BN.dat')

indat1 = read_ascii(ifile, dlimiter=" ")
indat1.field01(where(indat1.field01 lt -100))=!values.f_nan

NoahMP_ET = reform(indat1.field01[5,0:1824],365,5)
CLSM_ET = reform(indat1.field01[11,0:1824],365,5)

NoahMP_Qh = reform(indat1.field01[17,0:1824],365,5)
CLSM_Qh = reform(indat1.field01[23,0:1824],365,5)

NoahMP_SM = reform(indat1.field01[29,0:1824],365,5)
CLSM_SM = reform(indat1.field01[35,0:1824],365,5)

NoahMP_RZ = reform(indat1.field01[29+6,0:1824],365,5)
CLSM_RZ = reform(indat1.field01[35+6,0:1824],365,5)

p1 = plot(NoahMP_ET, 'b', name = 'noah-mp ET')
p2 = plot(CLSM_ET, 'c', name = 'clsm ET', /overplot)
!null = legend(target=[p1,p2], position=[0.9,0.9], font_size=14)
p2.title = 'Blue Nile Basin ET 2000-2004'

p1 = plot(NoahMP_SM, 'b', name = 'noah-mp SM')
p2 = plot(CLSM_SM, 'c', name = 'clsm SM', /overplot)
!null = legend(target=[p1,p2], position=[0.9,0.9], font_size=14)
p2.title = 'Blue Nile Basin SM 2000-2004'

p1 = plot(NoahMP_RZ, 'b', name = 'noah-mp RZSM')
p2 = plot(CLSM_RZ, 'c', name = 'clsm RZSM', /overplot)
!null = legend(target=[p1,p2], position=[0.9,0.9], font_size=14)
p2.title = 'Blue Nile Basin RZSM 2000-2004'