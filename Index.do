# project
Hw6-Sijin Du
Project

1. Download and edit the Stata_ReadInProgramALlSurveys.do provided by NHANES. Upload the edited do file to the github. This do file imports and prepare the mortality data which further analysis would be based on.
https://ftp.cdc.gov/pub/HEALTH_STATISTICS/NCHS/datalinkage/linked_mortality/Stata_ReadInProgramAllSurveys.do   
Refer to the followup.do to see edits.

2. Link the do file in step 1
global repo "https://github.com/kiyoiiiii/project/blob/main/"
do ${repo}followup.do
save followup, replace

3. merge with DEMO data
import sasxport5 "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DEMO.XPT", clear
merge 1:1 seqn using followup
lookfor follow

4. Prepare the key Parameters for Week 7s Analysis
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


<<dd_version: 2>>     
<<dd_include: header.txt>>

#Collaborative Project

1. Project Objective

- Collaborate with investigators to ask critical questions in public health field

2. Phase 1 Plan

- Data source:

     National Health and Nutrition Examination Survey (NHANES) [1999-2000 Survey Data](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DEMO.XPT)

     NHANES Mortality [Follow-up Data](https://ftp.cdc.gov/pub/HEALTH_STATISTICS/NCHS/datalinkage/linked_mortality/NHANES_1999_2000_MORT_2019_PUBLIC.dat)
- Code development:
  Download original Script from [here](https://ftp.cdc.gov/pub/HEALTH_STATISTICS/NCHS/datalinkage/linked_mortality/Stata_ReadInProgramAllSurveys.do). Modify the .do file and upload.
  Execute the following Stata code to merge the survey data with the mortality data, ensuring alignment on the unique sequence numbers:
  ```stata
  //use your own username/project repo instead of the class repo below
  global repo "https://github.com/jhustata/intermediate/raw/main/"
  do ${repo}followup.do
  save followup, replace
  import sasxport5 "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DEMO.XPT", clear
  merge 1:1 seqn using followup
  lookfor follow
  ```
sts graph, fail
save demo_mortality, replace 
import sasxport5 "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/HUQ.XPT", clear 
merge 1:1 seqn using demo_mortality, nogen
sts graph, by(huq010) fail
stcox i.huq010
Documentation for HUQ dataset: https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/HUQ.html


# **Hw7 Analyses**

#7.1 Parameters

Non-parametric

```stata
cls 
//1. data
global repo "https://github.com/jhustata/project/raw/main/"
global nhanes "https://wwwn.cdc.gov/Nchs/Nhanes/"

//2. code
do ${repo}followup.do
save followup, replace 
import sasxport5 "${nhanes}1999-2000/DEMO.XPT", clear
merge 1:1 seqn using followup, nogen
save survey_followup, replace 

//3. parameters
import sasxport5 "${nhanes}1999-2000/HUQ.XPT", clear
tab huq010 
merge 1:1 seqn using survey_followup, nogen keep(matched)
rm followup.dta
rm survey_followup.dta
g years=permth_int/12
stset years, fail(mortstat)
replace huq010=. if huq010==9
label define huq 1 "Excellent" 2 "Very Good" 3 "Good" 4 "Fair" 5 "Poor"
label values huq010 huq 
levelsof huq010, local(numlevels)
local i=1
foreach l of numlist `numlevels' {
    local vallab: value label huq010 
	local catlab: lab `vallab' `l'
	global legend`i' = "`catlab'"
	local i= `i' + 1
}
save week7, replace 
sts graph, ///
    by(huq010) ///
	fail ///
	per(100) ///
	ylab(0(20)80 , ///
	    format(%2.0f) ///
	) ///
	xlab(0(5)20) ///
	tmax(20) ///
	ti("Self-Reported Health and Mortality") ///
	legend( ///
	    order(5 4 3 2 1) ///
		lab(1 "$legend1") ///
		lab(2 "$legend2") ///
		lab(3 "$legend3") ///
		lab(4 "$legend4") ///
		lab(5 "$legend5") ///
		ring(0) pos(11) ///
	)
graph export nonpara.png, replace 
 ```


#7.2 Inferences

```stata
hist ridageyr 
graph export nonpara.png, replace 
//replace ridageyr=ridageyr/10
capture drop s0 
stcox i.huq010 ridageyr riagendr, basesurv(s0)
return list
matrix define mat_adj=r(table)
matrix define mat_adj=mat_adj'
matrix list mat_adj
svmat mat_adj
keep mat_adj*
drop if missing(mat_adj1)
rename (mat_adj1 mat_adj2 mat_adj3 mat_adj4 mat_adj5 mat_adj6 mat_adj7 mat_adj8 mat_adj9)(b se z p ll ul df crit eform)
g x=_n
replace b=log(b)
replace ll=log(ll)
replace ul=log(ul)
twoway (scatter b x if inrange(x,1,5)) || ///
       (rcap ll ul x if inrange(x,1,5), ///
	       yline(0, lcol(lime)) ///
		   ylab( ///
		       -2.08 "0.125" ///
			   -1.39 "0.25" ///
			   -.69 "0.5" ///
			     0 "1"  ///
			   .69 "2" ///
			   1.39 "4" ///
			   2.08 "8" ///
			   2.78 "16") ///
		   legend(off)  ///
		xlab( ///
           1 "$legend1" ///
		   2 "$legend2" ///
		   3 "$legend3" ///
		   4 "$legend4" ///
		   5 "$legend5") ///
	   xti("Self-Reported Health") ///
	   	   ) 
graph export semipara_adj.png, replace 
graph save semipara_adj.gph, replace 
```

#7.3 Updates

```stata
graph combine semipara_unadj.gph semipara_adj.gph, ///
    ycommon ti("Hazard Ratio, 95%CI") 
graph export unadj_adj.png, replace 

//these variable names don't exist in the dataset, this is a mere demo
di "What do you wish to adjust for in this analysis?" _request($varlist)
capture program drop selfassess
program define selfassess
    syntax varlist 
    stcox i.huq010 `varlist'
end 
selfassess $varlist
```

#7.4 Transparency

The “most open” you can ever get in the “Open Science” enterprise is by using a public GitHub repo
Of the topics we’ve discussed, including data, code, parameters, inferences, and updates, “data” is of particular concern if there might be “disclosure risks”
In the Stata II (Intermediate) we’ll assume all data are de-identified and have zero disclosure risk. Perhaps because we’ve de-identified the data or because we are using simulated datasets
But in Stata III (Advanced) we’ll learn how to use private repos for data storage. We’ll consider how to grant limited access by means of temporary “tokens”
Regardless, the parameters of our models represent reduced dimensions of data and have no associated disclosure risks
So we should consider “extracting” parameters from our data and from that point forth being 100% transparent in our workflow


#7.5 Extracting Parameters

Virtually all scientific inferences from quantitive analyses can be made as long as you have the beta coefficients and the variance-covariance matrix following a multivariable regression.
Because these parameters have zero discolure risk, you are encouraged to have them made available to the public in your public GitHub repo
You’d do the public an extra favor if you laid out a generalizable program that allows anyone to add new parameters (i.e., variables and interactions amongst them) to the model with little extra effort
Let’s restore the analytic dataset we’d created. If this dataset has disclosure risks, the we should extract “all” the relevant parameters for statistical inference, make them publically available, and display our findings

```stata
cls 
use week7, clear
```
e(b)
```stata
cls 
use week7, clear
replace riagendr=riagendr-1
stcox i.huq010 ridageyr riagendr, basesurv(s0)
keep s0 _t _t0 _st _d 
save s0, replace 
ereturn list 
matrix beta = e(b)
matrix vcov = e(V)
matrix SV = ( ///
    0, ///
	1, ///
	0, ///
	0, ///
	0, ///
	40, ///
	1 ///
)
matrix SV_ref = ( ///
    0, ///
	1, ///
	0, ///
	0, ///
	0, ///
	60, ///
	1 ///
)
//absolute risk
matrix risk_score = SV * beta'
matrix list risk_score
di exp(risk_score[1,1])
matrix var_prediction = SV * vcov * vcov'
matrix se_prediction = sqrt(var_prediction[1,1])

matrix risk_score_ref = SV_ref * beta'
matrix list risk_score_ref
di exp(risk_score_ref[1,1])
matrix var_prediction_ref = SV_ref * vcov * vcov'
matrix se_prediction_ref = sqrt(var_prediction_ref[1,1])

local hr = exp(risk_score_ref[1,1])/exp(risk_score[1,1])
di `hr'

//di "We conclude that `exp(risk_score[1,1])'"

//
g f0 = (1 - s0) * 100 
g f1_ = f0 * exp(risk_score[1,1])
line f1 _t , ///  
    sort connect(step step) ///
	legend(ring(0)) ///
    ylab(0(5)20) xlab(0(5)20) ///
    yti("") ///
    ti("Scenario, %", pos(11)) ///
    xti("Years") ///
    note("40yo male who self-describes as being in good health" ///
                  ,size(1.5) ///
		)
graph export scenario.png, replace 
```

