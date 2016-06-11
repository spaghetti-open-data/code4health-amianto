##14;"CO009002007";"COMUNE DI ALBENGA";17031;"ALBENGA";"SV";1437448;4877268;;;702;2;2;2;1;1;5;10;1;1;;5;5;1;;;;1;10;5;4;10
###15;"CO009002008";"COMUNE DI ALBENGA";17031;"ALBENGA";"SV";436958,87;4877628,04;;;109;5;2;1;2;2;10;10;1;1;;9;;3;;;;1;5;5;;
library(sp)

xy1 <- data.frame(x=1437448,y=4877268)


xy2 <- data.frame(x=436958.87,y=4877628.04)

pr1 <- CRS("+proj=tmerc +lat_0=0 +lon_0=9 +k=0.9996 +x_0=1500000 +y_0=0 +ellps=intl +units=m +no_defs ")



pr2 <- CRS("+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")


coordinates(xy1) <- ~x+y
coordinates(xy2) <- ~x+y

proj4string(xy1) <- pr1
proj4string(xy2) <- pr2

xy1p <- spTransform(xy1,CRSobj=pr2)


