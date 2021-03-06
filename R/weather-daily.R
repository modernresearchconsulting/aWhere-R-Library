#' @title daily_observed_fields
#'
#' @description
#' \code{daily_observed_fields} pulls historical weather data from aWhere's API based on field id
#'
#' @details
#' This function returns weather data on Min/Max Temperature, Precipitation,
#' Min/Max Humidity, Solar Radiation, and Maximum Wind Speed,
#' Morning Max Windspeed, and Average Windspeed for the field id specified. 
#' Default units are returned by the API. 
#' 
#' The Weather APIs provide access to aWhere's agriculture-specific Weather Terrain system,
#' and allows retrieval and integration of data across all different time ranges, long term normals,
#' daily observed, current weather, and forecasts. These APIs are designed for efficiency,
#' allowing you to customize the responses to return just the attributes you need.
#'
#' Understanding the recent and long-term daily weather is critical for making in-season decisions.
#' This API opens the weather attributes that matter most to agriculture. 
#' 
#'
#' @references http://developer.awhere.com/api/reference/weather/observations
#'
#' @param - field_id: the field_id associated with the location for which you want to pull data.  
#' Field IDs are created using the create_field function.(string)
#' @param - day_start: character string of the first day for which you want to retrieve data, in the form: YYYY-MM-DD
#' @param - day_end: character string of the last day for which you want to retrieve data, in form: YYYY-MM-DD
#'
#' @import httr
#' @import data.table
#' @import lubridate
#' @import jsonlite
#'
#' @return data.frame of requested data for dates requested
#'
#'
#' @examples
#' \dontrun{daily_observed_fields('field123','2016-04-28','2016-05-01')}

#' @export
daily_observed_fields <- function(field_id, day_start, day_end) {

  checkCredentials()
  checkValidField(field_id)
  checkValidStartEndDates(day_start,day_end)


  ## Create Request
  #Calculate number of loops needed if requesting more than 50 days
  numObsReturned <- 120

  if (day_start != '' & day_end != '') {
    numOfDays <- as.numeric(difftime(ymd(day_end), ymd(day_start), units = 'days'))
    allDates <- seq(as.Date(ymd(day_start)),as.Date(ymd(day_end)), by="days")

    loops <- ((length(allDates))) %/% numObsReturned
    remainder <- ((length(allDates))) %% numObsReturned

  } else if (day_start != '') {

    numOfDays <- 1
    allDates <- ymd(day_start)
    loops <- 1
    remainder <- 0
  } else {
    numOfDays <- 1
    allDates <- ''
    loops <- 1
    remainder <- 0
  }

  if(remainder > 0) {
    loops <- loops + 1
  }
  i <- 1

  dataList <- list()

  # loop through, making requests in 50-day chunks

  for (i in 1:loops) {

    starting = numObsReturned*(i-1)+1
    ending = numObsReturned*i

    if(paste(allDates,sep = '',collapse ='') != '') {
      day_start <- allDates[starting]
      day_end <- allDates[ending]
      if(is.na(day_end)) {
        tempDates <- allDates[c(starting:length(allDates))]
        day_start <- tempDates[1]
        day_end <- tempDates[length(tempDates)]
      }
    }


    # Create query

    urlAddress <- "https://api.awhere.com/v2/weather"

    strBeg <- paste0('/fields')
    strCoord <- paste0('/',field_id)
    strType <- paste0('/observations')

    if(paste(allDates,sep = '',collapse ='') != '') {
      strDates <- paste0('/',day_start,',',day_end)

      returnedAmount <- as.integer(difftime(ymd(day_end),ymd(day_start),units = 'days')) + 1L
      if (returnedAmount > numObsReturned) {
        returnedAmount <- numObsReturned
      }
      limitString <- paste0('?limit=',returnedAmount)

    } else {
      strDates <- ''
      limitString <- paste0('?limit=',numObsReturned)
    }

    url <- paste0(urlAddress, strBeg, strCoord, strType, strDates, limitString)

    doWeatherGet <- TRUE

    while (doWeatherGet == TRUE) {
      postbody = ''
      request <- httr::GET(url, body = postbody, httr::content_type('application/json'),
                           httr::add_headers(Authorization =paste0("Bearer ", awhereEnv75247$token)))

      a <- suppressMessages(httr::content(request, as = "text"))

      #The JSONLITE Serializer properly handles the JSON conversion
      x <- jsonlite::fromJSON(a, flatten = TRUE)

      if (grepl('API Access Expired',a)) {
        get_token(awhereEnv75247$uid,awhereEnv75247$secret)
      } else {
        doWeatherGet <- FALSE
      }
    }

    data <- data.table::as.data.table(x[[1]])

    dataList[[i]] <- data
  }

  allWeath <- rbindlist(dataList)

  varNames <- colnames(allWeath)

  #This removes the non-data info returned with the JSON object
  allWeath[,grep('_links',varNames) := NULL]
  allWeath[,grep('.units',varNames) := NULL]

  return(as.data.frame(allWeath))
}


#' @title daily_observed_latlng
#'
#' @description
#' \code{daily_observed_latlng} pulls historical weather data from aWhere's API based on latitude & longitude
#'
#' @details
#' This function returns weather data on Min/Max Temperature, Precipitation,
#' Min/Max Humidity, Solar Radiation, and Maximum Wind Speed,
#' Morning Max Windspeed, and Average Windspeed for the location specified by latitude and longitude. 
#' Default units are returned by the API. Latitude and longitude must be in decimal degrees.
#' 
#' The Weather APIs provide access to aWhere's agriculture-specific Weather Terrain system,
#' and allows retrieval and integration of data across all different time ranges, long term normals,
#' daily observed, current weather, and forecasts. These APIs are designed for efficiency,
#' allowing you to customize the responses to return just the attributes you need.
#'
#' Understanding the recent and long-term daily weather is critical for making in-season decisions.
#' This API opens the weather attributes that matter most to agriculture. 
#'
#' @references http://developer.awhere.com/api/reference/weather/observations/geolocation
#'
#' @param - latitude: the latitude of the requested location (double)
#' @param - longitude: the longitude of the requested locations (double)
#' @param - day_start: character string of the first day for which you want to retrieve data, in the form: YYYY-MM-DD
#' @param - day_end: character string of the last day for which you want to retrieve data, in the form: YYYY-MM-DD
#'
#' @import httr
#' @import data.table
#' @import lubridate
#' @import jsonlite
#'
#' @return data.frame of requested data for dates requested
#'
#'
#' @examples
#' \dontrun{daily_observed_latlng(39.8282, -98.5795,'2014-04-28','2015-05-01')}

#' @export


daily_observed_latlng <- function(latitude, longitude, day_start, day_end) {

  #checkCredentials()
  #checkValidLatLong(latitude,longitude)
  #checkValidStartEndDates(day_start,day_end)

  ## Create Request
  #Calculate number of loops needed if requesting more than 50 days
  numObsReturned <- 120

  if (day_end != '') {
    numOfDays <- as.numeric(difftime(ymd(day_end), ymd(day_start), units = 'days'))
    allDates <- seq(as.Date(ymd(day_start)),as.Date(ymd(day_end)), by="days")

    loops <- ((length(allDates))) %/% numObsReturned
    remainder <- ((length(allDates))) %% numObsReturned

  } else {

    numOfDays <- 1
    allDates <- ymd(day_start)
    loops <- 1
    remainder <- 0
  }

  if(remainder > 0) {
    loops <- loops + 1
  }
  i <- 1

  dataList <- list()

  # loop through, making requests in 50-day chunks

  for (i in 1:loops) {

    starting = numObsReturned*(i-1)+1
    ending = numObsReturned*i
    day_start <- allDates[starting]
    day_end <- allDates[ending]
    if(is.na(day_end)) {
      tempDates <- allDates[c(starting:length(allDates))]
      day_start <- tempDates[1]
      day_end <- tempDates[length(tempDates)]
    }


    # Create query

    urlAddress <- "https://api.awhere.com/v2/weather"

    strBeg <- paste0('/locations')
    strCoord <- paste0('/',latitude,',',longitude)
    strType <- paste0('/observations')
    strDates <- paste0('/',day_start,',',day_end)


    returnedAmount <- as.integer(difftime(ymd(day_end),ymd(day_start),units = 'days')) + 1L
    if (returnedAmount > numObsReturned) {
      returnedAmount <- numObsReturned
    }
    limitString <- paste0('?limit=',returnedAmount)

    url <- paste0(urlAddress, strBeg, strCoord, strType, strDates, limitString)

    doWeatherGet <- TRUE

    while (doWeatherGet == TRUE) {
      postbody = ''
      request <- httr::GET(url, body = postbody, httr::content_type('application/json'),
                           httr::add_headers(Authorization =paste0("Bearer ", awhereEnv75247$token)))

      # Make request

      a <- suppressMessages(httr::content(request, as = "text"))

      #The JSONLITE Serializer properly handles the JSON conversion

      x <- jsonlite::fromJSON(a,flatten = TRUE)

      if (grepl('API Access Expired',a)) {
        get_token(awhereEnv75247$uid,awhereEnv75247$secret)
      } else {
        doWeatherGet <- FALSE
      }
    }

    data <- data.table::as.data.table(x[[1]])

    dataList[[i]] <- data

  }
  allWeath <- rbindlist(dataList)

  varNames <- colnames(allWeath)

  #This removes the non-data info returned with the JSON object
  allWeath[,grep('_links',varNames) := NULL]
  allWeath[,grep('.units',varNames) := NULL]

  return(as.data.frame(allWeath))
}
