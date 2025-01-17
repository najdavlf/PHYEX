program main_rain_ice_old

  use xrd_getoptions, only: initoptions, getoption
  use getdata_rain_ice_old_mod, only: getdata_rain_ice_old

  use modi_rain_ice_old

  use yomhook, only: lhook, dr_hook
  use parkind1, only: jprb, jpim

  use modd_dimphyex, only: dimphyex_t
  use modd_cst, only: cst
  use modd_rain_ice_param_n, only: rain_ice_paramn
  use modd_rain_ice_descr_n, only: rain_ice_descrn
  use modd_param_ice_n,      only: param_icen
  use modd_budget

  use iso_fortran_env, only: output_unit

  implicit none

  integer :: n_gp_blocks, &
             n_proma, &
             n_levels

  real, allocatable, dimension(:,:,:)   :: pdzz
  real, allocatable, dimension(:,:,:)   :: prhodj
  real, allocatable, dimension(:,:,:)   :: prhodref
  real, allocatable, dimension(:,:,:)   :: pexnref
  real, allocatable, dimension(:,:,:)   :: ppabsm
  real, allocatable, dimension(:,:,:)   :: pcit, pcit_out
  real, allocatable, dimension(:,:,:)   :: pcldfr
  real, allocatable, dimension(:,:,:)   :: ptht
  real, allocatable, dimension(:,:,:,:) :: prt
  real, allocatable, dimension(:,:,:)   :: pths, pths_out
  real, allocatable, dimension(:,:,:,:) :: prs, prs_out
  real, allocatable, dimension(:,:,:)   :: psigs
  real, allocatable, dimension(:,:)     :: psea
  real, allocatable, dimension(:,:)     :: ptown

  real, allocatable, dimension(:,:)     :: zinprc, zinprc_out
  real, allocatable, dimension(:,:)     :: pinprr, pinprr_out
  real, allocatable, dimension(:,:,:)   :: pevap, pevap_out
  real, allocatable, dimension(:,:)     :: pinprs, pinprs_out
  real, allocatable, dimension(:,:)     :: pinprg, pinprg_out
  real, allocatable, dimension(:,:,:,:) :: pfpr, pfpr_out

  real, allocatable, dimension(:,:)     :: pinprh, pinprh_out

  !spp stuff
  real, allocatable, dimension(:,:)   :: picenu, pkgn_acon, pkgn_sbgr
  !ocnd2 stuff
  real, allocatable, dimension(:,:,:) :: picldfr ! Ice cloud fraction
  real, allocatable, dimension(:,:,:) :: pifr    ! Ratio cloud ice moist part to dry part
  real, allocatable, dimension(:,:,:) :: pssio   ! Super-saturation with respect to ice in the supersaturated fraction
  real, allocatable, dimension(:,:,:) :: pssiu   ! Sub-saturation with respect to ice in the subsaturated fraction

  logical, allocatable, dimension(:,:,:) :: llmicro

  integer :: isize

  type(dimphyex_t) :: D

  integer(8) :: counter, c_rate
  logical :: l_verbose, checkdiff

  integer :: kka
  integer :: kku
  integer :: kkl
  integer :: krr
  integer :: ksplitr

  logical :: osedic
  logical :: ocnd2
  logical :: lkogan
  logical :: lmodicedep
  character(len=4) :: c_sedim
  character(len=4) :: c_micro
  character(len=4) :: csubg_aucv_rc
  logical :: owarm
  TYPE(TBUDGETDATA), DIMENSION(NBUDGET_RH) :: YLBUDGET

  real    :: ptstep

  integer :: i, j, jrr

  real(8) :: time_start_real, time_end_real
  real(8) :: time_start_cpu, time_end_cpu

  interface

    subroutine init_rain_ice_old(kulout)

      implicit none

      integer, intent (in)            :: kulout

    end subroutine init_rain_ice_old

    subroutine init_gmicro(D, krr, n_gp_blocks, odmicro, prt, pssio, ocnd2, prht)

      use modd_dimphyex, only: dimphyex_t
      use modd_rain_ice_descr_n, only: xrtmin
      use modd_rain_ice_param_n, only: xfrmin

      implicit none

      type(dimphyex_t) :: D

      integer, intent(in) :: krr, n_gp_blocks
      logical, dimension(D%nit, D%nkt, n_gp_blocks), intent(inout) :: odmicro

      real, dimension(D%nit, D%nkt, krr, n_gp_blocks), intent(in) :: prt
      real, dimension(D%nit, D%nkt, n_gp_blocks), intent(in) :: pssio
      real, dimension(D%nit, D%nkt, n_gp_blocks), optional, intent(in) :: prht

      logical, intent(in) :: ocnd2

    end subroutine init_gmicro

    subroutine print_diff_1(array, ref)

      implicit none

      real, intent(in), dimension(:) :: array
      real, intent(in), dimension(:) :: ref

    end subroutine print_diff_1

    subroutine print_diff_2(array, ref)

      implicit none

      real, intent(in), dimension(:,:) :: array
      real, intent(in), dimension(:,:) :: ref

    end subroutine print_diff_2

  end interface


  n_gp_blocks = 150
  n_proma = 32
  n_levels = 90
  krr = 6
  l_verbose = .false.
  checkdiff = .false.

  owarm = .true.

  kka = 1
  kku = n_levels
  kkl = -1
  ksplitr = 2

  c_sedim = 'STAT'
  csubg_aucv_rc = 'PDF'

DO JRR=1, NBUDGET_RH
  YLBUDGET(JRR)%NBUDGET=JRR
ENDDO

  ptstep = 25.0000000000000

  call initoptions()

  call getoption ("--blocks", n_gp_blocks)
  call getoption ("--nproma", n_proma)
  call getoption ("--nflevg", n_levels)
  call getoption ("--verbose", l_verbose)

  write(output_unit, *) 'n_gp_blocks: ', n_gp_blocks
  write(output_unit, *) 'n_proma:     ', n_proma
  write(output_unit, *) 'n_levels:    ', n_levels
  write(output_unit, *) 'total:       ', n_levels*n_proma*n_gp_blocks

  call getdata_rain_ice_old(n_proma, n_gp_blocks, n_levels, krr, &
                            osedic, ocnd2, lkogan, lmodicedep, owarm, &
                            kka, kku, kkl, ksplitr, &
                            ptstep, c_sedim, csubg_aucv_rc, &
                            pdzz, prhodj, prhodref, &
                            pexnref, ppabsm, &
                            pcit, pcit_out, &
                            pcldfr, &
                            picldfr, pssio, pssiu, pifr,  &
                            ptht, prt, pths, pths_out, &
                            prs, prs_out, &
                            psigs, psea, ptown,     &
                            zinprc, zinprc_out, &
                            pinprr, pinprr_out, &
                            pevap, pevap_out,        &
                            pinprs, pinprs_out, &
                            pinprg, pinprg_out,      &
                            pinprh, pinprh_out,      &
                            picenu, pkgn_acon, pkgn_sbgr, &
                            pfpr, pfpr_out, llmicro, l_verbose)

  
  write(output_unit, *) 'osedic:        ', osedic
  write(output_unit, *) 'ocnd2:         ', ocnd2
  write(output_unit, *) 'lkogan:        ', lkogan
  write(output_unit, *) 'lmodicedep:    ', lmodicedep
  write(output_unit, *) 'owarm:         ', owarm
  write(output_unit, *) 'kka:           ', kka
  write(output_unit, *) 'kku:           ', kku
  write(output_unit, *) 'kkl:           ', kkl
  write(output_unit, *) 'ksplitr:       ', ksplitr
  write(output_unit, *) 'ptstep:        ', ptstep
  write(output_unit, *) 'c_sedim:       ', c_sedim
  write(output_unit, *) 'csubg_aucv_rc: ', csubg_aucv_rc

  D%nit  = n_proma
  D%nib  = 1
  D%nie  = n_proma
  D%njt  = 1
  D%njb  = 1
  D%nje  = 1
  D%nijt = D%nit * D%njt
  D%nijb = 1
  D%nije = n_proma
  D%nkl  = -1
  D%nkt  = n_levels
  D%nka  = n_levels
  D%nku  = 1
  D%nkb  = n_levels
  D%nke  = 1
  D%nktb = 1
  D%nkte = n_levels

  call init_rain_ice_old(20)

  call init_gmicro(D, krr, n_gp_blocks, llmicro, prt, pssio, ocnd2)

  call cpu_time(time_start_cpu)
  call system_clock(count=counter, count_rate=c_rate)
  time_start_real = real(counter,8)/c_rate

  do i = 1, n_gp_blocks

    isize = count(llmicro(:,:,i))

    if (isize .gt. 0) then

      call rain_ice_old(D=D, cst=cst, parami=param_icen,                                   &
                        icep=rain_ice_paramn, iced=rain_ice_descrn, buconf=tbuconf,        &
                        osedic=osedic, ocnd2=ocnd2,                                        &
                        lkogan=lkogan, lmodicedep=lmodicedep,                              &
                        hsedim=c_sedim, hsubg_aucv_rc=csubg_aucv_rc, owarm=owarm,          &
                        kka=kka, kku=kku, kkl=kkl,                                         &
                        ksplitr=ksplitr, ptstep=2*ptstep, krr=krr,                         &
                        ksize=isize, gmicro=llmicro(:,:,i),                                &
                        pdzz=pdzz(:,:,i), prhodj=prhodj(:,:,i), prhodref=prhodref(:,:,i),  &
                        pexnref=pexnref(:,:,i), ppabst=ppabsm(:,:,i),                      &
                        pcit=pcit(:,:,i), pcldfr=pcldfr(:,:,i),                            &
                        picldfr=picldfr(:,:,i), pssio=pssio(:,:,i), pssiu=pssiu(:,:,i),    &
                        pifr=pifr(:,:,i),                                                  &
                        ptht=ptht(:,:,i),                                                  &
                        prvt=prt(:,:,1,i), prct=prt(:,:,2,i), prrt=prt(:,:,3,i),           &
                        prit=prt(:,:,4,i), prst=prt(:,:,5,i), prgt=prt(:,:,6,i),           &
                        pths=pths(:,:,i),                                                  &
                        prvs=prs(:,:,1,i), prcs=prs(:,:,2,i), prrs=prs(:,:,3,i),           &
                        pris=prs(:,:,4,i), prss=prs(:,:,5,i), prgs=prs(:,:,6,i),           &
                        pinprc=zinprc(:,i), pinprr=pinprr(:,i), pevap3d=pevap(:,:,i),      &
                        pinprs=pinprs(:,i), pinprg=pinprg(:,i), psigs=psigs(:,:,i),        &
                        psea=psea(:,i), ptown=ptown(:,i),                                  &
                        TBUDGETS=YLBUDGET, KBUDGETS=SIZE(YLBUDGET),                        &
                        picenu=picenu(:,i),                                                &
                        pkgn_acon=pkgn_acon(:,i), pkgn_sbgr=pkgn_sbgr(:,i),                &
                        pfpr=pfpr(:,:,:,i))

    endif

  enddo

  call cpu_time(time_end_cpu)
  call system_clock(count=counter, count_rate=c_rate)
  time_end_real = real(counter,8)/c_rate

  write(output_unit, *)

  write(output_unit, *) 'Total time: ', time_end_real - time_start_real

  write(output_unit, *)

  write(output_unit, *) 'PEVAP'
  call print_diff_2(pevap(:,:,1), pevap_out(:,:,1))
  write(output_unit, *)

  write(output_unit, *) 'ZINPRC'
  call print_diff_1(zinprc(:,1), zinprc_out(:,1))
  write(output_unit, *)

  write(output_unit, *) 'PINPRR'
  call print_diff_1(pinprr(:,1), pinprr_out(:,1))
  write(output_unit, *)

  write(output_unit, *) 'PINPRS'
  call print_diff_1(pinprs(:,1), pinprs_out(:,1))
  write(output_unit, *)

  write(output_unit, *) 'PINPRG'
  call print_diff_1(pinprg(:,1), pinprg_out(:,1))
  write(output_unit, *)

  write(output_unit, *) 'PTHS'
  call print_diff_2(pths(:,:,1), pths_out(:,:,1))
  write(output_unit, *)

  write(output_unit, *) 'PCIT'
  call print_diff_2(pcit(:,:,1), pcit_out(:,:,1))
  write(output_unit, *)

  write(output_unit, *) 'PRVS'
  call print_diff_2(prs(:,:,1,1), prs_out(:,:,1,1))
  write(output_unit, *)

  write(output_unit, *) 'PRCS'
  call print_diff_2(prs(:,:,2,1), prs_out(:,:,2,1))
  write(output_unit, *)

  write(output_unit, *) 'PRRS'
  call print_diff_2(prs(:,:,3,1), prs_out(:,:,3,1))
  write(output_unit, *)

  write(output_unit, *) 'PRIS'
  call print_diff_2(prs(:,:,4,1), prs_out(:,:,4,1))
  write(output_unit, *)

  write(output_unit, *) 'PRSS'
  call print_diff_2(prs(:,:,5,1), prs_out(:,:,5,1))
  write(output_unit, *)

  write(output_unit, *) 'PRGS'
  call print_diff_2(prs(:,:,6,1), prs_out(:,:,6,1))
  write(output_unit, *)

  write(output_unit, *) 'PFPR 2'
  call print_diff_2(pfpr(:,:,2,1), pfpr_out(:,:,2,1))
  write(output_unit, *)

  write(output_unit, *) 'PFPR 3'
  call print_diff_2(pfpr(:,:,3,1), pfpr_out(:,:,3,1))
  write(output_unit, *)

  write(output_unit, *) 'PFPR 4'
  call print_diff_2(pfpr(:,:,4,1), pfpr_out(:,:,4,1))
  write(output_unit, *)

  write(output_unit, *) 'PFPR 5'
  call print_diff_2(pfpr(:,:,5,1), pfpr_out(:,:,5,1))
  write(output_unit, *)

  write(output_unit, *) 'PFPR 6'
  call print_diff_2(pfpr(:,:,6,1), pfpr_out(:,:,6,1))
  write(output_unit, *)

end program

subroutine init_rain_ice_old(kulout)

  use modd_param_ice_n,      only: param_ice_goto_model
  use modd_rain_ice_param_n, only: rain_ice_param_goto_model
  use modd_rain_ice_descr_n, only: rain_ice_descr_goto_model
  use modd_cloudpar_n,       only: cloudpar_goto_model
  use modd_param_ice_n

  use mode_ini_rain_ice

  use mode_ini_cst
  use mode_ini_tiwmx
  use modd_budget
  use modd_les, only: tles

  use iso_fortran_env, only: output_unit

  implicit none

  integer, intent (in) :: kulout

  character(len=4) :: c_micro
  integer :: isplitr

  call ini_cst

  call ini_tiwmx

  call cloudpar_goto_model(1, 1)
  call param_ice_goto_model(1, 1)
  call rain_ice_descr_goto_model(1, 1)
  call rain_ice_param_goto_model(1, 1)

  call param_icen_init('AROME', 0, .false., kulout, &                                                                 
                      &.true., .false., .false., 0)

  call tbuconf_associate

  lbu_enable=.false.
  lbudget_u=.false.
  lbudget_v=.false.
  lbudget_w=.false.
  lbudget_th=.false.
  lbudget_tke=.false.
  lbudget_rv=.false.
  lbudget_rc=.false.
  lbudget_rr=.false.
  lbudget_ri=.false.
  lbudget_rs=.false.
  lbudget_rg=.false.
  lbudget_rh=.false.
  lbudget_sv=.false.
  tles%lles_call = .false.

  ! 1. set implicit default values for modd_param_ice
  cpristine_ice = 'PLAT'
  csubg_rc_rr_accr = 'NONE'
  csubg_rr_evap = 'NONE'
  csubg_pr_pdf = 'SIGM'
  c_micro = 'ICE3'

  ! 2. set implicit default values for modd_rain_ice_descr and modd_rain_ice_param

  call ini_rain_ice(kulout, 50., 20., isplitr, c_micro)

end subroutine init_rain_ice_old


subroutine init_gmicro(D, krr, n_gp_blocks, odmicro, prt, pssio, ocnd2, prht)

  use modd_dimphyex, only: dimphyex_t
  use modd_rain_ice_descr_n, only: xrtmin
  use modd_rain_ice_param_n, only: xfrmin
  use iso_fortran_env, only: output_unit

  implicit none

  type(dimphyex_t) :: D

  integer, intent(in) :: krr, n_gp_blocks
  logical, dimension(D%nit, D%nkt, n_gp_blocks), intent(inout) :: odmicro

  real, dimension(D%nit, D%nkt, krr, n_gp_blocks), intent(in) :: prt
  real, dimension(D%nit, D%nkt, n_gp_blocks), intent(in) :: pssio
  real, dimension(D%nit, D%nkt, n_gp_blocks), optional, intent(in) :: prht

  logical, intent(in) :: ocnd2

  integer :: i, k, ikrr, iblock

  if (ocnd2) then

    do iblock = 1, n_gp_blocks

      do k = 1, D%nkt
        do i = 1, D%nit
          odmicro(i, k, iblock) = odmicro(i, k, iblock) .or. pssio(i, k, iblock) > xfrmin(12)
        enddo
      enddo

      do ikrr = 2, 6
        do k = 1, D%nkt
          do i = 1, D%nit
            odmicro(i, k, iblock) = odmicro(i, k, iblock) .or. prt(i, k, ikrr, iblock) > xfrmin(13)
          enddo
        enddo
      enddo

      if (krr == 7) then
        do k = 1, D%nkt
          do i = 1, D%nit
            odmicro(i, k, iblock) = odmicro(i, k, iblock) .or. prht(i, k, iblock) > xfrmin(13)
          enddo
        enddo
      endif

    enddo

  else

    do iblock = 1, n_gp_blocks
      do ikrr = 2, 6
        do k = 1, D%nkt
          do i = 1, D%nit
            odmicro(i, k, iblock) = odmicro(i, k, iblock) .or. prt(i, k, ikrr, iblock) > xrtmin(ikrr)
          enddo
        enddo
      enddo
    enddo

    if (krr == 7) then
      do k = 1, D%nkt
        do i = 1, D%nit
          odmicro(i, k, iblock) = odmicro(i, k, iblock) .or. prht(i, k, iblock) > xrtmin(7)
        enddo
      enddo
    endif

  endif

end subroutine init_gmicro


subroutine print_diff_1(array, ref)

  use iso_fortran_env, only: output_unit

  implicit none

  real, intent(in), dimension(:) :: array
  real, intent(in), dimension(:) :: ref

  real, parameter :: threshold = 1.0e-12

  integer :: i

  real :: absval

  do i = 1, size(array, 1)
    absval = max(abs(array(i)), abs(ref(i)))
    if (absval .gt. 0.) then
      if (abs(array(i) - ref(i))/absval .gt. threshold) then
        write(output_unit, '(1i4, 4e16.6)') i, array(i), ref(i), abs(array(i) - ref(i)), abs(array(i) - ref(i))/absval 
      endif
    endif
  enddo

end subroutine print_diff_1


subroutine print_diff_2(array, ref)

  use iso_fortran_env, only: output_unit

  implicit none

  real, intent(in), dimension(:,:) :: array
  real, intent(in), dimension(:,:) :: ref

  real, parameter :: threshold = 1.0e-12

  integer :: i, j

  real :: absval

  do j = 1, size(array, 2)
    do i = 1, size(array, 1)
      absval = max(abs(array(i,j)), abs(ref(i,j)))
      if (absval .gt. 0.) then
        if (abs(array(i,j) - ref(i,j))/absval .gt. threshold) then
          write(output_unit, '(2i4, 4e22.14)') i, j, array(i,j), ref(i,j), abs(array(i,j) - ref(i,j)), abs(array(i,j) - ref(i,j))/absval 
        endif
      endif
    enddo
 enddo

end subroutine print_diff_2


