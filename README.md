# ULB Sachsen-Anhalt - OCR System

![Python application](https://github.com/ulb-sachsen-anhalt/ocr-pipeline/workflows/Python%20application/badge.svg)

OCR-System of project "Digitalisierung historischer deutscher Zeitungen" (2019-2021). Processes large chunks of bare Imagefiles and creates for each file a correspondig OCR-Output in ALTO-XML V3 format using Open-Source Engine [Tesseract-OCR](https://github.com/tesseract-ocr/tesseract).

## Installation

Target Build and Runtime Platform: [Docker Container](https://www.docker.com/get-started) on [Ubuntu 18.04 LTS Server](https://ubuntu.com/#download)

### Host Specifications

* docker-ce (container image creation and container runtime)
* optional: libsm6 (if OpenCV used)
* optional: python3-venv (if Python is used outside Container, i.e. running Tests)
* optional: gitlab-runner with shell executor for CI/CD-based workflows

### Build Image

The OCR-Container is build in 2 stages.

The basis image contains a self-compiled version of Tesseract, cloned from <https://github.com/ulb-sachsen-anhalt/tesseract> plus localisations and additional Tesseract model configuration files like `frk` and `Fraktur`. This is extend in step 2 with the actual OCR-Container, that puts the scripts in place, declares entrypoint and takes care for internal structures that can be mapped at runtime to external images, workdir and logdir folders.

```shell
# 1st: build base image from official Tesseract Release Tag and with desired image name
./create-baseimage.sh 4.1.1 ulb-tesseract
=> ulb-tesseract:4.1.1

# 2nd: build ocr system image using the previously created base image + tag and desired name and version tag
./create-image.sh ulb-tesseract 4.1.1 ulb-ocr-system 1.0.0
=> ulb-ocr-system:1.0.0

```

## Development

### Setup

For local development required to have Python3 installed (version 3.6+). For coding assistance, supply your favourite IDE with Python support. If you don't know which one to choose, I can recommend [Visual Studio Code](https://code.visualstudio.com/). The Development OS was Ubuntu 18.04, but Windows with similar Python version should to the job fine.

Activate virtual Python environment and install required libraries on a Windows System:

```bash

# windows
python -m venv venv
venv\Scripts\activate.bat

pip install --upgrade pip
pip install -r requirements.txt

```

Afterwards, the [pytest Library](https://docs.pytest.org/en/latest/contents.html) is used to execute the current test cases from `test/test_steps.py` (with verbosity flag `v`)

```bash
pytest -v
```

## Execution

The script `manage-container-ocr.sh` forms the OCR-part of a larger digitalisation pipeline which spans itself from image scanning from microfiches to delivering data towards the final presentation system of the library.

It is scheduled at a fixed rate on the host. When triggered, it's searching a small marker file in a specific range of image-folders with name `meta_done`, which represents the previous stage in the workflow. After running the OCR-System, this marker file is moved on as `ocr_done`, which indicates the following step that it can go on since OCR has sucessfully finished.

### Example CronJob Entry

The script required the following parameters

* name of container: only one running container with this name is allowed on host
* number of parallel executors: how many Tesseracts to run
* image with name:tag
* pattern for image folders: image folders are organized with scoped names
* model configuration: label of model configuration for Tessract

```bash
sudo -u ocr /<absolute-path-to>/manage-container-ocr.sh ocr-pipeline-14 14 ulb-ocr-pipeline:1.0.6 "/data/ocr/${PPN_SAALEBOTE}_J_01*" frk | logger -t CRON_OCR
```

### Logging

Logging is done via configuration file `ocr_logger_config.ini`.

This file can be customized to alter provided loggers and formats.
