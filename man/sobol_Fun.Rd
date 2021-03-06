% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/test_functions.R
\name{sobol_Fun}
\alias{sobol_Fun}
\title{Sobol' G function}
\usage{
sobol_Fun(X)
}
\arguments{
\item{X}{A data frame or numeric matrix.}
}
\value{
A numeric vector with the model output.
}
\description{
It implements the \insertCite{Sobol1998;textual}{sensobol} G function.
}
\details{
The function requires 8 model inputs and reads as
\deqn{y=\prod_{i=1}^{k} \frac{|4 x_i - 2| + a_i}{1 + a_i}\,,}
where \eqn{k=8}, \eqn{x_i\sim\mathcal{U}(0,1)} and \eqn{a=(0, 1, 4.5, 9, 99, 99, 99, 99)}.
}
\examples{
# Define settings
N <- 100; params <- paste("X", 1:8, sep = "")

# Create sample matrix
mat <- sobol_matrices(N = N, params = params)

# Compute Sobol' G
Y <- sobol_Fun(mat)
}
\references{
\insertAllCited{}
}
