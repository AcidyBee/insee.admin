if (FALSE) {

# Création du package
name_package <- "insee.admin"
# available::available(name_package) # OK
usethis::create_package(file.path("/Users/Alexis/Documents/Travail/R/Packages", name_package))

## Gestion du .Rbuildignore
# usethis::use_build_ignore("devtools_history.R")
usethis::use_build_ignore("dev")
# usethis::use_build_ignore("output")

## Licence
# usethis::use_gpl3_license()
usethis::use_mit_license()

# Depend on R version 4.1
# usethis::use_package("R", type = "Depends", min_version = "4.1")
## La dépendance à la version 4.1 était justifiée par l'utilisation du pipe de base R `|>`
## il semble plus judicieux de retirer cette dépendance et de la substituer par l'utilisation du pipe de magritr (importé dans le package)
usethis::use_pipe()
# usethis::use_package("R", type = "Depends", min_version = "2.10")

## Orders and formats DESCRIPTION fields according to a fixed standard
usethis::use_tidy_description()

usethis::use_package("R", type = "Depends", min_version = "3.5")

# Dependances
usethis::use_package('dplyr', type = "Imports", min_version = "1.1.1")
usethis::use_package('sf', type = "Imports")
usethis::use_package('readxl', type = "Imports", min_version = "1.4.0")
usethis::use_package('stringr', type = "Imports")
usethis::use_package('tidyr', type = "Imports")
usethis::use_package('logger', type = "Imports")
usethis::use_package('rlang', type = "Imports", min_version = "1.0.0")
usethis::use_package('tidyselect', type = "Imports", min_version = "1.1.0")
usethis::use_package('purrr', type = "Imports", min_version = "1.0.0")
usethis::use_package('glue', type = "Imports")

# usethis::use_package('lubridate', type = "Imports", min_version = "1.5.0")
# usethis::use_package('forcats', type = "Imports", min_version = "1.0.0")
# usethis::use_package('rlang', type = "Imports", min_version = "1.0.0")
# usethis::use_package('checkupr', type = "Suggests")
# usethis::use_package("stringi", type = "Imports", min_version = "1.8.3")
# usethis::use_package('time.machine', type = "Imports")

# usethis::use_package('readr', type = "Imports", min_version = "2.0.0")

## packages dans les vignettes
# usethis::use_package('tidyr', type = "Suggests", min_version = "1.0.0")
usethis::use_package('insee.admin.data.2022', type = "Suggests")
usethis::use_package('tibble', type = "Suggests", min_version = "3.1.0")
usethis::use_package('ggplot2', type = "Suggests")
# ☐ Use `requireNamespace("htmlwidgets", quietly = TRUE)` to test if htmlwidgets is installed.
# ☐ Then directly refer to functions with `htmlwidgets::fun()`.
# usethis::use_package('leaflet', type = "Suggests")
# usethis::use_package('arsenal', type = "Suggests", min_version = "3.6.3")
# usethis::use_package('arsenal.extension', type = "Suggests")
# usethis::use_package('survival', type = "Suggests")
# usethis::use_package('survminer', type = "Suggests")
#
# usethis::use_package("data.table", type = "Imports")
# usethis::use_package('DT', type = "Suggests")
## DONE: compiler medikit pour l'importer
# usethis::use_package('medikit', type = "Imports")
# usethis::use_package('stats', type = "Imports")


# usethis::use_package('vroom', type = "Imports", min_version = "1.1.0")
# # usethis::use_package('tidyverse', type = "Imports", min_version = "1.3.0") # good-practices: lister les packages individuellement
#
# usethis::use_package('forcats', type = "Imports", min_version = "1.0.0")
# usethis::use_package('stringi', type = "Imports")
# usethis::use_package("janitor", type = "Imports")
# usethis::use_package('cellranger', type = "Imports", min_version = "1.1.0")
# usethis::use_package('rlang', type = "Suggests", min_version = "1.0.0")
#

## Data
usethis::use_data_raw()
# -> la création des data est réalisée dans "data-raw/DATASET.R"
# y compris la création des lazydata dans "data/"

## Créé un fichier README.Rmd
usethis::use_readme_rmd()
devtools::build_readme()

## Initialisation Git
usethis::use_git()
usethis::use_git_ignore("dev/")
## et GitHub
usethis::use_github()
# usethis::use_github_links() # opération déjà réalisée par la commande précédente
## GitHub et pkgdown
usethis::use_pkgdown_github_pages() # Run once to configure your package to use and deploy pkgdown
## prévisualisation en local # Preview your site locally before publishing
pkgdown::build_site()

# git push -u origin targets-workflow

## Badges CI (integration continue): Badge R-CMD-check passe sur les serveurs de GitHub
usethis::use_github_action("check-standard")
## Badge code coverage (mais ici pas de tests...)
# usethis::use_github_action("check-standard", badge = TRUE)



## Création des vignettes
## TODO: représenter les différentes échelles géographiques par leur géometrie
usethis::use_vignette("decoupage-admin-spatial")
## puis retrouver les emboîtements au niveau semantic
usethis::use_vignette("decoupage-admin-semantic")
# ## Créer une vignette rp-logemt et faire le lien avec la geometry
# usethis::use_vignette("rp-detail")
# ## puis une vignette rp-indcvi et faire le lien avec la geometry
# # usethis::use_vignette("indcvi")
## On aura tous les éléments pour créer un package de data pour mapuce millésime 2020 (geomerty 2022)

# ## Création des unit-tests
# usethis::use_testthat(3)
# usethis::use_test(name = "indcvi")
# devtools::test()

## Package workflow
# documente les fonctions
# roxygen2::roxygenize(clean = TRUE)
devtools::document()
# charge les fonctions dans l'environnement
devtools::load_all()
devtools::check()

## installation locale du package :)
## en cas de bug
# remove.packages(name_package)
# .rs.restartR()
devtools::install()

## Création d'un binaire pour installation locale:
# repo_path_source <- "~/Documents/Travail/R/r_packages_repo/src/contrib"
# repo_path_bin <- "~/Documents/Travail/R/r_packages_repo/bin/macosx/contrib/4.3"
# devtools::build(binary = TRUE)
utils::install.packages("../insee.admin_0.0.0.9000.tgz",
                        repos = NULL,
                        type = "source")
devtools::build(binary = FALSE, path = "/Users/Alexis/Documents/Travail/R/r_packages_repo/src/contrib")


## Gestion des versions
usethis::use_version()

}
