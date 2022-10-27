FROM ubuntu:20.04

MAINTAINER yuhao<yqyuhao@outlook.com>

RUN sed -i 's/http:\/\/archive\.ubuntu\.com\/ubuntu\//http:\/\/mirrors\.aliyun\.com\/ubuntu\//g' /etc/apt/sources.list

# set timezone
RUN set -x \
&& export DEBIAN_FRONTEND=noninteractive \
&& apt-get update \
&& apt-get install -y tzdata \
&& ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone

# install packages
RUN apt-get update \

&& apt-get install -y less curl apt-utils vim wget gcc-7 g++-7 make cmake git unzip dos2unix libncurses5 \

# lib
&& apt-get install -y zlib1g-dev libjpeg-dev libncurses5-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev \
 
# python3 perl java r-base
&& apt-get install -y python3 python3-dev python3-pip python perl openjdk-8-jdk r-base r-base-dev

ENV software /Righton_software

# create software folder

RUN mkdir -p /data/RightonAuto/analysis /data/RightonAuto/config $software/database $software/source $software/target $software/bin

# featureCounts
WORKDIR $software/source
RUN wget -c http://downloads.sourceforge.net/project/subread/subread-1.5.1/subread-1.5.1-Linux-x86_64.tar.gz -o $software/source/subread-1.5.1-Linux-x86_64.tar.gz \
&& tar -xf $software/source/subread-1.5.1-Linux-x86_64.tar.gz \
&& ln -s $software/source/subread-1.5.1-Linux-x86_64/bin/featureCounts $software/bin/featureCounts \
&& rm software/source/subread-1.5.1-Linux-x86_64.tar.gz

# STAR
WORKDIR $software/source
RUN git clone https://github.com/alexdobin/STAR.git \
&& mv $software/source/STAR $software/source/STAR-2.7.10 && cd $software/source/STAR-2.7.10 && make \
&& ln -s $software/source/STAR-2.7.10/STAR $software/bin/STAR

# cutadapt
RUN pip3 install cutadapt

# fastp v0.22.0
WORKDIR $software/source
RUN wget -c https://github.com/OpenGene/fastp/archive/refs/tags/v0.22.0.tar.gz -O $software/source/fastp.v0.22.0.tar.gz \
&& tar -xf $software/source/fastp.v0.22.0.tar.gz && cd $software/source/fastp-0.22.0 && make \
&& ln -s $software/source/fastp-0.22.0/fastp $software/bin/fastp

# bwa v0.7.17
WORKDIR $software/source
RUN wget -c https://github.com/lh3/bwa/releases/download/v0.7.17/bwa-0.7.17.tar.bz2 -O $software/source/bwa-0.7.17.tar.bz2 \
&& tar -xjvf $software/source/bwa-0.7.17.tar.bz2 && cd $software/source/bwa-0.7.17 \
&& make && ln -s $software/source/bwa-0.7.17/bwa $software/bin/bwa

# samtools v1.11
WORKDIR $software/source
RUN wget -c https://github.com/samtools/samtools/releases/download/1.11/samtools-1.11.tar.bz2 -O $software/source/samtools-1.11.tar.bz2 \
&& tar jxvf $software/source/samtools-1.11.tar.bz2 \
&& cd $software/source/samtools-1.11 \
&& ./configure \
&& make \
&& ln -s $software/source/samtools-1.11/samtools $software/bin/samtools

# gatk 4.1.3.0
WORKDIR $software/source
RUN wget -c https://github.com/broadinstitute/gatk/releases/download/4.1.3.0/gatk-4.1.3.0.zip \
&& unzip gatk-4.1.3.0.zip \
&& ln -s $software/source/gatk-4.1.3.0/gatk $software/bin/gatk

# bedtools v2.29.2
WORKDIR $software/source
RUN wget -c https://github.com/arq5x/bedtools2/releases/download/v2.29.2/bedtools-2.29.2.tar.gz -O $software/source/bedtools-2.29.2.tar.gz \
&& tar -zxvf $software/source/bedtools-2.29.2.tar.gz && mv $software/source/bedtools2 $software/source/bedtools-2.29.2 \
&& cd $software/source/bedtools-2.29.2/ \
&& sed -i '112s/const/constexpr/g' src/utils/fileType/FileRecordTypeChecker.h \
&& make clean \
&& make all \
&& ln -s $software/source/bedtools-2.29.2/bin/bedtools $software/bin/bedtools

# fastqc v0.11.9
WORKDIR $software/source
RUN wget -c https://github.com/s-andrews/FastQC/archive/refs/tags/v0.11.9.tar.gz -O $software/source/fastqc.v0.11.9.tar.gz \
&& tar -xf $software/source/fastqc.v0.11.9.tar.gz \
&& cd $software/source/FastQC-0.11.9 \
&& ln -s $software/source/FastQC-0.11.9/fastqc $software/bin/fastqc

# genefuse v0.6.1
WORKDIR $software/source
RUN wget https://github.com/OpenGene/GeneFuse/archive/refs/tags/v0.6.1.tar.gz -O $software/source/genefuse-v0.6.1.tar.gz \
&& tar -zxvf $software/source/genefuse-v0.6.1.tar.gz \
&& cd $software/source/GeneFuse-0.6.1 && make \
&& ln -s $software/source/GeneFuse-0.6.1 $software/bin/genefuse

# conda v4.12
WORKDIR $software/source
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.12.0-Linux-x86_64.sh -O $software/source/Miniconda3-py37_4.12.0-Linux-x86_64.sh \
&& sh $software/source/Miniconda3-py37_4.12.0-Linux-x86_64.sh -b -p $software/bin/conda-v4.12 \
&& $software/bin/conda-v4.12/bin/conda config --add channels conda-forge \
&& $software/bin/conda-v4.12/bin/conda config --add channels r \
&& $software/bin/conda-v4.12/bin/conda config --add channels bioconda

# jellyfish
RUN $software/bin/conda-v4.12/bin/conda install -y jellyfish -c bioconda
