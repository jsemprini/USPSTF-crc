

clear all

***import naaccr data***

rename v2 age
egen id=group(age)

egen fips=group(state)
replace fips=0 if us==0
gen old=0
replace old=1 if id!=1

estimates clear 

*drop states with missing rates
drop if state=="Nevada" | state=="Alaska" | state=="Mississippi" | state=="Tennessee" | state=="Virginia"

drop if year==2020 
reg rate i.year#i.old if us==1
margins year#old
marginsplot , scheme(tab2) ylab(0(50)500) xline(2008.5)
graph save naacrr_inc_can.gph, replace

drop fips id

rename age group

egen age=group(group)

egen fips=group(state)

egen id=group(state age)


gen post=0
replace post=1 if year>2008

gen uspstf=0
replace uspstf=1 if age>1 & year>2008

replace uspstf=0 if us==0

*drop Canada provinces with missing rates
drop if state=="Newfoundland and Labrador" | state=="Northwest Territory" | state=="Nunavut" | state=="Prince Edward Island"



estimates clear


eststo: reghdfe rate 1.uspstf i.age i.age#i.fips c.year#i.age i.us i.us#i.age, vce(cluster id) absorb(fips#year)
sum rate if e(sample) & old==1 & year<2008
estadd scalar avg=r(mean)

eststo: reghdfe rate 1.uspstf i.age i.age#i.fips c.year#i.age i.us i.us#i.age if group!="85+"  , vce(cluster id) absorb(fips#year)
sum rate if e(sample) & old==1 & year<2008
estadd scalar avg=r(mean)

eststo: reghdfe rate 1.uspstf i.age i.age#i.fips c.year#i.age i.us i.us#i.age  if group!="75-84"  , vce(cluster id) absorb(fips#year)
estadd scalar avg=r(mean)


esttab , keep(*1.usps*) b(1) ci(1) sca(avg)

