C$TEST  TTGR3
c  main program
      common /cstak/ ds
      double precision ds(350000)
      external handle, bc, af
      integer ndx, ndy, istkgt, i, iumb, immm
      integer is(1000), iu, ix, iy, nu, kx
      integer nx, ky, ny, ilumb
      real errpar(2), tstart, dt, yb(4), lx, rs(1000)
      real rx, ws(1000), tstop
      logical ls(1000)
      complex cs(500)
      equivalence (ds(1), cs(1), ws(1), rs(1), is(1), ls(1))
c to solve the layered heat equation, with kappa = 1, 1/2, 1/3,
c   div . ( kappa(x,y) * grad u ) = ut + g
c the port library stack and its aliases.
c initialize the port library stack length.
      call istkin(350000, 4)
      call enter(1)
      nu = 1
      lx = 0
      rx = 1
      do  1 i = 1, 4
         yb(i) = i-1
   1     continue
      kx = 2
      ky = 2
      ndx = 3
      ndy = 3
      tstart = 0
      tstop = 1
      dt = 1
      errpar(1) = 1e-2
      errpar(2) = 1e-4
c uniform grid.
      ix = iumb(lx, rx, ndx, kx, nx)
c uniform grid.
      iy = ilumb(yb, 4, ndy, ky, ny)
c make mult = ky-1.
      iy = immm(iy, ny, yb(2), ky-1)
c make mult = ky-1.
      iy = immm(iy, ny, yb(3), ky-1)
c space for the solution.
      iu = istkgt(nu*(nx-kx)*(ny-ky), 3)
      call setr(nu*(nx-kx)*(ny-ky), 0e0, ws(iu))
      call ttgr(ws(iu), nu, kx, ws(ix), nx, ky, ws(iy), ny, tstart, 
     1   tstop, dt, af, bc, errpar, handle)
      call leave
      call wrapup
      stop 
      end
      subroutine af(t, x, nx, y, ny, nu, u, ut, ux, uy, uxt, uyt
     1   , a, au, aut, aux, auy, auxt, auyt, f, fu, fut, fux, fuy, fuxt,
     2   fuyt)
      integer nu, nx, ny
      real t, x(nx), y(ny), u(nx, ny, nu), ut(nx, ny, nu), ux(nx, ny, 
     1   nu)
      real uy(nx, ny, nu), uxt(nx, ny, nu), uyt(nx, ny, nu), a(nx, ny, 
     1   nu, 2), au(nx, ny, nu, nu, 2), aut(nx, ny, nu, nu, 2)
      real aux(nx, ny, nu, nu, 2), auy(nx, ny, nu, nu, 2), auxt(nx, ny
     1   , nu, nu, 2), auyt(nx, ny, nu, nu, 2), f(nx, ny, nu), fu(nx, 
     2   ny, nu, nu)
      real fut(nx, ny, nu, nu), fux(nx, ny, nu, nu), fuy(nx, ny, nu, nu)
     1   , fuxt(nx, ny, nu, nu), fuyt(nx, ny, nu, nu)
      integer i, p, q
      real kappa
      logical temp
      do  7 i = 1, nu
         do  6 q = 1, ny
            do  5 p = 1, nx
               if (y(q) .ge. 1.) goto 1
                  kappa = 1
                  goto  4
   1              if (y(q) .ge. 2.) goto 2
                     kappa = 0.5
                     goto  3
   2                 kappa = 1./3e0
   3           continue
   4           a(p, q, i, 1) = kappa*ux(p, q, i)
               aux(p, q, i, i, 1) = kappa
               a(p, q, i, 2) = kappa*uy(p, q, i)
               auy(p, q, i, i, 2) = kappa
               f(p, q, i) = ut(p, q, i)
               fut(p, q, i, i) = 1
               f(p, q, i) = f(p, q, i)-y(q)/kappa
               temp = 1. .lt. y(q)
               if (temp) temp = y(q) .lt. 2.
               if (temp) f(p, q, i) = f(p, q, i)+1.
               temp = 2. .lt. y(q)
               if (temp) temp = y(q) .lt. 3.
               if (temp) f(p, q, i) = f(p, q, i)+3.
   5           continue
   6        continue
   7     continue
      return
      end
      subroutine bc(t, x, nx, y, ny, lx, rx, ly, ry, u, ut, ux, 
     1   uy, uxt, uyt, nu, b, bu, but, bux, buy, buxt, buyt)
      integer nu, nx, ny
      real t, x(nx), y(ny), lx, rx, ly
      real ry, u(nx, ny, nu), ut(nx, ny, nu), ux(nx, ny, nu), uy(nx, ny,
     1   nu), uxt(nx, ny, nu)
      real uyt(nx, ny, nu), b(nx, ny, nu), bu(nx, ny, nu, nu), but(nx, 
     1   ny, nu, nu), bux(nx, ny, nu, nu), buy(nx, ny, nu, nu)
      real buxt(nx, ny, nu, nu), buyt(nx, ny, nu, nu)
      integer i, j
      logical temp
      do  6 j = 1, ny
         do  5 i = 1, nx
            temp = x(i) .eq. lx
            if (.not. temp) temp = x(i) .eq. rx
            if (.not. temp) goto 1
               bux(i, j, 1, 1) = 1
c left or right.
c neumann bcs.
               b(i, j, 1) = ux(i, j, 1)
               goto  4
   1           if (y(j) .ne. ly) goto 2
                  b(i, j, 1) = u(i, j, 1)
c bottom.
                  bu(i, j, 1, 1) = 1
                  goto  3
   2              b(i, j, 1) = u(i, j, 1)-6.*t
c top.
                  bu(i, j, 1, 1) = 1
   3        continue
   4        continue
   5        continue
   6     continue
      return
      end
      subroutine handle(t0, u0, t, u, nv, dt, tstop)
      integer nv
      real t0, u0(nv), t, u(nv), dt, tstop
      common /a7tgrp/ errpar, nu, mxq, myq
      integer nu, mxq, myq
      real errpar(2)
      common /a7tgrm/ kx, ix, nx, ky, iy, ny
      integer kx, ix, nx, ky, iy, ny
      if (t0 .ne. t) goto 2
         write (6,  1) t
   1     format (16h restart for t =, 1pe10.2)
         return
   2  call gerr(kx, ix, nx, ky, iy, ny, u, nu, t)
      return
      end
      subroutine gerr(kx, ix, nx, ky, iy, ny, u, nu, t)
      integer kx, ix, nx, ky, iy, ny
      integer nu
      real u(1), t
      common /cstak/ ds
      double precision ds(500)
      integer ifa, ita(2), ixa(2), nta(2), nxa(2), ixs
      integer iys, nxs, nys, istkgt, i, iewe
      integer ka(2), ma(2), is(1000), ilumd, i1mach
      real abs, erru, amax1, rs(1000), ws(1000)
      logical ls(1000)
      complex cs(500)
      integer temp, temp1, temp2
      equivalence (ds(1), cs(1), ws(1), rs(1), is(1), ls(1))
c to get and print the error at each time-step.
c u(nx-kx,ny,ky,nu).
c the port library stack and its aliases.
      call enter(1)
c find the error in the solution at 2*kx * 2*ky points / mesh rectangle.
c x search grid.
      ixs = ilumd(ws(ix), nx, 2*kx, nxs)
c y search grid.
      iys = ilumd(ws(iy), ny, 2*ky, nys)
c u search grid values.
      iewe = istkgt(nxs*nys, 3)
c the exact solution.
      call ewe(t, ws(ixs), nxs, ws(iys), nys, ws(iewe), nu)
      ka(1) = kx
      ka(2) = ky
      ita(1) = ix
      ita(2) = iy
      nta(1) = nx
      nta(2) = ny
      ixa(1) = ixs
      ixa(2) = iys
      nxa(1) = nxs
      nxa(2) = nys
      ma(1) = 0
c get solution.
      ma(2) = 0
c approximate solution values.
      ifa = istkgt(nxs*nys, 3)
c evaluate them.
      call tsd1(2, ka, ws, ita, nta, u, ws, ixa, nxa, ma, ws(ifa))
c error in solution values.
      erru = 0
      temp = nxs*nys
      do  1 i = 1, temp
         temp2 = iewe+i
         temp1 = ifa+i
         erru = amax1(erru, abs(ws(temp2-1)-ws(temp1-1)))
   1     continue
      temp = i1mach(2)
      write (temp,  2) t, erru
   2  format (14h error in u(.,, 1pe10.2, 3h) =, 1pe10.2)
      call leave
      return
      end
      subroutine ewe(t, x, nx, y, ny, u, nu)
      integer nu, nx, ny
      real t, x(nx), y(ny), u(nx, ny, nu)
      integer i, j, p
c the exact solution.
      do  7 p = 1, nu
         do  6 i = 1, nx
            do  5 j = 1, ny
               if (y(j) .ge. 1.) goto 1
                  u(i, j, p) = t*y(j)
                  goto  4
   1              if (y(j) .ge. 2.) goto 2
                     u(i, j, p) = 2.*t*y(j)-t
                     goto  3
   2                 u(i, j, p) = 3.*t*y(j)-3.*t
   3           continue
   4           continue
   5           continue
   6        continue
   7     continue
      return
      end
