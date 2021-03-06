% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/test_functions.R
\name{oakley_Fun}
\alias{oakley_Fun}
\title{Oakley & O'Hagan (2004) function}
\usage{
oakley_Fun(X)
}
\arguments{
\item{X}{A data frame or numeric matrix.}
}
\value{
A numeric vector with the model output.
}
\description{
It implements the \insertCite{Oakley2004;textual}{sensobol} function.
}
\details{
The function requires 15 model inputs and reads as
\deqn{y=\mathbf{a}_1^T \bm{x} + \mathbf{a}_2 ^ T \sin(\mathbf{x}) + \mathbf{a}_3 ^ T \cos(\mathbf{x}) + \mathbf{x}^T \mathbf{M}\mathbf{x}\,,}
where \eqn{\mathbf{x}=x_1,x_2,...,x_k}, \eqn{k=15}, and values
for \eqn{\mathbf{a}^T_i,i=1,2,3} and \eqn{\mathbf{M}} are defined by the authors. The
transformation of the distribution of the model inputs from \eqn{U\sim(0, 1)} to
\eqn{N\sim(0, 1)}) is conducted internally.
}
\examples{
# Define settings
N <- 100; params <- paste("X", 1:15, sep = "")

# Create sample matrix
mat <- sobol_matrices(N = N, params = params)

# Compute Oakley and O'Hagan (2004) function
Y <- oakley_Fun(mat)
}
\references{
\insertAllCited{}
}
