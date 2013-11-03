

/* sample selection script */
/* selects core sample and merges topical datasets */

/* read http://www.census.gov/sipp/usrguide/sipp2001.pdf for general overview and structure */
/* look at http://www.census.gov/sipp/usrguide.html more up-to-date chapters */

** SIPP basics
**interviews conducted at 4 month intervals
**each interview is called a wave
**wave 1 is first interview


*** Some definitions regarding identication of sampling units

*** 1) household: obs with identical (ssuid, shhadid)
*** 2) families:  obs with identical (ssuid, shhadid,rfid)
*** 3) persons:   obs with identical (ssuid, epppnum)



** aim: 
** ==== 
              
** 1) from each wave, select subset of variables from Core Data to be used in analysis
** 2) for each wave where available, select subset of variables from Topical Data to be used in analysis
** 3) merge topical data into core dataset
** 4) save.

** topical modules index
** =====================

** sippp08putm2.dta: migration history. documentation at http://www.nber.org/sipp/2008/2008w2tm.pdf

*	tprstate	state or country of previous home
*	eprevres	where the previous home was
*	tbrstate	state or country of birth
*	tmovyryr	year moved into current home
*	toutinyr	year moved into previous home
*	tmovest		year moved into this state
*	eprevten	type of tenure of the previous home
 
** sippp08putm4.dta: wealth. real estate, assets and liabilities, total net worth thhtnw
** doc at http://www.nber.org/sipp/2008/2008w4tm.pdf

*	thhtnw		total net worth recode
*	thhtwlth	total wealth recode
*	thhtheq		home equity recode
*	thhmortg	total debt owed on home
 	

** sippp08putm7.dta: wealth. real estate, assets and liabilities, total net worth thhtnw
** sippp08putm10.dta: wealth. real estate, assets and liabilities, total net worth thhtnw

** merge instructions:
** ===================

** Sort the core wave extract using SSUID (SUID), EENTAID (ENTRY), and EPPPNUM (PNUM) 
** as the sort keys. These three variables uniquely identify people in the core wave files. 
** If the core wave extract is in the person-month format, include SREFMON (REFMTH) 
** as the final sort key.

** Create an extract from the topical module file of interest. 
** Sort the topical module extract using SSUID (ID), EENTAID (ENTRY), 
** and EPPPNUM (PNUM) as the sort keys.


* prepare topical datasets
* for each of them sort in the right way

* merging topical into each wave loop

clear
cd ~/datasets/SIPP/2008/dta
set more off

** variable index is online at
** https://docs.google.com/spreadsheet/pub?key=0AnOrv_MIRexjdGZNNXZHb3ZXbmV5OXRJRFZTOE0yYnc&output=html

** switch to ; delimiter to enter this list
#delimit ;
local corevars ssuid
shhadid
srefmon
rhcalmn
rhcalyr
tfipsst
tmovrflg
eoutcome
rhnf
tmetro
etenure
epubhse
tmthrnt
rfid
efrefper
rfnkids
wffinwgt
tftotinc
epppnum
wpfinwgt
eenlevel
eeducate
eentaid
tage
esex
erace
ebornus
eafnow
ems
epdjbthn
ersnowrk
east3e ;

** switch back;
#delimit cr


foreach wave of numlist 1(1)13 {

	** open core(wave) dataset
	use sippl08puw`wave'.dta,clear

	** subset core data
	** ----------------

	** drop if non-interview
	drop if eppintvw > 2

	** drop if age <15
	/*drop if tage < 15*/

	** keep interesting variables
	keep `corevars'
	
	** sort in correct way
	sort ssuid eentaid epppnum srefmon

	** save as tmp
	save tmp, replace

	** open migration history
	use sippp08putm2.dta,clear

	** merge required variables from mighist onto tmp 
	keep ssuid eentaid epppnum tprstate eprevres tbrstate tmovyryr toutinyr tmovest eprevten
	sort ssuid eentaid epppnum

	** merge m:1 because we have multiple observation per person (up to 4 per wave), but only
	** one entry per person on the topical file
	merge 1:m ssuid eentaid epppnum using tmp, assert(master match) keep(match master)
	drop _merge

	** save tmp
	sort ssuid eentaid epppnum srefmon
	save tmp,replace

	** open wealth4
	use sippp08putm4.dta,clear
	keep ssuid eentaid epppnum thhtnw thhtwlth thhtheq thhmortg
	sort ssuid eentaid epppnum

	** merge required variables from wealth4 onto tmp
	merge 1:m ssuid eentaid epppnum using tmp, assert(master match) keep(match master)
	drop _merge
	
	** save tmp
	sort ssuid eentaid epppnum srefmon
	save tmp,replace

	** open wealth7
	use sippp08putm7.dta,clear
	keep ssuid eentaid epppnum thhtnw thhtwlth thhtheq thhmortg
	sort ssuid eentaid epppnum

	** merge required variables with suffix _7 from wealth7 onto tmp
	merge 1:m ssuid eentaid epppnum using tmp, assert(master match) keep(match master)
	drop _merge
	
	** save tmp
	sort ssuid eentaid epppnum srefmon
	save tmp,replace

	** open wealth10
	use sippp08putm10.dta,clear
	keep ssuid eentaid epppnum thhtnw thhtwlth thhtheq thhmortg
	sort ssuid eentaid epppnum

	** merge required variables with suffix _10 from wealth10 onto tmp
	/*merge m:1 ssuid eentaid epppnum using tmp, replace assert(master match) keep(match master)*/
	merge 1:m ssuid eentaid epppnum using tmp, assert(master match) keep(match master)
	drop _merge

	** save 
	sort ssuid eentaid epppnum srefmon
	save core_and_topical/core_top`wave'.dta, replace

}










