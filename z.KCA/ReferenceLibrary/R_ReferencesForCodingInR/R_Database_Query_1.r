library(DBI)
con <- dbConnect(odbc::odbc(), "GRM_Main", timeout = 10)
?install.packages("odbc")
?library(odbc)
?odbc
library(tidyverse)

install.packages("RevoScaleR")
install.packages("T-SQL")
library(RevoScaleR)
library("T-SQL")

# https://learn.microsoft.com/en-us/sql/machine-learning/package-management/install-r-packages-standard-tools?view=sql-server-2017
# This isn't working


TSBv_PARCELMASTER <- "pm"

pmquery <- paste0("SELECT * FROM", TSBv_PARCELMASTER)

table_data <- dbGetTable(con, TSBv_PARCELMASTER)

table_data <- dbReadTable(con, TSBv_PARCELMASTER)

