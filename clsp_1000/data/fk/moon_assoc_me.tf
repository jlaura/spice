KPL/FK

\beginlabel
PDS_VERSION_ID               = PDS3
RECORD_TYPE                  = STREAM
RECORD_BYTES                 = "N/A"
^SPICE_KERNEL                = "moon_assoc_me.tf"
MISSION_NAME                 = "DEEP SPACE PROGRAM SCIENCE EXPERIMENT"
SPACECRAFT_NAME              = "CLEMENTINE 1"
DATA_SET_ID                  = "CLEM1-L-SPICE-6-V1.0"
KERNEL_TYPE_ID               = FK
PRODUCT_ID                   = "moon_assoc_me.tf"
PRODUCT_CREATION_TIME        = 2007-06-13T12:27:01
PRODUCER_ID                  = "NAIF/JPL"
MISSION_PHASE_NAME           = "N/A"
PRODUCT_VERSION_TYPE         = ACTUAL
PLATFORM_OR_MOUNTING_NAME    = "N/A"
START_TIME                   = "N/A"
STOP_TIME                    = "N/A"
SPACECRAFT_CLOCK_START_COUNT = "N/A"
SPACECRAFT_CLOCK_STOP_COUNT  = "N/A"
TARGET_NAME                  = MOON
INSTRUMENT_NAME              = "N/A"
NAIF_INSTRUMENT_ID           = "N/A"
SOURCE_PRODUCT_ID            = "N/A"
NOTE                         = "See comments in the file for details"
OBJECT                       = SPICE_KERNEL
  INTERCHANGE_FORMAT         = ASCII
  KERNEL_TYPE                = FRAMES
  DESCRIPTION                = "Generic Lunar SPICE FK file directing the
SPICE system to associate the lunar ``mean Earth'' reference frame, MOON_ME,
with the Moon, created by NAIF, JPL. "
END_OBJECT                   = SPICE_KERNEL
\endlabel


   SPICE Lunar ME Reference Frame/Body Association  Kernel
   =====================================================================

   Original file name:                   moon_assoc_me.tf
   Creation date:                        2007 February 13 17:24
   Created by:                           Nat Bachman  (NAIF/JPL)


   Overview
   =====================================================================

   In the SPICE system, the default body-fixed reference frame
   associated with the Moon is named

       IAU_MOON

   The IAU_MOON reference frame is implemented via approximate formulas
   provided by the IAU report [1] and is not suitable for high-accuracy
   work.

   This kernel directs the SPICE system to associate the lunar "mean
   Earth" reference frame

      MOON_ME

   with the Moon. 

   When this kernel is loaded via FURNSH, the SPICE frame system
   routines CNMFRM and CIDFRM, which identify the reference frame
   associated with a specified body, will indicate that the MOON_ME
   frame is associated with the Moon.  In addition, higher-level SPICE
   geometry routines that rely on the CNMFRM or CIDFRM routines will
   use the MOON_ME frame where applicable. As of the release date of
   this kernel, these SPICE routines are:

      ET2LST
      ILLUM
      SRFXPT
      SUBPT
      SUBSOL

   Finally, any code that calls these routines to obtain results
   involving lunar body-fixed frames are affected.  Within SPICE, the
   only higher-level system that is affected is the dynamic frame
   system.

   Note:  to direct SPICE to associate the lunar principal axis frame 

      MOON_PA

   with the Moon, load the kernel

      moon_assoc_pa.tf

   rather than this one.



   Using this kernel
   =====================================================================

   This kernel must be loaded together with a lunar frame specification
   kernel and a binary lunar PCK.  Below an example meta-kernel that
   loads these files and a small program illustrating use of the kernel
   are shown. The names of the kernels used here are current as of the
   release date of this kernel, but should not be assumed to current at
   later dates.


      Example meta-kernel
      -------------------

      To use the meta-kernel shown below, the '@' characters must be
      replaced with backslash '\' characters.  Backslashes cannot be
      used in this comment block because they would confuse the SPICE
      text kernel parser.


         KPL/FK

         @begintext

             Kernels to load are:

                Lunar kernels
                -------------
                Binary lunar PCK:          moon_pa_de403_1950-2198.bpc
                Lunar FK:                  moon_060721.tf
                Frame association kernel:  moon_assoc_me.tf

                Additional kernels to support sub-point computation
                ---------------------------------------------------
                Text PCK for lunar radii:  pck00008.tpc

                Leapseconds kernel (for
                time conversion):          naif0008.tls

                Planetary ephemeris (for
                sub-Earth computation):    de414.bsp

         @begindata

         KERNELS_TO_LOAD = ( 'moon_pa_de403_1950-2198.bpc'
                             'moon_060721.tf'
                             'moon_assoc_me.tf'    
                             'pck00008.tpc'
                             'naif0008.tls'         
                             'de414.bsp'                   )
         @begintext

         End of kernel



      Example code
      ------------

      Find the geometric (without light time and stellar aberration
      corrections) sub-Earth point on the Moon at a given UTC time,
      using the MOON_ME reference frame.  Display the name of the
      body-fixed lunar frame used for the computation.


             PROGRAM EX
             IMPLICIT NONE

             DOUBLE PRECISION      DPR

             INTEGER               FILEN 
             PARAMETER           ( FILEN  = 255 )

             INTEGER               FRNMLN
             PARAMETER           ( FRNMLN = 32 )

             INTEGER               TIMLEN
             PARAMETER           ( TIMLEN = 50 )

             CHARACTER*(FRNMLN)    FRNAME
             CHARACTER*(FILEN)     META
             CHARACTER*(TIMLEN)    TIMSTR

             DOUBLE PRECISION      ALT
             DOUBLE PRECISION      ET
             DOUBLE PRECISION      LAT
             DOUBLE PRECISION      LON
             DOUBLE PRECISION      RADIUS
             DOUBLE PRECISION      SPOINT ( 3 )

             INTEGER               FRCODE

             LOGICAL               FOUND

       C
       C     Obtain name of meta-kernel; load kernel.
       C
             CALL PROMPT ( 'Enter meta-kernel name > ', META   )
             CALL FURNSH ( META )

       C
       C     Obtain input time and convert to seconds past J2000 TDB.
       C
             CALL PROMPT ( 'Enter observation time > ', TIMSTR )
             CALL STR2ET ( TIMSTR, ET )

       C
       C     Find the closest point on the Moon to the center
       C     of the Earth at ET.
       C
             CALL SUBPT  ( 'Near point',  'MOON',  ET,  'NONE', 
            .              'EARTH',       SPOINT,  ALT          )
            .               
       C
       C     Express the sub-observer point in latitudinal
       C     coordinates.
       C
             CALL RECLAT ( SPOINT, RADIUS, LON, LAT )

       C
       C     Look up the name of the lunar body-fixed frame.
       C     
             CALL CNMFRM ( 'MOON', FRCODE, FRNAME, FOUND )

       C
       C     Always check the "found" flag.  Signal an error if we
       C     don't find a frame name.
       C
             IF ( .NOT. FOUND ) THEN
                CALL SETMSG ( 'No body-fixed frame found for the Moon.' )
                CALL SIGERR ( 'SPICE(NOFRAME)'                          )
             END IF

             WRITE(*,*) 'Lunar body-fixed frame is ', FRNAME
             WRITE(*,*) 'Sub-Earth planetocentric longitude (deg):', 
            .            LON*DPR()
             WRITE(*,*) 'Sub-Earth planetocentric latitude  (deg):',
            .            LAT*DPR()
             END


      Example program output
      ----------------------

      Numeric results and output formatting shown below should be
      expected to differ somewhat across different computing platforms.

      When the above example program is run using the example meta-kernel,
      and the (arbitrary) date 2007 Feb 13 00:00:00 UTC is used
      as the observation time, the output will be:

         Lunar body-fixed frame is MOON_ME
         Sub-Earth planetocentric longitude (deg): -6.73726142
         Sub-Earth planetocentric latitude  (deg):  6.75680538



   References
   =====================================================================
   [1]   Seidelmann, P.K., Abalakin, V.K., Bursa, M., Davies, M.E.,
         Bergh, C. de, Lieske, J.H., Oberst, J., Simon, J.L.,
         Standish, E.M., Stooke, P., and Thomas, P.C. (2002).
         "Report of the IAU/IAG Working Group on Cartographic
         Coordinates and Rotational Elements of the Planets and
         Satellites: 2000," Celestial Mechanics and Dynamical
         Astronomy, v.82, Issue 1, pp. 83-111.



   Data
   =====================================================================

   The assignment below directs the SPICE system to associate the MOON_ME 
   reference frame with the Moon.

   For further information, see the Frames Required Reading section
   titled "Connecting an Object to its Body-fixed Frame."

   \begindata

      OBJECT_MOON_FRAME =  'MOON_ME'

   \begintext


   End of kernel
   =====================================================================


