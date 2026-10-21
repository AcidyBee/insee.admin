#' # ## Extrait les codes IRIS qui peuvent être trouvés dans 2 communes distinctes
#' # decoupage_iris_2022 %>%
#' #   dplyr::distinct(CODE_IRIS, DEPCOM) %>%
#' #   dplyr::group_by(CODE_IRIS) %>%
#' #   dplyr::filter(dplyr::n() > 1)
#'
#' # Création de la fonction
#' ## on recherche si un même enfant peut avoir plus d'un unique parent
#' #' Extract rows corresponding to a non-hierarchical relationship
#' #'
#' #' Extract rows corresponding to a non-hierarchical relationship between two variables.
#' #' @param data A dataset with the hierarchy between variables to check.
#' #' @param parent A column with a role of parent compared to the other variable.
#' #' @param child A column with a role of child compared to the other variable.
#' #'
#' #' @return The same dataset as the input keeping only rows not diplaying the expected hierarchical relationship between parent and child columns.
#' #' @export
#' #'
#' # #' @examples
#' keep_non_hierarchic_rows <- function(data, parent, child) {
#'   data %>%
#'     dplyr::distinct({{ parent }}, {{ child }}) %>%
#'     dplyr::group_by({{ child }}) %>%
#'     dplyr::filter(dplyr::n() > 1)
#' }
#' ## note:
#' ## - le nombre d'éléments distinct d'une classe peut nous permettre de vérifier l'ordre de la hiérarchie, cependant
#' ## - il est possible d'avoir plus de parents que d'enfants ET une relation hiérarchique, si par exemple il y a des NA pour les enfants
#' ## TODO: imaginer un contrôle d'erreur adapté...
#'
#'
#' ## Création de la fonction inverse
#' #' Discard rows corresponding to a non-hierarchical relationship
#' #'
#' #' Discard rows corresponding to a non-hierarchical relationship between two variables.
#' #' @param data A dataset with the hierarchy between variables to check.
#' #' @param parent A column with a role of parent compared to the other variable.
#' #' @param child A column with a role of child compared to the other variable.
#' #'
#' #' @return The same dataset as the input keeping only rows diplaying the expected hierarchical relationship between parent and child columns.
#' #' @export
#' #'
#' # #' @examples
#' discard_non_hierarchic_rows <- function(data, parent, child) {
#'   data %>%
#'     dplyr::distinct({{ parent }}, {{ child }}) %>%
#'     dplyr::group_by({{ child }}) %>%
#'     dplyr::filter(dplyr::n() < 2)
#' }
#'
#'
#'
#' #' Augment insee administrative dataset with com_arm_code and com_arm_lib
#' #'
#' #' @param data A insee dataset containing at least the 4 olumns required for computation:
#' #'   c("arm_code", "arm_lib", "com_code", "com_lib").
#' #'
#' #' @return The input dataset augmented with com_arm_code and com_arm_lib columns
#' #' @export
#' #'
#' #' @examples
#' #' data.frame(
#' #'   id = 1:5,
#' #'   arm_code = c("75101", "75102", "75111", "ZZZZZ", NA_character_),
#' #'   com_code = c("75056", "75056", "75056", "72191", "72191")
#' #' ) %>%
#' #'   augment_com_arm_cols()
#' #' data.frame(
#' #'   id = 1:5,
#' #'   arm_code = c("75101", "75102", "75111", "ZZZZZ", NA_character_),
#' #'   com_code = c("75056", "75056", "75056", "74037", "74037"),
#' #'   arm_lib = c("Paris 1er Arrondissement", "Paris 2e Arrondissement",
#' #'     "Paris 11e Arrondissement", "ZZZZZ", NA_character_),
#' #'   com_lib = c("Paris", "Paris", "Paris", "Boëge", "Boëge")
#' #' ) %>%
#' #'   augment_com_arm_cols()
#' augment_com_arm_cols <- function(data) {
#'   # Vérifier que les colonnes arm_code, arm_lib, com_code & com_lib existent bien
#'   if (!all(c("arm_code", "com_code") %in% colnames(data))) {
#'     stop('Columns `c("arm_code", "com_code")` required for `com_arm_code` computation can not be found in `data`.\n')
#'   }
#'   if (!all(c("arm_lib", "com_lib") %in% colnames(data))) {
#'     warning("Columns required for `com_arm_lib` computation can not be found in `data`.\n")
#'   }
#'   data <- data %>%
#'     ## Création des codes com_arm_(code|lib) qui sont utilisés dans le découpage infracommunal.
#'     ## creates com_arm_code & com_arm_lib
#'     dplyr::mutate(
#'       com_arm_code = dplyr::if_else(.data$arm_code == "ZZZZZ", .data$com_code, .data$arm_code)
#'     )
#'   if (all(c("arm_lib", "com_lib") %in% colnames(data))) {
#'     data <- data %>%
#'       dplyr::mutate(
#'         com_arm_lib  = dplyr::if_else(.data$arm_code == "ZZZZZ", .data$com_lib, .data$arm_lib)
#'       )
#'   }
#'   data
#' }
#'
#'
#' ## ****************************************************************************
#' ## Ajout des libellés pour les codes geographiques supracommunaux
#'
#' #' Create a nested dictionary of French administrative divisions (COG)
#' #'
#' #' This function imports and structures French administrative divisions data from an Excel file
#' #' into a nested tibble dictionary with codes and labels organized by geographic level.
#' #'
#' #' @param path Character. Path to the Excel file containing COG data.
#' #' @param sheet Integer or character. Sheet number or name (default: 3).
#' #' @param skip Integer. Number of rows to skip at the beginning (default: 5).
#' #'
#' #' @return A tibble with nested data containing administrative codes and labels by geographic level.
#' #' Each row represents a geographic level with its corresponding data nested in the 'data' column.
#' #'
#' #' @importFrom readxl read_excel
#' #' @importFrom dplyr rename mutate
#' #' @importFrom tidyr nest
#' #' @importFrom rlang .data
#' #'
#' #' @examples
#' #' \dontrun{
#' #'   path_to_decoupage_communal_2022 <- insee.admin.data.2022::path_to_extdata(
#' #'     "decoupage-admin/table-appartenance-geo-communes-22.xlsx"
#' #'     )
#' #'   create_cog_nested_dict(path = path_to_decoupage_communal_2022)
#' #' }
#' #'
#' #' @export
#' create_cog_nested_dict <- function(path, sheet = 3L, skip = 5) {
#'   # Validate inputs
#'   if (!is.character(path) || length(path) != 1) {
#'     stop("'path' must be a single character string")
#'   }
#'   if (!file.exists(path)) {
#'     stop("File not found at specified path")
#'   }
#'   if (!(is.numeric(sheet) || is.character(sheet)) || length(sheet) != 1) {
#'     stop("'sheet' must be a single integer or character value")
#'   }
#'   if (!is.numeric(skip) || length(skip) != 1 || skip < 0) {
#'     stop("'skip' must be a single non-negative integer")
#'   }
#'
#'   # Read and process data
#'   result <- tryCatch({
#'     readxl::read_excel(path = path, sheet = sheet, skip = skip) %>%
#'       dplyr::rename(
#'         name_geo_level = "NIVGEO",
#'         code = "CODGEO",
#'         label = "LIBGEO",
#'         com_nb = "NB_COM"
#'       ) %>%
#'       dplyr::mutate(name_geo_level = tolower(.data[["name_geo_level"]])) %>%
#'       tidyr::nest(data = c("code", "label", "com_nb"))
#'   }, error = function(e) {
#'     stop("Error processing the Excel file: ", e$message)
#'   })
#'
#'   # Check if the result has the expected structure
#'   if (!all(c("name_geo_level", "data") %in% names(result))) {
#'     stop("The input file doesn't have the expected structure. Check sheet and skip parameters.")
#'   }
#'
#'   return(result)
#' }
#'
#'
#' #' Create a Lookup Table (LUT) for French administrative codes
#' #'
#' #' Generates a named vector lookup table from a data frame containing
#' #' French administrative division codes and labels. The vector values
#' #' contain labels and are named with corresponding codes.
#' #'
#' #' @param data A data frame or tibble containing at least two columns:
#' #'             'code' (administrative division code) and 'label' (division name).
#' #'             Can also accept the nested structure from `create_cog_nested_dict()`.
#' #'
#' #' @return A named character vector where:
#' #'         - Names are administrative codes
#' #'         - Values are corresponding labels
#' #'         - Returns NULL with warning if input is invalid
#' #'
#' #' @details
#' #' This function handles both flat data frames and nested structures (from
#' #' `create_cog_nested_dict()`). For nested data, it extracts the first
#' #' available code-label mapping.
#' #'
#' #' @importFrom rlang is_empty
#' #' @importFrom purrr pluck
#' #' @importFrom stats setNames
#' #'
#' #' @examples
#' #' \dontrun{
#' #' # From a flat data frame
#' #' data <- data.frame(code = c("01", "02"), label = c("Ain", "Aisne"))
#' #' create_COG_lut(data)
#' #'
#' #' # From nested COG data
#' #'   path_to_decoupage_communal_2022 <- insee.admin.data.2022::path_to_extdata(
#' #'     "decoupage-admin/table-appartenance-geo-communes-22.xlsx"
#' #'     )
#' #'   cog_data <- create_cog_nested_dict(path = path_to_decoupage_communal_2022)
#' #'   create_COG_lut(cog_data$data[[1]])
#' #' }
#' #'
#' #' @export
#' create_COG_lut <- function(data) {
#'   # Input validation
#'   if (missing(data) || is.null(data)) {
#'     warning("Input data is missing or NULL")
#'     return(NULL)
#'   }
#'
#'   # Handle nested structure (from create_cog_nested_dict)
#'   if (all(c("name_geo_level", "data") %in% names(data))) {
#'     if (rlang::is_empty(data$data)) {
#'       warning("Nested data contains no code-label mappings")
#'       return(NULL)
#'     }
#'     data <- purrr::pluck(data, "data", 1)
#'   }
#'
#'   # Check for required columns
#'   if (!all(c("code", "label") %in% names(data))) {
#'     warning("Input data must contain 'code' and 'label' columns")
#'     return(NULL)
#'   }
#'
#'   if (nrow(data) == 0) {
#'     warning("Input data contains no rows")
#'     return(NULL)
#'   }
#'
#'   # Check for duplicate codes
#'   dup_codes <- duplicated(data$code)
#'   if (any(dup_codes)) {
#'     dup_examples <- paste(utils::head(unique(data$code[dup_codes])), collapse = ", ")
#'     warning("Duplicate codes detected (e.g.: ", dup_examples,
#'             "). Only first occurrence will be kept.")
#'   }
#'
#'   # Create and return the lookup table
#'   stats::setNames(as.character(data$label),
#'                   as.character(data$code))
#' }
#'
#'
#' ## Fonction de création lut entre code et label, nested par niveau geographique du cog
#' #' Create Nested Lookup Tables for French Administrative Divisions
#' #'
#' #' Generates a nested structure of lookup tables (LUTs) for French administrative codes,
#' #' organized by geographic level. Each LUT is a named vector mapping codes to labels.
#' #'
#' #' @param path Character. Path to the Excel file containing COG data.
#' #' @param sheet Integer or character. Sheet number or name (default: 3).
#' #' @param skip Integer. Number of rows to skip at the beginning (default: 5).
#' #'
#' #' @return A tibble with:
#' #'         - `name_geo_level`: Geographic level name with "_code" suffix
#' #'         - `data`: Lookup table (named vector) mapping codes to labels
#' #'         Returns NULL with warning if any step fails.
#' #'
#' #' @details
#' #' This function combines `create_cog_nested_dict()` and `create_COG_lut()` to create
#' #' a ready-to-use nested structure of lookup tables. The "_code" suffix helps distinguish
#' #' geographic levels when used in joins or merges.
#' #'
#' #' @importFrom dplyr mutate
#' #' @importFrom purrr map
#' #' @importFrom rlang .data
#' #' @importFrom logger log_warn
#' #'
#' #' @examples
#' #' \dontrun{
#' #' # Basic usage
#' #'   path_to_decoupage_communal_2022 <- insee.admin.data.2022::path_to_extdata(
#' #'     "decoupage-admin/table-appartenance-geo-communes-22.xlsx"
#' #'     )
#' #'   nested_luts <- create_cog_nested_lut(path_to_decoupage_communal_2022)
#' #'
#' #' # Accessing a specific LUT
#' #' region_lut <- nested_luts$data[[4]]
#' #' }
#' #'
#' #' @seealso \code{\link{create_cog_nested_dict}}, \code{\link{create_COG_lut}}
#' #' @export
#' create_cog_nested_lut <- function(path, sheet = 3L, skip = 5) {
#'   tryCatch({
#'     # Create nested dictionary
#'     nested_dict <- create_cog_nested_dict(path = path, sheet = sheet, skip = skip)
#'
#'     # Validate the nested dictionary structure
#'     if (is.null(nested_dict)) {
#'       stop("Failed to create nested dictionary")
#'     }
#'
#'     # Apply LUT creation to each nested dataset
#'     result <- nested_dict %>%
#'       dplyr::mutate(
#'         data = purrr::map(.data$data, function(x) {
#'           lut <- create_COG_lut(x)
#'           if (is.null(lut)) {
#'             logger::log_warn("Failed to create LUT for one geographic level")
#'           }
#'           lut
#'         }),
#'         name_geo_level = paste0(.data$name_geo_level, "_code")
#'       )
#'
#'     # Verify at least one LUT was created successfully
#'     if (all(purrr::map_lgl(result$data, is.null))) {
#'       stop("All LUT creations failed")
#'     }
#'
#'     # Add class for better printing
#'     class(result) <- c("cog_nested_lut", class(result))
#'
#'     return(result)
#'
#'     }, error = function(e) {
#'     logger::log_warn("create_cog_nested_lut failed: {e$message}")
#'     return(NULL)
#'   }
#'   )
#' }
#'
#'
#' ## Extract individual cog lut for a given geo level thanks to name_geo_level
#' #' Extract Individual COG Lookup Table by Geographic Level
#' #'
#' #' Retrieves a specific lookup table (LUT) from a nested COG structure based on the geographic level name.
#' #'
#' #' @param cog_nested_lut A nested COG lookup table object created by \code{create_cog_nested_lut()}
#' #' @param unique_geo_level Character. The geographic level name to extract (with "_code" suffix).
#' #'                        Can be either the full name (e.g., "regions_code") or without suffix.
#' #'
#' #' @return A named character vector (LUT) mapping codes to labels for the requested geographic level.
#' #'         Returns NULL with warning if:
#' #'         - Input is invalid
#' #'         - Requested geographic level not found
#' #'         - LUT is empty
#' #'
#' #' @details
#' #' The function automatically handles geographic level names with or without the "_code" suffix.
#' #' It provides informative messages when the requested level isn't found or when the LUT is empty.
#' #'
#' #' @importFrom dplyr filter pull
#' #' @importFrom rlang .data
#' #' @importFrom logger log_warn
#' #' @importFrom glue glue
#' #' @importFrom stringr str_ends
#' #'
#' #' @examples
#' #' \dontrun{
#' #' nested_luts <- create_cog_nested_lut("path/to/file.xlsx")
#' #'
#' #' # Both versions work:
#' #' regions <- extract_individual_cog_lut(nested_luts, "regions_code")
#' #' depts <- extract_individual_cog_lut(nested_luts, "departements")
#' #' }
#' #'
#' #' @seealso \code{\link{create_cog_nested_lut}}
#' #' @export
#' extract_individual_cog_lut <- function(cog_nested_lut, unique_geo_level) {
#'   # Input validation
#'   if (missing(cog_nested_lut) || is.null(cog_nested_lut)) {
#'     logger::log_warn("No nested LUT provided")
#'     return(NULL)
#'   }
#'
#'   if (missing(unique_geo_level)) {
#'     logger::log_warn("No geographic level specified")
#'     return(NULL)
#'   }
#'
#'   if (!inherits(cog_nested_lut, "data.frame") ||
#'       !all(c("name_geo_level", "data") %in% names(cog_nested_lut))) {
#'     logger::log_warn("Input doesn't appear to be a valid nested COG LUT object")
#'     return(NULL)
#'   }
#'
#'   # Normalize geo level name (add _code suffix if missing)
#'   if (!stringr::str_ends(unique_geo_level, "_code")) {
#'     unique_geo_level <- paste0(unique_geo_level, "_code")
#'   }
#'
#'   tryCatch({
#'     # Extract the requested LUT
#'     result <- cog_nested_lut %>%
#'       dplyr::filter(.data$name_geo_level == !!unique_geo_level) %>%
#'       dplyr::pull(.data$data) %>%
#'       purrr::pluck(1)
#'
#'     # Check if extraction was successful
#'     if (is.null(result)) {
#'       available_levels <- paste(cog_nested_lut$name_geo_level, collapse = ", ")
#'       logger::log_warn(glue::glue(
#'         "Requested geographic level '{unique_geo_level}' not found. ",
#'         "Available levels: {available_levels}"
#'       ))
#'       return(NULL)
#'     }
#'
#'     # Check if LUT is empty
#'     if (length(result) == 0) {
#'       logger::log_warn(glue::glue(
#'         "Lookup table for '{unique_geo_level}' is empty"
#'       ))
#'       return(NULL)
#'     }
#'
#'     # Add class and attributes for better tracking
#'     class(result) <- c("cog_lut", class(result))
#'     attr(result, "geo_level") <- unique_geo_level
#'
#'     return(result)
#'
#'   }, error = function(e) {
#'     logger::log_warn(glue::glue(
#'       "Error extracting LUT for '{unique_geo_level}': {e$message}"
#'     ))
#'     return(NULL)
#'   })
#' }
#'
#'
#' #' Augment Data with Administrative Labels from Codes
#' #'
#' #' Adds administrative division labels to a dataset by looking up codes in COG lookup tables.
#' #' For each column containing codes, creates a new column with corresponding labels.
#' #'
#' #' @param data A data frame or tibble containing administrative codes
#' #' @param cog_nested_lut A nested COG lookup table from `create_cog_nested_lut()`
#' #' @param .cols Columns to process (tidy selection, default: all columns)
#' #' @param suffix Character suffix to add for label columns (default: "label")
#' #'
#' #' @return The input data frame with additional columns containing administrative labels.
#' #'         Original columns remain unchanged. If lookup fails for a column, returns NA values
#' #'         with a warning.
#' #'
#' #' @details
#' #' For each specified column containing codes (e.g., "region_code"), creates a new column
#' #' with corresponding labels (e.g., "region_label"). The function automatically handles:
#' #' - Different geographic levels (regions, departments, etc.)
#' #' - Missing or invalid codes
#' #' - Columns that don't have corresponding lookup tables
#' #'
#' #' @importFrom dplyr across everything mutate rename_with
#' #' @importFrom tidyselect eval_select
#' #' @importFrom rlang .data abort warn inform
#' #' @importFrom glue glue
#' #' @importFrom purrr possibly
#' #'
#' #' @examples
#' #' \dontrun{
#' #' # Basic usage
#' #' data <- tibble(region_code = c("11", "24"), dep_code = c("75", "13"))
#' #' nested_lut <- create_cog_nested_lut("path/to/file.xlsx")
#' #' augment_admin_label_from_code(data, nested_lut)
#' #'
#' #' # Process specific columns
#' #' augment_admin_label_from_code(data, nested_lut, .cols = starts_with("dep"))
#' #' }
#' #'
#' #' @seealso \code{\link{create_cog_nested_lut}}, \code{\link{extract_individual_cog_lut}}
#' #' @export
#' augment_admin_label_from_code <- function(data, cog_nested_lut,
#'                                           .cols = dplyr::everything(),
#'                                           suffix = "label") {
#'   # Input validation
#'   if (missing(data) || !is.data.frame(data)) {
#'     rlang::abort("Input data must be a data frame")
#'   }
#'
#'   if (missing(cog_nested_lut) || is.null(cog_nested_lut)) {
#'     rlang::abort("No COG lookup table provided")
#'   }
#'
#'   # Safe version of extract_individual_cog_lut that returns NULL on failure
#'   safe_extract <- purrr::possibly(extract_individual_cog_lut, otherwise = NULL)
#'
#'   # Get selected columns
#'   cols <- tidyselect::eval_select(rlang::enquo(.cols), data)
#'   if (length(cols) == 0) {
#'     rlang::warn("No columns selected for processing")
#'     return(data)
#'   }
#'
#'   # Process each column
#'   data %>%
#'     dplyr::mutate(
#'       dplyr::across(
#'         .cols = dplyr::all_of(names(cols)),
#'         .fns = ~ {
#'           lut <- safe_extract(cog_nested_lut, dplyr::cur_column())
#'           if (is.null(lut)) {
#'             rlang::warn(glue::glue(
#'               "No lookup table found for column '{dplyr::cur_column()}'"
#'             ))
#'             return(rep(NA_character_, length(.x)))
#'           }
#'           unname(lut[as.character(.x)])
#'         },
#'         .names = "{sub('code', {suffix}, {.col})}"
#'         # .names = "{sub('code', 'label', col)}"
#'         # .names = "{.col}_{suffix}"
#'       )
#'     ) %>%
#'     # Reorder columns to keep original + new label columns together
#'     dplyr::relocate(
#'       dplyr::ends_with(paste0("_", suffix)),
#'       .after = dplyr::all_of(names(cols))
#'     )
#' }
#'
#'
#' #' Augment Data with Administrative Labels from Codes
#' #'
#' #' Adds administrative division labels to a dataset by looking up codes in COG lookup tables.
#' #' Transforms columns with '_code' suffix into corresponding '_label' columns.
#' #'
#' #' @param data A data frame or tibble containing administrative codes
#' #' @param cog_nested_lut A nested COG lookup table from `create_cog_nested_lut()`
#' #' @param .cols Columns to process (tidy selection, default: all columns)
#' #' @param code_suffix Suffix identifying code columns (default: "code")
#' #' @param label_suffix Suffix for new label columns (default: "label")
#' #'
#' #' @return The input data frame with new label columns (replacing '_code' with '_label')
#' #'
#' #' @importFrom dplyr across mutate rename_with
#' #' @importFrom tidyselect eval_select
#' #' @importFrom stringr str_replace
#' #' @importFrom rlang .data abort warn
#' #' @importFrom glue glue
#' #' @importFrom purrr possibly
#' #'
#' #' @examples
#' #' \dontrun{
#' #' data <- tibble(region_code = c("11", "24"), dep_code = c("75", "13"))
#' #' nested_lut <- create_cog_nested_lut("path/to/file.xlsx")
#' #' augment_admin_label_from_code_2(data, nested_lut)
#' #' # Returns data with region_label and dep_label columns
#' #' }
#' #'
#' #' @export
#' augment_admin_label_from_code_2 <- function(data, cog_nested_lut,
#'                                           .cols = dplyr::everything(),
#'                                           code_suffix = "code",
#'                                           label_suffix = "label") {
#'
#'   # Validate inputs
#'   if (!is.data.frame(data)) rlang::abort("Input data must be a data frame")
#'   if (is.null(cog_nested_lut)) rlang::abort("COG lookup table cannot be NULL")
#'
#'   # Create safe extraction function
#'   safe_extract <- purrr::possibly(extract_individual_cog_lut, otherwise = NULL)
#'
#'   # Select and validate columns
#'   cols <- tidyselect::eval_select(rlang::enquo(.cols), data)
#'   col_names <- names(cols)
#'
#'   # Process each column
#'   result <- data %>%
#'     dplyr::mutate(dplyr::across(
#'       .cols = dplyr::all_of(col_names),
#'       .fns = ~ {
#'         # Extract base name without suffix
#'         base_name <- stringr::str_replace(dplyr::cur_column(),
#'                                           paste0("_", code_suffix, "$"), "")
#'
#'         # Get lookup table
#'         lut <- safe_extract(cog_nested_lut, base_name)
#'         if (is.null(lut)) {
#'           rlang::warn(glue::glue("No LUT found for {dplyr::cur_column()}"))
#'           return(rep(NA_character_, length(.x)))
#'         }
#'         unname(lut[as.character(.x)])
#'       },
#'       .names = "{stringr::str_replace(.col, paste0('_', code_suffix),
#'                paste0('_', label_suffix))}"
#'     ))
#'
#'   # Reorder columns to keep original + new label columns together
#'   label_cols <- stringr::str_replace(col_names,
#'                                      paste0("_", code_suffix),
#'                                      paste0("_", label_suffix))
#'
#'   result %>%
#'     dplyr::relocate(dplyr::all_of(label_cols),
#'                     .after = dplyr::all_of(col_names))
#' }
