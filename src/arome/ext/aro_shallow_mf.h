INTERFACE
 SUBROUTINE ARO_SHALLOW_MF(KKL, KLON,KLEV, KRR, KRRL, KRRI,KSV,&
 & HMF_UPDRAFT, HMF_CLOUD, HFRAC_ICE, OMIXUV,&
 & ONOMIXLG,KSV_LGBEG,KSV_LGEND,&
 & KTCOUNT, PTSTEP,&
 & PZZ, PZZF,PDZZF,&
 & PRHODJ, PRHODREF,&
 & PPABSM, PEXNM,&
 & PSFTH,PSFRV,&
 & PTHM,PRM,&
 & PUM,PVM,PTKEM,PSVM,&
 & PDUDT_MF,PDVDT_MF,&
 & PDTHLDT_MF,PDRTDT_MF,PDSVDT_MF,&
 & PSIGMF,PRC_MF,PRI_MF,PCF_MF,PFLXZTHVMF,&
 & PTHL_UP,PRT_UP,PRV_UP,PRC_UP,PRI_UP,&
 & PU_UP, PV_UP, PTHV_UP, PW_UP, PFRAC_UP, PEMF) 
USE PARKIND1  ,ONLY : JPIM     ,JPRB
INTEGER(KIND=JPIM), INTENT(IN) :: KKL
INTEGER(KIND=JPIM), INTENT(IN) :: KLON
INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
INTEGER(KIND=JPIM), INTENT(IN) :: KRR
INTEGER(KIND=JPIM), INTENT(IN) :: KRRL
INTEGER(KIND=JPIM), INTENT(IN) :: KRRI
INTEGER(KIND=JPIM), INTENT(IN) :: KSV
CHARACTER (LEN=4), INTENT(IN) :: HMF_UPDRAFT
CHARACTER (LEN=4), INTENT(IN) :: HMF_CLOUD
CHARACTER*1, INTENT(IN) :: HFRAC_ICE
LOGICAL, INTENT(IN) :: OMIXUV
LOGICAL, INTENT(IN) :: ONOMIXLG
INTEGER(KIND=JPIM), INTENT(IN) :: KSV_LGBEG
INTEGER(KIND=JPIM), INTENT(IN) :: KSV_LGEND
INTEGER(KIND=JPIM), INTENT(IN) :: KTCOUNT
REAL(KIND=JPRB), INTENT(IN) :: PTSTEP
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(IN) :: PZZ
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(IN) :: PZZF
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(IN) :: PDZZF
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(IN) :: PRHODJ
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(IN) :: PRHODREF
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(IN) :: PPABSM
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(IN) :: PEXNM
REAL(KIND=JPRB), DIMENSION(KLON), INTENT(IN) :: PSFTH,PSFRV
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(IN) :: PTHM
REAL(KIND=JPRB), DIMENSION(KLON,KLEV,KRR), INTENT(IN) :: PRM
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(IN) :: PUM,PVM
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(IN) :: PTKEM
REAL(KIND=JPRB), DIMENSION(KLON,KLEV,KSV), INTENT(IN) :: PSVM
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(OUT):: PDUDT_MF
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(OUT):: PDVDT_MF
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(OUT):: PDTHLDT_MF
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(OUT):: PDRTDT_MF
REAL(KIND=JPRB), DIMENSION(KLON,KLEV,KSV), INTENT(OUT):: PDSVDT_MF
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(OUT) :: PSIGMF,PRC_MF,PRI_MF,PCF_MF
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(OUT) :: PFLXZTHVMF
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(INOUT) :: PTHL_UP
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(INOUT) :: PRT_UP
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(INOUT) :: PRV_UP
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(INOUT) :: PU_UP
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(INOUT) :: PV_UP
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(INOUT) :: PRC_UP
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(INOUT) :: PRI_UP
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(INOUT) :: PTHV_UP
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(INOUT) :: PW_UP
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(INOUT) :: PFRAC_UP
REAL(KIND=JPRB), DIMENSION(KLON,KLEV), INTENT(INOUT) :: PEMF
END SUBROUTINE ARO_SHALLOW_MF
END INTERFACE