
url_p1<-"https://www2.census.gov/programs-surveys/popest/tables/2000-2010/intercensal/county/co-est00int-01-"

state_fips <- c(
  "01", "02", "04", "05", "06", "08", "09", "10", "11", "12", 
  "13", "15", "16", "17", "18", "19", "20", "21", "22", "23", 
  "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", 
  "34", "35", "36", "37", "38", "39", "40", "41", "42", "44", 
  "45", "46", "47", "48", "49", "50", "51", "53", "54", "55", "56"
)

county_pop<-data.frame(c(NA),c(NA),c(NA),c(NA))
colnames(county_pop)<-c("Area","2000Pop","2005Pop","2010Pop")

for(i in state_fips){
  url<-paste(url_p1, i, ".xls",sep="")
  download.file(url,"mydata.xls")
  
  temp<- read_excel("mydata.xls")
  temp<-temp[,c(1,2,8,13)]
  colnames(temp)<-colnames(county_pop)
  temp <- temp[-c(1:3, (nrow(temp) - 7):nrow(temp)), ]
  temp$Area<-ifelse(substr(temp$Area, 1, 1) == ".",
                    substr(temp$Area, 2, nchar(temp$Area)),
                    temp$Area)
  county_pop<-rbind(county_pop,temp)
  
}


county_pop<-county_pop[-c(1),]
write.csv(county_pop,"census_pop.csv",row.names = FALSE)

