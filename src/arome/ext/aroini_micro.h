INTERFACE
SUBROUTINE AROINI_MICRO(KULOUT,PTSTEP,LDWARM,CMICRO,KSPLITR,CCSEDIM,LDCRIAUTI,&
 &         PCRIAUTI,PT0CRIAUTI,PCRIAUTC,PTSTEP_TS,CCSNOWRIMING, PMRSTEP,KMAXITER,&
 &         LDFEEDBACKT, LDEVLIMIT, LDNULLWETG, LDWETGPOST, LDNULLWETH, LDWETHPOST, &
 &         PFRACM90, LDCONVHG, CCSUBG_RC_RR_ACCR, CCSUBG_RR_EVAP, CCSUBG_PR_PDF, &
 &         LDCRFLIMIT, CCFRAC_ICE_ADJUST, PSPLIT_MAXCFL,&
 &         CCFRAC_ICE_SHALLOW_MF, LDSEDIC_AFTER,LDDEPOSC, PVDEPOSC, PFRMIN,&
 &         LDDEPSG,PRDEPSRED,PRDEPGRED)
USE PARKIND1  ,ONLY : JPIM     ,JPRB
INTEGER(KIND=JPIM), INTENT (IN) :: KULOUT
REAL(KIND=JPRB), INTENT (IN) :: PTSTEP
LOGICAL, INTENT (IN) :: LDWARM
CHARACTER (LEN=4), INTENT (IN) :: CMICRO
CHARACTER(4), INTENT (IN) :: CCSEDIM
INTEGER(KIND=JPIM), INTENT (OUT) :: KSPLITR
LOGICAL, INTENT (IN) :: LDCRIAUTI
REAL(KIND=JPRB), INTENT (IN) :: PCRIAUTI
REAL(KIND=JPRB), INTENT (IN) :: PT0CRIAUTI
REAL(KIND=JPRB), INTENT (IN) :: PCRIAUTC
REAL(KIND=JPRB), INTENT (IN) :: PTSTEP_TS
CHARACTER(4), INTENT (IN) :: CCSNOWRIMING
REAL(KIND=JPRB), INTENT (IN) :: PMRSTEP
INTEGER(KIND=JPIM), INTENT (IN) :: KMAXITER
LOGICAL, INTENT (IN) :: LDFEEDBACKT
LOGICAL, INTENT (IN) :: LDEVLIMIT
LOGICAL, INTENT (IN) :: LDNULLWETG
LOGICAL, INTENT (IN) :: LDWETGPOST
LOGICAL, INTENT (IN) :: LDNULLWETH
LOGICAL, INTENT (IN) :: LDWETHPOST
REAL(KIND=JPRB), INTENT (IN) :: PFRACM90
LOGICAL, INTENT (IN) :: LDCONVHG
CHARACTER(LEN=80), INTENT(IN) :: CCSUBG_RC_RR_ACCR
CHARACTER(LEN=80), INTENT(IN) :: CCSUBG_RR_EVAP
CHARACTER(LEN=80), INTENT(IN) :: CCSUBG_PR_PDF
LOGICAL, INTENT (IN) :: LDCRFLIMIT
CHARACTER(LEN=1), INTENT(IN) :: CCFRAC_ICE_ADJUST
REAL(KIND=JPRB), INTENT (IN) :: PSPLIT_MAXCFL
CHARACTER(LEN=1), INTENT(IN) :: CCFRAC_ICE_SHALLOW_MF
LOGICAL, INTENT (IN) :: LDSEDIC_AFTER
LOGICAL, INTENT (IN) :: LDDEPOSC
REAL(KIND=JPRB), INTENT (IN) :: PVDEPOSC
REAL(KIND=JPRB), OPTIONAL, INTENT (IN) :: PFRMIN(40)
LOGICAL, INTENT (IN) :: LDDEPSG
REAL(KIND=JPRB), INTENT (IN) :: PRDEPSRED, PRDEPGRED
END SUBROUTINE AROINI_MICRO
END INTERFACE