# Selected publications

`selected-publications.qmd` is a regular page in the existing Quarto website.
It inherits the site theme and navigation and renders to
`docs/selected-publications.html`. It needs R, knitr, and readxl, alongside the
existing Quarto installation.

The only publication content to edit is the `publications` sheet of
`data/cv.xlsx` in https://github.com/feracotommaso/cv.
Mark records `Yes` in `selected_pub` (the reader also supports `selected_pubs`).
The page uses `citation_en`, `year`, `abstract`, `doi_url`, `data_url`,
`code_url`, `materials_url`, and `preregistration_url`. Titles, authors, and
journals are extracted from the English citations; citations with a different
format are shown in full. Publications are sorted by descending year, then
descending `order`. Missing resource URLs are omitted.

Render and publish using the site's existing workflow:

```sh
quarto render
```

Commit and push the source changes and the generated `docs/` output as usual.
There is no additional generation command or separate hosting service.

Only this page disables execution freezing and caching: every render downloads
the current workbook from GitHub. An internet connection is required; download
errors stop the render rather than silently publishing stale content. Changes
to the workbook become visible after rendering and publishing the website.

The search runs locally on the generated cards and matches title, authors,
journal, year, abstract, and resource labels. Multiple words must all match;
matching ignores capitalization and accents. The original cards remain readable
when JavaScript is disabled.

Cards use three columns on desktop, two below 1100px, and one below 640px.
Abstracts are closed by default and expand through native `details` / `summary`
controls, including when JavaScript is disabled. Search includes closed abstracts.

Resource links use local icons in `img/publications/`, with hover titles and
accessible labels. The four Open Science PNGs are reused unchanged from
`assets/badges/` in the CV repository. The article SVG is drawn for this website.
