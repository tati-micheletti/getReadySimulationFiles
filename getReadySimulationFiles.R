defineModule(sim, list(
  name = "getReadySimulationFiles",
  description = paste0("This module helps getting previously simulated files for a given climate",
                       "scenario and replicate (run) based on a googledrive table"),
  keywords = c("simulations", "pre-run", "download"),
  authors = structure(list(list(given = "Tati", family = "Micheletti", role = c("aut", "cre"), 
                                email = "tati.micheletti@gmail.com", comment = NULL)), 
                      class = "person"),
  childModules = character(0),
  version = list(getReadySimulationFiles = "0.0.0.9000"),
  timeframe = as.POSIXlt(c(NA, NA)),
  timeunit = "year",
  citation = list("citation.bib"),
  documentation = list("NEWS.md", "README.md", "getReadySimulationFiles.Rmd"),
  reqdPkgs = list("SpaDES.core (>= 2.1.5.9003)", "PredictiveEcology/reproducible",
                  "googledrive", "PredictiveEcology/Require"),
  parameters = bindrows(
    #defineParameter("paramName", "paramClass", value, min, max, "parameter description"),
    defineParameter("gDriveFolder", "character", "1lqIjwQQ8CU6l5GJezC9tVgs0Uz0dv-FD", NA, NA,
                    "Google drive folder (as id) where to find the zipped simulation results"),
    defineParameter("climateScenario", "character", c("CanESM5_SSP370"), NA, NA,
                    "Climate Scenario (as ModelName_SSPXXX) to be used"),
    defineParameter("replicateRun", "character", "run01", NA, NA,
                    "Replicate to be used"),
    defineParameter("runInterval", "numeric", 1, NA, NA,
                    paste0("Should the module be run every decade? This speeds up module testing as ",
                           "testing if the events need to be run at every time is time-consuming. If ",
                           "the user knows the disturbances happen every X years, X can be passed here.")),
    defineParameter(".runName", "character", "run1", NA, NA,
                    paste0("If you would like your simulations' results to have an appended name ",
                           "(i.e., replicate number, study area, etc) you can use this parameter")),
    defineParameter("lastHistoricalFireYearKnown", "numeric", 2017, NA, NA,
                    paste0("The last historical fire year known that will be passed to the caribou",
                           " module. After this year, rstCurrentBurn need to be available.")),
    defineParameter("lastYearSimulations", "numeric", end(sim), NA, NA,
                    "When is the last year of simulations?"),
    defineParameter(".useCache", "logical", TRUE, NA, NA,
                    "Should caching of events or module be used?")
  ),
  inputObjects = bindrows(
    expectsInput(objectName = "studyArea", objectClass = "SpatVector",
                 desc = "Study area for the prediction. Currently only available for NWT",
                 sourceURL = "https://drive.google.com/open?id=1P4grDYDffVyVXvMjM-RwzpuH1deZuvL3"),
    expectsInput(objectName = "rasterToMatch", objectClass = "SpatRaster",
                 desc = "All spatial outputs will be reprojected and resampled to it",
                 sourceURL = "https://drive.google.com/open?id=1P4grDYDffVyVXvMjM-RwzpuH1deZuvL3")
  ),
  outputObjects = bindrows(
    createsOutput(objectName = "rstCurrentBurnList", objectClass = "list", 
                  desc = paste0("List of fires by year (SpatRaster format, named list as YearXXXX). These ",
                                "layers are produced by landscape simulations")),
    createsOutput(objectName = "rstCurrentBurn", objectClass = "SpatRaster", 
                  desc = paste0("Raster for time(sim) indicating burned area (in current year).",
                                "These compose the list rstCurrentBurnList"))
  )
))

## event types
#   - type `init` is required for initialization

doEvent.getReadySimulationFiles = function(sim, eventTime, eventType) {
  switch(
    eventType,
    init = {
      ### check for more detailed object dependencies:
      ### (use `checkObject` or similar)

      # do stuff for this event
      allBurnFiles <- getSimulationDataFromGDrive(
        climateScenario = P(sim)[["climateScenario"]],
        replicateRun = P(sim)[["replicateRun"]],
        gDriveFolder = P(sim)[["gDriveFolder"]],
        destinationPath = Paths[["outputPath"]],
        startYear = P(sim)$lastHistoricalFireYearKnown+1,
        endYear = P(sim)$lastYearSimulations)

      sim$rstCurrentBurnList <- rstCurrentBurnListGenerator(pathInputs = Paths[["outputPath"]],
                                                            studyArea = sim$studyArea, 
                                                            rasterToMatch = sim$rasterToMatch,
                                                            runName = P(sim)$.runName)

      sim <- scheduleEvent(sim, time(sim), "getReadySimulationFiles", "getRstCurrBurn", eventPriority = 3)
    },
    getRstCurrBurn = {
      ### check for more detailed object dependencies:
      ### (use `checkObject` or similar)
      
      # do stuff for this event
      if (!paste0("Year", time(sim)) %in% names(sim$rstCurrentBurnList)){
        warning(paste0("Year ", time(sim), " is not available in sim$rstCurrentBurnList.",
                       ifelse(P(sim)$lastHistoricalFireYearKnown > time(sim), 
                              paste0(" However, last Historical Fire Year Known is ",P(sim)$lastHistoricalFireYearKnown, 
                              " so year ", time(sim)," might still become available for future modules. "),
                              paste0(" Last Historical Fire Year Known is ", P(sim)$lastHistoricalFireYearKnown, 
                                     " so this year might NOT become available for future modules. Please make sure this is ok."))), 
                immediate. = TRUE)
      } else {
        sim$rstCurrentBurn <- sim$rstCurrentBurnList[[paste0("Year", time(sim))]]
      }
      
      sim <- scheduleEvent(sim, time(sim) + P(sim)$runInterval, "getReadySimulationFiles", "getRstCurrBurn")
      
    },
    warning(paste("Undefined event type: \'", current(sim)[1, "eventType", with = FALSE],
                  "\' in module \'", current(sim)[1, "moduleName", with = FALSE], "\'", sep = ""))
  )
  return(invisible(sim))
}

