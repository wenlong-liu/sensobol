
# PERSONALIZED GGPLOT2 THEME
##################################################################################

theme_AP <- function() {
  ggplot2::theme_bw() +
    ggplot2::theme(panel.grid.major = ggplot2::element_blank(),
          panel.grid.minor = ggplot2::element_blank(),
          legend.background = ggplot2::element_rect(fill = "transparent",
                                           color = NA),
          legend.key = ggplot2::element_rect(fill = "transparent", color = NA),
          strip.background = ggplot2::element_rect(fill = "white"),
          legend.position = "top")
}

# PLOT SOBOL' FIRST AND TOTAL-ORDER INDICES
##################################################################################

#' Plot Sobol' indices.
#'
#' @param data The matrix created with \code{\link{sobol_matrices}}.
#' @param order If \code{order = "first"}, it plots first and total effects.
#' If \code{order = "second"}, it plots second-order effects. If \code{order = "third"}, it plots
#' third-order effects. Default is \code{order = "first"}
#' @param dummy the output of \code{sobol_dummy}. Default is NULL.
#'
#' @return A ggplot object.
#' @import ggplot2
#' @export
#'
#' @examples
#' # Define settings
#' N <- 1000; params <- paste("X", 1:3, sep = ""); R <- 10
#'
#' # Create sample matrix
#' mat <- sobol_matrices(N = N, params = params)
#'
#' # Compute Ishigami function
#' Y <- ishigami_Fun(mat)
#'
#' # Compute and bootstrap Sobol' indices
#' ind <- sobol_indices(Y = Y, N = N, params = params, boot = TRUE, R = R)
#'
#' # Plot Sobol' indices
#' plot_sobol(data = ind)

plot_sobol <- function(data, order = "first", dummy = NULL) {
  sensitivity <- parameters <- original <- low.ci <- high.ci <- NULL
  colNames <- colnames(data)
  if(order == "first") {
    dt <- data[sensitivity %in% c("Si", "Ti")]
    gg <- ggplot2::ggplot(dt, ggplot2::aes(parameters, original, fill = sensitivity)) +
      ggplot2::geom_bar(stat = "identity",
                        position = ggplot2::position_dodge(0.6),
                        color = "black") +
      ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 3)) +
      ggplot2::labs(x = "",
                    y = "Sobol' index") +
      ggplot2::scale_fill_discrete(name = "Sobol' indices",
                                   labels = c(expression(S[italic(i)]),
                                              expression(T[italic(i)]))) +
      theme_AP()
    if(any(grepl("high.ci", colNames)) == TRUE) {
      gg <- gg +
        ggplot2::geom_errorbar(ggplot2::aes(ymin = low.ci,
                                            ymax = high.ci),
                               position = ggplot2::position_dodge(0.6))
    }
    if(is.null(dummy) == FALSE) {
      col_names <- colnames(dummy)
      if(any(grepl("high.ci", col_names)) == TRUE) {
        lmt <- dummy$high.ci
      } else {
        lmt <- dummy$original
      }
      gg <- gg +
        ggplot2::geom_hline(data = dummy,
                            ggplot2::aes(yintercept = lmt, color = sensitivity),
                            lty = 2) +
        ggplot2::guides(linetype = FALSE, color = FALSE)
    }
  } else if(!order == "first") {
    if(order == "second") {
      dt <- data[sensitivity %in% "Sij"][low.ci > 0]
    } else if(order == "third") {
      dt <- data[sensitivity %in% "Sijk"][low.ci > 0]
    } else {
      stop("Order should be first, second or third")
    }
    gg <- ggplot2::ggplot(dt, ggplot2::aes(stats::reorder(parameters, original),
                                           original)) +
      ggplot2::geom_point() +
      ggplot2::geom_errorbar(ggplot2::aes(ymin = low.ci,
                                          ymax = high.ci)) +
      ggplot2::labs(x = "",
                    y = "Sobol' index") +
      ggplot2::geom_hline(yintercept = 0,
                          lty = 2,
                          color = "red") +
      theme_AP()
  }
  return(gg)
}

# PLOT MODEL OUTPUT UNCERTAINTY
##################################################################################

#' Plot model output uncertainty
#'
#' It creates an histogram with the model output distribution.
#'
#' @param Y A numeric vector with the model output.
#' @param N The initial sample size of the base sample matrix created with \code{\link{sobol_matrices}}.
#'
#' @return a ggplot2 object.
#' @import ggplot2
#' @export
#'
#' @examples
#' # Define settings
#' N <- 1000; params <- paste("X", 1:3, sep = ""); R <- 10
#'
#' # Create sample matrix
#' mat <- sobol_matrices(N = N, params = params)
#'
#' # Compute Ishigami function
#' Y <- ishigami_Fun(mat)
#'
#' # Plot uncertainty
#' plot_uncertainty(Y = Y, N = N)

plot_uncertainty <- function(Y, N = NULL) {
  if(is.vector(Y) == FALSE) {
    stop("Y should be a vector")
  }
  if(is.null(N) == TRUE) {
    stop("The size of the base sample matrix N should be specified")
  }
  Y <- Y[1:N]
  df <- data.frame(Y)
  gg <- ggplot2::ggplot(df, ggplot2::aes(Y)) +
    ggplot2::geom_histogram(color = "black",
                   fill = "white") +
    ggplot2::labs(x = "y",
         y = "Count") +
    theme_AP()
  return(gg)
}

# PLOT SCATTERPLOTS OF MODEL OUTPUT AGAINST MODEL INPUTS
##################################################################################

#' Scatterplots of model inputs against model output.
#'
#' @param data The matrix created with \code{\link{sobol_matrices}}.
#' @param N The initial sample size of the base sample matrix created with \code{\link{sobol_matrices}}.
#' @param Y A numeric vector with the model output.
#' @param params Character vector with the name of the model inputs.
#' @param method The type of plot. If \code{method = "point"} (the default), each simulation is a point.
#' If \code{method = "bin"}, bins are used to aggregate simulationd. This option is appropriate to prevent
#' overplotting.
#' @param size Number between 0 and 1, argument of \code{geom_point()}. Default is 0.7.
#' @param alpha Number between 0 and 1, transparency scale of \code{geom_point()}. Default is 0.2.
#' @return A ggplot2 object
#' @import ggplot2
#' @export
#'
#' @examples
#' # Define settings
#' N <- 1000; params <- paste("X", 1:3, sep = ""); R <- 10
#'
#' # Create sample matrix
#' mat <- sobol_matrices(N = N, params = params)
#'
#' # Compute Ishigami function
#' Y <- ishigami_Fun(mat)
#'
#' # Plot scatter
#' plot_scatter(data = mat, Y = Y, N = N, params = params)
plot_scatter <- function(data, N, Y, params, method = "point", size = 0.7, alpha = 0.2) {
  value <- y <- NULL
  dt <- data.table::data.table(cbind(data, Y))[1:N]
  colnames(dt)[length(colnames(dt))] <- "y"
  out <- data.table::melt(dt, measure.vars = params)
  gg <- ggplot2::ggplot(out, ggplot2::aes(value, y)) +
    ggplot2::facet_wrap(~variable, scales = "free_x") +
    ggplot2::labs(x = "Value", y = "y") +
    ggplot2::theme_bw() +
    ggplot2::theme(panel.grid.major = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank(),
                   legend.background = ggplot2::element_rect(fill = "transparent",
                                                             color = NA),
                   legend.key = ggplot2::element_rect(fill = "transparent", color = NA),
                   strip.background = ggplot2::element_rect(fill = "white"),
                   legend.position = "top")
  if(method == "point") {
    gg <- gg + ggplot2::geom_point(size = size, alpha = alpha) +
      ggplot2::stat_summary_bin(fun = "mean", geom = "point", colour = "red", size = 0.7)
  } else if(method == "bin") {
    gg <- gg + ggplot2::geom_hex() +
      ggplot2::stat_summary_bin(fun = "mean", geom = "point", colour = "red", size = 0.7)
  } else {
    stop("Method should be either point or bin")
  }
  return(gg)
}

# PLOT SCATTERPLOT MATRIX OF PAIRS OF PARAMETERS
##################################################################################

#' Scatterplot matrix of model inputs and model output.
#'
#' @param data The matrix created with \code{\link{sobol_matrices}}.
#' @param N The initial sample size of the base sample matrix created with \code{\link{sobol_matrices}}.
#' @param Y A numeric vector with the model output.
#' @param params Character vector with the name of the model inputs.
#' @param smpl The number of simulations to plot (needed only to avoid overplotting).
#' The default is NULL.
#'
#' @importFrom data.table .SD .N
#'
#' @return A ggplot2 object
#' @import ggplot2
#' @export
#'
#' @examples
#' # Define settings
#' N <- 1000; params <- paste("X", 1:3, sep = ""); R <- 10
#'
#' # Create sample matrix
#' mat <- sobol_matrices(N = N, params = params)
#'
#' # Compute Ishigami function
#' Y <- ishigami_Fun(mat)
#'
#' # Plot scatterplot matrix
#' plot_multiscatter(data = mat, N = N, Y = Y, params = params)
plot_multiscatter <- function(data, N, Y, params, smpl = NULL) {
  xvar <- yvar <- x <- y <- NULL
  dt <- data.table::data.table(data)
  out <- t(utils::combn(params, 2))
  da <- list()
  for(i in 1:nrow(out)) {
    cols <- out[i, ]
    da[[i]] <- cbind(dt[1:N, .SD, .SDcols = (cols)], cols[1], cols[2], Y[1:N])
    data.table::setnames(da[[i]], colnames(da[[i]]), c("xvar", "yvar", "x", "y", "output"))
  }
  output <- data.table::rbindlist(da)
  if(is.null(smpl) == FALSE) {
    if(is.numeric(smpl) == FALSE) {
      stop("smpl should be a number")
    } else {
      output <- output[,.SD[sample(.N, min(smpl,.N))], by = list(x, y)]
    }
  }
  gg <- ggplot2::ggplot(output, ggplot2::aes(xvar, yvar, color = output)) +
    ggplot2::geom_point(size = 0.5) +
    ggplot2::scale_colour_gradientn(colours = grDevices::terrain.colors(10), name = "y") +
    ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 3)) +
    ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 3)) +
    ggplot2::facet_wrap(x~y, scales = "free") +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "", y = "") +
    ggplot2::theme(panel.grid.major = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank(),
                   legend.background = ggplot2::element_rect(fill = "transparent",
                                                             color = NA),
                   legend.key = ggplot2::element_rect(fill = "transparent", color = NA),
                   strip.background = ggplot2::element_rect(fill = "white"),
                   legend.position = "top")
  return(gg)
}
