FROM continuumio/miniconda:4.6.14
LABEL authors="Gisela Gabernet, Alexander Peltzer" \
    description="Docker image containing all requirements for qbic-pipelines/rnadeseq pipeline"
COPY environment.yml /
RUN conda install -c conda-forge mamba
RUN mamba env create -f /environment.yml && conda clean -a
RUN apt-get update -qq && \
    apt-get install -y zip procps ghostscript
# Add conda installation dir to PATH
ENV PATH /opt/conda/envs/qbic-pipelines-rnadeseq-dev/bin:$PATH
# Dump the details of the installed packates to a file for posterity
RUN mamba env export --name qbic-pipelines-rnadeseq-dev > qbic-pipelines-rnadeseq-dev.yml
# Instruct R processes to use these empty files instead of clashing with a local config
RUN touch .Rprofile
RUN touch .Renviron
