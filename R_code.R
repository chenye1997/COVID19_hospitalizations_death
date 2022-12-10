list.of.packages <- c("wesanderson",'gapminder','ggplot2','gganimate','gifski', "dplyr", "broom", "readxl", "writexl")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)
setwd('~/COVID19_hospitalizations-death/')
deaths <- read_excel("united_states_covid19_cases_deaths_and_testing_by_state_states only.xlsx")
govenors<- read_excel("US govenors party 2020.xlsx")
age<-read_excel('US state median population.xlsx')
gini<-read_excel('gini index.xlsx')
beds<-read.csv("states_beds_per1000.csv")
beds<-beds[c(1,5)]
deaths<- deaths[c(1,7)]
final1<- merge(deaths, govenors, by = "State")
final2 <- merge(gini, age, by = "State")
final <- merge(final1, final2, by = "State")
final <- merge(final,beds,by="State")
write_xlsx(x = final, path = "final.xlsx")
summary(final)
final$Governor <- factor(final$Governor)
final$`Gini Index` <- as.numeric(final$`Gini Index`)
ggplot(final, aes(`Total_beds_per1000`,`Death Rate per 100000`,colour=Governor)) +
  geom_point(size=4,alpha = 20, show.legend = FALSE) +
  scale_color_manual(values=wes_palette(n=2, name="Cavalcanti1"))+
  labs(title = 'Beds per1000 vs Death rate per 100000', x = 'Total beds per1000', y = 'Death Rate per 100000')+
  theme(
  panel.background = element_rect(fill = "lightcyan",
                                  colour = "lightblue",
                                  size = 0.5, linetype = "solid"),
  panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                  colour = "grey"), 
  panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                  colour = "grey")
)
ggplot(final, aes(`Gini Index`,`Death Rate per 100000`,colour=Governor)) +
  geom_point(size=4,alpha = 20, show.legend = FALSE) +
  scale_color_manual(values=wes_palette(n=2, name="Cavalcanti1"))+
  labs(title = 'Gini Index vs Death rate per 100000', x = 'Gini Index', y = 'Death Rate per 100000')+
  theme(
    panel.background = element_rect(fill = "lightcyan",
                                    colour = "lightblue",
                                    size = 0.5, linetype = "solid"),
    panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                    colour = "grey"), 
    panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                    colour = "grey")
  )
# hist(final$`Death Rate per 100000`)
# hist(final$`Total_beds_per1000`)
# plot(`Total_beds_per1000` ~ `Death Rate per 100000`, data = final)
cor(final$`Total_beds_per1000`, final$`Death Rate per 100000`)
bed.lm <- lm(`Total_beds_per1000` ~ `Death Rate per 100000`, data = final)
age.lm <-  lm(`MedianAge` ~ `Death Rate per 100000`, data = final)
gini.lm <- lm(`Gini Index` ~ `Death Rate per 100000`, data = final)
final.lm <- glm(`Death Rate per 100000`~`Total_beds_per1000` + `MedianAge` + `Gini Index` + `Governor`,
                data = final
                )
summary(final.lm)
summary(bed.lm)
summary(age.lm)
summary(gini.lm)
