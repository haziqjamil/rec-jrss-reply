# Load functions
source("R/1-gpr-iprior-sim-functions.R")

experiment.name <- "Cardiac data"
# (https://archive.ics.uci.edu/ml/datasets/Arrhythmia) This database contains
# 279 attributes, 206 of which are linear valued and the rest are nominal.
# Concerning the study of H. Altay Guvenir: "The aim is to distinguish between
# the presence and absence of cardiac arrhythmia and to classify it in one of
# the 16 groups. Class 01 refers to 'normal' ECG classes 02 to 15 refers to
# different classes of arrhythmia and class 16 refers to the rest of
# unclassified ones. For the time being, there exists a computer program that
# makes such a classification. However there are differences between the
# cardiolog's and the programs classification. Taking the cardiolog's as a gold
# standard we aim to minimise this difference by means of machine learning
# tools."
# Binary classification task: "normal (0)" or "arrhythmia (1)" p = 194 (ECG
# measurements), N = 451
load("data/Arrh194.RData")
summary(as.factor(ArrhDataNew$y))
X.orig <- ArrhDataNew$x
y <- ArrhDataNew$y
y <- y - 1  # convert to 0 and 1
N <- length(y)
n <- c(50, 100, 200)  # subsamples

# Simulations
res.gprlin <- mySim(type = "linear", gpr = TRUE)  # linear GPR
res.gprfbm <- mySim(type = "fbm", gpr = TRUE)  # FBM GPR
res.gprfbmoptim <- mySim(type = "fbmoptim", gpr = TRUE)  # FBM optim GPR

res.iplin <- mySim(type = "linear")  # Canonical I-prior
res.ipfbm <- mySim(type = "fbm")  # FBM I-prior
res.ipfbmoptim <- mySim(type = "fbmoptim")  # FBM optim I-prior

res.gprlinRP <- mySimRP(type = "linear", gpr = TRUE)  # linear GPR with RP
res.gprfbmRP <- mySimRP(type = "fbm", gpr = TRUE)  # FBM GPR with RP
# res.iplinRP <- mySimRP(type = "linear")  # Canonical I-prior with RP
# res.ipfbmRP <- mySimRP(type = "fbm")  # FBM I-prior with RP

tab <- tabRes("RP5-GPR (linear)"  = res.gprlinRP,
              "RP5-GPR (FBM-0.5)" = res.gprfbmRP,
              "GPR (linear)"      = res.gprlin,
              "GPR (FBM-0.5)"     = res.gprfbm,
              "GPR (FBM-MLE)"     = res.gprfbmoptim,
              "I-prior (linear)"  = res.iplin,
              "I-prior (FBM-0.5)" = res.ipfbm,
              "I-prior (FBM-MLE)" = res.ipfbmoptim)
              # "RP5-I-prior (linear)"    = res.iplinRP,
              # "RP5-I-prior (FBM)"       = res.ipfbmRP)

# Results from REC
rp.lda5.mean <- c(33.24, 30.19, 27.49)
rp.lda5.se   <- c(0.42, 0.35, 0.30)
rp.lda5      <- meanAndSE(rp.lda5.mean, rp.lda5.se)
rp.qda5.mean <- c(30.47, 28.28, 26.31)
rp.qda5.se   <- c(0.33, 0.26, 0.28)
rp.qda5      <- meanAndSE(rp.qda5.mean, rp.qda5.se)
rp.knn5.mean <- c(33.49, 30.18, 27.09)
rp.knn5.se   <- c(0.40, 0.33, 0.31)
rp.knn5      <- meanAndSE(rp.knn5.mean, rp.knn5.se)
rp.tab <- rbind("RP5-LDA" = rp.lda5, "RP5-QDA" = rp.qda5, "RP5-knn" = rp.knn5)
colnames(rp.tab) <- colnames(tab$tab)

# Calculate ranks
tab.mean <- rbind(tab$tab.mean, "RP5-LDA" = rp.lda5.mean,
                  "RP5-QDA" = rp.qda5.mean, "RP5-knn" = rp.knn5.mean)
tab.se <- rbind(tab$tab.se, "RP5-LDA" = rp.lda5.se,
                "RP5-QDA" = rp.qda5.se, "RP5-knn" = rp.knn5.se)
tab.ranks <- tabRank(tab.mean, tab.se)

# Tabulate results
tab.all <- cbind(rbind(tab$tab, rp.tab), Rank = tab.ranks)
knitr::kable(tab.all, align = "r")

# Plot
plotRes()
