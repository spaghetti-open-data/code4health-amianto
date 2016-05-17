#!/usr/bin/Rscript

## Athor: Emanuele Cordano
# TODO: Add comment
# 
# Author: ecor
###############################################################################

rm(list=ls())

library(rgdal)
library(stringr)
###
source('/home/ecor/Dropbox/R-packages/code4health-amianto/Rcode4health-asbestos/R/getData.R') 

###
projectDir <- '/home/ecor/Dropbox/R-packages/code4health-amianto' 

dataDir <- paste(projectDir,"dati",sep="/")


files <- list.files(dataDir,recursive=TRUE,full.names=TRUE) ####,pattern=".shp")


files <- files[!str_detect(files,".zip")]
files <- files[!str_detect(files,".qgs")]
files <- files[!str_detect(files,".pdf")]
files <- files[!str_detect(files,".txt")]
files <- files[!str_detect(files,".md")]
files <- files[!str_detect(files,".url")]
files <- files[!str_detect(files,"RegioneToscana")] ## Regione Toscana actually not considered! 

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
sources$coordfield <- sapply(X=dl[sources$name],FUN=attr,which="coords")

idf <- which(classes=="data.frame")

table <- '/home/ecor/Dropbox/R-packages/code4health-amianto/Rcode4health-asbestos/inst/table.csv' 


write.table(sources,file=table,sep=";",row.names=FALSE)




#####
#########
stop()
shpfiles <- unique(files)

names(shpfiles) <- shpfiles


df <- lapply(X=shpfiles[-(1:17)],FUN=function(x) {
			
			####x <- str_replace(x,".shp","")
			print(x)
			x <- str_split(x,"/")[[1]]
			lx <- length(x)
			dsn <- paste(x[-lx],collapse="/")
			layer <- x[lx]
			print(dsn)
			out <- readOGR(dsn=dsn,layer=layer,stringsAsFactors=FALSE)
			
		})


stop()

json <- "/home/ecor/Dropbox/R-packages/code4health-amianto/dati/INAIL/INAIL WGS 84.geojson"
