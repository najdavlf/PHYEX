!MNH_LIC Copyright 1994-2023 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!!    MODIFICATIONS
!!    -------------
!!      06/12 (Tomasini) Grid-nesting of ADVFRC and EDDY_FLUX
!!      07/13 (Bosseur & Filippi) adds Forefire
!!      2014 (Faivre)
!!      2016  (Leriche) Add MODD_CH_ICE Suppress MODD_CH_DEP_n
!!      Modification    01/2016  (JP Pinty) Add LIMA
!!  10/2016     (F Brosse) Add prod/loss terms computation for chemistry 
!!                      07/2017 (M.Leriche) Add DIAG chimical surface fluxes
!                   02/2018 Q.Libois ECRAD
!!  Philippe Wautelet: 05/2016-04/2018: new data structures and calls for I/O
!                  2017 V.Vionnet blow snow
!                  11/2019 C.Lac correction in the drag formula and application to building in addition to tree
!  F. Auguste     02/21: add IBM
!  T. Nagel       02/21: add turbulence recycling
!  P. Wautelet 27/04/2022: add namelist for profilers
!  P. Wautelet 10/02/2023: add Blaze variables
!-----------------------------------------------------------------
MODULE MODI_GOTO_MODEL_WRAPPER

INTERFACE 
SUBROUTINE GOTO_MODEL_WRAPPER(KFROM, KTO, ONOFIELDLIST)
INTEGER,           INTENT(IN) :: KFROM, KTO
LOGICAL, OPTIONAL, INTENT(IN) :: ONOFIELDLIST
END SUBROUTINE GOTO_MODEL_WRAPPER
END INTERFACE

END MODULE MODI_GOTO_MODEL_WRAPPER

SUBROUTINE GOTO_MODEL_WRAPPER(KFROM, KTO, ONOFIELDLIST)
! all USE modd*_n modules
USE MODD_ADVFRC_n
USE MODD_ADV_n
USE MODD_ALLPROFILER_n
USE MODD_ALLSTATION_n
USE MODD_BIKHARDT_n
USE MODD_BLANK_n
USE MODD_BLOWSNOW_n
USE MODD_CH_AERO_n
USE MODD_CH_BUDGET_n
USE MODD_CH_FLX_n
USE MODD_CH_ICE_n
USE MODD_CH_JVALUES_n
USE MODD_CH_M9_n
USE MODD_CH_MNHC_n
USE MODD_CH_PH_n
USE MODD_CH_PRODLOSSTOT_n
USE MODD_CH_ROSENBROCK_n
USE MODD_CH_SOLVER_n
USE MODD_CLOUDPAR_n
USE MODD_PARAM_ICE_n
USE MODD_PARAM_LIMA, ONLY: PARAM_LIMA_ASSOCIATE !not yet a '_n' module
USE MODD_RAIN_ICE_PARAM_n
USE MODD_RAIN_ICE_DESCR_n
USE MODD_CLOUD_MF_n
USE MODD_CONF_n
USE MODD_CURVCOR_n
USE MODD_DIM_n
USE MODD_DRAG_n
USE MODD_DRAGTREE_n
USE MODD_DRAGBLDG_n
USE MODD_DUMMY_GR_FIELD_n
USE MODD_DYN_n
USE MODD_DYNZD_n
USE MODD_ELEC_n
USE MODD_FIELD_n
USE MODD_FIRE_n
#ifdef MNH_FOREFIRE
USE MODD_FOREFIRE_n
#endif
USE MODD_FRC_n
USE MODD_GET_n
USE MODD_GR_FIELD_n
USE MODD_IBM_LSF
USE MODD_IBM_PARAM_n
USE MODD_IO_SURF_MNH
USE MODD_LBC_n
USE MODD_LES_n
USE MODD_LSFIELD_n
USE MODD_LUNIT_n
USE MODD_MEAN_FIELD_n
USE MODD_METRICS_n
USE MODD_NEST_PGD_n
USE MODD_NUDGING_n
USE MODD_OUT_n
USE MODD_PACK_GR_FIELD_n
USE MODD_PARAM_KAFR_n
USE MODD_PARAM_MFSHALL_n
USE MODD_PARAM_n
USE MODD_PARAM_RAD_n
USE MODD_PARAM_ECRAD_n
USE MODD_PASPOL_n
USE MODD_PAST_FIELD_n
USE MODD_PRECIP_n
USE MODD_PROFILER_n
USE MODD_RADIATIONS_n
USE MODD_RBK90_Global_n
USE MODD_RBK90_JacobianSP_n
USE MODD_RBK90_Parameters_n
USE MODD_RECYCL_PARAM_n
USE MODD_REF_n
USE MODD_RELFRC_n
USE MODD_SECPGD_FIELD_n
USE MODD_SERIES_n
USE MODD_SHADOWS_n
USE MODD_STATION_n
USE MODD_SUB_CH_FIELD_VALUE_n
USE MODD_SUB_CH_MONITOR_n
USE MODD_SUB_ELEC_n
USE MODD_SUB_MODEL_n
USE MODD_SUB_PASPOL_n
USE MODD_SUB_PHYS_PARAM_n
USE MODD_TIMEZ
USE MODD_TURB_n
USE MODD_NEB_n, ONLY: NEB_GOTO_MODEL
!
!
use mode_field,             only: Fieldlist_goto_model
use mode_msg
!
!
IMPLICIT NONE 
!
INTEGER,           INTENT(IN) :: KFROM, KTO
LOGICAL, OPTIONAL, INTENT(IN) :: ONOFIELDLIST
!
CHARACTER(LEN=64) :: YMSG
LOGICAL           :: GNOFIELDLIST
!
WRITE(YMSG,'( I4,"->",I4 )') KFROM,KTO
CALL PRINT_MSG(NVERB_DEBUG,'GEN','GOTO_MODEL_WRAPPER',TRIM(YMSG))
!
IF (PRESENT(ONOFIELDLIST)) THEN
  GNOFIELDLIST = ONOFIELDLIST
ELSE
  GNOFIELDLIST = .FALSE.
END IF
!
! All calls to specific modd_*n goto_model routines
!
CALL ADV_GOTO_MODEL(KFROM, KTO)
CALL BIKHARDT_GOTO_MODEL(KFROM, KTO)
CALL BLANK_GOTO_MODEL(KFROM,KTO)
CALL CH_AERO_GOTO_MODEL(KFROM,KTO)
CALL CH_FLX_GOTO_MODEL(KFROM, KTO)
CALL CH_JVALUES_GOTO_MODEL(KFROM, KTO)
CALL CH_MNHC_GOTO_MODEL(KFROM, KTO)
CALL CH_SOLVER_GOTO_MODEL(KFROM, KTO)
CALL CLOUDPAR_GOTO_MODEL(KFROM, KTO)
CALL PARAM_ICE_GOTO_MODEL(KFROM, KTO)
CALL PARAM_LIMA_ASSOCIATE() !Not yet a goto_model but put here for simplicity and to prepare the transformation into a '_n' module
CALL RAIN_ICE_PARAM_GOTO_MODEL(KFROM, KTO)
CALL RAIN_ICE_DESCR_GOTO_MODEL(KFROM, KTO)
CALL CLOUD_MF_GOTO_MODEL(KFROM, KTO)
CALL CONF_GOTO_MODEL(KFROM, KTO)
CALL CURVCOR_GOTO_MODEL(KFROM, KTO)
!CALL DEEP_CONVECTION_GOTO_MODEL(KFROM, KTO)
CALL DIM_GOTO_MODEL(KFROM, KTO)
CALL DRAGTREE_GOTO_MODEL(KFROM, KTO)
CALL DRAGBLDG_GOTO_MODEL(KFROM, KTO)
CALL DUMMY_GR_FIELD_GOTO_MODEL(KFROM, KTO)
CALL DYN_GOTO_MODEL(KFROM, KTO)
CALL DYNZD_GOTO_MODEL(KFROM,KTO)
CALL FIELD_GOTO_MODEL(KFROM, KTO)
!CALL PAST_FIELD_GOTO_MODEL(KFROM, KTO)
CALL GET_GOTO_MODEL(KFROM, KTO)
!CALL GR_FIELD_GOTO_MODEL(KFROM, KTO)
!$20140403 add grid_conf_proj_goto_model
!CALL GRID_CONF_PROJ_GOTO_MODEL(KFROM,KTO)
!$
!CALL GRID_GOTO_MODEL(KFROM, KTO)
!CALL HURR_FIELD_GOTO_MODEL(KFROM, KTO)
!$20140403 add io_surf_mnh_goto_model!!
CALL IO_SURF_MNH_GOTO_MODEL(KFROM, KTO)
!$
CALL LBC_GOTO_MODEL(KFROM, KTO)
CALL LES_GOTO_MODEL(KFROM, KTO)
CALL LSFIELD_GOTO_MODEL(KFROM, KTO)
CALL LUNIT_GOTO_MODEL(KFROM, KTO)
CALL MEAN_FIELD_GOTO_MODEL(KFROM, KTO)
CALL METRICS_GOTO_MODEL(KFROM, KTO)
CALL NEST_PGD_GOTO_MODEL(KFROM, KTO)
CALL NUDGING_GOTO_MODEL(KFROM, KTO)
CALL OUT_GOTO_MODEL(KFROM, KTO)
CALL PACK_GR_FIELD_GOTO_MODEL(KFROM, KTO)
CALL PARAM_KAFR_GOTO_MODEL(KFROM, KTO)
CALL PARAM_MFSHALL_GOTO_MODEL(KFROM, KTO)
CALL PARAM_GOTO_MODEL(KFROM, KTO)
CALL PARAM_RAD_GOTO_MODEL(KFROM, KTO)
#ifdef MNH_ECRAD
CALL PARAM_ECRAD_GOTO_MODEL(KFROM, KTO)
#endif
CALL PASPOL_GOTO_MODEL(KFROM, KTO)
#ifdef MNH_FOREFIRE
CALL FOREFIRE_GOTO_MODEL(KFROM, KTO)
#endif
CALL FIRE_GOTO_MODEL( KFROM, KTO )
!CALL PRECIP_GOTO_MODEL(KFROM, KTO)
CALL ELEC_GOTO_MODEL(KFROM, KTO)
CALL RADIATIONS_GOTO_MODEL(KFROM, KTO)
CALL SHADOWS_GOTO_MODEL(KFROM, KTO)
CALL REF_GOTO_MODEL(KFROM, KTO)
CALL FRC_GOTO_MODEL(KFROM, KTO)
CALL SECPGD_FIELD_GOTO_MODEL(KFROM, KTO)
CALL SERIES_GOTO_MODEL(KFROM, KTO)
CALL PROFILER_GOTO_MODEL(KFROM, KTO)
CALL STATION_GOTO_MODEL(KFROM, KTO)
CALL ALLPROFILER_GOTO_MODEL(KFROM, KTO)
CALL ALLSTATION_GOTO_MODEL(KFROM, KTO)
CALL SUB_CH_FIELD_VALUE_GOTO_MODEL(KFROM, KTO)
CALL SUB_CH_MONITOR_GOTO_MODEL(KFROM, KTO)
CALL SUB_MODEL_GOTO_MODEL(KFROM, KTO)
CALL SUB_PHYS_PARAM_GOTO_MODEL(KFROM, KTO)
CALL SUB_PASPOL_GOTO_MODEL(KFROM, KTO)
CALL SUB_ELEC_GOTO_MODEL(KFROM, KTO)
!CALL TIME_GOTO_MODEL(KFROM, KTO)
CALL TURB_GOTO_MODEL(KFROM, KTO)
CALL NEB_GOTO_MODEL(KFROM, KTO)
CALL DRAG_GOTO_MODEL(KFROM, KTO)
CALL TIMEZ_GOTO_MODEL(KFROM, KTO)
CALL CH_PH_GOTO_MODEL(KFROM, KTO)
CALL CH_ICE_GOTO_MODEL(KFROM, KTO)
CALL CH_M9_GOTO_MODEL(KFROM, KTO)
CALL CH_ROSENBROCK_GOTO_MODEL(KFROM, KTO)
CALL RBK90_Global_GOTO_MODEL(KFROM, KTO)
CALL RBK90_JacobianSP_GOTO_MODEL(KFROM, KTO)
CALL RBK90_Parameters_GOTO_MODEL(KFROM, KTO)
!
!CALL LIMA_PRECIP_SCAVENGING_GOTO_MODEL(KFROM, KTO)
!
!CALL EDDY_FLUX_GOTO_MODEL(KFROM, KTO)
!CALL EDDYUV_FLUX_GOTO_MODEL(KFROM, KTO)
CALL ADVFRC_GOTO_MODEL(KFROM, KTO)
CALL RELFRC_GOTO_MODEL(KFROM, KTO)
CALL CH_PRODLOSSTOT_GOTO_MODEL(KFROM,KTO)
CALL CH_BUDGET_GOTO_MODEL(KFROM,KTO)
CALL BLOWSNOW_GOTO_MODEL(KFROM, KTO)
CALL IBM_GOTO_MODEL(KFROM, KTO)
CALL RECYCL_GOTO_MODEL(KFROM, KTO)
CALL LSF_GOTO_MODEL(KFROM, KTO)
!
IF (.NOT.GNOFIELDLIST) CALL FIELDLIST_GOTO_MODEL(KFROM, KTO)
!
END SUBROUTINE GOTO_MODEL_WRAPPER
