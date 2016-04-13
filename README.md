# BIOL6293 - Analyse statistique de données expérimentales
Exemples d'analyses statistiques avec données expérimentales, dans le cadre du cours BIOL6293:

* Les [données d'analyse spatiale](#spatial_analysis) font parti du projet de maîtrise à François
* Guillaume n'avait pas suffisamment de [données de cytométrie en flux](#flow_cytometry) pour en faire des analyses cohérentes,
mais on a trouvé des jeux de données similaires disponibles [en ligne](https://flowrepository.org/experiments/42)
pour en faire l'analyse. Seules les données de deux patients sont inclues dans le projet Github pour des raisons
de limites techniques: le jeu de données complet fait plusieurs Go en taille.

## <a name="spatial_analysis">Analyse et statistiques spatiales</a>

[SA_1]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA_1.png?raw=true "Graphique de Kent et Westmorland avec les points de cueillette des échantillons"
[SA_2]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA_2.png?raw=true "Graphique de Kent et Westmorland avec les points de cueillette des échantillons"
[SA_3]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA_3.png?raw=true "Graphique de Kent et Westmorland avec les points de cueillette des échantillons"

```
library(sp)
library(rgeos)
library(maptools)
library(classInt)
library(GISTools)
library(raster)
library(rgdal)
#library(SDMTools)

# Solution for file path found here: https://gist.github.com/jennybc/362f52446fe1ebc4c49f
setwd(file.path(PROJHOME, "data"))

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
>>
```

![Graphique de Kent et Westmorland avec les points de cueillette des échantillons][SA_1]

```
plot(comteswgs.84[9,], add=TRUE)
>>
```

![Graphique de Kent et Westmorland avec les points de cueillette des échantillons][SA_2]

```
plot(coordonnees, pch =21, cex = 0.7, bg="dodgerblue", add = TRUE)
>>
```

![Graphique de Kent et Westmorland avec les points de cueillette des échantillons][SA_3]

```
#labels
pointLabel(coordonnees2$long, coordonnees2$lat, labels = coordonnees$ID, cex = 0.7, allowSmallOverlap = FALSE, col ="darkolivegreen")
north.arrow(-64.65445,46.93657,len = 0.02, "N", col="light gray")

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
```

## <a name="flow_cytometry">Analyse statistique de cytométrie en flux</a>
[FC_1]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_1.png?raw=true "FS pour tous les jeux de données"
[FC_2]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_2.png?raw=true "Graphe de SS et FS pour le premier jeu de données"
[FC_3]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_3.png?raw=true "Plot all of the things like it's your last day on earth"

Vérifiez que vous avez bel et bien la dernière version de R à partir de la console de R:

`> version`

Vous pouvez obtenir la dernière version de R ici: https://www.r-project.org/

### Installation de Bioconductor
Pour accéder aux librairies de cytométrie en flux, il faut d'abord installer Bioconductor.
Dans la console de R, tappez:

`> setRepositories()`

Ensuite, sélectionnez CRAN et BioC software, par exemple en tappant dans la console de R, selon les
options qui vous sont présentées:

`> 1 2`

Vous pouvez maintenant accéder aux librairies de Bioconductor (sauf flowQ qui ne marchera pas encore)
à partir de R ou de RStudio!

### Installation de flowStats
flowStats peut vous donner de la misère avec rgl (un dependency) si votre version de X11 n'est pas à jour.
Vous pouvez télécharger la dernière vesion de X11 pour Mac ici: http://www.xquartz.org/

### Installation de flowQ
Attention! flowQ dépend de ImageMagick, que vous pouvez installer à partir des binaries suivants:
* Mac: http://www.imagemagick.org/script/binary-releases.php#macosx
* Win: http://www.imagemagick.org/script/binary-releases.php#windows

Sur Mac, la manière la plus simple d'installer ImageMagick est de dabord installer "Xcode Command Line Tools"
à partir du Terminal:

`$ xcode-select --install`

puis d'installer MacPorts ici: https://www.macports.org/install.php
puis d'installer ImageMagick à partir du Terminal:

`$ sudo port install ImageMagick`

Sur Mac, vous pouvez tester le succès de l'installation en tappant dans le Terminal:

`$ which convert`

Ça devrait donner un résultat qui ressemble à quelque chose comme `"/opt/local/bin/convert"`. Si ça vous donne
une erreur, ImageMagick n'est pas bien installé.

Sur Windows, bonne chance!

### Analyse

```
library(flowCore)  # Bioconductor
library(flowQ)     # Bioconductor + imagemagick
library(flowViz)   # Bioconductor
library(flowStats) # Bioconductor
library(flowClust) # Bioconductor
library(openCyto)  # Bioconductor
library(ggplot2)

setwd(file.path(PROJHOME, "data"))

# Fetch data
pt4_fclist <- c("4 Normal/0025.FCS",
                "4 Normal/0026.FCS",
                "4 Normal/0027.FCS",
                "4 Normal/0028.FCS",
                "4 Normal/0029.FCS",
                "4 Normal/0030.FCS",
                "4 Normal/0031.FCS",
                "4 Normal/0032.FCS")
pt5_fclist <- c("5 AML/0033.FCS",
                "5 AML/0034.FCS",
                "5 AML/0035.FCS",
                "5 AML/0036.FCS",
                "5 AML/0037.FCS",
                "5 AML/0038.FCS",
                "5 AML/0039.FCS",
                "5 AML/0040.FCS")

# À l'aide de la librairie flowCore, générer des objets de type 'flowSet' à partir des données brutes
pt4_fs <- read.flowSet(pt4_fclist, dataset=2, transformation=FALSE, alter.names=TRUE)
pt5_fs <- read.flowSet(pt5_fclist, dataset=2, transformation=FALSE, alter.names=TRUE)

channelList <- c("FS", "SS", "FL1", "FL2", "FL3", "FL4", "FL5")

# Truncate extreme values
largest_FS <- tail(sort(as.numeric(exprs(pt4_fs[[1]][,1])[,1])), 1)
filter_result <- filter(pt4_fs, rectangleGate("FS" = c(-Inf, largest_FS)))
pt4_fs_trunc <- Subset(pt4_fs, filter_result)

# Play with density plot to find optimal values for logicle transform
densityplot(~`SS`, pt4_fs_trunc, xlim=c(0,50000))
```

![FS pour tous les jeux de données][FC_1]

```
#lgcl <- estimateLogicle(pt4_fs[[2]], channels=channelList)
lgcl_FS <- logicleTransform(w=0.6, t=1300000, m=4.5, a=0)
lgcl_SS <- logicleTransform(w=0.5, t=500, m=3, a=0)
tData <- transform(pt4_fs_trunc, FS=lgcl_FS(FS), SS=lgcl_SS(SS))

make.nice.plot <- function(data, mapping)
{
  binningVector <- c(0.2,0.15)
  p <- ggplot(data=as.data.frame(data), mapping=mapping)
  p <- p + geom_point(alpha=0.03, color="#051A2D")
  p <- p + stat_density2d(aes(fill=..level..), col='white', size=0.15, geom="polygon", h=binningVector)
  p <- p + labs(title="Patient 4 (données partielles: 1 de 8)", x="FSC (logicle)", y="SSC (logicle)")
  p <- p + theme(plot.title = element_text(size=20, face="bold", vjust=1.5, family="Helvetica Neue"))
  p <- p + theme(axis.title.y = element_text(size=16), axis.title.x = element_text(size=16))
  p <- p + theme(axis.ticks.y = element_blank(), axis.ticks.x = element_blank())
  p <- p + theme(axis.text.y = element_blank(), axis.text.x = element_blank())
  p <- p + theme(legend.position = "none")
  p <- p + theme(panel.background = element_rect(fill='white'),
                 panel.grid.major = element_line(colour="#DDDDDD", size=0.5),
                 panel.grid.minor = element_line(colour="#DDDDDD", size=0.5))
  p <- p + theme(panel.border = element_rect(fill=NA, colour='black', size=1))
  p <- p + scale_x_continuous(expand=c(0,0))
  p <- p + scale_y_continuous(expand=c(0,0))
  p <- p + theme(aspect.ratio = 1)
  p
}

# Plot one thing
thing <- exprs(tData[[1]])
make.nice.plot(thing, aes(x=FS,y=SS))
```

![Graphe de SS et FS pour le premier jeu de données][FC_2]

```
# Plot all of the things
ggpairs(thing, lower = list(continuous = make.nice.plot))

```

![Plot all of the things like it's your last day on earth][FC_3]
