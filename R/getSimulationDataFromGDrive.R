getSimulationDataFromGDrive <- function(climateScenario,
                                        replicateRun,
                                        gDriveFolder,
                                        destinationPath,
                                        targetArchive = NULL,
                                        startYear,
                                        endYear,
                                        targetFile = NULL,
                                        usePrepInputs = FALSE){
  # 1. Get all files from GDrive
  allFls <- data.table(googledrive::drive_ls(path = googledrive::as_id(gDriveFolder)))
  # 2. Find the Climate folder of interest
  targetFolderChecked <- allFls[grep(pattern = climateScenario, x = allFls$name), name]
  targetFolderID <- allFls[grep(pattern = climateScenario, x = allFls$name), id]
  # 3. Now check the run of interest
  allFlsClim <- data.table(googledrive::drive_ls(path = googledrive::as_id(targetFolderID)))
  # 2. Find the Climate folder of interest
  targetFolderCheckedClim <- allFlsClim[grep(pattern = replicateRun, x = allFlsClim$name), name]
  targetFolderIDClim <- allFlsClim[grep(pattern = replicateRun, x = allFlsClim$name), id]
  # List all files and download all files in folder and place in destinationPath
  allFlsList <- data.table(googledrive::drive_ls(path = googledrive::as_id(targetFolderIDClim)))
  allFlsNms <- allFlsList$name
  allYsDesired <- startYear:endYear
  rowsToKeep <- grepl(pattern = paste(allYsDesired, collapse = "|"), x = allFlsNms)
  allFlsList <- allFlsList[rowsToKeep,]
  allFilsOk <- rbindlist(lapply(1:NROW(allFlsList), function(Row){
    destFile <- file.path(destinationPath, allFlsList[Row, name])
    fileExists <- file.exists(destFile)
    if (!fileExists){
      drive_download(file = googledrive::as_id(allFlsList[Row, id]), path = destFile)
    }
    return(data.table(fileName = allFlsList[Row, name],
                      fileID = allFlsList[Row, id],
                      targetFile = destFile,
                      status = if (fileExists) "EXISTING" else "DOWNLOADED"))
    }))
  message(paste0("All files for ", climateScenario, " replicate ", 
                 replicateRun," downloaded"))
  return(allFilsOk)
}






# Maybe get to this when I have time... Need to move on,
# so downloading all files manually and passing them.
# This is for huge files. Version above is specifically for rstCurrBurn

# getSimulationDataFromGDrive <- function(climateScenario,
#                                         replicateRun,
#                                         gDriveFolder, 
#                                         destinationPath,
#                                         targetArchive = NULL,
#                                         targetFile = NULL,
#                                         usePrepInputs = FALSE){
#   
#   patt <- paste0(climateScenario, "_", replicateRun)
#   # 1. Get all files from GDrive
#   allFls <- data.table(googledrive::drive_ls(path = googledrive::as_id(gDriveFolder)))
#   # 2. Find the file of interest
#   targetArchiveChecked <- allFls[grep(pattern = patt, x = allFls$name), name]
#   targetArchiveID <- allFls[grep(pattern = patt, x = allFls$name), id]
#   targetArchive <- if (is.null(targetArchive)) targetArchiveChecked else targetArchive
#   if (!identical(targetArchive, targetArchiveChecked)) stop(paste0("targetArchive provided (", 
#                                                                    targetArchive,
#                                                                    ") and file found online (",
#                                                                    targetArchiveChecked,") do not ",
#                                                                    "match. Please check: 1. if file ",
#                                                                    "desired is in the passed folder; ",
#                                                                    "2. if filename provided is correct"))
#   # if ()
#   # Check if file exists anywhere 
#   # 1. Destination folder
#   # file.exists()
#   # 2. Options destination path if not the same
#   
#   if (usePrepInputs){
#     warning(paste0("usePrepInputs = TRUE. The files to be downloaded are",
#                    "potentially very large. By unstable internet, prepInputs ",
#                    "might fail (known problem with the combination googledrive,",
#                    " large file and unstable internet). Alternatively, please",
#                    "pass usePrepInputs = FALSE to use a system call of `gdown`",
#                    " which has had more success with such download."), 
#             immediate. = TRUE)
#     reproducible::preProcess(url = googledrive::as_id(targetArchiveID),
#                                    archive = targetArchive,
#                                    destinationPath = destinationPath)
#     if (file.exists(file.path(destinationPath, targetArchiveChecked)))
#       message(paste0("File", targetArchiveChecked, "sucessfully downloaded"))
#     return(destinationPath)
#     # targetFile <- if (is.null(targetFile)) targetFileChecked else targetFile
#     # if (!identical(targetFile, targetFileChecked)) stop(paste0("targetFile provided (", 
#     #                                                            targetFile,
#     #                                                            ") and file found in archive (",
#     #                                                            targetFileChecked,") do not ",
#     #                                                            "match. Please check: 1. if file ",
#     #                                                            "desired is in the passed archive; ",
#     #                                                            "2. if filename provided is correct"))
#     
#   } else {
# 
#     warning(paste0("usePrepInputs = FALSE. The file will be downloaded ",
#                    "using a system call of 'gdown'. ",
#                    " If 'gdown' has not been installed, please follow the instructions: ",
#                    "https://pypi.org/project/gdown/. Yet, gdown may not work with shared drives!"), 
#             immediate. = TRUE)
#     tryCatch({system(paste0("gdown https://drive.google.com/uc?id=", targetArchiveID, 
#                   " -O ", destinationPath), 
#            wait = TRUE)}, error = function(e){
#              stop(paste0("Downloading the file ",paste0("https://drive.google.com/uc?id=", 
#                                                        targetArchiveID),
#                          " automatically has failed. Please try to download it",
#                          "manually, place it in ",destinationPath," and try running the module",
#                          " again."))
#            })
#     # Needs to implement unzip!
#     browser()
#     # Because the files are always potentially VERY large, use gdown directly.
#     # Make sure to unzip it
#     # Check for the specific files needed
#     # NEED TO BE SAVED IN: Paths[['outputPath']]
#   }
#     # archiveExists <- if (exists(file.path(destinationPath, targetArchive))) TRUE else FALSE
#     # fileExists <- if (exists(file.path(destinationPath, targetFile))) TRUE else FALSE
#     # if (all(archiveExists, fileExists)) return(file.path(destinationPath, targetFile)) else
#     #   if (all(archiveExists, !fileExists)) 
#     #     stop(paste0("targetArchive was downloaded but targetFile",
#     #                 "does not. Please make sure archive was",
#     #                 "correctly unzipped and that the targetFile ",
#     #                 "was in the archive.")) else
#     #       if (all(!archiveExists, fileExists)){
#     #         warning(paste0("targetArchive was not downloaded but targetFile",
#     #                                                    "exists. Please make sure this file",
#     #                        file.path(destinationPath, targetFile), "is the one desired"), 
#     #                 immediate. = TRUE)
#     #         return(file.path(destinationPath, targetFile))
# }