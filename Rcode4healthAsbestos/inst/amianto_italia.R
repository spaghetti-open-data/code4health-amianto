#!/usr/bin/Rscript

## Athor: Emanuele Cordano
## Date: 2015-05-18

###############################################################################

rm(list=ls())

library(rgdal)
library(stringr)
library(Rcode4healthAsbestos)


###
## IN alternativa a library(Rcode4healthAsbestos) si puo richamare direttamente il file
## alternatively to library(Rcode4healthAsbestos) you can load the R functions directly
source('/home/ecor/Dropbox/R-packages/code4health-amianto/Rcode4healthAsbestos/R/getData.R') 
#
###
projectDir <- '/home/ecor/Dropbox/R-packages/code4health-amianto'  ## REPLACE WITH YOUR PROJECT DIR

dataDir <- paste(projectDir,"dati",sep="/")




files <- list.files(dataDir,recursive=TRUE,full.names=TRUE) ####,pattern=".shp")

admitted_extensions <- c("shp","geojson","csv") ## extansion files with data 

files <- files[!str_detect(files,"RegioneToscana")] ## Regione Toscana actually not yet considered! 

files_o <- files
files_o <- str_split(files,"[.]")

######  VEDERE QUI:  
######  http://stackoverflow.com/questions/24183007/is-it-possible-to-read-geojson-or-topojson-file-in-r-to-draw-a-choropleth-map
###### per GEOJSON 

files <- sapply(X=files_o,FUN=function(x){x[[1]]})
extension <- sapply(X=files_o,FUN=function(x){x[[2]]})


#########

sources <- data.frame(filename=files,extension=extension,dsn=as.character(NA),layer=as.character(NA),driver=as.character(NA),stringsAsFactors=FALSE)


sources$name <- str_replace(sources$filename,dataDir,".")
		
		
admitted_extensions <- c("shp","geojson","csv")

sources <- sources[sources$extension %in% admitted_extensions,]




#####  SHP shapefile
cond  <- which(sources$extension=="shp") 



x <- sources$filename[cond]
x <- str_split(x,"/")
lx <- sapply(x,FUN=length)
sources$dsn[cond] <- sapply(X=x,FUN=function (x){
			lx <- length(x)
			o <- paste(x[-lx],collapse="/")
			
		})

sources$layer[cond] <- sapply(X=x,FUN=function (x){
			lx <- length(x)
			o <- x[lx]
			
		})

#####
##### GEOJson 
cond <- which(sources$extension=="geojson")



sources$dsn[cond] <- paste(sources$filename[cond],sources$extension[cond],sep=".")
sources$layer[cond] <- "OGRGeoJSON"

## CLEANING 
cond2 <- which(sources$filename %in% sources$filename[cond])

cond2 <- cond2[!(cond2 %in% cond)]
print(cond2)
sources <- sources[-cond2,]

cond <- which(sources$extension=="geojson")


##

###### csv
cond <- which(sources$extension=="csv")
#
sources$dsn[cond] <- paste(sources$filename[cond],sources$extension[cond],sep=".")
sources$layer[cond] <- NA ###"OGRcsv"
#
#### TEST 

dl <- list()

for (i in 1:nrow(sources)) {
	
	dsn_ <- sources$dsn[i]
	layer_ <- sources$layer[i]
	it <- sources$name[i]
	print(dsn_)
	
	dl[[it]] <- getAsbestosFile(dsn=dsn_,layer=layer_,stringsAsFactors=FALSE)
	
	
}


classes <- sapply(X=dl,FUN=class)
fields <- lapply(X=dl,FUN=names)

sources$class <- classes[sources$name]
sources$proj_CRS <- sapply(X=dl[sources$name],FUN=attr,which="proj_CRS")
sources$coordfield <- sapply(X=dl[sources$name],FUN=attr,which="coords")

idf <- which(classes=="data.frame")

table <- '/home/ecor/Dropbox/R-packages/code4health-amianto/Rcode4healthAsbestos/inst/table.csv' 
writeFields_file <- '/home/ecor/Dropbox/R-packages/code4health-amianto/Rcode4healthAsbestos/inst/lista_campi.txt'
writeFields_csv <- str_replace(writeFields_file,".txt",".csv")

write.table(sources,file=table,sep=";",row.names=FALSE)



### FIELDS 

writeFields <- c("","#CAMPI DEI DATA FRAMES","","")
writeFields_csv_v <- "" 
for (it in names(fields)) {
	
	
	
	ff <- paste(fields[[it]],collapse="  ")
	ffi <- fields[[it]]
	coords <- str_split(attr(dl[[it]],which="coords")," AND ")[[1]]
	print(coords)
	ffi <- ffi[!(ffi %in% coords)]
	
	writeFields <- c(writeFields,sprintf("#%s",it),ff,"")
	writeFields_csv_v[it] <- paste(c(it,ffi),collapse=";")
	
	
	
}

writeLines(writeFields,con=writeFields_file)
writeLines(writeFields_csv_v,con=writeFields_csv)
### END script
