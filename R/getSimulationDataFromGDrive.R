getSimulationDataFromGDrive <- function(climateScenario,
                                        replicateRun,
                                        gDriveFolder, 
                                        destinationPath,
                                        targetArchive = NULL,
                                        targetFile = NULL,
                                        usePrepInputs = FALSE){
  
  # 1. Get all files from GDrive
  allFls <- googledrive::drive_ls(path = as_id(gDriveFolder))
  # 2. Find the file of interest
  # targetArchiveChecked <- 
  # targetFileChecked <- 
  # targetArchiveID <- 
  targetArchive <- if (is.null(targetArchive)) targetArchiveChecked else targetArchive
  targetFile <- if (is.null(targetFile)) targetFileChecked else targetFile
  browser()
  if (!identical(targetArchive, targetArchiveChecked)) stop(paste0("targetArchive provided (", 
                                                                   targetArchive,
                                                                   ") and file found online (",
                                                                   targetArchiveChecked,") do not ",
                                                                   "match. Please check: 1. if file ",
                                                                   "desired is in the passed folder; ",
                                                                   "2. if filename provided is correct"))
  if (!identical(targetFile, targetFileChecked)) stop(paste0("targetFile provided (", 
                                                             targetFile,
                                                                   ") and file found in archive (",
                                                             targetFileChecked,") do not ",
                                                                   "match. Please check: 1. if file ",
                                                                   "desired is in the passed archive; ",
                                                                   "2. if filename provided is correct"))
  if (usePrepInputs){
    warning(paste0("usePrepInputs = TRUE. The files to be downloaded are",
                   "potentially very large. By unstable internet, prepInputs ",
                   "might fail (known problem with the combination googledrive,",
                   " large file and unstable internet). Alternatively, please",
                   "pass usePrepInputs = FALSE to use a system call of `gdown`",
                   " which has had more success with such download."), 
            immediate. = TRUE)
    fl <- reproducible::prepInputs(url = as_id(targetArchiveID),
                                   archive = targetArchive,
                                   targetFile = targetFile, 
                                   destinationPath = destinationPath)
  } else {

    # Because the files are always potentially VERY large, use gdown directly.
    # Make sure to unzip it
    # Check for the specific files needed
    # NEED TO BE SAVED IN: Paths[['outputPath']]
  }
    archiveExists <- if (exists(file.path(destinationPath, targetArchive))) TRUE else FALSE
    fileExists <- if (exists(file.path(destinationPath, targetFile))) TRUE else FALSE
    if (all(archiveExists, fileExists)) return(file.path(destinationPath, targetFile)) else
      if (all(archiveExists, !fileExists)) 
        stop(paste0("targetArchive was downloaded but targetFile",
                    "does not. Please make sure archive was",
                    "correctly unzipped and that the targetFile ",
                    "was in the archive.")) else
          if (all(!archiveExists, fileExists)){
            warning(paste0("targetArchive was not downloaded but targetFile",
                                                       "exists. Please make sure this file",
                           file.path(destinationPath, targetFile), "is the one desired"), 
                    immediate. = TRUE)
            return(file.path(destinationPath, targetFile))
  }
}