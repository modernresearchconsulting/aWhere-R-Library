% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/weather-norms.R
\name{weather_norms_fields}
\alias{weather_norms_fields}
\title{weather_norms_fields}
\usage{
weather_norms_fields(field_id, monthday_start, monthday_end, year_start,
  year_end, exclude_years = c())
}
\arguments{
\item{-}{field_id: the field_id associated with the location for which you want to pull data.
Field IDs are created using the create_field function. (string)}

\item{-}{monthday_start: character string of the first month and day for which you want to retrieve data,
in the form: MM-DD.  This is the start of your date range. e.g. '07-01' (July 1) (required)}

\item{-}{monthday_end: character string of the last month and day for which you want to retrieve data,
in the form: MM-DD.  This is the end of your date range. e.g. '07-01' (July 1) (required)}

\item{-}{year_start: character string of the starting year (inclusive) of the range of years for which
you're calculating norms, in the form YYYY. e.g., 2008 (required)}

\item{-}{year_end: character string of the last year (inclusive) of the range of years for which
you're calculating norms, in the form YYYY. e.g., 2015 (required)}

\item{-}{exclude_year: character string of a year or years which you'd like to exclude from
 your range of years on which to calculate norms. To exclude
 multiple years, provide a vector of years. You must include
at least three years of data with which to calculate the norms. (optional)}
}
\value{
dataframe of requested data for dates requested
}
\description{
\code{weather_norms_fields} pulls long term norm weather data from aWhere's API based on field id
}
\details{
This function allows you to calculate the averages for weather attributes
across any range of years for which data are available.  The data pulled includes
meanTemp, maxTemp, minTemp, precipitation average, solar radiation average,
minHumidity, maxHumidity, maxWind and averageWind, along with the standard deviations
for these variables.  The data pulled is for the field id identified.

The data returned in this function
allow you to compare this year or previous years to the long-term normals, calculated as
the average of those weather conditions on that day in that location over the years specified.
}
\examples{
\dontrun{weather_norms_fields("aWhere", monthday_start = "06-01", monthday_end = "09-01",
year_start = 2006, year_end = 2015)}
}
\references{
http://developer.awhere.com/api/reference/weather/norms
}

