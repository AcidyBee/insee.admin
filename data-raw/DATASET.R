## Création de jeux de données spatailes exemples pour le fichier README
## Les données sont stockées dans le répertoire "inst/extdata/"
library(sf)
# chemin du shapefile source
path_to_shp_cog_2022 <- insee.admin.data.2022::path_to_extdata("IGN/ADMIN-EXPRESS-COG")
sf_COM_2022 <- sf::st_read(path_to_shp_cog_2022, layer = "COMMUNE")
sf_DEP_2022 <- sf::st_read(path_to_shp_cog_2022, layer = "DEPARTEMENT")

library(dplyr)
library(stringr)
# Exemple : garder seulement quelques communes et départements de la région Centre-Val de Loire
sf_COM <- sf_COM_2022 %>%
  filter(str_detect(INSEE_DEP, "^24"))
sf_DEP <- sf_DEP_2022 %>%
  filter(str_detect(INSEE_REG, "^24"))

# # Créer le dossier si nécessaire
# dir.create("inst/extdata", recursive = TRUE, showWarnings = FALSE)

# Écrire le shapefile filtré
sf::st_write(
  sf_COM,
  dsn = "inst/extdata/COMMUNE.shp",
  delete_layer = TRUE
)
sf::st_write(
  sf_DEP,
  dsn = "inst/extdata/DEPARTEMENT.shp",
  delete_layer = TRUE
)
