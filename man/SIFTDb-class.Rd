\name{SIFTDb-class}
\docType{class}

\alias{SIFT}
\alias{SIFTDb}
\alias{class:SIFTDb}
\alias{SIFTDb-class}

\alias{metadata,SIFTDb-method}
\alias{cols,SIFTDb-method}
\alias{keys,SIFTDb-method}
\alias{select,SIFTDb,missing,missing-method}
\alias{select,SIFTDb,character,character-method}
\alias{select,SIFTDb,missing,character-method}
\alias{select,SIFTDb,character,missing-method}

\title{SIFTDb objects}

\description{
  The SIFTDb class is a container for storing a connection to a SIFT 
  sqlite database.
}

\section{Methods}{
  In the code below, \code{x} and \code{db} are a \code{SIFTDb} object.

  \describe{
    \item{}{
      \code{metadata(x)}:
      Returns \code{x}'s metadata in a data frame.
    }
    \item{}{
      \code{cols(x)}:
      Returns the names of the \code{cols} that can be used to subset the
      data columns.
    }
    \item{}{
      \code{keys(x)}:
      Returns the names of the \code{keys} that can be used to subset the
      data rows. The \code{keys} values are the rsid's.
    }
    \item{}{
      \code{select(db, keys, cols, ...)}:
      Returns a subset of data defined by the character vectors \code{keys} 
      and \code{cols}. If no \code{keys} are supplied, all rows are
      returned. If no \code{cols} are supplied, all columns
      are returned.
      \itemize{
        \item rsid : rsid
        \item proteinID : NCBI RefSeq protein ID
        \item aaChange : amino acid substitution; reference aa is preceeding,
                         followed by the position and finally the snp aa
        \item method : method of obtaining related sequences using PSI-BLAST
        \item aa : either the reference or snp residue amino acid
        \item prediction : SIFT prediction
        \item score : SIFT score (range 0 to 1)
          \itemize{
            \item TOLERATED : score is > 0.05
            \item DAMAGING : score is <= 0.05
            \item NOT SCORED : no prediction is made if there are <2 homologous 
                               sequences that have an amino acid at the position
                               of the given SNP or if the SIFT prediction is not
                               available
         } 
        \item median : diversity measurement of the sequences used for 
                       prediction (range 0 to 4.32) 
        \item positionSeqs : number of sequences with an amino acide at the 
                             position of prediction
        \item totalSeqs : total number of sequences in alignment
      }
    }
  }
}


\details{
  SIFT is a sequence homology-based tool that sorts intolerant from tolerant 
  amino acid substitutions and predicts whether an amino acid substitution 
  in a protein will have a phenotypic effect. SIFT is based on the premise 
  that protein evolution is correlated with protein function. Positions 
  important for function should be conserved in an alignment of the protein 
  family, whereas unimportant positions should appear diverse in an alignment.

  SIFT uses multiple alignment information to predict tolerated 
  and deleterious substitutions for every position of the query sequence. 
  The procedure can be outlined in the following steps, 
  \itemize{
    \item search for similar sequences
    \item choose closely related sequences that may share similar
          function to the query sequence
    \item obtain the alignment of the chosen sequences
    \item calculate normalized probabilities for all possible
          substitutions from the alignment.
  } Positions with normalized probabilities less than 0.05 are predicted
  to be deleterious, those greater than or equal to 0.05 are predicted to be
  tolerated.
}

\references{
  SIFT Home:
  \url{http://sift.jcvi.org/}

  Kumar P, Henikoff S, Ng PC. Predicting the effects of coding non-synonymous
  variants on protein function using the SIFT algorithm. Nat Protoc.
  2009;4(7):1073-81

  Ng PC, Henikoff S. Predicting the Effects of Amino Acid Substitutions on
  Protein Function Annu Rev Genomics Hum Genet. 2006;7:61-80.

  Ng PC, Henikoff S. SIFT: predicting amino acid changes that affect protein
  function. Nucleic Acids Res. 2003 Jul 1;31(13):3812-4.
}

\author{Valerie Obenchain <vobencha@fhcrc.org>}

\examples{
  library(SIFT.Hsapiens.dbSNP132)

  ## metadata
  metadata(SIFT.Hsapiens.dbSNP132)

  ## table names, keys and cols
  head(keys(SIFT.Hsapiens.dbSNP132))
  cols(SIFT.Hsapiens.dbSNP132)

  ## subset on keys and cols 
  #rsids <- c("rs2142947", "NotFound", "rs17970171", "rs8692231", "rs3026284") 
  rsids <- c("rs2142947", "NotFound", "rs3026284", "rs1009382")
  select(SIFT.Hsapiens.dbSNP132, keys=rsids)

  subst <- c("rsid", "prediction", "score")
  select(SIFT.Hsapiens.dbSNP132, keys=rsids[c(1,3)], cols=subst)
}

\keyword{classes}
\keyword{methods}
