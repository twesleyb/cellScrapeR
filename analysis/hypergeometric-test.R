#!/usr/bin/env Rscript

# Hypergeometric test for enrichment.

# pop size : 5260
# sample size : 131
# Number of items in the pop that are classified as successes : 1998
# Number of items in the sample that are classified as successes : 62
# phyper(q, m, n, k, lower.tail = TRUE, log.p = FALSE)

#q numer of white balls drawn.
#m the number of white balls in the urn.
#n the number of black balls in the urn.
#k the number of balls drawn from the urn.

hyperTest <- function(n_success,pop_size,pop_success,sample_size) {
	n_expected <- sample_size*(pop_success/pop_size)
	fold_enrichment <- n_success/n_expected
	pval <- 1 - phyper(n_success,pop_success,pop_size-pop_success,sample_size,lower.tail=TRUE)
	result <- c("Fold Enrichment"=fold_enrichment,"P-value"=pval)
	return(result)
}

hyperTest(n_success = 62,pop_size = 5260,pop_success = 1998,sample_size = 131)


# Try to generalize for lists of genes of interst and pathways.
listA = genes_of_interest
listB = pathways

listA <- list("A" = sample(LETTERS,sample(seq(5,15),1)),
	      "B" = sample(LETTERS,sample(seq(5,15),1)))
listB <- list(vowels = c("A","E","I","O","U"),
	      special = c("Q","X","Y","Z"))
for (i in 1:length(listA)){
	a = listA[[i]]
	b = listB[[i]]
	n_success = length(intersect(a,b))
	pop_size = length(union(a,b))
	pop_success = length(intersect(union(a,b),b))
	sample_size = length(a)
}


