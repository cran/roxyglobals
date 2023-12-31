test_that("global_roclet() works", {
  roclet_out <- roxygen2::roc_proc_text(
    global_roclet(),
    paste_line(
      "#' @global foo bar",
      "fn1 <- function() {}",
      "#' @autoglobal",
      "fn2 <- function(x) { dplyr::select(x, foobar) }",
      "#' @name fn3",
      "#' @global foofy",
      "NULL"
    )
  )

  expect_identical(
    skip(roclet_out, 2),
    global_variables(
      "\"foo\", # <fn1>",
      "\"bar\", # <fn1>",
      "\"foobar\", # <fn2>",
      "\"foofy\", # <fn3>"
    )
  )
})

test_that("global_roclet() handles empty", {
  expect_identical(
    skip(roxygen2::roc_proc_text(global_roclet(), ""), 2),
    c(
      "utils::globalVariables(c(",
      "  NULL",
      "))"
    )
  )
})

test_that("global_roclet() emits generated by", {
  expect_identical(
    first(roxygen2::roc_proc_text(global_roclet(), "")),
    "# Generated by roxyglobals: do not edit by hand"
  )
})

test_that("global_roclet() writes unique globals", {
  pkg_path <- local_package_copy(test_path("./config-unique"))
  globals_file <- file.path(pkg_path, "R", "globals.R")

  suppressMessages(roxygen2::roxygenise(pkg_path))

  expect_identical(
    skip(brio::read_lines(globals_file), 2),
    global_variables(
      "# <automode>",
      "# <automode_duplicate>",
      "\"my_key\",",
      "# <automode>",
      "# <automode_duplicate>",
      "\"something\",",
      "# <manualmode>",
      "# <manualmode_duplicate>",
      "\"that\",",
      "# <manualmode>",
      "# <manualmode_duplicate>",
      "\"this\",",
      "# <manualmode>",
      "# <manualmode_duplicate>",
      "\"thistoo\",",
      "# <nofunction>",
      "# <nofunction_duplicate>",
      "\"thisworks\","
    )
  )
})

test_that("global_roclet() writes to custom filename", {
  pkg_path <- local_package_copy(test_path("./config-filename"))
  globals_file <- file.path(pkg_path, "R", "generated-globals.R")

  suppressMessages(roxygen2::roxygenise(pkg_path))

  expect_identical(
    skip(brio::read_lines(globals_file), 2),
    c(
      "utils::globalVariables(c(",
      "  \"my_key\", # <automode>",
      "  \"something\", # <automode>",
      "  \"thisworks\", # <nofunction>",
      "  \"this\", # <manualmode>",
      "  \"that\", # <manualmode>",
      "  \"thistoo\", # <manualmode>",
      "  NULL",
      "))"
    )
  )
})

test_that("global_roclet() cleans globals file", {
  pkg_path <- local_package_copy(test_path("./empty"))
  globals_file <- file.path(pkg_path, "R", "globals.R")

  roxygen2::roclet_clean(global_roclet(), pkg_path)
  expect_false(
    file.exists(globals_file)
  )

  # ensure file exists
  suppressMessages(roxygen2::roxygenise(pkg_path, clean = TRUE))

  roxygen2::roclet_clean(global_roclet(), pkg_path)
  expect_false(
    file.exists(globals_file)
  )
})
