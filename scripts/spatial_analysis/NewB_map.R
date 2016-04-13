# L'installation de rgdal et de rgeos demande quelques étapes supplémentaires:
# http://tlocoh.r-forge.r-project.org/mac_rgeos_rgdal.html

#Part I visualisation des données

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


#Carte composite NB
plot(comtes, main = "Nouveau-Brunswick", axes = FALSE)
plot(coord.epsg2953, pch =21,cex = 0.5, bg="dodgerblue", add = TRUE)
plot(coord.kings, pch =21, cex = 0.5, bg="yellow", add = TRUE)
plot(coord.albert, pch =21, cex = 0.5, bg="red", add = TRUE)
north.arrow(2660000, 7550000,len = 5000, "N", col="light gray")
map.scale(2350000,7310000,100000,"km",5,subdiv=20,tcol='black',scol='black',sfcol='black')

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

#Part II : Analyse

#Analyse spatiale recherche du voisin
library(spdep)
knn1 <- knearneigh(coord.epsg2953, k = 1, longlat = FALSE, RANN = FALSE)$nn
knn1
cor.test(coord.epsg2953$Conc, coord.epsg2953$Conc[knn1])

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

#Création d'une matrice de poids basée sur la distance inverse
d.matrix <- spDists(coord.epsg2953, coord.epsg2953, longlat = FALSE)
d.matrix #Création d'une matrice de distance

#Détermine le nombre de points
np <- knear45$np
np

#Crée un vecteur pour stocké les poids
d.weights <- vector(mode="list", length=np)

for (i in 1:np) {						# Une boucle prenant chaque point
  neighbours <- knear45$nn[i,]		# Trouve les voisins pour le point i
  distances <- d.matrix[i,neighbours]	# Calcule la distance entre i et ses voisins
  d.weights[[i]] <- 1/distances^0.5	# Calcule un poids entre i et chaque voisin en fonction de la distance qui les séparent
}

head(knear45$nn, n=1)					# La liste des voisins
head(d.weights, n=1)					# La liste des poids correspondants

knear45nb <- knn2nb(knear45)
class(knear45nb)
knear45nb

#Examen de l'autoccorélation entre les points d'échantillons selon la concentration en radium
spknear45 <- nb2listw(knear45nb, glist=d.weights, style="C")
moran.plot(coord.epsg2953$Conc, spknear45, labels = TRUE)
moran.test(coord.epsg2953$Conc, spknear45)
moran.test(coord.epsg2953$Conc, listw2U(spknear45))

#Modèle pour déterminer ce qui influence la concentration en radium
modele1 <- lm(Conc ~ Age + Profondeur, data = coord.epsg2953)
summary(modele1)

#Comparaison entre les différents comtés.
concentrations <- read.table("concentrations.txt", sep = "\t", header = TRUE)
concentrations$Comtes <- as.factor(concentrations$Comtes)

describeBy(concentrations$Conc, concentrations$Comtes) #disponible library psych
hist(concentrations$Conc)

agostino.test(concentrations$Conc) #disponible library moments

anova <- aov(concentrations$Conc ~ concentrations$Comtes)
summary(anova)
hist(anova$residuals)
agostino.test(anova$residuals)
#Les résidus ne sont pas normalement distribués

logConc <- log10(concentrations$Conc+1)
anova2 <- aov(logConc ~ concentrations$Comtes)
summary(anova2)
hist(anova2$residuals)
agostino.test(anova2$residuals)
#Toujours pas

xConc <- 1/(1+concentrations$Conc)
anova3 <- aov(xConc ~ concentrations$Comtes)
summary(anova3)
hist(anova3$residuals)
agostino.test(anova3$residuals)

sqrtlogConc <- sqrt(logConc)
anova4 <- aov(sqrtlogConc ~ concentrations$Comtes)
summary(anova4)
hist(anova4$residuals)
agostino.test(anova4$residuals)
summary(anova4$residuals)

#Présentation des résidus
layout(matrix(1:4, 2, 2))
plot(lm(sqrtlogConc ~ concentrations$Comtes), which = 1:4)

#Représentation graphique anova
layout(matrix(1))
plot(concentrations$Comtes, sqrtlogConc, xlab = "comtés", ylab = "sqrt(log10(Conc+1))", col = c("brown1", "lightblue", "darkgoldenrod1"), axes =TRUE, main="Comparaison ANOVA concentration en radium par comté")

#Comparaisons planifié KENT et HILLS et KINGS et HILLS
contrasts(concentrations$Comtes) <- cbind(c(-1,1,0), c(1,0,-1))
contrasts(concentrations$Comtes)
summary.lm(anova4)

#Comparaison non-planifié
anova(anova4)
TukeyHSD(anova4)

#Filtrés vs Non-Filtrés

filtre <- read.table("Filtre.txt", sep = "\t", header = TRUE)
filtre

plot(filtre$Filtre, filtre$nFiltre, axes = FALSE, main = "Échantillons filtrés vs non-filtrés, spéciation du radium", xlab = "Filtrés", ylab = "Non-Filtrés")
axis(1, pos = 0)
axis(2, pos = 0)

filtrelm <- lm(nFiltre ~ Filtre, data = filtre)
summary(filtrelm)
abline(filtrelm$coefficients, col = "red")

hist(filtre$Filtre)
hist(filtre$nFiltre)
shapiro.test(filtre$Filtre)
shapiro.test(filtre$nFiltre)

logfiltre <- sqrt(log10(filtre$Filtre +1))
lognfiltre <- sqrt(log10(filtre$nFiltre +1))

hist(logfiltre)
hist(lognfiltre)
shapiro.test(logfiltre)
shapiro.test(lognfiltre)

plot(logfiltre, lognfiltre, axes = TRUE, main = "Échantillons filtrés vs non-filtrés, spéciation du radium", xlab = "tFiltrés", ylab = "tNon-Filtrés")
tfiltrelm <- lm(logfiltre ~ lognfiltre)
summary(tfiltrelm)
abline(tfiltrelm$coefficients, col = "blue")
hist(tfiltrelm$residuals)
shapiro.test(tfiltrelm$residuals)

var.test(logfiltre, lognfiltre)

t.test(logfiltre, lognfiltre, var.equal = TRUE)