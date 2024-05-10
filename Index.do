<<dd_version: 2>>     
<<dd_include: header.txt>>




# **Collaborative Project**

$\small For$  $\small ongoing$  $\small sharing$  $\small project$

1. **Project Objective**

- Collaborate with investigators to ask critical questions in public health field

2. **Phase 1 Plan**

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