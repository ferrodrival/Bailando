#!/bin/sh
currenttime=`date "+%Y%m%d%H%M%S"`
if [ ! -d log ]; then
    mkdir log
fi

echo "[Usage] ./srun.sh config_path [train|eval] partition gpunum"
# check config exists
if [ ! -e "$1" ]
then
    echo "[ERROR] configuration file: $1 does not exists!"
    exit 1
fi

# Extract expname from config path
config_suffix=$(basename "$1" .yaml)
expname="exp_${config_suffix}_${currenttime}"

if [ ! -d "${expname}" ]; then
    mkdir "${expname}"
fi

echo "[INFO] saving results to, or loading files from: $expname"

if [ -z "$3" ]; then
    echo "[ERROR] enter partition name"
    exit 1
fi
partition_name=$3
echo "[INFO] partition name: $partition_name"

if [ -z "$4" ]; then
    echo "[ERROR] enter gpu num"
    exit 1
fi
gpunum=$4
gpunum=$((gpunum<8?gpunum:8))
echo "[INFO] GPU num: $gpunum"
ntask=$((gpunum*3))


TOOLS="srun --mpi=pmi2 --partition=$partition_name --gres=gpu:$gpunum -n1 --job-name=${config_suffix}"
PYTHONCMD="python -u main.py --config $1"

if [ "$2" = "train" ];
then
    $TOOLS $PYTHONCMD --train 
elif [ "$2" = "eval" ];
then
    $TOOLS $PYTHONCMD --eval 
elif [ "$2" = "visgt" ];
then
    $TOOLS $PYTHONCMD --visgt 
elif [ "$2" = "anl" ];
then
    $TOOLS $PYTHONCMD --anl 
elif [ "$2" = "sample" ];
then
    $TOOLS $PYTHONCMD --sample 
fi