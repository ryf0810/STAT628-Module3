#!/bin/bash
set -e

tar --warning=no-unknown-keyword -xzf data.tar.gz

export HOME=$PWD
export PATH
sh Miniconda3-latest-Linux-x86_64.sh -b -p $PWD/miniconda3
export PATH=$PWD/miniconda3/bin:$PATH

conda install pandas tqdm Pillow 
conda install pytorch::pytorch torchvision torchaudio -c pytorch
#wandb login <your api key>

python3 model_parallel.py
