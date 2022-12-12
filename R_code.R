list.of.packages <- c('ggiraphExtra',"wesanderson",'ggplot2', "dplyr", "broom", "readxl", "writexl")
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
df_list <- list(deaths, govenors, gini,beds,age)
final<-Reduce(function(x, y) merge(x, y, all=TRUE), df_list)
final$Governor <- factor(final$Governor)
final$`Gini Index` <- as.numeric(final$`Gini Index`)
final$`Gini Index` <- final$`Gini Index`*100
final<-na.omit(final)
mytheme <-  theme(
  panel.background = element_rect(fill = "lightcyan",
                                  colour = "lightblue",
                                  size = 0.5, linetype = "solid"),
  panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                  colour = "grey"), 
  panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                  colour = "grey")
)
ggplot(final, aes(x=MedianAge)) + 
  geom_histogram(binwidth=.25, colour="black", fill="white")+mytheme
ggsave('age.png')
ggplot(final, aes(x=`Gini Index`)) + 
  geom_histogram(binwidth=.25, colour="black", fill="white")+mytheme
ggsave('gini index.png')
ggplot(final, aes(x=`Total_beds_per1000`)) + 
  geom_histogram(binwidth=.25, colour="black", fill="white")+mytheme
ggsave('beds.png')
write_xlsx(x = final, path = "final.xlsx")
summary(final)
ggplot(final, aes(`Total_beds_per1000`,`Death Rate per 100000`,colour=Governor)) +
  geom_point(size=4,alpha = 20, show.legend = FALSE) +
  scale_color_manual(values=wes_palette(n=2, name="Cavalcanti1"))+
  labs(title = 'Beds per1000 vs Death rate per 100000', x = 'Total beds per1000', y = 'Death Rate per 100000')+
  mytheme
ggsave("Beds_vs_Deathrate(scatterplot).png")
ggplot(final, aes(`Gini Index`,`Death Rate per 100000`,colour=Governor)) +
  geom_point(size=4,alpha = 20, show.legend = TRUE) +
  scale_color_manual(values=wes_palette(n=2, name="Cavalcanti1"))+
  labs(title = 'Gini Index vs Death rate per 100000', x = 'Gini Index', y = 'Death Rate per 100000')+
  mytheme
ggsave("Giniindex_vs_Deathrate.png")
ggplot(final, aes(`MedianAge`,`Death Rate per 100000`,colour=Governor)) +
  geom_point(size=4,alpha = 20, show.legend = TRUE) +
  scale_color_manual(values=wes_palette(n=2, name="Cavalcanti1"))+
  labs(title = 'MedianAge vs Death rate per 100000', x = 'MedianAge', y = 'Death Rate per 100000')+
  mytheme
ggsave("Age_vs_Deathrate.png")
# hist(final$`Death Rate per 100000`)
# hist(final$`Total_beds_per1000`)
# plot(`Total_beds_per1000` ~ `Death Rate per 100000`, data = final)
ggcorr(final,
       method = c("pairwise", "spearman"),
       nbreaks = 6,
       hjust = 0.8,
       label = TRUE,
       label_size = 3,
       color = "grey50")
ggsave('corrlation.png')
bed.lm <- lm( `Death Rate per 100000`~`Total_beds_per1000` , data = final)
ggplot(final,aes(`Total_beds_per1000`, `Death Rate per 100000`)) +
  geom_point()+
  mytheme+stat_smooth(method = "lm", col = "red")+
  labs(title = paste("Adj R2 = ",signif(summary(bed.lm)$adj.r.squared, 5),
                     "Intercept =",signif(bed.lm$coef[[1]],5 ),
                     " Slope =",signif(bed.lm$coef[[2]], 5),
                     " P =",signif(summary(bed.lm)$coef[2,4], 5)),x = 'Total_beds_per1000', y = 'Death Rate per 100000')
ggsave('Bed_simple_regression.png')
age.lm <-  lm(`Death Rate per 100000`~`MedianAge` , data = final)
ggplot(final,aes(`MedianAge`, `Death Rate per 100000`)) +
  geom_point()+
  labs(title = 'MedianAge vs Death rate per 100000', x = 'MedianAge', y = 'Death Rate per 100000')+
  mytheme+stat_smooth(method = "lm", col = "red")+
  labs(title = paste("Adj R2 = ",signif(summary(age.lm)$adj.r.squared, 5),
                     "Intercept =",signif(age.lm$coef[[1]],5 ),
                     " Slope =",signif(age.lm$coef[[2]], 5),
                     " P =",signif(summary(age.lm)$coef[2,4], 5)))
ggsave('age_simple_regression.png')
gini.lm <- lm(`Death Rate per 100000`~`Gini Index` , data = final)
ggplot(final,aes(`Gini Index`, `Death Rate per 100000`)) +
  geom_point()+
  labs(title = 'MedianAge vs Death rate per 100000', x = 'Gini Index', y = 'Death Rate per 100000')+
  mytheme+stat_smooth(method = "lm", col = "red")+
  labs(title = paste("Adj R2 = ",signif(summary(gini.lm)$adj.r.squared, 5),
                     "Intercept =",signif(gini.lm$coef[[1]],5 ),
                     " Slope =",signif(gini.lm$coef[[2]], 5),
                     " P =",signif(summary(gini.lm)$coef[2,4], 5)))
ggsave('gini_simple_regression.png')
final.lm <- glm(`Death Rate per 100000`~`Total_beds_per1000` + `MedianAge` + `Gini Index` + `Governor`,
                data = final
)

ggplot(final.lm, aes(x = .fitted, y = .resid)) +
  geom_point() +
  geom_hline(yintercept = 0) +
  labs(title='Residual vs. Fitted Values Plot', x='Fitted Values', y='Residuals')+
  mytheme
ggsave("residualplot_for_final_model.png")
pred<-predict(final.lm)
final$`Death Rate per 100000`
ggplot(final, aes(x=predict(final.lm), y=`Death Rate per 100000`)) +
  geom_point() +
  geom_abline(intercept=0, slope=1) +
  labs(x='Predicted Values', y='Actual Values', title='Predicted vs. Actual Values')+
  mytheme
ggsave("predicted_vs_observed.png")
summary(final.lm)
summary(bed.lm)
summary(age.lm)
summary(gini.lm)

