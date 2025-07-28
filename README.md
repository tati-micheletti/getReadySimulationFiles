---
title: "getReadySimulationFiles SpaDES Module"
author: "Tati Micheletti"
output:
  github_document:
    toc: true
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# `getReadySimulationFiles` SpaDES Module

## Description

This module helps getting previously simulated files for a given climate scenario and replicate (run) based on a googledrive table. It is designed to import landscape simulation outputs (specifically annual burn data) into a new `SpaDES` simulation, avoiding the need to re-run computationally intensive models.

**Keywords:** `simulations`, `pre-run`, `download`

## Dependencies

This module requires the following R packages:
*   `SpaDES.core (>= 2.1.5.9003)`
*   `PredictiveEcology/reproducible`
*   `googledrive`
*   `PredictiveEcology/Require`

## Events

The module's functionality is divided into two main events:

1.  **`init`**:
    *   Runs once at the start of the simulation.
    *   Connects to Google Drive using parameters provided by the user (`gDriveFolder`, `climateScenario`, `replicateRun`).
    *   Downloads and prepares the simulation data for the specified time range (`lastHistoricalFireYearKnown` to `lastYearSimulations`).
    *   Processes the downloaded files into `rstCurrentBurnList`, a list where each element is a `SpatRaster` of the burned area for a specific year.
    *   Schedules the `getRstCurrBurn` event to run at the simulation's start time.

2.  **`getRstCurrBurn`**:
    *   Runs at the start of the simulation and then repeats at a frequency defined by the `runInterval` parameter.
    *   For the current simulation year (`time(sim)`), it extracts the corresponding annual burn raster from `rstCurrentBurnList`.
    *   Makes this raster available to other modules as `sim$rstCurrentBurn`.
    *   If no burn data is available for the current year, it issues a warning.
