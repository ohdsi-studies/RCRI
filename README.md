RCRI model validation study
=============

<img src="https://img.shields.io/badge/Study%20Status-Results%20Available-yellow.svg" alt="Study Status: Results Available"> 

- Analytics use case(s): **Patient-Level Prediction**
- Study type: **Clinical Application**
- Tags: **OHDSI 2020 Study-a-thon**
- Study lead: **Jenna Reps, Peter Rijnbeek**
- Study lead forums tag: **[jreps](https://forums.ohdsi.org/u/jreps), [Rijnbeek](https://forums.ohdsi.org/u/Rijnbeek)**
- Study start date: **2020-10-01**
- Study end date: **2020-11-01**
- Protocol: **Coming Soon**
- Publications: **Coming Soon**
- Results explorer: **[Click here](http://data.ohdsi.org/RCRIvalidation)**

The objective of this study is to preform a large-scale external validation of the RCRI prognostic model across the OHDSI network using OMOP CDM data

Instructions To Install and Run Package From Github
===================

- Make sure you have PatientLevelPrediction installed (this requires having Java installed and the OHDSI FeatureExtraction R package installed):

```r
  # get the latest PatientLevelPrediction
  install.packages("devtools")
  devtools::install_github("OHDSI/PatientLevelPrediction", ref = 'development')
  # check the package
  PatientLevelPrediction::checkPlpInstallation()
```

- Then install the study package:
```r
  # install the network package
  devtools::install_github("ohdsi-studies/RCRI")
```

- Execute the study by running the code in (extras/CodeToRun.R) but make sure to edit the settings:
```r
library(RCRI)
# USER INPUTS
#=======================

# The folder where the study intermediate and result files will be written:
outputFolder <- "./RCRIResults"

# Details for connecting to the server:
dbms <- "you dbms"
user <- 'your username'
pw <- 'your password'
server <- 'your server'
port <- 'your port'

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# Add the database containing the OMOP CDM data
cdmDatabaseSchema <- 'cdm database schema'
cdmDatabaseName <- 'A friendly name for the database name'
# Add a database with read/write access as this is where the cohorts will be generated
cohortDatabaseSchema <- 'work database schema'

oracleTempSchema <- NULL

# table name where the cohorts will be generated
cohortTable <- 'RCRICohort'

# if you have big data you can pick a random sample 
# for speed (doesn't really speed much up validaition)
# so recommend keeping as NULL (no sample)
sampleSize <- NULL

# TAR settings 
# ========= Recommended to not edit this =========
riskWindowStart <- 1
startAnchor <- 'cohort start'
riskWindowEnd <- 30
endAnchor <- 'cohort start'
firstExposureOnly <- F
removeSubjectsWithPriorOutcome <- T
priorOutcomeLookback <- 99999
requireTimeAtRisk <- F
minTimeAtRisk <- 1
includeAllOutcomes <- T
# ========= Recommended to not edit this =========

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cdmDatabaseName = cdmDatabaseName,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        setting = data.frame(tId = c(1455,1373), 
                             oId = rep(1456,2), 
                             model = c('rcri_with_creatinine_model.csv',
                                       'rcri_with_creatinine_plus_renal_model.csv')
        ),
        sampleSize = sampleSize, 
        recalibrate = F,
        riskWindowStart = riskWindowStart,
        startAnchor = startAnchor,
        riskWindowEnd = riskWindowEnd,
        endAnchor = endAnchor,
        firstExposureOnly = firstExposureOnly,
        removeSubjectsWithPriorOutcome = removeSubjectsWithPriorOutcome,
        priorOutcomeLookback = priorOutcomeLookback,
        requireTimeAtRisk = requireTimeAtRisk,
        minTimeAtRisk = minTimeAtRisk,
        includeAllOutcomes = includeAllOutcomes,
        outputFolder = outputFolder,
        createCohorts = T,
        runAnalyses = T,
        viewShiny = F,
        packageResults = T, 
        minCellCount= 5,
        verbosity = "INFO",
        cdmVersion = 5)

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cdmDatabaseName = paste0(cdmDatabaseName, '_recalibrate'),
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        setting = data.frame(tId = c(1455,1373), 
                             oId = rep(1456,2), 
                             model = c('rcri_with_creatinine_model.csv',
                                       'rcri_with_creatinine_plus_renal_model.csv')
        ),
        sampleSize = sampleSize, 
        recalibrate = T,
        riskWindowStart = riskWindowStart,
        startAnchor = startAnchor,
        riskWindowEnd = riskWindowEnd,
        endAnchor = endAnchor,
        firstExposureOnly = firstExposureOnly,
        removeSubjectsWithPriorOutcome = removeSubjectsWithPriorOutcome,
        priorOutcomeLookback = priorOutcomeLookback,
        requireTimeAtRisk = requireTimeAtRisk,
        minTimeAtRisk = minTimeAtRisk,
        includeAllOutcomes = includeAllOutcomes,
        outputFolder = outputFolder,
        createCohorts = F,
        runAnalyses = T,
        viewShiny = F,
        packageResults = T, 
        minCellCount= 5,
        verbosity = "INFO",
        cdmVersion = 5)

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cdmDatabaseName = paste0(cdmDatabaseName, '_recalibrateIntercept'),
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        setting = data.frame(tId = c(1455,1373), 
                             oId = rep(1456,2), 
                             model = c('rcri_with_creatinine_model.csv',
                                       'rcri_with_creatinine_plus_renal_model.csv')
        ),
        sampleSize = sampleSize, 
        recalibrateIntercept = T,
        riskWindowStart = riskWindowStart,
        startAnchor = startAnchor,
        riskWindowEnd = riskWindowEnd,
        endAnchor = endAnchor,
        firstExposureOnly = firstExposureOnly,
        removeSubjectsWithPriorOutcome = removeSubjectsWithPriorOutcome,
        priorOutcomeLookback = priorOutcomeLookback,
        requireTimeAtRisk = requireTimeAtRisk,
        minTimeAtRisk = minTimeAtRisk,
        includeAllOutcomes = includeAllOutcomes,
        outputFolder = outputFolder,
        createCohorts = F,
        runAnalyses = T,
        viewShiny = F, 
        packageResults = T, 
        minCellCount= 5,
        verbosity = "INFO",
        cdmVersion = 5)
```

# Output
After running the code go to the location you specified as outputFolder. Inside this location you should see three folders starting with the value you specified as cdmDatabaseName.  For example if I set cdmDatabaseName = 'testData' then I would see: 'testData', 'testData_recalibrate' and 'teatData_recalibrate' folders. In addition there should be three zipped files for these three folders. Continuing the example, then I would see: 'testData.zip', 'testData_recalibrate.zip' and 'teatData_recalibrate.zip' files.  These are the results to be shared.  We recommend that you inspect the files before sending to make sure you are happy.  They will contain various csv files that can be opened and inspected.result 



# Development status
Under development.

