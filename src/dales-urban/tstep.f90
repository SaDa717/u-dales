!> \file tstep.f90
!!  Performs the time integration

!>
!!  Performs the time integration
!>
!! Tstep uses adaptive timestepping and 3rd order Runge Kutta time integration.
!! The adaptive timestepping chooses it's delta_t according to the courant number
!! and the cell peclet number, depending on the advection scheme in use.
!!
!!  \author Jasper Tomas, TU Delft
!!  \author Chiel van Heerwaarden, Wageningen University
!!  \author Thijs Heus,MPI-M
!! \see Wicker and Skamarock 2002
!!  \par Revision list
!  This file is part of DALES.
!
! DALES is free software; you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation; either version 3 of the License, or
! (at your option) any later version.
!
! DALES is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with this program.  If not, see <http://www.gnu.org/licenses/>.
!
!  Copyright 1993-2009 Delft University of Technology, Wageningen University, Utrecht University, KNMI
!

!> Determine time step size dt in initialization and update time variables
!!
!! The size of the timestep Delta t is determined adaptively, and is limited by both the Courant-Friedrichs-Lewy criterion CFL
!! \latexonly
!! \begin{equation}
!! \CFL = \mr{max}\left(\left|\frac{u_i \Delta t}{\Delta x_i}\right|\right),
!! \end{equation}
!! and the diffusion number $d$. The timestep is further limited by the needs of other modules, e.g. the statistics.
!! \endlatexonly
subroutine tstep_update


  use modglobal, only : ib,ie,jb,je,rk3step,timee,runtime,dtmax,dt,ntimee,ntrun,courant,peclet,&
                        kb,ke,dxh,dxhi,dxh2i,dyi,dy2i,dzh,dt_lim,ladaptive,timeleft,dt,lwarmstart,&
                        scalsrc,dzh2i
  use modfields, only : um,vm,wm
  use modsubgriddata, only : ekm,ekh
  use modmpi,    only : myid,comm3d,mpierr,mpi_max,my_real
  implicit none

  integer       :: i, j, k,imin,kmin
  real,save     :: courtot=-1,peclettot=-1
  real          :: courtotl,courold,peclettotl,pecletold
!  logical,save  :: spinup=.true.
  logical,save  :: spinup=.false.

   
  if(lwarmstart) spinup = .false.
  rk3step = mod(rk3step,3) + 1
  if(rk3step == 1) then

    ! Initialization
    if (spinup) then
      write(6,*) '!spinup!'
      if (ladaptive) then
        courold = courtot
        pecletold = peclettot
        courtotl=0
        peclettotl = 0
        do k=kb,ke
        do j=jb,je
        do i=ib,ie
          courtotl = max(courtotl,(abs(um(i,j,k))*dxhi(i) + abs(vm(i,j,k))*dyi + abs(wm(i,j,k))/dzh(k))*dt)
!          peclettotl = max(peclettotl,  ekm(i,j,k)*(1/dzh(k)**2 + dxh2i(i) + dy2i)*dt )
          peclettotl = max(peclettotl,  ekm(i,j,k)*(dzh2i(k) + dxh2i(i) + dy2i)*dt, & 
                                        ekh(i,j,k)*(dzh2i(k) + dxh2i(i) + dy2i)*dt ) 
        end do
        end do
        end do
        call MPI_ALLREDUCE(courtotl,courtot,1,MY_REAL,MPI_MAX,comm3d,mpierr)
        call MPI_ALLREDUCE(peclettotl,peclettot,1,MY_REAL,MPI_MAX,comm3d,mpierr)
        if ( pecletold>0) then
          dt = min(dtmax,dt*courant/courtot,dt*peclet/peclettot)
          if (abs(courtot-courold)/courold<0.1 .and. (abs(peclettot-pecletold)/pecletold<0.1)) then
            spinup = .false.
          end if
        end if
        dt = dt
        dt_lim = timeleft
        timee   = timee  + dt
        timeleft = timeleft- dt
        ntimee  = ntimee + 1
        ntrun   = ntrun  + 1
      else
        dt = 2 * dt
        if (dt >= dtmax) then
          dt = dtmax
          spinup = .false.
        end if
      end if
    ! Normal time loop
    else  !spinup = .false.
      if (ladaptive) then
        courtotl=0
        peclettotl = 1e-5
        do k=kb,ke
        do j=jb,je
        do i=ib,ie
          courtotl = max(courtotl,(abs(um(i,j,k))*dxhi(i) + abs(vm(i,j,k))*dyi + abs(wm(i,j,k))/dzh(k))*dt)
          peclettotl = max(peclettotl,  ekm(i,j,k)*(dzh2i(k) + dxh2i(i) + dy2i)*dt,&
                                        ekh(i,j,k)*(dzh2i(k) + dxh2i(i) + dy2i)*dt ) 
!          if (peclettotl ==  ekh(i,j,k)*(dzh2i(k) + dxh2i(i) + dy2i)*dt) then 
!           imin = i
!           kmin = k
!          end if
        end do
        end do
        end do
!     write(6,*) 'Peclet criterion at proc,i,k = ', myid,imin,kmin

        call MPI_ALLREDUCE(courtotl,courtot,1,MY_REAL,MPI_MAX,comm3d,mpierr)
        call MPI_ALLREDUCE(peclettotl,peclettot,1,MY_REAL,MPI_MAX,comm3d,mpierr)
        if (courtot <= 0) then
          write(6,*) 'courtot=0!'
        end if 
        if (peclettot <= 0) then
          write(6,*) 'peclettot=0!'
        end if 
        dt = min(dtmax,dt*courant/courtot,dt*peclet/peclettot)          
        timeleft=timeleft-dt
        dt_lim = timeleft
        timee   = timee  + dt
        ntimee  = ntimee + 1
        ntrun   = ntrun  + 1
      else
        dt = dtmax
        ntimee  = ntimee + 1
        ntrun   = ntrun  + 1
        timee   = timee  + dt 
        timeleft=timeleft-dt
      end if
    end if
  end if
end subroutine tstep_update


!> Time integration is done by a third order Runge-Kutta scheme.
!!
!! \latexonly
!! With $f^n(\phi^n)$ the right-hand side of the appropriate equation for variable
!! $\phi=\{\fav{u},\fav{v},\fav{w},e^{\smfrac{1}{2}},\fav{\varphi}\}$, $\phi^{n+1}$
!! at $t+\Delta t$ is calculated in three steps:
!! \begin{eqnarray}
!! \phi^{*} &=&\phi^n + \frac{\Delta t}{3}f^n(\phi^n)\nonumber\\\\
!! \phi^{**} &=&\phi^{n} + \frac{\Delta t}{2}f^{*}(\phi^{*})\nonumber\\\\
!! \phi^{n+1} &=&\phi^{n} + \Delta t f^{**}(\phi^{**}),
!! \end{eqnarray}
!! with the asterisks denoting intermediate time steps.
!! \endlatexonly
!! \see Wicker and Skamarock, 2002
subroutine tstep_integrate


  use modglobal, only : ib,ie,jb,jgb,je,kb,ke,nsv,dt,rk3step,e12min,lmoist,timee,ntrun,&
                        linoutflow, linletgen,scalsrc,scalptsrc,ltempeq,nsvl,nsvp,&
                        dzf,dzhi,dzf,dxhi,dxf,ifixuinf,thlsrc
  use modmpi, only    : cmyid,myid,nprocs
  use modfields, only : u0,um,up,v0,vm,vp,w0,wm,wp,wp_store,&
                        thl0,thlm,thlp,qt0,qtm,qtp,e120,e12m,e12p,sv0,svm,svp,uouttot,&
                        friction,shear,momthick,displthick,wouttot,dpdxl,dgdt,thlsrcdt
  use modgenstat, only: tketotu,tketotv,tketotw,slabshearu,slabshearv,istart,ni
  use modsurfdata,only: thvs
  use modinletdata, only: totalu,di_test,dr,thetar,thetai,displ,irecy, &
                          dti_test,dtr,thetati,thetatr,q0,lmoi,lmor,utaui,utaur
  use modsubgriddata, only : loneeqn

  implicit none

  integer i,j,k,n,m
  real rk3coef, ugem,shapef
  character(27) namef

  rk3coef = dt / (4. - dble(rk3step))
  wp_store = wp

  if(ifixuinf==2) then
    dpdxl(:) = dpdxl(:) + dgdt*rk3coef 
    if(ltempeq==.true.) then
      thlsrc = thlsrc + thlsrcdt*rk3coef
    end if
!    write(6,*) 'dpdx = ', dpdxl(kb)
  end if

  if (loneeqn==.true.) then
    do k=kb,ke
      do j=jb,je
        do i=ib,ie
          u0(i,j,k)   = um(i,j,k)   + rk3coef * up(i,j,k)
          v0(i,j,k)   = vm(i,j,k)   + rk3coef * vp(i,j,k)
          w0(i,j,k)   = wm(i,j,k)   + rk3coef * wp(i,j,k)
          e120(i,j,k) = e12m(i,j,k) + rk3coef * e12p(i,j,k)
          e120(i,j,k) = max(e12min,e120(i,j,k))
          e12m(i,j,k) = max(e12min,e12m(i,j,k))
          do n=1,nsv
            sv0(i,j,k,n) = svm(i,j,k,n) + rk3coef * svp(i,j,k,n)
          enddo
        enddo
      enddo
    end do
  else
    do k=kb,ke
      do j=jb,je
        do i=ib,ie
          u0(i,j,k)   = um(i,j,k)   + rk3coef * up(i,j,k)
          v0(i,j,k)   = vm(i,j,k)   + rk3coef * vp(i,j,k)
          w0(i,j,k)   = wm(i,j,k)   + rk3coef * wp(i,j,k)       
          do n=1,nsv
            sv0(i,j,k,n) = svm(i,j,k,n) + rk3coef * svp(i,j,k,n)
          enddo
        enddo 
      enddo
    enddo
  end if
  if (ltempeq == .true.) then
    do k=kb,ke
      do j=jb,je
        do i=ib,ie
          thl0(i,j,k) = thlm(i,j,k) + rk3coef * thlp(i,j,k)
        enddo 
      enddo 
    enddo
  end if
  if (lmoist) then
   do k=kb,ke
     do j=jb,je
       do i=ib,ie
         qt0(i,j,k) = qtm(i,j,k) + rk3coef * qtp(i,j,k)
       enddo 
      enddo
    enddo
  end if
  
  if (linoutflow==.true.) then
    if (linletgen == 0) then
      u0(ie+1,jb:je,kb:ke) = um(ie+1,jb:je,kb:ke)  + rk3coef * up(ie+1,jb:je,kb:ke)
    else
      u0(ib-1,jb:je,kb:ke) = um(ib-1,jb:je,kb:ke)  + rk3coef * up(ib-1,jb:je,kb:ke)
      u0(ie+1,jb:je,kb:ke) = um(ie+1,jb:je,kb:ke)  + rk3coef * up(ie+1,jb:je,kb:ke)
    end if
  end if


! all commented by tg3315 !undone

  ! add scalar line sources:
   do n=1,nsvl
      do k=kb,ke
        do i=ib,ie
          sv0(i,:,k,n) =  sv0(i,:,k,n) + scalsrc(i,k,n)*rk3coef
        end do    
      end do
    end do
  ! add scalar point sources:
    do n=nsvl+1,nsvl+nsvp
      m = n - nsvl  ! index for point sources
      do k=kb,ke
        do j=jb,je
          do i=ib,ie
            sv0(i,j,k,n) =  sv0(i,j,k,n) + scalptsrc(i,j,k,m)*rk3coef
          end do    
        end do
      end do
    end do

!up to here


!  Write some statistics to monitoring file 
      if (myid==0 .and. rk3step==3) then
        open(unit=11,file='monitor'//cmyid//'.txt',position='append')
        if (linletgen == 1) then 
          write(11,3001) timee,uouttot,totalu,wouttot,tketotu,tketotv,tketotw,di_test,dr,displ(ib),displ(irecy),thetai,thetar,utaui,utaur,dti_test,dtr,thetati,thetatr,q0,lmoi,lmor
        else 
          write(11,3001) timee,tketotu,tketotv,tketotw
        end if  
3001    format (13(6e14.6))
        close(11)

        if (ifixuinf == 2) then
          open(unit=11,file='dpdx___.txt',position='append')
          write(11,3002) timee,dpdxl(kb)
3002      format (13(6e20.12))
          close(11)
          
          if (ltempeq==.true.) then
            open(unit=11,file='thlsrc.txt',position='append')
            write(11,3002) timee,thlsrc
3003        format (13(6e20.12))
            close(11)
          end if


        end if
      endif

! write data from measuring points to file:
! midplane
!       if ((nsv > 1) .and. myid == (nprocs/2)-1 .and. rk3step==3) then
!!       write(6,*) 'Monitor points!'
!!       write(6,*) istart+INT(0.75*ni)
!         k=24
!         do i = istart+INT(0.75*ni),ie,ni
!!           write(6,*) 'data at point i = ', i
!           namef(1:27) = 'monitor/u_i____mid_z0p5.dat'
!           write (namef(12:15)  ,'(i4.4)') i
!!           write(6,*) 'filename = ', namef
!           open(unit=15,file=namef,form='unformatted',access='stream',position='append')
!           write(15) 0.25*( (u0(i,je,k)  +u0(i,je+1,k)  )*dzf(k-1) + &
!                            (u0(i,je,k-1)+u0(i,je+1,k-1))*dzf(k))*dzhi(k)
!           close (15)
!           namef(1:27) = 'monitor/v_i____mid_z0p5.dat'
!           write (namef(12:15)  ,'(i4.4)') i
!           open(unit=15,file=namef,form='unformatted',access='stream',position='append')
!           write(15) 0.25*( (v0(i,je+1,k)  *dxf(i-1)+v0(i-1,je+1,k)  *dxf(i))*dxhi(i-1)*dzf(k-1) + &
!                            (v0(i,je+1,k-1)*dxf(i-1)+v0(i-1,je+1,k-1)*dxf(i))*dxhi(i-1)*dzf(k))*dzhi(k)
!           close (15)
!           namef(1:27) = 'monitor/w_i____mid_z0p5.dat'
!           write (namef(12:15)  ,'(i4.4)') i
!           open(unit=15,file=namef,form='unformatted',access='stream',position='append')
!           write(15) 0.25*( (w0(i,je+1,k)*dxf(i-1)+w0(i-1,je+1,k)*dxf(i))*dxhi(i-1) + &
!                           (w0(i,je,k)  *dxf(i-1)+w0(i-1,je,k)  *dxf(i))*dxhi(i-1))
!           close (15)
!           namef(1:27) = 'monitor/s1i____mid_z0p5.dat'
!           write (namef(12:15)  ,'(i4.4)') i
!           open(unit=15,file=namef,form='unformatted',access='stream',position='append')
!           write(15) 0.125*(( (sv0(i,je+1,k,1)  *dxf(i-1)+sv0(i-1,je+1,k,1)  *dxf(i))*dxhi(i-1)*dzf(k-1) + &
!                              (sv0(i,je+1,k-1,1)*dxf(i-1)+sv0(i-1,je+1,k-1,1)*dxf(i))*dxhi(i-1)*dzf(k))*dzhi(k) &
!                            +((sv0(i,je,k,1)  *dxf(i-1)+sv0(i-1,je,k,1)*dxf(i)  )*dxhi(i-1)*dzf(k-1) + &
!                              (sv0(i,je,k-1,1)*dxf(i-1)+sv0(i-1,je,k-1,1)*dxf(i))*dxhi(i-1)*dzf(k))*dzhi(k))
!           close (15)
!          namef(1:27) = 'monitor/s2i____mid_z0p5.dat'
!         write (namef(12:15)  ,'(i4.4)') i
!           open(unit=15,file=namef,form='unformatted',access='stream',position='append')
!           write(15) 0.125*(( (sv0(i,je+1,k,2)  *dxf(i-1)+sv0(i-1,je+1,k,2)*dxf(i))*dxhi(i-1)*dzf(k-1) + &
!                              (sv0(i,je+1,k-1,2)*dxf(i-1)+sv0(i-1,je+1,k-1,2)*dxf(i))*dxhi(i-1)*dzf(k))*dzhi(k)&
!                            +((sv0(i,je,k,2)  *dxf(i-1)+sv0(i-1,je,k,2)*dxf(i))*dxhi(i-1)*dzf(k-1) + &
!                              (sv0(i,je,k-1,2)*dxf(i-1)+sv0(i-1,je,k-1,2)*dxf(i))*dxhi(i-1)*dzf(k))*dzhi(k))
!           close (15)
!
!         end do
!       end if ! myid and rk3step


        

!! write velocities along line to file
!   ! at (x,z) = 180h, 1.5h) (recycle x-location)
!      open(unit=15,file='u_i691k48'//cmyid//'.dat',form='unformatted',access='stream',position='append')
!         write(15) u0(691,:,48)
!      close (15)
!      open(unit=15,file='v_i691k48'//cmyid//'.dat',form='unformatted',access='stream',position='append')
!         write(15) v0(691,:,48)
!      close (15)
!      open(unit=15,file='w_i691k48'//cmyid//'.dat',form='unformatted',access='stream',position='append')
!         write(15) w0(691,:,48)
!      close (15)
!
!   ! at (x,z) = 10h, 4h)
!      open(unit=15,file='u_i691k70'//cmyid//'.dat',form='unformatted',access='stream',position='append')
!         write(15) u0(691,:,70)
!      close (15)
!      open(unit=15,file='v_i691k70'//cmyid//'.dat',form='unformatted',access='stream',position='append')
!         write(15) v0(691,:,70)
!      close (15)
!      open(unit=15,file='w_i691k70'//cmyid//'.dat',form='unformatted',access='stream',position='append')
!         write(15) w0(691,:,70)
!      close (15)
!
!    if (myid==0) then
!   ! at (j,z) = (X, 1.5h)
!      open(unit=15,file='u_jlock48'//cmyid//'.dat',form='unformatted',access='stream',position='append')
!         write(15) u0(:,1,48)
!      close (15)
!      open(unit=15,file='v_jlock48'//cmyid//'.dat',form='unformatted',access='stream',position='append')
!         write(15) v0(:,1,48)
!      close (15)
!      open(unit=15,file='w_jlock48'//cmyid//'.dat',form='unformatted',access='stream',position='append')
!         write(15) w0(:,1,48)
!      close (15)
!    end if


  up=0.
  vp=0.
  wp=0.
  thlp=0.
  svp=0.
  e12p=0.
  qtp=0.

  if(rk3step == 3) then
    um = u0
    vm = v0
    wm = w0
    thlm = thl0
    e12m = e120
    svm = sv0
    qtm = qt0
  end if
end subroutine tstep_integrate
