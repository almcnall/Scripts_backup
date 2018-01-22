pro intial_cond_std

;looking at the variance in intial conditions for sept30/Oct 1 to explore the utility of ESP vs just rainfall

;;readin all of the October 1st data from 1982-2016 and look at the varaince
;use readin_NOAH_daily.
help, smday, sm2day, etday, pday, roday
;compute and map the variance for the first of the month
varSMday = stddev(total(smday[*,*,0:9,0,*],3), dimension=4,/nan)/mean(total(smday[*,*,0:9,0,*],3), dimension=4,/nan) & help, varSMday
varSM2day = stddev(total(sm2day[*,*,0:9,0,*],3), dimension=4,/nan)/mean(total(sm2day[*,*,0:9,0,*],3), dimension=4,/nan) & help, varSM2day
varETday = stddev(total(ETday[*,*,0:9,0,*],3), dimension=4,/nan)/mean(total(ETday[*,*,0:9,0,*],3), dimension=4,/nan) & help, varETday
varROday = stddev(total(ROday[*,*,0:0,0,*],3), dimension=4,/nan)/mean(total(ROday[*,*,0:0,0,*],3), dimension=4,/nan) & help, varROday
varPday = stddev(total(Pday[*,*,0:9,0,*],3), dimension=4,/nan)/mean(total(Pday[*,*,0:9,0,*],3), dimension=4,/nan) & help, varPday

p2 = image(varSMday, rgb_table=20, /buffer, title='SM01', min=0, max=2) & c=colorbar(target=p2)
p3 = image(varSM2day,rgb_table=20, /buffer, title='SM02', min=0, max=2) & c=colorbar(target=p3)
p4 = image(varETday, rgb_table=20, /buffer, title = 'ET', min=0, max=2) & c=colorbar(target=p4)
p5 = image(varROday, rgb_table=20, /buffer, title = 'RO', min=0, max=2) & c=colorbar(target=p5)
p6 = image(varPday, rgb_table=20, /buffer, title = 'P', min=0, max=2) & c=colorbar(target=p6)


p2.save, '/home/almcnall/IDLplots/VARSM_MAP.png'
p3.save, '/home/almcnall/IDLplots/VARSM2_MAP.png'
p4.save, '/home/almcnall/IDLplots/VARET_MAP.png'
p5.save, '/home/almcnall/IDLplots/VARRO_MAP.png'
p6.save, '/home/almcnall/IDLplots/VARP_MAP.png'