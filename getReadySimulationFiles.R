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
  reqdPkgs = list("PredictiveEcology/SpaDES.core@sequentialCaching (>= 2.0.3.9002)"),
  parameters = bindrows(
    #defineParameter("paramName", "paramClass", value, min, max, "parameter description"),
    defineParameter("gDriveFolder", "character", "1t6032ggUC__jzaJs5H39LW6iFfrqlK_T", NA, NA,
                    "Google drive folder (as id) where to find the zipped simulation results"),
    defineParameter("climateScenario", "character", c("CanESM5_SPP370"), NA, NA,
                    "Climate Scenario (as ModelName_SPPXXX) to be used"),
    defineParameter("replicateRun", "character", "run01", NA, NA,
                    "Replicate to be used"),
    defineParameter("usePrepInputs", "logical", FALSE, NA, NA,
                    paste0("Should reproducible::prepInputs be used for downloading of large",
                           " existing simulation results? Note that there are known issues ",
                           "in using googledrive with very large files.")),
    defineParameter(".useCache", "logical", TRUE, NA, NA,
                    "Should caching of events or module be used?")
  ),
  inputObjects = bindrows(
    expectsInput(objectName = NA, objectClass = NA, desc = NA, sourceURL = NA)
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
      sim$rstCurrentBurnList <- Cache(getSimulationDataFromGDrive,
                                      climateScenario = P(sim)[["climateScenario"]],
                                      replicateRun = P(sim)[["replicateRun"]],
                                      gDriveFolder = P(sim)[["gDriveFolder"]], 
                                      destinationPath = dataPath(sim), 
                                      usePrepInputs = P(sim)$usePrepInputs)
      
      sim <- scheduleEvent(sim, time(sim), "getReadySimulationFiles", "getRstCurrBurn")
    },
    getRstCurrBurn = {
      ### check for more detailed object dependencies:
      ### (use `checkObject` or similar)
      
      # do stuff for this event
      sim$rstCurrentBurn <- sim$rstCurrentBurnList[[paste0("Year", time(sim))]]
      
      sim <- scheduleEvent(sim, time(sim) + 1, "getReadySimulationFiles", "getRstCurrBurn")
      
    },
    warning(paste("Undefined event type: \'", current(sim)[1, "eventType", with = FALSE],
                  "\' in module \'", current(sim)[1, "moduleName", with = FALSE], "\'", sep = ""))
  )
  return(invisible(sim))
}

