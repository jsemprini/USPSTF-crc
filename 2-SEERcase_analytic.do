clear all 

*import SEER case data 

tab agerecodewith1yearolds, gen(dum_age)

keep if dum_age6==1 | dum_age7==1 | dum_age8==1 | dum_age9==1 | dum_age10==1

gen exposed_old=0
replace exposed_old=1 if dum_age8==1 | dum_age9==1 | dum_age10==1

split(agerecodewithsingleagesand90), p("")

rename agerecodewithsingleagesand901 age

drop agerecodewithsingleagesand90 agerecodewith1yearolds dum_age1 dum_age2 dum_age3 dum_age4 dum_age5 dum_age6 dum_age7 dum_age8 dum_age9 dum_age10 agerecodewithsingleagesand902

order exposed_old age

rename (raceandoriginrecodenhwnhbnhaiann maritalstatusatdiagnosis medianhouseholdincomeinflationad ruralurbancontinuumcode seerregistrywithcaandgaaswholest) (race marital hhinc rucc state)

foreach x in race marital hhinc rucc state{ 
	tab `x' , gen(`x'_)
}

gen metro=0
replace metro=1 if rucc_1==1 | rucc_2==1 | rucc_3==1

drop rucc_*

rename race_1 hispanic
rename race_4 nhb
rename race_6 nhw

drop race_*

tab marital
rename marital_2 married
drop marital_*

tab hhinc
rename hhinc_8 highincome
drop hhinc_*

egen fips=group(state)
egen id=group(state exposed_old)

tab firstmalignantprimaryindicator, gen(first_mal)
rename first_mal2 first_malignant_primary

drop first_mal1 
drop firstmalignantprimaryindicator
gen one_primary=0
replace one_primary=1 if sequencenumber=="One primary only"

drop icdo3histbehav sequencenumber

tab  totalnumberofbenignborderlinetum , missing
rename  totalnumberofbenignborderlinetum numb_benign
destring(numb_benign), force replace



tab behaviorcodeicdo3, gen(behavior)
rename behavior1 insitu
rename behavior2 malignant

tab combinedsummarystage2004 if combinedsummarystage2004!="Blank(s)" & combinedsummarystage2004!="Unknown/unstaged", gen(stage)
rename stage1 distant
rename stage3 local
rename stage4 regional

gen advanced=0 if local==1 | stage2==1
replace advanced=1 if regional==1 | distant==1

destring(monthsfromdiagnosistotreatment) , force replace
rename monthsfromdiagnosistotreatment mo2tx

tab yearofdeathrecode
gen alive=0 
replace alive=1 if yearofdeathrecode=="Alive at last contact"

gen yr_death=yearofdeathrecode if alive!=1

destring(yr_death), force replace

rename yearofdiagnosis year_dx

gen num_yeardeath=yearofdeathrecode

replace num_yeardeath="2025" if yearofdeathrecode=="Alive at last contact"

destring(num_yeardeath), force replace

gen surv=num_yeardeath-year_dx

drop if yearofdeathrecode=="2020"

gen surv1=0
replace surv1=1 if surv>1

gen surv2=0 
replace surv2=1 if surv>2

gen surv5=0
replace surv5=1 if surv>5

drop if year_dx==2020

estimates clear 

global y_outcomes insitu local advanced alive surv1 surv2 surv5

***begin analysis***
cd "C:\Users\jsemprini\OneDrive - University of Iowa\4-Misc Projects\p-USPSTF\2-CRC-call\results"
foreach y in $y_outcomes{
	
	reg `y' i.year_dx#i.exposed_old  , vce(cluster id) 
	margins year_dx#exposed_old
	marginsplot , scheme(tab2) xline(2008.5) ylab(0(.2)1)
	graph save g_`y'.gph, replace
}

gen post=0
replace post=1 if year_dx>2009


destring(yearofdeathrecode), force replace
gen survival=2019-year_dx if alive==1
replace survival=yearofdeathrecode-year_dx if alive==0


global y_outcomes insitu local advanced  

global controls hispanic nhb nhw  married metro highincome 


set more off
  quietly log
  local logon = r(status)
  if "`logon'" == "on" { 
	log close 
	}
log using seer_crc_dd, replace text

gen o_uspstf=post*exposed_old

replace age="90" if age=="90+"
destring(age), force replace

estimates clear 
*$y_outcomes
foreach y in  $y_outcomes  {
	

	
	eststo: reghdfe `y' 1.o_uspstf#1.post i.age i.($controls) , vce(cluster id) absorb(year_dx#fips) 
	sum `y' if e(sample)
	estadd scalar avg=r(mean)
	
}

esttab using ddcrc_seer.csv, replace b(3) se(3) keep(*o_uspstf*) sca(avg) star(* .1 ** .05 *** .01 **** .001)


estimates clear 
	
	eststo: reghdfe surv1 1.o_uspstf#1.post i.age i.($controls) if  year_dx!=2019, vce(cluster id) absorb(year_dx#fips) 
	sum surv1 if e(sample)
	estadd scalar avg=r(mean)
	
	eststo: reghdfe surv2 1.o_uspstf#1.post i.age i.($controls) if  year_dx<2018, vce(cluster id) absorb(year_dx#fips) 
	sum surv2 if e(sample)
	estadd scalar avg=r(mean)
	
	
		eststo: reghdfe surv5 1.o_uspstf#1.post i.age i.($controls) if  year_dx<2015, vce(cluster id) absorb(year_dx#fips) 
	sum surv5 if e(sample)
	estadd scalar avg=r(mean)
	
esttab using ddcrc_seer2.csv, replace b(3) se(3) keep(*o_uspstf*) sca(avg) star(* .1 ** .05 *** .01 **** .001)
