# project
Hw6-Sijin Du
Project

1. Download and edit the Stata_ReadInProgramALlSurveys.do provided by NHANES. Upload the edited do file to the github. This do file imports and prepare the mortality data which further analysis would be based on.
https://ftp.cdc.gov/pub/HEALTH_STATISTICS/NCHS/datalinkage/linked_mortality/Stata_ReadInProgramAllSurveys.do   
Refer to the followup.do to see edits.

2. Link the do file in step 1
global repo "https://github.com/WenjieCai825/project/blob/main/"
do ${repo}followup.do
save followup, replace

4. merge with DEMO data
import sasxport5 "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DEMO.XPT", clear
merge 1:1 seqn using followup
lookfor follow

5. Prepare the key Parameters for Week 7s Analysis
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
Documentation for HUQ dataset: https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/HUQ.htm
