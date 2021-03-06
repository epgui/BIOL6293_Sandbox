# Vérifiez que vous avez bel et bien la dernière version de R à partir de la console de R:
# > version
#
# Vous pouvez obtenir la dernière version de R ici: https://www.r-project.org/
#
# ==================================== #
#             BIOCONDUCTOR             #
# ==================================== #
#
# Pour accéder aux librairies de cytométrie en flux, il faut d'abord installer Bioconductor.
# Dans la console de R, tappez:
# > setRepositories()
#
# Ensuite, sélectionnez CRAN et BioC software, par exemple en tappant dans la console de R, selon les
# options qui vous sont présentées:
# > 1 2
#
# Vous pouvez maintenant accéder aux librairies de Bioconductor (sauf flowQ qui ne marchera pas encore)
# à partir de R ou de RStudio!
#
#
# ==================================== #
#               FLOWSTATS              #
# ==================================== #
#
# flowStats peut vous donner de la misère avec rgl (un dependency) si votre version de X11 n'est pas à jour.
# Vous pouvez télécharger la dernière vesion de X11 pour Mac ici:
# http://www.xquartz.org/
#
# ==================================== #
#                FLOWQ                 #
# ==================================== #
#
# Attention! flowQ dépend de ImageMagick, que vous pouvez installer à partir des binaries suivants:
# - Mac: http://www.imagemagick.org/script/binary-releases.php#macosx
# - Win: http://www.imagemagick.org/script/binary-releases.php#windows
#
# Sur Mac, la manière la plus simple d'installer ImageMagick est de dabord installer "Xcode Command Line Tools"
# à partir du Terminal:
# $ xcode-select --install
#
# puis d'installer MacPorts ici: https://www.macports.org/install.php
# puis d'installer ImageMagick à partir du Terminal:
# $ sudo port install ImageMagick
#
# Sur Mac, vous pouvez tester le succès de l'installation en tappant dans le Terminal:
# $ which convert
#
# Ça devrait donner un résultat qui ressemble à quelque chose comme "/opt/local/bin/convert". Si ça vous donne
# une erreur, ImageMagick n'est pas bien installé.
#
# Sur Windows, bonne chance!



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



# Définir les channels d'intérêt
channelList <- c("FS", "SS", "FL1", "FL2", "FL3", "FL4", "FL5")

# Truncate extreme values of FS
largest_FS <- tail(sort(as.numeric(exprs(pt5_fs[[1]][,1])[,1])), 1)
filter_result <- filter(pt5_fs, rectangleGate("FS" = c(-Inf, largest_FS)))
pt5_fs_trunc <- Subset(pt5_fs, filter_result)

# Play with density plot to find optimal values for logicle transform
densityplot(~`SS`, pt5_fs_trunc, xlim=c(-5000,60000))

#lgcl <- estimateLogicle(pt4_fs[[2]], channels=channelList)
lgcl_FS  <- logicleTransform(w=0.60, t=1300000, m=4.5, a=0)
lgcl_SS  <- logicleTransform(w=0.50, t=500,     m=3,   a=0)
lgcl_FL1 <- logicleTransform(w=0.79, t=130000,  m=4.5, a=0)
lgcl_FL2 <- logicleTransform(w=0.92, t=100000,  m=4.5, a=0)
lgcl_FL3 <- logicleTransform(w=0.92, t=100000,  m=4.5, a=0)
lgcl_FL4 <- logicleTransform(w=0.46, t=250000,  m=4.5, a=0)
lgcl_FL5 <- logicleTransform(w=1.17, t=60000,   m=4.5, a=0)
tData <- transform(pt5_fs_trunc, FS =lgcl_FS(FS),
                                 SS =lgcl_SS(SS),
                                 FL1=lgcl_FL1(FL1),
                                 FL2=lgcl_FL2(FL2),
                                 FL3=lgcl_FL3(FL3),
                                 FL4=lgcl_FL4(FL4),
                                 FL5=lgcl_FL5(FL5))

# tData n'est pas un dataFrame standard de R... c'est un objet de type 'flowFrame' défini
# par la librairie flowCore. On va le convertir en dataframe standard plus simple à manipuler.
thing <- exprs(tData[[1]])



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

# Plot one thing
thing <- exprs(tData[[1]])

# Play with density plot to find optimal values for logicle transform
densityplot(~`FL1`, pt4_fs_trunc, xlim=c(-7000, 130000))
densityplot(~`FL2`, pt4_fs_trunc, xlim=c(-7000, 100000))
densityplot(~`FL3`, pt4_fs_trunc, xlim=c(-7000, 100000))
densityplot(~`FL4`, pt4_fs_trunc, xlim=c(-20000, 250000))
densityplot(~`FL5`, pt4_fs_trunc, xlim=c(-1000, 60000))

#lgcl <- estimateLogicle(pt4_fs[[2]], channels=channelList)
lgcl_FL1 <- logicleTransform(w=0.79, t=130000, m=4.5, a=0)
lgcl_FL2 <- logicleTransform(w=0.92, t=100000, m=4.5, a=0)
lgcl_FL3 <- logicleTransform(w=0.92, t=100000, m=4.5, a=0)
lgcl_FL4 <- logicleTransform(w=0.46, t=250000, m=4.5, a=0)
lgcl_FL5 <- logicleTransform(w=1.17, t=60000, m=4.5, a=0)
tData <- transform(pt4_fs_trunc, FS=lgcl_FS(FS),
                                 SS=lgcl_SS(SS),
                                 FL1=lgcl_FL1(FL1),
                                 FL2=lgcl_FL2(FL2),
                                 FL3=lgcl_FL3(FL3),
                                 FL4=lgcl_FL4(FL4),
                                 FL5=lgcl_FL5(FL5))

# Vérifions de quoi ça a l'air!
make.nice.plot(thing,
               plot.title="Patient 4 (données partielles: 1 de 8)",
               y.axis.title="SSC (logicle)",
               x.axis.title="FSC (logicle)",
               mapping=aes(x=FS, y=SS)) # :D

# Plot all of the things
ggpairs(thing, lower = list(continuous = make.nice.plot))





