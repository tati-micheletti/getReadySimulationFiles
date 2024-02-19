rstCurrentBurnListGenerator <- function(pathInputs, 
                                        studyArea, 
                                        rasterToMatch, 
                                        runName){
  
  listName <- file.path(pathInputs, paste0("rstCurrentBurnList_", runName, ".tif"))
  if (!file.exists(listName)){
    rstPath <- grepMulti(x = list.files(path = pathInputs, full.names = TRUE),
                         patterns = c("rstCurrentBurn"),
                         unwanted = c("aux", "xml"))
    if (length(rstPath) == 0)
      stop("No rstCurrentBurn file (.tif) found in pathInputs. ",
           "Please make sure these files are in the folder. ",
           "These come generallyfrom landscape simulation, and ",
           "indicate the pixels burned on a given year (raster)")
    rstCurrentBurnList <- lapply(rstPath, function(rPath){
      rasName <- paste0("Year", substrBoth(strng = tools::file_path_sans_ext(rPath),
                                           howManyCharacters = 4, fromEnd = TRUE))
      message(paste0("Postprocessing fire raster for ", rasName))
      ras <- reproducible::postProcessTo(rast(rPath),
                                         studyArea = studyArea,
                                         rasterToMatch = rasterToMatch)
      names(ras) <- rasName
      return(ras)
    })
    rstStck <- rast(rstCurrentBurnList)
    names(rstStck) <- unlist(lapply(rstCurrentBurnList, names))
    writeRaster(rstStck, filename = listName)
  } else {
    rstStck <- rast(listName)
  }
  message(paste0("Files found for  ",
                 names(rstStck)[1], " to ", names(rstStck)[terra::nlyr(rstStck)]))
  return(rstStck)
}
