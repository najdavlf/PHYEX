INTERFACE
 SUBROUTINE ARO_ADJUST(KLON,KIDIA,KFDIA,KLEV, KRR,&
 & HFRAC_ICE, HCONDENS, HLAMBDA3, OSUBG_COND, &
 & OSIGMAS, CMICRO, OCND2, LHGT_QS, HSUBG_MF_PDF,&
 & PTSTEP, PSIGQSAT, PZZF, PRHODJ, PEXNREF, PRHODREF,&
 & PPABSM, PTHT, PRT, PSIGS,&
 & PMFCONV, PRC_MF, PRI_MF, PCF_MF,&
 & PTHS, PRS, PSRCS, PCLDFR, &
 & PICLDFR, PWCLDFR, PSSIO, PSSIU, PIFR,&
 & PHLC_HRC, PHLC_HCF, PHLI_HRI, PHLI_HCF, &
 & YDDDH,YDLDDH,YDMDDH,&
 & YSPP_PSIGQSAT,YSPP_ICE_CLD_WGT)
USE PARKIND1  ,ONLY : JPIM     ,JPRB
USE SPP_MOD_TYPE, ONLY : TSPP_CONFIG_TYPE
USE DDH_MIX, ONLY : TYP_DDH
USE YOMLDDH, ONLY : TLDDH
USE YOMMDDH, ONLY : TMDDH
INTEGER(KIND=JPIM), INTENT(IN) :: KLON
INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
INTEGER(KIND=JPIM), INTENT(IN) :: KRR
CHARACTER*1, INTENT(IN) :: HFRAC_ICE
CHARACTER(LEN=80), INTENT(IN) :: HCONDENS
CHARACTER*4, INTENT(IN) :: HLAMBDA3
LOGICAL, INTENT(IN) :: OSUBG_COND
LOGICAL, INTENT(IN) :: OSIGMAS
CHARACTER(LEN=4), INTENT(IN) :: CMICRO
LOGICAL, INTENT(IN) :: OCND2
LOGICAL, INTENT(IN) :: LHGT_QS
CHARACTER(LEN=80), INTENT(IN) :: HSUBG_MF_PDF
REAL(KIND=JPRB), INTENT(IN) :: PTSTEP
REAL(KIND=JPRB), INTENT(IN) :: PSIGQSAT
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(IN) :: PZZF
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(IN) :: PRHODJ
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(IN) :: PEXNREF
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(IN) :: PRHODREF
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(IN) :: PPABSM
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(IN) :: PTHT
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV,KRR), INTENT(INOUT) :: PRT
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(IN) :: PSIGS
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(IN) :: PMFCONV
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(IN) :: PRC_MF,PRI_MF,PCF_MF
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(INOUT) :: PTHS
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV,KRR), INTENT(INOUT) :: PRS
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(OUT) :: PSRCS
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(INOUT) :: PCLDFR
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(OUT)  :: PICLDFR 
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(OUT)  :: PWCLDFR
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(OUT)  :: PSSIO 
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(OUT)  :: PSSIU
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(OUT)  :: PIFR
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(OUT) :: PHLC_HRC
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(OUT) :: PHLC_HCF
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(OUT) :: PHLI_HRI
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(OUT) :: PHLI_HCF
TYPE(TYP_DDH)                          , INTENT(INOUT) :: YDDDH
TYPE(TLDDH)                          , INTENT(IN) :: YDLDDH
TYPE(TMDDH)                          , INTENT(IN) :: YDMDDH
TYPE(TSPP_CONFIG_TYPE), INTENT(INOUT) :: YSPP_PSIGQSAT,YSPP_ICE_CLD_WGT
END SUBROUTINE ARO_ADJUST
END INTERFACE
