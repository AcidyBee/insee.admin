#' Filter Polygons by Distance
#'
#' This function filters polygons from an sf object that are located within a given distance from a target polygon.
#'
#' @param sf_data An object of class `sf` containing polygon geometries.
#' @param id_column The name of the column in `sf_data` that contains the identifiers for the polygons.
#' @param target_polygon_id The identifier(s) of the target polygon(s) to use as the reference for distance calculations.
#' @param distance_threshold Numeric value specifying the distance threshold within which to filter polygons (in the same units as the sf object).
#'
#' @return An `sf` object containing only the polygons that are within the specified distance from the target polygon(s).
#'
#' @importFrom sf st_distance
#' @export
#'
#' @examples
#' # Assuming `sf_data` is an sf object and `target_polygon_id` is the ID of the target polygon
#' # filtered_polygons <- filter_polygons_by_distance(sf_data, "ID", "target_polygon_id", 1000)
filter_polygons_by_distance <- function(sf_data, id_column, target_polygon_id, distance_threshold) {

  # Vérifier que l'objet est de classe sf
  if (!inherits(sf_data, "sf")) {
    stop("Input object `sf_data` is not of class classe 'sf'.")
  }

  # Vérifier que la colonne d'identification existe dans les données
  if (!id_column %in% colnames(sf_data)) {
    stop("Identification column specified in `id_column` can not be found in the `sf_data` dataset.")
  }

  # Vérifier que la distance_threshold est un nombre positif
  if (!is.numeric(distance_threshold) || distance_threshold <= 0) {
    stop("Distance threshold `distance_threshold` is expected to be a positive number.")
  }

  # Vérifier que les identifiants cibles existent dans les données
  if (!all(target_polygon_id %in% sf_data[[id_column]])) {
    stop("At least one of the identifier for target polygons `target_polygon_id` can not be found in the `sf_data` dataset.")
  }

  # Extraire les polygones cibles
  target_polygons <- sf_data[sf_data[[id_column]] %in% target_polygon_id, ]

  # Calculer la distance entre les polygones cibles et tous les autres polygones
  distances <- sf::st_distance(target_polygons, sf_data)

  # Filtrer les polygones en fonction du seuil de distance
  filtered_sf <- sf_data[apply(distances, 2, min) <= distance_threshold, ]

  return(filtered_sf)
}


# ## Fichier de test : test_filter_polygons.R
# library(testthat)
# library(sf)
#
# # Créer des données de test
# test_data <- st_sf(
#   id = 1:3,
#   geometry = st_sfc(
#     st_polygon(list(rbind(c(0,0), c(1,0), c(1,1), c(0,1), c(0,0)))),
#     st_polygon(list(rbind(c(2,2), c(3,2), c(3,3), c(2,3), c(2,2)))),
#     st_polygon(list(rbind(c(4,4), c(5,4), c(5,5), c(4,5), c(4,4))))
#   )
# )
#
# test_that("filter_polygons_by_distance works correctly", {
#   # Test avec une distance suffisante pour inclure tous les polygones
#   result <- filter_polygons_by_distance(test_data, "id", 1, 10)
#   expect_equal(nrow(result), 3)
#
#   # Test avec une distance insuffisante pour inclure seulement le premier polygone
#   result <- filter_polygons_by_distance(test_data, "id", 1, 1)
#   expect_equal(nrow(result), 1)
#
#   # Test avec des identifiants invalides
#   expect_error(filter_polygons_by_distance(test_data, "id", c(99), 10),
#                "Un ou plusieurs identifiants de polygone cibles n'existent pas dans les données.")
#
#   # Test avec une colonne d'identification invalide
#   expect_error(filter_polygons_by_distance(test_data, "invalid_col", 1, 10),
#                "La colonne d'identification spécifiée n'existe pas dans les données.")
#
#   # Test avec une distance_threshold invalide
#   expect_error(filter_polygons_by_distance(test_data, "id", 1, -1),
#                "Le seuil de distance doit être un nombre positif.")
#
#   # Test avec un objet non sf
#   non_sf_data <- data.frame(id = 1:3, x = c(0, 1, 2))
#   expect_error(filter_polygons_by_distance(non_sf_data, "id", 1, 10),
#                "L'objet fourni n'est pas de classe 'sf'.")
# }
