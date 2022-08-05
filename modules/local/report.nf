process REPORT {

    container "${ 'qbicpipelines/rnadeseq:dev' }"

    input:
    path gene_counts
    path metadata
    path model
    path gtf

    path contrast_matrix
    path contrast_list
    path contrast_pairs
    path genelist
    path relevel

    path proj_summary
    path softwareversions
    path multiqc

    output:
    path "*.zip"
    path "RNAseq_report.html", emit: rnaseq_report

    script:

    def contrast_matrix_opt = contrast_matrix.name != 'DEFAULT' ? "--contrast_matrix $contrast_matrix" : ''
    def contrast_list_opt = contrast_list.name != 'DEFAULT1' ? "--contrast_list $contrast_list" : ''
    def contrast_pairs_opt = contrast_pairs.name != 'DEFAULT2' ? "--contrast_pairs $contrast_pairs" : ''
    def genelist_opt = genelist.name != 'NO_FILE' ? "--genelist $genelist" : ''
    def relevel_opt = relevel.name != 'NO_FILE2' ? "--relevel $relevel" : ''
    def batch_effect_opt = params.batch_effect ? "--batch_effect TRUE" : ''
    def rlog_opt = params.use_vst ? '--rlog FALSE' : ''
    def round_DE_opt = params.round_DE ? "--round_DE $params.round_DE" : ''

    def pathwayopt = params.skip_pathway_analysis ? '' : "--pathway_analysis"

    def citest_opt = params.citest == "true" ? "--citest TRUE" : ''

    """
    if [ "$multiqc" != "NO_FILE3" ]; then
        unzip $multiqc
        mkdir QC
        mv MultiQC/multiqc_plots/ MultiQC/multiqc_data/ MultiQC/multiqc_report.html QC/
    fi
    Execute_report.R \
        --report '$baseDir/assets/RNAseq_report.Rmd' \
        --output 'RNAseq_report.html' \
        --input_type $params.input_type \
        --gene_counts $gene_counts \
        --metadata $metadata \
        --model $model \
        --gtf $gtf \
        $contrast_matrix_opt \
        $contrast_list_opt \
        $contrast_pairs_opt \
        $genelist_opt \
        $relevel_opt \
        $batch_effect_opt \
        --log_FC_threshold $params.logFCthreshold \
        $rlog_opt \
        --nsub_genes $params.vst_genes_number \
        $round_DE_opt \
        $pathwayopt \
        --organism $params.organism \
        --species_library $params.library \
        --keytype $params.keytype \
        --min_DEG_pathway $params.min_DEG_pathway \
        --proj_summary $proj_summary \
        --versions $softwareversions \
        --revision $workflow.manifest.version \
        $citest_opt

    # Remove allgenes dir as the contained files do not contain only DE genes
    rm -r differential_gene_expression/allgenes
    # If citest, remove heatmaps as their filenames contain : which is an invalid character
    if [ "$params.citest" == true ]; then
        mkdir ../../../results_test
        cp -r RNAseq_report.html differential_gene_expression/ pathway_analysis/ ../../../results_test
        if [ "$pathwayopt" == "--pathway_analysis" ]; then
            cp -r pathway_analysis/ ../../../results_test
        fi
    fi
    if [ "$pathwayopt" == "--pathway_analysis" ]; then
        zip -r report.zip RNAseq_report.html differential_gene_expression/ QC/ pathway_analysis/
    else
        zip -r report.zip RNAseq_report.html differential_gene_expression/ QC/
    fi
    """




}

