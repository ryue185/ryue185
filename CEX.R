library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)

food <- data.frame(matrix(ncol = 0, nrow = 1))
house <- data.frame(matrix(ncol = 0, nrow = 1))
for(year_counter in 0:18){
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
    if(year_counter<2|year_counter==17){
      if(file_counter==1){
        file_str<-paste("intrvw",year_string,"/intrvw",year_string,"/fmli",year_string,file_counter,"x.csv",sep="")
      }else{
        file_str<-paste("intrvw",year_string,"/intrvw",year_string,"/fmli",year_string,file_counter,".csv",sep="")
      }
    }else if(file_counter==1){
      file_str<-paste("intrvw",year_string,"/fmli",year_string,file_counter,"x.csv",sep="")
    }else{
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
food_mean<-data.frame(colMeans(food, na.rm = TRUE))
colnames(food_mean)<-c("mean_food_spending")
food_mean$quarter<-rownames(food_mean)
house_mean<-data.frame(colMeans(house, na.rm = TRUE))
colnames(house_mean)<-c("mean_housing_spending")
house_mean$quarter<-rownames(house_mean)

GDPDEF_URL<-"https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=GDPDEF&scale=left&cosd=1947-01-01&coed=2021-04-01&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Quarterly&fam=avg&fgst=lin&fgsnd=2020-02-01&line_index=1&transformation=lin&vintage_date=2021-09-02&revision_date=2021-09-02&nd=1947-01-01"
download.file(GDPDEF_URL,"GDPDEF.csv")
GDPDEF<-read.csv("GDPDEF.csv")
file.remove("GDPDEF.csv")
GDPDEF$DATE<-as.Date(GDPDEF$DATE)
GDPDEF$month<-format(GDPDEF$DATE,"%m")
GDPDEF$quarter<-as.integer(as.numeric(GDPDEF$month)/3)+1
GDPDEF$year<-format(GDPDEF$DATE,"%y")
GDPDEF$quarter<-paste(GDPDEF$year,GDPDEF$quarter,sep="-")
GDPDEF<-subset(GDPDEF,select=c("GDPDEF","quarter"))

food_mean<-merge(food_mean,GDPDEF,by="quarter")
food_mean$GDPDEF<-food_mean$GDPDEF/food_mean$GDPDEF[1]
food_mean$mean_food_spending<-food_mean$mean_food_spending/food_mean$GDPDEF
food_mean$mean_food_spending_log<-log(food_mean$mean_food_spending)

house_mean<-merge(house_mean,GDPDEF,by="quarter")
house_mean$GDPDEF<-house_mean$GDPDEF/house_mean$GDPDEF[1]
house_mean$mean_housing_spending<-house_mean$mean_housing_spending/house_mean$GDPDEF
house_mean$mean_housing_spending_log<-log(house_mean$mean_housing_spending)

ggplot(data=house_mean,aes(x=quarter,y=mean_housing_spending))+
  geom_point(shape=8)+
  ylab("CEX average housing spending real base 2000Q1") + xlab("Quarter")+
  theme(axis.text.x = element_text(angle = 90))

ggplot(data=food_mean,aes(x=quarter,y=mean_food_spending))+
  geom_point(shape=9)+
  ylab("CEX average food spending real base 2000Q1") + xlab("Quarter")+
  theme(axis.text.x = element_text(angle = 90))


ggplot(data=house_mean,aes(x=quarter,y=mean_housing_spending_log))+
  geom_point(shape=8)+
  ylab("CEX average housing spending log 2000Q1") + xlab("Quarter")+
  theme(axis.text.x = element_text(angle = 90))

ggplot(data=food_mean,aes(x=quarter,y=mean_food_spending_log))+
  geom_point(shape=9)+
  ylab("CEX average food spending log 2000Q1") + xlab("Quarter")+
  theme(axis.text.x = element_text(angle = 90))

