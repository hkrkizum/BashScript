# RNA-seq

 Scripts for RNA-seq, Windows subsystem on Linux

## Getting Started

### Requirement

#### 1. Hardware

When STAR running, large size memory (~ 40GB in rat RNA-seq alinemnt) will be required.

#### 2. Software

- pigz</br>
  "A parallel implementation of gzip for modern multi-processor, multi-core machines"

- STAR</br>
  "Spliced Transcripts Alignment to a Reference"</br>
  https://github.com/alexdobin/STAR

- fastp</br>
  "A tool designed to provide fast all-in-one preprocessing for FastQ files"</br>
  https://github.com/OpenGene/fastp

- Subread</br>
  "high-performance read alignment, quantification and mutation discovery"</br>
  http://subread.sourceforge.net/
  
### Installation

Check PATH to softwares

``` bash
$ STAR --version
2.7
$ fastp --version

$ featureCount --version

```

Pull repository

```bash
$ git clone https://github.com/hkrkizum/BashScript.git
...
```


if you do not have the analysistools described above, you can set up analysis environment using docker image.

```bash
$ docker pull hkrkizum/bioinfo_star:1.1
...
$ docker pull hkrkizum/bioinfo_fastp:1.1
...
$ docker pull hkrkizum/bioinfo_subread:1.0
...
```

## Usage

auto_***.sh -i [full path of dir contain target files] -o [full path of output dir]
