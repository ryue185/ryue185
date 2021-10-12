library(dplyr)
library(readr)
library(lubridate)
library(ggplot2)
library(tidyverse)

cons_data <- read_csv("cons_data.csv")
cons_data<-cons_data[as.numeric(format(cons_data$date,"%m"))==11,]
cons_data<-cons_data%>%
  filter(age>=25)%>%
  filter(age<=80)%>%
  filter(aggs>0)


cons_data_count <- cons_data %>% 
  count(id)%>%
  filter(n==9)

always_in<-as.vector(cons_data_count$id)

rm(cons_data_count)

cons_data<-cons_data%>%
  filter(id %in% always_in)%>%
  subset(select=c("date","age","aggs"))%>%
  mutate(date = format(date,"%Y"))

q1 <- function(col) {
  return(quantile(col, 0.25))
}

q3 <- function(col) {
  return(quantile(col, 0.75))
}

temp1<-aggregate(cons_data[,3],list(cons_data$age,cons_data$date),median)
colnames(temp1)<-c("age","year","aggs")
temp1$type<-"median"

temp2<-aggregate(cons_data[,3],list(cons_data$age,cons_data$date),q1)
colnames(temp2)<-c("age","year","aggs")
temp2$type<-"25%"

temp1<-rbind(temp1,temp2)

temp2<-aggregate(cons_data[,3],list(cons_data$age,cons_data$date),q3)
colnames(temp2)<-c("age","year","aggs")
temp2$type<-"75%"

temp1<-rbind(temp1,temp2)

cons_data_clean<-temp1
rm(temp1)
rm(temp2)
cons_data_clean<-cons_data_clean%>%
  mutate(birthyear = as.numeric(year)-age)%>%
  mutate(birthyear_type = paste(birthyear, type,sep=" "))

ggplot(data=cons_data_clean,aes(x=age,y=aggs, group=birthyear_type))+
  geom_smooth(aes(color=type),method = "loess", se=FALSE,size=0.5)+
  ylab("Annual Consumption (life cycle)") + xlab("Age")+
  ylim(0,30000)

