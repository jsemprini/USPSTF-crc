clear all
*import NCHS data from SEER*Stat (all-cause)

egen age=group(group)

egen fips=group(state)

egen id=group(state age)

gen uspstf=0
replace uspstf=1 if age>1 & year>2008

estimates clear
eststo: reghdfe rate 1.uspstf i.age i.age#i.fips c.year#i.age , vce(cluster id) absorb(fips#year)

eststo: reghdfe rate 1.uspstf i.age i.age#i.fips c.year#i.age if age!=3 , vce(cluster fips) absorb(fips#year)


eststo: reghdfe rate 1.uspstf i.age i.age#i.fips c.year#i.age if age!=2 , vce(cluster fips) absorb(fips#year)

esttab , b(1) ci(1) keep(1.us*) sca(avg)


clear all
*import NCHS data from SEER*Stat (crc-cause)

rename age group

egen age=group(group)

egen fips=group(state)

egen id=group(state age)

gen uspstf=0
replace uspstf=1 if age>1 & year>2008

estimates clear

drop if state=="Alaska"

eststo: reghdfe rate 1.uspstf i.age i.age#i.fips c.year#i.age , vce(cluster id) absorb(fips#year)
sum rate if e(sample) & age!=1 & year<2008
estadd scalar avg=r(mean)
eststo: reghdfe rate 1.uspstf i.age i.age#i.fips c.year#i.age  if age!=3 , vce(cluster id) absorb(fips#year)
sum rate if e(sample) & age!=1 & year<2008
estadd scalar avg=r(mean)

eststo: reghdfe rate 1.uspstf i.age i.age#i.fips c.year#i.age  if age!=2 , vce(cluster id) absorb(fips#year)
sum rate if e(sample) & age!=1 & year<2008
estadd scalar avg=r(mean)


esttab , b(1) ci(1) keep(1.us*) sca(avg)



clear all

*import NCHS data from SEER*Stat (other cancer-cause)


egen age=group(group)

egen fips=group(state)

egen id=group(state age)

gen uspstf=0
replace uspstf=1 if age>1 & year>2008

estimates clear

eststo: reghdfe rate 1.uspstf i.age i.age#i.fips c.year#i.age , vce(cluster id) absorb(fips#year)
sum rate if e(sample) & age!=1 & year<2008
estadd scalar avg=r(mean)
eststo: reghdfe rate 1.uspstf i.age i.age#i.fips c.year#i.age  if age!=3 , vce(cluster id) absorb(fips#year)
sum rate if e(sample) & age!=1 & year<2008
estadd scalar avg=r(mean)

eststo: reghdfe rate 1.uspstf i.age i.age#i.fips c.year#i.age  if age!=2 , vce(cluster id) absorb(fips#year)
sum rate if e(sample) & age!=1 & year<2008
estadd scalar avg=r(mean)


esttab , b(1) ci(1) keep(1.us*) sca(avg)

