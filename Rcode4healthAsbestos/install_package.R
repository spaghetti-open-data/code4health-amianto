#! /usr/bin/Rscript

# file install_packege.R
#
# This file roxygenizes all documentation wriiten in "Roxygen" format.
#
# author: Emanuele Cordano on 24-05-2016
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

###############################################################################
library(roxygen2)

options(repos = c(CRAN="http://cran.r-project.org"))

path <- "/home/ecor/Dropbox/R-packages/code4health-amianto"
pkg_name <- "Rcode4healthAsbestos"
pkg_dir <- paste(path,pkg_name,sep="/")



roxygenize(pkg_dir,clean=TRUE)

#roxygen.dir=pkg_dir copy.package=FALSE,unlink.target=FALSE

## installation
oo <- installed.packages()
if (pkg_name %in% oo[,"Package"]) {
	
	
	vv <-as.character(packageVersion(pkg_name))
	vv1 <- as.character(packageVersion(pkg_name,lib.loc=path))
	print(vv)
	print(vv1)
	if (compareVersion(vv1,vv)>=0) {
		
		
		print("removing")
		remove.packages(pkg_name)
		install.packages(pkg_dir,type="source",repos=NULL)
	}
	
	
} else { 
	
	install.packages(pkg_dir,type="source",repos=NULL)
}

## 


