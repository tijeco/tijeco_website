+++
title = "Reproducubility Tutorial"
subtitle = "Tutorial for bioinformatics pipelines"

date = 2017-04-18T00:00:00
#lastmod = 2018-01-13T00:00:00
draft = false

# Authors. Comma separated list, e.g. `["Bob Smith", "David Jones"]`.
authors = ["Jeff Cole"]

tags = ["tutorials"]
summary = "Tutorial for bioinformatics pipelines"

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["deep-learning"]` references 
#   `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
# projects = ["internal-project"]

# Featured image
# To use, add an image named `featured.jpg/png` to your project's folder. 
[image]
  # Caption (optional)
  caption = "Image credit: [**Unsplash**](https://unsplash.com/photos/CpkOjOcXdUY)"

  # Focal point (optional)
  # Options: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight
  focal_point = ""

  # Show image only in page previews?
  preview_only = false


+++

## Topics to be covered
1. Anaconda
2. Snakemake
3. Docker

# Let's try to make a small bioinformatics pipeline



Let's say we have some FASTA files containing protein sequences, and we'd like to make a phylogeny with those sequences.

To do this we would make the following bash script, called ```butterbean.sh```
It would look like the following

```bash
#!/bin/bash
mafft --auto --phylipout  $1 > $1.aln
fasttree  $1.aln  > $1.tree
```





**Data for the pipeline!**

Create a file called ```ex1.fasta``` from [here](https://raw.githubusercontent.com/tijeco/ReproducibilityTutorial/master/ex1.fasta)



## The pipeline works the following way:


First, ```mafft``` takes as input a fasta file of protein sequences as from input file the first argument ```$1```, in this case ```ex1.fasta```. The program then automatically chooses the best algorithm for generating an alignment as prompted by ```--auto```, it then produces a multiple sequence alignment named ```ex1.fasta.aln```  from ```$1.aln```
 Then, ```fasttree``` takes as input the ouput from ```mafft``` referenced as ```$1.aln``` in our case known as ```ex1.fasta.aln```. It then prodeces a newick format phylogeny of the sequences in the file referenced as ```$1.tree``` in our case ex1.fasta.tree

## Running our pipeline

Issue the folowing command to run the pipeline ```butterbean.sh``` on our data  ```ex1.fasta```

```bash
bash butterbean.sh ex1.fasta
```

## What did the output look like?

You may have received the following error message
```bash
butterbean.sh: line 2: mafft: command not found
butterbean.sh: line 3: fasttree: command not found
```

## What went wrong????? :sob: :sob: :sob:

Well,```mafft``` and ```fasttree``` are dependencies for ```butterbean``` and **must** be installed on your system in order to work properly.

If only there were a system in place for managing software packages and dependencies....

</br>
</br>


![alt text](https://conda.io/docs/_images/conda_logo.svg)

</br>
Software package dependency and environment management system.

Allows for easy version control!

## Make a conda environment for butterbean's dependencies

Make a file called ```butterbean.requirements.txt``` with the following information in it

```
mafft=7.310
fasttree=2.1.9
```

This file can be used to create a conda environment called **{your_name_here}_butterbean** using the following command


###  DO NOT USE UPPER CASE IN {your_name_here} 


```bash
conda create --name {your_name_here}_butterbean -c bioconda --file butterbean.requirements.txt
```


Issue the following command to activate this environment

```bash
source activate {your_name_here}_butterbean
```

Now we can rerun the pipeline

```bash
bash butterbean.sh ex1.fasta
```

Hopefully it actually worked!

You should have a tree!


**What if we wanted to run our pipeline on hundreds of fasta files?**

**Can we add multithread support?**

**Can we have the dependencies automatically install themselves?**




# **Snakemake**

![](https://bitbucket-assetroot.s3.amazonaws.com/c/photos/2012/Dec/31/snakemake-logo-1807870285-12_avatar.png)

This is a workflow management system that can increase the usability and reproducibility of our pipeline


## Setup conda environments

First, we need to take care of dependencies. We can set up conda environments for snakemake to setup and run on the fly during analysis

make a directory called ```envs```

In that directory, make the file ```envs/mafft.yaml``` with the following contents

```yaml
channels:
  - bioconda
dependencies:
  - mafft=7.310
```

Make another file ```envs/fasttree.yaml``` with the following contents

```yaml
channels:
  - bioconda
dependencies:
  - fasttree=2.1.9
```

## Make Snakefile
Make a file called ```Snakefile``` with the following information in it


```python
SAMPLES, = glob_wildcards("{sample}.fasta")
```

This uses wild cards to find all files that end in **.fasta** that will be used by the pipeline

Add the final subroutine to ```Snakefile```

```python

rule final:
    input:expand("{sample}.tree",sample=SAMPLES)
```

Then, add the first subroutine

```python
rule mafft:
    input:
        "{sample}.fasta"
    output:
        "{sample}.aln"
    conda:
        "envs/mafft.yaml"
    shell:
        "mafft --auto --phylipout {input} > {output}"

```

Then, we add the second subroutine

```python
rule fasttree:
    input:
        "{sample}.aln"
    output:
        "{sample}.tree"
    conda:  
        "envs/fasttree.yaml"
    shell:
        "fasttree  {input}  > {output}"
```

Altogether, the file looks like the following

```python
SAMPLES, = glob_wildcards("{sample}.fasta")

rule final:
    input:expand("{sample}.tree",sample=SAMPLES)

rule mafft:
    input:
        "{sample}.fasta"
    output:
        "{sample}.aln"
    conda:
        "envs/mafft.yaml"
    shell:
        "mafft --auto --phylipout {input} > {output}"

rule fasttree:
    input:
        "{sample}.aln"
    output:
        "{sample}.tree"
    conda:
        "envs/fasttree.yaml"
    shell:
        "fasttree  {input}  > {output}"


```

Run the pipeline with the following command

```bash
snakemake --use-conda
```

**What if we want others to rerun our analysis on their computer with a non supported operating system?**

**Can we distribute our pipeline as a self contained virtual environment**


![](https://www.docker.com/sites/default/files/social/docker_twitter_share.png)

Create a file ```Dockerfile``` with the following information

```Docker
FROM ubuntu
MAINTAINER Jeff Cole <coleti16@students.ecu.edu>


RUN apt-get -qq update
RUN apt-get install -y wget git build-essential cmake unzip curl
RUN apt-get install -qqy python3-setuptools python3-docutils python3-flask
RUN easy_install3 snakemake

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.3.14-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

ENV PATH /opt/conda/bin:$PATH

WORKDIR /home/user/

RUN git clone https://github.com/tijeco/ReproducibilityTutorial.git

WORKDIR /home/user/ReproducibilityTutorial

RUN ln -sf /bin/bash /bin/sh

RUN snakemake --use-conda
```
Build the docker container

```bash
docker build -t {your_name_here}_butterbean ./

```

Run the docker container with the following command

```bash
docker run -it {your_name_here}_butterbean /bin/bash
```