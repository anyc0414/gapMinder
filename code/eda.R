# Gapminder exploratory data analysis

input_file <- "gapminder_clean.csv"
output_dir <- "eda_outputs"
dir.create(output_dir, showWarnings = FALSE)

gap <- read.csv(input_file, stringsAsFactors = FALSE)

required_cols <- c(
  "country", "continent", "year", "lifeexp", "pop", "gdppercap",
  "iso_alpha", "iso_num"
)
missing_cols <- setdiff(required_cols, names(gap))
if (length(missing_cols) > 0) {
  stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
}

gap$continent <- factor(gap$continent)
gap$year <- as.integer(gap$year)
gap$pop <- as.numeric(gap$pop)
gap$lifeexp <- as.numeric(gap$lifeexp)
gap$gdppercap <- as.numeric(gap$gdppercap)
gap$log_gdppercap <- log10(gap$gdppercap)

fmt_num <- function(x, digits = 2) {
  format(round(x, digits), big.mark = ",", trim = TRUE, nsmall = digits)
}

fmt_int <- function(x) {
  format(round(x, 0), big.mark = ",", trim = TRUE, scientific = FALSE)
}

make_numeric_summary <- function(data, cols) {
  out <- do.call(
    rbind,
    lapply(cols, function(col) {
      x <- data[[col]]
      data.frame(
        variable = col,
        count = sum(!is.na(x)),
        mean = mean(x, na.rm = TRUE),
        sd = sd(x, na.rm = TRUE),
        min = min(x, na.rm = TRUE),
        q25 = as.numeric(quantile(x, 0.25, na.rm = TRUE)),
        median = median(x, na.rm = TRUE),
        q75 = as.numeric(quantile(x, 0.75, na.rm = TRUE)),
        max = max(x, na.rm = TRUE),
        stringsAsFactors = FALSE
      )
    })
  )
  rownames(out) <- NULL
  out
}

numeric_summary <- make_numeric_summary(gap, c("lifeexp", "pop", "gdppercap"))

continent_summary <- aggregate(
  cbind(lifeexp, pop, gdppercap) ~ continent,
  data = gap,
  FUN = mean
)
continent_summary$country_count <- as.integer(
  tapply(gap$country, gap$continent, function(x) length(unique(x)))[
    as.character(continent_summary$continent)
  ]
)
continent_summary <- continent_summary[
  order(continent_summary$lifeexp, decreasing = TRUE),
  c("continent", "country_count", "lifeexp", "pop", "gdppercap")
]
rownames(continent_summary) <- NULL

year_summary <- aggregate(
  cbind(lifeexp, pop, gdppercap) ~ year,
  data = gap,
  FUN = mean
)
year_summary <- year_summary[order(year_summary$year), ]
year_summary$total_pop <- as.numeric(tapply(gap$pop, gap$year, sum))
year_summary$total_pop <- year_summary$total_pop[
  match(year_summary$year, names(tapply(gap$pop, gap$year, sum)))
]
rownames(year_summary) <- NULL

latest_year <- max(gap$year, na.rm = TRUE)
first_year <- min(gap$year, na.rm = TRUE)
latest <- gap[gap$year == latest_year, ]
first <- gap[gap$year == first_year, ]

top_lifeexp <- latest[order(latest$lifeexp, decreasing = TRUE), ]
top_lifeexp <- head(top_lifeexp[, c("country", "continent", "lifeexp", "gdppercap", "pop")], 10)

low_lifeexp <- latest[order(latest$lifeexp), ]
low_lifeexp <- head(low_lifeexp[, c("country", "continent", "lifeexp", "gdppercap", "pop")], 10)

top_gdp <- latest[order(latest$gdppercap, decreasing = TRUE), ]
top_gdp <- head(top_gdp[, c("country", "continent", "gdppercap", "lifeexp", "pop")], 10)

country_change <- merge(
  first[, c("country", "continent", "lifeexp", "gdppercap", "pop")],
  latest[, c("country", "lifeexp", "gdppercap", "pop")],
  by = "country",
  suffixes = c("_first", "_latest")
)
country_change$lifeexp_change <- country_change$lifeexp_latest - country_change$lifeexp_first
country_change$gdppercap_ratio <- country_change$gdppercap_latest / country_change$gdppercap_first
country_change$pop_ratio <- country_change$pop_latest / country_change$pop_first
country_change <- country_change[order(country_change$lifeexp_change, decreasing = TRUE), ]

write.csv(numeric_summary, file.path(output_dir, "numeric_summary.csv"), row.names = FALSE)
write.csv(continent_summary, file.path(output_dir, "continent_summary.csv"), row.names = FALSE)
write.csv(year_summary, file.path(output_dir, "year_summary.csv"), row.names = FALSE)
write.csv(top_lifeexp, file.path(output_dir, "top_lifeexp_latest.csv"), row.names = FALSE)
write.csv(low_lifeexp, file.path(output_dir, "low_lifeexp_latest.csv"), row.names = FALSE)
write.csv(top_gdp, file.path(output_dir, "top_gdp_latest.csv"), row.names = FALSE)
write.csv(head(country_change, 10), file.path(output_dir, "top_lifeexp_growth.csv"), row.names = FALSE)

png(file.path(output_dir, "lifeexp_by_year.png"), width = 1100, height = 700)
plot(
  year_summary$year, year_summary$lifeexp,
  type = "o", pch = 19, col = "#2563eb", lwd = 2,
  xlab = "Year", ylab = "Average life expectancy",
  main = "Global Average Life Expectancy by Year"
)
grid()
dev.off()

png(file.path(output_dir, "gdp_lifeexp_scatter_latest.png"), width = 1100, height = 700)
continent_cols <- setNames(
  c("#2563eb", "#16a34a", "#dc2626", "#9333ea", "#f59e0b"),
  levels(gap$continent)
)
plot(
  latest$gdppercap, latest$lifeexp,
  log = "x", pch = 19,
  col = continent_cols[as.character(latest$continent)],
  xlab = "GDP per capita, log scale",
  ylab = "Life expectancy",
  main = paste("GDP per Capita and Life Expectancy in", latest_year)
)
legend(
  "bottomright", legend = names(continent_cols), col = continent_cols,
  pch = 19, bty = "n"
)
grid()
dev.off()

png(file.path(output_dir, "continent_lifeexp_boxplot.png"), width = 1100, height = 700)
boxplot(
  lifeexp ~ continent,
  data = gap,
  col = "#dbeafe",
  border = "#1e3a8a",
  xlab = "Continent",
  ylab = "Life expectancy",
  main = "Life Expectancy Distribution by Continent"
)
grid()
dev.off()

png(file.path(output_dir, "population_by_continent_latest.png"), width = 1100, height = 700)
latest_pop_by_continent <- tapply(latest$pop, latest$continent, sum)
barplot(
  latest_pop_by_continent / 1e9,
  col = "#86efac",
  border = "#166534",
  xlab = "Continent",
  ylab = "Population, billions",
  main = paste("Total Population by Continent in", latest_year)
)
grid()
dev.off()

to_md_table <- function(data, digits = 2) {
  data2 <- data
  for (nm in names(data2)) {
    if (is.numeric(data2[[nm]])) {
      if (nm %in% c("pop", "total_pop", "country_count", "count", "iso_num")) {
        data2[[nm]] <- fmt_int(data2[[nm]])
      } else {
        data2[[nm]] <- fmt_num(data2[[nm]], digits)
      }
    }
  }
  header <- paste0("| ", paste(names(data2), collapse = " | "), " |")
  sep <- paste0("|", paste(rep("---", ncol(data2)), collapse = "|"), "|")
  rows <- apply(data2, 1, function(row) paste0("| ", paste(row, collapse = " | "), " |"))
  paste(c(header, sep, rows), collapse = "\n")
}

cor_life_gdp <- cor(gap$lifeexp, gap$log_gdppercap, use = "complete.obs")
lifeexp_gain <- mean(latest$lifeexp) - mean(first$lifeexp)
gdp_ratio <- mean(latest$gdppercap) / mean(first$gdppercap)
pop_ratio <- sum(latest$pop) / sum(first$pop)

report <- c(
  "# Gapminder EDA Report",
  "",
  "## Overview",
  "",
  paste0("- Rows: ", fmt_int(nrow(gap))),
  paste0("- Countries: ", fmt_int(length(unique(gap$country)))),
  paste0("- Continents: ", paste(levels(gap$continent), collapse = ", ")),
  paste0("- Year range: ", first_year, " to ", latest_year),
  paste0("- Missing values: ", fmt_int(sum(is.na(gap)))),
  "",
  "## Key Findings",
  "",
  paste0("- Average life expectancy increased by ", fmt_num(lifeexp_gain), " years from ", first_year, " to ", latest_year, "."),
  paste0("- Average GDP per capita became ", fmt_num(gdp_ratio), " times larger over the same period."),
  paste0("- Total population became ", fmt_num(pop_ratio), " times larger over the same period."),
  paste0("- The correlation between life expectancy and log10 GDP per capita is ", fmt_num(cor_life_gdp), "."),
  paste0("- In ", latest_year, ", the highest average life expectancy appears in countries such as ", paste(head(top_lifeexp$country, 3), collapse = ", "), "."),
  "",
  "## Numeric Summary",
  "",
  to_md_table(numeric_summary),
  "",
  "## Continent Summary",
  "",
  to_md_table(continent_summary),
  "",
  paste0("## Top 10 Life Expectancy Countries in ", latest_year),
  "",
  to_md_table(top_lifeexp),
  "",
  paste0("## Lowest 10 Life Expectancy Countries in ", latest_year),
  "",
  to_md_table(low_lifeexp),
  "",
  "## Generated Plots",
  "",
  "### Average Life Expectancy Trend",
  "",
  "![Average life expectancy trend](lifeexp_by_year.png)",
  "",
  "### GDP per Capita and Life Expectancy",
  "",
  "![GDP per capita and life expectancy in latest year](gdp_lifeexp_scatter_latest.png)",
  "",
  "### Life Expectancy by Continent",
  "",
  "![Life expectancy distribution by continent](continent_lifeexp_boxplot.png)",
  "",
  "### Population by Continent",
  "",
  "![Latest-year population by continent](population_by_continent_latest.png)"
)

writeLines(report, file.path(output_dir, "eda_report.md"))

cat("EDA complete.\n")
cat("Report:", file.path(output_dir, "eda_report.md"), "\n")
cat("Outputs:", output_dir, "\n")
