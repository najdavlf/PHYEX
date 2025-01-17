MODULE MODE_POSNAM_PHY
IMPLICIT NONE
PRIVATE
PUBLIC :: POSNAM_PHY
CONTAINS
SUBROUTINE POSNAM_PHY(KULNAM, CDNAML, LDNEEDNAM, LDFOUND, KLUOUT)

!Wrapper to call the Meso-NH version of posnam

USE MODE_MSG, ONLY: NVERB_FATAL, PRINT_MSG
USE MODE_POS, ONLY: POSNAM

IMPLICIT NONE

INTEGER,          INTENT(IN)    :: KULNAM    !< Logical unit to access the namelist
CHARACTER(LEN=*), INTENT(IN)    :: CDNAML    !< Namelist name
LOGICAL,          INTENT(IN)    :: LDNEEDNAM !< True to abort if namelist is absent
LOGICAL,          INTENT(OUT)   :: LDFOUND   !< True if namelist has been found
INTEGER,          INTENT(IN)    :: KLUOUT    !< Logical unit for output

CALL POSNAM(KULNAM, CDNAML, LDFOUND, KLUOUT)
IF(LDNEEDNAM .AND. .NOT. LDFOUND) CALL PRINT_MSG(NVERB_FATAL, 'GEN', 'POSNAM_PHY', 'CANNOT LOCATE '//CDNAML)

END SUBROUTINE POSNAM_PHY

END MODULE MODE_POSNAM_PHY
