library(plyr)

# Loading data ####
full <- read.csv("../Clean data/full_rough.csv", as.is=TRUE)
pdata <- full[!is.na(full$BIOMASS),] # Removing rows with NAs for BIOMASS

abund = function(x){
  bm = x$BIOMASS
  names(bm) = x$TAXANAME
  return (bm/sum(bm))
}

get_neutral_network = function(d){
  Zoo = subset(d, T_GROUP == "Zooplankton")
  Phy = subset(d, T_GROUP == "Phytoplankton")
  if (nrow(Phy) > 3) {
    if (nrow(Zoo) > 3) {
      ap = abund(Phy)
      az = abund(Zoo)
      A = kronecker(ap, t(az))
      colnames(A) = names(az)
      rownames(A) = names(ap)
      return(A)
    }
  }
}

pmat = dlply(pdata, "SITE_ID", get_neutral_network)
pmat = pmat[!laply(pmat, is.null)]

even = function(A) exp(sum(A * log(A)) / log(prod(dim(A))))

n_measures = function(x) {
  return(cbind(
    even = even(x),
    size = prod(dim(x))
    ))
}

shannon_data = ldply(pmat, n_measures)
cn = colnames(shannon_data)
cn[1] = "SITE_ID"
colnames(shannon_data) = cn
edata = merge(pdata, shannon_data)
