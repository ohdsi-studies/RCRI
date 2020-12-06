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

# Add the shareable database name
cdmDatabaseName <- 'friendly_name'

# Add a database with read/write access as this is where the cohorts will be generated
cohortDatabaseSchema <- 'work database schema'

oracleTempSchema <- NULL

# table name where the cohorts will be generated
cohortTable <- 'RCRICohort'

# TAR settings
sampleSize <- NULL
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


#=======================

RCRI::execute(connectionDetails = connectionDetails,
                                    cdmDatabaseSchema = cdmDatabaseSchema,
                                    cdmDatabaseName = cdmDatabaseName,
                                    cohortDatabaseSchema = cohortDatabaseSchema,
                                    cohortTable = cohortTable,
              setting = data.frame(tId = rep(c(1373),2), 
                                   oId = c(rep(1339,1),rep(1365,1)), 
                                   model = c('rcri_with_creatinine_model.csv',
                                             'rcri_with_creatinine_plus_renal_model.csv')
              ),
                                    sampleSize = sampleSize,
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
        setting = data.frame(tId = rep(c(1373),2), 
                             oId = c(rep(1339,1),rep(1365,1)), 
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
        setting = data.frame(tId = rep(c(1373),2), 
                             oId = c(rep(1339,1),rep(1365,1)), 
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
