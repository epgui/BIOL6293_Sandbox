[< Retour à l'index](https://github.com/epgui/BIOL6293_Sandbox/) | [Cytométrie en flux >](https://github.com/epgui/BIOL6293_Sandbox/blob/master/CF.md)

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
[SA_18]: https://github.com/epgui/BIOL6293_Sandbox/blob/master/images/SA-18.png?raw=true "Representation des donnees"

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

# Lis la carte des comtés du Nouveau-Brunswick disponible sur GéoNB
comtes <- readShapePoly("geonb_county-comte_shp/geonb_county-comte.shp")
summary(comtes)

# Initialise la projection EPSG 2953 utilisés par la carte du NB
crs <- CRS("+init=epsg:2953")
proj4string(comtes) <- crs
summary(comtes)

# Crée un systéme de coordonnées(projection) pour la carte du Nouveau-Brunswick utilisant les
# longitudes et latitudes et le datum WGS84
wgs.84 <- "+proj=longlat +datum=WGS84"
epsg.2953 <- paste("+init=epsg:2953",
                   "+proj=sterea",
                   "+lat_0=46.5",
                   "+lon_0=-66.5",
                   "+k=0.999912",
                   "+x_0=2500000",
                   "+y_0=7500000",
                   "+ellps=GRS80",
                   "+towgs84=0,0,0,0,0,0,0",
                   "+units=m +no_defs",
                   collapse=" ")

# Lis le fichier comportant les coordonnées (longitude, latitude) des échantillons d'eaux
# souterraines du comtés de KENT
coordonnees <- read.table("coordonnees.txt", sep = "\t", header = TRUE)

# La longitude est contenue dans la colonne 3 du fichier alors que la latitude est dans la colonne 2
coordonnees

# Transforme les coordonnées présente dans le fichier en objet spatiale en l'occurence, des points.
coordinates(coordonnees) <- c(3,2)
class(coordonnees)
summary(coordonnees)

# Initialise la projection des coordonnées en wgs.84 à l'aide de epsg:4326
crs2 <- CRS("+init=epsg:4326")
proj4string(coordonnees) <- crs2
summary(coordonnees)

# Transforme la projection wgs 84 des points de coordonnées en projection EPSG2953 du Nouveau-Brunswick
coord.epsg2953 <- spTransform(coordonnees, CRS(epsg.2953))
summary(coord.epsg2953)

# Fais un graphique de KENT et Westmorland avec les points de ceuillettes des échantillons
plot(comtes[5,],
     xlab = "Longitude",
     ylab = "Latitude",
     axes = TRUE,
     main = "Comté de KENT")
plot(comtes[9,],
     add=TRUE)
plot(coord.epsg2953,
     pch =21,
     cex = 0.7,
     bg="dodgerblue",
     add = TRUE)

# labels
pointLabel(coord.epsg2953@coords,
           labels = coordonnees$ID,
           cex = 0.7,
           allowSmallOverlap = FALSE,
           col = "darkolivegreen",
           offset = 0)
north.arrow(2640000,
            7545000,
            len = 1500,
            "N",
            col = "light gray")
map.scale(2555000,
          7460000,
          10000,
          "km",
          5,
          subdiv = 2,
          tcol = 'black',
          scol = 'black',
          sfcol = 'black')

```

![Graphique de Kent et Westmorland avec les points de cueillette des échantillons][SA_1]

```

# comtés de Kings
coordonneeskings <- read.table("coordonneskings.txt", sep = "\t", header = TRUE)
coordinates(coordonneeskings) <- c(3,2)
proj4string(coordonneeskings) <- crs2
coord.kings <- spTransform(coordonneeskings, CRS(epsg.2953))

# Fait un graphique de Kings avec les points de ceuillettes des échantillons
plot(comtes[8,],
     xlab = "Longitude",
     ylab = "Latitude",
     axes = TRUE,
     main = "Comté de KINGS")
plot(coord.kings,
     pch = 21,
     cex = 0.7,
     bg = "dodgerblue",
     add = TRUE)

# labels
pointLabel(coord.kings@coords,
           labels = coordonneeskings$ID,
           cex = 0.7,
           allowSmallOverlap = FALSE,
           col = "darkolivegreen",
           offset = 0)
north.arrow(2600000,
            7440000,
            len = 1500,
            "N",
            col="light gray")
map.scale(2510000,
          7350000,
          10000,
          "km",
          5,
          subdiv = 2,
          tcol = 'black',
          scol = 'black',
          sfcol = 'black')

```

![Graphique de Kings avec les points de cueillette des échantillons][SA_2]

```
# comtés de Albert
coordonneesalbert <- read.table("coordonneshills.txt", sep = "\t", header = TRUE)
coordinates(coordonneesalbert) <- c(3,2)
proj4string(coordonneesalbert) <- crs2
coord.albert <- spTransform(coordonneesalbert, CRS(epsg.2953))

# Fait un graphique du comtés de Albert avec les points de ceuillettes des échantillons près de Hillsborough
plot(comtes[14,],
     xlab = "Longitude",
     ylab = "Latitude",
     axes = TRUE,
     main = "Comté de Albert")
plot(coord.albert,
     pch = 21,
     cex = 0.7,
     bg = "dodgerblue",
     add = TRUE)

# labels
pointLabel(coord.albert@coords,
           labels = coordonneesalbert$ID,
           cex = 0.7,
           allowSmallOverlap = FALSE,
           col = "darkolivegreen",
           offset = 0)
north.arrow(2647000,
            7450000,
            len = 1000,
            "N",
            col = "light gray")
map.scale(2605000,
          7440000,
          10000,
          "km",
          5,
          subdiv = 2,
          tcol = 'black',
          scol = 'black',
          sfcol = 'black')

```

![Graphique de Albert avec les points de cueillette des échantillons][SA_3]

```

# Carte composite NB
plot(comtes,
     main = "Nouveau-Brunswick",
     axes = FALSE)
plot(coord.epsg2953,
     pch = 21,
     cex = 0.5,
     bg = "dodgerblue",
     add = TRUE)
plot(coord.kings,
     pch = 21,
     cex = 0.5,
     bg = "yellow",
     add = TRUE)
plot(coord.albert,
     pch = 21,
     cex = 0.5,
     bg = "red",
     add = TRUE)
north.arrow(2660000,
            7550000,
            len = 5000,
            "N",
            col = "light gray")
map.scale(2350000,
          7310000,
          100000,
          "km",
          5,
          subdiv = 20,
          tcol = 'black',
          scol = 'black',
          sfcol = 'black')

```

![Carte du Nouveau-Brunswick avec points d'échantillonnage][SA_4]

```

# Raster Brute
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
blank.grid <- raster(ncols = ncol, nrows = nrow, xmn = xmin, xmx = xmax, ymn = ymin, ymx = ymax)
dataconc <- read.table("concentrations.txt", sep = "\t", header = TRUE)
xs <- dataconc[,3]
ys <- dataconc[,2]
xy <- cbind(xs,ys)
x <- dataconc$Conc
land.grid = rasterize(xy, blank.grid, x, mean)
plot(comtes2,
     main = "Nouveau-Brunswick",
     axes = TRUE)
plot(land.grid,
     add = TRUE,
     axes = FALSE)

# Changement de couleur et d'intervale.
palette <- brewer.pal(5, "YlOrRd")
plot(land.grid,
     col = palette,
     main = "Concentration en radium (pg/L) au Nouveau-Brunswick",
     axes = FALSE)
plot(comtes2,
     add = TRUE,
     axes = FALSE)
north.arrow(-64.000,
            47.0000,
            len = 0.09,
            "N",
            col = "light gray")

```

![Carte raster du Nouveau-Brunswick avec définition brute][SA_5]

```

# Raster définition plus fine cell length plus petite
cell.length <- 0.03
bbox(comtes2)
ncol2 <- round((xmax - xmin)/cell.length, 0)
nrow2 <- round((ymax - ymin)/cell.length, 0)
ncol2
nrow2
blank.grid2 <- raster(ncols = ncol2, nrows = nrow2, xmn = xmin, xmx = xmax, ymn = ymin, ymx = ymax)
land.grid2 = rasterize(xy, blank.grid2, x, mean)
plot(comtes2,
     main = "Nouveau-Brunswick",
     axes = TRUE)
plot(land.grid2,
     add = TRUE,
     axes = FALSE)

# Changement de couleur et d'intervale.
plot(land.grid2,
     col = palette,
     main = "Concentration en radium (pg/L) au Nouveau-Brunswick",
     axes = FALSE)
plot(comtes2,
     add = TRUE,
     axes = FALSE)
north.arrow(-64.000,
            47.0000,
            len = 0.09,
            "N",
            col = "light gray")

```

![Carte raster du Nouveau-Brunswick avec définition fine][SA_6]

```

# Représentation des échantillons de Kent en fonction de leurs concentrations en radium
class(coord.epsg2953)
conc <- coordonnees$Conc
break.points <- c(0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35)
groups <- cut(conc,
              break.points,
              include.lowest = TRUE,
              label = FALSE)
palette2 <- brewer.pal(7, "YlOrRd")
plot(comtes[5,],
     axes = TRUE,
     main = "Concentration en radium dans les eaux souterraines de puits du comté de Kent")
plot(coord.epsg2953,
     pch = 21,
     bg = palette2[groups],
     add = TRUE)
north.arrow(2640000,
            7545000,
            len = 1500,
            "N",
            col = "light gray")
map.scale(2640000,
          7565000,
          10000,
          "km",
          5,
          subdiv = 2,
          tcol = 'black',
          scol = 'black',
          sfcol = 'black')
legend(2550000,
       7565000,
       legend = c("<0.05","0.05 à 0.1", "0.1 à 0.15", "0.15 à 0.2","0.2 à 0.25", "0.25 à 0,30", ">0.30"),
       pch = 21,
       pt.bg = palette2,
       cex = 0.6,
       title = "Concentration Ra (pg/L)")
pointLabel(coord.epsg2953@coords,
           labels = coordonnees$ID,
           cex = 0.7,
           allowSmallOverlap = FALSE,
           col = "darkolivegreen")

```

![Représentation des échantillons de Kent en fonction de leurs concentrations en radium][SA_7]



###Part II : Analyse

```

# Analyse spatiale recherche du voisin
library(spdep)
knn1 <- knearneigh(coord.epsg2953, k = 1, longlat = FALSE, RANN = FALSE)$nn
knn1
cor.test(coord.epsg2953$Conc, coord.epsg2953$Conc[knn1])

```

> cor.test(coord.epsg2953$Conc, coord.epsg2953$Conc[knn1])

> Pearson's product-moment correlation

> data:  coord.epsg2953$Conc and coord.epsg2953$Conc[knn1]

> t = 2.282, df = 44, p-value = 0.02738

> alternative hypothesis: true correlation is not equal to 0

> 95 percent confidence interval:

> 0.03866938 0.56249265

> sample estimates:
>      cor
>	0.3253155

```

# Trouve les 45 plus proche voisin
knear45 <- knearneigh(coord.epsg2953, k = 45, longlat = FALSE, RANN = FALSE)

# Crée un objet pour stocker les corrélations
correlations <- vector(mode = "numeric", length = 45)

for (i in 1:45) {
  correlations[i] <- cor(coord.epsg2953$Conc, coord.epsg2953$Conc[knear45$nn[,i]])
}
correlations

plot(correlations,
     xlab = "nth nearest neighbour",
     ylab = "Correlation")
lines(lowess(correlations, f = 1/10),
      col = "blue")		# Ajoute une ligne entre chaque point

```

![Graphique correlation de la concentration en radium entre voisins dans KENT][SA_8]

```

# Création d'une matrice de poids basée sur la distance inverse
d.matrix <- spDists(coord.epsg2953, coord.epsg2953, longlat = FALSE)
d.matrix      # Création d'une matrice de distance

# Détermine le nombre de points
np <- knear45$np
np

```

>46


```

# Crée un vecteur pour stocké les poids
d.weights <- vector(mode = "list", length = np)

for (i in 1:np) {                     # Une boucle prenant chaque point
  neighbours <- knear45$nn[i,]        # Trouve les voisins pour le point i
  distances <- d.matrix[i,neighbours] # Calcule la distance entre i et ses voisins
  d.weights[[i]] <- sqrt(1/distances) # Calcule un poids entre i et chaque voisin en fonction
                                      #    de la distance qui les séparent
}

head(knear45$nn, n = 1)               # La liste des voisins
head(d.weights, n = 1)                # La liste des poids correspondants

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

# Examen de l'autoccorélation entre les points d'échantillons selon la concentration en radium
spknear45 <- nb2listw(knear45nb, glist=d.weights, style="C")
moran.plot(coord.epsg2953$Conc,
           spknear45,
           labels = TRUE)
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
Il n`y a donc pas d`autocorrelation significative entre les concentrations
```

# Modèle pour déterminer ce qui influence la concentration en radium
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
> Signif. codes:  0 ‘\*\*\*’ 0.001 ‘\*\*’ 0.01 ‘\*’ 0.05 ‘.’ 0.1 ‘ ’ 1
>
> Residual standard error: 0.08431 on 41 degrees of freedom

>  (2 observations deleted due to missingness)

> Multiple R-squared:  0.05209,	Adjusted R-squared:  0.005852

> F-statistic: 1.127 on 2 and 41 DF,  p-value: 0.334

```

# Comparaison entre les différents comtés.
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

 # Les résidus ne sont pas normalement distribués

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

 # Présentation des résidus
 layout(matrix(1:4, 2, 2))
 plot(lm(sqrtlogConc ~ concentrations$Comtes), which = 1:4)  

```

![Presentation des residus apres anova][SA_12]

```

# Représentation graphique anova
layout(matrix(1))
plot(concentrations$Comtes,
     sqrtlogConc,
     xlab = "comtés",
     ylab = "sqrt(log10(Conc+1))",
     col = c("brown1", "lightblue", "darkgoldenrod1"),
     axes =TRUE,
     main="Comparaision ANOVA concentration en radium par comté")

```  

![Representation graphique de l'anova][SA_13]

```
# Comparaisons planifié KENT et HILLS et KINGS et HILLS
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


# Comparasion non-planifié
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
```
Filtrés vs Non-Filtrés
 
filtre <- read.table("Filtre.txt", sep = "\t", header = TRUE)
filtre
   Filtre nFiltre
1   0.060   0.022
2   0.225   0.195
3   0.046   0.050
4   0.344   0.304
5   0.029   0.000
6   0.048   0.046
7   0.121   0.108
8   0.027   0.056
9   0.079   0.019
10  0.033   0.015
11  0.033   0.028
12  0.079   0.091
13  0.011   0.000
14  0.031   0.030
15  0.078   0.062
16  0.212   0.201
17  0.075   0.055
18  0.124   0.082
19  0.089   0.061
20  0.095   0.072
21  0.143   0.115
22  0.035   0.018
23  0.037   0.023
 
 plot(filtre$Filtre, filtre$nFiltre, axes = FALSE, main = "Échantillons filtrés vs non-filtrés, spéciation du radium", xlab = "Filtrés", ylab = "Non-Filtrés")
 axis(1, pos = 0)
 axis(2, pos = 0)
```

![Representation des donnees][SA_18]


``` 
 filtrelm <- lm(nFiltre ~ Filtre, data = filtre)
 summary(filtrelm)

Call:
lm(formula = nFiltre ~ Filtre, data = filtre)

Residuals:
      Min        1Q    Median        3Q       Max 
-0.043562 -0.005691 -0.001142  0.009147  0.040406 

Coefficients:
             Estimate Std. Error t value Pr(|t|)    
(Intercept) -0.008793   0.005763  -1.526    0.142    
Filtre       0.903237   0.048788  18.514 1.75e-14 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.01809 on 21 degrees of freedom
Multiple R-squared:  0.9423,	Adjusted R-squared:  0.9395 
F-statistic: 342.8 on 1 and 21 DF,  p-value: 1.747e-14

 abline(filtrelm$coefficients, col = "red")
 
 hist(filtre$Filtre)
 hist(filtre$nFiltre)
 shapiro.test(filtre$Filtre)

	Shapiro-Wilk normality test

data:  filtre$Filtre
W = 0.7894, p-value = 0.0002605

 shapiro.test(filtre$nFiltre)

	Shapiro-Wilk normality test

data:  filtre$nFiltre
W = 0.79776, p-value = 0.0003529

 
 logfiltre <- sqrt(log10(filtre$Filtre +1))
 lognfiltre <- sqrt(log10(filtre$nFiltre +1))
 
 hist(logfiltre)
 hist(lognfiltre)
 shapiro.test(logfiltre)

	Shapiro-Wilk normality test

data:  logfiltre
W = 0.92817, p-value = 0.09984

 shapiro.test(lognfiltre)

	Shapiro-Wilk normality test

data:  lognfiltre
W = 0.96527, p-value = 0.5774

 
 plot(logfiltre, lognfiltre, axes = TRUE, main = "Échantillons filtrés vs non-filtrés, spéciation du radium", xlab = "tFiltrés", ylab = "tNon-Filtrés")
 tfiltrelm <- lm(logfiltre ~ lognfiltre)
 summary(tfiltrelm)

Call:
lm(formula = logfiltre ~ lognfiltre)

Residuals:
      Min        1Q    Median        3Q       Max 
-0.071829 -0.018372 -0.001118  0.015826  0.052662 

Coefficients:
            Estimate Std. Error t value Pr(|t|)    
(Intercept)  0.05876    0.01307   4.496 0.000199 ***
lognfiltre   0.78419    0.07645  10.257 1.24e-09 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.02939 on 21 degrees of freedom
Multiple R-squared:  0.8336,	Adjusted R-squared:  0.8257 
F-statistic: 105.2 on 1 and 21 DF,  p-value: 1.24e-09

 abline(tfiltrelm$coefficients, col = "blue")
 hist(tfiltrelm$residuals)
 shapiro.test(tfiltrelm$residuals)

	Shapiro-Wilk normality test

data:  tfiltrelm$residuals
W = 0.96859, p-value = 0.6553


 var.test(logfiltre, lognfiltre)

	F test to compare two variances

data:  logfiltre and lognfiltre
F = 0.7377, num df = 22, denom df = 22, p-value = 0.4814
alternative hypothesis: true ratio of variances is not equal to 1
95 percent confidence interval:
 0.3128665 1.7394140
sample estimates:
ratio of variances 
         0.7377021 

 t.test(logfiltre, lognfiltre, var.equal = TRUE)

	Two Sample t-test

data:  logfiltre and lognfiltre
t = 1.1619, df = 44, p-value = 0.2515
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
 -0.01922519  0.07157002
sample estimates:
mean of x mean of y 
0.1771864 0.1510140 
```


[< Retour à l'index](https://github.com/epgui/BIOL6293_Sandbox/) | [Cytométrie en flux >](https://github.com/epgui/BIOL6293_Sandbox/blob/master/CF.md)
