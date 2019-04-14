#!/bin/bash
#SBATCH --qos=premium
#SBATCH --time=15:00
#SBATCH --nodes=1
#SBATCH --constraint=haswell
#SBATCH --image=roybens/bpopt:v1
#SBATCH --array 1-1
#SBATCH --export=PYTHONPATH=/build/nrn/src/nrnpython/build/lib.linux-x86_64-2.7/neuron:/build/nrn/share/lib/python

echo "start-A "`hostname`" task="${job_sh}
echo  'cscratch='${CSCRATCH}
echo  'scratch='${SCRATCH}
echo SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}
echo SLURM_JOBID=${SLURM_JOBID}


sleep 10
model=mainen4v27
c='mainen4v27'
stimName='chirp23a'
coreN=${c}'/sandbox/'${SLURM_ARRAY_JOB_ID}
arrIdx=${SLURM_ARRAY_TASK_ID}
wrkDir=${SCRATCH}/${coreN}-${arrIdx}
echo 'my wrkDir='${wrkDir}
mkdir -p ${wrkDir}
mkdir -p ${wrkDir}/${stimName}

parFileN=params512_$arrIdx
cp /global/cscratch1/sd/asranjan/${c}/params/$parFileN.csv ${wrkDir}
cp /global/cscratch1/sd/asranjan/${c}/params/${parFileN}Sets.csv ${wrkDir}
cp run_one_pin_parts.py  ${wrkDir}
cp /global/homes/a/asranjan/ML/run_mainen/gen_hd5.py  ${wrkDir}
cp /global/homes/a/asranjan/ML/run_mainen/run_model_cori_pin_parts.hoc  ${wrkDir}
cp /global/homes/a/asranjan/ML/run_mainen/times_0.02_23k.csv ${wrkDir}
cp /global/homes/a/asranjan/ML/run_mainen/${stimName}/${stimName}.csv ${wrkDir}/${stimName}
cp -rp /global/homes/a/asranjan/ML/run_mainen/x86_64 ${wrkDir}/
cd ${wrkDir}
echo inventore at start
pwd
ls -l *
export PYTHONPATH=/build/nrn/src/nrnpython/build/lib.linux-x86_64-2.7/neuron:/build/nrn/share/lib/python
srun -n 64 shifter /build/nrn/x86_64/bin/nrniv -mpi ./run_one_pin_parts.py $parFileN

module load tensorflow/intel-1.12.0-py36

python gen_hd5.py $arrIdx 512 4paramsv27 mainen4v27
