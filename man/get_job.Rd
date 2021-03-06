% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get.R
\name{get_job}
\alias{get_job}
\title{Get Job}
\usage{
get_job(job_id, wait = T, retry_secs = 60, num_retries = 60)
}
\arguments{
\item{-}{job_id: a job ID assigned by an aWhere create job.}

\item{-}{wait: wait for job to complete before returning}
}
\value{
- data.frame containing the requested payload(s).
}
\description{
\code{get_job} Gets a job's results when complete.
}
\details{
Once a batch job is queued you can check on its status with this API. If the job is complete and results are available, they will be included in the response body.
}
\examples{
\dontrun{get_job(job_id='1234')}
}
\references{
https://developer.awhere.com/api/reference/batch/status-results
}

