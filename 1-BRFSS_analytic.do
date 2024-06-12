clear all

*import clean BRFSS data

gen agecode=.
foreach n of numlist 1/13{
	replace agecode=`n' if agedum`n'==1
}

gen bs2yr=.
replace bs2yr=0 if bscat==0 | bscat==3 | bscat==4
replace bs2yr=1 if bscat==1 | bscat==2

gen crc2yr=.
replace crc2yr=0 if colsigcat==0 | colsigcat==3 | colsigcat==4
replace crc2yr=1 if colsigcat==1 | colsigcat==2

drop if colsigcat==. & bscat==.

drop if agecode==.

drop agedum1 agedum2 agedum3 agedum4 agedum5 agedum6 agedum7 agedum8 agedum9

drop if agecode>=1 & agecode<=9

keep statefips svywave month perwt age* nhw nhb hisp nho uninsured empstat1 empstat2 empstat3 empstat4 empstat5 empstat6 empstat7 empstat8 edustat1 edustat2 edustat3 edustat4 edustat5 edustat6 hhinc1 hhinc2 hhinc3 hhinc4 hhinc5 hhinc6 hhinc7 hhinc8 marstat1 marstat2 marstat3 marstat4 marstat5 marstat6  bs2yr crc2yr male

global controls nhw nhb hisp empstat1 empstat2 empstat3 empstat4 empstat5 empstat6 empstat7 empstat8 edustat1 edustat2 edustat3 edustat4 edustat5 edustat6 hhinc1 hhinc2 hhinc3 hhinc4 hhinc5 hhinc6 hhinc7 hhinc8 marstat1 marstat2 marstat3 marstat4 marstat5 marstat6 

global controls nhw nhb hisp empstat1 empstat7  edustat4 edustat5 edustat6  hhinc7 hhinc8 marstat1  male


gen college=0
replace college=1 if  edustat5==1 | edustat6==1

gen agecat=.
replace agecat=0 if agecode>=10 & agecode<=11
replace agecat=1 if agecode>=12 & agecode<=13

gen newyear=svywave
foreach n of numlist 1 3 5 7 9{
	replace newyear=svywave-1 if svywave==200`n'
}

foreach n of numlist 11 13 15 17 19{
	replace newyear=svywave-1 if svywave==20`n'
}

drop if svywave==2020

*ssc install schemepack
reg bs2yr i.newyear#agecat [pw=perwt], vce(cluster statefips)
margins newyear#agecat
marginsplot, scheme(tab2) xline(2008.5) ylab(0(.1)1)
graph save bs2yr08.gph, replace 

reg crc2yr i.newyear#agecat [pw=perwt], vce(cluster statefips)
margins newyear#agecat
marginsplot, scheme(tab2) xline(2008.5) ylab(0(.1)1)
graph save col2yr08.gph, replace 

graph combine bs2yr08.gph col2yr08.gph, ycommon

gen post=0
replace post=1 if newyear>=2010

egen id=group(statefips agecode)

gen uspstf_old=agecat*post

estimates clear

foreach y in bs2yr crc2yr {
eststo: reghdfe `y' 1.uspstf_old i.agecode i.newyear i.($controls) [pw=perwt] if newyear!=2008, vce(cluster id) absorb(statefips#newyear)
sum `y' if e(sample) & svywave<2008 & agecat==1
estadd scalar avg=r(mean)

}

esttab using full_colon08.csv , replace b(3) se(3) star(* .1 ** .05 *** .01 **** .001) keep(*uspstf_old) sca(avg)
