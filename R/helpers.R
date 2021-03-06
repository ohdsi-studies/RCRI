getAnalyses <- function(settings, outputFolder,cdmDatabaseName){
  
  cohorts <- system.file("settings", 'CohortsToCreate.csv', package = "RCRI")
  cohorts <- read.csv(cohorts)
  
  if(is.null(settings)){
    cohortsSettings <- cohorts[cohorts$type == 'target', c('cohortId','name')]
    cohortsSettings$outcomeId <- cohorts$cohortId[cohorts$type == 'outcome']
    cohortsSettings$outcomeName <- cohorts$name[cohorts$type == 'outcome']
    colnames(cohortsSettings) <- c('targetId', 'targetName', 'outcomeId', 'outcomeName')
    
    settingLoc <- system.file("settings", package = "RCRI")
    modelSettings <- data.frame(model = dir(settingLoc, pattern = '_model.csv'))
    modelSettings$modelSettingsId <- 1:nrow(modelSettings)
    analysesSettings <- merge(cohortsSettings, modelSettings)
  } else{
    
    #use data.frame(tId, oId and model) to create...
    settings <- settings[, c('tId', 'oId', 'model')]
    colnames(settings) <- c('targetId','outcomeId','model')
    
    settings <- merge(settings, cohorts[,c('cohortId','name')], by.x='targetId', by.y='cohortId')
    colnames(settings)[colnames(settings) == 'name'] <- 'targetName'
    settings <- merge(settings, cohorts[,c('cohortId','name')], by.x='outcomeId', by.y='cohortId')
    colnames(settings)[colnames(settings) == 'name'] <- 'outcomeName'
    settings <- settings[,c('targetId', 'targetName', 'outcomeId', 'outcomeName','model')]
    settings$modelSettingsId <- as.double(as.factor(settings$model))
    analysesSettings <- settings
    
  }
  analysesSettings$analysisId <- paste0('Analysis_', 1:nrow(analysesSettings))
  
  # adding extras for shiny
  analysesSettings$cohortName <- analysesSettings$targetName
  analysesSettings$devDatabase <- 'NA'
  analysesSettings$valDatabase <- cdmDatabaseName
  analysesSettings$modelSettingName <- analysesSettings$model
  analysesSettings$populationSettingId <- 1
  analysesSettings$covariateSettingId <- analysesSettings$modelSettingsId
  
  if(!dir.exists(file.path(outputFolder,cdmDatabaseName))){
    dir.create(file.path(outputFolder,cdmDatabaseName))
  }
  write.csv(analysesSettings, file.path(outputFolder,cdmDatabaseName, 'settings.csv'))
  return(analysesSettings)
}

getData <- function(connectionDetails,
                    cdmDatabaseSchema,
                    cdmDatabaseName,
                    cohortDatabaseSchema,
                    cohortTable,
                    cohortId,
                    outcomeId,
                    oracleTempSchema,
                    model,
                    standardCovariates,
                    firstExposureOnly,
                    sampleSize,
                    cdmVersion){
  
  
  pathToCustom <- system.file("settings", model, package = "RCRI")
  varsToCreate <- utils::read.csv(pathToCustom)

  covSets <- list()
  if(!is.null(standardCovariates)){
    extra <- 1
  } else{
    extra <- 0
    if(nrow(varsToCreate[varsToCreate$type == 'standardCovariate',])!=0){
      warning('Standard covariates used but not set')
    }
  }
  length(covSets) <- nrow(varsToCreate)+extra 
  
  if(!is.null(standardCovariates)){
    covSets[[1]] <- standardCovariates
  }
  
  cohortVarsToCreate <- varsToCreate[varsToCreate$type == 'cohortCovariate',]
  if(nrow(cohortVarsToCreate)>0){
  for(i in 1:nrow(cohortVarsToCreate)){
    covSets[[extra+i]] <- createCohortCovariateSettings(covariateName = as.character(cohortVarsToCreate$cohortName[i]),
                                                        analysisId = cohortVarsToCreate$analysisId[i],
                                                        covariateId = cohortVarsToCreate$cohortId[i]*1000+cohortVarsToCreate$analysisId[i],
                                                      cohortDatabaseSchema = cohortDatabaseSchema,
                                                      cohortTable = cohortTable,
                                                      cohortId = cohortVarsToCreate$atlasId[i],
                                                      startDay=cohortVarsToCreate$startDay[i], 
                                                      endDay=cohortVarsToCreate$endDay[i],
                                                      count= ifelse(is.null(cohortVarsToCreate$count), F, cohortVarsToCreate$count[i]), 
                                                      ageInteraction = ifelse(is.null(cohortVarsToCreate$ageInteraction), F, cohortVarsToCreate$ageInteraction[i]),
                                                      lnAgeInteraction = ifelse(is.null(cohortVarsToCreate$lnAgeInteraction), F, cohortVarsToCreate$lnAgeInteraction[i])
                                                      
    )
  }
  }
  
  # add measurement covariates...
  measurementVarsToCreate <- varsToCreate[varsToCreate$type == 'measurementCovariate',]
  if(nrow(measurementVarsToCreate)>0){
  for(i in 1:nrow(measurementVarsToCreate)){
    pathToConcept <- system.file("settings", paste0(measurementVarsToCreate$covariateName[i],'_concepts.csv'), package = "RCRI")
    conceptSet <- read.csv(pathToConcept)$x
    pathToScaleMap <- system.file("settings", paste0(measurementVarsToCreate$covariateName[i],'_scaleMap.rds'), package = "RCRI")
    scaleMap <- readRDS(pathToScaleMap)
    
    covSets[[extra+nrow(cohortVarsToCreate)+i]] <- createMeasurementCovariateSettings(covariateName = measurementVarsToCreate$covariateName[i], 
                                                                                      analysisId = measurementVarsToCreate$analysisId[i],
                                                                                      conceptSet = conceptSet,
                                                                                      startDay = measurementVarsToCreate$startDay[i], 
                                                                                      endDay = measurementVarsToCreate$endDay[i], 
                                                                                      scaleMap = scaleMap, 
                                                                                      aggregateMethod = measurementVarsToCreate$aggregateMethod[i],
                                                                                      imputationValue = measurementVarsToCreate$imputationValue[i],
                                                                                      covariateId = measurementVarsToCreate$covariateId[i],
                                                                                      ageInteraction = ifelse(is.null(measurementVarsToCreate$ageInteraction), F, measurementVarsToCreate$ageInteraction[i]),
                                                                                      
                                                                                      lnAgeInteraction = ifelse(is.null(measurementVarsToCreate$lnAgeInteraction), F, measurementVarsToCreate$lnAgeInteraction[i]),
                                                                                      lnValue = ifelse(is.null(measurementVarsToCreate$lnValue), F, measurementVarsToCreate$lnValue[i])
                                                                                      
                                                                                      )
  }
  }
  
  # add age covariates...
  ageVarsToCreate <- varsToCreate[varsToCreate$type == 'ageCovariate',]
  if(nrow(ageVarsToCreate)>0){
    for(i in 1:nrow(ageVarsToCreate)){
      
      pathToAgeMap <- system.file("settings", paste0(paste0(gsub(' ', '_',gsub('\\)','_',gsub('\\(','_',ageVarsToCreate$covariateName[i])))),'_ageMap.rds'), package = "RCRI")
      ageMap <- readRDS(pathToAgeMap)
      
      covSets[[extra+nrow(cohortVarsToCreate) +nrow(measurementVarsToCreate) +i]] <- createAgeCovariateSettings(covariateName = ageVarsToCreate$covariateName[i], 
                                                                                        analysisId = ageVarsToCreate$analysisId[i],
                                                                                        ageMap = ageMap, 
                                                                                        covariateId = ageVarsToCreate$covariateId[i]
                                                                                        
      )
    }
  }
  
  
  # add measurement cohort covariates...
  measurementCohortVarsToCreate <- varsToCreate[grep('measurementCohortCovariate',varsToCreate$type),]
  if(nrow(measurementCohortVarsToCreate)>0){
    for(i in 1:nrow(measurementCohortVarsToCreate)){
      pathToConcept <- system.file("settings", paste0(measurementCohortVarsToCreate$covariateName[i],'_concepts.csv'), package = "RCRI")
      conceptSet <- read.csv(pathToConcept)$x
      pathToScaleMap <- system.file("settings", paste0(measurementCohortVarsToCreate$covariateName[i],'_scaleMap.rds'), package = "RCRI")
      scaleMap <- readRDS(pathToScaleMap)
      
      covSets[[extra+nrow(cohortVarsToCreate) + nrow(measurementVarsToCreate) + nrow(ageVarsToCreate) +i]] <- createMeasurementCohortCovariateSettings(covariateName = measurementCohortVarsToCreate$covariateName[i], 
                                                                                        analysisId = measurementCohortVarsToCreate$analysisId[i],
                                                                                        cohortDatabaseSchema = cohortDatabaseSchema,
                                                                                        cohortTable = cohortTable,
                                                                                        cohortId = measurementCohortVarsToCreate$atlasId[i],
                                                                                        type = ifelse(length(grep('_in', measurementCohortVarsToCreate$type[i]))>0, 'in', 'out'),
                                                                                        conceptSet = conceptSet,
                                                                                        startDay = measurementCohortVarsToCreate$startDay[i], 
                                                                                        endDay = measurementCohortVarsToCreate$endDay[i], 
                                                                                        scaleMap = scaleMap, 
                                                                                        aggregateMethod = measurementCohortVarsToCreate$aggregateMethod[i],
                                                                                        imputationValue = measurementCohortVarsToCreate$imputationValue[i],
                                                                                        covariateId = measurementCohortVarsToCreate$covariateId[i],
                                                                                        ageInteraction = ifelse(is.null(measurementCohortVarsToCreate$ageInteraction), F, measurementCohortVarsToCreate$ageInteraction[i]),
                                                                                        
                                                                                        lnAgeInteraction = ifelse(is.null(measurementCohortVarsToCreate$lnAgeInteraction), F, measurementCohortVarsToCreate$lnAgeInteraction[i]),
                                                                                        lnValue = ifelse(is.null(measurementCohortVarsToCreate$lnValue), F, measurementCohortVarsToCreate$lnValue[i])
                                                                                        
      )
    }
  }
  
  
  result <- PatientLevelPrediction::getPlpData(connectionDetails = connectionDetails,
                                     cdmDatabaseSchema = cdmDatabaseSchema,
                                     oracleTempSchema = oracleTempSchema, 
                                     cohortId = cohortId, 
                                     outcomeIds = outcomeId, 
                                     cohortDatabaseSchema = cohortDatabaseSchema, 
                                     outcomeDatabaseSchema = cohortDatabaseSchema, 
                                     cohortTable = cohortTable, 
                                     outcomeTable = cohortTable, 
                                     cdmVersion = cdmVersion, 
                                     firstExposureOnly = firstExposureOnly, 
                                     sampleSize =  sampleSize, 
                                     covariateSettings = covSets)
  
  return(result)
  
}


getModel <- function(model = 'SimpleModel'){
  
  pathToCustom <- system.file("settings", model, package = "RCRI")
  coefficients <- utils::read.csv(pathToCustom)
  coefficients <- coefficients[,colnames(coefficients)%in%c('covariateId','points')]
 
   return(coefficients)
}

predictExisting <- function(model){
  
  coefficients <- getModel(model)
  mapping <- getMap(gsub('_model.csv','',model))
  
  predict <- function(plpData, population){
    
    plpData$covariateData$coefficients <- coefficients
    on.exit(plpData$covariateData$coefficients <- NULL, add = TRUE)
    
    prediction <- plpData$covariateData$covariates %>% 
      dplyr::inner_join(plpData$covariateData$coefficients, by= 'covariateId') %>% 
      dplyr::mutate(values = covariateValue*points) %>%
      dplyr::group_by(rowId) %>%
      dplyr::summarise(value = sum(values, na.rm = TRUE)) %>%
      dplyr::select(rowId, value) %>% dplyr::collect() 
    
    prediction <- merge(population, prediction, by ="rowId", all.x = TRUE)
    prediction$value[is.na(prediction$value)] <- 0
    
    # add any final mapping here (e.g., add intercept and mapping)
    prediction$value <- mapping(prediction$value)
    
    # make sure every value is less than 1 for the evaluatation
    scaleVal <- max(prediction$value)
    if(scaleVal>1){
      prediction$value <- prediction$value/scaleVal
    }
    
    attr(prediction, "metaData") <- list(predictionType = 'binary', scale = scaleVal)
    
    return(prediction)
  }
  
  return(predict)
}




