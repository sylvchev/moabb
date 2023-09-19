#!/bin/bash
#SBATCH --job-name=mobatch # nom du job
#SBATCH --output=/gpfsdswork/projects/rech/ouw/uhi38pi/logs/benchmark-%x-%j.log # fichier de sortie (%j = job ID, %x = job name)
#SBATCH --error=/gpfsdswork/projects/rech/ouw/uhi38pi/logs/error-%x-%j.log # fichier d’erreur (%j = job ID, %x = job name)
# #SBATCH --constraint=v100-16g # demander des GPU a 16 Go de RAM, sinon a100
#SBATCH --nodes=2 # reserver 1 nœud
#SBATCH --ntasks=8 # nombre de sujet
# #SBATCH --gres=gpu:1 # reserver 4 GPU, si CPU alors pas gpu
#SBATCH --cpus-per-task=10 # reserver 10 CPU par tache (et memoire associee)
#SBATCH --time=2:00:00 # temps maximal d’allocation "(HH:MM:SS)"
#SBATCH --qos=qos_cpu-dev # QoS qos_cpu-t3, qos_cpu-t4, qos_cpu-dev, idem avec gpu
#SBATCH --hint=nomultithread # desactiver l’hyperthreading
#SBATCH --account=ouw@cpu # comptabilite V100

# set -x # activer l’echo des commandes
module purge # nettoyer les modules herites par default
# conda deactivate # desactiver les environnements herites par default
module load tensorflow-gpu/py3/2.11.0 # charger les modules

nb_cpu=10
in_file="dataset-AlexandreMotorImagery.txt"
save_dir="/gpfswork/rech/ouw/uhi38pi"
pipelines="/linkhome/rech/genrqo01/uhi38pi/src/github/moabb/pipelines-mi"
context="/linkhome/rech/genrqo01/uhi38pi/src/github/moabb/contexts/mi_rh_f.yml"

# task is $SLURM_ARRAY_TASK_ID

while read line; do
	 dataset=$(echo ${line} | awk '{ print $1 }')
	 subj=$(echo ${line} | awk '{print $2}')

	 # create subj folder if it does not exist
	 if [ ! -e ${save_dir}/${dataset}-${subj} ]; then
		 mkdir -p ${save_dir}/${dataset}-${subj}/results ${save_dir}/${dataset}-${subj}/benchmark
	 fi
	 srun python -u run-jeanzay.py --pipelines ${pipelines} --results ${save_dir}/${dataset}-${subj}/results --output ${save_dir}/${dataset}-${subj}/benchmark --threads ${nb_cpu} --contexts ${context} --paradigm "MotorImagery" --include-dataset ${dataset} --subject ${subj}
done < ${in_file}
wait
