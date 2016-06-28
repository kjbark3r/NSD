######################################################
######## Migration - Net Squared Displacement ########
#### Visualizing Geographic Distance Values ##########
########  NSERP - Kristin Barker - June 2016  ########
######################################################

# note to self - need to read in csvs for future

plot(nsd.avg$avgNSD2014~nsd.avg$avgNSD2015)

par(mfrow = c(2,1))
n14rank <- nsd.avg.2014 %>%
  arrange(avgNSD) %>%
  mutate(Rank = row_number()) %>%
  na.omit()
plot(n14rank$avgNSD ~ n14rank$Rank, main = "Avg NSD 2014")

n15rank <- nsd.avg.2015 %>%
  arrange(avgNSD) %>%
  mutate(Rank = row_number()) %>%
  na.omit()
plot(n15rank$avgNSD ~ n15rank$Rank, main = "Avg NSD 2015")