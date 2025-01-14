
!> \file advec_2nd.f90
!!  Does advection with a 2nd order central differencing scheme.
!! \par Revision list
!! \par Authors
!! Second order central differencing can be used for variables where neither very
!! high accuracy nor strict monotonicity is necessary.
!! \latexonly
!!\begin{eqnarray}
!! F_{i-\frac{1}{2}}^{2nd} &=&
!!\fav{u}_{i-\frac{1}{2}}\frac{\phi_{i}+\phi_{i-1}}{2},
!!\end{eqnarray}
!! \endlatexonly
!!
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

!> Advection at cell center
subroutine advecc_2nd(hi, hj, hk, putin, putout)

   use modglobal, only:ih, jh, kh, kb, ke, ib, ie, jb, je, dxi, dxi5, dyi, dyi5, dzf, dzfi, dzhi, dzfi5, libm, jmax
   use modfields, only:u0, v0, w0
   use modibm, only:nxwallsnorm, nzwallsnorm, nywallsm, nywallsp, ywallsm, ywallsp, &
      xwallsnorm, zwallsnorm, iypluswall, iyminwall, nyminwall, nypluswall
   use modibmdata, only:nxwall, ixwall
   use initfac, only:block
   use modmpi, only:myid
   implicit none

   integer, intent(in) :: hi !< size of halo in i
   integer, intent(in) :: hj !< size of halo in j
   integer, intent(in) :: hk !< size of halo in k
   real, dimension(ib - hi:ie + hi, jb - hj:je + hj, kb - hk:ke + hk), intent(in)  :: putin !< Input: the cell centered field
   real, dimension(ib - hi:ie + hi, jb - hj:je + hj, kb:ke + hk), intent(inout) :: putout !< Output: the tendency

   integer :: i, j, k, ip, im, jp, jm, kp, km, il, iu, jl, ju, kl, ku, n
   do k = kb, ke
      km = k - 1
      kp = k + 1
      do j = jb, je
         jm = j - 1
         jp = j + 1
         do i = ib, ie
            im = i - 1
            ip = i + 1
            putout(i, j, k) = putout(i, j, k) - ( &
                              ( &
                              u0(ip, j, k)*(putin(ip, j, k) + putin(i, j, k)) &
                            - u0(i, j, k)*(putin(im, j, k) + putin(i, j, k)) & ! d(uc)/dx
                              )*dxi5 &
                            + ( & !
                              v0(i, jp, k)*(putin(i, jp, k) + putin(i, j, k)) &
                            - v0(i, j, k)*(putin(i, jm, k) + putin(i, j, k)) & ! d(vc)/dy
                              )*dyi5)
         end do
      end do
   end do

   do j = jb, je
      jm = j - 1
      jp = j + 1
      do i = ib, ie
         im = i - 1
         ip = i + 1
         do k = kb, ke
            km = k - 1
            kp = k + 1
            putout(i, j, k) = putout(i, j, k) - ( &
                              w0(i, j, kp)*(putin(i, j, kp)*dzf(k) + putin(i, j, k)*dzf(kp))*dzhi(kp) &
                            - w0(i, j, k)*(putin(i, j, km)*dzf(k) + putin(i, j, k)*dzf(km))*dzhi(k) &
                              )*dzfi5(k)
         end do
      end do
   end do

end subroutine advecc_2nd

!> Advection at the u point.
subroutine advecu_2nd(putin, putout)

   use modglobal, only:ih, ib, ie, jb, je, jh, kb, ke, kh, dxi, dxiq, dyiq, dzf, dzfi5, dzhi, libm, imax, jmax, ktot
   use modfields, only:u0, v0, w0, pres0, uh, vh, wh, pres0h
   use modibm, only:nxwallsnorm, nzwallsnorm, nywallsm, nywallsp, ywallsm, ywallsp, &
      xwallsnorm, zwallsnorm
   use modmpi, only:myid
   use decomp_2d
   implicit none

   real, dimension(ib - ih:ie + ih, jb - jh:je + jh, kb - kh:ke + kh), intent(in)  :: putin !< Input: the u-field
   real, dimension(ib - ih:ie + ih, jb - jh:je + jh, kb:ke + kh), intent(inout) :: putout !< Output: the tendency

   integer :: i, j, k, ip, im, jp, jm, kp, km, il, iu, jl, ju, kl, ku, n

   do k = kb, ke
      km = k - 1
      kp = k + 1
      do j = jb, je
         jm = j - 1
         jp = j + 1
         do i = ib, ie
            im = i - 1
            ip = i + 1
            putout(i, j, k) = putout(i, j, k) - ( &
                              ( &
                              (putin(i, j, k) + putin(ip, j, k))*(u0(i, j, k) + u0(ip, j, k)) &
                            - (putin(i, j, k) + putin(im, j, k))*(u0(i, j, k) + u0(im, j, k)) & ! d(uu)/dx
                              )*dxiq &
                            + ( &
                              (putin(i, j, k) + putin(i, jp, k))*(v0(i, jp, k) + v0(im, jp, k)) &
                            - (putin(i, j, k) + putin(i, jm, k))*(v0(i, j, k) +  v0(im, j, k)) & ! d(vu)/dy
                              )*dyiq) &
                            - ((pres0(i, j, k) - pres0(i - 1, j, k))*dxi) ! - dp/dx

         end do
      end do
   end do

   do j = jb, je
      jm = j - 1
      jp = j + 1
      do i = ib, ie
         im = i - 1
         ip = i + 1
         do k = kb, ke
            km = k - 1
            kp = k + 1
            putout(i, j, k) = putout(i, j, k) - ( &
                              (putin(i, j, kp)*dzf(k) + putin(i, j, k)*dzf(kp))*dzhi(kp) &
                            * (w0(i, j, kp) + w0(im, j, kp)) &
                            - (putin(i, j, k)*dzf(km) + putin(i, j, km)*dzf(k))*dzhi(k) &
                            * (w0(i, j, k) + w0(im, j, k)) &
                              )*0.5*dzfi5(k)
         end do
      end do
   end do

end subroutine advecu_2nd

!> Advection at the v point.
subroutine advecv_2nd(putin, putout)

   use modglobal, only:ih, ib, ie, jh, jb, je, kb, ke, kh, dx, dxi, dxiq, dyiq, dzf, dzfi5, dzhi, dyi
   use modfields, only:u0, v0, w0, pres0
   implicit none

   real, dimension(ib - ih:ie + ih, jb - jh:je + jh, kb - kh:ke + kh), intent(in)  :: putin !< Input: the v-field
   real, dimension(ib - ih:ie + ih, jb - jh:je + jh, kb:ke + kh), intent(inout) :: putout !< Output: the tendency

   integer :: i, j, k, ip, im, jp, jm, kp, km
   do k = kb, ke
      km = k - 1
      kp = k + 1
      do j = jb, je
         jm = j - 1
         jp = j + 1
         do i = ib, ie
            im = i - 1
            ip = i + 1

            putout(i, j, k) = putout(i, j, k) - ( &
                              ( &
                              (u0(ip, j, k) + u0(ip, jm, k))*(putin(i, j, k) + putin(ip, j, k)) &
                            - (u0(i, j, k)  + u0(i, jm, k)) *(putin(i, j, k) + putin(im, j, k)) & ! d(uv)/dx
                              )*dxiq &
                            + ( &
                              ( v0(i, jp, k) + v0(i, j, k))*(putin(i, j, k) + putin(i, jp, k)) &
                            - (v0(i, jm, k) + v0(i, j, k))*(putin(i, j, k) + putin(i, jm, k)) & ! d(vv)/dy
                              )*dyiq &
                              ) &
                            - ((pres0(i, j, k) - pres0(i, jm, k))*dyi) ! - dp/dy

         end do
      end do
   end do

   do j = jb, je
      jm = j - 1
      jp = j + 1
      do i = ib, ie
         im = i - 1
         ip = i + 1
         do k = kb, ke
            km = k - 1
            kp = k + 1
            putout(i, j, k) = putout(i, j, k) - ( &
                              (w0(i, j, kp) + w0(i, jm, kp)) &
                            * (putin(i, j, kp)*dzf(k) + putin(i, j, k)*dzf(kp))*dzhi(kp) &
                            - (w0(i, j, k) + w0(i, jm, k)) &
                            * (putin(i, j, km)*dzf(k) + putin(i, j, k)*dzf(km))*dzhi(k) &
                              )*0.5*dzfi5(k)
         end do
      end do
   end do

end subroutine advecv_2nd

!> Advection at the w point.
subroutine advecw_2nd(putin, putout)

   use modglobal, only:ih, ib, ie, jh, jb, je, kb, ke, kh, dx, dxi, dxiq, dyiq, dzf, dzhi, dzhiq
   use modfields, only:u0, v0, w0, pres0
   ! use modmpi, only : myid
   implicit none

   real, dimension(ib - ih:ie + ih, jb - jh:je + jh, kb - kh:ke + kh), intent(in)  :: putin !< Input: the w-field
   real, dimension(ib - ih:ie + ih, jb - jh:je + jh, kb:ke + kh), intent(inout) :: putout !< Output: the tendency

   integer :: i, j, k, ip, im, jp, jm, kp, km

   do k = kb + 1, ke
      km = k - 1
      kp = k + 1
      do j = jb, je
         jm = j - 1
         jp = j + 1
         do i = ib, ie
            im = i - 1
            ip = i + 1

            putout(i, j, k) = putout(i, j, k) - ( &
                              ( &
                              (putin(ip, j, k) + putin(i, j, k))*(dzf(km)*u0(ip, j, k) + dzf(k)*u0(ip, j, km)) &
                            - (putin(i, j, k)  + putin(im, j, k))*(dzf(km)*u0(i, j, k) + dzf(k)*u0(i, j, km)) &
                              )*dxiq*dzhi(k) & ! d(uw)/dx
                            + ( &
                              (putin(i, jp, k) + putin(i, j, k))*(dzf(km)*v0(i, jp, k) + dzf(k)*v0(i, jp, km)) &
                            - (putin(i, j, k) + putin(i, jm, k))*(dzf(km)*v0(i, j, k) + dzf(k)*v0(i, j, km)) &
                              )*dyiq*dzhi(k) & ! d(vw)/dy
                            + ( &
                              (putin(i, j, k) + putin(i, j, kp))*(w0(i, j, k) + w0(i, j, kp)) &
                            - (putin(i, j, k) + putin(i, j, km))*(w0(i, j, k) + w0(i, j, km)) &
                              )*dzhiq(k) & ! d(ww)/dz
                              ) &
                            - ((pres0(i, j, k) - pres0(i, j, km))*dzhi(k)) ! - dp/dz

         end do
      end do
   end do
end subroutine advecw_2nd
