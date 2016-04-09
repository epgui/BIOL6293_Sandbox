library(sp)
library(rgeos)
library(maptools)
setwd("C:/Users/Francois/Documents/R/Spatial_analysis/ShaleGas")
#Lis la carte des comtés du Nouveau-Brunswick disponible sur GéoNB
comtes <- readShapePoly("geonb_county-comte_shp/geonb_county-comte.shp")
summary(comtes)
#Initialise la projection EPSG 2953 utilisés par la carte du NB
crs <- CRS("+init=epsg:2953")
proj4string(comtes) <- crs
summary(comtes)
#Crée un systéme de coordonnées(projection) pour la carte du Nouveau-Brunswick utilisant les longitudes et latitudes et le datum WGS84
wgs.84 <- "+proj=longlat +datum=WGS84"
#Transforme la projection EPSG 2953 en projection wgs.84
comteswgs.84 <- spTransform(comtes, CRS(wgs.84))
summary(comteswgs.84)
#Lis le fichier comportant les coordonnées (longitude, latitude) des échantillons d'eaux souterraines du comtés de KENT
coordonnees <- read.table("coordonnees.txt", sep = "\t", header = TRUE)
#Crée une copie des coordonées pour les labels
coordonnees2 <- read.table("coordonnees.txt", sep = "\t", header = TRUE)
#La longitude est contenue dans la colonne 3 du fichier alors que la latitude est dans la colonne 2
coordonnees
#Transforme les coordonnées présente dans le fichier en objet spatiale en l'occurence, des points.
coordinates(coordonnees) <- c(3,2)
class(coordonnees)
summary(coordonnees)
#Initialise la projection des coordonnées en wgs.84 é l'aide de epsg:4326
crs2 <- CRS("+init=epsg:4326")
proj4string(coordonnees) <- crs2
summary(coordonnees)

#Fais un graphique de KENT et Westmorland avec les points de ceuillettes des échantillons
plot(comteswgs.84[5,], xlab = "Longitude", ylab = "Latitude", axes = TRUE, main = "Comté de KENT")
plot(comteswgs.84[9,], add=TRUE)
plot(coordonnees, pch =21, cex = 0.7, bg="dodgerblue", add = TRUE)
#labels
pointLabel(coordonnees2$long, coordonnees2$lat, labels = coordonnees$ID, cex = 0.7, allowSmallOverlap = FALSE, col ="darkolivegreen")
library(GISTools)
north.arrow(-64.65445,46.93657,len = 0.02, "N", col="light gray")
#library(SDMTools)
#Scalebar(-65.66533, 46.93655, distance = 1, unit = "km", scale = 0.01, t.cex = 0.7)

#comtés de Kings
coordonneeskings <- read.table("coordonneskings.txt", sep = "\t", header = TRUE)
coordonneeskings2 <- read.table("coordonneskings.txt", sep = "\t", header = TRUE)
coordinates(coordonneeskings) <- c(3,2)
proj4string(coordonneeskings) <- crs2
summary(coordonneeskings)

#Fait un graphique de Kings avec les points de ceuillettes des échantillons
plot(comteswgs.84[8,], xlab = "Longitude", ylab = "Latitude", axes = TRUE, main = "Comté de KINGS")
plot(coordonneeskings, pch =21, cex = 0.7, bg="dodgerblue", add = TRUE)
#labels
pointLabel(coordonneeskings2$long, coordonneeskings2$lat, labels = coordonneeskings$ID, cex = 0.7, allowSmallOverlap = FALSE, col ="darkolivegreen")
north.arrow(-65.2000,45.9600,len = 0.02, "N", col="light gray")
#map.scale(-66.5000, 46.0000, len = 0.3, "km", ndivs = 5, subdiv = 2, tcol='black',scol='black',sfcol='black')

#comtés de Albert
coordonneesalbert <- read.table("coordonneshills.txt", sep = "\t", header = TRUE)
coordonneesalbert2 <- read.table("coordonneshills.txt", sep = "\t", header = TRUE)
coordinates(coordonneesalbert) <- c(3,2)
proj4string(coordonneesalbert) <- crs2
summary(coordonneesalbert)

#Fait un graphique du comtés de Albert avec les points de ceuillettes des échantillons prés de Hillsborough
plot(comteswgs.84[14,], xlab = "Longitude", ylab = "Latitude", axes = TRUE, main = "Comté de Albert")
plot(coordonneesalbert, pch =21, cex = 0.7, bg="dodgerblue", add = TRUE)
#labels
pointLabel(coordonneesalbert2$long, coordonneesalbert2$lat, labels = coordonneesalbert$ID, cex = 0.7, allowSmallOverlap = FALSE, col ="darkolivegreen")
north.arrow(-64.6000,46.0500,len = 0.01, "N", col="light gray")
#map.scale(-65.3000, 46.0000, len = 0.3, "km", ndivs = 5, subdiv = 2, tcol='black',scol='black',sfcol='black')

#Carte composite NB
plot(comteswgs.84, main = "Nouveau-Brunswick")
plot(coordonnees, pch =21,cex = 0.5, bg="dodgerblue", axes = TRUE, add = TRUE)
plot(coordonneeskings, pch =21, cex = 0.5, bg="yellow", add = TRUE)
plot(coordonneesalbert, pch =21, cex = 0.5, bg="red", add = TRUE)
north.arrow(-64.000,47.0000,len = 0.09, "N", col="light gray")
#map.scale(-68.0000, 45.5000, len = 1, "km", ndivs = 5, subdiv = 2, tcol='black',scol='black',sfcol='black')

#Raster Brute
library(raster)
cell.length <- 0.2
bbox(comteswgs.84)
xmin <- bbox(comteswgs.84)[1,1]
xmax <- bbox(comteswgs.84)[1,2]
ymin <- bbox(comteswgs.84)[2,1]
ymax <- bbox(comteswgs.84)[2,2]
ncol <- round((xmax - xmin)/cell.length, 0)
nrow <- round((ymax - ymin)/cell.length, 0)
ncol
nrow
blank.grid <- raster(ncols=ncol, nrows=nrow, xmn=xmin, xmx=xmax, ymn=ymin, ymx=ymax)
dataconc <- read.table("concentrations.txt", sep = "\t", header = TRUE)
xs <- dataconc[,3]
ys <- dataconc[,2]
xy <- cbind(xs,ys)
x <- dataconc$Conc
land.grid = rasterize(xy, blank.grid, x, mean)
plot(comteswgs.84, main = "Nouveau-Brunswick", axes = TRUE)
plot(land.grid, add = TRUE, axes = FALSE)
#Changement de couleur et d'intervale.
library(classInt)
palette <- brewer.pal(5, "YlOrRd")
plot(land.grid, col=palette, main="Concentration en radium (pg/L) au Nouveau-Brunswick", axes = FALSE)
plot(comteswgs.84, add=TRUE, axes = FALSE)
north.arrow(-64.000,47.0000,len = 0.09, "N", col="light gray")

#Raster définition plus fine cell length plus petite
cell.length <- 0.03
bbox(comteswgs.84)
ncol2 <- round((xmax - xmin)/cell.length, 0)
nrow2 <- round((ymax - ymin)/cell.length, 0)
ncol2
nrow2
blank.grid2 <- raster(ncols=ncol2, nrows=nrow2, xmn=xmin, xmx=xmax, ymn=ymin, ymx=ymax)
land.grid2 = rasterize(xy, blank.grid2, x, mean)
plot(comteswgs.84, main = "Nouveau-Brunswick", axes = TRUE)
plot(land.grid2, add = TRUE, axes = FALSE)
#Changement de couleur et d'intervale.
plot(land.grid2, col=palette, main="Concentration en radium (pg/L) au Nouveau-Brunswick", axes = FALSE)
plot(comteswgs.84, add=TRUE, axes = FALSE)
north.arrow(-64.000,47.0000,len = 0.09, "N", col="light gray")
