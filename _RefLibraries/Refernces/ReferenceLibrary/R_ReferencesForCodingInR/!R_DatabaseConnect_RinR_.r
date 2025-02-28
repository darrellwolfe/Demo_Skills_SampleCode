# install.packages("sqldf")
install.packages("Rtools")
install.packages("DBI")

library(tidyverse)
library(Rtools)
library(DBI)


#remove.packages("DBI")
#update.packages("DBI")

#install.packages("tidyverse")
#install.packages("DBI")
#install.packages("odbc")

#library(tidyverse)
#library(DBI)
#library(dplyr)
#library(odbc)



if(!require('DBI')) {
  install.packages('DBI')
  library('DBI')
}


conn <- dbConnect(odbc::odbc(),
                 Driver = "SQL Server",
                 Server = "AsTxDBProd",
                 Database = "GRM_Main",
                 Trusted_Connection = "True")

ag_analysis <- dbGetQuery(conn, " SELECT * FROM table_name WHERE column_name = 'condition' ")

colnames(ag_analysis)
summarise(ag_analysis)
summary(ag_analysis)

sum(ag_analysis$xxx, na.rm = TRUE)
max(ag_analysis$xxx, na.rm = TRUE)
median(ag_analysis$xxx, na.rm = TRUE)
mean(tag_values$Certified_Value, na.rm = TRUE)
min(tag_values$Certified_Value, na.rm = TRUE)


