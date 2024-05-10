https://github.com/Kiyoiiiii/project/blob/38921b7b2d066db7fa1885f888b0504d4b3995fd/followup.do

import sasxport5 "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DEMO.XPT", clear
 //data
 global mort_1999_2000 https://ftp.cdc.gov/pub/HEALTH_STATISTICS/NCHS/datalinkage/linked_mortality/NHANES_1999_2000_MORT_2019_PUBLIC.dat
 //code
cat https://ftp.cdc.gov/pub/HEALTH_STATISTICS/NCHS/datalinkage/linked_mortality/Stata_ReadInProgramAllSurveys.do

global repo "https://github.com/jhustata/intermediate/raw/main/"
do ${repo}followup.do
save followup, replace 
import sasxport5 "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DEMO.XPT", clear
merge 1:1 seqn using followup
lookfor follow
lookfor mortstat permth_int eligstat 
keep if eligstat==1
capture g years=permth_int/12
codebook mortstat
stset years, fail(mortstat)
sts graph, fail
save demo_mortality, replace 
import sasxport5 "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/HUQ.XPT", clear 
merge 1:1 seqn using demo_mortality, nogen
sts graph, by(huq010) fail
stcox i.huq010
