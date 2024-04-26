set more off
*remember to change the working directory
*and to download pop.dta into that directory
cd ""

import delimited "https://api.covidtracking.com/v1/states/daily.csv", clear

tostring date, replace
gen date2=date(date,"YMD")
format date2 %tdMon_DD
drop date
rename date2 date
lab var date "Date"
gen today=date(c(current_date),"DMY")
format today %td_Mon_DD

keep if today-date>=2 & date>=date("07mar2020","DMY")
statastates, abbreviation(state)
drop state
rename state_name state
replace state=proper(state)
replace state="District of Columbia" if state=="District Of Columbia"
keep state date negativeincrease positiveincrease deathincrease totaltestresultsincrease

merge m:1 state using pop.dta
keep if _merge==3
drop _merge

gen new_cases_per100k=(positiveincrease/population)*100000
replace new_cases_per100k=0 if missing(new_cases_per100k) | new_cases_per100k<0
replace new_cases_per100k=300 if new_cases_per100k>300
label var new_cases_per100k "New Cases per 100,000 Residents"
gen new_deaths_per100k=(deathincrease/population)*100000
replace new_deaths_per100k=0 if missing(new_deaths_per100k) | new_deaths_per100k<0
replace new_deaths_per100k=6 if new_deaths_per100k>6
label var new_deaths_per100k "New Deaths per 100,000 Residents"

bysort state (date): gen reg_date=_n-1
gen state_nospace=subinstr(state," ","",.)
replace state_nospace="DC" if state_nospace=="DistrictofColumbia"

local bwidth=(50/(_N/51))
foreach state in "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "DC" "Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" "Nevada" "NewHampshire" "NewJersey" "NewMexico" "NewYork" "NorthCarolina" "NorthDakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" "RhodeIsland" "SouthCarolina" "SouthDakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" "Washington" "WestVirginia" "Wisconsin" "Wyoming"{
display "`state'"
lowess new_cases_per100k reg_date if state_nospace=="`state'", nog gen(new_cases_smooth_`state') bwidth(`bwidth')
replace new_cases_smooth_`state'=0 if new_cases_smooth_`state'<0
lowess new_deaths_per100k reg_date if state_nospace=="`state'", nog gen(new_deaths_smooth_`state') bwidth(`bwidth')
replace new_deaths_smooth_`state'=0 if new_deaths_smooth_`state'<0
}
egen new_cases_smooth=rowfirst(new_cases_smooth_Alabama new_cases_smooth_Alaska new_cases_smooth_Arizona new_cases_smooth_Arkansas new_cases_smooth_California new_cases_smooth_Colorado new_cases_smooth_Connecticut new_cases_smooth_Delaware new_cases_smooth_DC new_cases_smooth_Florida new_cases_smooth_Georgia new_cases_smooth_Hawaii new_cases_smooth_Idaho new_cases_smooth_Illinois new_cases_smooth_Indiana new_cases_smooth_Iowa new_cases_smooth_Kansas new_cases_smooth_Kentucky new_cases_smooth_Louisiana new_cases_smooth_Maine new_cases_smooth_Maryland new_cases_smooth_Massachusetts new_cases_smooth_Michigan new_cases_smooth_Minnesota new_cases_smooth_Mississippi new_cases_smooth_Missouri new_cases_smooth_Montana new_cases_smooth_Nebraska new_cases_smooth_Nevada new_cases_smooth_NewHampshire new_cases_smooth_NewJersey new_cases_smooth_NewMexico new_cases_smooth_NewYork new_cases_smooth_NorthCarolina new_cases_smooth_NorthDakota new_cases_smooth_Ohio new_cases_smooth_Oklahoma new_cases_smooth_Oregon new_cases_smooth_Pennsylvania new_cases_smooth_RhodeIsland new_cases_smooth_SouthCarolina new_cases_smooth_SouthDakota new_cases_smooth_Tennessee new_cases_smooth_Texas new_cases_smooth_Utah new_cases_smooth_Vermont new_cases_smooth_Virginia new_cases_smooth_Washington new_cases_smooth_WestVirginia new_cases_smooth_Wisconsin new_cases_smooth_Wyoming)
egen new_deaths_smooth=rowfirst(new_deaths_smooth_Alabama new_deaths_smooth_Alaska new_deaths_smooth_Arizona new_deaths_smooth_Arkansas new_deaths_smooth_California new_deaths_smooth_Colorado new_deaths_smooth_Connecticut new_deaths_smooth_Delaware new_deaths_smooth_DC new_deaths_smooth_Florida new_deaths_smooth_Georgia new_deaths_smooth_Hawaii new_deaths_smooth_Idaho new_deaths_smooth_Illinois new_deaths_smooth_Indiana new_deaths_smooth_Iowa new_deaths_smooth_Kansas new_deaths_smooth_Kentucky new_deaths_smooth_Louisiana new_deaths_smooth_Maine new_deaths_smooth_Maryland new_deaths_smooth_Massachusetts new_deaths_smooth_Michigan new_deaths_smooth_Minnesota new_deaths_smooth_Mississippi new_deaths_smooth_Missouri new_deaths_smooth_Montana new_deaths_smooth_Nebraska new_deaths_smooth_Nevada new_deaths_smooth_NewHampshire new_deaths_smooth_NewJersey new_deaths_smooth_NewMexico new_deaths_smooth_NewYork new_deaths_smooth_NorthCarolina new_deaths_smooth_NorthDakota new_deaths_smooth_Ohio new_deaths_smooth_Oklahoma new_deaths_smooth_Oregon new_deaths_smooth_Pennsylvania new_deaths_smooth_RhodeIsland new_deaths_smooth_SouthCarolina new_deaths_smooth_SouthDakota new_deaths_smooth_Tennessee new_deaths_smooth_Texas new_deaths_smooth_Utah new_deaths_smooth_Vermont new_deaths_smooth_Virginia new_deaths_smooth_Washington new_deaths_smooth_WestVirginia new_deaths_smooth_Wisconsin new_deaths_smooth_Wyoming)
drop reg_date state_nospace new_cases_smooth_Alabama new_deaths_smooth_Alabama new_cases_smooth_Alaska new_deaths_smooth_Alaska new_cases_smooth_Arizona new_deaths_smooth_Arizona new_cases_smooth_Arkansas new_deaths_smooth_Arkansas new_cases_smooth_California new_deaths_smooth_California new_cases_smooth_Colorado new_deaths_smooth_Colorado new_cases_smooth_Connecticut new_deaths_smooth_Connecticut new_cases_smooth_Delaware new_deaths_smooth_Delaware new_cases_smooth_DC new_deaths_smooth_DC new_cases_smooth_Florida new_deaths_smooth_Florida new_cases_smooth_Georgia new_deaths_smooth_Georgia new_cases_smooth_Hawaii new_deaths_smooth_Hawaii new_cases_smooth_Idaho new_deaths_smooth_Idaho new_cases_smooth_Illinois new_deaths_smooth_Illinois new_cases_smooth_Indiana new_deaths_smooth_Indiana new_cases_smooth_Iowa new_deaths_smooth_Iowa new_cases_smooth_Kansas new_deaths_smooth_Kansas new_cases_smooth_Kentucky new_deaths_smooth_Kentucky new_cases_smooth_Louisiana new_deaths_smooth_Louisiana new_cases_smooth_Maine new_deaths_smooth_Maine new_cases_smooth_Maryland new_deaths_smooth_Maryland new_cases_smooth_Massachusetts new_deaths_smooth_Massachusetts new_cases_smooth_Michigan new_deaths_smooth_Michigan new_cases_smooth_Minnesota new_deaths_smooth_Minnesota new_cases_smooth_Mississippi new_deaths_smooth_Mississippi new_cases_smooth_Missouri new_deaths_smooth_Missouri new_cases_smooth_Montana new_deaths_smooth_Montana new_cases_smooth_Nebraska new_deaths_smooth_Nebraska new_cases_smooth_Nevada new_deaths_smooth_Nevada new_cases_smooth_NewHampshire new_deaths_smooth_NewHampshire new_cases_smooth_NewJersey new_deaths_smooth_NewJersey new_cases_smooth_NewMexico new_deaths_smooth_NewMexico new_cases_smooth_NewYork new_deaths_smooth_NewYork new_cases_smooth_NorthCarolina new_deaths_smooth_NorthCarolina new_cases_smooth_NorthDakota new_deaths_smooth_NorthDakota new_cases_smooth_Ohio new_deaths_smooth_Ohio new_cases_smooth_Oklahoma new_deaths_smooth_Oklahoma new_cases_smooth_Oregon new_deaths_smooth_Oregon new_cases_smooth_Pennsylvania new_deaths_smooth_Pennsylvania new_cases_smooth_RhodeIsland new_deaths_smooth_RhodeIsland new_cases_smooth_SouthCarolina new_deaths_smooth_SouthCarolina new_cases_smooth_SouthDakota new_deaths_smooth_SouthDakota new_cases_smooth_Tennessee new_deaths_smooth_Tennessee new_cases_smooth_Texas new_deaths_smooth_Texas new_cases_smooth_Utah new_deaths_smooth_Utah new_cases_smooth_Vermont new_deaths_smooth_Vermont new_cases_smooth_Virginia new_deaths_smooth_Virginia new_cases_smooth_Washington new_deaths_smooth_Washington new_cases_smooth_WestVirginia new_deaths_smooth_WestVirginia new_cases_smooth_Wisconsin new_deaths_smooth_Wisconsin new_cases_smooth_Wyoming new_deaths_smooth_Wyoming

bysort state: egen max_new_cases=max(new_cases_per100k)
bysort state: egen max_new_deaths=max(new_deaths_per100k)
bysort state: gen seqnum=_n
sort max_new_cases
list state max_new_cases if seqnum==1, noobs abbrev(13)
sort max_new_deaths
list state max_new_deaths if seqnum==1, noobs abbrev(14)
drop seqnum
sort state date

set more off
foreach state in "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "District of Columbia" "Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" "Nevada" "New Hampshire" "New Jersey" "New Mexico" "New York" "North Carolina" "North Dakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" "Rhode Island" "South Carolina" "South Dakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" "Washington" "West Virginia" "Wisconsin" "Wyoming"{
graph twoway ///
(bar new_cases_per100k date, color(navy) yaxis(1)) ///
(line new_cases_smooth date, color(black) lwidth(medthick) yaxis(1)) ///
if state=="`state'", xlabel(21975 "Mar" 22006 "Apr" 22036 "May" 22067 "Jun" 22097 "Jul" 22128 "Aug" 22159 "Sep" 22189 "Oct" 22220 "Nov" 22250 "Dec" 22281 "Jan" 22312 "Feb" 22340 "Mar") ylabel(0(50)300, angle(0)) graphregion(color(white)) title("New Daily Confirmed Cases", color(black)) legend(off)
graph save "`state'_cases", replace
graph twoway ///
(bar new_deaths_per100k date, color(red*2)) ///
(line new_deaths_smooth date, color(black) lwidth(medthick)) ///
if state=="`state'", xlabel(21975 "Mar" 22006 "Apr" 22036 "May" 22067 "Jun" 22097 "Jul" 22128 "Aug" 22159 "Sep" 22189 "Oct" 22220 "Nov" 22250 "Dec" 22281 "Jan" 22312 "Feb" 22340 "Mar") graphregion(color(white)) ylabel(0(1)6, angle(0)) title("New Daily Confirmed Deaths", color(black)) legend(off)
graph save "`state'_deaths", replace
graph combine "`state'_cases.gph" "`state'_deaths.gph", rows(1) graphregion(color(white)) title("{bf:`state'}" "COVID-19 Trends for Daily Cases and Deaths" "Per 100,000 Residents", color(black)) xsize(12) ysize(4) note("Data from COVID Tracking Project and CDC" "$S_DATE")
graph export "`state'.png", replace width(2000)
erase "`state'_cases.gph"
erase "`state'_deaths.gph"
}
