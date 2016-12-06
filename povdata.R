library(plyr)
library(dplyr)
  ## Load in tables
fips <- read.csv("./fips_codes_website.csv", header = TRUE, stringsAsFactors = FALSE)
portcities <- read.csv("./Tableau Sheet.csv", header = TRUE, stringsAsFactors = FALSE,
                       na.strings = c(""," ", "??"))


  ## force city names to lower case and create table of unique city names
  ## from the table of Heron's holdings.
fips$GU.Name <- tolower(fips$GU.Name)
fips <- fips[,c(1,2,3,6)]
portcities$Property.City <- as.character(tolower(portcities$Property.City))

  ## isolate to state/city and remove duplicates, remove NAs
cities <- unique(portcities[,6:7])
cities <- cities[!is.na(cities$Property.City),]

  ## match with fips code
citycode <- merge(cities,fips,by.x = c("Property.City","Prop..State"), 
                  by.y = c("GU.Name","State.Abbreviation"))

needfips <- unique(citycode$County.FIPS.Code) 
  #set up connection to Census API
key <- "&key=97d55623ee041618526d685d56a340986817ea2c"
baseurl <- "http://api.census.gov/data/2015/acs1/profile?get="
variables <- c("DP03_0119E,","DP03_0092M,")

  ##run for loop on
mylist <- list()
for (i in needfips){
  fipsdata <- filter(citycode, County.FIPS.Code == i)
  fipsstate <- fips[,3]
df <- fromJSON(paste0(baseurl,variables,"NAME&for=county:",i,"&in=state:",fipsstate,key,".json"))
mylist[[i]] <- df
}
dfall <- do.call("rbind",mylist)

