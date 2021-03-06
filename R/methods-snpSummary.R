### =========================================================================
### snpSummary methods 
### =========================================================================

setMethod("snpSummary", "CollapsedVCF", 
    function(x, ...) 
{
    alt <- alt(x)
    if (is(alt, "CompressedCharacterList")) {
        alt <- .toDNAStringSetList(alt)
        if (all(elementLengths(alt) == 0L)) {
            warning("No nucleotide ALT values were detected.")
            return(.emptySnpSummary())
        }
    }
    gt <- geno(x)$GT
    if (is.null(gt)) {
        warning("No genotype data found in VCF.")
        return(.emptySnpSummary())
    }
    if (ncol(gt) == 0L) {
        warning("No genotype data found in VCF.")
        return(.emptySnpSummary())
    }

    ## Genotype count
    snv <- .testForSNV(ref(x), alt)
    if (sum(snv) == 0L) {
        warning("No valid SNPs found in VCF.")
        return(.emptySnpSummary())
    }
    gmap <- .genotypeToIntegerSNV(FALSE)
    gmat <- matrix(gmap[gt], nrow=nrow(gt))
    gcts <- matrix(NA_integer_, nrow(gmat), 3)
    if (ncol(gmat) == 1L)
        fun <- I
    else
        fun <- rowSums
    gcts[snv,] <- sapply(1:3, function(i)
                      fun(gmat[snv,] == i))
    gcts <- matrix(as.integer(gcts), nrow=nrow(gmat),
                   dimnames=list(NULL, c("g00", "g01", "g11")))

    ## Allele frequency 
    acts <- gcts %*% matrix(c(2,1,0,0,1,2), nrow=3)
    afrq <- acts/rowSums(acts)
    colnames(afrq) <- c("a0Freq", "a1Freq") 
 
    ## HWE 
    HWEzscore <- .HWEzscore(gcts, acts, afrq)
    HWEpvalue <- pchisq(HWEzscore^2, 1, lower.tail=FALSE)

    data.frame(gcts, afrq, HWEzscore, HWEpvalue,
               row.names=rownames(x))
})

.HWEzscore <- function(genoCounts, alleleCounts, alleleFrequency)
{
    a0 <- alleleFrequency[,"a0Freq"]
    a1 <- alleleFrequency[,"a1Freq"]
    expt <- rowSums(alleleCounts) * cbind(a0^2/2, a0*a1, a1^2/2)
    chisq <- rowSums((genoCounts - expt)^2 / expt)
    z <- rep(NA, nrow(genoCounts))
    zsign <- sign(genoCounts[,"g01"] - expt[,2] * rowSums(genoCounts))
    zsign * sqrt(chisq)
}

## Maps diploid genotypes, phased or unphased.
.genotypeToIntegerSNV <- function(raw=TRUE)
{
    name <-  c(".|.", "0|0", "0|1", "1|0", "1|1",
              "./.", "0/0", "0/1", "1/0", "1/1")
    value <- rep(c(0, 1, 2, 2, 3), 2) 
    if (raw)
        setNames(sapply(value, as.raw), name)
    else
        setNames(value, name)
}

## Expects 'ref' as DNAStringSet and 'alt' as
## DNAStringSetList. Returns a logical vector
## the same length as 'ref'. 
.testForSNV <- function(ref, alt)
{
    altelt <- elementLengths(alt) == 1L
    altseq <- logical(length(alt))
    idx <- rep(altelt, elementLengths(alt))
    altseq[altelt] = width(unlist(alt, use.names=FALSE)[idx]) == 1L
    altseq & (width(ref) == 1L)
}

.emptySnpSummary <- function()
{
    data.frame(g00=integer(), g01=integer(), g11=integer(),
               a0Freq=numeric(), a1Freq=numeric(),
               HWEzscore=numeric(), HWEpvalue=numeric())
}
