# Pour accéder aux librairies de cytométrie en flux, il faut d'abord installer Bioconductor.
# Dans la console, tappez:
# > setRepositories()
# Ensuite, sélectionnez CRAN et BioC software, par exemple en tappant, selon les options qui vous sont présentées:
# > 1 2
# Vous pouvez maintenant accéder aux librairies de Bioconductor à partir de R ou de RStudio!

# Attention! flowQ dépend de imagemagick, que vous pouvez installer à partir des binairies suivants:
# - Mac: http://www.imagemagick.org/script/binary-releases.php#macosx
# - Win: http://www.imagemagick.org/script/binary-releases.php#windows

library(flowCore)  # Bioconductor
library(flowQ)     # Bioconductor + imagemagick
library(flowViz)   # Bioconductor
library(flowStats) # Bioconductor
library(ggplot2)

setwd(file.path(PROJHOME, "data"))
fclist <- c("4 Normal/0025.FCS",
            "4 Normal/0026.FCS",
            "4 Normal/0027.FCS",
            "4 Normal/0028.FCS",
            "4 Normal/0029.FCS",
            "4 Normal/0030.FCS",
            "4 Normal/0031.FCS",
            "4 Normal/0032.FCS")

patient_4_flowset <- read.flowset(fclist, transformation=FALSE, alter.names=TRUE)