# BIOL6293 - Analyse statistique de données expérimentales
Exemples d'analyses statistiques avec données expérimentales, dans le cadre du cours BIOL6293:

* Les [données d'analyse spatiale](#spatial_analysis) font parti du projet de maîtrise à François
* Guillaume n'avait pas suffisamment de [données de cytométrie en flux](#flow_cytometry) pour en faire des analyses cohérentes,
mais on a trouvé des jeux de données similaires disponibles [en ligne](https://flowrepository.org/experiments/42)
pour en faire l'analyse. Seules les données de deux patients sont inclues dans le projet Github pour des raisons
de limites techniques: le jeu de données complet fait plusieurs Go en taille.


## <a name="spatial_analysis">Analyse et statistiques spatiales</a>

### Part I : visualisation des données

Avant d'utiliser les librairies rgdal et rgeos dans R, on doit installer les logiciels gdal et geos: http://tlocoh.r-forge.r-project.org/mac_rgeos_rgdal.html

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



###Part II : Analyse

```

#Analyse spatiale recherche du voisin
library(spdep)
knn1 <- knearneigh(coord.epsg2953, k = 1, longlat = FALSE, RANN = FALSE)$nn
knn1
cor.test(coord.epsg2953$Conc, coord.epsg2953$Conc[knn1])

```

> cor.test(coord.epsg2953$Conc, coord.epsg2953$Conc[knn1])

>Pearson's product-moment correlation

>data:  coord.epsg2953$Conc and coord.epsg2953$Conc[knn1]

>t = 2.282, df = 44, p-value = 0.02738

>alternative hypothesis: true correlation is not equal to 0

>95 percent confidence interval:

> 0.03866938 0.56249265

>sample estimates:
>      cor
>	0.3253155

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

#Création d'une matrice de poids basée sur la distance inverse
d.matrix <- spDists(coord.epsg2953, coord.epsg2953, longlat = FALSE)
d.matrix #Création d'une matrice de distance

#Détermine le nombre de points
np <- knear45$np
np

```

>46


```

#Crée un vecteur pour stocké les poids
d.weights <- vector(mode="list", length=np)

for (i in 1:np) {						# Une boucle prenant chaque point
  neighbours <- knear45$nn[i,]		# Trouve les voisins pour le point i
  distances <- d.matrix[i,neighbours]	# Calcule la distance entre i et ses voisins
  d.weights[[i]] <- 1/distances^0.5	# Calcule un poids entre i et chaque voisin en fonction de la distance qui les séparent
}

head(knear45$nn, n=1)					# La liste des voisins
head(d.weights, n=1)					# La liste des poids correspondants

```

> head(knear45$nn, n=1)					# La liste des voisins
     [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11] [,12] [,13] [,14] [,15] [,16] [,17] [,18] [,19] [,20] [,21] [,22] [,23] [,24] [,25]
[1,]   12    2   36    4   42   38   30   41    3    35     7     8    13    31    28     5     6    39    11    26    19    20    37    10    18
     [,26] [,27] [,28] [,29] [,30] [,31] [,32] [,33] [,34] [,35] [,36] [,37] [,38] [,39] [,40] [,41] [,42] [,43] [,44] [,45]
[1,]    27    15    23    17    43    33     9    16    32    34    22    21    14    25    40    24    44    46    45    29

> head(d.weights, n=1)					# La liste des poids correspondants
[[1]]
 [1] 0.073842652 0.011499389 0.011046278 0.010463427 0.010377768 0.010226429 0.010213943 0.010003307 0.008616610 0.008556768 0.008503951
[12] 0.008458228 0.008449261 0.008277297 0.008273555 0.008222866 0.008148792 0.008121341 0.007919839 0.007700053 0.007195550 0.006922693
[23] 0.006847181 0.006765893 0.006597946 0.006360170 0.006046376 0.005968267 0.005953109 0.005883492 0.005833687 0.005829958 0.005746118
[34] 0.005733636 0.005680487 0.005645019 0.005218810 0.005166379 0.005134100 0.005091814 0.005071874 0.004332457 0.004082338 0.004037346
[45] 0.003643757

```

knear45nb <- knn2nb(knear45)
class(knear45nb)
knear45nb

#Examen de l'autoccorélation entre les points d'échantillons selon la concentration en radium
spknear45 <- nb2listw(knear45nb, glist=d.weights, style="C")
moran.plot(coord.epsg2953$Conc, spknear45, labels = TRUE)
moran.test(coord.epsg2953$Conc, spknear45)
moran.test(coord.epsg2953$Conc, listw2U(spknear45))

```

![Moran Plot pour le comte de KENT][SA_9]

> moran.test(coord.epsg2953$Conc, listw2U(spknear45))
>
>Moran I test under randomisation
>
>data:  coord.epsg2953$Conc  
>weights: listw2U(spknear45)  
>
>Moran I statistic standard deviate = -0.97645, p-value = 0.8356

>alternative hypothesis: greater

>sample estimates:

>Moran I statistic		 Expectation		 Variance

>      -0.03682426       -0.02222222        0.00022363

```

#Modèle pour déterminer ce qui influence la concentration en radium
modele1 <- lm(Conc ~ Age + Profondeur, data = coord.epsg2953)
summary(modele1)

```

> summary(modele1)

> Call:

> lm(formula = Conc ~ Age + Profondeur, data = coord.epsg2953)
>
> Residuals:

>      Min        1Q    Median        3Q       Max

> -0.119869 -0.055732 -0.009389  0.035900  0.214515
>
> Coefficients:

>               Estimate Std. Error t value Pr(>|t|)   

> (Intercept)  1.172e-01  3.838e-02   3.053  0.00397 **

> Age         -1.515e-03  1.090e-03  -1.390  0.17206   

> Profondeur   9.341e-05  2.607e-04   0.358  0.72197   
>
> Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
>
> Residual standard error: 0.08431 on 41 degrees of freedom

>  (2 observations deleted due to missingness)

> Multiple R-squared:  0.05209,	Adjusted R-squared:  0.005852

> F-statistic: 1.127 on 2 and 41 DF,  p-value: 0.334

```

#Comparaison entre les différents comtés.
concentrations <- read.table("concentrations.txt", sep = "\t", header = TRUE)
concentrations$Comtes <- as.factor(concentrations$Comtes)

describeBy(concentrations$Conc, concentrations$Comtes) #disponible library psych
hist(concentrations$Conc)

```


>group: HILLS    
  vars  n mean   sd median trimmed  mad min  max range skew kurtosis   se    
1    1 14 0.05 0.06   0.03    0.04 0.04   0 0.18  0.18 0.88    -0.83 0.02    
`-------------------------------------------------------------------------------------------------------------`
>group: KENT   
  vars  n mean   sd median trimmed  mad min max range skew kurtosis   se   
1    1 46 0.09 0.08   0.07    0.08 0.07   0 0.3   0.3  1.1      0.2 0.01    
`-------------------------------------------------------------------------------------------------------------`
>group: KINGS   
  vars n mean   sd median trimmed  mad  min  max range skew kurtosis   se   
1    1 7 0.06 0.03   0.06    0.06 0.03 0.02 0.11   0.1 0.27    -1.53 0.01    

```

 anova <- aov(concentrations$Conc ~ concentrations$Comtes)
 summary(anova)
                      Df Sum Sq Mean Sq F value Pr(F)
concentrations$Comtes  2 0.0258 0.01292   2.194   0.12
Residuals             64 0.3770 0.00589               
 hist(anova$residuals)
 agostino.test(anova$residuals)

	D'Agostino skewness test

data:  anova$residuals
skew = 1.1799, z = 3.6102, p-value = 0.0003059
alternative hypothesis: data have a skewness

 #Les résidus ne sont pas normalement distribués

 logConc <- log10(concentrations$Conc+1)
 anova2 <- aov(logConc ~ concentrations$Comtes)
 summary(anova2)
                      Df  Sum Sq   Mean Sq F value Pr(F)
concentrations$Comtes  2 0.00393 0.0019657   2.244  0.114
Residuals             64 0.05606 0.0008759               
 hist(anova2$residuals)
 agostino.test(anova2$residuals)

	D'Agostino skewness test

data:  anova2$residuals
skew = 1.0565, z = 3.3189, p-value = 0.0009038
alternative hypothesis: data have a skewness

 #Toujours pas

 xConc <- 1/(1+concentrations$Conc)
 anova3 <- aov(xConc ~ concentrations$Comtes)
 summary(anova3)
                      Df  Sum Sq  Mean Sq F value Pr(F)
concentrations$Comtes  2 0.01701 0.008507   2.297  0.109
Residuals             64 0.23703 0.003704               
 hist(anova3$residuals)
 agostino.test(anova3$residuals)

	D'Agostino skewness test

data:  anova3$residuals
skew = -0.93883, z = -3.02300, p-value = 0.002503
alternative hypothesis: data have a skewness


 sqrtlogConc <- sqrt(logConc)
 anova4 <- aov(sqrtlogConc ~ concentrations$Comtes)
 summary(anova4)
                      Df Sum Sq  Mean Sq F value Pr(F)  
concentrations$Comtes  2 0.0580 0.029005   3.784  0.028 *
Residuals             64 0.4906 0.007665                 
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
 hist(anova4$residuals)
 agostino.test(anova4$residuals)

```

![Histogramme des residus apres anova sur les données transformees][SA_11]

```
 D'Agostino skewness test

data:  anova4$residuals
skew = 0.13719, z = 0.49825, p-value = 0.6183
alternative hypothesis: data have a skewness

 summary(anova4$residuals)
     Min.   1st Qu.    Median      Mean   3rd Qu.      Max.
-0.175000 -0.066140 -0.003878  0.000000  0.049600  0.164600

 #Présentation des résidus
 layout(matrix(1:4, 2, 2))
 plot(lm(sqrtlogConc ~ concentrations$Comtes), which = 1:4)  

```

![Presentation des residus apres anova][SA_12]

```

#Représentation graphique anova
layout(matrix(1))
plot(concentrations$Comtes, sqrtlogConc, xlab = "comtés", ylab = "sqrt(log10(Conc+1))", col = c("brown1", "lightblue", "darkgoldenrod1"), axes =TRUE, main="Comparaision ANOVA concentration en radium par comté")

```  

![Representation graphique de l'anova][SA_13]

```
#Comparaisons planifié KENT et HILLS et KINGS et HILLS
 contrasts(concentrations$Comtes) <- cbind(c(-1,1,0), c(1,0,-1))
 contrasts(concentrations$Comtes)
      [,1] [,2]
HILLS   -1    1
KENT     1    0
KINGS    0   -1
 summary.lm(anova4)

Call:
aov(formula = sqrtlogConc ~ concentrations$Comtes)

Residuals:
      Min        1Q    Median        3Q       Max
-0.174951 -0.066136 -0.003878  0.049600  0.164613

Coefficients:
                           Estimate Std. Error t value Pr(|t|)    
(Intercept)                 0.10166    0.02340   4.345 5.09e-05 ***
concentrations$ComtesKENT   0.07329    0.02672   2.743   0.0079 **
concentrations$ComtesKINGS  0.04869    0.04053   1.201   0.2340    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.08755 on 64 degrees of freedom
Multiple R-squared:  0.1057,	Adjusted R-squared:  0.0778
F-statistic: 3.784 on 2 and 64 DF,  p-value: 0.02797


 #Comparasion non-planifié
 anova(anova4)
Analysis of Variance Table

Response: sqrtlogConc
                      Df  Sum Sq   Mean Sq F value  Pr(F)  
concentrations$Comtes  2 0.05801 0.0290048   3.784 0.02797 *
Residuals             64 0.49056 0.0076651                  
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
 TukeyHSD(anova4)
  Tukey multiple comparisons of means
    95% family-wise confidence level

Fit: aov(formula = sqrtlogConc ~ concentrations$Comtes)

$`concentrations$Comtes`
                   diff          lwr        upr     p adj
KENT-HILLS   0.07329242  0.009171837 0.13741300 0.0212582
KINGS-HILLS  0.04869198 -0.048551702 0.14593565 0.4566905
KINGS-KENT  -0.02460044 -0.109826965 0.06062608 0.7686623

```














## <a name="flow_cytometry">Analyse statistique de cytométrie en flux</a>
[FC_workflow]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_workflow.png?raw=true "Workflow de cytométrie en flux"
[FC_0.1]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_0.1.png?raw=true "Graphe des données linéaires"
[FC_0.2]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_0.2.png?raw=true "Graphe des données transformées"
[FC_1]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_1.png?raw=true "FS pour tous les jeux de données"
[FC_1.1]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_1.1.png?raw=true "FS pour tous les jeux de données"
[FC_1.2]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_1.2.png?raw=true "FS pour tous les jeux de données"
[FC_2]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_2.png?raw=true "Graphe de SS et FS pour le premier jeu de données"
[FC_3]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_3.png?raw=true "Plot all of the things like it's your last day on earth"
[FC_3.1]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_3.1.png?raw=true "Plot all of the things like it's your last day on earth"
[FC_3.2]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_3.2.png?raw=true "Plot all of the things like it's your last day on earth"
[FC_4]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_4.png?raw=true "BIC of 10 clusters"
[FC_4.1]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/FC_4.1.png?raw=true "Résultats du clustering"

### Qu'est-ce que la cytométrie en flux?
C'est une technique excessivement populaire en biochimie et en biologie médicale, mais peut-être moins dans certaines branches de la biologie ou de l'écologie. Le principe est illustré ci-dessous:

![Workflow de cytométrie en flux][FC_workflow]






### Visualisation des données
L'instrument produit un fichier [de format standard .FCS](https://en.wikipedia.org/wiki/Flow_Cytometry_Standard) gigantesque qui contient l'information d'intensité lumineuse capté par les détecteurs [SSC, FSC](http://ricfacility.byu.edu/Research/CellSizeGranularity.aspx), et un certain nombre de détecteurs à fluorescence (par exemple FL1, FL2, FL3, FL4, FL5, FL6, FL7, ...) selon les marqueurs fluorescents et l'appareil utilisé, pour chaque 'événement' ou pour chaque cellule qui passe à travers le laser. Le premier problème, c'est de visualiser toutes ces données pour avoir une impression initiale de quoi il s'agit.

#### Préparation de l'environnement R
La cytométrie en flux est une technique excessivement populaire. Initialement, la seule manière d'analyser les données c'était d'avoir recours aux logiciels commerciaux qui viennent avec l'appareil ou qu'on peut acheter de commerçants indépendants. Tous les appareils ont leurs propres logiciels, et il existe une grande variété de logiciels disponibles. Le problème c'est que les méthodes d'analyse de ces logiciels ne sont pas open source, et c'est donc très suboptimal en termes de reproductibilité.

De plus en plus de solutions sont développées pour permettre l'analyse de données complexes de cytométrie en flux avec R. Voici un guide d'installation pour les librairies de base.

Vérifiez que vous avez bel et bien la dernière version de R à partir de la console de R:

`> version`

Vous pouvez obtenir la dernière version de R ici: https://www.r-project.org/

#### Installation de Bioconductor
Pour accéder aux librairies de cytométrie en flux, il faut d'abord installer Bioconductor. Pour plus d'infos, voir: https://www.bioconductor.org/install/

Dans la console de R, tappez:

`> setRepositories()`

Ensuite, sélectionnez CRAN et BioC software, par exemple en tappant dans la console de R, selon les
options qui vous sont présentées:

`> 1 2`

Vous pouvez maintenant accéder aux librairies de Bioconductor (sauf flowQ qui ne marchera pas encore)
à partir de R ou de RStudio!

#### Installation de flowStats
Voir la documentation: https://www.bioconductor.org/packages/release/bioc/html/flowStats.html

flowStats peut vous donner de la misère avec rgl (un dependency) si votre version de X11 n'est pas à jour.
Vous pouvez télécharger la dernière vesion de X11 pour Mac ici: http://www.xquartz.org/

#### Installation de flowQ
Voir la documentation: https://www.bioconductor.org/packages/release/bioc/html/flowQ.html

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

#### À propos des autres librairies de base
Consultez la documentation officielle pour les autres librairies de base pour la cytométrie en flux:
* [flowCore](http://bioconductor.org/packages/release/bioc/html/flowCore.html) (permet la manipulation de données de cytométrie en flux)
* [flowViz](http://bioconductor.org/packages/release/bioc/html/flowViz.html) (permet la visualisation des données de flowCore)
* [flowClust](http://bioconductor.org/packages/release/bioc/html/flowClust.html) (permet le clustering des données de flowCore)
* [openCyto](http://bioconductor.org/packages/release/bioc/html/openCyto.html) (framework d'analyses automatisées, qui fonctionne avec toutes les autres librairies)









#### Visualisation

```
library(flowCore)  # Bioconductor
library(flowQ)     # Bioconductor + imagemagick
library(flowViz)   # Bioconductor
library(flowStats) # Bioconductor
library(flowClust) # Bioconductor
library(openCyto)  # Bioconductor
library(ggplot2)

setwd(file.path(PROJHOME, "data"))

# Choisir les fichiers .FCS qu'on veut analyser et mettre leur path dans un vecteur de strings
pt4_fclist <- c("4 Normal/0025.FCS",
                "4 Normal/0026.FCS",
                "4 Normal/0027.FCS",
                "4 Normal/0028.FCS",
                "4 Normal/0029.FCS",
                "4 Normal/0030.FCS",
                "4 Normal/0031.FCS",
                "4 Normal/0032.FCS")
pt5_fclist <- c("5 AML/0033.FCS",      # OK bon oui ici on triche parce qu'on sait quels patients sont
                "5 AML/0034.FCS",      # en santé et lesquels ont reçu un diagnostique de AML, mais la
                "5 AML/0035.FCS",      # démo reste intéressante!
                "5 AML/0036.FCS",
                "5 AML/0037.FCS",
                "5 AML/0038.FCS",
                "5 AML/0039.FCS",
                "5 AML/0040.FCS")

# À l'aide de la librairie flowCore, générer des objets de type 'flowSet' à partir des données brutes
pt4_fs <- read.flowSet(pt4_fclist, dataset=2, transformation=FALSE, alter.names=TRUE)
pt5_fs <- read.flowSet(pt5_fclist, dataset=2, transformation=FALSE, alter.names=TRUE)
```

Le format .FCS définit une manière standard de représenter les données, mais la structure précise des données de cytométrie en flux varie d'un appareil à un autre (par exemple certains appareils appellent le FSC 'FS' et le SSC 'SS' et les appareils n'ont pas toujours les mêmes détecteurs de fluorescence).

On peut donc vérifier avec la console à quoi ressemblent nos données:

```
> pt4_fs

A flowSet with 8 experiments.

  column names:
  FS SS FL1 FL2 FL3 FL4 FL5 TIME

> pt4_fs[1]

A flowSet with 1 experiments.

  column names:
  FS SS FL1 FL2 FL3 FL4 FL5 TIME

> pt4_fs[[1]]

flowFrame object '0025.FCS'
with 30000 cells and 8 observables:
    name desc   range minRange maxRange
$P1   FS <NA> 1048576        0  1048575
$P2   SS <NA> 1048576        0  1048575
$P3  FL1 <NA> 1048576        0  1048575
$P4  FL2 <NA> 1048576        0  1048575
$P5  FL3 <NA> 1048576        0  1048575
$P6  FL4 <NA> 1048576        0  1048575
$P7  FL5 <NA> 1048576        0  1048575
$P8 TIME <NA>    1024        0     1023
61 keywords are stored in the 'description' slot

> # Le minRange est de 0... Allons voir la valeur minimale réelle, pour le FS par exemple.
> head(sort(as.numeric(exprs(pt4_fs[[1]][,1])[,1])), 1)

[1] 152224

> # Le maxRange est de 1048575... Allons voir quelle est la valeur maximale réelle, pour le FS par exemple.
> tail(sort(as.numeric(exprs(pt4_fs[[1]][,1])[,1])), 1)

[1] 1048544

```

Bon, maintenant qu'on sait qu'est-ce que nos fichiers contiennent on peut continuer!

```
# Définir les channels d'intérêt
channelList <- c("FS", "SS", "FL1", "FL2", "FL3", "FL4", "FL5")
```

Une des premières étapes concerne la sanitization des données (et c'est un peu particulier aux techniques d'analyse de cytométrie en flux). On voit que pour tous les channels, la valeur minimum est de 0, et que la valeur maximale est de 1048544. On veut s'assurer que si on a des mesures négatives (ce qui n'est pas le cas ici), on en prenne compte dans l'analyse.

Certains appareils plafonnent les mesures (aucun appareil de mesure n'a un dynamic range infini) à une valeur constante. Si il y a plafonnement, on s'attend à retrouver la plus grande valeur de mesure un grand nombre de fois. Sinon, elle ne se retrouvera sans doute qu'une fois dans le jeu de données. Regardons:

```

> tail(sort(as.numeric(exprs(pt4_fs[[1]][,1])[,1])), 1000)

   [1] 1043488 1043488 1043648 1043776 1043968 1044736 1044896 1044992 1045056 1045344 1045440 1045696
  [13] 1046496 1046528 1046528 1046560 1046560 1046784 1046816 1046880 1046880 1046880 1047008 1047040
  [25] 1047040 1047648 1047648 1047744 1047840 1048032 1048096 1048128 1048160 1048224 1048352 1048544
  [37] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
  [49] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
  [61] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
  [73] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
  [85] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
  [97] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [109] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [121] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [133] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [145] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [157] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [169] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [181] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [193] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [205] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [217] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [229] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [241] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [253] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [265] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [277] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [289] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [301] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [313] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [325] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [337] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [349] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [361] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [373] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [385] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [397] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [409] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [421] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [433] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [445] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [457] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [469] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [481] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [493] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [505] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [517] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [529] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [541] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [553] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [565] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [577] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [589] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [601] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [613] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [625] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [637] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [649] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [661] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [673] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [685] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [697] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [709] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [721] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [733] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [745] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [757] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [769] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [781] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [793] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [805] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [817] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [829] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [841] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [853] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [865] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [877] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [889] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [901] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [913] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [925] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [937] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [949] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [961] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [973] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [985] 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544 1048544
 [997] 1048544 1048544 1048544 1048544

```

Wow ok, il y a beaucoup de données tronquées. Si c'était un problème, il faudrait probablement optimiser le protocole en utilisant des concentrations moins importantes de marqueurs fluorescents (pour les FL), ou en ajoutant un filtre devant les détecteurs (pour les FL, SSC et FSC). On va juste les enlever ici parce que les valeurs extrêmes n'affectent pas vraiment la suite des analyses.

```
# Éliminer les valeurs tronquées (on pourrait faire de même avec les autres channels)
largest_FS <- tail(sort(as.numeric(exprs(pt4_fs[[1]][,1])[,1])), 1)
filter_result <- filter(pt4_fs, rectangleGate("FS" = c(-Inf, largest_FS)))
pt4_fs_trunc <- Subset(pt4_fs, filter_result)

# Vérifier le graphe
plot(as.numeric(exprs(pt4_fs_trunc[[1]]$SS)) ~ as.numeric(exprs(pt4_fs_trunc[[1]]$FS)),
     ylab="SSC (linéaire)",
     xlab="FSC (linéaire)")
```

![Graphe des données non-transformées][FC_0.1]

Les données de cytométrie en flux doivent être transformées pour être utiles, et on sait que les transformations logarithmiques sont suboptimales ([doi:10.1038/ni0706-681](http://www.ncbi.nlm.nih.gov/pubmed/16785881)) dans plusieurs situations: on préfère de loin utiliser la transformation biexponentielle (aussi appellée 'logicle', ce n'est pas un typo). C'est une transformation à 4 paramètres, et il va falloir regarder nos données pour choisir des paramètres qui font du sens.

```
# Voyons la distribution du FS et du SS
densityplot(~`FS`, pt4_fs_trunc)
densityplot(~`SS`, pt4_fs_trunc)
```
Alors pour le FSC on a quelque chose qui ressemble à ça:
![FS pour tous les jeux de données][FC_1]

Et pour le SSC... ouppelaye!
![FS pour tous les jeux de données][FC_1.1]

Changeons l'axe pour mieux voir.

```
# Voyons la distribution du SS
densityplot(~`SS`, pt4_fs_trunc, xlim=c(-5000,60000))
```

Voilà qui est plus facile à visualiser
![FS pour tous les jeux de données][FC_1.2]

On dirait que la valeur minimale est plus petite que 0, mais en réalité c'est un artefact de lissage. C'est pas important de visualiser la distribution exacte ici, ce résultat suffit.

Pour estimer les paramètres optimaux de la transformation biexponentielle,il existe certaines lignes directrices utiles ([doi:10.1002/cyto.20258](http://www.ncbi.nlm.nih.gov/pubmed/16604519)). Voici la liste des paramètres avec leur description et quelques astuces pour estimer leurs valeurs optimales:

* t: "top of data scale", est estimée par la plus grande valeur du jeu de données
* m: c'est la l'étendu des données, mais mesurée en nombre de décades asymptotiques. Souvent 4.5 donne des bons résultats pour la cytométrie en flux.
* r: "reference point", correspond au nouveau zéro. On choisit habituellement la plus petite valeur du jeu de données.
* w: la largeur de la zone de linéarisation, qui peut être estimée par (m - log(t/abs(r)))/2 mais qui peut nécessiter quelques ajustements.
* a: ce paramètre est moins important mais peut être utilisé pour tasser davantage les valeurs vers les positifs après avoir choisi les autres paramètres. On peut habituellement le laisser à 0.

Bref je vous épargne les essais et erreurs, mais j'en suis arrivé aux paramètres suivants à partir des graphes qu'on vient de générer, et les graphes des channels de fluorescence (FL1 à FL5), que je ne montre pas ici. On effectue la transformation des données!

```
lgcl_FS  <- logicleTransform(w=0.60, t=1300000, m=4.5, a=0)
lgcl_SS  <- logicleTransform(w=0.50, t=500,     m=3,   a=0)
lgcl_FL1 <- logicleTransform(w=0.79, t=130000,  m=4.5, a=0)
lgcl_FL2 <- logicleTransform(w=0.92, t=100000,  m=4.5, a=0)
lgcl_FL3 <- logicleTransform(w=0.92, t=100000,  m=4.5, a=0)
lgcl_FL4 <- logicleTransform(w=0.46, t=250000,  m=4.5, a=0)
lgcl_FL5 <- logicleTransform(w=1.17, t=60000,   m=4.5, a=0)
tData <- transform(pt4_fs_trunc, FS =lgcl_FS(FS),
                                 SS =lgcl_SS(SS),
                                 FL1=lgcl_FL1(FL1),
                                 FL2=lgcl_FL2(FL2),
                                 FL3=lgcl_FL3(FL3),
                                 FL4=lgcl_FL4(FL4),
                                 FL5=lgcl_FL5(FL5))

# tData n'est pas un dataFrame standard de R... c'est un objet de type 'flowFrame' défini
# par la librairie flowCore. On va le convertir en dataframe standard plus simple à manipuler.
thing <- exprs(tData[[1]])

# Voyons voir à quoi ressemble le graphe résultant.
plot(thing[,'SS'] ~ thing[,'FS'],
     ylab="SSC (logicle)",
     xlab="FSC (logicle)")
```

![Graphe des données transformées][FC_0.2]

Excellent! On discerne beaucoup mieux les sous-populations de cellules... Mais le graphe est abominable. Le design est très important quand on publie des graphes, parce que ceux-ci racontent une histoire et on veut aider le plus possible le lecteur à suivre l'histoire en présentant judicieusement nos infos. Le design çe n'est pas qu'une considération cosmétique... Et en fait un bon design est davantage fonctionnel que cosmétique. Puisqu'on va refaire des graphes souvent, il convient de définir une fonction qu'on pourra réutiliser comme bon nous semble.

```
make.nice.plot <- function(data,
                           mapping,
                           plot.title=NULL,
                           y.axis.title="y",
                           x.axis.title="x",
                           binningVect=c(0.2,0.15))
{
  binningVector <- binningVect # Je n'ai aucune espèce d'idée comment déterminer la taille optimale du binning pour
                               # les cartes de type topographique qu'on va produire. Ma stratégie c'est d'y aller
                               # par essai et erreur... Mais c'est pas la fin du monde parce que cette mesure est
                               # assez robuste d'un jeu de données à l'autre. Je crois.

  p <- ggplot(data=as.data.frame(data), mapping=mapping)

  p <- p + geom_point(alpha=0.03,
                      color="#051A2D")

  p <- p + stat_density2d(aes(fill=..level..),
                          col='white',
                          size=0.15,
                          geom="polygon",
                          h=binningVector)

  p <- p + labs(title=plot.title,
                x=x.axis.title,
                y=y.axis.title)

  p <- p + theme(plot.title = element_text(size=20,
                                           face="bold",
                                           vjust=1.5,
                                           family="Helvetica Neue"))

  p <- p + theme(axis.title.y = element_text(size=16),
                 axis.title.x = element_text(size=16))

  p <- p + theme(axis.ticks.y = element_blank(),
                 axis.ticks.x = element_blank())

  p <- p + theme(axis.text.y = element_blank(),
                 axis.text.x = element_blank())

  p <- p + theme(legend.position = "none")

  p <- p + theme(panel.background = element_rect(fill='white'),
                 panel.grid.major = element_line(colour="#DDDDDD", size=0.5),
                 panel.grid.minor = element_line(colour="#DDDDDD", size=0.5))

  p <- p + theme(panel.border = element_rect(fill=NA,
                                             colour='black',
                                             size=1))

  p <- p + scale_x_continuous(expand=c(0,0))
  p <- p + scale_y_continuous(expand=c(0,0))
  p <- p + theme(aspect.ratio = 1)

  # La fonction génère au final le graphe demandé
  p
}
```

On écrit tout ça, et on essaie de l'exécuter... Mais on dirait que rien ne se passe! Kessé ça? C'est beaucoup d'effort pour rien, dites-vous?

Détrompez-vous! On vient d'assigner à la 'variable' `make.nice.plot` toute une série d'instructions, délimitées par des `{ }` et acceptant une liste de paramètres. De telles variables qui contiennent des séries d'instructions s'appellent des fonctions. Pour faire appel à une fonction, on écrit `make.nice.plot()`, avec la liste des paramètres dans les parenthèses. Reconnaissez-vous la syntaxe? Vous avez certainement déjà utilisé des fonctions en travaillant avec R!

Les paramètres qu'acceptent les fonctions peuvent être obligatoires ou optionnels, et les paramètres optionnels peuvent prendre une valeur par défaut, qui est alors déclarée dans la liste des paramètres (voir ci-haut pour des exemples).

En programmation, les fonctions sont importantes: elles permettent la réutilisation judicieuse de code. Une fois définie, une fonction bien pensée est très simple d'utilisation et très versatile. Un autre avantage d'utiliser des fonctions pour réutiliser du code, c'est que si jamais on veut y apporter des changements, on peut faire des modifications une seule fois et ça va se réfléter sur chaque appel à la fonction!

Voyons comment il est simple de l'utiliser.

```
# Vérifions de quoi ça a l'air! :D
make.nice.plot(thing,
               plot.title="Patient 4 (données partielles: 1 de 8)",
               y.axis.title="SSC (logicle)",
               x.axis.title="FSC (logicle)",
               mapping=aes(x=FS,y=SS))
```

![Graphe de SS et FS pour le premier jeu de données][FC_2]

Vous voulez voir un exemple de réutilisation judicieuse de code, à l'aide de la fonction qu'on vient de définir? Vous allez être servis! On va faire un graphe de tous les channels en fonction de tous les autres channels pour un des jeux de données (il faudra bien prendre soin de transformer les channels autres que SS et FS, mais je ne le démontre pas ici et c'est trivial).

```
# Plot all of the things like it's your last day on earth! Arrrr! Ou devrais-je dire RRRrrrrrr!
ggpairs(thing, lower = list(continuous = make.nice.plot))

```

![Plot all of the things like it's your last day on earth][FC_3]

On peut rapidement comparer avec un jeu de données d'un patient atteint de AML:

![Plot all of the things like it's your last day on earth][FC_3.1]

Pour mieux comparer, on peut faire un overlay des graphes en deux couleurs. En vert, le patient normal, en rouge, le patient diagnostiqué avec AML.

![Plot all of the things like it's your last day on earth][FC_3.2]

Cool, on a développé notre propre petite méthode graphique pour visualiser les données de cytométrie en flux! Maintenant amusons-nous avec des statistiques Bayésiennes et du machine-learning.








### Identification automatisée des populations par clustering
On commence par l'analyse à 1 cluster avec les paramètres FS et SS afin d'identifier les outliers ou les valeurs extrêmes, qui seront retirées des analyses subséquentes. K c'est le nombre de clusters, B le nombre d'itérations maximal de l'algorithme EM.

```
patient4 <- tData[[1]]
res1 <- flowClust(patient4, varNames=c("FS", "SS"), K=1, B=200)

     Using the parallel (multicore) version of flowClust with 8 cores
```

Ensuite on procède à l'analyse de FL1 et FL2, que j'ai choisi parce qu'ils semblaient différer pas mal entre le patient sain et le patient atteint de AML. On performe une analyse avec 10 clusters.

```
patient4.2 <- patient4[patient4 %in% res1,]
res2 <- flowClust(patient4.2, varNames=c("FL1","FL2"), K=1:10, B=100)

     Using the parallel (multicore) version of flowClust with 8 cores
```

On choisit le meilleur modèle à l'aide du BIC.

```
criterion(res2, "BIC")

[1] -19416.450 -10676.642  -7706.767  -5774.253  -5062.323  -4950.900  -4760.073  -4752.090  -4601.089
[10]  -4598.855

plot(criterion(res2,"BIC"))
```

![BIC of 10 clusters][FC_4]

On voit donc que les valeurs de BIC restent relativement constantes à partir du 7e cluster. On choisit le modèle à 7 clusters et on check les résultats:

```
summary(res2[[7]])

** Experiment Information **
Experiment name: Flow Experiment
Variables used: FL1 FL2
** Clustering Summary **
Number of clusters: 7
Proportions: 0.30073 0.1789337 0.03301198 0.06883092 0.1375168 0.2437108 0.03726587
** Transformation Parameter **
lambda: 0.7633071
** Information Criteria **
Log likelihood: -2165.735
BIC: -4760.073
ICL: -46648.13
** Data Quality **
Number of points filtered from above: 0 (0%)
Number of points filtered from below: 168 (0.62%)
Rule of identifying outliers: 90% quantile
Number of outliers: 1164 (4.28%)
Uncertainty summary:
```

On voit que la règle pour identifier les valeurs extrêmes est la règle du 90% quantile. On peut spécifier une règle différente et choisir d'être plus conservateur avec une règle du 95% quantile.

```
ruleOutliers(res2[[7]]) <- list(level=0.95)

summary(res2[[7]])

** Experiment Information **
Experiment name: Flow Experiment
Variables used: FL1 FL2
** Clustering Summary **
Number of clusters: 7
Proportions: 0.30073 0.1789337 0.03301198 0.06883092 0.1375168 0.2437108 0.03726587
** Transformation Parameter **
lambda: 0.7633071
** Information Criteria **
Log likelihood: -2165.735
BIC: -4760.073
ICL: -46648.13
** Data Quality **
Number of points filtered from above: 0 (0%)
Number of points filtered from below: 168 (0.62%)
Rule of identifying outliers: 95% quantile
Number of outliers: 405 (1.49%)
Uncertainty summary:
```

On peut aussi combiner à cette règle un paramètre additionnel. Si, par exemple, on veut associer un événement à un cluster uniquement si la probabilité postérieure est supérieure à 0.6, on peut le spécifier:

```
ruleOutliers(res2[[7]]) <- list(z.cutoff=0.6)

Rule of identifying outliers: 95% quantile,
                              probability of  assignment < 0.6

summary(res2[[7]])

** Experiment Information **
Experiment name: Flow Experiment
Variables used: FL1 FL2
** Clustering Summary **
Number of clusters: 7
Proportions: 0.30073 0.1789337 0.03301198 0.06883092 0.1375168 0.2437108 0.03726587
** Transformation Parameter **
lambda: 0.7633071
** Information Criteria **
Log likelihood: -2165.735
BIC: -4760.073
ICL: -46648.13
** Data Quality **
Number of points filtered from above: 0 (0%)
Number of points filtered from below: 168 (0.62%)
Rule of identifying outliers: 95% quantile,
                              probability of  assignment < 0.6
Number of outliers: 8512 (31.29%)
Uncertainty summary:
```

La quantité de valeurs jugées extrêmes augmente, naturellement.

Visualisons les résultats! (Désolé, je n'arrive toujours pas à réconcilier flowClust avec ggplot2... Mais je vais surement y arriver quand personne ne sera là pour apprécier le résultat!)

```
plot(res2[[7]], data=patient4.2, level=0.8, z.cutoff=0)

    Rule of identifying outliers: 80% quantile
```

![Résultats du clustering][FC_4.1]
