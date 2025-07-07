# set working directory path
if (file.exists("/home/amovas/")){
  print("Remote HPC Connection!")
  wd <- "/home/amovas/data/genome-evo-proj/"
} else {
  print("Local PC Connection!")
  wd <- "/Users/alimos313/Documents/studies/phd/hpc-research/genome-evo-proj/"
}

# load data
source(paste0(wd, "src/analysis/1st-man/readin_data.r"))


variants_ann_expiii %<>% 
    filter(allele_freq >= 0.01) %>%
    select(chrom, exp_line, passage, mut_type, genomic_pos, ref_allele, alt_allele, mut_info, mut_context, allele_freq, coverage, feature, feature_range, variant_id, annotation_id, effect, impact, effect_simplified, ORF, aa_change, loc_in_cds, loc_in_protein) %>%
    mutate(chrom = "NL43_ancestral_plasmid")


# save the data
saveRDS(variants_ann_expiii, paste0("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/variants_ann_expiii.rds"))


