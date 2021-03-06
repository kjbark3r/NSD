######################################################
######## Migration - Net Squared Displacement ########
########  NSERP - Kristin Barker - June 2016  ########
######################################################

################################
#SETUP

#working directory
  wd_workcomp <- "C:\\Users\\kristin.barker\\Documents\\GitHub\\NSD"
  wd_laptop <- "C:\\Users\\kjbark3r\\Documents\\GitHub\\NSD"
  
  if (file.exists(wd_workcomp)) {
    setwd(wd_workcomp)
  } else {
    if(file.exists(wd_laptop)) {
      setwd(wd_laptop)
    } else {
      cat("Are you SURE you got that file path right?\n")
    }
  }

#packages
  library(gsubfn)
  library(sp) #for kernel centroid estimate
  library(adehabitatHR) #for kernel centroid estimate
  library(raster)
  library(rgdal)

#shared parameters
	#asymptotes - migration distance from starting point - km^2 
		#migrant must move minimum 1 mile from starting location (2.2 km)
		#mixed migrant must return half that distance
		L_a1=4.84 #spring 2014 migration

	#duration - 1/4 duration of migration
		#must remain on different seasonal range > 90 days
		L_dur1=0
		U_dur1=23
		L_dur2=0
		U_dur2=23
					
	
##################################
# 2014 CODE
##################################

# start date = 2014-02-26
		
# output subfolder
out_workcomp <- "C:\\Users\\kristin.barker\\Documents\\GitHub\\NSD\\output\\2014\\"
out_laptop <- "C:\\Users\\kjbark3r\\Documents\\GitHub\\NSD\\output\\2014\\"

 if (file.exists(wd_workcomp)) {
	 outputpath = out_workcomp
  } else {
	if(file.exists(wd_laptop)) {
	  outputpath = out_laptop
	} else {
	  cat("Are you SURE you got that file path right?\n")
	}
  }
  rm(out_workcomp, out_laptop)
	
# 2014 midpoint dates
L_t1=35  # April 01
U_t1=95 # May 31
L_t2=188 # September 01
U_t2=309 # December 31

# data
dataall <- read.csv("nsd-locs-2014.csv") 
elklist <- as.data.frame(unique(dataall$AnimalID))
numelk <- nrow(elklist)
attach(dataall)

# blank aic csv
AICcsv = array(NA,c(1,7))
AICcsv[1,]=c("animal","migrant","mixed-migrant","disperser","resident","nomad","bestmodel")
write.table(AICcsv, append=FALSE,
            paste0(outputpath,"AICtable.csv"), 
            sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE)

#blank coefficient csv
COEFcsv=array(NA,c(1,15))
COEFcsv[1,]=c("animal","asym1","asym2","t1","t2","dur1","dur2","intercept","nomadbeta","day0","distance",
              "springstart","springend","fallstart","fallend")
write.table(COEFcsv, append=FALSE,
            paste0(outputpath,"COEFFICIENTStable.csv"), 
            sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE)

for(i in 1:numelk) {
  ######### PER-ANIMAL CODE 
  elk=elklist[i,]
  
  datasub<-subset(dataall, AnimalID==elk)	#Subset data to 1 animal 
  
  ##Calculate NSD - distance from first location (km)
  datasub = datasub[order(datasub$J_day_new),]
  datasub["NSD"] = ((((datasub$X_UTM - datasub$X_UTM[1])/1000)^2) + (((datasub$Y_UTM - datasub$Y_UTM[1])/1000)^2))
  
  #set up AIC and coefficient tables
  AICtable = array(NA,c(1,7))
  AICtable[1,1] = elk
  coefs=array(NA,c(1,15))
  coefs[1,1]=elk

  #indiv img
  png(filename=paste0(outputpath,elk,".png"),height=800,width=900,pointsize=16,bg="white")
  par(mfrow=c(2,3))
  
  #Run 5 Bunnfeld models and use AIC to determine which model has best fit
  # eq1: MIGRANT
  m.1 = try(nls(NSD~(asym/(1+exp((t1-J_day_new)/dur1)))+(-asym/(1+exp((t2-J_day_new)/dur2))), 
                data = datasub,
                control=nls.control(maxiter = 1000, warnOnly=TRUE),
                algorithm="port",
                start=c(asym=0.75*max(datasub$NSD),t1=90,t2=240, dur1=2,dur2=2),
                #Set lower limits 
                lower=c(asym=L_a1,t1=L_t1,t2=L_t2, dur1=L_dur1,dur2=L_dur2),
                #Set upper limits
                upper=c(asym=max(datasub$NSD),t1=U_t1,t2=U_t2,dur1=U_dur1,dur2=U_dur2)
  ),TRUE) 
  
  
  if (class(m.1)=="nls") {
    c1=coef(m.1)
    AICtable[1,2] = AIC(m.1)
    y_mig=predict(m.1)
    plot(datasub$J_day_new,y_mig, type="l", xlim=c(1,366), lwd=3, ylim=c(0,max(datasub$NSD)),col=2,main="eq1:migrant", ylab="NSD", xlab="Day")
    points(datasub$J_day_new,datasub$NSD)
    try(summary(m.1),silent=TRUE)
  } else m.1 <- NA
  
  
  # eq2: MIXED-MIGRANT
  m.2 = try(nls(NSD~(asym1/(1+exp((t1-J_day_new)/dur1)))+(-asym2/(1+exp((t2-J_day_new)/dur2))), 
                data = datasub, 
                control=nls.control(maxiter = 1000, warnOnly=TRUE),
                algorithm="port",
                start=c(asym1=0.75*max(datasub$NSD),asym2=0.5*max(datasub$NSD),t1=90,t2=240, dur1=2,dur2=2),
                #Set lower limits such that asym1 and asym2 are positive and midpoints of spring and fall migration >=1Apr an
                lower=c(asym1=L_a1,asym2=(0.5*c1["asym"]),t1=L_t1,t2=L_t2, dur1=L_dur1,dur2=L_dur2),
                #Set upper limits
                upper=c(asym1=max(datasub$NSD),asym2=max(datasub$NSD),t1=U_t1,t2=U_t2,dur1=U_dur1,dur2=U_dur2)
  ),silent=TRUE)
  
  if (class(m.2)== "nls") {
    c2=coef(m.2)
    AICtable[1,3] = AIC(m.2)
    y_mm=predict(m.2)
    plot(datasub$J_day_new,y_mm, type="l", xlim=c(1,366), lwd=3, ylim=c(0,max(datasub$NSD)),col=2,main="eq2:mixed-migrant", ylab="NSD", xlab="Day")
    points(datasub$J_day_new,datasub$NSD)
    try(summary(m.2),silent=TRUE)
  } else m.2 <- NA
  
  # eq3: DISPERSAL	
  m.3 = try(nls(NSD~(asym/(1+exp((t1-J_day_new)/dur1))), 
                data = datasub,
                control=nls.control(maxiter = 1000, warnOnly=TRUE),
                algorithm="port",
                start=c(asym=0.75*max(datasub$NSD),t1=90,dur1=2),
                lower=c(asym=L_a1,t1=L_t1,dur1=L_dur1),
                upper=c(asym1=max(datasub$NSD),t1=U_t1,dur1=U_dur1)
  ),silent=TRUE)
  
  if (class(m.3)== "nls") {
    c3=try(coef(m.3),silent=TRUE)
    AICtable[1,4] = try(AIC(m.3),silent=TRUE)
    y_disp=predict(m.3)
    plot(datasub$J_day_new,y_disp, type="l", xlim=c(1,366), lwd=3, ylim=c(0,max(datasub$NSD)),col=2,main="eq3:disperser", ylab="NSD", xlab="Day")
    points(datasub$J_day_new,datasub$NSD)
    try(summary(m.3),silent=TRUE)
  } else m.3 <- NA
  
  
  # eq4: RESIDENT
  #fit with lm for linear models, the 1 codes the intercept
  m.4 = lm(NSD~1, data=datasub)
  summary(m.4)
  c4=coef(m.4)
  AICtable[1,5] = AIC(m.4)
  y_hr=predict(m.4)
  plot(datasub$J_day_new,y_hr, type="l",xlim=c(1,366), lwd=3, ylim=c(0,max(datasub$NSD)), col=2,main="eq4:resident", ylab="NSD", xlab="Day")
  points(datasub$J_day_new,datasub$NSD)
  
  # eq5: NOMAD
  #fit with lm for linear models, the 0 implies no intercept
  m.5 = lm(NSD~(0+J_day_new), data=datasub)
  summary(m.5)
  c5=coef(m.5)
  AICtable[1,6] = AIC(m.5)
  y_nom=predict(m.5)
  plot(datasub$J_day_new,y_nom, type="l", xlim=c(1,366), lwd=3, ylim=c(0,max(datasub$NSD)),col=2,main="eq5:nomad", ylab="NSD", xlab="Day")
  points(datasub$J_day_new,datasub$NSD)
  dev.off()
  
  
  #AICtable
  bestmodel=which.min(AICtable[1,2:6])
  AICtable[1,7] = bestmodel
  
  write.table(AICtable, append=TRUE,
              paste0(outputpath,"AICtable.csv"), 
              sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE, na="NA")
  
  #COEFFICIENT table
  if (bestmodel==1) {
    coefs[1,2]=c1["asym"];coefs[1,4]=c1["t1"];coefs[1,5]=c1["t2"];coefs[1,6]=c1["dur1"];coefs[1,7]=c1["dur2"]
  } else if (bestmodel==2) {
    coefs[1,2]=c2["asym1"];coefs[1,3]=c2["asym2"];coefs[1,4]=c2["t1"];coefs[1,5]=c2["t2"];coefs[1,6]=c2["dur1"];coefs[1,7]=c2["dur2"]
  } else if (bestmodel==3) {
    coefs[1,2]=c3["asym"];coefs[1,4]=c3["t1"];coefs[1,6]=c3["dur1"]
  } else if (bestmodel==4) {
    coefs[1,8]=c4["(Intercept)"]	
  } else
    coefs[1,9]=c5["J_day_new"]
  
  
  #ADJUST COEFFICIENTS TO MIGRATION VALUES
  coefs[1,10]=as.Date(c("2014-02-26"))
  
  ###spring
  
  if (bestmodel==1|bestmodel==2|bestmodel==3) {
    
    coefs[1,11]=sqrt(coefs[1,2])
    coefs[1,12]=25568+coefs[1,4]-(2*coefs[1,6])+coefs[1,10]
    coefs[1,13]=25568+coefs[1,4]+(2*coefs[1,6])+coefs[1,10]
  } else {
    coefs[1,11]=NA
    coefs[1,12]=NA
    coefs[1,13]=NA
  }
  
  ###fall
  
  if (bestmodel==1|bestmodel==2) {
    coefs[1,14]=25568+coefs[1,5]-(2*coefs[1,7])+coefs[1,10]
    coefs[1,15]=25568+coefs[1,5]+(2*coefs[1,7])+coefs[1,10]
  } else {
    coefs[1,14]=NA;coefs[1,15]=NA
  }
  
  write.table(coefs, append=TRUE,
              paste0(outputpath,"COEFFICIENTStable.csv"),
              sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE, na="NA")
}

##################################
# 2015 CODE
##################################

# start date = 2015-01-24

# output subfolder
out_workcomp <- "C:\\Users\\kristin.barker\\Documents\\GitHub\\NSD\\output\\2015\\"
out_laptop <- "C:\\Users\\kjbark3r\\Documents\\GitHub\\NSD\\output\\2015\\"

 if (file.exists(wd_workcomp)) {
	 outputpath = out_workcomp
  } else {
	if(file.exists(wd_laptop)) {
	  outputpath = out_laptop
	} else {
	  cat("Are you SURE you got that file path right?\n")
	}
  }
  rm(wd_workcomp, wd_laptop, out_workcomp, out_laptop)
	  
# 2015 midpoint dates
L_t1=68  # April 01
U_t1=128 # May 31
L_t2=221 # September 01
U_t2=342 # December 31

# data
detach(dataall)
dataall <- read.csv("nsd-locs-2015.csv")
elklist <- as.data.frame(unique(dataall$AnimalID))
numelk <- nrow(elklist)
attach(dataall)

# blank aic csv
AICcsv = array(NA,c(1,7))
AICcsv[1,]=c("animal","migrant","mixed-migrant","disperser","resident","nomad","bestmodel")
write.table(AICcsv, append=FALSE,
            paste0(outputpath,"AICtable.csv"), 
            sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE)

#blank coefficient csv
COEFcsv=array(NA,c(1,15))
COEFcsv[1,]=c("animal","asym1","asym2","t1","t2","dur1","dur2","intercept","nomadbeta","day0","distance",
              "springstart","springend","fallstart","fallend")
write.table(COEFcsv, append=FALSE,
            paste0(outputpath,"COEFFICIENTStable.csv"), 
            sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE)

for(i in 1:numelk) {
  ######### PER-ANIMAL CODE 
  elk=elklist[i,]
  
  datasub<-subset(dataall, AnimalID==elk)	#Subset data to 1 animal 
  
  ##Calculate NSD - distance from first location (km)
  datasub = datasub[order(datasub$J_day_new),]
  datasub["NSD"] = ((((datasub$X_UTM - datasub$X_UTM[1])/1000)^2) + (((datasub$Y_UTM - datasub$Y_UTM[1])/1000)^2))
  
  #set up AIC and coefficient tables
  AICtable = array(NA,c(1,7))
  AICtable[1,1] = elk
  coefs=array(NA,c(1,15))
  coefs[1,1]=elk

  #indiv img
  png(filename=paste0(outputpath,elk,".png"),height=800,width=900,pointsize=16,bg="white")
  par(mfrow=c(2,3))
  
  #Run 5 Bunnfeld models and use AIC to determine which model has best fit
  # eq1: MIGRANT
  m.1 = try(nls(NSD~(asym/(1+exp((t1-J_day_new)/dur1)))+(-asym/(1+exp((t2-J_day_new)/dur2))), 
                data = datasub,
                control=nls.control(maxiter = 1000, warnOnly=TRUE),
                algorithm="port",
                start=c(asym=0.75*max(datasub$NSD),t1=90,t2=240, dur1=2,dur2=2),
                #Set lower limits 
                lower=c(asym=L_a1,t1=L_t1,t2=L_t2, dur1=L_dur1,dur2=L_dur2),
                #Set upper limits
                upper=c(asym=max(datasub$NSD),t1=U_t1,t2=U_t2,dur1=U_dur1,dur2=U_dur2)
  ),TRUE) 
  
  
  if (class(m.1)=="nls") {
    c1=coef(m.1)
    AICtable[1,2] = AIC(m.1)
    y_mig=predict(m.1)
    plot(datasub$J_day_new,y_mig, type="l", xlim=c(1,366), lwd=3, ylim=c(0,max(datasub$NSD)),col=2,main="eq1:migrant", ylab="NSD", xlab="Day")
    points(datasub$J_day_new,datasub$NSD)
    try(summary(m.1),silent=TRUE)
  } else m.1 <- NA
  
  
  # eq2: MIXED-MIGRANT
  m.2 = try(nls(NSD~(asym1/(1+exp((t1-J_day_new)/dur1)))+(-asym2/(1+exp((t2-J_day_new)/dur2))), 
                data = datasub, 
                control=nls.control(maxiter = 1000, warnOnly=TRUE),
                algorithm="port",
                start=c(asym1=0.75*max(datasub$NSD),asym2=0.5*max(datasub$NSD),t1=90,t2=240, dur1=2,dur2=2),
                #Set lower limits such that asym1 and asym2 are positive and midpoints of spring and fall migration >=1Apr an
                lower=c(asym1=L_a1,asym2=(0.5*c1["asym"]),t1=L_t1,t2=L_t2, dur1=L_dur1,dur2=L_dur2),
                #Set upper limits
                upper=c(asym1=max(datasub$NSD),asym2=max(datasub$NSD),t1=U_t1,t2=U_t2,dur1=U_dur1,dur2=U_dur2)
  ),silent=TRUE)
  
  if (class(m.2)== "nls") {
    c2=coef(m.2)
    AICtable[1,3] = AIC(m.2)
    y_mm=predict(m.2)
    plot(datasub$J_day_new,y_mm, type="l", xlim=c(1,366), lwd=3, ylim=c(0,max(datasub$NSD)),col=2,main="eq2:mixed-migrant", ylab="NSD", xlab="Day")
    points(datasub$J_day_new,datasub$NSD)
    try(summary(m.2),silent=TRUE)
  } else m.2 <- NA
  
  # eq3: DISPERSAL	
  m.3 = try(nls(NSD~(asym/(1+exp((t1-J_day_new)/dur1))), 
                data = datasub,
                control=nls.control(maxiter = 1000, warnOnly=TRUE),
                algorithm="port",
                start=c(asym=0.75*max(datasub$NSD),t1=90,dur1=2),
                lower=c(asym=L_a1,t1=L_t1,dur1=L_dur1),
                upper=c(asym1=max(datasub$NSD),t1=U_t1,dur1=U_dur1)
  ),silent=TRUE)
  
  if (class(m.3)== "nls") {
    c3=try(coef(m.3),silent=TRUE)
    AICtable[1,4] = try(AIC(m.3),silent=TRUE)
    y_disp=predict(m.3)
    plot(datasub$J_day_new,y_disp, type="l", xlim=c(1,366), lwd=3, ylim=c(0,max(datasub$NSD)),col=2,main="eq3:disperser", ylab="NSD", xlab="Day")
    points(datasub$J_day_new,datasub$NSD)
    try(summary(m.3),silent=TRUE)
  } else m.3 <- NA
  
  
  # eq4: RESIDENT
  #fit with lm for linear models, the 1 codes the intercept
  m.4 = lm(NSD~1, data=datasub)
  summary(m.4)
  c4=coef(m.4)
  AICtable[1,5] = AIC(m.4)
  y_hr=predict(m.4)
  plot(datasub$J_day_new,y_hr, type="l",xlim=c(1,366), lwd=3, ylim=c(0,max(datasub$NSD)), col=2,main="eq4:resident", ylab="NSD", xlab="Day")
  points(datasub$J_day_new,datasub$NSD)
  
  # eq5: NOMAD
  #fit with lm for linear models, the 0 implies no intercept
  m.5 = lm(NSD~(0+J_day_new), data=datasub)
  summary(m.5)
  c5=coef(m.5)
  AICtable[1,6] = AIC(m.5)
  y_nom=predict(m.5)
  plot(datasub$J_day_new,y_nom, type="l", xlim=c(1,366), lwd=3, ylim=c(0,max(datasub$NSD)),col=2,main="eq5:nomad", ylab="NSD", xlab="Day")
  points(datasub$J_day_new,datasub$NSD)
  dev.off()
  
  
  #AICtable
  bestmodel=which.min(AICtable[1,2:6])
  AICtable[1,7] = bestmodel
  
  write.table(AICtable, append=TRUE,
              paste0(outputpath,"AICtable.csv"), 
              sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE, na="NA")
  
  #COEFFICIENT table
  if (bestmodel==1) {
    coefs[1,2]=c1["asym"];coefs[1,4]=c1["t1"];coefs[1,5]=c1["t2"];coefs[1,6]=c1["dur1"];coefs[1,7]=c1["dur2"]
  } else if (bestmodel==2) {
    coefs[1,2]=c2["asym1"];coefs[1,3]=c2["asym2"];coefs[1,4]=c2["t1"];coefs[1,5]=c2["t2"];coefs[1,6]=c2["dur1"];coefs[1,7]=c2["dur2"]
  } else if (bestmodel==3) {
    coefs[1,2]=c3["asym"];coefs[1,4]=c3["t1"];coefs[1,6]=c3["dur1"]
  } else if (bestmodel==4) {
    coefs[1,8]=c4["(Intercept)"]	
  } else
    coefs[1,9]=c5["J_day_new"]
  
  
  #ADJUST COEFFICIENTS TO MIGRATION VALUES
  coefs[1,10]=as.Date(c("2015-01-24"))
  
  ###spring
  
  if (bestmodel==1|bestmodel==2|bestmodel==3) {
    
    coefs[1,11]=sqrt(coefs[1,2])
    coefs[1,12]=25568+coefs[1,4]-(2*coefs[1,6])+coefs[1,10]
    coefs[1,13]=25568+coefs[1,4]+(2*coefs[1,6])+coefs[1,10]
  } else {
    coefs[1,11]=NA
    coefs[1,12]=NA
    coefs[1,13]=NA
  }
  
  ###fall
  
  if (bestmodel==1|bestmodel==2) {
    coefs[1,14]=25568+coefs[1,5]-(2*coefs[1,7])+coefs[1,10]
    coefs[1,15]=25568+coefs[1,5]+(2*coefs[1,7])+coefs[1,10]
  } else {
    coefs[1,14]=NA;coefs[1,15]=NA
  }
  
  write.table(coefs, append=TRUE,
              paste0(outputpath,"COEFFICIENTStable.csv"),
              sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE, na="NA")
}