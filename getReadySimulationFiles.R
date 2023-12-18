## Everything in this file and any files in the R directory are sourced during `simInit()`;
## all functions and objects are put into the `simList`.
## To use objects, use `sim$xxx` (they are globally available to all modules).
## Functions can be used inside any function that was sourced in this module;
## they are namespaced to the module, just like functions in R packages.
## If exact location is required, functions will be: `sim$.mods$<moduleName>$FunctionName`.
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
  reqdPkgs = list("PredictiveEcology/SpaDES.core@sequentialCaching (>= 2.0.3.9002)", "ggplot2"),
  parameters = bindrows(
    #defineParameter("paramName", "paramClass", value, min, max, "parameter description"),
    defineParameter("gDriveFolder", "character", "1t6032ggUC__jzaJs5H39LW6iFfrqlK_T", NA, NA,
                    "Folder where to find the zipped simulation results"),
    defineParameter("climateScenario", "character", c("CanESM5_SPP370"), NA, NA,
                    "Climate Scenario (as ModelName_SPPXXX) to be used"),
    defineParameter("replicateRun", "character", "run01", NA, NA,
                    "Replicate to be used"),
    defineParameter(".useCache", "logical", TRUE, NA, NA,
                    "Should caching of events or module be used?")
  ),
  inputObjects = bindrows(
    expectsInput(objectName = NA, objectClass = NA, desc = NA, sourceURL = NA)
  ),
  outputObjects = bindrows(
    createsOutput(objectName = "rstCurrentBurnList", objectClass = "list", 
                  desc = paste0("List of fires by year (raster format). These ",
                                "layers are produced by landscape simulations"))
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
                                      P(sim)[["climateScenario"]],
                                      P(sim)[["replicateRun"]],
                                      P(sim)[["gDriveFolder"]])
      
    },
    warning(paste("Undefined event type: \'", current(sim)[1, "eventType", with = FALSE],
                  "\' in module \'", current(sim)[1, "moduleName", with = FALSE], "\'", sep = ""))
  )
  return(invisible(sim))
}

## event functions
#   - keep event functions short and clean, modularize by calling subroutines from section below.

### template initialization
Init <- function(sim) {
  # # ! ----- EDIT BELOW ----- ! #

  # ! ----- STOP EDITING ----- ! #

  return(invisible(sim))
}
