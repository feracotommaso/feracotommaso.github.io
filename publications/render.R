# The CV workbook remains the only source of publication content.
# Read the current GitHub version at each render; never silently reuse old data.
read_selected_publications <- function(path = NULL) {
  if (!requireNamespace("readxl", quietly = TRUE)) {
    stop("Install readxl before rendering: install.packages('readxl')")
  }
  if (is.null(path)) {
    path <- tempfile(fileext = ".xlsx")
    on.exit(unlink(path), add = TRUE)
    url <- "https://raw.githubusercontent.com/feracotommaso/cv/main/data/cv.xlsx"
    tryCatch(
      utils::download.file(url, path, mode = "wb", quiet = TRUE),
      error = function(e) stop("Could not retrieve the CV workbook from GitHub. Check your connection and render again.\n", conditionMessage(e))
    )
  }
  pubs <- readxl::read_excel(path, sheet = "publications")
  selection <- intersect(c("selected_pubs", "selected_pub"), names(pubs))
  required <- c("publication_id", "year", "citation_en", "abstract")
  missing <- setdiff(required, names(pubs))
  if (!length(selection) || length(missing)) {
    stop("The publications sheet needs selected_pub (or selected_pubs) and: ", paste(required, collapse = ", "))
  }
  selected <- tolower(trimws(as.character(pubs[[selection[1]]]))) %in% c("yes", "true", "1", "x")
  pubs <- pubs[selected, , drop = FALSE]
  if (anyNA(pubs$publication_id) || anyDuplicated(pubs$publication_id)) {
    stop("Selected publications must have unique, non-empty publication_id values.")
  }
  if (anyNA(pubs$citation_en) || any(!nzchar(trimws(pubs$citation_en)))) {
    stop("Each selected publication needs an English citation.")
  }
  sort_order <- if ("order" %in% names(pubs)) suppressWarnings(as.numeric(pubs$order)) else seq_len(nrow(pubs))
  pubs[order(-as.numeric(pubs$year), -sort_order, na.last = TRUE), , drop = FALSE]
}

publication_text <- function(value) {
  if (is.null(value) || !length(value) || is.na(value)) "" else trimws(as.character(value))
}

publication_url <- function(value) {
  value <- publication_text(value)
  if (grepl("^https?://[^[:space:]<>]+$", value, ignore.case = TRUE)) value else ""
}

render_selected_publications <- function(path = NULL) {
  # Some Windows sessions inherit an unsupported C.UTF-8 locale and fall back
  # to ASCII. knitr would then print accents as literal <U+....> sequences.
  if (.Platform$OS.type == "windows" && !l10n_info()[["UTF-8"]]) {
    Sys.setlocale("LC_CTYPE", "English_United States.utf8")
  }
  pubs <- read_selected_publications(path)
  if (!nrow(pubs)) {
    cat("No selected publications yet.\n")
    return(invisible(pubs))
  }
  resources <- c(doi_url = "Article", data_url = "Open data", code_url = "Open code",
                 materials_url = "Open materials", preregistration_url = "Preregistration")
  icons <- c(doi_url = "article.svg", data_url = "open-data.png", code_url = "open-code.png",
             materials_url = "open-materials.png", preregistration_url = "preregistered.png")
  for (i in seq_len(nrow(pubs))) {
    pub <- pubs[i, , drop = FALSE]
    citation <- gsub("[\r\n]+", " ", publication_text(pub$citation_en))
    # Titles are stored within the citation, between the year and italic journal.
    # Keep the complete citation if a future entry uses another format.
    parts <- regmatches(citation, regexec("^(.*?)\\s*\\(([^)]+)\\)\\.\\s+(.*?)\\s+([*].*)$", citation, perl = TRUE))[[1]]
    id <- gsub("[^A-Za-z0-9_-]", "-", pub$publication_id)
    cat("\n::: {#", id, " .publication-card}\n\n", sep = "")
    cat("::: {.publication-year}\n", publication_text(pub$year), "\n:::\n\n", sep = "")
    if (length(parts) == 5) {
      title <- sub("\\.$", "", parts[4])
      journal <- sub("\\s*\\[https?://.*$", "", parts[5])
      cat("## ", title, " {.publication-title .unnumbered}\n\n", sep = "")
      cat("::: {.publication-authors}\n", parts[2], "\n:::\n\n", sep = "")
      cat("::: {.publication-journal}\n", journal, "\n:::\n\n", sep = "")
    } else {
      cat("::: {.publication-citation}\n", citation, "\n:::\n\n", sep = "")
    }
    abstract <- publication_text(pub$abstract)
    if (nzchar(abstract)) {
      # Native disclosure works with the mouse, keyboard, and without JavaScript.
      abstract <- gsub("&", "&amp;", abstract, fixed = TRUE)
      abstract <- gsub("<", "&lt;", abstract, fixed = TRUE)
      abstract <- gsub(">", "&gt;", abstract, fixed = TRUE)
      paragraphs <- strsplit(abstract, "\n\\s*\n", perl = TRUE)[[1]]
      cat("```{=html}\n<details class=\"publication-abstract\">\n<summary>Abstract</summary>\n",
          paste0("<p>", paragraphs, "</p>", collapse = "\n"),
          "\n</details>\n```\n\n", sep = "")
    }
    links <- character()
    for (field in names(resources)) {
      url <- publication_url(pub[[field]])
      if (nzchar(url)) {
        url <- gsub('"', "&quot;", gsub("&", "&amp;", url, fixed = TRUE), fixed = TRUE)
        label <- resources[[field]]
        links <- c(links, sprintf(
          '<a href="%s" class="publication-resource" title="%s" aria-label="%s"><img src="img/publications/%s" alt="" aria-hidden="true" width="40" height="40"><span class="visually-hidden">%s</span></a>',
          url, label, label, icons[[field]], label
        ))
      }
    }
    if (length(links)) cat('```{=html}\n<div class="publication-links">\n', paste(links, collapse = "\n"), "\n</div>\n```\n\n", sep = "")
    cat(":::\n\n")
  }
  invisible(pubs)
}
