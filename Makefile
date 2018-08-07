# Set variables

DEBUG=TRUE

#---------- cx1 ----------------------------------------------------------#

ifeq ($(PLATFORM),cx1)
  TARGET=dalesurban_cx1
  INCDIRS = $(MPI_HOME)/include
  LIBDIRS = $(MPI_HOME)/lib
  LIBS    = mpi

# Objects required for build
FSRC=$(wildcard *.f90)
FOBJS=$(FSRC:.f90=.o)
F77SRC=$(wildcard *.f)
F77OBJS=$(F77SRC:.f=.o)

  NETCDF      = /apps/netcdf/4.0.1-mcmodel-medium
  LIBS       += netcdf #netcdff90 #lnetcdff
  INCDIRS    += $(NETCDF)/include $(MPI_HOME)/include
  LIBDIRS    += $(NETCDF)/lib

  FC          =  mpiifort
  FCOPTS     += -r8 -fpp -WB -fpe0 -extend_source -mcmodel=medium
  FLOPTS      = -mcmodel=medium
  FCOPTS77     += -r8 -fpp -WB -fpe0 -extend_source -mcmodel=medium
  FLOPTS77      = -mcmodel=medium
 ifeq ($(DEBUG),TRUE)
#    FCOPTS     += -g  -traceback -CB -check all
    FCOPTS     += -g -traceback -CB -Wunused
    FLOPTS     += -g -traceback -CB -Wunused
    FCOPTS77   += -g -traceback -CB
    FLOPTS77   += -g -CB
  else
    FCOPTS     += -O3 -g -traceback
    FCOPTS77     += -O3 -g -traceback
 endif

endif

#----------local----------------------------------------------------------#

ifeq ($(PLATFORM),local)
  TARGET=dalesurban_local
 # INCDIRS = /usr/lib64/mpi/gcc/openmpi/include/
 # LIBDIRS = /usr/lib64/mpi/gcc/openmpi/lib64/
  LIBS    =  mpi netcdf netcdff fftw3 #netcdff90

# Objects required for build
FSRC=$(wildcard *.f90)
FOBJS=$(FSRC:.f90=.o)
F77SRC=$(wildcard *.f)
F77OBJS=$(F77SRC:.f=.o)

  INCDIRS    += /usr/include /usr/bin /usr/lib64/mpi/gcc/openmpi/include/ /usr/local/include
  LIBDIRS    += /usr/lib64 /usr/local/lib64 /usr/lib64/mpi/gcc/openmpi/lib64/

  FC          =  mpifort

 FCOPTS      = -fdefault-real-8 -ffree-line-length-none -cpp -ffpe-trap=inv,zero,ov
 FLOPTS      = -fdefault-real-8 
 FCOPTS77     += -fdefault-real-8 
 FLOPTS77      = -fdefault-real-8 

 ifeq ($(DEBUG),TRUE)
    FCOPTS     += -g -Warray-bounds -finit-real=nan -fbacktrace #-Wall -Wextra -Warray-temporaries -Wconversion -fimplicit-none -fcheck=all -ffpe-trap=zero,overflow,underflow
    FLOPTS     += -g -Warray-bounds -finit-real=nan -fbacktrace #-Wextra -Wall
    FCOPTS77   += -g -fbacktrace
    FLOPTS77   += -g -fbacktrace
 else
    FCOPTS     += -O3 -g -fbacktrace
    FCOPTS77   += -O3 -g -fbacktrace
 endif

endif

#----------archer----------------------------------------------------------#

ifeq ($(PLATFORM),archer)
  TARGET=dalesurban_archer
  INCDIRS = $(MPI_HOME)/include 
  LIBDIRS = $(MPI_HOME)/lib 

  # Objects required for build
  FSRC=$(wildcard *.f90)
  FOBJS=$(FSRC:.f90=.o)
  F77SRC=$(wildcard *.f)
  F77OBJS=$(F77SRC:.f=.o)

#  HDF5         = /opt/cray/hdf5/1.8.14/intel/14.0
#  NETCDF       = /opt/cray/netcdf/4.3.3.1/intel/14.0
#  FFTW	       = /opt/cray/fftw/3.3.4.5/sandybridge
#  INCDIRS    += $(NETCDF)/include $(NETCDFF)/include  $(MPI_HOME)/include $(HDF5)/include $(FFTW)/include
#  LIBDIRS    += $(NETCDF)/lib $(HDF5)/lib $(NETCDFF)/lib $(FFTW)/lib $(MPI_HOME)/mpi
#  LIBS    = hdf5 netcdf netcdff fftw3

  FC          =  ftn
  FCOPTS     +=   -fpp -fpe0 -r8 -WB
  FLOPTS     +=   -fpp -fpe0 -r8 -WB
  FCOPTS77     += -fpp -fpe0 -r8 -WB
  FLOPTS77      = -fpp -fpe0 -r8 -WB

#  ifeq ($(FFTW), TRUE)
    FCOPTS     += -DFFTW
#  endif

  ifeq ($(DEBUG),TRUE)
    FCOPTS     += -g -O0 -traceback
    FLOPTS     += -g -CB
    FCOPTS77   += -g -traceback
    FLOPTS77   += -g -CB
  else
    FCOPTS     += -O3 -dynamic -ftz -mcmodel=large -ip
    FLOPTS     += -O3 -dynamic -mcmodel=large
    FCOPTS     += -O3 -dynamic -ftz -mcmodel=large -ip
    FLOPTS     += -O3 -dynamic -mcmodel=large
  endif

endif

#----------macOS-----------------------------------------------------------#

ifeq ($(PLATFORM),macos)
  TARGET = dalesurban_macos
  LIBS    =  mpi netcdf netcdff fftw3 #netcdff90

  # Objects required for build
  FSRC=$(wildcard *.f90)
  FOBJS=$(FSRC:.f90=.o)
  F77SRC=$(wildcard *.f)
  F77OBJS=$(F77SRC:.f=.o)

  INCDIRS    += /usr/local /usr/bin /usr/local/include /usr/local/Cellar
  LIBDIRS    += /usr/local/Cellar /usr/local/include /usr/local/opt

  FC          =  mpifort

  FCOPTS      = -fdefault-real-8 -ffree-line-length-none -cpp -ffpe-trap=inv,zero,ov
  FLOPTS      = -fdefault-real-8
  FCOPTS77   += -fdefault-real-8
  FLOPTS77    = -fdefault-real-8

  ifeq ($(DEBUG),TRUE)
    FCOPTS     += -g -Warray-bounds -finit-real=nan -fbacktrace #-Wall -Wextra -Warray-temporaries -Wconversion -fimplicit-none -fcheck=all -ffpe-trap=zero,overflow,underflow -Wunused
    FLOPTS     += -g -Warray-bounds -Wunused -finit-real=nan -fbacktrace #-Wextra -Wall
    FCOPTS77   += -g -fbacktrace
    FLOPTS77   += -g -fbacktrace
  else
    FCOPTS     += -O3 -g -fbacktrace
    FCOPTS77   += -O3 -g -fbacktrace
  endif

endif

# ----------------------------------------------------------------------
# Some compiler and linker options
FCINCOPTS     =  $(patsubst %, -I%, $(INCDIRS))

FL            = $(FC)
FLOPTS       +=
FLLIBOPTS     = $(patsubst %, -L%, $(LIBDIRS)) $(patsubst %, -l%, $(LIBS))

VPATH = $(subst ,:,$(INCDIRS))


# ---------------------   Build rules -----------------------------------
.PHONY:  all
all: depend $(TARGET)

$(TARGET): $(F77OBJS) $(FOBJS) $(COBJS)
	$(FL) $(FLOPTS) -o $@ $(^F) $(FLLIBOPTS)

install: $(TARGET)
	cp $(TARGET) $(BINDIR)

.PHONY: clean
depend: $(FRSC) $(F77SRC)
	makedepf90 $(FSRC) $(F77SRC) > depend

%.mod %.o : %.f90
	$(FC) $(FCOPTS) $(FCINCOPTS) -c $<

%.mod %.o : %.f
	$(FC) $(FCOPTS77) $(FCINCOPTS) -c $<

# Include the dependencies file generated by makedepf90
include depend

clean:
	rm -f $(notdir $(F77OBJS) $(FOBJS) $(COBJS)) $(TARGET) *.mod
