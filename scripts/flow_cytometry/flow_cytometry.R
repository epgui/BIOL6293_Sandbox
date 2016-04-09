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
pt4_fs <- read.flowset(fclist_pt4, transformation=FALSE, alter.names=TRUE)
pt5_fs <- read.flowset(fclist_pt5, transformation=FALSE, alter.names=TRUE)












