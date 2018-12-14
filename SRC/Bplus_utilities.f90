! “ButterflyPACK” Copyright (c) 2018, The Regents of the University of California, through
! Lawrence Berkeley National Laboratory (subject to receipt of any required approvals from the
! U.S. Dept. of Energy). All rights reserved.

! If you have questions about your rights to use or distribute this software, please contact
! Berkeley Lab's Intellectual Property Office at  IPO@lbl.gov.

! NOTICE.  This Software was developed under funding from the U.S. Department of Energy and the
! U.S. Government consequently retains certain rights. As such, the U.S. Government has been
! granted for itself and others acting on its behalf a paid-up, nonexclusive, irrevocable
! worldwide license in the Software to reproduce, distribute copies to the public, prepare
! derivative works, and perform publicly and display publicly, and to permit other to do so.

! Developers: Yang Liu
!             (Lawrence Berkeley National Lab, Computational Research Division).

#include "ButterflyPACK_config.fi"
module Bplus_Utilities
use misc
contains


subroutine Bplus_delete(bplus)
use BPACK_DEFS
use misc
implicit none
type(matrixblock),pointer::block
type(blockplus)::bplus

integer i, j, ii, jj, iii, jjj,index_ij,mm,nn,rank,index_i,index_j,levelm,index_i_m,index_j_m,ll,bb
integer level, blocks, edge, patch, node, group,level_c
integer::block_num,block_num_new,num_blocks,level_butterfly,Nboundall
real(kind=8)::rtemp

if(associated(bplus%LL))then
do ll=1,LplusMax
	if(bplus%LL(ll)%Nbound>0)then
		if(associated(bplus%LL(ll)%matrices_block))then
		do bb=1,bplus%LL(ll)%Nbound
			! write(*,*)ll,bplus%Lplus,bb,bplus%LL(ll)%Nbound,'fff'
			call BF_delete(bplus%LL(ll)%matrices_block(bb),1)
		end do
		deallocate(bplus%LL(ll)%matrices_block)
		endif
		if(allocated(bplus%LL(ll)%boundary_map))deallocate(bplus%LL(ll)%boundary_map)
	end if
end do
deallocate(bplus%LL)
endif

end subroutine Bplus_delete


subroutine Bplus_copy(bplus_i,bplus_o,memory)
use BPACK_DEFS
use misc
implicit none
type(matrixblock),pointer::block_i,block_o
type(blockplus)::bplus_i,bplus_o

integer i, j, ii, jj, iii, jjj,index_ij,mm,nn,rank,index_i,index_j,levelm,index_i_m,index_j_m,ll,bb
integer level, blocks, edge, patch, node, group,level_c
integer::block_num,block_num_new,num_blocks,level_butterfly,Nboundall
real(kind=8),optional::memory
real(kind=8)::rtemp

call Bplus_delete(bplus_o)

if(present(memory))memory=0

allocate(bplus_o%LL(LplusMax))
bplus_o%Lplus = bplus_i%Lplus
bplus_o%boundary = bplus_i%boundary
bplus_o%level = bplus_i%level
bplus_o%col_group = bplus_i%col_group
bplus_o%row_group = bplus_i%row_group
bplus_o%pgno = bplus_i%pgno


do ll=1,LplusMax
	bplus_o%LL(ll)%Nbound=bplus_i%LL(ll)%Nbound
	bplus_o%LL(ll)%rankmax=bplus_i%LL(ll)%rankmax



	if(bplus_i%LL(ll)%Nbound>0)then
		allocate(bplus_o%LL(ll)%matrices_block(bplus_i%LL(ll)%Nbound))
		do bb=1,bplus_i%LL(ll)%Nbound
			call BF_copy('N',bplus_i%LL(ll)%matrices_block(bb),bplus_o%LL(ll)%matrices_block(bb),rtemp)
			if(present(memory))memory=memory+rtemp
		end do
		if(allocated(bplus_i%LL(ll)%boundary_map))then
			Nboundall=size(bplus_i%LL(ll)%boundary_map)
			allocate(bplus_o%LL(ll)%boundary_map(Nboundall))
			if(present(memory))memory=memory+ SIZEOF(bplus_o%LL(ll)%boundary_map)/1024.0d3
			bplus_o%LL(ll)%boundary_map = bplus_i%LL(ll)%boundary_map
		endif
	end if
end do

end subroutine Bplus_copy


subroutine Bplus_copy_delete(bplus_i,bplus_o,memory)
use BPACK_DEFS
use misc
implicit none
type(matrixblock),pointer::block_i,block_o
type(blockplus)::bplus_i,bplus_o

integer i, j, ii, jj, iii, jjj,index_ij,mm,nn,rank,index_i,index_j,levelm,index_i_m,index_j_m,ll,bb
integer level, blocks, edge, patch, node, group,level_c
integer::block_num,block_num_new,num_blocks,level_butterfly,Nboundall
real(kind=8),optional::memory
real(kind=8)::rtemp

if(present(memory))memory=0

allocate(bplus_o%LL(LplusMax))
bplus_o%Lplus = bplus_i%Lplus
bplus_o%boundary = bplus_i%boundary
bplus_o%level = bplus_i%level
bplus_o%col_group = bplus_i%col_group
bplus_o%row_group = bplus_i%row_group


do ll=1,LplusMax
	bplus_o%LL(ll)%Nbound=bplus_i%LL(ll)%Nbound
	bplus_o%LL(ll)%rankmax=bplus_i%LL(ll)%rankmax
	if(bplus_i%LL(ll)%Nbound>0)then
		allocate(bplus_o%LL(ll)%matrices_block(bplus_i%LL(ll)%Nbound))
		do bb=1,bplus_i%LL(ll)%Nbound
			call BF_copy_delete(bplus_i%LL(ll)%matrices_block(bb),bplus_o%LL(ll)%matrices_block(bb),rtemp)
			if(present(memory))memory=memory+rtemp
		end do
		deallocate(bplus_i%LL(ll)%matrices_block)
		Nboundall=size(bplus_i%LL(ll)%boundary_map)
		allocate(bplus_o%LL(ll)%boundary_map(Nboundall))
		if(present(memory))memory=memory+ SIZEOF(bplus_o%LL(ll)%boundary_map)/1024.0d3
		bplus_o%LL(ll)%boundary_map = bplus_i%LL(ll)%boundary_map
		deallocate(bplus_i%LL(ll)%boundary_map)
	end if
end do

deallocate(bplus_i%LL)
end subroutine Bplus_copy_delete



subroutine Bplus_extract_partial(bplus_i,ll_s,row_group,agent_bplus,msh)
use BPACK_DEFS
use misc
implicit none
type(matrixblock),pointer::block_i,block_o
type(blockplus)::bplus_i,agent_bplus

integer i, j, ii, jj, iii, jjj,index_ij,mm,nn,rank,index_i,index_j,levelm,index_i_m,index_j_m,ll,bb,bb_o
integer level, blocks, edge, patch, node, group,level_c
integer::block_num,block_num_new,num_blocks,level_butterfly,Nboundall
real(kind=8)::rtemp
integer row_group,ll_s,idx_s,idx_e
type(mesh)::msh

call assert(bplus_i%row_group==bplus_i%col_group,'only works for square matrix')

idx_s = msh%basis_group(row_group)%head
idx_e = msh%basis_group(row_group)%tail

! allocate(agent_bplus)
allocate(agent_bplus%LL(LplusMax))
do ll=1,LplusMax
agent_bplus%LL(ll)%Nbound = 0
end do

agent_bplus%Lplus = bplus_i%Lplus - ll_s + 1
agent_bplus%row_group = 	row_group
agent_bplus%col_group = 	row_group
agent_bplus%level = GetTreelevel(row_group)-1

do ll=1,agent_bplus%Lplus
	agent_bplus%LL(ll)%Nbound = 0
	agent_bplus%LL(ll)%rankmax=bplus_i%LL(ll+ll_s-1)%rankmax
	do bb=1,bplus_i%LL(ll+ll_s-1)%Nbound
		if(msh%basis_group(bplus_i%LL(ll+ll_s-1)%matrices_block(bb)%row_group)%head>=idx_s .and. msh%basis_group(bplus_i%LL(ll+ll_s-1)%matrices_block(bb)%row_group)%tail<=idx_e)then
			agent_bplus%LL(ll)%Nbound = agent_bplus%LL(ll)%Nbound + 1
		end if
	end do
	if(agent_bplus%LL(ll)%Nbound>0)then
		allocate(agent_bplus%LL(ll)%matrices_block(agent_bplus%LL(ll)%Nbound))
	end if
end do


do ll=1,agent_bplus%Lplus
	bb_o = 0
	do bb=1,bplus_i%LL(ll+ll_s-1)%Nbound
		if(msh%basis_group(bplus_i%LL(ll+ll_s-1)%matrices_block(bb)%row_group)%head>=idx_s .and. msh%basis_group(bplus_i%LL(ll+ll_s-1)%matrices_block(bb)%row_group)%tail<=idx_e)then
			bb_o = bb_o + 1
			call BF_copy('N',bplus_i%LL(ll+ll_s-1)%matrices_block(bb),agent_bplus%LL(ll)%matrices_block(bb_o))
		end if
	end do
end do



end subroutine Bplus_extract_partial



subroutine Bplus_ComputeMemory(bplus_i,memory)
use BPACK_DEFS
use misc
implicit none
type(matrixblock),pointer::block_i,block_o
type(blockplus)::bplus_i,bplus_o

integer i, j, ii, jj, iii, jjj,index_ij,mm,nn,rank,index_i,index_j,levelm,index_i_m,index_j_m,ll,bb
integer level, blocks, edge, patch, node, group,level_c
integer::block_num,block_num_new,num_blocks,level_butterfly,Nboundall
real(kind=8)::memory
real(kind=8)::rtemp

memory=0

do ll=1,LplusMax
	if(bplus_i%LL(ll)%Nbound>0)then
		do bb=1,bplus_i%LL(ll)%Nbound
			call BF_ComputeMemory(bplus_i%LL(ll)%matrices_block(bb),rtemp)
			memory=memory+rtemp
		end do
	end if
end do

end subroutine Bplus_ComputeMemory




logical function Bplus_checkNAN(bplus_i)
use BPACK_DEFS
use misc
implicit none
type(matrixblock),pointer::block_i,block_o
type(blockplus)::bplus_i,bplus_o

integer i, j, ii, jj, iii, jjj,index_ij,mm,nn,rank,index_i,index_j,levelm,index_i_m,index_j_m,ll,bb
integer level, blocks, edge, patch, node, group,level_c
integer::block_num,block_num_new,num_blocks,level_butterfly,Nboundall
real(kind=8)::rtemp
Bplus_checkNAN = .false.

do ll=1,LplusMax
	if(bplus_i%LL(ll)%Nbound>0)then
		do bb=1,bplus_i%LL(ll)%Nbound
			if(BF_checkNAN(bplus_i%LL(ll)%matrices_block(bb)))then
				Bplus_checkNAN = .true.
				return
			end if
		end do
	end if
end do

end function Bplus_checkNAN

subroutine Bplus_block_MVP_dat(bplus,chara,M,N,Nrnd,random1,random2,a,b,ptree,stats,level_start,level_end)

    use BPACK_DEFS
	use misc
    implicit none

    integer M,N, Nrnd,index_i, index_j, na, nb, index_start, num_vectors
    integer i, j, ii, jj, ij, level, level_butterfly, index_iijj, index_ij, k, k1, k2, kk, intemp1, intemp2
    integer vector_inuse, mm, nn, num_blocks, level_define, col_vector
    integer rank1, rank2, rank, num_groupm, num_groupn, butterflyB_inuse, header_nn, header_mm, ma, mb
    integer vector_a, vector_b, nn1, nn2, mm1, mm2,levelm
    DT ctemp, a, b,ctemp1,ctemp2
    character chara
	type(matrixblock),pointer::blocks,blocks_1
    integer:: middleflag
	type(blockplus)::bplus
	integer ll,bb
	integer,optional:: level_start,level_end
	integer:: level_s,level_e
	type(proctree)::ptree
	type(Hstat)::stats

    type(butterfly_Kerl),allocatable :: ButterflyVector(:)
    !  DT :: random1(N,Nrnd), random2(M,Nrnd)
        DT :: random1(:,:), random2(:,:)
        DT,allocatable :: Vout(:,:),Vin_loc(:,:),Vout_loc(:,:)
	DT,allocatable::matrixtemp(:,:),matrixtemp1(:,:)

	integer,allocatable:: arr_acc_m(:),arr_acc_n(:)

	integer idx_start_m,idx_start_n, idx_start_n_loc,idx_start_m_loc, idx_end_n_loc,idx_end_m_loc,idx_start_i_loc,idx_start_o_loc,idx_end_i_loc,idx_end_o_loc

	level_s=1
	level_e=bplus%Lplus
	if(present(level_start))level_s=level_start
	if(present(level_end))level_e=level_end


	if (chara=='N')allocate(Vout(M,Nrnd))
	if (chara=='T')allocate(Vout(N,Nrnd))
	Vout = 0
	idx_start_n = bplus%LL(1)%matrices_block(1)%headn
	idx_start_m = bplus%LL(1)%matrices_block(1)%headm


	ctemp1=1.0d0 ; ctemp2=1.0d0

	blocks_1 => bplus%LL(1)%matrices_block(1)

	do ll=level_s,level_e
		do bb = 1,bplus%LL(ll)%Nbound
			blocks => bplus%LL(ll)%matrices_block(bb)

			if (chara=='N')then

				if(blocks%M_loc>0)allocate(Vout_loc(blocks%M_loc,Nrnd))
				if(blocks%N_loc>0)allocate(Vin_loc(blocks%N_loc,Nrnd))
				call Redistribute1Dto1D(random1,blocks_1%N_p,blocks_1%headn,blocks_1%pgno,Vin_loc,blocks%N_p,blocks%headn,blocks%pgno,Nrnd,ptree)
				call Redistribute1Dto1D(Vout,blocks_1%M_p,blocks_1%headm,blocks_1%pgno,Vout_loc,blocks%M_p,blocks%headm,blocks%pgno,Nrnd,ptree)
			else

				if(blocks%N_loc>0)allocate(Vout_loc(blocks%N_loc,Nrnd))
				if(blocks%M_loc>0)allocate(Vin_loc(blocks%M_loc,Nrnd))
				call Redistribute1Dto1D(random1,blocks_1%M_p,blocks_1%headm,blocks_1%pgno,Vin_loc,blocks%M_p,blocks%headm,blocks%pgno,Nrnd,ptree)
				call Redistribute1Dto1D(Vout,blocks_1%N_p,blocks_1%headn,blocks_1%pgno,Vout_loc,blocks%N_p,blocks%headn,blocks%pgno,Nrnd,ptree)

			endif

			if(blocks%N_loc>0 .or. blocks%M_loc>0)then
				if(blocks%style==1)then
					write(*,*)'style 1 not implemented'
					stop
				else
					! write(*,*)'ddd1',ll,bb
					call BF_block_MVP_dat(blocks,chara,blocks%M_loc,blocks%N_loc,Nrnd,&
					&Vin_loc,Vout_loc,ctemp1,ctemp2,ptree,stats)
					! write(*,*)'ddd2'
				end if
			endif

			if (chara=='N')then
				call Redistribute1Dto1D(Vout_loc,blocks%M_p,blocks%headm,blocks%pgno,Vout,blocks_1%M_p,blocks_1%headm,blocks_1%pgno,Nrnd,ptree)
				if(blocks%M_loc>0)deallocate(Vout_loc)
				if(blocks%N_loc>0)deallocate(Vin_loc)
			else
				call Redistribute1Dto1D(Vout_loc,blocks%N_p,blocks%headn,blocks%pgno,Vout,blocks_1%N_p,blocks_1%headn,blocks_1%pgno,Nrnd,ptree)
				if(blocks%N_loc>0)deallocate(Vout_loc)
				if(blocks%M_loc>0)deallocate(Vin_loc)
			endif

		end do
	end do

	random2 = random2*b + Vout*a
	deallocate(Vout)

end subroutine Bplus_block_MVP_dat



! redistribute Bplus
subroutine Bplus_DoubleDistribute(bplus_o,stats,ptree)
implicit none

integer nproc_i, nproc_o,idxs_i,idxs_o,idxe_i,idxe_o,ii,jj,iii,jjj
type(proctree)::ptree
type(commquant1D),allocatable::sendquant(:),recvquant(:)
integer,allocatable::S_req(:),R_req(:)
integer,allocatable:: statuss(:,:),statusr(:,:)
integer tag,Nreqs,Nreqr,recvid,sendid,ierr,head_i,head_o,rank,rankmax
type(blockplus)::bplus_o
type(matrixblock),pointer::blocks
DT,pointer::dat_new(:,:),dat_old(:,:)
real(kind=8)::n1,n2
type(Hstat)::stats

dat_new=>null()
dat_old=>null()

if(bplus_o%Lplus==1)then
	blocks => bplus_o%LL(1)%matrices_block(1)
	! call MPI_barrier(ptree%pgrp(blocks%pgno_db)%Comm,ierr)
	n1 = OMP_get_wtime()

	if(blocks%level_butterfly==0)then

		if(blocks%pgno/=blocks%pgno_db)then
			! communicate block sizes first
			if(blocks%M_loc>0)then
				rank = blocks%rankmax
			else
				rank = 0
			endif
			call assert(MPI_COMM_NULL/=ptree%pgrp(blocks%pgno_db)%Comm,'communicator should not be null 4')
			rankmax=0
			call MPI_ALLREDUCE(rank,rankmax,1,MPI_INTEGER,MPI_MAX,ptree%pgrp(blocks%pgno_db)%Comm,ierr)
			rank=rankmax

			! redistribute U
			if(blocks%M_loc>0)then
				allocate(dat_old(blocks%M_loc,rank))
				dat_old=blocks%ButterflyU%blocks(1)%matrix
			endif
			if(blocks%M_loc_db>0)then
				allocate(dat_new(blocks%M_loc_db,rank))
				dat_new=0
			endif
			call Redistribute1Dto1D(dat_old,blocks%M_p,0,blocks%pgno,dat_new,blocks%M_p_db,0,blocks%pgno_db,rank,ptree)
			if(blocks%M_loc>0)then
				deallocate(blocks%ButterflyU%blocks(1)%matrix)
				deallocate(dat_old)
				deallocate(blocks%M_p)
			endif
			if(blocks%M_loc_db>0)then
				if(.not.allocated(blocks%ButterflyU%blocks))allocate(blocks%ButterflyU%blocks(1))
				if(.not.allocated(blocks%ButterflyU%blocks(1)%matrix))allocate(blocks%ButterflyU%blocks(1)%matrix(blocks%M_loc_db,rank))
				blocks%ButterflyU%blocks(1)%matrix = dat_new
				blocks%ButterflyU%blocks(1)%mdim = blocks%M
				blocks%ButterflyU%blocks(1)%ndim = rank
				deallocate(dat_new)
				blocks%M_loc =blocks%M_loc_db
				blocks%M_p=>blocks%M_p_db
				blocks%M_p_db=>NULL()
			endif



			! redistribute V
			if(blocks%N_loc>0)then
				allocate(dat_old(blocks%N_loc,rank))
				dat_old=blocks%ButterflyV%blocks(1)%matrix
			endif
			if(blocks%N_loc_db>0)then
				allocate(dat_new(blocks%N_loc_db,rank))
				dat_new=0
			endif
			call Redistribute1Dto1D(dat_old,blocks%N_p,0,blocks%pgno,dat_new,blocks%N_p_db,0,blocks%pgno_db,rank,ptree)
			if(blocks%N_loc>0)then
				deallocate(blocks%ButterflyV%blocks(1)%matrix)
				deallocate(dat_old)
				deallocate(blocks%N_p)
			endif


			if(blocks%N_loc_db>0)then
				if(.not.allocated(blocks%ButterflyV%blocks))allocate(blocks%ButterflyV%blocks(1))
				if(.not.allocated(blocks%ButterflyV%blocks(1)%matrix))allocate(blocks%ButterflyV%blocks(1)%matrix(blocks%N_loc_db,rank))
				blocks%ButterflyV%blocks(1)%matrix = dat_new
				blocks%ButterflyV%blocks(1)%mdim = blocks%N
				blocks%ButterflyV%blocks(1)%ndim = rank
				deallocate(dat_new)
				blocks%N_loc =blocks%N_loc_db
				blocks%N_p=>blocks%N_p_db
				blocks%N_p_db=>NULL()
				blocks%rankmax = rank
				blocks%pgno=blocks%pgno_db
			endif
		endif
	else
		write(*,*)'redistribution of butterfly not implemented'
				! write(*,*)blocks%N_p,blocks%N_loc,blocks%N_p_db,blocks%rankmax,blocks%pgno
				! call assert(blocks%N_p(1,2)-blocks%N_p(1,1)+1==blocks%N_loc,'not good')
				! call assert(blocks%M_p(1,2)-blocks%M_p(1,1)+1==blocks%M_loc,'not good')
		! stop
	endif

	n2 = OMP_get_wtime()
	stats%Time_RedistB=stats%Time_RedistB + n2-n1

else
	write(*,*)'redistribution of bplus not implemented'
	! stop
endif


end subroutine Bplus_DoubleDistribute



subroutine BF_delete(blocks,allflag)

    use BPACK_DEFS
    implicit none

    integer butterflyB_inuse, level_actual, num_col, num_row
    integer i, j, mm, nn, rank, num_blocks, level, level_butterfly,index_i_m,index_j_m,levelm
    real(kind=8) memory_butterfly, rtemp
    type(matrixblock)::blocks
	integer allflag

        level_butterfly=blocks%level_butterfly

        ! level_actual=Maxlevel_for_blocks-blocks%level
        level_actual=level_butterfly

		if(allocated(blocks%ButterflyU%blocks))then
        ! !$omp parallel do default(shared) private(i)
        do i=1, 2**level_actual

            if(allocated(blocks%ButterflyU%blocks(i)%matrix))deallocate (blocks%ButterflyU%blocks(i)%matrix)
        enddo
        ! !$omp end parallel do
        deallocate (blocks%ButterflyU%blocks)
        end if

		if(allocated(blocks%ButterflyV%blocks))then
        ! !$omp parallel do default(shared) private(i)
        do i=1, 2**level_actual
            if(allocated(blocks%ButterflyV%blocks(i)%matrix))deallocate (blocks%ButterflyV%blocks(i)%matrix)
        enddo
        ! !$omp end parallel do
        deallocate (blocks%ButterflyV%blocks)
        end if


		if(allocated(blocks%ButterflyKerl))then
        if (level_butterfly/=0) then
            ! !$omp parallel do default(shared) private(level,i,j,num_col,num_row)
            do level=1, level_butterfly
                num_col=blocks%ButterflyKerl(level)%num_col
                num_row=blocks%ButterflyKerl(level)%num_row
                do j=1, num_col
                    do i=1, num_row
                        if(allocated(blocks%ButterflyKerl(level)%blocks(i,j)%matrix))deallocate (blocks%ButterflyKerl(level)%blocks(i,j)%matrix)
                    enddo
                enddo
                deallocate (blocks%ButterflyKerl(level)%blocks)
            enddo
            ! !$omp end parallel do
            deallocate (blocks%ButterflyKerl)
        endif
		end if

		if(allocated(blocks%ButterflyMiddle))then
			levelm = ceiling_safe(dble(level_butterfly)/2d0)
			do index_i_m=1, 2**levelm
				do index_j_m=1, 2**(level_butterfly-levelm)
					if(allocated(blocks%ButterflyMiddle(index_i_m,index_j_m)%matrix))deallocate(blocks%ButterflyMiddle(index_i_m,index_j_m)%matrix)
				end do
			end do
			deallocate(blocks%ButterflyMiddle)
		end if

		if(allocated(blocks%KerInv))deallocate(blocks%KerInv)

        ! blocks%level_butterfly=0
		blocks%rankmax = -1000
		blocks%rankmin = 1000

		if(allocated(blocks%fullmat))deallocate (blocks%fullmat)
		if(allocated(blocks%fullmat_MPI))deallocate (blocks%fullmat_MPI)
		if(allocated(blocks%ipiv))deallocate (blocks%ipiv)
        if (allocated(blocks%Butterfly_data_MPI))deallocate (blocks%Butterfly_data_MPI)
        if (allocated(blocks%Butterfly_index_MPI))deallocate (blocks%Butterfly_index_MPI)

		if(allflag==1)then
			if(associated(blocks%N_p))deallocate(blocks%N_p)
			if(associated(blocks%M_p))deallocate(blocks%M_p)
			if(associated(blocks%M_p_db))deallocate(blocks%M_p_db)
			if(associated(blocks%N_p_db))deallocate(blocks%N_p_db)
		endif
    return

end subroutine BF_delete


subroutine BF_copy(trans,block_i,block_o,memory)
use BPACK_DEFS
use misc
implicit none
type(matrixblock)::block_i,block_o

integer i, j, ii, jj, iii, jjj,index_ij,mm,nn,rank,index_i,index_j,levelm,index_i_m,index_j_m
integer level, blocks, edge, patch, node, group,level_c
integer::block_num,block_num_new,num_blocks,level_butterfly
character::trans
real(kind=8),optional::memory

if(present(memory))memory=0

if(trans=='N')then

	block_o%level = block_i%level
	block_o%col_group = block_i%col_group
	block_o%row_group = block_i%row_group
	block_o%style = block_i%style
	block_o%level_butterfly = block_i%level_butterfly
	block_o%rankmax = block_i%rankmax
	block_o%rankmin = block_i%rankmin
	block_o%dimension_rank = block_i%dimension_rank
	block_o%M = block_i%M
	block_o%N = block_i%N
	block_o%headm = block_i%headm
	block_o%headn = block_i%headn

	block_o%M_loc = block_i%M_loc
	block_o%M_loc_db = block_i%M_loc_db
	block_o%N_loc = block_i%N_loc
	block_o%N_loc_db = block_i%N_loc_db
	block_o%pgno = block_i%pgno
	block_o%pgno_db = block_i%pgno_db



	if(associated(block_i%N_p))then
		if(associated(block_o%N_p))deallocate(block_o%N_p)
		allocate(block_o%N_p(size(block_i%N_p,1),2))
		if(present(memory))memory = memory + SIZEOF(block_o%N_p)/1024.0d3
		block_o%N_p = block_i%N_p
	endif
	if(associated(block_i%M_p))then
		if(associated(block_o%M_p))deallocate(block_o%M_p)
		allocate(block_o%M_p(size(block_i%M_p,1),2))
		if(present(memory))memory = memory + SIZEOF(block_o%M_p)/1024.0d3
		block_o%M_p = block_i%M_p
	endif
	if(associated(block_i%N_p_db))then
		if(associated(block_o%N_p_db))deallocate(block_o%N_p_db)
		allocate(block_o%N_p_db(size(block_i%N_p_db,1),2))
		if(present(memory))memory = memory + SIZEOF(block_o%N_p_db)/1024.0d3
		block_o%N_p_db = block_i%N_p_db
	endif
	if(associated(block_i%M_p_db))then
		if(associated(block_o%M_p_db))deallocate(block_o%M_p_db)
		allocate(block_o%M_p_db(size(block_i%M_p_db,1),2))
		if(present(memory))memory = memory + SIZEOF(block_o%M_p_db)/1024.0d3
		block_o%M_p_db = block_i%M_p_db
	endif



	level_butterfly = block_i%level_butterfly
	num_blocks=2**level_butterfly

	if(block_i%style==2)then
		if(allocated(block_i%ButterflyU%blocks))then
			allocate(block_o%ButterflyU%blocks(num_blocks))
			allocate(block_o%ButterflyV%blocks(num_blocks))
			if (level_butterfly/=0) then
				allocate(block_o%ButterflyKerl(level_butterfly))
			end if

			do level=0, level_butterfly
				index_ij=0
				if (level>0) then
					block_o%ButterflyKerl(level)%num_row=2**level
					block_o%ButterflyKerl(level)%num_col=2**(level_butterfly-level+1)
					allocate(block_o%ButterflyKerl(level)%blocks(2**level,2**(level_butterfly-level+1)))
				endif
				do index_i=1, 2**level
					do index_j=1, 2**(level_butterfly-level)
						index_ij=index_ij+1
						if (level==0) then
							nn=size(block_i%ButterflyV%blocks(index_ij)%matrix,1)
							rank=size(block_i%ButterflyV%blocks(index_ij)%matrix,2)
							allocate(block_o%ButterflyV%blocks(index_ij)%matrix(nn,rank))
							block_o%ButterflyV%blocks(index_ij)%matrix = block_i%ButterflyV%blocks(index_ij)%matrix
							block_o%ButterflyV%blocks(index_ij)%mdim = block_i%ButterflyV%blocks(index_ij)%mdim
							block_o%ButterflyV%blocks(index_ij)%ndim = block_i%ButterflyV%blocks(index_ij)%ndim
							if(present(memory))memory = memory + SIZEOF(block_o%ButterflyV%blocks(index_ij)%matrix)/1024.0d3
						else
							nn=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,2)
							rank=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,1)
							allocate(block_o%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix(rank,nn))
							block_o%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix
							block_o%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%mdim = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%mdim
							block_o%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%ndim = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%ndim
							if(present(memory))memory = memory + SIZEOF(block_o%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix)/1024.0d3
							nn=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix,2)
							allocate(block_o%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix(rank,nn))
							block_o%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix
							block_o%ButterflyKerl(level)%blocks(index_i,2*index_j)%mdim = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%mdim
							block_o%ButterflyKerl(level)%blocks(index_i,2*index_j)%ndim = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%ndim
							if(present(memory))memory = memory + SIZEOF(block_o%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix)/1024.0d3
						endif
						if (level==level_butterfly) then
							mm=size(block_i%ButterflyU%blocks(index_ij)%matrix,1)
							rank=size(block_i%ButterflyU%blocks(index_ij)%matrix,2)
							allocate(block_o%ButterflyU%blocks(index_ij)%matrix(mm,rank))
							block_o%ButterflyU%blocks(index_ij)%matrix = block_i%ButterflyU%blocks(index_ij)%matrix
							block_o%ButterflyU%blocks(index_ij)%mdim = block_i%ButterflyU%blocks(index_ij)%mdim
							block_o%ButterflyU%blocks(index_ij)%ndim = block_i%ButterflyU%blocks(index_ij)%ndim
							if(present(memory))memory = memory + SIZEOF(block_o%ButterflyU%blocks(index_ij)%matrix)/1024.0d3
						endif
					enddo
				enddo
			enddo
		endif

		if(allocated(block_i%ButterflyMiddle))then
			levelm = ceiling_safe(dble(level_butterfly)/2d0)
			allocate(block_o%ButterflyMiddle(2**levelm,2**(level_butterfly-levelm)))

			do index_i_m=1, 2**levelm
				do index_j_m=1, 2**(level_butterfly-levelm)
					rank = size(block_i%ButterflyMiddle(index_i_m,index_j_m)%matrix,1)
					allocate(block_o%ButterflyMiddle(index_i_m,index_j_m)%matrix(rank,rank))
					block_o%ButterflyMiddle(index_i_m,index_j_m)%matrix = block_i%ButterflyMiddle(index_i_m,index_j_m)%matrix
					block_o%ButterflyMiddle(index_i_m,index_j_m)%mdim = block_i%ButterflyMiddle(index_i_m,index_j_m)%mdim
					block_o%ButterflyMiddle(index_i_m,index_j_m)%ndim = block_i%ButterflyMiddle(index_i_m,index_j_m)%ndim
				end do
			end do
		end if
	else if(block_i%style==1)then
		if(allocated(block_i%fullmat))then
			mm = size(block_i%fullmat,1)
			nn = size(block_i%fullmat,2)
			allocate (block_o%fullmat(mm,nn))
			block_o%fullmat = block_i%fullmat
			if(present(memory))memory = memory + SIZEOF(block_o%fullmat)/1024.0d3
		endif
	else
		! write(*,*)'block style not implemented'
		! stop
	end if
else if(trans=='T')then

	block_o%level = block_i%level
	block_o%col_group = block_i%row_group
	block_o%row_group = block_i%col_group
	block_o%style = block_i%style
	block_o%level_butterfly = block_i%level_butterfly
	block_o%rankmax = block_i%rankmax
	block_o%rankmin = block_i%rankmin
	block_o%dimension_rank = block_i%dimension_rank
	block_o%M = block_i%N
	block_o%N = block_i%M
	block_o%headm = block_i%headn
	block_o%headn = block_i%headm

	block_o%M_loc = block_i%N_loc
	block_o%M_loc_db = block_i%N_loc_db
	block_o%N_loc = block_i%M_loc
	block_o%N_loc_db = block_i%M_loc_db
	block_o%pgno = block_i%pgno
	block_o%pgno_db = block_i%pgno_db



	if(associated(block_i%N_p))then
		if(associated(block_o%M_p))deallocate(block_o%M_p)
		allocate(block_o%M_p(size(block_i%N_p,1),2))
		if(present(memory))memory = memory + SIZEOF(block_o%M_p)/1024.0d3
		block_o%M_p = block_i%N_p
	endif
	if(associated(block_i%M_p))then
		if(associated(block_o%N_p))deallocate(block_o%N_p)
		allocate(block_o%N_p(size(block_i%M_p,1),2))
		if(present(memory))memory = memory + SIZEOF(block_o%N_p)/1024.0d3
		block_o%N_p = block_i%M_p
	endif
	if(associated(block_i%N_p_db))then
		if(associated(block_o%M_p_db))deallocate(block_o%M_p_db)
		allocate(block_o%M_p_db(size(block_i%N_p_db,1),2))
		if(present(memory))memory = memory + SIZEOF(block_o%N_p_db)/1024.0d3
		block_o%M_p_db = block_i%N_p_db
	endif
	if(associated(block_i%M_p_db))then
		if(associated(block_o%N_p_db))deallocate(block_o%N_p_db)
		allocate(block_o%N_p_db(size(block_i%M_p_db,1),2))
		if(present(memory))memory = memory + SIZEOF(block_o%M_p_db)/1024.0d3
		block_o%N_p_db = block_i%M_p_db
	endif



	level_butterfly = block_i%level_butterfly
	num_blocks=2**level_butterfly

	if(block_i%style==2)then
		if(allocated(block_i%ButterflyU%blocks))then
			allocate(block_o%ButterflyU%blocks(num_blocks))
			allocate(block_o%ButterflyV%blocks(num_blocks))
			if (level_butterfly/=0) then
				allocate(block_o%ButterflyKerl(level_butterfly))
			end if

			do level=0, level_butterfly
				index_ij=0
				if (level>0) then
					block_o%ButterflyKerl(level)%num_col=2**level
					block_o%ButterflyKerl(level)%num_row=2**(level_butterfly-level+1)
					allocate(block_o%ButterflyKerl(level)%blocks(2**(level_butterfly-level+1),2**level))
				endif
				do index_i=1, 2**level
					do index_j=1, 2**(level_butterfly-level)
						index_ij=index_ij+1
						if (level==0) then
							nn=size(block_i%ButterflyV%blocks(index_ij)%matrix,1)
							rank=size(block_i%ButterflyV%blocks(index_ij)%matrix,2)
							allocate(block_o%ButterflyU%blocks(index_ij)%matrix(nn,rank))
							block_o%ButterflyU%blocks(index_ij)%matrix = block_i%ButterflyV%blocks(index_ij)%matrix
							block_o%ButterflyU%blocks(index_ij)%mdim = block_i%ButterflyV%blocks(index_ij)%mdim
							block_o%ButterflyU%blocks(index_ij)%ndim = block_i%ButterflyV%blocks(index_ij)%ndim
							if(present(memory))memory = memory + SIZEOF(block_o%ButterflyU%blocks(index_ij)%matrix)/1024.0d3
						else
							nn=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,2)
							rank=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,1)
							allocate(block_o%ButterflyKerl(level_butterfly-level+1)%blocks(2*index_j-1,index_i)%matrix(nn,rank))
							call copymatT(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,block_o%ButterflyKerl(level_butterfly-level+1)%blocks(2*index_j-1,index_i)%matrix,rank,nn)
							block_o%ButterflyKerl(level_butterfly-level+1)%blocks(2*index_j-1,index_i)%mdim = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%mdim
							block_o%ButterflyKerl(level_butterfly-level+1)%blocks(2*index_j-1,index_i)%ndim = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%ndim
							if(present(memory))memory = memory + SIZEOF(block_o%ButterflyKerl(level_butterfly-level+1)%blocks(2*index_j-1,index_i)%matrix)/1024.0d3
							nn=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix,2)
							allocate(block_o%ButterflyKerl(level_butterfly-level+1)%blocks(2*index_j,index_i)%matrix(nn,rank))
							call copymatT(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix,block_o%ButterflyKerl(level_butterfly-level+1)%blocks(2*index_j,index_i)%matrix,rank,nn)
							block_o%ButterflyKerl(level_butterfly-level+1)%blocks(2*index_j,index_i)%mdim = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%mdim
							block_o%ButterflyKerl(level_butterfly-level+1)%blocks(2*index_j,index_i)%ndim = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%ndim
							if(present(memory))memory = memory + SIZEOF(block_o%ButterflyKerl(level_butterfly-level+1)%blocks(2*index_j,index_i)%matrix)/1024.0d3
						endif
						if (level==level_butterfly) then
							mm=size(block_i%ButterflyU%blocks(index_ij)%matrix,1)
							rank=size(block_i%ButterflyU%blocks(index_ij)%matrix,2)
							allocate(block_o%ButterflyV%blocks(index_ij)%matrix(mm,rank))
							block_o%ButterflyV%blocks(index_ij)%matrix = block_i%ButterflyU%blocks(index_ij)%matrix
							block_o%ButterflyV%blocks(index_ij)%mdim = block_i%ButterflyU%blocks(index_ij)%mdim
							block_o%ButterflyV%blocks(index_ij)%ndim = block_i%ButterflyU%blocks(index_ij)%ndim
							if(present(memory))memory = memory + SIZEOF(block_o%ButterflyV%blocks(index_ij)%matrix)/1024.0d3
						endif
					enddo
				enddo
			enddo
		endif

		if(allocated(block_i%ButterflyMiddle))then
			levelm = ceiling_safe(dble(level_butterfly)/2d0)
			allocate(block_o%ButterflyMiddle(2**(level_butterfly-levelm),2**levelm))

			do index_i_m=1, 2**levelm
				do index_j_m=1, 2**(level_butterfly-levelm)
					rank = size(block_i%ButterflyMiddle(index_i_m,index_j_m)%matrix,1)
					allocate(block_o%ButterflyMiddle(index_j_m,index_i_m)%matrix(rank,rank))
					call copymatT(block_i%ButterflyMiddle(index_i_m,index_j_m)%matrix,block_o%ButterflyMiddle(index_j_m,index_i_m)%matrix,rank,rank)
					block_o%ButterflyMiddle(index_j_m,index_i_m)%mdim = block_i%ButterflyMiddle(index_i_m,index_j_m)%ndim
					block_o%ButterflyMiddle(index_j_m,index_i_m)%ndim = block_i%ButterflyMiddle(index_i_m,index_j_m)%mdim
				end do
			end do
		end if
	else if(block_i%style==1)then
		if(allocated(block_i%fullmat))then
			mm = size(block_i%fullmat,1)
			nn = size(block_i%fullmat,2)
			allocate (block_o%fullmat(nn,mm))
			call copymatT(block_i%fullmat,block_o%fullmat,mm,nn)
			if(present(memory))memory = memory + SIZEOF(block_o%fullmat)/1024.0d3
		endif
	else
		! write(*,*)'block style not implemented'
		! stop
	end if
endif


end subroutine BF_copy

subroutine BF_copy_delete(block_i,block_o,memory)
use BPACK_DEFS
use misc
implicit none
type(matrixblock)::block_i,block_o

integer i, j, ii, jj, iii, jjj,index_ij,mm,nn,rank,index_i,index_j,levelm,index_i_m,index_j_m
integer level, blocks, edge, patch, node, group,level_c
integer::block_num,block_num_new,num_blocks,level_butterfly
real(kind=8),optional::memory
if(present(memory))memory=0
block_o%level = block_i%level
block_o%col_group = block_i%col_group
block_o%row_group = block_i%row_group
block_o%style = block_i%style
block_o%level_butterfly = block_i%level_butterfly
block_o%rankmax = block_i%rankmax
block_o%rankmin = block_i%rankmin
block_o%M = block_i%M
block_o%N = block_i%N
block_o%headm = block_i%headm
block_o%headn = block_i%headn

block_o%M_loc = block_i%M_loc
block_o%M_loc_db = block_i%M_loc_db
block_o%N_loc = block_i%N_loc
block_o%N_loc_db = block_i%N_loc_db
block_o%pgno = block_i%pgno
block_o%pgno_db = block_i%pgno_db

if(associated(block_i%N_p))then
	allocate(block_o%N_p(size(block_i%N_p,1),2))
	block_o%N_p = block_i%N_p
endif
if(associated(block_i%M_p))then
	allocate(block_o%M_p(size(block_i%M_p,1),2))
	block_o%M_p = block_i%M_p
endif
if(associated(block_i%N_p_db))then
	allocate(block_o%N_p_db(size(block_i%N_p_db,1),2))
	block_o%N_p_db = block_i%N_p_db
endif
if(associated(block_i%M_p_db))then
	allocate(block_o%M_p_db(size(block_i%M_p_db,1),2))
	block_o%M_p_db = block_i%M_p_db
endif


level_butterfly = block_i%level_butterfly
num_blocks=2**level_butterfly

if(block_i%style==2)then

	allocate(block_o%ButterflyU%blocks(num_blocks))
	allocate(block_o%ButterflyV%blocks(num_blocks))
	if (level_butterfly/=0) then
		allocate(block_o%ButterflyKerl(level_butterfly))
	end if

	do level=0, level_butterfly
		index_ij=0
		if (level>0) then
			block_o%ButterflyKerl(level)%num_row=2**level
			block_o%ButterflyKerl(level)%num_col=2**(level_butterfly-level+1)
			allocate(block_o%ButterflyKerl(level)%blocks(2**level,2**(level_butterfly-level+1)))
		endif
		do index_i=1, 2**level
			do index_j=1, 2**(level_butterfly-level)
				index_ij=index_ij+1
				if (level==0) then
					nn=size(block_i%ButterflyV%blocks(index_ij)%matrix,1)
					rank=size(block_i%ButterflyV%blocks(index_ij)%matrix,2)
					allocate(block_o%ButterflyV%blocks(index_ij)%matrix(nn,rank))
					block_o%ButterflyV%blocks(index_ij)%matrix = block_i%ButterflyV%blocks(index_ij)%matrix
					block_o%ButterflyV%blocks(index_ij)%mdim = block_i%ButterflyV%blocks(index_ij)%mdim
					block_o%ButterflyV%blocks(index_ij)%ndim = block_i%ButterflyV%blocks(index_ij)%ndim
					deallocate(block_i%ButterflyV%blocks(index_ij)%matrix)
					if(present(memory))memory = memory + SIZEOF(block_o%ButterflyV%blocks(index_ij)%matrix)/1024.0d3
				else
					nn=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,2)
					rank=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,1)
					allocate(block_o%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix(rank,nn))
					block_o%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix
					block_o%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%mdim = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%mdim
					block_o%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%ndim = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%ndim
					deallocate(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix)
					if(present(memory))memory = memory + SIZEOF(block_o%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix)/1024.0d3
					nn=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix,2)
					allocate(block_o%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix(rank,nn))
					block_o%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix
					block_o%ButterflyKerl(level)%blocks(index_i,2*index_j)%mdim = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%mdim
					block_o%ButterflyKerl(level)%blocks(index_i,2*index_j)%ndim = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%ndim
					deallocate(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix)
					if(present(memory))memory = memory + SIZEOF(block_o%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix)/1024.0d3
				endif
				if (level==level_butterfly) then
					mm=size(block_i%ButterflyU%blocks(index_ij)%matrix,1)
					rank=size(block_i%ButterflyU%blocks(index_ij)%matrix,2)
					allocate(block_o%ButterflyU%blocks(index_ij)%matrix(mm,rank))
					block_o%ButterflyU%blocks(index_ij)%matrix = block_i%ButterflyU%blocks(index_ij)%matrix
					block_o%ButterflyU%blocks(index_ij)%mdim = block_i%ButterflyU%blocks(index_ij)%mdim
					block_o%ButterflyU%blocks(index_ij)%ndim = block_i%ButterflyU%blocks(index_ij)%ndim
					deallocate(block_i%ButterflyU%blocks(index_ij)%matrix)
					if(present(memory))memory = memory + SIZEOF(block_o%ButterflyU%blocks(index_ij)%matrix)/1024.0d3
				endif
			enddo
		enddo
		if (level>0) then
			deallocate(block_i%ButterflyKerl(level)%blocks)
		end if
	enddo
	deallocate(block_i%ButterflyU%blocks)
	deallocate(block_i%ButterflyV%blocks)
	if(level_butterfly/=0)deallocate(block_i%ButterflyKerl)

	if(allocated(block_i%ButterflyMiddle))then
		levelm = ceiling_safe(dble(level_butterfly)/2d0)
		allocate(block_o%ButterflyMiddle(2**levelm,2**(level_butterfly-levelm)))

		do index_i_m=1, 2**levelm
			do index_j_m=1, 2**(level_butterfly-levelm)
				rank = size(block_i%ButterflyMiddle(index_i_m,index_j_m)%matrix,1)
				allocate(block_o%ButterflyMiddle(index_i_m,index_j_m)%matrix(rank,rank))
				block_o%ButterflyMiddle(index_i_m,index_j_m)%matrix = block_i%ButterflyMiddle(index_i_m,index_j_m)%matrix
				block_o%ButterflyMiddle(index_i_m,index_j_m)%mdim = block_i%ButterflyMiddle(index_i_m,index_j_m)%mdim
				block_o%ButterflyMiddle(index_i_m,index_j_m)%ndim = block_i%ButterflyMiddle(index_i_m,index_j_m)%ndim
				deallocate(block_i%ButterflyMiddle(index_i_m,index_j_m)%matrix)
			end do
		end do
		deallocate(block_i%ButterflyMiddle)
	end if
else if(block_i%style==1)then
	mm = size(block_i%fullmat,1)
	nn = size(block_i%fullmat,2)
	allocate (block_o%fullmat(mm,nn))
	block_o%fullmat = block_i%fullmat
	deallocate(block_i%fullmat)
else
	write(*,*)'block style not implemented'
	stop
end if

end subroutine BF_copy_delete

subroutine BF_ComputeMemory(block_i,memory)
use BPACK_DEFS
use misc
implicit none
type(matrixblock)::block_i

integer i, j, ii, jj, iii, jjj,index_ij,mm,nn,rank,index_i,index_j,levelm,index_i_m,index_j_m
integer level, blocks, edge, patch, node, group,level_c
integer::block_num,block_num_new,num_blocks,level_butterfly
real(kind=8)::memory
memory=0

level_butterfly = block_i%level_butterfly
num_blocks=2**level_butterfly

if(block_i%style==2)then

	do level=0, level_butterfly
		index_ij=0
		do index_i=1, 2**level
			do index_j=1, 2**(level_butterfly-level)
				index_ij=index_ij+1
				if (level==0) then
					memory = memory + SIZEOF(block_i%ButterflyV%blocks(index_ij)%matrix)/1024.0d3
				else
					memory = memory + SIZEOF(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix)/1024.0d3
					memory = memory + SIZEOF(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix)/1024.0d3
				endif
				if (level==level_butterfly) then
					memory = memory + SIZEOF(block_i%ButterflyU%blocks(index_ij)%matrix)/1024.0d3
				endif
			enddo
		enddo
	enddo

else if(block_i%style==1)then
	memory = memory + SIZEOF(block_i%fullmat)/1024.0d3
else
	write(*,*)'block style not implemented'
	stop
end if

end subroutine BF_ComputeMemory



logical function BF_checkNAN(block_i)
use BPACK_DEFS
use misc
implicit none
type(matrixblock)::block_i

integer i, j, ii, jj, iii, jjj,index_ij,mm,nn,rank,index_i,index_j,levelm,index_i_m,index_j_m
integer level, blocks, edge, patch, node, group,level_c
integer::block_num,block_num_new,num_blocks,level_butterfly
real(kind=8):: temp

level_butterfly = block_i%level_butterfly
num_blocks=2**level_butterfly
temp = 0

if(block_i%style==2)then

	do level=0, level_butterfly
		index_ij=0
		do index_i=1, 2**level
			do index_j=1, 2**(level_butterfly-level)
				index_ij=index_ij+1
				if (level==0) then
					mm=size(block_i%ButterflyV%blocks(index_ij)%matrix,1)
					nn=size(block_i%ButterflyV%blocks(index_ij)%matrix,2)
					temp = temp + fnorm(block_i%ButterflyV%blocks(index_ij)%matrix,mm,nn)
				else
					mm=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,1)
					nn=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,2)
					temp = temp + fnorm(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,mm,nn)

					mm=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix,1)
					nn=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix,2)
					temp = temp + fnorm(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix,mm,nn)
				endif
				if (level==level_butterfly) then
					mm=size(block_i%ButterflyU%blocks(index_ij)%matrix,1)
					nn=size(block_i%ButterflyU%blocks(index_ij)%matrix,2)
					temp = temp + fnorm(block_i%ButterflyU%blocks(index_ij)%matrix,mm,nn)
				endif
			enddo
		enddo
	enddo

else if(block_i%style==1)then
	mm=size(block_i%fullmat,1)
	nn=size(block_i%fullmat,2)
	temp = temp + fnorm(block_i%fullmat,mm,nn)
else
	write(*,*)'block style not implemented'
	stop
end if

BF_checkNAN = isnan(temp)

end function BF_checkNAN



subroutine BF_print_size_rank(block_i,tolerance)
use BPACK_DEFS
use misc
implicit none
type(matrixblock)::block_i

integer i, j, ii, jj, iii, jjj,index_ij,mm,nn,rank,truerank,index_i,index_j,levelm,index_i_m,index_j_m,mm1,mm2,nn1,nn2
integer level, blocks, edge, patch, node, group,level_c
integer::block_num,block_num_new,num_blocks,level_butterfly
DT,allocatable::matrixtemp(:,:),mat11(:,:),mat12(:,:),mat21(:,:),mat22(:,:)
real(kind=8)::tolerance

level_butterfly = block_i%level_butterfly
num_blocks=2**level_butterfly

do level=0, level_butterfly+1
	! write(*,*)level
	if (level==0) then
		do index_ij=1, 2**level_butterfly
			nn=size(block_i%ButterflyV%blocks(index_ij)%matrix,1)
			rank=size(block_i%ButterflyV%blocks(index_ij)%matrix,2)
			allocate(matrixtemp(nn,rank))
			matrixtemp = block_i%ButterflyV%blocks(index_ij)%matrix
			call GetRank(nn,rank,matrixtemp,truerank,tolerance)
			write(*,*)level,index_ij,nn,rank,truerank
			deallocate(matrixtemp)
		end do
	else if (level==level_butterfly+1) then
		do index_ij=1, 2**level_butterfly
			mm=size(block_i%ButterflyU%blocks(index_ij)%matrix,1)
			rank=size(block_i%ButterflyU%blocks(index_ij)%matrix,2)
			allocate(matrixtemp(mm,rank))
			matrixtemp = block_i%ButterflyU%blocks(index_ij)%matrix
			call GetRank(mm,rank,matrixtemp,truerank,tolerance)
			write(*,*)level,index_ij,mm,rank,truerank
			deallocate(matrixtemp)
		end do
	else
		do index_i=1, 2**(level-1)
			do index_j=1, 2**(level_butterfly-level)

				mm1=size(block_i%ButterflyKerl(level)%blocks(2*index_i-1,2*index_j-1)%matrix,1)
				nn1=size(block_i%ButterflyKerl(level)%blocks(2*index_i-1,2*index_j-1)%matrix,2)

				mm2=size(block_i%ButterflyKerl(level)%blocks(2*index_i,2*index_j)%matrix,1)
				nn2=size(block_i%ButterflyKerl(level)%blocks(2*index_i,2*index_j)%matrix,2)

				allocate(mat11(mm1,nn1))
				mat11 = block_i%ButterflyKerl(level)%blocks(2*index_i-1,2*index_j-1)%matrix
				allocate(mat12(mm1,nn2))
				mat12 = block_i%ButterflyKerl(level)%blocks(2*index_i-1,2*index_j)%matrix
				allocate(mat21(mm2,nn1))
				mat21 = block_i%ButterflyKerl(level)%blocks(2*index_i,2*index_j-1)%matrix
				allocate(mat22(mm2,nn2))
				mat22 = block_i%ButterflyKerl(level)%blocks(2*index_i,2*index_j)%matrix
				allocate(matrixtemp(mm1+mm2,nn1+nn2))
				matrixtemp(1:mm1,1:nn1) = mat11
				matrixtemp(1:mm1,1+nn1:nn2+nn1) = mat12
				matrixtemp(1+mm1:mm2+mm1,1:nn1) = mat21
				matrixtemp(1+mm1:mm2+mm1,1+nn1:nn2+nn1) = mat22
				call GetRank(mm1+mm2,nn1+nn2,matrixtemp,truerank,tolerance)
				write(*,*)level,index_i,index_j,(mm1+mm2),(nn1+nn2),truerank
				deallocate(mat11)
				deallocate(mat12)
				deallocate(mat21)
				deallocate(mat22)
				deallocate(matrixtemp)

			enddo
		enddo

	end if

enddo

end subroutine BF_print_size_rank



subroutine BF_extract_partial(block_o,level_butterfly_loc,ij_loc,LR,agent_block)
	use misc
    use BPACK_DEFS
    implicit none

	type(matrixblock)::block_o,agent_block
	integer level_butterfly,level_butterfly_loc, ij_loc,index_i,index_i_start,index_j_start,index_j,level,ii,nn,mm,num_blocks,rank
	character LR

	! allocate(agent_block)


	call assert(level_butterfly_loc>=1,'level_butterfly_loc cannot be zero')

	agent_block%row_group=-1
	agent_block%col_group=-1

	agent_block%style = block_o%style
	agent_block%level_butterfly = level_butterfly_loc
	agent_block%rankmax = block_o%rankmax
	agent_block%rankmin = block_o%rankmin
	level_butterfly = block_o%level_butterfly



	num_blocks=2**level_butterfly_loc




	allocate(agent_block%ButterflyU%blocks(num_blocks))
	allocate(agent_block%ButterflyV%blocks(num_blocks))

	allocate(agent_block%ButterflyKerl(level_butterfly_loc))


	if(LR=='L')then
		do level=1, level_butterfly_loc
			agent_block%ButterflyKerl(level)%num_row=2**level
			agent_block%ButterflyKerl(level)%num_col=2**(level_butterfly_loc-level+1)
			allocate(agent_block%ButterflyKerl(level)%blocks(2**level,2**(level_butterfly_loc-level+1)))
			do index_i=1, 2**level
				do index_j=1, 2**(level_butterfly_loc-level)

					index_i_start = (ij_loc-1)*2**level
					nn=size(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix,2)
					rank=size(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix,1)
					allocate(agent_block%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix(rank,nn))
					agent_block%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix = block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix

					nn=size(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j)%matrix,2)
					allocate(agent_block%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix(rank,nn))
					agent_block%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix = block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j)%matrix

					if (level==level_butterfly_loc) then
						index_i_start = (ij_loc-1)*2**level

						mm=size(block_o%ButterflyU%blocks(index_i+index_i_start)%matrix,1)
						rank=size(block_o%ButterflyU%blocks(index_i+index_i_start)%matrix,2)
						allocate(agent_block%ButterflyU%blocks(index_i)%matrix(mm,rank))
						agent_block%ButterflyU%blocks(index_i)%matrix = block_o%ButterflyU%blocks(index_i+index_i_start)%matrix
					endif
				enddo
			enddo

			if(level==1)then
				do index_i=1, 1
					do index_j=1, 2**(level_butterfly_loc-level)
						index_i_start = (ij_loc-1)*2**level
						nn=size(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix,2)
						allocate(agent_block%ButterflyV%blocks(2*index_j-1)%matrix(nn,nn))
						agent_block%ButterflyV%blocks(2*index_j-1)%matrix = 0
						do ii=1,nn
							agent_block%ButterflyV%blocks(2*index_j-1)%matrix(ii,ii)=1
						end do
						nn=size(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j)%matrix,2)
						allocate(agent_block%ButterflyV%blocks(2*index_j)%matrix(nn,nn))
						agent_block%ButterflyV%blocks(2*index_j)%matrix = 0
						do ii=1,nn
							agent_block%ButterflyV%blocks(2*index_j)%matrix(ii,ii)=1
						end do
					end do
				end do
			end if

		enddo
	else if(LR=='R')then
		do level=1, level_butterfly_loc
			agent_block%ButterflyKerl(level)%num_row=2**level
			agent_block%ButterflyKerl(level)%num_col=2**(level_butterfly_loc-level+1)
			allocate(agent_block%ButterflyKerl(level)%blocks(2**level,2**(level_butterfly_loc-level+1)))
			do index_i=1, 2**(level-1)
				do index_j=1, 2**(level_butterfly_loc-level+1)

					index_j_start = (ij_loc-1)*2**(level_butterfly_loc-level+1)

					mm=size(block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix,1)
					rank=size(block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix,2)
					allocate(agent_block%ButterflyKerl(level)%blocks(2*index_i-1,index_j)%matrix(mm,rank))
					agent_block%ButterflyKerl(level)%blocks(2*index_i-1,index_j)%matrix = block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix

					mm=size(block_o%ButterflyKerl(level)%blocks(2*index_i,index_j+index_j_start)%matrix,1)
					allocate(agent_block%ButterflyKerl(level)%blocks(2*index_i,index_j)%matrix(mm,rank))
					agent_block%ButterflyKerl(level)%blocks(2*index_i,index_j)%matrix = block_o%ButterflyKerl(level)%blocks(2*index_i,index_j+index_j_start)%matrix

					if (level==1) then
						index_j_start = (ij_loc-1)*2**(level_butterfly_loc-level+1)

						nn=size(block_o%ButterflyV%blocks(index_j+index_j_start)%matrix,1)
						rank=size(block_o%ButterflyV%blocks(index_j+index_j_start)%matrix,2)
						allocate(agent_block%ButterflyV%blocks(index_j)%matrix(nn,rank))
						agent_block%ButterflyV%blocks(index_j)%matrix = block_o%ButterflyV%blocks(index_j+index_j_start)%matrix
					endif
				enddo
			enddo

			if(level==level_butterfly_loc)then
				do index_i=1, 2**(level_butterfly_loc-1)
					do index_j=1, 1
						index_j_start = (ij_loc-1)*2**(level_butterfly_loc-level+1)
						mm=size(block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix,1)
						allocate(agent_block%ButterflyU%blocks(2*index_i-1)%matrix(mm,mm))
						agent_block%ButterflyU%blocks(2*index_i-1)%matrix = 0
						do ii=1,mm
							agent_block%ButterflyU%blocks(2*index_i-1)%matrix(ii,ii)=1
						end do
						mm=size(block_o%ButterflyKerl(level)%blocks(2*index_i,index_j+index_j_start)%matrix,1)
						allocate(agent_block%ButterflyU%blocks(2*index_i)%matrix(mm,mm))
						agent_block%ButterflyU%blocks(2*index_i)%matrix = 0
						do ii=1,mm
							agent_block%ButterflyU%blocks(2*index_i)%matrix(ii,ii)=1
						end do
					end do
				end do
			end if

		enddo

	end if
end subroutine BF_extract_partial


subroutine BF_copy_partial(block_i,block_o,level_butterfly_loc,ij_loc,LR,memory)
use BPACK_DEFS
use misc
implicit none
type(matrixblock)::block_o,block_i

integer i, j, ii, jj, iii, jjj,index_ij,mm,nn,rank,index_i,index_j,levelm,index_i_m,index_j_m,dimension_m,dimension_n,index_i_start,index_j_start
integer level, blocks, edge, patch, node, group,level_c
integer::block_num,block_num_new,num_blocks,level_butterfly,level_butterfly_loc,ij_loc
character LR
real(kind=8),optional::memory
if(present(memory))memory=0

!!!!! be careful here, may need changes later
block_o%rankmax = max(block_o%rankmax,block_i%rankmax)
block_o%rankmin = max(block_o%rankmin,block_i%rankmin)


call assert(level_butterfly_loc>=1,'level_butterfly_loc cannot be zero')
call assert(level_butterfly_loc==block_i%level_butterfly,'level_butterfly_loc/=block_i%level_butterfly')

level_butterfly = block_o%level_butterfly
num_blocks=2**level_butterfly_loc


if(LR=='L')then

	do level=1, level_butterfly_loc
		do index_i=1, 2**level
			do index_j=1, 2**(level_butterfly_loc-level)
				index_i_start = (ij_loc-1)*2**level

				if(level==1)then
					dimension_n = size(block_i%ButterflyV%blocks(2*index_j-1)%matrix,1)
					nn=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,2)
					rank=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,1)
					deallocate(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix)
					allocate(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix(rank,dimension_n))
					! call gemmNT_omp(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix, block_i%ButterflyV%blocks(2*index_j-1)%matrix, &
					! &block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix,rank,dimension_n,nn)
					call gemmf90(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,rank, block_i%ButterflyV%blocks(2*index_j-1)%matrix,dimension_n, block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix,rank, 'N','T',rank,dimension_n,nn,cone,czero)



					if(isnan(fnorm(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix,rank,dimension_n)))then
						write(*,*)'NAN in L 1'
					end if


					dimension_n = size(block_i%ButterflyV%blocks(2*index_j)%matrix,1)
					nn=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix,2)
					rank=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix,1)
					deallocate(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j)%matrix)
					allocate(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j)%matrix(rank,dimension_n))
					! call gemmNT_omp(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix, block_i%ButterflyV%blocks(2*index_j)%matrix, &
					! &block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j)%matrix,rank,dimension_n,nn)
					call gemmf90(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix,rank, block_i%ButterflyV%blocks(2*index_j)%matrix,dimension_n, block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j)%matrix,rank, 'N','T',rank,dimension_n,nn,cone,czero)

					if(isnan(fnorm(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j)%matrix,rank,dimension_n)))then
						write(*,*)'NAN in L 2'
					end if


				else
					nn=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,2)
					rank=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,1)
					deallocate(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix)
					allocate(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix(rank,nn))
					block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix

					if(isnan(fnorm(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix,rank,nn)))then
						write(*,*)'NAN in L 3'
					end if

					nn=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix,2)
					deallocate(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j)%matrix)
					allocate(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j)%matrix(rank,nn))
					block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j)%matrix = block_i%ButterflyKerl(level)%blocks(index_i,2*index_j)%matrix

					if(isnan(fnorm(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j)%matrix,rank,nn)))then
						write(*,*)'NAN in L 4'
					end if

				end if

				if(present(memory))memory = memory + SIZEOF(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j-1)%matrix)/1024.0d3
				if(present(memory))memory = memory + SIZEOF(block_o%ButterflyKerl(level_butterfly-level_butterfly_loc+level)%blocks(index_i+index_i_start,2*index_j)%matrix)/1024.0d3

				if (level==level_butterfly_loc) then
					index_i_start = (ij_loc-1)*2**level
					mm=size(block_i%ButterflyU%blocks(index_i)%matrix,1)
					rank=size(block_i%ButterflyU%blocks(index_i)%matrix,2)
					deallocate(block_o%ButterflyU%blocks(index_i+index_i_start)%matrix)
					allocate(block_o%ButterflyU%blocks(index_i+index_i_start)%matrix(mm,rank))
					block_o%ButterflyU%blocks(index_i+index_i_start)%matrix = block_i%ButterflyU%blocks(index_i)%matrix
					if(present(memory))memory = memory + SIZEOF(block_o%ButterflyU%blocks(index_i+index_i_start)%matrix)/1024.0d3
					if(isnan(fnorm(block_o%ButterflyU%blocks(index_i+index_i_start)%matrix,mm,rank)))then
						write(*,*)'NAN in L 5'
					end if
				endif
			enddo
		enddo
	enddo

else if(LR=='R')then


	do level=1, level_butterfly_loc
		do index_i=1, 2**(level-1)
			do index_j=1, 2**(level_butterfly_loc-level+1)
			! write(*,*)level,index_i,index_j
				index_j_start = (ij_loc-1)*2**(level_butterfly_loc-level+1)
				if(level==level_butterfly_loc)then
				! write(*,*)'good 1'
					dimension_m = size(block_i%ButterflyU%blocks(2*index_i-1)%matrix,1)
					mm=size(block_i%ButterflyKerl(level)%blocks(2*index_i-1,index_j)%matrix,1)
					rank=size(block_i%ButterflyKerl(level)%blocks(2*index_i-1,index_j)%matrix,2)
					! write(*,*)dimension_m,mm,rank,'d'
					deallocate(block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix)
					allocate(block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix(dimension_m,rank))
					! call gemm_omp(block_i%ButterflyU%blocks(2*index_i-1)%matrix, block_i%ButterflyKerl(level)%blocks(2*index_i-1,index_j)%matrix,&
					! &block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix,dimension_m,rank,mm)

					call gemmf90(block_i%ButterflyU%blocks(2*index_i-1)%matrix,dimension_m,block_i%ButterflyKerl(level)%blocks(2*index_i-1,index_j)%matrix,mm,block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix,dimension_m,'N','N',dimension_m,rank,mm,cone,czero)

! write(*,*)'good 1.1'

					if(isnan(fnorm(block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix,dimension_m,rank)))then
						write(*,*)'NAN in R 1'
					end if

					dimension_m = size(block_i%ButterflyU%blocks(2*index_i)%matrix,1)
					mm=size(block_i%ButterflyKerl(level)%blocks(2*index_i,index_j)%matrix,1)
					rank=size(block_i%ButterflyKerl(level)%blocks(2*index_i,index_j)%matrix,2)
					deallocate(block_o%ButterflyKerl(level)%blocks(2*index_i,index_j+index_j_start)%matrix)
					allocate(block_o%ButterflyKerl(level)%blocks(2*index_i,index_j+index_j_start)%matrix(dimension_m,rank))
					! call gemm_omp(block_i%ButterflyU%blocks(2*index_i)%matrix, block_i%ButterflyKerl(level)%blocks(2*index_i,index_j)%matrix,&
					! &block_o%ButterflyKerl(level)%blocks(2*index_i,index_j+index_j_start)%matrix,dimension_m,rank,mm)

					call gemmf90(block_i%ButterflyU%blocks(2*index_i)%matrix,dimension_m,block_i%ButterflyKerl(level)%blocks(2*index_i,index_j)%matrix,mm,block_o%ButterflyKerl(level)%blocks(2*index_i,index_j+index_j_start)%matrix,dimension_m,'N','N',dimension_m,rank,mm,cone,czero)

! write(*,*)'good 2'
					if(isnan(fnorm(block_o%ButterflyKerl(level)%blocks(2*index_i,index_j+index_j_start)%matrix,dimension_m,rank)))then
						write(*,*)'NAN in R 2'
					end if
				else
				! write(*,*)'good 3'
					mm=size(block_i%ButterflyKerl(level)%blocks(2*index_i-1,index_j)%matrix,1)
					rank=size(block_i%ButterflyKerl(level)%blocks(2*index_i-1,index_j)%matrix,2)
					deallocate(block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix)
					allocate(block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix(mm,rank))
					block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix = block_i%ButterflyKerl(level)%blocks(2*index_i-1,index_j)%matrix

					if(isnan(fnorm(block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix,mm,rank)))then
						write(*,*)'NAN in R 3'
					end if


					mm=size(block_i%ButterflyKerl(level)%blocks(2*index_i,index_j)%matrix,1)
					rank=size(block_i%ButterflyKerl(level)%blocks(2*index_i,index_j)%matrix,2)
					deallocate(block_o%ButterflyKerl(level)%blocks(2*index_i,index_j+index_j_start)%matrix)
					allocate(block_o%ButterflyKerl(level)%blocks(2*index_i,index_j+index_j_start)%matrix(mm,rank))
					block_o%ButterflyKerl(level)%blocks(2*index_i,index_j+index_j_start)%matrix = block_i%ButterflyKerl(level)%blocks(2*index_i,index_j)%matrix
				! write(*,*)'good 4'
					if(isnan(fnorm(block_o%ButterflyKerl(level)%blocks(2*index_i,index_j+index_j_start)%matrix,mm,rank)))then
						write(*,*)'NAN in R 4'
					end if
				end if

				if(present(memory))memory = memory + SIZEOF(block_o%ButterflyKerl(level)%blocks(2*index_i-1,index_j+index_j_start)%matrix)/1024.0d3
				if(present(memory))memory = memory + SIZEOF(block_o%ButterflyKerl(level)%blocks(2*index_i,index_j+index_j_start)%matrix)/1024.0d3

				if (level==1) then
					index_j_start = (ij_loc-1)*2**(level_butterfly_loc-level+1)
					nn=size(block_i%ButterflyV%blocks(index_j)%matrix,1)
					rank=size(block_i%ButterflyV%blocks(index_j)%matrix,2)
					deallocate(block_o%ButterflyV%blocks(index_j+index_j_start)%matrix)
					allocate(block_o%ButterflyV%blocks(index_j+index_j_start)%matrix(nn,rank))
					block_o%ButterflyV%blocks(index_j+index_j_start)%matrix = block_i%ButterflyV%blocks(index_j)%matrix
					if(present(memory))memory = memory + SIZEOF(block_o%ButterflyV%blocks(index_j+index_j_start)%matrix)/1024.0d3

					if(isnan(fnorm(block_o%ButterflyV%blocks(index_j+index_j_start)%matrix,nn,rank)))then
						write(*,*)'NAN in R 5'
					end if
				endif
			end do
		end do
	end do

end if

end subroutine BF_copy_partial




subroutine BF_Partial_MVP_Half(block_rand,chara,level_start,level_end,random,num_vect_sub,nth_s,nth_e,Ng)

    use BPACK_DEFS
    implicit none

    integer n, group_m, group_n, group_mm, group_nn, index_i, index_j, na, nb, index_start
    integer i, j, ii, jj, ij, level, groupm_start, groupn_start, index_iijj, index_ij, k, kk, intemp1, intemp2
    integer header_m, header_n, tailer_m, tailer_n, mm, nn, num_blocks, level_define, col_vector
    integer rank1, rank2, rank, num_groupm, num_groupn, header_nn, header_mm, ma, mb
    integer vector_a, vector_b, nn1, nn2, level_blocks, mm1, mm2, level_end, level_start
    DT ctemp, a, b
    character chara
	integer num_vect_sub,num_vect_subsub,nth_s,nth_e,Ng,nth,dimension_rank,level_butterfly

    type(RandomBlock) :: random

    type(butterfly_Kerl),allocatable :: ButterflyVector(:)
    type(matrixblock)::block_rand
   ! write(*,*)'in '

	level_butterfly=block_rand%level_butterfly
	dimension_rank = block_rand%dimension_rank
    num_vect_subsub = num_vect_sub/(nth_e-nth_s+1)

    if (chara=='N') then

        num_blocks=2**level_butterfly

        do level=level_start, level_end
            if (level==0) then
                num_groupn=num_blocks
                do nth=nth_s, nth_e
					! !$omp parallel do default(shared) private(j,rank,nn,ii,jj,ctemp,kk)
					do j = (nth-1)*Ng+1,nth*Ng
						rank=size(block_rand%ButterflyV%blocks(j)%matrix,2)
						nn=size(block_rand%ButterflyV%blocks(j)%matrix,1)
						if(.not. allocated(random%RandomVectorRR(1)%blocks(1,j)%matrix))allocate(random%RandomVectorRR(1)%blocks(1,j)%matrix(rank,num_vect_subsub))
						random%RandomVectorRR(1)%blocks(1,j)%matrix(:,(nth-nth_s)*num_vect_subsub+1:(nth-nth_s+1)*num_vect_subsub) = 0
						!$omp parallel do default(shared) private(ii,jj,kk,ctemp)
						do jj=1, num_vect_subsub
							do ii=1, rank
								ctemp=0d0
								do kk=1, nn
									ctemp=ctemp+block_rand%ButterflyV%blocks(j)%matrix(kk,ii)*random%RandomVectorRR(0)%blocks(1,j)%matrix(kk,jj+(nth-nth_s)*num_vect_subsub)
								enddo
								random%RandomVectorRR(1)%blocks(1,j)%matrix(ii,jj+(nth-nth_s)*num_vect_subsub)=ctemp
							enddo
						enddo
						!$omp end parallel do
					enddo
					! !$omp end parallel do
                enddo
            elseif (level==level_butterfly+1) then

            else
                num_groupm=block_rand%ButterflyKerl(level)%num_row
                num_groupn=block_rand%ButterflyKerl(level)%num_col

				! !$omp parallel do default(shared) private(ij,ii,jj,kk,ctemp,i,j,index_i,index_j,nn1,nn2,mm,nth)
				do ij=1,(num_groupm/2)*(num_groupn/2)
					index_i = (ij-1)/(num_groupn/2)+1
					index_j = mod(ij-1,(num_groupn/2)) + 1
					i = index_i*2-1
					j = index_j*2-1




					do nth = nth_s,nth_e

						if((j>=(nth-1)*Ng/2**(level-1)+1 .and. j<=nth*Ng/2**(level-1)) .or. &
						& (j+1>=(nth-1)*Ng/2**(level-1)+1 .and. j+1<=nth*Ng/2**(level-1)))then
							nn1=size(block_rand%ButterflyKerl(level)%blocks(i,j)%matrix,2)
							nn2=size(block_rand%ButterflyKerl(level)%blocks(i,j+1)%matrix,2)
							mm=size(block_rand%ButterflyKerl(level)%blocks(i,j)%matrix,1)
							! write(*,*)ij,i,j,level,'ha',index_i
							if(.not. allocated(random%RandomVectorRR(level+1)%blocks(i,index_j)%matrix))allocate(random%RandomVectorRR(level+1)%blocks(i,index_j)%matrix(mm,num_vect_subsub))
							random%RandomVectorRR(level+1)%blocks(i,index_j)%matrix(:,(nth-nth_s)*num_vect_subsub+1:(nth-nth_s+1)*num_vect_subsub) = 0
							!$omp parallel do default(shared) private(ii,jj,kk,ctemp)
							do jj=1, num_vect_subsub
								do ii=1, mm
									ctemp=0d0
									do kk=1, nn1
										ctemp=ctemp+block_rand%ButterflyKerl(level)%blocks(i,j)%matrix(ii,kk)*random%RandomVectorRR(level)%blocks(index_i,j)%matrix(kk,jj+(nth-nth_s)*num_vect_subsub)
									enddo
									do kk=1, nn2
										ctemp=ctemp+block_rand%ButterflyKerl(level)%blocks(i,j+1)%matrix(ii,kk)*random%RandomVectorRR(level)%blocks(index_i,j+1)%matrix(kk,jj+(nth-nth_s)*num_vect_subsub)
									enddo
									random%RandomVectorRR(level+1)%blocks(i,index_j)%matrix(ii,jj+(nth-nth_s)*num_vect_subsub)=ctemp
								enddo
							enddo
							!$omp end parallel do

							nn1=size(block_rand%ButterflyKerl(level)%blocks(i+1,j)%matrix,2)
							nn2=size(block_rand%ButterflyKerl(level)%blocks(i+1,j+1)%matrix,2)
							mm=size(block_rand%ButterflyKerl(level)%blocks(i+1,j)%matrix,1)
							! write(*,*)ij,i,j,level,'ha',index_i
							if(.not. allocated(random%RandomVectorRR(level+1)%blocks(i+1,index_j)%matrix))allocate(random%RandomVectorRR(level+1)%blocks(i+1,index_j)%matrix(mm,num_vect_subsub))
							random%RandomVectorRR(level+1)%blocks(i+1,index_j)%matrix(:,(nth-nth_s)*num_vect_subsub+1:(nth-nth_s+1)*num_vect_subsub) = 0
							!$omp parallel do default(shared) private(ii,jj,kk,ctemp)
							do jj=1, num_vect_subsub
								do ii=1, mm
									ctemp=0d0
									do kk=1, nn1
										ctemp=ctemp+block_rand%ButterflyKerl(level)%blocks(i+1,j)%matrix(ii,kk)*random%RandomVectorRR(level)%blocks(index_i,j)%matrix(kk,jj+(nth-nth_s)*num_vect_subsub)
									enddo
									do kk=1, nn2
										ctemp=ctemp+block_rand%ButterflyKerl(level)%blocks(i+1,j+1)%matrix(ii,kk)*random%RandomVectorRR(level)%blocks(index_i,j+1)%matrix(kk,jj+(nth-nth_s)*num_vect_subsub)
									enddo
									random%RandomVectorRR(level+1)%blocks(i+1,index_j)%matrix(ii,jj+(nth-nth_s)*num_vect_subsub)=ctemp
								enddo
							enddo
							!$omp end parallel do

							! write(*,*)ij,i,j,level,'ha done0',index_i
							deallocate(random%RandomVectorRR(level)%blocks(index_i,j)%matrix)
							deallocate(random%RandomVectorRR(level)%blocks(index_i,j+1)%matrix)
							! write(*,*)ij,i,j,level,'ha done',index_i
						end if
					end do
				enddo
				! !$omp end parallel do
            endif
        enddo


    elseif (chara=='T') then

        num_blocks=2**level_butterfly

        do level=level_start, level_end
            if (level==0) then
                num_groupm=num_blocks
                do nth=nth_s, nth_e
					! !$omp parallel do default(shared) private(i,rank,mm,ii,jj,ctemp,kk)
					do i = (nth-1)*Ng+1,nth*Ng
						rank=size(block_rand%ButterflyU%blocks(i)%matrix,2)
						mm=size(block_rand%ButterflyU%blocks(i)%matrix,1)
						if(.not. allocated(random%RandomVectorLL(1)%blocks(i,1)%matrix))allocate(random%RandomVectorLL(1)%blocks(i,1)%matrix(rank,num_vect_subsub))
						random%RandomVectorLL(1)%blocks(i,1)%matrix(:,(nth-nth_s)*num_vect_subsub+1:(nth-nth_s+1)*num_vect_subsub) = 0
						!$omp parallel do default(shared) private(ii,jj,kk,ctemp)
						do jj=1, num_vect_subsub
							do ii=1, rank
								ctemp=0d0
								do kk=1, mm
									ctemp=ctemp+block_rand%ButterflyU%blocks(i)%matrix(kk,ii)*random%RandomVectorLL(0)%blocks(i,1)%matrix(kk,jj+(nth-nth_s)*num_vect_subsub)
								enddo
								random%RandomVectorLL(1)%blocks(i,1)%matrix(ii,jj+(nth-nth_s)*num_vect_subsub)=ctemp
							enddo
						enddo
						!$omp end parallel do
					end do
					! !$omp end parallel do
                enddo
            elseif (level==level_butterfly+1) then
            else
                num_groupm=block_rand%ButterflyKerl(level_butterfly-level+1)%num_row
                num_groupn=block_rand%ButterflyKerl(level_butterfly-level+1)%num_col

				! !$omp parallel do default(shared) private(ij,ii,jj,kk,ctemp,i,j,index_i,index_j,mm1,mm2,nn,nth)
				do ij=1,(num_groupn/2)*(num_groupm/2)
					index_j = (ij-1)/(num_groupm/2)+1
					index_i = mod(ij-1,(num_groupm/2)) + 1
					j = 2*index_j-1
					i = 2*index_i-1




					do nth = nth_s,nth_e

						if((i>=(nth-1)*Ng/2**(level-1)+1 .and. i<=nth*Ng/2**(level-1)) .or. &
						& (i+1>=(nth-1)*Ng/2**(level-1)+1 .and. i+1<=nth*Ng/2**(level-1)))then
							mm1=size(block_rand%ButterflyKerl(level_butterfly-level+1)%blocks(i,j)%matrix,1)
							mm2=size(block_rand%ButterflyKerl(level_butterfly-level+1)%blocks(i+1,j)%matrix,1)
							nn=size(block_rand%ButterflyKerl(level_butterfly-level+1)%blocks(i,j)%matrix,2)
							if(.not. allocated(random%RandomVectorLL(level+1)%blocks(index_i,j)%matrix))allocate(random%RandomVectorLL(level+1)%blocks(index_i,j)%matrix(nn,num_vect_subsub))
							random%RandomVectorLL(level+1)%blocks(index_i,j)%matrix(:,(nth-nth_s)*num_vect_subsub+1:(nth-nth_s+1)*num_vect_subsub) = 0
							!$omp parallel do default(shared) private(ii,jj,kk,ctemp)
							do ii=1, num_vect_subsub
								do jj=1, nn
									ctemp=0d0
									do kk=1, mm1
										ctemp=ctemp+random%RandomVectorLL(level)%blocks(i,index_j)%matrix(kk,ii+(nth-nth_s)*num_vect_subsub)*block_rand%ButterflyKerl(level_butterfly-level+1)%blocks(i,j)%matrix(kk,jj)
									enddo
									do kk=1, mm2
										ctemp=ctemp+random%RandomVectorLL(level)%blocks(i+1,index_j)%matrix(kk,ii+(nth-nth_s)*num_vect_subsub)*block_rand%ButterflyKerl(level_butterfly-level+1)%blocks(i+1,j)%matrix(kk,jj)
									enddo
									random%RandomVectorLL(level+1)%blocks(index_i,j)%matrix(jj,ii+(nth-nth_s)*num_vect_subsub)=ctemp
								enddo
							enddo
							!$omp end parallel do
							mm1=size(block_rand%ButterflyKerl(level_butterfly-level+1)%blocks(i,j+1)%matrix,1)
							mm2=size(block_rand%ButterflyKerl(level_butterfly-level+1)%blocks(i+1,j+1)%matrix,1)
							nn=size(block_rand%ButterflyKerl(level_butterfly-level+1)%blocks(i,j+1)%matrix,2)
							if(.not. allocated(random%RandomVectorLL(level+1)%blocks(index_i,j+1)%matrix))allocate(random%RandomVectorLL(level+1)%blocks(index_i,j+1)%matrix(nn,num_vect_subsub))
							random%RandomVectorLL(level+1)%blocks(index_i,j+1)%matrix(:,(nth-nth_s)*num_vect_subsub+1:(nth-nth_s+1)*num_vect_subsub) = 0
							!$omp parallel do default(shared) private(ii,jj,kk,ctemp)
							do ii=1, num_vect_subsub
								do jj=1, nn
									ctemp=0d0
									do kk=1, mm1
										ctemp=ctemp+random%RandomVectorLL(level)%blocks(i,index_j)%matrix(kk,ii+(nth-nth_s)*num_vect_subsub)*block_rand%ButterflyKerl(level_butterfly-level+1)%blocks(i,j+1)%matrix(kk,jj)
									enddo
									do kk=1, mm2
										ctemp=ctemp+random%RandomVectorLL(level)%blocks(i+1,index_j)%matrix(kk,ii+(nth-nth_s)*num_vect_subsub)*block_rand%ButterflyKerl(level_butterfly-level+1)%blocks(i+1,j+1)%matrix(kk,jj)
									enddo
									random%RandomVectorLL(level+1)%blocks(index_i,j+1)%matrix(jj,ii+(nth-nth_s)*num_vect_subsub)=ctemp
								enddo
							enddo
							!$omp end parallel do
							deallocate(random%RandomVectorLL(level)%blocks(i,index_j)%matrix)
							deallocate(random%RandomVectorLL(level)%blocks(i+1,index_j)%matrix)
						end if
					end do
				enddo
				! !$omp end parallel do

            endif
        enddo

    endif
       ! write(*,*)'out '
    return

end subroutine BF_Partial_MVP_Half


subroutine BF_block_MVP_dat(blocks,chara,M,N,Nrnd,random1,random2,a,b,ptree,stats)

    use BPACK_DEFS
	use misc
    implicit none

    integer M,N, Nrnd,index_i, index_j, na, nb, index_start, num_vectors
    integer i, j, ii, jj, ij, level, level_butterfly, index_iijj, index_ij, k, k1, k2, kk, intemp1, intemp2
    integer vector_inuse, mm, nn, num_blocks, level_define, col_vector
    integer rank1, rank2, rank, num_groupm, num_groupn, butterflyB_inuse, header_nn, header_mm, ma, mb
    integer vector_a, vector_b, nn1, nn2, mm1, mm2,levelm
    DT ctemp, a, b
    character chara
	type(matrixblock)::blocks
    integer:: middleflag
	type(proctree)::ptree
	integer pgno,comm,ierr
	type(Hstat)::stats
	real(kind=8)::flop,flops


    type(butterfly_Kerl),allocatable :: ButterflyVector(:)
    !  DT :: random1(N,Nrnd), random2(M,Nrnd)
        DT :: random1(:,:), random2(:,:)
	DT,allocatable::matrixtemp(:,:),matrixtemp1(:,:),Vout_tmp(:,:)

	integer,allocatable:: arr_acc_m(:),arr_acc_n(:)

	level_butterfly=blocks%level_butterfly
	pgno = blocks%pgno
	! write(*,*)blocks%col_group,blocks%row_group,blocks%pgno,level_butterfly,'dd'
	comm = ptree%pgrp(pgno)%comm
	if(comm==MPI_COMM_NULL)then
		write(*,*)'ninin',pgno,comm==MPI_COMM_NULL,ptree%MyID
	endif

	call assert(IOwnPgrp(ptree,pgno),'I do not share this block!')

	if(level_butterfly==0)then
		rank = size(blocks%ButterflyU%blocks(1)%matrix,2)
		call assert(rank>0,'rank incorrect in blocks%ButterflyU')
		allocate(matrixtemp(rank,Nrnd))
		matrixtemp=0
		allocate(matrixtemp1(rank,Nrnd))
		matrixtemp1=0
		allocate(Vout_tmp(size(random2,1),size(random2,2)))
		Vout_tmp = 0
		! for implementation simplicity, MPI_ALLREDUCE is used even when nproc==1
		if (chara=='N') then !Vout=U*V^T*Vin
			call gemmf90(blocks%ButterflyV%blocks(1)%matrix,size(blocks%ButterflyV%blocks(1)%matrix,1),random1,size(random1,1),matrixtemp,rank,'T','N',rank,Nrnd,size(blocks%ButterflyV%blocks(1)%matrix,1),cone,czero,flop)
			stats%Flop_Tmp = stats%Flop_Tmp + flop
			call assert(MPI_COMM_NULL/=comm,'communicator should not be null 2')
			call MPI_ALLREDUCE(matrixtemp,matrixtemp1,rank*Nrnd,MPI_DT,MPI_SUM,comm,ierr)
			call gemmf90(blocks%ButterflyU%blocks(1)%matrix,size(blocks%ButterflyU%blocks(1)%matrix,1),matrixtemp1,rank,Vout_tmp,size(random2,1),'N','N',size(blocks%ButterflyU%blocks(1)%matrix,1),Nrnd,rank,cone,czero,flop)
			stats%Flop_Tmp = stats%Flop_Tmp + flop
			random2 = b*random2+a*Vout_tmp
		else if(chara=='T')then !Vout=V*U^T*Vin
			call gemmf90(blocks%ButterflyU%blocks(1)%matrix,size(blocks%ButterflyU%blocks(1)%matrix,1),random1,size(random1,1),matrixtemp,rank,'T','N',rank,Nrnd,size(blocks%ButterflyU%blocks(1)%matrix,1),cone,czero,flop)
			stats%Flop_Tmp = stats%Flop_Tmp + flop
			call assert(MPI_COMM_NULL/=comm,'communicator should not be null 3')
			call MPI_ALLREDUCE(matrixtemp,matrixtemp1,rank*Nrnd,MPI_DT,MPI_SUM,comm,ierr)
			call gemmf90(blocks%ButterflyV%blocks(1)%matrix,size(blocks%ButterflyV%blocks(1)%matrix,1),matrixtemp1,rank,Vout_tmp,size(random2,1),'N','N',size(blocks%ButterflyV%blocks(1)%matrix,1),Nrnd,rank,cone,czero,flop)
			stats%Flop_Tmp = stats%Flop_Tmp + flop
			random2 = b*random2+a*Vout_tmp
		endif

		deallocate(matrixtemp)
		deallocate(matrixtemp1)
		deallocate(Vout_tmp)

	else
		middleflag = 0
		if(allocated(blocks%ButterflyMiddle))middleflag=1


		num_blocks=2**level_butterfly
		allocate(arr_acc_m(num_blocks))
		allocate(arr_acc_n(num_blocks))

		k1=0
		k2=0
		do i=1, num_blocks
			arr_acc_n(i) = k1
			arr_acc_m(i) = k2
			nn=size(blocks%ButterflyV%blocks(i)%matrix,1)
			k1 =k1 +nn
			mm=size(blocks%ButterflyU%blocks(i)%matrix,1)
			k2 =k2 +mm
		enddo

		! write(*,*)arr_acc_m
		! write(*,*)arr_acc_n

		num_vectors=Nrnd
		! write(*,*)num_vectors
		! stop
		if(BF_checkNAN(blocks))then
			write(*,*)'NAN in 0 BF_block_MVP_dat'
			stop
		end if

		if (chara=='N') then

			if(isnan(sum(abs(random1(:,1))**2)))then
				write(*,*)'NAN in 1 BF_block_MVP_dat'
				stop
			end if

			level_butterfly=blocks%level_butterfly
			num_blocks=2**level_butterfly
			levelm = ceiling_safe(dble(level_butterfly)/2d0)

			allocate (ButterflyVector(0:level_butterfly+2))
			allocate (ButterflyVector(0)%blocks(1,num_blocks))
			ButterflyVector(0)%num_row=1
			ButterflyVector(0)%num_col=num_blocks
					!  write(*,*)'nima0'
			!$omp parallel do default(shared) private(i,nn,ii,jj)
			do i=1, num_blocks
				nn=size(blocks%ButterflyV%blocks(i)%matrix,1)
				allocate (ButterflyVector(0)%blocks(1,i)%matrix(nn,num_vectors))
				do ii=1, nn
					do jj=1, num_vectors
						ButterflyVector(0)%blocks(1,i)%matrix(ii,jj)=random1(ii+arr_acc_n(i),jj)
					enddo
				enddo
			enddo
			!$omp end parallel do

			!  write(*,*)'nima1'
			do level=0, level_butterfly
				!  write(*,*)'nima1',level
				if (level==0) then
					num_groupn=num_blocks
					allocate (ButterflyVector(1)%blocks(1,num_groupn))
					ButterflyVector(1)%num_row=1
					ButterflyVector(1)%num_col=num_groupn

					flops=0
					!$omp parallel do default(shared) private(j,rank,nn,flop) reduction(+:flops)
					do j=1, num_groupn
					! write(*,*)num_groupn
						rank=size(blocks%ButterflyV%blocks(j)%matrix,2)
						nn=size(blocks%ButterflyV%blocks(j)%matrix,1)
						allocate (ButterflyVector(1)%blocks(1,j)%matrix(rank,num_vectors))

						call gemmf90(blocks%ButterflyV%blocks(j)%matrix,nn,ButterflyVector(0)%blocks(1,j)%matrix,nn,ButterflyVector(1)%blocks(1,j)%matrix,rank,'T','N',rank,num_vectors,nn,cone,czero,flop=flop)
						flops=flops+flop
					enddo
					!$omp end parallel do
					stats%Flop_Tmp = stats%Flop_Tmp + flops

				else
					num_groupm=blocks%ButterflyKerl(level)%num_row
					num_groupn=blocks%ButterflyKerl(level)%num_col
					if (num_groupn/=1) then
						allocate (ButterflyVector(level+1)%blocks(num_groupm,int(num_groupn/2)))
						ButterflyVector(level+1)%num_row=num_groupm
						ButterflyVector(level+1)%num_col=int(num_groupn/2)

						flops=0
						!$omp parallel do default(shared) private(ij,ii,jj,kk,i,j,index_i,index_j,nn1,nn2,mm,flop) reduction(+:flops)
						do ij=1,num_groupm*(num_groupn/2)
							i = (ij-1)/(num_groupn/2)+1
							j = (mod(ij-1,(num_groupn/2)) + 1)*2-1
							index_i=int((i+1)/2)
							index_j=int((j+1)/2)

							nn1=size(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,2)
							nn2=size(blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix,2)
							mm=size(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,1)
							allocate (ButterflyVector(level+1)%blocks(i,index_j)%matrix(mm,num_vectors))
							ButterflyVector(level+1)%blocks(i,index_j)%matrix=0
							if(size(ButterflyVector(level)%blocks(index_i,j)%matrix,1)<nn1)then
								write(*,*)blocks%row_group,blocks%col_group,blocks%level_butterfly,level,'nimade'
								stop
							end if

							call gemmf90(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,mm,ButterflyVector(level)%blocks(index_i,j)%matrix,nn1,ButterflyVector(level+1)%blocks(i,index_j)%matrix,mm,'N','N',mm,num_vectors,nn1,cone,cone,flop=flop)
							flops = flops + flop

							call gemmf90(blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix,mm,ButterflyVector(level)%blocks(index_i,j+1)%matrix,nn2,ButterflyVector(level+1)%blocks(i,index_j)%matrix,mm,'N','N',mm,num_vectors,nn2,cone,cone,flop=flop)
							flops = flops + flop

							if(level==levelm .and. middleflag==1 .and. level_butterfly>=2)then
								call gemmf90(blocks%ButterflyMiddle(i,index_j)%matrix,mm, ButterflyVector(level+1)%blocks(i,index_j)%matrix,mm, ButterflyVector(level+1)%blocks(i,index_j)%matrix,mm, 'N','N',mm,num_vectors,mm,cone,czero,flop=flop)
								flops = flops + flop
							end if
						enddo
						!$omp end parallel do
						stats%Flop_Tmp = stats%Flop_Tmp + flops
					else
						allocate (ButterflyVector(level+1)%blocks(num_groupm,1))
						ButterflyVector(level+1)%num_row=num_groupm
						ButterflyVector(level+1)%num_col=1
						do i=1, num_groupm
							index_i=int((i+1)/2)
							nn=size(blocks%ButterflyKerl(level)%blocks(i,1)%matrix,2)
							mm=size(blocks%ButterflyKerl(level)%blocks(i,1)%matrix,1)
							allocate (ButterflyVector(level+1)%blocks(i,1)%matrix(mm,num_vectors))
							ButterflyVector(level+1)%blocks(i,1)%matrix=0

							call gemmf90(blocks%ButterflyKerl(level)%blocks(i,1)%matrix,mm,ButterflyVector(level)%blocks(index_i,1)%matrix,nn,ButterflyVector(level+1)%blocks(i,1)%matrix,mm,'N','N',mm,num_vectors,nn,cone,czero,flop=flop)
							stats%Flop_Tmp = stats%Flop_Tmp + flop


						! ! if(is_nan_mat_c(blocks%ButterflyKerl(level)%blocks(i,1)%matrix,mm,nn))then
							! ! write(*,*)'kernel2'
							! ! stop
						! ! end if



						enddo
					endif
				endif
				if (level==level_butterfly) then
					allocate (ButterflyVector(level+2)%blocks(num_blocks,1))
					ButterflyVector(level+2)%num_row=num_blocks
					ButterflyVector(level+2)%num_col=1
					flops=0
					!$omp parallel do default(shared) private(i,rank,mm,flop) reduction(+:flops)
					do i=1, num_blocks
						rank=size(blocks%ButterflyU%blocks(i)%matrix,2)
						mm=size(blocks%ButterflyU%blocks(i)%matrix,1)
						allocate (ButterflyVector(level+2)%blocks(i,1)%matrix(mm,num_vectors))
						ButterflyVector(level+2)%blocks(i,1)%matrix=0

						call gemmf90(blocks%ButterflyU%blocks(i)%matrix,mm,ButterflyVector(level+1)%blocks(i,1)%matrix,rank,ButterflyVector(level+2)%blocks(i,1)%matrix,mm,'N','N',mm,num_vectors,rank,cone,czero,flop=flop)
						flops = flops + flop
					enddo
					!$omp end parallel do
					stats%Flop_Tmp = stats%Flop_Tmp + flops
				endif

				if (level/=0) then
					do j=1, ButterflyVector(level)%num_col
						do i=1, ButterflyVector(level)%num_row
							deallocate (ButterflyVector(level)%blocks(i,j)%matrix)
						enddo
					enddo
				end if
				if (level==level_butterfly) then
					do j=1, ButterflyVector(level+1)%num_col
						do i=1, ButterflyVector(level+1)%num_row
							deallocate (ButterflyVector(level+1)%blocks(i,j)%matrix)
						enddo
					enddo
				end if

			enddo


			!$omp parallel do default(shared) private(index_i,mm,ii,jj)
			do jj=1, num_vectors
				do index_i=1, num_blocks
					mm=size(blocks%ButterflyU%blocks(index_i)%matrix,1)
					! write(*,*)mm,shape(random2),shape(arr_acc_m),allocated(ButterflyVector(level_butterfly+2)%blocks(index_i,1)%matrix),shape(ButterflyVector(level_butterfly+2)%blocks(index_i,1)%matrix)
					do ii=1, mm

							random2(ii+arr_acc_m(index_i),jj)=b*random2(ii+arr_acc_m(index_i),jj)+a*ButterflyVector(level_butterfly+2)%blocks(index_i,1)%matrix(ii,jj)
							! if(isnan(abs(b*random2(ii+k,jj)+a*ButterflyVector(level_butterfly+2)%blocks(index_i,1)%matrix(ii,jj))))write(*,*)index_i,ii,k,jj,ButterflyVector(level_butterfly+2)%blocks(index_i,1)%matrix(ii,jj),random2(ii+k,jj),a,b

					enddo
				enddo
			enddo
			!$omp end parallel do

			if(isnan(sum(abs(random2(:,1))**2)))then
				write(*,*)'NAN in 2 BF_block_MVP_dat',blocks%row_group,blocks%col_group,blocks%level,blocks%level_butterfly
				stop
			end if
			!deallocate (butterflyvector)

		elseif (chara=='T') then

			level_butterfly=blocks%level_butterfly
			num_blocks=2**level_butterfly
			levelm = ceiling_safe(dble(level_butterfly)/2d0)

			allocate (ButterflyVector(0:level_butterfly+2))
			allocate (ButterflyVector(0)%blocks(num_blocks,1))
			ButterflyVector(0)%num_row=num_blocks
			ButterflyVector(0)%num_col=1

			!$omp parallel do default(shared) private(i,mm,ii,jj)
			do i=1, num_blocks
				mm=size(blocks%ButterflyU%blocks(i)%matrix,1)
				allocate (ButterflyVector(0)%blocks(i,1)%matrix(mm,num_vectors))
				do ii=1, mm
					do jj=1, num_vectors
						ButterflyVector(0)%blocks(i,1)%matrix(ii,jj)=random1(ii+arr_acc_m(i),jj)
					enddo
				enddo
			enddo
			!$omp end parallel do

			do level=0, level_butterfly
				if (level==0) then
					num_groupm=num_blocks
					allocate (ButterflyVector(1)%blocks(num_groupm,1))
					ButterflyVector(1)%num_row=num_groupm
					ButterflyVector(1)%num_col=1
					flops=0
					!$omp parallel do default(shared) private(i,rank,mm,flop) reduction(+:flops)
					do i=1, num_groupm
						rank=size(blocks%ButterflyU%blocks(i)%matrix,2)
						mm=size(blocks%ButterflyU%blocks(i)%matrix,1)
						allocate (ButterflyVector(1)%blocks(i,1)%matrix(rank,num_vectors))
						ButterflyVector(1)%blocks(i,1)%matrix=0


						call gemmf90(blocks%ButterflyU%blocks(i)%matrix,mm,ButterflyVector(0)%blocks(i,1)%matrix,mm,ButterflyVector(1)%blocks(i,1)%matrix,rank,'T','N',rank,num_vectors,mm,cone,czero,flop=flop)
						flops = flops + flop

					enddo
					!$omp end parallel do
					stats%Flop_Tmp = stats%Flop_Tmp + flops
				else
					num_groupm=blocks%ButterflyKerl(level_butterfly-level+1)%num_row
					num_groupn=blocks%ButterflyKerl(level_butterfly-level+1)%num_col
					if (num_groupm/=1) then
						allocate (ButterflyVector(level+1)%blocks(int(num_groupm/2),num_groupn))
						ButterflyVector(level+1)%num_row=int(num_groupm/2)
						ButterflyVector(level+1)%num_col=num_groupn

						flops=0
						!$omp parallel do default(shared) private(ij,ii,jj,kk,ctemp,i,j,index_i,index_j,mm1,mm2,nn,flop) reduction(+:flops)
						do ij=1,num_groupn*(num_groupm/2)
							j = (ij-1)/(num_groupm/2)+1
							i = (mod(ij-1,(num_groupm/2)) + 1)*2-1
							index_j=int((j+1)/2)
							index_i=int((i+1)/2)

							mm1=size(blocks%ButterflyKerl(level_butterfly-level+1)%blocks(i,j)%matrix,1)
							mm2=size(blocks%ButterflyKerl(level_butterfly-level+1)%blocks(i+1,j)%matrix,1)
							nn=size(blocks%ButterflyKerl(level_butterfly-level+1)%blocks(i,j)%matrix,2)
							allocate (ButterflyVector(level+1)%blocks(index_i,j)%matrix(nn,num_vectors))
							ButterflyVector(level+1)%blocks(index_i,j)%matrix=0


							call gemmf90(blocks%ButterflyKerl(level_butterfly-level+1)%blocks(i,j)%matrix,mm1,ButterflyVector(level)%blocks(i,index_j)%matrix,mm1,ButterflyVector(level+1)%blocks(index_i,j)%matrix,nn,'T','N',nn,num_vectors,mm1,cone,cone,flop=flop)
							flops = flops + flop
							call gemmf90(blocks%ButterflyKerl(level_butterfly-level+1)%blocks(i+1,j)%matrix,mm2,ButterflyVector(level)%blocks(i+1,index_j)%matrix,mm2,ButterflyVector(level+1)%blocks(index_i,j)%matrix,nn,'T','N',nn,num_vectors,mm2,cone,cone,flop=flop)
							flops = flops + flop

							if(level_butterfly-level==levelm .and. middleflag==1 .and. level_butterfly>=2)then
								call gemmf90(blocks%ButterflyMiddle(index_i,j)%matrix,nn,ButterflyVector(level+1)%blocks(index_i,j)%matrix,nn,ButterflyVector(level+1)%blocks(index_i,j)%matrix,nn,'T','N',nn,num_vectors,nn,cone,czero,flop=flop)
								flops = flops + flop

							end if
						enddo
						!$omp end parallel do
						stats%Flop_Tmp = stats%Flop_Tmp + flops
					else
						allocate (ButterflyVector(level+1)%blocks(1,num_groupn))
						ButterflyVector(level+1)%num_row=1
						ButterflyVector(level+1)%num_col=num_groupn
						do j=1, num_groupn
							index_j=int((j+1)/2)
							nn=size(blocks%ButterflyKerl(level_butterfly-level+1)%blocks(1,j)%matrix,2)
							mm=size(blocks%ButterflyKerl(level_butterfly-level+1)%blocks(1,j)%matrix,1)
							allocate (ButterflyVector(level+1)%blocks(1,j)%matrix(nn,num_vectors))
							ButterflyVector(level+1)%blocks(1,j)%matrix=0

							call gemmf90(blocks%ButterflyKerl(level_butterfly-level+1)%blocks(1,j)%matrix,mm,ButterflyVector(level)%blocks(1,index_j)%matrix,mm,ButterflyVector(level+1)%blocks(1,j)%matrix,nn,'T','N',nn,num_vectors,mm,cone,czero,flop=flop)
							stats%Flop_Tmp = stats%Flop_Tmp + flop

						enddo
					endif
				endif
				if (level==level_butterfly) then
					allocate (ButterflyVector(level+2)%blocks(1,num_blocks))
					ButterflyVector(level+2)%num_row=1
					ButterflyVector(level+2)%num_col=num_blocks
					flops=0
					!$omp parallel do default(shared) private(j,rank,nn,flop) reduction(+:flops)
					do j=1, num_blocks
						nn=size(blocks%ButterflyV%blocks(j)%matrix,1)
						rank=size(blocks%ButterflyV%blocks(j)%matrix,2)
						allocate (ButterflyVector(level+2)%blocks(1,j)%matrix(nn,num_vectors))
						ButterflyVector(level+2)%blocks(1,j)%matrix=0
						if(size(ButterflyVector(level+1)%blocks(1,j)%matrix,1)/=rank)write(*,*)rank,shape(ButterflyVector(level+1)%blocks(1,j)%matrix),'5gf43'

						call gemmf90(blocks%ButterflyV%blocks(j)%matrix,nn,ButterflyVector(level+1)%blocks(1,j)%matrix,rank,ButterflyVector(level+2)%blocks(1,j)%matrix,nn,'N','N',nn,num_vectors,rank,cone,czero,flop=flop)
						flops = flops + flop
					enddo
					!$omp end parallel do
					stats%Flop_Tmp = stats%Flop_Tmp + flops
				endif
				if (level/=0) then
					do j=1, ButterflyVector(level)%num_col
						do i=1, ButterflyVector(level)%num_row
							deallocate (ButterflyVector(level)%blocks(i,j)%matrix)
						enddo
					enddo
				end if
				if (level==level_butterfly) then
					do j=1, ButterflyVector(level+1)%num_col
						do i=1, ButterflyVector(level+1)%num_row
							deallocate (ButterflyVector(level+1)%blocks(i,j)%matrix)
						enddo
					enddo
				end if

			enddo

			!$omp parallel do default(shared) private(index_j,nn,ii,jj)
			do jj=1, num_vectors
				do index_j=1, num_blocks
					nn=size(blocks%ButterflyV%blocks(index_j)%matrix,1)
					! write(*,*)nn,arr_acc_n(index_j)
					do ii=1, nn

						random2(ii+arr_acc_n(index_j),jj)=b*random2(ii+arr_acc_n(index_j),jj)+a*ButterflyVector(level_butterfly+2)%blocks(1,index_j)%matrix(ii,jj)
					enddo
				enddo
			enddo
			!$omp end parallel do

		endif

		! !$omp parallel do default(shared) private(level,i,j)
		do level=0, level_butterfly+2
			do j=1, ButterflyVector(level)%num_col
				do i=1, ButterflyVector(level)%num_row
					if(allocated(ButterflyVector(level)%blocks(i,j)%matrix))deallocate (ButterflyVector(level)%blocks(i,j)%matrix)
				enddo
			enddo
			deallocate (ButterflyVector(level)%blocks)
		enddo
		! !$omp end parallel do
		deallocate (ButterflyVector)
		deallocate(arr_acc_m,arr_acc_n)

	endif

    return

end subroutine BF_block_MVP_dat





subroutine BF_value(mi,nj,blocks,value)

    use BPACK_DEFS
    implicit none

    integer mm, nn, mi, nj, groupm_start, groupn_start, level_butterfly, flag
    integer i, j, ii, jj, rank, group_m, group_n, header_mm, header_nn, k, kk
    integer group, level, mii, njj, rank1, rank2, index_ij, level_blocks, flag1
    DT ctemp, value

    type(matrixblock) :: blocks
    type(vectorset),allocatable:: vectors_set(:)
    integer,allocatable :: group_index_mm(:), group_index_nn(:)





    level_butterfly=blocks%level_butterfly




    allocate (group_index_mm(0:level_butterfly),group_index_nn(0:level_butterfly))

    flag=0; i=0; k=0
    do while (flag==0)
        i=i+1
        if (size(blocks%ButterflyU%blocks(i)%matrix,1)+k>=mi) then
            flag=1
        endif
        k=k+size(blocks%ButterflyU%blocks(i)%matrix,1)
    enddo
    group_index_mm(0)=i
    mii=mi-k+size(blocks%ButterflyU%blocks(i)%matrix,1)

    flag=0; j=0; k=0
    do while (flag==0)
        j=j+1
        if (size(blocks%ButterflyV%blocks(j)%matrix,1)+k>=nj) then
            flag=1
        endif
        k=k+size(blocks%ButterflyV%blocks(j)%matrix,1)
    enddo
    group_index_nn(0)=j
    njj=nj-k+size(blocks%ButterflyV%blocks(j)%matrix,1)

    if (level_butterfly>0) then
        group_index_mm(1)=group_index_mm(0)
        group_index_nn(1)= group_index_nn(0)
        do level=1, level_butterfly-1
            group_index_mm(level+1)=int((group_index_mm(level)+1)/2)
            group_index_nn(level+1)=int((group_index_nn(level)+1)/2)
        enddo
    endif

!     if (group_index_mm(0)/=group_m .or. group_index_nn(0)/=group_n) then
!         write (*,*) 'BF_value_func error1!'
!         pause
!         continue
!     endif

!     do level=0, level_butterfly
!         group_index_mm(level)=group_index_mm(level)-group_m*2**level+1
!         group_index_nn(level)=group_index_nn(level)-group_n*2**level+1
!     enddo

    allocate (vectors_set(0:level_butterfly))
    do level=0, level_butterfly
        if (level==0) then
            rank=size(blocks%ButterflyV%blocks(group_index_nn(0))%matrix,2)
            allocate (vectors_set(level)%vector(rank))
            !!$omp parallel do default(shared) private(i)
            do i=1, rank
                vectors_set(level)%vector(i)=blocks%ButterflyV%blocks(group_index_nn(0))%matrix(njj,i)
            enddo
            !!$omp end parallel do
        else
            rank1=size(blocks%ButterflyKerl(level)%blocks(group_index_mm(level_butterfly-level+1),group_index_nn(level))%matrix,2)
            rank2=size(blocks%ButterflyKerl(level)%blocks(group_index_mm(level_butterfly-level+1),group_index_nn(level))%matrix,1)
            allocate (vectors_set(level)%vector(rank2))
            !!$omp parallel do default(shared) private(i,j,ctemp)
            do i=1, rank2
                ctemp=0
                do j=1, rank1
                    ctemp=ctemp+blocks%ButterflyKerl(level)%blocks(group_index_mm(level_butterfly-level+1),group_index_nn(level))%matrix(i,j)*vectors_set(level-1)%vector(j)
                enddo
                vectors_set(level)%vector(i)=ctemp
            enddo
            !!$omp end parallel do
            deallocate (vectors_set(level-1)%vector)
        endif
        if (level==level_butterfly) then
            rank=size(vectors_set(level)%vector,1)
            ctemp=0
            !!$omp parallel do default(shared) private(i) reduction(+:ctemp)
            do i=1, rank
                ctemp=ctemp+blocks%ButterflyU%blocks(group_index_mm(0))%matrix(mii,i)*vectors_set(level)%vector(i)
            enddo
            !!$omp end parallel do
            value=ctemp
            deallocate (vectors_set(level)%vector)
        endif
    enddo
    deallocate (vectors_set)

    return

end subroutine BF_value


subroutine BF_get_rank(block_i)
use BPACK_DEFS
use misc
implicit none
type(matrixblock)::block_i

integer i, j, ii, jj, iii, jjj,index_ij,mm,nn,rank,index_i,index_j,levelm,index_i_m,index_j_m
integer level, blocks, edge, patch, node, group,level_c
integer::block_num,block_num_new,num_blocks,level_butterfly


block_i%rankmin = 100000
block_i%rankmax = -100000


level_butterfly = block_i%level_butterfly
num_blocks=2**level_butterfly

do level=0, level_butterfly
	index_ij=0
	do index_i=1, 2**level
		do index_j=1, 2**(level_butterfly-level)
			index_ij=index_ij+1
			if (level==0) then
				nn=size(block_i%ButterflyV%blocks(index_ij)%matrix,1)
				rank=size(block_i%ButterflyV%blocks(index_ij)%matrix,2)
				block_i%rankmin = min(block_i%rankmin,rank)
				block_i%rankmax = max(block_i%rankmax,rank)
			else
				nn=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,2)
				rank=size(block_i%ButterflyKerl(level)%blocks(index_i,2*index_j-1)%matrix,1)
				block_i%rankmin = min(block_i%rankmin,rank)
				block_i%rankmax = max(block_i%rankmax,rank)
			endif
			if (level==level_butterfly) then
				mm=size(block_i%ButterflyU%blocks(index_ij)%matrix,1)
				rank=size(block_i%ButterflyU%blocks(index_ij)%matrix,2)
				block_i%rankmin = min(block_i%rankmin,rank)
				block_i%rankmax = max(block_i%rankmax,rank)
			endif
		enddo
	enddo
enddo

end subroutine BF_get_rank







subroutine BF_sym2asym(blocks)

    use BPACK_DEFS
	use misc


    implicit none

    integer M,N, Nrnd,group_m, group_n, group_mm, group_nn, index_i, index_j, na, nb, index_start, num_vectors
    integer i, j, ii, jj, ij, iijj, level, level_butterfly, groupm_start, groupn_start, index_iijj, index_ij, k, kk, intemp1, intemp2
    integer header_m, header_n, tailer_m, tailer_n, vector_inuse, mm, nn, num_blocks, level_define, col_vector
    integer rank1, rank2, rank, num_groupm, num_groupn, butterflyB_inuse, header_nn, header_mm, ma, mb
    integer vector_a, vector_b, nn1, nn2, mm1, mm2,levelm
    DT ctemp, a, b
    character chara
	type(matrixblock)::blocks
    integer:: middleflag,dimension_n,num_row,num_col,mn_min

	DT,allocatable::matrixtemp(:,:),matrixtemp1(:,:)

    real(kind=8), allocatable :: Singular(:)
    DT, allocatable :: UU(:,:),VV(:,:)


	if(allocated(blocks%ButterflyMiddle))then



        group_m=blocks%row_group ! Note: row_group and col_group interchanged here
        group_n=blocks%col_group
        level_butterfly=blocks%level_butterfly
        num_blocks=2**level_butterfly
	    levelm = ceiling_safe(dble(level_butterfly)/2d0)

		call assert(level_butterfly>=2,'level_butterfly not correct')

		level = levelm
		num_groupm=blocks%ButterflyKerl(level)%num_row
		num_groupn=blocks%ButterflyKerl(level)%num_col


		! !$omp parallel do default(shared) private(ij,ii,jj,kk,ctemp,i,j,index_i,index_j,nn1,nn2,mm)
		do ij=1,num_groupm*(num_groupn/2)
			i = (ij-1)/(num_groupn/2)+1
			j = (mod(ij-1,(num_groupn/2)) + 1)*2-1
			index_i=int((i+1)/2)
			index_j=int((j+1)/2)

			nn1=size(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,2)
			nn2=size(blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix,2)
			mm=size(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,1)

			allocate(matrixtemp(mm,nn1))
			matrixtemp = blocks%ButterflyKerl(level)%blocks(i,j)%matrix
			! call gemm_omp(blocks%ButterflyMiddle(i,index_j)%matrix,blocks%ButterflyKerl(level)%blocks(i,j)%matrix,blocks%ButterflyKerl(level)%blocks(i,j)%matrix,mm,nn1,mm)
			call gemmf90(blocks%ButterflyMiddle(i,index_j)%matrix,mm,matrixtemp,mm,blocks%ButterflyKerl(level)%blocks(i,j)%matrix,mm,'N','N',mm,nn1,mm,cone,czero)
			deallocate(matrixtemp)

			allocate(matrixtemp(mm,nn2))
			matrixtemp = blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix
			! call gemm_omp(blocks%ButterflyMiddle(i,index_j)%matrix,blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix,blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix,mm,nn2,mm)
			call gemmf90(blocks%ButterflyMiddle(i,index_j)%matrix,mm,matrixtemp,mm,blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix,mm,'N','N',mm,nn2,mm,cone,czero)
			deallocate(matrixtemp)

			deallocate(blocks%ButterflyMiddle(i,index_j)%matrix)
		enddo
		! !$omp end parallel do

		deallocate(blocks%ButterflyMiddle)

		do level=0, levelm-1
			if(level==0)then

				iijj=0
				do j=1, num_blocks
					iijj = iijj + 1
					dimension_n=size(blocks%ButterflyV%blocks(j)%matrix,1)
					rank = size(blocks%ButterflyV%blocks(j)%matrix,2)
					mn_min = min(dimension_n,rank)

					allocate(matrixtemp(rank,dimension_n))
					allocate(UU(rank,mn_min))
					allocate(VV(mn_min,dimension_n))
					allocate(Singular(mn_min))

					call copymatT(blocks%ButterflyV%blocks(j)%matrix,matrixtemp,dimension_n,rank)

					call gesvd_robust(matrixtemp,Singular,UU,VV,rank,dimension_n,mn_min)
					do ii=1,mn_min
						UU(:,ii) = UU(:,ii)*Singular(ii)
					end do

					deallocate(blocks%ButterflyV%blocks(j)%matrix)
					allocate(blocks%ButterflyV%blocks(j)%matrix(dimension_n,mn_min))
					call copymatT(VV,blocks%ButterflyV%blocks(j)%matrix,mn_min,dimension_n)

					index_j = mod(iijj-1,blocks%ButterflyKerl(level+1)%num_col)+1
					index_i = ceiling_safe(dble(iijj)/dble(blocks%ButterflyKerl(level+1)%num_col))
					mm1=size(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix,1)
					allocate(matrixtemp1(mm1,mn_min))
					matrixtemp1=0
					! call gemm_omp(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix,UU,matrixtemp1,mm1,mn_min,rank)
					call gemmf90(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix,mm1,UU,rank,matrixtemp1,mm1,'N','N',mm1,mn_min,rank,cone,czero)

					deallocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix)
					allocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix(mm1,mn_min))
					blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix = matrixtemp1
					deallocate(matrixtemp1)

					mm2=size(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix,1)
					allocate(matrixtemp1(mm2,mn_min))
					! call gemm_omp(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix,UU,matrixtemp1,mm2,mn_min,rank)
					call gemmf90(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix,mm2,UU,rank,matrixtemp1,mm2,'N','N',mm2,mn_min,rank,cone,czero)
					deallocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix)
					allocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix(mm2,mn_min))
					blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix = matrixtemp1
					deallocate(matrixtemp1)

					deallocate(matrixtemp)
					deallocate(UU)
					deallocate(VV)
					deallocate(Singular)

				enddo
			else
				num_row=blocks%ButterflyKerl(level)%num_row
				num_col=blocks%ButterflyKerl(level)%num_col

				iijj=0
				do i=1,	num_row
					do j =1, num_col, 2
						iijj = iijj + 1
						rank = size(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,1)
						nn1 = size(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,2)
						nn2 = size(blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix,2)
						mn_min = min(nn1+nn2,rank)

						allocate(matrixtemp(rank,nn1+nn2))
						allocate(UU(rank,mn_min))
						allocate(VV(mn_min,nn1+nn2))
						allocate(Singular(mn_min))

						! call copymatN(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,matrixtemp(1:rank,1:nn1),rank,nn1)
						matrixtemp(1:rank,1:nn1) = blocks%ButterflyKerl(level)%blocks(i,j)%matrix
						! call copymatN(blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix,matrixtemp(1:rank,1+nn1:nn2+nn1),rank,nn2)
						matrixtemp(1:rank,1+nn1:nn2+nn1) = blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix

						call gesvd_robust(matrixtemp,Singular,UU,VV,rank,nn1+nn2,mn_min)
						do ii=1,mn_min
							UU(:,ii) = UU(:,ii)*Singular(ii)
						end do

						deallocate(blocks%ButterflyKerl(level)%blocks(i,j)%matrix)
						allocate(blocks%ButterflyKerl(level)%blocks(i,j)%matrix(mn_min,nn1))
						! call copymatN(VV(1:mn_min,1:nn1),blocks%ButterflyKerl(level)%blocks(i,j)%matrix,mn_min,nn1)
						blocks%ButterflyKerl(level)%blocks(i,j)%matrix = VV(1:mn_min,1:nn1)
						deallocate(blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix)
						allocate(blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix(mn_min,nn2))
						! call copymatN(VV(1:mn_min,1+nn1:nn2+nn1),blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix,mn_min,nn2)
						blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix = VV(1:mn_min,1+nn1:nn2+nn1)


						index_j = mod(iijj-1,blocks%ButterflyKerl(level+1)%num_col)+1
						index_i = ceiling_safe(dble(iijj)/dble(blocks%ButterflyKerl(level+1)%num_col))


						mm1=size(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix,1)
						allocate(matrixtemp1(mm1,mn_min))
						! call gemm_omp(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix,UU,matrixtemp1,mm1,mn_min,rank)
						call gemmf90(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix,mm1,UU,rank,matrixtemp1,mm1,'N','N',mm1,mn_min,rank,cone,czero)
						deallocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix)
						allocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix(mm1,mn_min))
						blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix = matrixtemp1
						deallocate(matrixtemp1)

						mm2=size(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix,1)
						allocate(matrixtemp1(mm2,mn_min))
						! call gemm_omp(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix,UU,matrixtemp1,mm2,mn_min,rank)
						call gemmf90(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix,mm2,UU,rank,matrixtemp1,mm2,'N','N',mm2,mn_min,rank,cone,czero)
						deallocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix)
						allocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix(mm2,mn_min))
						blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix = matrixtemp1
						deallocate(matrixtemp1)

						deallocate(matrixtemp)
						deallocate(UU)
						deallocate(VV)
						deallocate(Singular)

					end do
				end do
			end if
		end do

	end if

end subroutine BF_sym2asym




subroutine BF_MoveSingulartoLeft(blocks)

    use BPACK_DEFS
	use misc


    implicit none

    integer M,N, Nrnd,group_m, group_n, group_mm, group_nn, index_i, index_j, na, nb, index_start, num_vectors
    integer i, j, ii, jj, ij, iijj, level, level_butterfly, groupm_start, groupn_start, index_iijj, index_ij, k, kk, intemp1, intemp2
    integer header_m, header_n, tailer_m, tailer_n, vector_inuse, mm, nn, num_blocks, level_define, col_vector
    integer rank1, rank2, rank, num_groupm, num_groupn, butterflyB_inuse, header_nn, header_mm, ma, mb
    integer vector_a, vector_b, nn1, nn2, mm1, mm2,levelm
    DT ctemp, a, b
    character chara
	type(matrixblock)::blocks
    integer:: middleflag,dimension_n,dimension_m,num_row,num_col,mn_min

	DT,allocatable::matrixtemp(:,:),matrixtemp1(:,:)

    real(kind=8), allocatable :: Singular(:)
    DT, allocatable :: UU(:,:),VV(:,:)


	group_m=blocks%row_group ! Note: row_group and col_group interchanged here
	group_n=blocks%col_group
	level_butterfly=blocks%level_butterfly
	num_blocks=2**level_butterfly

	do level=0, level_butterfly
		if(level==0)then
			iijj=0
			do j=1, num_blocks
				iijj = iijj + 1
				dimension_n=size(blocks%ButterflyV%blocks(j)%matrix,1)
				rank = size(blocks%ButterflyV%blocks(j)%matrix,2)
				mn_min = min(dimension_n,rank)

				allocate(matrixtemp(rank,dimension_n))
				allocate(UU(rank,mn_min))
				allocate(VV(mn_min,dimension_n))
				allocate(Singular(mn_min))

				call copymatT(blocks%ButterflyV%blocks(j)%matrix,matrixtemp,dimension_n,rank)
				call assert(.not. isnan(fnorm(matrixtemp,rank,dimension_n)),'matrixtemp NAN at 3')

				call gesvd_robust(matrixtemp,Singular,UU,VV,rank,dimension_n,mn_min)
				call assert(.not. isnan(sum(Singular)),'Singular NAN at 3')

				do ii=1,mn_min
					UU(:,ii) = UU(:,ii)*Singular(ii)
				end do


				deallocate(blocks%ButterflyV%blocks(j)%matrix)
				allocate(blocks%ButterflyV%blocks(j)%matrix(dimension_n,mn_min))
				call copymatT(VV,blocks%ButterflyV%blocks(j)%matrix,mn_min,dimension_n)


				index_j = mod(iijj-1,blocks%ButterflyKerl(level+1)%num_col)+1
				index_i = ceiling_safe(dble(iijj)/dble(blocks%ButterflyKerl(level+1)%num_col))

				mm1=size(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix,1)
				allocate(matrixtemp1(mm1,mn_min))
				! call gemm_omp(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix,UU,matrixtemp1,mm1,mn_min,rank)
				call gemmf90(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix,mm1,UU,rank,matrixtemp1,mm1,'N','N',mm1,mn_min,rank,cone,czero)

				deallocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix)
				allocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix(mm1,mn_min))
				blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix = matrixtemp1
				deallocate(matrixtemp1)

				mm2=size(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix,1)
				allocate(matrixtemp1(mm2,mn_min))
				! call gemm_omp(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix,UU,matrixtemp1,mm2,mn_min,rank)
				call gemmf90(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix,mm2,UU,rank,matrixtemp1,mm2,'N','N',mm2,mn_min,rank,cone,czero)
				deallocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix)
				allocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix(mm2,mn_min))
				blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix = matrixtemp1
				deallocate(matrixtemp1)

				deallocate(matrixtemp)
				deallocate(UU)
				deallocate(VV)
				deallocate(Singular)

			enddo
		else
			num_row=blocks%ButterflyKerl(level)%num_row
			num_col=blocks%ButterflyKerl(level)%num_col

			iijj=0
			do i=1,	num_row
				do j =1, num_col, 2
					iijj = iijj + 1
					rank = size(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,1)
					nn1 = size(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,2)
					nn2 = size(blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix,2)
					mn_min = min(nn1+nn2,rank)

					allocate(matrixtemp(rank,nn1+nn2))
					allocate(UU(rank,mn_min))
					allocate(VV(mn_min,nn1+nn2))
					allocate(Singular(mn_min))

					! call copymatN(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,matrixtemp(1:rank,1:nn1),rank,nn1)
					matrixtemp(1:rank,1:nn1) = blocks%ButterflyKerl(level)%blocks(i,j)%matrix
					! call copymatN(blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix,matrixtemp(1:rank,1+nn1:nn2+nn1),rank,nn2)
					matrixtemp(1:rank,1+nn1:nn2+nn1) = blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix
					call assert(.not. isnan(fnorm(matrixtemp,rank,nn1+nn2)),'matrixtemp NAN at 4')
					call gesvd_robust(matrixtemp,Singular,UU,VV,rank,nn1+nn2,mn_min)
					call assert(.not. isnan(sum(Singular)),'Singular NAN at 4')

					do ii=1,mn_min
						UU(:,ii) = UU(:,ii)*Singular(ii)
					end do

					deallocate(blocks%ButterflyKerl(level)%blocks(i,j)%matrix)
					allocate(blocks%ButterflyKerl(level)%blocks(i,j)%matrix(mn_min,nn1))
					! call copymatN(VV(1:mn_min,1:nn1),blocks%ButterflyKerl(level)%blocks(i,j)%matrix,mn_min,nn1)
					blocks%ButterflyKerl(level)%blocks(i,j)%matrix = VV(1:mn_min,1:nn1)
					deallocate(blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix)
					allocate(blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix(mn_min,nn2))
					! call copymatN(VV(1:mn_min,1+nn1:nn2+nn1),blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix,mn_min,nn2)
					blocks%ButterflyKerl(level)%blocks(i,j+1)%matrix = VV(1:mn_min,1+nn1:nn2+nn1)

					if(level/=level_butterfly)then
						index_j = mod(iijj-1,blocks%ButterflyKerl(level+1)%num_col)+1
						index_i = ceiling_safe(dble(iijj)/dble(blocks%ButterflyKerl(level+1)%num_col))

						mm1=size(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix,1)
						allocate(matrixtemp1(mm1,mn_min))
						! call gemm_omp(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix,UU,matrixtemp1,mm1,mn_min,rank)

						call gemmf90(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix,mm1,UU,rank,matrixtemp1,mm1,'N','N',mm1,mn_min,rank,cone,czero)

						deallocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix)
						allocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix(mm1,mn_min))
						blocks%ButterflyKerl(level+1)%blocks(index_i*2-1,index_j)%matrix = matrixtemp1
						deallocate(matrixtemp1)

						mm2=size(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix,1)
						allocate(matrixtemp1(mm2,mn_min))
						! call gemm_omp(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix,UU,matrixtemp1,mm2,mn_min,rank)
						call gemmf90(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix,mm2,UU,rank,matrixtemp1,mm2,'N','N',mm2,mn_min,rank,cone,czero)

						deallocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix)
						allocate(blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix(mm2,mn_min))
						blocks%ButterflyKerl(level+1)%blocks(index_i*2,index_j)%matrix = matrixtemp1
						deallocate(matrixtemp1)
					else
						mm1 = size(blocks%ButterflyU%blocks(i)%matrix,1)
						allocate(matrixtemp1(mm1,mn_min))
						! call gemm_omp(blocks%ButterflyU%blocks(i)%matrix,UU,matrixtemp1,mm1,mn_min,rank)
						call gemmf90(blocks%ButterflyU%blocks(i)%matrix,mm1,UU,rank,matrixtemp1,mm1,'N','N',mm1,mn_min,rank,cone,czero)
						deallocate(blocks%ButterflyU%blocks(i)%matrix)
						allocate(blocks%ButterflyU%blocks(i)%matrix(mm1,mn_min))
						blocks%ButterflyU%blocks(i)%matrix = matrixtemp1
						deallocate(matrixtemp1)
					end if

					deallocate(matrixtemp)
					deallocate(UU)
					deallocate(VV)
					deallocate(Singular)

				end do
			end do
		end if
	end do


end subroutine BF_MoveSingulartoLeft





subroutine BF_MoveSingulartoRight(blocks)

    use BPACK_DEFS
	use misc


    implicit none

    integer M,N, Nrnd,group_m, group_n, group_mm, group_nn, index_i, index_j, na, nb, index_start, num_vectors
    integer i, j, ii, jj, ij, iijj, level, level_butterfly, groupm_start, groupn_start, index_iijj, index_ij, k, kk, intemp1, intemp2
    integer header_m, header_n, tailer_m, tailer_n, vector_inuse, mm, nn, num_blocks, level_define, col_vector
    integer rank1, rank2, rank, num_groupm, num_groupn, butterflyB_inuse, header_nn, header_mm, ma, mb
    integer vector_a, vector_b, nn1, nn2, mm1, mm2,levelm
    DT ctemp, a, b
    character chara
	type(matrixblock)::blocks
    integer:: middleflag,dimension_n,dimension_m,num_row,num_col,mn_min

	DT,allocatable::matrixtemp(:,:),matrixtemp1(:,:)

    real(kind=8), allocatable :: Singular(:)
    DT, allocatable :: UU(:,:),VV(:,:)


	group_m=blocks%row_group ! Note: row_group and col_group interchanged here
	group_n=blocks%col_group
	level_butterfly=blocks%level_butterfly
	num_blocks=2**level_butterfly

	do level=level_butterfly+1, 1,-1
		if(level==level_butterfly+1)then
			iijj=0
			do i=1, num_blocks
				iijj = iijj + 1
				dimension_m=size(blocks%ButterflyU%blocks(i)%matrix,1)
				rank = size(blocks%ButterflyU%blocks(i)%matrix,2)
				mn_min = min(dimension_m,rank)

				allocate(matrixtemp(dimension_m,rank))
				allocate(UU(dimension_m,mn_min))
				allocate(VV(mn_min,rank))
				allocate(Singular(mn_min))

				! call copymatN(blocks%ButterflyU%blocks(i)%matrix,matrixtemp,dimension_m,rank)
				matrixtemp = blocks%ButterflyU%blocks(i)%matrix
				call assert(.not. isnan(fnorm(matrixtemp,dimension_m,rank)),'matrixtemp NAN at 1')

				call gesvd_robust(matrixtemp,Singular,UU,VV,dimension_m,rank,mn_min)
				call assert(.not. isnan(sum(Singular)),'Singular NAN at 1')

				do ii=1,mn_min
					VV(ii,:) = VV(ii,:)*Singular(ii)
				end do

				deallocate(blocks%ButterflyU%blocks(i)%matrix)
				allocate(blocks%ButterflyU%blocks(i)%matrix(dimension_m,mn_min))
				! call copymatN(UU,blocks%ButterflyU%blocks(i)%matrix,dimension_m,mn_min)
				blocks%ButterflyU%blocks(i)%matrix = UU

				index_i = mod(iijj-1,blocks%ButterflyKerl(level-1)%num_row)+1
				index_j = ceiling_safe(dble(iijj)/dble(blocks%ButterflyKerl(level-1)%num_row))

				nn1=size(blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2-1)%matrix,2)
				allocate(matrixtemp1(mn_min,nn1))
				! call gemm_omp(VV,blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2-1)%matrix,matrixtemp1,mn_min,nn1,rank)
				call gemmf90(VV,mn_min,blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2-1)%matrix,rank,matrixtemp1,mn_min,'N','N',mn_min,nn1,rank,cone,czero)

				deallocate(blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2-1)%matrix)
				allocate(blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2-1)%matrix(mn_min,nn1))
				blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2-1)%matrix = matrixtemp1
				deallocate(matrixtemp1)

				nn2=size(blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2)%matrix,2)
				allocate(matrixtemp1(mn_min,nn2))
				! call gemm_omp(VV,blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2)%matrix,matrixtemp1,mn_min,nn2,rank)
				call gemmf90(VV,mn_min,blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2)%matrix,rank,matrixtemp1,mn_min,'N','N',mn_min,nn2,rank,cone,czero)
				deallocate(blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2)%matrix)
				allocate(blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2)%matrix(mn_min,nn2))
				blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2)%matrix = matrixtemp1
				deallocate(matrixtemp1)

				deallocate(matrixtemp)
				deallocate(UU)
				deallocate(VV)
				deallocate(Singular)

			enddo
		else
			num_row=blocks%ButterflyKerl(level)%num_row
			num_col=blocks%ButterflyKerl(level)%num_col

			iijj=0
			do j=1,	num_col
				do i =1, num_row, 2
					iijj = iijj + 1
					rank = size(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,2)

					mm1 = size(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,1)
					mm2 = size(blocks%ButterflyKerl(level)%blocks(i+1,j)%matrix,1)
					mn_min = min(mm1+mm2,rank)

					allocate(matrixtemp(mm1+mm2,rank))
					allocate(UU(mm1+mm2,mn_min))
					allocate(VV(mn_min,rank))
					allocate(Singular(mn_min))

					! call copymatN(blocks%ButterflyKerl(level)%blocks(i,j)%matrix,matrixtemp(1:mm1,1:rank),mm1,rank)
					matrixtemp(1:mm1,1:rank) = blocks%ButterflyKerl(level)%blocks(i,j)%matrix
					! call copymatN(blocks%ButterflyKerl(level)%blocks(i+1,j)%matrix,matrixtemp(1+mm1:mm2+mm1,1:rank),mm2,rank)
					matrixtemp(1+mm1:mm2+mm1,1:rank) = blocks%ButterflyKerl(level)%blocks(i+1,j)%matrix
					call assert(.not. isnan(fnorm(matrixtemp,mm1+mm2,rank)),'matrixtemp NAN at 2')

					call gesvd_robust(matrixtemp,Singular,UU,VV,mm1+mm2,rank,mn_min)
					! if(isnan(sum(Singular)).and. mm1+mm2<rank)then
						! write(*,*)mm1+mm2,rank,mm1+mm2>=rank,'rank too large?'
					! end if

					! call assert(.not. isnan(sum(Singular)),'Singular NAN at 2')
					if(isnan(sum(Singular)))then
						write(*,*)'Singular NAN at 2',mm1+mm2,rank
						do ii=1,mm1+mm2
							do jj=1,rank
								write(777,*)dble(matrixtemp(ii,jj)),aimag(cmplx(matrixtemp(ii,jj),kind=8)),abs(matrixtemp(ii,jj))
							end do
						end do
						stop
					end if



					do ii=1,mn_min
						VV(ii,:) = VV(ii,:)*Singular(ii)
					end do

					deallocate(blocks%ButterflyKerl(level)%blocks(i,j)%matrix)
					allocate(blocks%ButterflyKerl(level)%blocks(i,j)%matrix(mm1,mn_min))
					! call copymatN(UU(1:mm1,1:mn_min),blocks%ButterflyKerl(level)%blocks(i,j)%matrix,mm1,mn_min)
					blocks%ButterflyKerl(level)%blocks(i,j)%matrix = UU(1:mm1,1:mn_min)
					deallocate(blocks%ButterflyKerl(level)%blocks(i+1,j)%matrix)
					allocate(blocks%ButterflyKerl(level)%blocks(i+1,j)%matrix(mm2,mn_min))
					! call copymatN(UU(1+mm1:mm2+mm1,1:mn_min),blocks%ButterflyKerl(level)%blocks(i+1,j)%matrix,mm2,mn_min)
					blocks%ButterflyKerl(level)%blocks(i+1,j)%matrix = UU(1+mm1:mm2+mm1,1:mn_min)

					if(level/=1)then
						index_i = mod(iijj-1,blocks%ButterflyKerl(level-1)%num_row)+1
						index_j = ceiling_safe(dble(iijj)/dble(blocks%ButterflyKerl(level-1)%num_row))
						nn1 = size(blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2-1)%matrix,2)

						allocate(matrixtemp1(mn_min,nn1))
						! call gemm_omp(VV,blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2-1)%matrix,matrixtemp1,mn_min,nn1,rank)
						call gemmf90(VV,mn_min,blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2-1)%matrix,rank,matrixtemp1,mn_min,'N','N',mn_min,nn1,rank,cone,czero)

						deallocate(blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2-1)%matrix)
						allocate(blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2-1)%matrix(mn_min,nn1))
						blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2-1)%matrix = matrixtemp1
						deallocate(matrixtemp1)

						nn2 = size(blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2)%matrix,2)
						allocate(matrixtemp1(mn_min,nn2))
						! call gemm_omp(VV,blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2)%matrix,matrixtemp1,mn_min,nn2,rank)
						call gemmf90(VV,mn_min,blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2)%matrix,rank,matrixtemp1,mn_min,'N','N',mn_min,nn2,rank,cone,czero)


						deallocate(blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2)%matrix)
						allocate(blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2)%matrix(mn_min,nn2))
						blocks%ButterflyKerl(level-1)%blocks(index_i,index_j*2)%matrix = matrixtemp1
						deallocate(matrixtemp1)
					else
						nn1 = size(blocks%ButterflyV%blocks(j)%matrix,1)
						allocate(matrixtemp1(nn1,mn_min))
						! call gemmNT_omp(blocks%ButterflyV%blocks(j)%matrix,VV,matrixtemp1,nn1,mn_min,rank)
						call gemmf90(blocks%ButterflyV%blocks(j)%matrix,nn1, VV,mn_min, matrixtemp1,nn1, 'N','T',nn1,mn_min,rank,cone,czero)
						deallocate(blocks%ButterflyV%blocks(j)%matrix)
						allocate(blocks%ButterflyV%blocks(j)%matrix(nn1,mn_min))
						blocks%ButterflyV%blocks(j)%matrix = matrixtemp1
						deallocate(matrixtemp1)
					end if

					deallocate(matrixtemp)
					deallocate(UU)
					deallocate(VV)
					deallocate(Singular)

				end do
			end do
		end if
	end do


end subroutine BF_MoveSingulartoRight



recursive subroutine Hmat_block_copy(trans,block2,block1,memory)

    use BPACK_DEFS
    implicit none

    integer blocks, flag_recv, count1, count2, recv_count, mm, nn, length
    integer i, ii, j, jj, style, send_ID, group_m, group_n, indices, requests
    character chara

    type(matrixblock), pointer :: block1, block2, blocks_son1, blocks_son2
	character::trans
	real(kind=8),optional::memory
	real(kind=8)::memory_tmp

	block2%style = block1%style

	block2%level=block1%level
	block2%row_group=block1%row_group
	block2%col_group=block1%col_group
	block2%level_butterfly=0
	group_m = block2%row_group
	group_n = block2%col_group
	block2%pgno = block1%pgno
	block2%M = block1%M
	block2%N = block1%N
	block2%headm = block1%headm
	block2%headn = block1%headn

	if(associated(block1%N_p))then
		if(associated(block2%N_p))deallocate(block2%N_p)
		allocate(block2%N_p(size(block1%N_p,1),2))
		block2%N_p = block1%N_p
	endif
	if(associated(block1%M_p))then
		if(associated(block2%M_p))deallocate(block2%M_p)
		allocate(block2%M_p(size(block1%M_p,1),2))
		block2%M_p = block1%M_p
	endif


    style=block2%style
    if (style==4) then
        allocate(block2%sons(2,2))
        do j=1,2
            do i=1,2
                block2%sons(i,j)%father=>block2
            enddo
        enddo

		blocks_son1=>block1%sons(1,1)
		blocks_son2=>block2%sons(1,1)
		call Hmat_block_copy(trans,blocks_son2,blocks_son1,memory)
		blocks_son1=>block1%sons(2,1)
		blocks_son2=>block2%sons(2,1)
		call Hmat_block_copy(trans,blocks_son2,blocks_son1,memory)
		 blocks_son1=>block1%sons(1,2)
		blocks_son2=>block2%sons(1,2)
		call Hmat_block_copy(trans,blocks_son2,blocks_son1,memory)
		 blocks_son1=>block1%sons(2,2)
		blocks_son2=>block2%sons(2,2)
		call Hmat_block_copy(trans,blocks_son2,blocks_son1,memory)

    else
		call BF_copy(trans,block1,block2,memory_tmp)
		if(present(memory))memory = memory + memory_tmp
    endif

    return

end subroutine Hmat_block_copy


recursive subroutine Hmat_block_delete(blocks)


    implicit none

    integer level_actual, num_col, num_row
    integer i, j, mm, nn, rank, num_blocks, level, level_butterfly
    real*8 memory_butterfly, rtemp
    type(matrixblock) :: blocks
    type(matrixblock), pointer :: blocks_son

    if (blocks%style==4) then

		blocks_son=>blocks%sons(1,1)
		call Hmat_block_delete(blocks_son)
		blocks_son=>blocks%sons(2,1)
		call Hmat_block_delete(blocks_son)
		blocks_son=>blocks%sons(1,2)
		call Hmat_block_delete(blocks_son)
		blocks_son=>blocks%sons(2,2)
		call Hmat_block_delete(blocks_son)

        deallocate (blocks%sons)

    else
        call BF_delete(blocks,1)
    endif

    return

end subroutine Hmat_block_delete




recursive subroutine Hmat_block_ComputeMemory(blocks,memory)


    implicit none

    integer level_actual, num_col, num_row
    integer i, j, mm, nn, rank, num_blocks, level, level_butterfly
    real*8 memory_butterfly, rtemp,memory
    type(matrixblock) :: blocks
    type(matrixblock), pointer :: blocks_son

    if (blocks%style==4) then

		blocks_son=>blocks%sons(1,1)
		call Hmat_block_ComputeMemory(blocks_son,memory)
		blocks_son=>blocks%sons(2,1)
		call Hmat_block_ComputeMemory(blocks_son,memory)
		blocks_son=>blocks%sons(1,2)
		call Hmat_block_ComputeMemory(blocks_son,memory)
		blocks_son=>blocks%sons(2,2)
		call Hmat_block_ComputeMemory(blocks_son,memory)
    else
        call BF_ComputeMemory(blocks,rtemp)
		memory = memory + rtemp
    endif

    return

end subroutine Hmat_block_ComputeMemory




recursive subroutine Hmat_Lsolve(blocks_l,trans,idx_start,nvec,Vinout,ptree,stats)
    implicit none

    ! integer vectors_y
    integer style(3)
    integer i, j, k, ii
    integer mm, nn, nvec,idxs_m, idx_start ! idx_start means the global indice of the first element of Vinout
    integer head, tail
    DT ctemp
    DT:: Vinout(:,:)
    type(matrixblock) :: blocks_l !!!! modified by Yang Liu. passing pointer is dangerous, blocks_u row/row_group becomes different once in this subroutine
	character trans ! 'N' means multiple L^-1 from left, 'T' means multiple L^-1 from right
	type(proctree)::ptree
	type(Hstat)::stats

    if (blocks_l%style==4) then
		if(trans=='N')then
			call Hmat_Lsolve(blocks_l%sons(1,1),trans,idx_start,nvec,Vinout,ptree,stats)
			call Hmat_block_MVP_dat(blocks_l%sons(2,1),trans,idx_start,idx_start,nvec,Vinout,Vinout,-cone,ptree,stats)
			call Hmat_Lsolve(blocks_l%sons(2,2),trans,idx_start,nvec,Vinout,ptree,stats)
		else
			call Hmat_Lsolve(blocks_l%sons(2,2),trans,idx_start,nvec,Vinout,ptree,stats)
			call Hmat_block_MVP_dat(blocks_l%sons(2,1),trans,idx_start,idx_start,nvec,Vinout,Vinout,-cone,ptree,stats)
			call Hmat_Lsolve(blocks_l%sons(1,1),trans,idx_start,nvec,Vinout,ptree,stats)
		end if
    else
		mm = blocks_l%M
		idxs_m = blocks_l%headm - idx_start + 1

		if(trans=='N')then
			do i=1, mm
				ii=blocks_l%ipiv(i)
				if (ii/=i) then
					!$omp parallel do default(shared) private(j,ctemp)
					do j=1, nvec
						ctemp=Vinout(idxs_m+i-1,j)
						Vinout(idxs_m+i-1,j)=Vinout(idxs_m+ii-1,j)
						Vinout(idxs_m+ii-1,j)=ctemp
					enddo
					!$omp end parallel do
				endif
			enddo
		endif
		! write(*,*)blocks_l%level,blocks_l%pgno,ptree%MyID,blocks_l%headm,mm,idx_start,'daha'
		call trsmf90(blocks_l%fullmat,Vinout(idxs_m:idxs_m+mm-1,1:nvec),'L','L',trans,'U',mm,nvec)
		if(trans/='N')then
			do i=mm,1,-1
				ii=blocks_l%ipiv(i)
				if (ii/=i) then
					!$omp parallel do default(shared) private(j,ctemp)
					do j=1, nvec
						ctemp=Vinout(idxs_m+i-1,j)
						Vinout(idxs_m+i-1,j)=Vinout(idxs_m+ii-1,j)
						Vinout(idxs_m+ii-1,j)=ctemp
					enddo
					!$omp end parallel do
				endif
			enddo
		end if
    endif

    return

end subroutine Hmat_Lsolve


recursive subroutine Hmat_Usolve(blocks_u,trans,idx_start,nvec,Vinout,ptree,stats)
    implicit none


	type(proctree)::ptree
	type(Hstat)::stats

	integer vectors_x, vectors_y
    integer style(3), mark
    integer i, j, k,ii
    integer mm, nn, nvec
    integer head, tail
    DT Vinout(:,:)
    type(matrixblock) :: blocks_u, blocks !!!! modified by Yang Liu. passing pointer is dangerous, blocks_u row/row_group becomes different once in this subroutine
	character trans
    integer idx_start,idxs_m

    mark=0
    if (blocks_u%style==4) then
		if(trans=='N')then
			call Hmat_Usolve(blocks_u%sons(2,2),trans,idx_start,nvec,Vinout,ptree,stats)
			call Hmat_block_MVP_dat(blocks_u%sons(1,2),trans,idx_start,idx_start,nvec,Vinout,Vinout,-cone,ptree,stats)
			call Hmat_Usolve(blocks_u%sons(1,1),trans,idx_start,nvec,Vinout,ptree,stats)
		else
			call Hmat_Usolve(blocks_u%sons(1,1),trans,idx_start,nvec,Vinout,ptree,stats)
			call Hmat_block_MVP_dat(blocks_u%sons(1,2),trans,idx_start,idx_start,nvec,Vinout,Vinout,-cone,ptree,stats)
			call Hmat_Usolve(blocks_u%sons(2,2),trans,idx_start,nvec,Vinout,ptree,stats)
		end if

    else
		mm = blocks_u%M
		idxs_m = blocks_u%headm - idx_start + 1
		call trsmf90(blocks_u%fullmat,Vinout(idxs_m:idxs_m+mm-1,1:nvec),'L','U',trans,'N',mm,nvec)
    endif

    return

end subroutine Hmat_Usolve

recursive subroutine Hmat_block_MVP_dat(blocks,trans,idx_start_m,idx_start_n,Nrnd,Vin,Vout,a,ptree,stats)

    implicit none
	integer idx_start_m,idx_start_n
    integer Nrnd
    integer mm, nn, idxs_m,idxs_n
    DT a
    character trans
	type(matrixblock)::blocks
	type(matrixblock),pointer::blocks_son
	integer:: style
	DT,allocatable::Vintmp(:,:),Vouttmp(:,:)
	DT::Vin(:,:),Vout(:,:)
	type(proctree)::ptree
	type(Hstat)::stats


	style = blocks%style
	mm = blocks%M
	idxs_m = blocks%headm - idx_start_m + 1
	nn = blocks%N
	idxs_n = blocks%headn - idx_start_n + 1


    if (style==4) then
		blocks_son=>blocks%sons(1,1)
		call Hmat_block_MVP_dat(blocks_son,trans,idx_start_m,idx_start_n,Nrnd,Vin,Vout,a,ptree,stats)
		blocks_son=>blocks%sons(1,2)
		call Hmat_block_MVP_dat(blocks_son,trans,idx_start_m,idx_start_n,Nrnd,Vin,Vout,a,ptree,stats)
		blocks_son=>blocks%sons(2,1)
		call Hmat_block_MVP_dat(blocks_son,trans,idx_start_m,idx_start_n,Nrnd,Vin,Vout,a,ptree,stats)
		blocks_son=>blocks%sons(2,2)
		call Hmat_block_MVP_dat(blocks_son,trans,idx_start_m,idx_start_n,Nrnd,Vin,Vout,a,ptree,stats)
    else
        if (style==1) then
            if (trans=='N') then
				allocate(Vintmp(nn,Nrnd))
				Vintmp = Vin(idxs_n:idxs_n+nn-1,1:Nrnd)
				allocate(Vouttmp(mm,Nrnd))
				Vouttmp = 0
				call gemmf90(blocks%fullmat,mm,Vintmp,nn,Vouttmp,mm,trans,'N',mm,Nrnd,nn,a,czero)
				Vout(idxs_m:idxs_m+mm-1,1:Nrnd) = Vout(idxs_m:idxs_m+mm-1,1:Nrnd)+Vouttmp
				deallocate(Vintmp)
				deallocate(Vouttmp)
			else
				allocate(Vintmp(mm,Nrnd))
				Vintmp = Vin(idxs_m:idxs_m+mm-1,1:Nrnd)
				allocate(Vouttmp(nn,Nrnd))
				Vouttmp = 0
				call gemmf90(blocks%fullmat,mm,Vintmp,mm,Vouttmp,nn,trans,'N',nn,Nrnd,mm,a,czero)
				Vout(idxs_n:idxs_n+nn-1,1:Nrnd) = Vout(idxs_n:idxs_n+nn-1,1:Nrnd)+Vouttmp
				deallocate(Vintmp)
				deallocate(Vouttmp)
		   endif
        else
			if (trans=='N') then
				call BF_block_MVP_dat(blocks,trans,mm,nn,Nrnd,Vin(idxs_n:idxs_n+nn-1,1:Nrnd),Vout(idxs_m:idxs_m+mm-1,1:Nrnd),a,cone,ptree,stats)
            else
				call BF_block_MVP_dat(blocks,trans,mm,nn,Nrnd,Vin(idxs_m:idxs_m+mm-1,1:Nrnd),Vout(idxs_n:idxs_n+nn-1,1:Nrnd),a,cone,ptree,stats)
            endif
        endif
    endif

end subroutine Hmat_block_MVP_dat



subroutine Full_block_MVP_dat(blocks,chara,M,N,random1,random2,a,b)
	use BPACK_DEFS


	use misc
    implicit none

    integer group_m, group_n, group_mm, group_nn, index_i, index_j, na, nb, index_start, num_vectors
    integer i, j, ii, jj, level, level_butterfly, groupm_start, groupn_start, index_iijj, index_ij, k, kk, intemp1, intemp2
    integer header_m, header_n, tailer_m, tailer_n, vector_inuse, mm, nn, num_blocks, level_define, col_vector
    integer rank1, rank2, rank, num_groupm, num_groupn, butterflyB_inuse, header_nn, header_mm, ma, mb
    integer vector_a, vector_b, nn1, nn2, level_blocks, mm1, mm2
    DT ctemp, a, b
    character chara
	type(matrixblock)::blocks
	integer M,N
    DT :: random1(M,N), random2(M,N)
	DT:: al,be
	DT,allocatable :: random2tmp(:,:)

	allocate(random2tmp(M,N))



	al=1d0
	be=0d0

	num_vectors=size(random1,2)


	random2tmp = random2
	call assert(size(blocks%fullmat,1)==size(blocks%fullmat,2) ,'M not square')
	if(size(blocks%fullmat,1)/=M)write(*,*)M,N,shape(blocks%fullmat),blocks%row_group,blocks%col_group,'niao'
	call assert(size(blocks%fullmat,1)==M,'M not equal fullmat dim')

	if (chara=='N') then
        group_m=blocks%row_group  ! Note: row_group and col_group interchanged here
        group_n=blocks%col_group
		call assert(group_m==group_n,'fullmat not square')
        ! level_blocks=blocks%level
		! write(*,*)shape(blocks%fullmat),shape(random1),shape(random2),num_vectors

		! call gemm_omp(blocks%fullmat, random1, random2,M,N,M)
		call gemmf90(blocks%fullmat,M, random1,M, random2,M,'N','N',M,N,M,cone,czero)
    elseif (chara=='T') then
        group_m=blocks%row_group  ! Note: row_group and col_group interchanged here
        group_n=blocks%col_group
		call assert(group_m==group_n,'fullmat not square')
        ! level_blocks=blocks%level
		! call gemmTN_omp(blocks%fullmat, random1, random2,M,N,M)
		call gemmf90(blocks%fullmat,M, random1,M, random2,M, 'T','N',M,N,M,al,be)
	end if

	random2 = a*random2+ b*random2tmp
	! write(*,*)'wo cao ni ma'
	deallocate(random2tmp)
end subroutine Full_block_MVP_dat




! compute arrays M_p(1:P+1) and N_p(1:P+1) the holds the start and end column/row of each process sharing this block
subroutine ComputeParallelIndices(block,pgno,ptree,msh,flag)
implicit none
	type(matrixblock)::block
	integer pgno,level,level_p,level_butterfly,flag,nproc,num_blocks,proc,gg,ii,ii_new,Maxlevel
	type(proctree)::ptree
	integer,pointer::M_p(:,:),N_p(:,:)
	type(mesh)::msh

	if(flag==0)block%M_loc = 0
	if(flag==1)block%M_loc_db = 0
	if(flag==0)block%N_loc = 0
	if(flag==1)block%N_loc_db = 0

	Maxlevel = GetTreelevel(msh%Maxgroup)-1
	! write(*,*)msh%Maxgroup,GetTreelevel(msh%Maxgroup),Maxlevel-block%level,block%level,ptree%nlevel-GetTreelevel(pgno),pgno
	call assert(Maxlevel-block%level>=ptree%nlevel-GetTreelevel(pgno),'too many process sharing this group')

	! if(IOwnPgrp(ptree,pgno))then

		! level_butterfly = block%level_butterfly
		level_p = ptree%nlevel-GetTreelevel(pgno)
		nproc = ptree%pgrp(pgno)%nproc
		num_blocks = 2**level_p

		if(flag==0)then
			if(associated(block%M_p))deallocate(block%M_p)
			if(associated(block%N_p))deallocate(block%N_p)
			allocate(block%M_p(nproc,2))
			allocate(block%N_p(nproc,2))
			M_p => block%M_p
			N_p => block%N_p
		else
			if(associated(block%M_p_db))deallocate(block%M_p_db)
			if(associated(block%N_p_db))deallocate(block%N_p_db)
			allocate(block%M_p_db(nproc,2))
			allocate(block%N_p_db(nproc,2))
			M_p => block%M_p_db
			N_p => block%N_p_db
		endif

		M_p(:,1) = block%M+1
		N_p(:,1) = block%N+1
		M_p(:,2) = -block%M-1
		N_p(:,2) = -block%N-1

		do ii=1,num_blocks

			! if(flag==1)then  ! compute optimal renumbering of data pieces among the twice many processes
				! if(mod(ii,2)==1)then
					! ii_new=ceiling_safe(ii/2d0)
				! else
					! ii_new=ii/2+num_blocks/2
				! endif
			! else
				ii_new=ii
			! endif

			gg = block%row_group*2**level_p+ii_new-1
			proc = ptree%pgrp(pgno*2**level_p+ii-1)%head - ptree%pgrp(pgno)%head
			M_p(proc+1,1) = min(M_p(proc+1,1),msh%basis_group(gg)%head-msh%basis_group(block%row_group)%head+1)
			M_p(proc+1,2) = max(M_p(proc+1,2),msh%basis_group(gg)%tail-msh%basis_group(block%row_group)%head+1)
			gg = block%col_group*2**level_p+ii_new-1
			N_p(proc+1,1) = min(N_p(proc+1,1),msh%basis_group(gg)%head-msh%basis_group(block%col_group)%head+1)
			N_p(proc+1,2) = max(N_p(proc+1,2),msh%basis_group(gg)%tail-msh%basis_group(block%col_group)%head+1)
		enddo

		if(IOwnPgrp(ptree,pgno))then
			ii = ptree%myid-ptree%pgrp(pgno)%head+1
			if(flag==0)block%M_loc = M_p(ii,2)-M_p(ii,1)+1
			if(flag==1)block%M_loc_db = M_p(ii,2)-M_p(ii,1)+1
			if(flag==0)block%N_loc = N_p(ii,2)-N_p(ii,1)+1
			if(flag==1)block%N_loc_db = N_p(ii,2)-N_p(ii,1)+1
		endif
		! write(*,*)level_butterfly,level_p,block%M_loc,block%N_loc,'nima',M_p,N_p,block%M,block%N,block%row_group,block%col_group
	! endif
end subroutine ComputeParallelIndices


end module Bplus_Utilities