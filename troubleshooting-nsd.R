###################################################
## MISC CODE RELATED TO NET SQUARED DISPLACEMENT ##
###################################################

#testing inpath/outpath stuff
wd_workcomp <- "C:\\Users\\kristin.barker\\Documents\\GitHub\\NSD"
  out_workcomp <- "C:\\Users\\kristin.barker\\Documents\\GitHub\\NSD\\output"
wd_laptop <- "C:\\Users\\kjbark3r\\Documents\\GitHub\\NSD"
  out_laptop <- "C:\\Users\\kjbark3r\\Documents\\GitHub\\NSD\\output"

if (file.exists(wd_workcomp)) {
  setwd(wd_workcomp)
  inputpath = wd_workcomp
  outputpath = out_workcomp
} else {
  if(file.exists(wd_laptop)) {
    setwd(wd_laptop)
    inputpath = wd_laptop
    outputpath = out_laptop
  } else {
    cat("Are you SURE you got that file path right?\n")
    }
}

rm(wd_workcomp, wd_laptop, out_workcomp, out_laptop)

