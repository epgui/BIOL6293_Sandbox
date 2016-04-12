# BIOL6293 - Analyse statistique de données expérimentales
Exemples d'analyses statistiques avec données expérimentales, dans le cadre du cours BIOL6293:

* Les [données d'analyse spatiale](#spatial_analysis) font parti du projet de maîtrise à François
* Guillaume n'avait pas suffisamment de [données de cytométrie en flux](#flow_cytometry) pour en faire des analyses cohérentes,
mais on a trouvé des jeux de données similaires disponibles [en ligne](https://flowrepository.org/experiments/42)
pour en faire l'analyse. Seules les données de deux patients sont inclues dans le projet Github pour des raisons
de limites techniques: le jeu de données complet fait plusieurs Go en taille.

* L'installation de rgdal et de rgeos demande quelques étapes supplémentaires:
* http://tlocoh.r-forge.r-project.org/mac_rgeos_rgdal.html

### Part I : visualisation des données

## <a name="spatial_analysis">Analyse et statistiques spatiales</a>

[SA_1]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-1.PNG?raw=true "Graphique de Kent et Westmorland avec les points de cueillette des échantillons"
[SA_2]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-2.PNG?raw=true "Graphique de Kings avec les points de cueillette des échantillons"
[SA_3]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-3.PNG?raw=true "Graphique de Albert avec les points de cueillette des échantillons"
[SA_4]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-4.PNG?raw=true "Carte du Nouveau-Brunswick"
[SA_5]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-5.PNG?raw=true "raster NB"
[SA_6]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-6.PNG?raw=true "raster NB fine"
[SA_7]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-7.PNG?raw=true "Concentration par échantillon KENT"
[SA_8]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-8.png?raw=true "Corrélation de la concentrations en radium en fonction des voisins"
[SA_9]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-9.png?raw=true "Moran plot des concentrations en radium dans le comtés de KENT"
[SA_10]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-10.png?raw=true "Histogramme des concentrations en radium distribution générale"
[SA_11]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-11.png?raw=true "Histogramme des résidus de l'anova après transformation"
[SA_12]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-12.PNG?raw=true "Analyse des résidus après anova après transformation"
[SA_13]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-13.PNG?raw=true "ANOVA représentée graphiquement"

```

library(sp)
library(maptools)
library(classInt)
library(GISTools)
library(raster)
library(rgeos)    # Voir ci-dessus
library(rgdal)    # Voir ci-dessus
library(psych)
library(moments)

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
epsg.2953 <- "+init=epsg:2953 +proj=sterea +lat_0=46.5 +lon_0=-66.5 +k=0.999912 +x_0=2500000 +y_0=7500000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0
+units=m +no_defs"

#Lis le fichier comportant les coordonnées (longitude, latitude) des échantillons d'eaux souterraines du comtés de KENT
coordonnees <- read.table("coordonnees.txt", sep = "\t", header = TRUE)

#La longitude est contenue dans la colonne 3 du fichier alors que la latitude est dans la colonne 2
coordonnees

#Transforme les coordonnées présente dans le fichier en objet spatiale en l'occurence, des points.
coordinates(coordonnees) <- c(3,2)
class(coordonnees)
summary(coordonnees)

#Initialise la projection des coordonnées en wgs.84 à l'aide de epsg:4326
crs2 <- CRS("+init=epsg:4326")
proj4string(coordonnees) <- crs2
summary(coordonnees)

#Transforme la projection wgs 84 des points de coordonnées en projection EPSG2953 du Nouveau-Brunswick
coord.epsg2953 <- spTransform(coordonnees, CRS(epsg.2953))
summary(coord.epsg2953)

#Fais un graphique de KENT et Westmorland avec les points de ceuillettes des échantillons
plot(comtes[5,], xlab = "Longitude", ylab = "Latitude", axes = TRUE, main = "Comté de KENT")
plot(comtes[9,], add=TRUE)
plot(coord.epsg2953, pch =21, cex = 0.7, bg="dodgerblue", add = TRUE)

#labels
pointLabel(coord.epsg2953@coords, labels = coordonnees$ID, cex = 0.7, allowSmallOverlap = FALSE, col ="darkolivegreen", offset = 0)
north.arrow(2640000, 7545000,len = 1500, "N", col="light gray")
map.scale(2555000,7460000,10000,"km",5,subdiv=2,tcol='black',scol='black',sfcol='black')
>>
```

![Graphique de Kent et Westmorland avec les points de cueillette des échantillons][SA_1]

```

#comtés de Kings
coordonneeskings <- read.table("coordonneskings.txt", sep = "\t", header = TRUE)
coordinates(coordonneeskings) <- c(3,2)
proj4string(coordonneeskings) <- crs2
coord.kings <- spTransform(coordonneeskings, CRS(epsg.2953))

#Fait un graphique de Kings avec les points de ceuillettes des échantillons
plot(comtes[8,], xlab = "Longitude", ylab = "Latitude", axes = TRUE, main = "Comté de KINGS")
plot(coord.kings, pch =21, cex = 0.7, bg="dodgerblue", add = TRUE)

#labels
pointLabel(coord.kings@coords, labels = coordonneeskings$ID, cex = 0.7, allowSmallOverlap = FALSE, col ="darkolivegreen", offset = 0)
north.arrow(2600000, 7440000,len = 1500, "N", col="light gray")
map.scale(2510000,7350000,10000,"km",5,subdiv=2,tcol='black',scol='black',sfcol='black')

```

![Graphique de Kings avec les points de cueillette des échantillons][SA_2]

```
#comtés de Albert
coordonneesalbert <- read.table("coordonneshills.txt", sep = "\t", header = TRUE)
coordinates(coordonneesalbert) <- c(3,2)
proj4string(coordonneesalbert) <- crs2
coord.albert <- spTransform(coordonneesalbert, CRS(epsg.2953))

#Fait un graphique du comtés de Albert avec les points de ceuillettes des échantillons près de Hillsborough
plot(comtes[14,], xlab = "Longitude", ylab = "Latitude", axes = TRUE, main = "Comté de Albert")
plot(coord.albert, pch =21, cex = 0.7, bg="dodgerblue", add = TRUE)

#labels
pointLabel(coord.albert@coords, labels = coordonneesalbert$ID, cex = 0.7, allowSmallOverlap = FALSE, col ="darkolivegreen", offset = 0)
north.arrow(2647000, 7450000,len = 1000, "N", col="light gray")
map.scale(2605000,7440000,10000,"km",5,subdiv=2,tcol='black',scol='black',sfcol='black')

```

![Graphique de Albert avec les points de cueillette des échantillons][SA_3]

```

#Carte composite NB
plot(comtes, main = "Nouveau-Brunswick", axes = FALSE)
plot(coord.epsg2953, pch =21,cex = 0.5, bg="dodgerblue", add = TRUE)
plot(coord.kings, pch =21, cex = 0.5, bg="yellow", add = TRUE)
plot(coord.albert, pch =21, cex = 0.5, bg="red", add = TRUE)
north.arrow(2660000, 7550000,len = 5000, "N", col="light gray")
map.scale(2350000,7310000,100000,"km",5,subdiv=20,tcol='black',scol='black',sfcol='black')

```

![Carte du Nouveau-Brunswick avec points d'échantillonnage][SA_4]

```

#Raster Brute
cell.length <- 0.2
comtes2 <- spTransform(comtes, CRS(wgs.84))
bbox(comtes2)
xmin <- bbox(comtes2)[1,1]
xmax <- bbox(comtes2)[1,2]
ymin <- bbox(comtes2)[2,1]
ymax <- bbox(comtes2)[2,2]
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
plot(comtes2, main = "Nouveau-Brunswick", axes = TRUE)
plot(land.grid, add = TRUE, axes = FALSE)

#Changement de couleur et d'intervale.
palette <- brewer.pal(5, "YlOrRd")
plot(land.grid, col=palette, main="Concentration en radium (pg/L) au Nouveau-Brunswick", axes = FALSE)
plot(comtes2, add=TRUE, axes = FALSE)
north.arrow(-64.000,47.0000,len = 0.09, "N", col="light gray")

```

![Carte raster du Nouveau-Brunswick avec définition brute][SA_5]

```

#Raster définition plus fine cell length plus petite
cell.length <- 0.03
bbox(comtes2)
ncol2 <- round((xmax - xmin)/cell.length, 0)
nrow2 <- round((ymax - ymin)/cell.length, 0)
ncol2
nrow2
blank.grid2 <- raster(ncols=ncol2, nrows=nrow2, xmn=xmin, xmx=xmax, ymn=ymin, ymx=ymax)
land.grid2 = rasterize(xy, blank.grid2, x, mean)
plot(comtes2, main = "Nouveau-Brunswick", axes = TRUE)
plot(land.grid2, add = TRUE, axes = FALSE)

#Changement de couleur et d'intervale.
plot(land.grid2, col=palette, main="Concentration en radium (pg/L) au Nouveau-Brunswick", axes = FALSE)
plot(comtes2, add=TRUE, axes = FALSE)
north.arrow(-64.000,47.0000,len = 0.09, "N", col="light gray")

```

![Carte raster du Nouveau-Brunswick avec définition fine][SA_6]

```

#Représentation des échantillons de Kent en fonction de leurs concentrations en radium
class(coord.epsg2953)
conc <- coordonnees$Conc
break.points <- c(0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35)
groups <- cut(conc, break.points, include.lowest = TRUE, label = FALSE)
palette2 <- brewer.pal(7, "YlOrRd")
plot(comtes[5,], axes = TRUE, main = "Concentration en radium dans les eaux souterraines de puits du comté de Kent")
plot(coord.epsg2953, pch = 21, bg = palette2[groups], add = TRUE)
north.arrow(2640000, 7545000,len = 1500, "N", col="light gray")
map.scale(2640000,7565000,10000,"km",5,subdiv=2,tcol='black',scol='black',sfcol='black')
legend(2550000, 7565000, legend=c("<0.05","0.05 à 0.1", "0.1 à 0.15", "0.15 à 0.2","0.2 à 0.25", "0.25 à 0,30", ">0.30"), pch=21, pt.bg=palette2, cex=0.6, title="Concentration Ra (pg/L)")
pointLabel(coord.epsg2953@coords, labels = coordonnees$ID, cex = 0.7, allowSmallOverlap = FALSE, col ="darkolivegreen")

```

![Représentation des échantillons de Kent en fonction de leurs concentrations en radium][SA_7]

```

###Part II : Analyse

```

#Analyse spatiale recherche du voisin
library(spdep)
knn1 <- knearneigh(coord.epsg2953, k = 1, longlat = FALSE, RANN = FALSE)$nn
knn1
cor.test(coord.epsg2953$Conc, coord.epsg2953$Conc[knn1])

```

`> cor.test(coord.epsg2953$Conc, coord.epsg2953$Conc[knn1])

	Pearson's product-moment correlation

data:  coord.epsg2953$Conc and coord.epsg2953$Conc[knn1]
t = 2.282, df = 44, p-value = 0.02738
alternative hypothesis: true correlation is not equal to 0
95 percent confidence interval:
 0.03866938 0.56249265
sample estimates:
      cor 
0.3253155`

```

#Trouve les 45 plus proche voisin
knear45 <- knearneigh(coord.epsg2953, k=45, longlat = FALSE, RANN=FALSE)

#Crée un objet pour stocker les corrélations
correlations <- vector(mode="numeric", length=45)

for (i in 1: 45) {
  correlations[i] <- cor(coord.epsg2953$Conc, coord.epsg2953$Conc[knear45$nn[,i]])
}
correlations

plot(correlations, xlab="nth nearest neighbour", ylab="Correlation")
lines(lowess(correlations, f=1/10), col="blue")		# Ajoute une ligne entre chaque point

```

![Graphique correlation de la concentration en radium entre voisins dans KENT][SA_8]

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
  p <- p + theme(panel.background = element_rect(fill='white'), panel.grid.major = element_line(colour="#DDDDDD", size=0.5), panel.grid.minor = element_line(colour="#DDDDDD", size=0.5))
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
