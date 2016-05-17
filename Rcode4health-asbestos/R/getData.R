NULL
#' Function to import data (for Code4Health)
#' 
#' @param dsn     input file with data. See \code{\link{readOGR}} 
#' @param layer   see \code{\link{readOGR}} 
#' @param sep potential separator characters for CSV files. See \code{\link{read.table}}
#' @param header  See \code{\link{read.table}}
#' 
#' 
#' 
#' 
#' @author Emanuele Cordano, Spaghetti Open Data
#' 
#' 
#' @note It reads single source files in SHP, CSV or geoJSON format. 
#' 
#' 
#' 


getAsbestosFile <- function(dsn=NA,layer=NA,sep=c(";",","),header=TRUE,...) {
	
	
	
	

	print(dsn)
	
	if (str_detect(dsn,".csv")) {
		
		x <- readLines(dsn)
	
		sep <- sep[str_detect(x[1],sep)]
		
		print(sep)
		out <- read.table(dsn,sep=sep,header=header,...)
		
		
	} else {
	   
		if (is.na(layer)) layer_ <- NULL
		out <- readOGR(dsn=dsn,layer=layer,...)
	}
		
	
	names(out) <- str_replace_all(names(out),"[.]","_")
	
	if (class(out)=="data.frame") {
		
		find_coords <- c("coord","x","y","X","Y","Coord","WGS","UTM")
		cond <- array(FALSE,length(names(out)))
		names(cond) <- names(out)
		
		for (cordit in find_coords) {
		  
			cond <- cond | str_detect(names(out),cordit) 
		
		}
		
		coords <- names(out)[cond]
		
		if (length(coords)>2) {
			
			find_coords <- c("coord","y","Y","Coord","WGS","UTM")
			cond <- array(FALSE,length(names(out)))
			names(cond) <- names(out)
			
			for (cordit in find_coords) {
				
				cond <- cond | str_detect(names(out),cordit) 
				
			}
			
			coords <- names(out)[cond]
			
		}
		
		
		attr(out,"coords") <- paste(coords,collapse=" AND ")
		
		
		
		
		
	} else {
		
		attr(out,"coords") <-  "NOT IN DATA"
	}
	
	return(out)
	
	
	
}