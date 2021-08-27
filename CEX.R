library(readr)
library(dplyr)
library(ggplot2)

food <- data.frame(matrix(ncol = 0, nrow = 1))
house <- data.frame(matrix(ncol = 0, nrow = 1))
for(year_counter in 7:16){
  if(year_counter<10){
    year_string<-paste("0",year_counter,sep="")
  }else{
    year_string<-year_counter
  }
  url<-paste("https://www.bls.gov/cex/pumd/data/comma/intrvw",year_string,".zip", sep="")
  download.file(url,"mydata.zip")
  unzip("mydata.zip")
  file.remove("mydata.zip")
  for(file_counter in 1:4){
    if(file_counter==1){
      file_str<-paste("intrvw",year_string,"/fmli",year_string,file_counter,"x.csv",sep="")
    }else {
      file_str<-paste("intrvw",year_string,"/fmli",year_string,file_counter,".csv",sep="")
    }
    temp <- read_csv(file_str)
    temp_h <-data.frame(temp$HOUSCQ)
    colnames(temp_h)<-(paste(year_string,file_counter,sep="-"))
    temp_f <-data.frame(temp$FOODCQ)
    colnames(temp_f)<-(paste(year_string,file_counter,sep="-"))
    house<-merge(house,temp_h,all=TRUE,by=0)
    house<-subset(house,select=-c(Row.names))
    food<-merge(food,temp_f,all=TRUE,by=0)
    food<-subset(food,select=-c(Row.names))
  }
  unlink(paste("expn",year_string,sep=""),recursive = TRUE)
  unlink(paste("intrvw",year_string,sep=""),recursive = TRUE)
  unlink(paste("para",year_string,sep=""),recursive = TRUE)
}

food[food==0]<-NA
house[house==0]<-NA
food<-data.frame(colMeans(food, na.rm = TRUE))
colnames(food)<-c("mean_food_spending")
food$quarter<-rownames(food)
house<-data.frame(colMeans(house, na.rm = TRUE))
colnames(house)<-c("mean_housing_spending")
house$quarter<-rownames(house)

ggplot(data=house,aes(x=quarter,y=mean_housing_spending))+
  geom_point(shape=8)+
  ylab("CEX average housing spending") + xlab("Quarter")+
  theme(axis.text.x = element_text(angle = 90))

ggplot(data=food,aes(x=quarter,y=mean_food_spending))+
  geom_point(shape=9)+
  ylab("CEX average food spending") + xlab("Quarter")+
  theme(axis.text.x = element_text(angle = 90))
