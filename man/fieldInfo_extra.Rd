% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fct_fieldInfo_extra.R
\name{fieldInfo_extra}
\alias{fieldInfo_extra}
\title{Extract information from image using the fieldShape file as reference}
\usage{
fieldInfo_extra(mosaic, fieldShape, fun = "mean", progress = FALSE)
}
\arguments{
\item{mosaic}{object of class stack.}

\item{fieldShape}{plot shape file, please use first the function \code{\link{fieldShape}}.}

\item{fun}{character to summarize the values (e.g. "mean").}

\item{progress}{if TRUE, display a progress bar during processing}
}
\value{
A data frame class "sf" with values by plot.
}
\description{
Function that use \code{exactextractr::exact_extract()} to extract information from the original
image using fieldShape file as reference.
}
\details{
fieldInfo_extra
}
