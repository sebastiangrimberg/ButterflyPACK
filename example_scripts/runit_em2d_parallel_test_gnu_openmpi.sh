#!/bin/bash -l

#SBATCH -q premium
#SBATCH -N 128
#SBATCH -t 00:30:00
#SBATCH -J paralleltest
#SBATCH --mail-user=liuyangzhuan@lbl.gov
#SBATCH -C haswell

module unload cray-mpich
module swap PrgEnv-intel PrgEnv-gnu
export MKLROOT=/opt/intel/compilers_and_libraries_2019.3.199/linux/mkl
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/intel/compilers_and_libraries_2019.3.199/linux/mkl/lib/intel64
module load openmpi/4.0.1
CCC=mpicc
CCCPP=mpicxx
FTN=mpif90


NTH=8
CORES_PER_NODE=32
THREADS_PER_RANK=`expr $NTH \* 2`								 

export EXEC=./EXAMPLE/ie2d
export OMP_NUM_THREADS=$NTH
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
  							 
											
# for nmpi in 16 18 32 50 64 98 128 200 256 512 1024
#for nmpi in  512 
for nmpi in  16 
# for nmpi in  32 64
do

NODE_VAL=`expr $nmpi / $CORES_PER_NODE \* $NTH`
for pat_comp in  3 #1: from right to left 2: from left to right 3: from outter to inner
do

for precon in 1  #1: direct 2: no preconditioner 3: LU preconditioner
do

# ######## half cyclinder
Ns=(50000)
wavelengths=(0.002)

			
					 

for ((i = 0; i < ${#Ns[@]}; i++)); do
N=${Ns[i]}
wavelength=${wavelengths[i]}

blknum=1
model=7
# N=5000
# wavelength=0.08
# wavelength=0.01
tol=1d-4
errcheck=0
lrcomp=4
bACAbatch=16
LRlevel=0
xyzsort=0
leafsize=50
para=0.01
schulzlevel=100		  
Nbundle=1 
knn=10
format=2		  

srun -n $nmpi -N $NODE_VAL -c $THREADS_PER_RANK --cpu_bind=cores $EXEC -quant --model2d $model --nunk $N --wavelength $wavelength -option --lr_blk_num $blknum --tol_comp $tol --errfillfull $errcheck --reclr_leaf $lrcomp --baca_batch $bACAbatch --lrlevel $LRlevel --precon $precon --xyzsort $xyzsort --nmin_leaf $leafsize --near_para $para --pat_comp $pat_comp --schulzlevel $schulzlevel --nbundle $Nbundle --format $format --knn $knn | tee hcylindar_N_${N}_w_${wavelength}_tol_${tol}_mpi_${nmpi}_nth_${OMP_NUM_THREADS}_LRlevel_${LRlevel}_precon_${precon}_sort_${xyzsort}_pat_${pat_comp}

done
done
done

done


