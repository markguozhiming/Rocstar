! *********************************************************************
! * Rocstar Simulation Suite                                          *
! * Copyright@2015, Illinois Rocstar LLC. All rights reserved.        *
! *                                                                   *
! * Illinois Rocstar LLC                                              *
! * Champaign, IL                                                     *
! * www.illinoisrocstar.com                                           *
! * sales@illinoisrocstar.com                                         *
! *                                                                   *
! * License: See LICENSE file in top level of distribution package or *
! * http://opensource.org/licenses/NCSA                               *
! *********************************************************************
! *********************************************************************
! * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,   *
! * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES   *
! * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND          *
! * NONINFRINGEMENT.  IN NO EVENT SHALL THE CONTRIBUTORS OR           *
! * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       *
! * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   *
! * Arising FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE    *
! * USE OR OTHER DEALINGS WITH THE SOFTWARE.                          *
! *********************************************************************
!******************************************************************************
!
! Purpose: treatments after solution dump to Hdf files.
!
! Description: none.
!
! Input: globalGenx = global data structure (contains name of the window)
!
! Output: none.
!
! Notes: none.
!
!******************************************************************************
!
! $Id: Fluid_postHdfOutput.F90,v 1.4 2008/12/06 08:44:00 mtcampbe Exp $
!
! Copyright: (c) 2002 by the University of Illinois
!
!******************************************************************************

SUBROUTINE Fluid_postHdfOutput( globalGenx )

  USE ModDataTypes
  USE ModRocstar, ONLY       : t_globalGenx
  USE ModGlobal, ONLY     : t_global
  USE ModDataStruct, ONLY : t_region
  USE ModError
  USE ModParameters

  IMPLICIT NONE
  INCLUDE 'comf90.h'

! ... parameters
  TYPE(t_globalGenx), POINTER  :: globalGenx
  TYPE(t_global), POINTER      :: global
  TYPE(t_region), POINTER      :: regions(:)

! ... loop variables
  INTEGER :: iReg, iStat

! ... local variables
  INTEGER :: iLev
  REAL(RFREAL) :: eps

!******************************************************************************

  global  => globalGenx%global

  regions => globalGenx%levels(1)%regions

  CALL RegisterFunction( global,'Fluid_preHdfOutput',&
  'Fluid_postHdfOutput.F90' )

! set tav from accumulated values ---------------------------------------------
! to be moved to a wrapper

  eps = 100._RFREAL*EPSILON( 1._RFREAL )

#ifdef STATS

  DO iReg=1,global%nRegionsLocal

      IF ((global%flowType==FLOW_UNSTEADY) .AND. (global%doStat==ACTIVE)) THEN
        IF (global%integrTime > eps) THEN
          IF (global%mixtNStat > 0) THEN
            DO iStat=1,global%mixtNStat

              regions(iReg)%mixt%tav(iStat,:) = &
              regions(iReg)%mixt%tav(iStat,:)*global%integrTime

            ENDDO
          ENDIF  ! mixtNstat

#ifdef TURB
          IF ((global%turbActive .EQV. .true.) .AND. (global%turbNStat > 0)) THEN
            DO iStat=1,global%turbNStat

              regions(iReg)%turb%tav(iStat,:) = &
              regions(iReg)%turb%tav(iStat,:)*global%integrTime

            ENDDO
          ENDIF  ! turbNstat
#endif

        ENDIF    ! integrTime
      ENDIF      ! unsteady and dostat

  ENDDO          ! iReg

#endif

  CALL DeregisterFunction( global )

END SUBROUTINE Fluid_postHdfOutput

!******************************************************************************
!
! RCS Revision history:
!
! $Log: Fluid_postHdfOutput.F90,v $
! Revision 1.4  2008/12/06 08:44:00  mtcampbe
! Updated license.
!
! Revision 1.3  2008/11/19 22:17:14  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.2  2006/01/07 10:19:56  wasistho
! added Rocflu treatment
!
! Revision 1.1  2005/12/08 19:58:26  wasistho
! initial import
!
!
!
!******************************************************************************







