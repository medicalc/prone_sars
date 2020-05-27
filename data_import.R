# DATA IMPORT

# directory where the notebook is
wdir <- getwd() 
# directory where data are imported from & saved to
datadir <- file.path(wdir, "data") # better than datadir <- paste(wdir, "/data", sep="")
# directory where external images are imported from
imgdir <- file.path(wdir, "assets", "img")
# directory where files are saved to
outdir <- file.path(wdir, "out")
plotdir <- file.path(outdir, "plot")
# the folder immediately above root
Up <- paste("\\/", basename(wdir), sep="")
wdirUp <- gsub(Up, "", wdir) 


#****** PARAMETERS ******#
params <- list(
  dataname_csv = "mydata_prone_sars_2020-05-27",
  mimetype_csv = ".csv"
)

#****** IMPORT ******#
routecsv <- paste0(datadir, "/", params$dataname_csv, params$mimetype_csv)  # complete route to archive
mydata0 <- readr::read_csv(routecsv, na=c("NA", ""))  
mydata <- mydata0

# DATA NAMES + ENGLISH TRANSLATION
mydata_names_prone <-  c(
  "session_pp", # prone positioning session
  "cama_paciente", # patient ID
  
  # Previous to PP
  "fio2_pre", # O2 inspired fraction previous to PP
  "ph_pre", # pH previous to PP
  "po2_pre", # O2 partial pressure previous to PP
  "pco2_pre", # CO2 partial pressure previous to PP
  "po2_fio2_pre", # PaO2/FiO2 ratio previous to PP
  "sto2_pre", # StO2% previous to PP
  # During PP
  "fio2_prono", # O2 inspired fraction during PP
  "ph_prono",
  "po2_prono",
  "pco2_prono",
  "po2_fio2_prono",
  "sto2_prono",
  
  # Post PP
  "fio2_post", # O2 inspired fraction during PP
  "ph_post",
  "po2_post",
  "pco2_post",
  "po2_fio2_post",
  "sto2_post",
  "horas" # hour at which PP was performed
)


