!> \file modfields.f90
!!  Declares, allocates and initializes the 3D fields

!>
!!  Declares, allocates and initializes the 3D fields
!>


module modfields

  implicit none
  save

  ! Prognostic variables

  real, allocatable :: worksave(:)      !<   Used in POISR!
  real, allocatable :: um(:,:,:)        !<   x-component of velocity at time step t-1
  real, allocatable :: vm(:,:,:)        !<   y-component of velocity at time step t-1
  real, allocatable :: wm(:,:,:)        !<   z-component of velocity at time step t-1
  real, allocatable :: thlm(:,:,:)      !<   liq. water pot. temperature at time step t-1
  real, allocatable :: e12m(:,:,:)      !<   turb. kin. energy at time step t-1
  real, allocatable :: qtm(:,:,:)       !<   total specific humidity at time step t
  real, allocatable :: u0(:,:,:)        !<   x-component of velocity at time step t
  real, allocatable :: v0(:,:,:)        !<   y-component of velocity at time step t
  real, allocatable :: w0(:,:,:)        !<   z-component of velocity at time step t
  real, allocatable :: pres0(:,:,:)     !<   pressure at time step t
  real, allocatable :: thl0(:,:,:)      !<   liq. water pot. temperature at time step t
  real, allocatable :: thl0h(:,:,:)     !<  3d-field of theta_l at half levels for kappa scheme
  real, allocatable :: qt0h(:,:,:)      !<  3d-field of q_tot   at half levels for kappa scheme
  real, allocatable :: e120(:,:,:)      !<   turb. kin. energy at time step t
  real, allocatable :: qt0(:,:,:)       !<   total specific humidity at time step t

  real, allocatable :: up(:,:,:)        !<   tendency of um
  real, allocatable :: vp(:,:,:)        !<   tendency of vm
  real, allocatable :: wp(:,:,:)        !<   tendency of wm
  real, allocatable :: wp_store(:,:,:)  !<   tendency of wm, dummy variable for w-budget sampling
  real, allocatable :: thlp(:,:,:)      !<   tendency of thlm
  real, allocatable :: e12p(:,:,:)      !<   tendency of e12m
  real, allocatable :: qtp(:,:,:)       !<   tendency of qtm

  real, allocatable :: svm(:,:,:,:)     !<  scalar sv(n) at time step t-1
  real, allocatable :: sv0(:,:,:,:)     !<  scalar sv(n) at time step t
  real, allocatable :: svp(:,:,:,:)     !<  tendency of sv(n)

  ! Diagnostic variables
  real, allocatable :: mindist(:,:,:)   !< minimal distance of cell center to a wall
  real, allocatable :: yplus(:,:,:)     !< Yplus value of cell center

  real, allocatable :: shear(:,:,:,:)   !<   wall shear (last rank indicates the type of shear componenten (uym, uyp, etc.)

  real, allocatable :: uav(:,:,:)       !<   time-averaged u-velocity
  real, allocatable :: vav(:,:,:)       !<   time-averaged u-velocity
  real, allocatable :: wav(:,:,:)       !<   time-averaged u-velocity 
  real, allocatable :: thlav(:,:,:)     !<   time-averaged liquid temperature
  real, allocatable :: qtav(:,:,:)      !<   time-averaged specific humidity
  real, allocatable :: qlav(:,:,:)      !<   time-averaged liquid water
  real, allocatable :: presav(:,:,:)    !<   time-averaged pressure
  real, allocatable :: svav(:,:,:,:)    !<   time-averaged scalar concentration 
  real, allocatable :: viscratioav(:,:,:)    !<   time-averaged viscosity ratio; turb viscosity / molecular viscosity
  real, allocatable :: umint(:,:,:)     !<   um interpolated to cell-center
  real, allocatable :: vmint(:,:,:)     !<   vm interpolated to cell-center
  real, allocatable :: wmint(:,:,:)     !<   wm interpolated to cell-center
  real, allocatable :: thl2av(:,:,:)    !<   time-average: liquid temperature squared
  real, allocatable :: ql2av(:,:,:)    !<   time-average: liquid temperature squared
  real, allocatable :: qt2av(:,:,:)    !<   time-average: liquid temperature squared
  real, allocatable :: sv2av(:,:,:,:)   !<   time-average: scalar concentration squared
  real, allocatable :: uuav(:,:,:)      !<   time-average: u-velocity squared
  real, allocatable :: vvav(:,:,:)      !<   time-average: v-velocity squared
  real, allocatable :: wwav(:,:,:)      !<   time-average: w-velocity squared
  real, allocatable :: uvav(:,:,:)      !<   time-average: u-velocity times v-velocity
  real, allocatable :: uwav(:,:,:)      !<   time-average: u-velocity times fluctuation
  real, allocatable :: vwav(:,:,:)      !<   time-average: v-velocity times w-velocity
  real, allocatable :: thluav(:,:,:)    !<   time-average: thl times u-velocity
  real, allocatable :: thlvav(:,:,:)    !<   time-average: thl times v-velocity
  real, allocatable :: thlwav(:,:,:)    !<   time-average: thl times w-velocity
  real, allocatable :: qluav(:,:,:)    !<   time-average: ql times u-velocity
  real, allocatable :: qlvav(:,:,:)    !<   time-average: ql times v-velocity
  real, allocatable :: qlwav(:,:,:)    !<   time-average: ql times w-velocity
  real, allocatable :: qtuav(:,:,:)    !<   time-average: qt times u-velocity
  real, allocatable :: qtvav(:,:,:)    !<   time-average: qt times v-velocity
  real, allocatable :: qtwav(:,:,:)    !<   time-average: qt times w-velocity
  real, allocatable :: svuav(:,:,:,:)   !<   time-average: sv times u-velocity
  real, allocatable :: svvav(:,:,:,:)   !<   time-average: sv times v-velocity
  real, allocatable :: svwav(:,:,:,:)   !<   time-average: sv times w-velocity

  real, allocatable :: upupav(:,:,:)    !<   time-average: u'u'
  real, allocatable :: vpvpav(:,:,:)    !<   time-average: v'v'
  real, allocatable :: wpwpav(:,:,:)    !<   time-average: w'w'
  real, allocatable :: thlpthlpav(:,:,:)!<   time-average: thl'thl'
  real, allocatable :: qlpqlpav(:,:,:)  !<   time-average: ql'ql'
  real, allocatable :: qtpqtpav(:,:,:)!<   time-average: thl'thl'
  real, allocatable :: svpsvpav(:,:,:,:)!<   time-average: sv'sv'
  real, allocatable :: upvpav(:,:,:)    !<   time-average: u'v'
  real, allocatable :: upwpav(:,:,:)    !<   time-average: u'w'
  real, allocatable :: vpwpav(:,:,:)    !<   time-average: v'w'
  real, allocatable :: thlpupav(:,:,:)  !<   time-average: thl'u'
  real, allocatable :: thlpvpav(:,:,:)  !<   time-average: thl'v'
  real, allocatable :: thlpwpav(:,:,:)  !<   time-average: thl'w'
  real, allocatable :: qlpupav(:,:,:)  !<   time-average: ql'u'
  real, allocatable :: qlpvpav(:,:,:)  !<   time-average: ql'v'
  real, allocatable :: qlpwpav(:,:,:)  !<   time-average: ql'w'
  real, allocatable :: qtpupav(:,:,:)  !<   time-average: qt'u'
  real, allocatable :: qtpvpav(:,:,:)  !<   time-average: qt'v'
  real, allocatable :: qtpwpav(:,:,:)  !<   time-average: qt'w'
  real, allocatable :: svpupav(:,:,:,:) !<   time-average: sv'u'
  real, allocatable :: svpvpav(:,:,:,:) !<   time-average: sv'v'
  real, allocatable :: svpwpav(:,:,:,:) !<   time-average: sv'w'

! SGS fields
  real, allocatable :: uusgsav(:,:,:)    !<   time-average subgrid contribution (estimate)
  real, allocatable :: vvsgsav(:,:,:)    !<   time-average subgrid contribution (estimate)
  real, allocatable :: wwsgsav(:,:,:)    !<   time-average subgrid contribution (estimate)
  real, allocatable :: uwsgsav(:,:,:)    !<   time-average subgrid contribution (estimate)
  real, allocatable :: thlusgsav(:,:,:)  !<   time-average subgrid contribution (estimate)
  real, allocatable :: thlwsgsav(:,:,:)  !<   time-average subgrid contribution (estimate)
  real, allocatable :: qlusgsav(:,:,:)  !<   time-average subgrid contribution (estimate)
  real, allocatable :: qlwsgsav(:,:,:)  !<   time-average subgrid contribution (estimate)
  real, allocatable :: qtusgsav(:,:,:)  !<   time-average subgrid contribution (estimate)
  real, allocatable :: qtwsgsav(:,:,:)  !<   time-average subgrid contribution (estimate)
  real, allocatable :: svusgsav(:,:,:,:) !<   time-average subgrid contribution (estimate)
  real, allocatable :: svwsgsav(:,:,:,:) !<   time-average subgrid contribution (estimate)
  real, allocatable :: tkesgsav(:,:,:)   !<   time-average subgrid turbulence kinetic energy
  real, allocatable :: nusgsav(:,:,:)    !<   time-average subgrid viscosity

! Resolved dissipation 'terms'
  real, allocatable :: strain2av(:,:,:)  !<   <Sij*Sij> used to compute <Sij'*Sij'> = <Sij*Sij> - <S>ij*<S>ij
  real, allocatable :: disssgsav(:,:,:)  !<   mean subgrid dissipation: <nu_sgs*2.*Sij*Sij>
                                         !<   which is used for resolved dissipation = nu*2*<Sij'*Sij'> 
! TKE budget terms:
  real, allocatable :: tvmx(:,:,:)        !<   needed for viscous transport: <u*d/dxj(2*nu*S1j)>
  real, allocatable :: tvmy(:,:,:)        !<   needed for viscous transport: <v*d/dxj(2*nu*S2j)>
  real, allocatable :: tvmz(:,:,:)        !<   needed for viscous transport: <w*d/dxj(2*nu*S3j)>
  real, allocatable :: tpm (:,:,:)        !<   needed for transport by pressure fluctuations
  real, allocatable :: ttmx(:,:,:)        !<   needed for transport by turb. vel. fluctuations
  real, allocatable :: ttmy(:,:,:)        !<   needed for transport by turb. vel. fluctuations
  real, allocatable :: ttmz(:,:,:)        !<   needed for transport by turb. vel. fluctuations
  real, allocatable :: tsgsmx1(:,:,:)     !<   needed for transport by subgrid x = <u*d/dxj(2*nu_t*S1j)>
  real, allocatable :: tsgsmy1(:,:,:)     !<   needed for transport by subgrid y = <v*d/dxj(2*nu_t*S2j)>
  real, allocatable :: tsgsmz1(:,:,:)     !<   needed for transport by subgrid z = <w*d/dxj(2*nu_t*S3j)>
  real, allocatable :: tsgsmx2(:,:,:)     !<   needed for transport by subgrid x = <d/dxj(2*nu_t*S1j)>
  real, allocatable :: tsgsmy2(:,:,:)     !<   needed for transport by subgrid y = <d/dxj(2*nu_t*S2j)>
  real, allocatable :: tsgsmz2(:,:,:)     !<   needed for transport by subgrid z = <d/dxj(2*nu_t*S3j)>
! TKE budget results (written to files):
  real, allocatable :: t_vav(:,:,:)        !<   viscous transport
  real, allocatable :: t_sgsav(:,:,:)      !<   transport by subgrid
  real, allocatable :: t_pav(:,:,:)        !<   transport by pressure fluctuations
  real, allocatable :: t_tav(:,:,:)        !<   transport by by turb. vel. fluctuations
  real, allocatable :: p_tav(:,:,:)        !<   production by shear
  real, allocatable :: p_bav(:,:,:)        !<   production/destruction by buoyancy
  real, allocatable :: d_sgsav(:,:,:)      !<   dissipation by subgrid
  real, allocatable :: tkeadv(:,:,:)      !<   advection of tke 
  
  


  real, allocatable :: ql0(:,:,:)       !<   liquid water content

  real, allocatable :: thv0h(:,:,:)     !<   theta_v at half level

  real, allocatable :: whls(:)          !<   large scale vert velocity at half levels

  real, allocatable :: presf(:)         !<   hydrostatic pressure at full level
  real, allocatable :: presh(:)         !<   hydrostatic pressure at half level
  real, allocatable :: exnf(:)          !<   hydrostatic exner function at full level
  real, allocatable :: exnh(:)          !<   hydrostatic exner function at half level
  real, allocatable :: thvf(:)          !<   hydrostatic exner function at full level
  real, allocatable :: thvh(:)          !<   hydrostatic exner function at half level
  real, allocatable :: rhof(:)          !<   slab averaged density at full level
  real, allocatable :: qt0av(:)         !<   slab averaged q_tot
  real, allocatable :: ql0av(:)         !<   slab averaged q_liq

  real, allocatable :: thl0av(:)        !<   slab averaged th_liq
  real, allocatable :: u0av(:)          !<   slab averaged u
  real, allocatable :: v0av(:)          !<   slab averaged v
  real, allocatable :: ug(:)            !<   geostrophic u-wind
  real, allocatable :: vg(:)            !<   geostrophic v-wind

  real, allocatable :: pgx(:)            !<   driving pressure gradient in x
  real, allocatable :: pgy(:)            !<   driving pressure gradient in y

  real, allocatable :: dpdxl(:)                      !<   large scale pressure x-gradient
  real, allocatable :: dpdyl(:)                      !<   large scale pressure y-gradient

  real, allocatable :: dthldxls(:)                   !<   large scale x-gradient of th_liq
  real, allocatable :: dthldyls(:)                   !<   large scale y-gradient of th_liq
  real, allocatable :: dqtdxls(:)                    !<   large scale x-gradient of q_tot
  real, allocatable :: dqtdyls(:)                    !<   large scale y-gradient of q_tot
  real, allocatable :: dqtdtls(:)                    !<   large scale y-gradient of q_tot
  real, allocatable :: dudxls(:)                     !<   large scale x-gradient of u

  real, allocatable :: dudyls(:)                     !<   large scale y-gradient of u
  real, allocatable :: dvdxls(:)                     !<   large scale x-gradient of v
  real, allocatable :: dvdyls(:)                     !<   large scale y-gradient of v
  real, allocatable :: wfls  (:)                     !<   large scale y-gradient of v
  real, allocatable :: ql0h(:,:,:)
  real, allocatable :: dthvdz(:,:,:)                 !<   theta_v at half level

  real, allocatable :: thlprof(:)                    !<   initial thl-profile
  real, allocatable :: qtprof(:)                     !<   initial qt-profile
  real, allocatable :: uprof(:)                      !<   initial u-profile
  real, allocatable :: vprof(:)                      !<   initial v-profile
  real, allocatable :: e12prof(:)                    !<   initial subgrid TKE profile
  real, allocatable :: sv0av(:,:)                    !<   slab average of sv(n)
  real, allocatable :: svprof(:,:)                   !<   initial sv(n)-profile
  real, allocatable :: qlprof(:)


  real, allocatable :: thlpcar(:)                    !< prescribed radiatively forced thl tendency
  real, allocatable :: SW_up_TOA(:,:), SW_dn_TOA(:,:), LW_up_TOA(:,:), LW_dn_TOA(:,:)
  real, allocatable :: uout(:)                      !< height average outlet velocity (used in convective outflow BC)
  real, allocatable :: wout(:)                      !< j-averaged top velocity
  real, allocatable :: friction(:)                  !< skin-friction coeff: from y-line-averaged shear 
  real, allocatable :: momthick(:)                  !< momentum thickness: y-line average 
  real, allocatable :: displthick(:)                !< displacement thickness: y-line average 
  real              :: uouttot                      !< area-averaged outflow velocity (used in convective outflow BC) 
  real              :: wouttot                      !< area-averaveraged top velocity

  real              :: thlsrcdt                     ! thlsrc -> thlsrcdt is used to solve 1-order ODE for thlsrc 
  real              :: dgdt                         ! g = dp/dx -> dgdt is used to solve 1-order ODE for dpdx 
  real              :: dpdx = 0.                   ! dpdx given in namoptions

  character(80), allocatable :: ncname(:,:)
  integer, allocatable :: wall(:,:,:,:)             !< wall(ic,jc,kc,1-5) gives the global indices of the wall closest to cell center ic,jc,kc. The 4th and 5th integer gives the corresponding shear components

contains
  !> Allocate and initialize the prognostic variables
  subroutine initfields

    use modglobal, only : ib,ie,jb,je,ih,jh,kb,ke,kh,nsv,jtot,imax,jmax,kmax,&
         ihc,jhc,khc!, iadv_kappa,iadv_sv
    ! Allocation of prognostic variables
    implicit none

    allocate(worksave(2*imax*jmax*kmax))
    allocate(um(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(vm(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(wm(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(thlm(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(e12m(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(qtm(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(u0(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(v0(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(w0(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(pres0(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(thl0(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(thl0h(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(qt0h(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(e120(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(qt0(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(ql0(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(up(ib-ih:ie+ih,jb-jh:je+jh,kb:ke+kh))
    allocate(vp(ib-ih:ie+ih,jb-jh:je+jh,kb:ke+kh))
    allocate(wp(ib-ih:ie+ih,jb-jh:je+jh,kb:ke+kh))
    allocate(wp_store(ib-ih:ie+ih,jb-jh:je+jh,kb:ke+kh))
    allocate(thlp(ib-ih:ie+ih,jb-jh:je+jh,kb:ke+kh))
    allocate(e12p(ib-ih:ie+ih,jb-jh:je+jh,kb:ke+kh))
    allocate(qtp(ib-ih:ie+ih,jb-jh:je+jh,kb:ke+kh))
    allocate(svm(ib-ihc:ie+ihc,jb-jhc:je+jhc,kb-khc:ke+khc,nsv))
    allocate(sv0(ib-ihc:ie+ihc,jb-jhc:je+jhc,kb-khc:ke+khc,nsv))
    allocate(svp(ib-ihc:ie+ihc,jb-jhc:je+jhc,kb:ke+khc,nsv))

    ! Allocation of diagnostic variables
    allocate(mindist(ib:ie,jb:je,kb:ke))
    allocate(yplus(ib:ie,jb:je,kb:ke))
    allocate(thv0h(ib-ih:ie+ih,jb-jh:je+jh,kb:ke+kh))
    allocate(whls(kb:ke+kh))
    allocate(presf(kb:ke+kh))
    allocate(presh(kb:ke+kh))
    allocate(exnf(kb:ke+kh))
    allocate(exnh(kb:ke+kh))
    allocate(thvf(kb:ke+kh))
    allocate(thvh(kb:ke+kh))
    allocate(rhof(kb:ke+kh))
    allocate(qt0av(kb:ke+kh))
    allocate(ql0av(kb:ke+kh))
    allocate(thl0av(kb:ke+kh))
    allocate(u0av(kb:ke+kh))
    allocate(v0av(kb:ke+kh))
    allocate(ug(kb:ke+kh))
    allocate(vg(kb:ke+kh))
    allocate(pgx(kb:ke+kh))
    allocate(pgy(kb:ke+kh))
    allocate(dpdxl(kb:ke+kh))
    allocate(dpdyl(kb:ke+kh))
    allocate(dthldxls(kb:ke+kh))
    allocate(dthldyls(kb:ke+kh))
    allocate(dqtdxls(kb:ke+kh))
    allocate(dqtdyls(kb:ke+kh))
    allocate(dqtdtls(kb:ke+kh))
    allocate(dudxls(kb:ke+kh))
    allocate(dudyls(kb:ke+kh))
    allocate(dvdxls(kb:ke+kh))
    allocate(dvdyls(kb:ke+kh))
    allocate(wfls  (kb:ke+kh))
    allocate(ql0h(ib-ih:ie+ih,jb-jh:je+jh,kb:ke+kh))
    allocate(dthvdz(ib-ih:ie+ih,jb-jh:je+jh,kb:ke+kh))
    allocate(thlprof(kb:ke+kh))
    allocate(qtprof(kb:ke+kh))
    allocate(qlprof(kb:ke+kh))
    allocate(uprof(kb:ke+kh))
    allocate(vprof(kb:ke+kh))
    allocate(e12prof(kb:ke+kh))
    allocate(sv0av(kb:ke+kh,nsv))
    allocate(svprof(kb:ke+kh,nsv))
    allocate(thlpcar(kb:ke+kh))
    allocate(uout(kb:ke))         ! height average outlet velocity (used in convective outflow BC)
    allocate(wout(ib:ie))         ! j -averaged top velocity
    allocate(friction(ib:ie))     ! line-averaged (along j) skin friction 
    allocate(momthick(ib:ie))     ! line-averaged (along j) momentum thickness 
    allocate(displthick(ib:ie))   ! line-averaged (along j) displacement thickness 
    allocate(SW_up_TOA(ib-ih:ie+ih,jb-jh:je+jh))
    allocate(SW_dn_TOA(ib-ih:ie+ih,jb-jh:je+jh))
    allocate(LW_up_TOA(ib-ih:ie+ih,jb-jh:je+jh))
    allocate(LW_dn_TOA(ib-ih:ie+ih,jb-jh:je+jh))

    ! allocate averaged variables
    allocate(uav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(vav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(wav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(thlav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(qtav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(qlav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(presav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(svav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh,1:nsv))
    allocate(viscratioav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))

    allocate(thl2av(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(ql2av(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(qt2av(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(sv2av(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh,1:nsv))
    allocate(umint(ib:ie,jb:je,kb:ke))
    allocate(vmint(ib:ie,jb:je,kb:ke))
    allocate(wmint(ib:ie,jb:je,kb:ke))
    allocate(uuav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(vvav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(wwav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(uvav(ib:ie+ih,jb:je+jh,kb:ke   ))
    allocate(uwav(ib:ie+ih,jb:je   ,kb:ke+kh))
    allocate(vwav(ib:ie   ,jb:je+jh,kb:ke+kh))

    allocate(thluav(ib:ie+ih,jb:je   ,kb:ke   ))
    allocate(thlvav(ib:ie   ,jb:je+jh,kb:ke   ))
    allocate(thlwav(ib:ie   ,jb:je,   kb:ke+kh))
    allocate(qluav(ib:ie+ih,jb:je   ,kb:ke   ))
    allocate(qlvav(ib:ie   ,jb:je+jh,kb:ke   ))
    allocate(qlwav(ib:ie   ,jb:je,   kb:ke+kh))
    allocate(qtuav(ib:ie+ih,jb:je   ,kb:ke   ))
    allocate(qtvav(ib:ie   ,jb:je+jh,kb:ke   ))
    allocate(qtwav(ib:ie   ,jb:je,   kb:ke+kh))
    allocate(svuav (ib:ie+ih,jb:je   ,kb:ke   ,1:nsv))
    allocate(svvav (ib:ie   ,jb:je+jh,kb:ke   ,1:nsv))
    allocate(svwav (ib:ie   ,jb:je   ,kb:ke+kh,1:nsv))

    ! <x'x> ( = <xx> -<x><x> )
    allocate(upupav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(vpvpav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(wpwpav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(upvpav(ib:ie+ih,jb:je+jh,kb:ke   ))
    allocate(upwpav(ib:ie+ih,jb:je   ,kb:ke+kh))
    allocate(vpwpav(ib:ie   ,jb:je+jh,kb:ke+kh))

    allocate(thlpthlpav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(thlpupav(ib:ie+ih,jb:je   ,kb:ke   ))
    allocate(thlpvpav(ib:ie   ,jb:je+jh,kb:ke   ))
    allocate(thlpwpav(ib:ie   ,jb:je   ,kb:ke+kh))
    allocate(qlpqlpav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(qlpupav(ib:ie+ih,jb:je   ,kb:ke   ))
    allocate(qlpvpav(ib:ie   ,jb:je+jh,kb:ke   ))
    allocate(qlpwpav(ib:ie   ,jb:je   ,kb:ke+kh))
    allocate(qtpqtpav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(qtpupav(ib:ie+ih,jb:je   ,kb:ke   ))
    allocate(qtpvpav(ib:ie   ,jb:je+jh,kb:ke   ))
    allocate(qtpwpav(ib:ie   ,jb:je   ,kb:ke+kh))
    allocate(svpsvpav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh,1:nsv))
    allocate(svpupav(ib:ie+ih,jb:je   ,kb:ke   ,1:nsv))
    allocate(svpvpav(ib:ie   ,jb:je+jh,kb:ke   ,1:nsv))
    allocate(svpwpav(ib:ie   ,jb:je   ,kb:ke+kh,1:nsv))
 
! Subgrid

    allocate(uusgsav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(vvsgsav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(wwsgsav(ib-ih:ie+ih,jb-jh:je+jh,kb-kh:ke+kh))
    allocate(uwsgsav(ib:ie+ih,jb:je   ,kb:ke+kh))
    allocate(thlusgsav(ib:ie+ih,jb:je   ,kb:ke   ))
    allocate(thlwsgsav(ib:ie   ,jb:je,   kb:ke+kh))
    allocate(qlusgsav(ib:ie+ih,jb:je   ,kb:ke   ))
    allocate(qlwsgsav(ib:ie   ,jb:je,   kb:ke+kh))
    allocate(qtusgsav(ib:ie+ih,jb:je   ,kb:ke   ))
    allocate(qtwsgsav(ib:ie   ,jb:je,   kb:ke+kh))
    allocate(tkesgsav (ib:ie   ,jb:je   ,kb:ke   ))
    allocate(svusgsav (ib:ie+ih,jb:je   ,kb:ke   ,1:nsv))
    allocate(svwsgsav (ib:ie   ,jb:je   ,kb:ke+kh,1:nsv))
    allocate(nusgsav  (ib:ie   ,jb:je   ,kb:ke   ))

! resolved dissipation
    allocate(strain2av(ib:ie,jb:je,kb:ke))
    allocate(disssgsav(ib:ie,jb:je,kb:ke))

! TKE budget terms
    allocate(tvmx  (ib:ie+1,jb:je,kb:ke))
    allocate(tvmy  (ib:ie,jb-1:je+1,kb:ke))
    allocate(tvmz  (ib:ie,jb:je,kb:ke+1))
    allocate(tpm   (ib:ie,jb:je,kb:ke))
    allocate(ttmx  (ib:ie+1,jb:je,    kb:ke))
    allocate(ttmy  (ib:ie,  jb-1:je+1,kb:ke))
    allocate(ttmz  (ib:ie,  jb:je,    kb:ke+1))
    allocate(tsgsmx1(ib:ie+1,jb:je,kb:ke))
    allocate(tsgsmy1(ib:ie,jb-1:je+1,kb:ke))
    allocate(tsgsmz1(ib:ie,jb:je,kb:ke+1))
    allocate(tsgsmx2(ib:ie+1,jb:je,kb:ke))
    allocate(tsgsmy2(ib:ie,jb-1:je+1,kb:ke))
    allocate(tsgsmz2(ib:ie,jb:je,kb:ke+1))
    
    allocate(t_pav  (ib:ie,jb:je,kb:ke))
    allocate(t_vav  (ib:ie,jb:je,kb:ke))
    allocate(t_tav  (ib:ie,jb:je,kb:ke))
    allocate(t_sgsav(ib:ie,jb:je,kb:ke))
    allocate(p_tav  (ib:ie,jb:je,kb:ke))
    allocate(p_bav  (ib:ie,jb:je,kb:ke))
    allocate(d_sgsav(ib:ie,jb:je,kb:ke))
    allocate(tkeadv(ib:ie,jb:je,kb:ke))


    ! allocate wall shear-stress terms (immersed boundaries)
    allocate(shear(ib:ie,jb-1:je+1,kb:ke,12))    ! halo is set to 1

    allocate(wall(ib:ie,jb:je,kb:ke,5))              ! (for j the 'global' length is used: 1:jtot )

    um=0;u0=0;up=0
    vm=0;v0=0;vp=0
    wm=0;w0=0;wp=0;wp_store=0
    pres0=0;
    thlm=0.;thl0=0.;thlp=0
    qtm=0;qt0=0;qtp=0
    e12m=0;e120=0;e12p=0
    svm=0;sv0=0;svp=0

    ql0=0;qt0h=0;
    thv0h=0;thl0h=0;
    mindist=1.0e10;yplus=0
    presf=0;presh=0;exnf=1;exnh=0;thvf=0;thvh=0;rhof=0    ! OG   
    !Exner function should be called in startup and just be initialised here
    qt0av=0;ql0av=0;thl0av=0;u0av=0;v0av=0;sv0av=0
    thlprof=0;qtprof=0;qlprof=0;uprof=0;vprof=0;e12prof=0;svprof=0
    ug=0;vg=0;pgx=0;pgy=0;dpdxl=0;dpdyl=0;wfls=0;whls=0;thlpcar = 0;uout=0;wout=0;uouttot=0;wouttot=0
    dthldxls=0;dthldyls=0;dqtdxls=0;dqtdyls=0;dudxls=0;dudyls=0;dvdxls=0;dvdyls=0
    dthvdz=0
    SW_up_TOA=0;SW_dn_TOA=0;LW_up_TOA=0;LW_dn_TOA=0

    uav=0;vav=0;wav=0;thlav=0;qtav=0;svav=0;viscratioav=0;uuav=0;vvav=0
    wwav=0;uvav=0;uwav=0;vwav=0;sv2av=0;thl2av=0;ql2av=0;qt2av=0;presav=0
    thluav=0;thlvav=0;thlwav=0;svuav=0;svvav=0;svwav=0
    shear=0
    upupav=0;vpvpav=0;wpwpav=0;thlpthlpav=0;qlpqlpav=0;qtpqtpav=0;svpsvpav=0;upvpav=0;upwpav=0;vpwpav=0
    thlpupav=0;thlpvpav=0;thlpwpav=0;qlpupav=0;qlpvpav=0;qlpwpav=0;qtpwpav=0;qtpvpav=0;qtpupav=0;svpupav=0;svpvpav=0;svpwpav=0
    umint=0;vmint=0;wmint=0
! SGS
    uusgsav=0;vvsgsav=0;wwsgsav=0;uwsgsav=0;thlusgsav=0;thlwsgsav=0;qlusgsav=0;qlwsgsav=0;qtwsgsav=0;qtusgsav=0;
    svusgsav=0;svwsgsav=0;tkesgsav=0;nusgsav=0.
! Resolved dissipation 
    strain2av=0.
! Subgrid dissipation 
    disssgsav=0.
! TKE budget
    t_vav=0.;tvmx=0.;tvmy=0.;tvmz=0.;tpm=0.;ttmx=0.;ttmy=0.;ttmz=0.;t_sgsav=0.;p_tav=0.
    tsgsmx1=0.;tsgsmy1=0.;tsgsmz1=0.;tsgsmx2=0.;tsgsmy2=0.;tsgsmz2=0.
    t_pav=0.;t_tav=0.;p_bav=0.;d_sgsav=0.;tkeadv=0.
  end subroutine initfields

  !> Deallocate the fields
  subroutine exitfields
    implicit none

    deallocate(um,vm,wm,thlm,e12m,qtm,u0,v0,w0,pres0,thl0,thl0h,qt0h,e120,qt0)
    deallocate(up,vp,wp,wp_store,thlp,e12p,qtp)
    deallocate(svm,sv0,svp)
    deallocate(ql0,ql0h,thv0h,dthvdz,whls,presf,presh,exnf,exnh,thvf,thvh,rhof,qt0av,ql0av,thl0av,u0av,v0av)
    deallocate(ug,vg,pgx,pgy,dpdxl,dpdyl,dthldxls,dthldyls,dqtdxls,dqtdyls,dqtdtls,dudxls,dudyls,dvdxls,dvdyls,wfls)
    deallocate(thlprof,qtprof,uprof,vprof,e12prof,sv0av,svprof)
    deallocate(thlpcar)
    deallocate(SW_up_TOA,SW_dn_TOA,LW_up_TOA,LW_dn_TOA)

  end subroutine exitfields

end module modfields
