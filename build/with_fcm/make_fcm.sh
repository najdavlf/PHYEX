#!/bin/bash

set -e
#set -x

fcm_version=tags/2021.05.0
fiat_version=1295120464c3905e5edcbb887e4921686653eab8

function parse_args() {
  # default values
  ARCH_PATH=$PWD/arch
  ARCH=
  GMKFILE=
  MESONHPROFILE=
  useexpand=1
  commit=""
  # pass unrecognized arguments to fcm
  FCM_ARGS=""
  
  while (($# > 0)); do
    OPTION="$1" ; shift
    case "$OPTION" in
      "-h") cat <<EOF
	    Usage :
$0 [options]
--help -h   help
--arch-path ARCH_PATH directory for architecture specific files (see below) [./arch]
--arch ARCH  	        build using arch files $ARCH_PATH/arch-ARCH.* [gnu]
--gmkfile FILE        build using a gmkpack configuration file (--arch must be used to give a name to the build dir)
--mesonhprofile FILE  build using Méso-NH profile and rules (--arch must be used to give a name to the build dir)
--noexpand            do not use mnh_expand (code will be in array-syntax)"
--commit              commit hash (or a directory) to test; do not use this option from within a repository

Unrecognized options are passed to the fcm build command. Useful options include :
--new                   clean build tree before building
--jobs=N                parallel build, similar to make -j N
--ignore-lock           ignore lock indicating another build is ongoing, useful after an interrupted build

For details on FCM, see 
    http://metomi.github.io/fcm/doc/user_guide/build.html
    http://metomi.github.io/fcm/doc/user_guide/command_ref.html#fcm-build
EOF
        exit;;
      "--arch")
        ARCH=$1 ; shift ;; 
      "--arch-path")
        ARCH_PATH=$1 ; shift ;; 
      "--gmkfile")
        GMKFILE=$1 ; shift ;;
      "--mesonhprofile")
        MESONHPROFILE=$1 ; shift ;;
      '--noexpand') useexpand=0;;
      '--commit') commit=$1; shift;;
      *)
        FCM_ARGS="$FCM_ARGS $OPTION" ;;
    esac
  done
  [ "$GMKFILE" == "" -a "$MESONHPROFILE" == "" -a "$ARCH" == "" ] && ARCH=gnu
  if [ "$GMKFILE" != "" -a "$ARCH" == "" ]; then
    echo "--arch option is mandatory if --gmkfile option is used"
    exit 2
  fi
  if [ "$MESONHPROFILE" != "" -a "$ARCH" == "" ]; then
    echo "--arch option is mandatory if --mesonhprofile option is used"
    exit 3
  fi
}

function check_install_fcm() {
  if [ ! -f fcm/bin/fcm ]; then
    echo "Performing FCM installation..."
    cd fcm
    rm -f .gitkeep
    git clone https://github.com/metomi/fcm.git .
    git checkout $fcm_version
    touch .gitkeep
    cd ..
    echo "...FCM installation done"
  fi
}

function check_install_fiat() {
  if [ ! -d fiat/src ]; then
    echo "Performing fiat cloning..."
    cd fiat
    rm -f .gitkeep
    git clone https://github.com/ecmwf-ifs/fiat.git .
    git checkout $fiat_version
    touch .gitkeep
    cd ..
    echo "...fiat cloning done"
  fi
echo
}

function gmkfile2arch() {
  GMKFILE=$1
  ARCHFILE=$2
cat <<EOF > $ARCHFILE
# Compilation
\$FCOMPILER     =     $(grep "^FRTNAME =" $GMKFILE | cut -d = -f 2)
\$BASE_FFLAGS   =     $(grep "^FRTFLAGS =" $GMKFILE | cut -d = -f 2-) $(grep "^GMK_FCFLAGS_PHYEX =" $GMKFILE | cut -d = -f 2-)
\$PROD_FFLAGS   =     $(grep "^OPT_FRTFLAGS =" $GMKFILE | cut -d = -f 2-)
\$DEV_FFLAGS    =     $(grep "^DBG_FRTFLAGS =" $GMKFILE | cut -d = -f 2-)
\$DEBUG_FFLAGS  =     $(grep "^DBG_FRTFLAGS =" $GMKFILE | cut -d = -f 2-) $(grep "^BCD_FRTFLAGS =" $GMKFILE | cut -d = -f 2-) $(grep "^NAN_FRTFLAGS =" $GMKFILE | cut -d = -f 2-)
\$CCOMPILER     =     $(grep "^VCCNAME =" $GMKFILE | cut -d = -f 2)
\$BASE_CFLAGS   =     $(grep "^VCCFLAGS =" $GMKFILE | cut -d = -f 2-)
\$PROD_CFLAGS   =     $(grep "^OPT_VCCFLAGS =" $GMKFILE | cut -d = -f 2-)
\$DEV_CFLAGS    =     
\$DEBUG_CFLAGS  =     
\$OMP_FFLAGS    =

# Preprocessor
\$FPP_FLAGS     =     $(grep "^MACROS_FRT =" $GMKFILE | cut -d = -f 2- | sed 's/-D//g')
\$CPP_FLAGS     =     $(grep "^MACROS_CC =" $GMKFILE | cut -d = -f 2- | sed 's/-D//g')

# Linker
\$LINK          =     $(grep "^LNK_MPI =" $GMKFILE | cut -d = -f 2-)
\$BASE_LD       =     $(grep "^LNK_FLAGS =" $GMKFILE | cut -d = -f 2-)
\$OMP_LD        =
\$LD_EXE_TO_SHARED = $(grep "^LNK_SOLIB =" $GMKFILE | cut -d = -f 2-  | sed 's/-o a.out//')

# Other
\$AR            =     $(grep "^AR =" $GMKFILE | cut -d = -f 2-)
EOF
}

function mesonhprofile2archenv() {
  MESONHPROFILE=$1
  ARCHFILE=$2
  ENVFILE=$3

  echo "
   You are trying to produce a configuration file for fcm from a Meso-NH configuration.
   The resulting file is certainly incomplete and must be modified as follows:
      Optimisation level:
        The opt level is set in the mesonh profile file; as a consequence, the BASE_FFLAGS contains
        the base *and* the opt flags.
        To compile with other opt level, the profile file must be modified before executing this function.
      Long lines:
        Meso-NH rules does not allow the compilation of long lines. Depending on compilers, it might be needed to
        manually add an option to allow long lines.
        For gfortran: add '-ffree-line-length-none' to BASE_FFLAGS
      OpenMP:
        Meso-NH does not use OpenMP but testprogs do; as a consequence, openmp flags are not included in the
        Meso-NH rules, they must be manually added.
        For gfortran: add '-fopenmp' to BASE_FFLAGS and to BASE_LD
      Position Independent Code:
        Meso-NH does not need to build position independent code, flags must be set manually.
        For gfortran ('-fPIC' already in BASE_FFLAGS): add '-fPIC' to BASE_CFLAGS
      Shared lib:
        Flags needed to build shared lib are not defined in Meso-NH rules, only hard coded in Makefile to build a
        specific lib. The flags to set for building a shared lib, in addition to flags used to build an object, must
        be manually set.
        For gfortran: add '-shared' to LD_EXE_TO_SHARED
      Swap:
        Meso-NH rules does not swap IO byte order (litle-/big-endian). Depending on your endianess, the
        corresponding flag may have to be set manually.
        For gfortran: add '-fconvert=swap' to BASE_FFLAGS"
  tac $MESONHPROFILE | grep -m1 '#' -B $(cat $MESONHPROFILE | wc -l) | tac | grep -v '#' > $ENVFILE
  MAKEFILE='
include Rules.$(ARCH)$(F).mk

archfile :
	echo "# Compilation"
	echo "\$$FCOMPILER     =     $(F90)"
	echo "\$$BASE_FFLAGS   =     -c $(F90FLAGS)"
	echo "\$$PROD_FFLAGS   =     "
	echo "\$$DEV_FFLAGS    =     "
	echo "\$$DEBUG_FFLAGS  =     "
	echo "\$$CCOMPILER     =     $(CC)"
	echo "\$$BASE_CFLAGS   =     -c $(CFLAGS)"
	echo "\$$PROD_CFLAGS   =     "
	echo "\$$DEV_CFLAGS    =     "
	echo "\$$DEBUG_CFLAGS  =     "
	echo "\$$OMP_FFLAGS    ="
	echo ""
	echo "# Preprocessor"
	echo "\$$FPP_FLAGS     =     $(CPPFLAGS)"
	echo "\$$CPP_FLAGS     =     $(CPPFLAGS)" 
	echo ""
	echo "# Linker"
	echo "\$$LINK          =     $(FC)"
	echo "\$$BASE_LD       =     $(LDFLAGS)"
	echo "\$$OMP_LD        ="
	echo "\$$LD_EXE_TO_SHARED =  "
	echo ""
	echo "# Other" 
	echo "\$$AR            =     $(AR)"

'
  (. $MESONHPROFILE; make -f <(echo -e "$MAKEFILE") -s -I $(dirname $MESONHPROFILE)/../src archfile) | sed 's/-D//g' > $ARCHFILE
}

function build_compilation_script() {
srcdir=$1

#fcm doesn't like if a source directory doesn't exist.
#To be able to compile an old commit, we must filter the source directories
TESTPROGS_DIR=""
#support is not a testprog but is needed
for testprog in ice_adjust rain_ice turb_mnh shallow rain_ice_old support; do
  [ -d $srcdir/$testprog ] && TESTPROGS_DIR+="src/$testprog "
done

cat <<EOF > compilation.sh
#!/bin/bash

. arch.env

level=PROD #PROD DEV or DEBUG

#fcm variables begin with a dollar sign

COMPIL_FFLAGS="\\\$\${level}_FFLAGS"
COMPIL_FFLAGS="\$COMPIL_FFLAGS \\\$OMP_FFLAGS"

COMPIL_CFLAGS="\\\$\${level}_CFLAGS"

LD_FLAGS="\\\$BASE_LD"
LD_FLAGS="\$LD_FLAGS \$OMP_LD"

LIBS="rt dl"

ENTRYPOINTS="rain_ice.o shallow_mf.o turb.o ice_adjust.o"

FCM_ARGS="$FCM_ARGS"

echo "\\\$COMPIL_FFLAGS = \$COMPIL_FFLAGS" > config.fcm
echo "\\\$COMPIL_CFLAGS = \$COMPIL_CFLAGS" >> config.fcm
echo "\\\$LD_FLAGS = \$LD_FLAGS" >> config.fcm
echo "\\\$ENTRYPOINTS = \$ENTRYPOINTS" >> config.fcm
echo "\\\$LIBS = \$LIBS" >> config.fcm
echo "\\\$TESTPROGS_DIR=$TESTPROGS_DIR" >> config.fcm

export PATH=$PWD/../fcm/bin/:\$PATH

echo "This script has generated config.fcm which is included by fcm-make.cfg, the FCM configuration file."
echo "Running : fcm make \$FCM_ARGS"

fcm make \$FCM_ARGS
EOF
chmod +x compilation.sh
}

####################################

# Parse command line arguments
parse_args $*

# Change current working dir
cd -P $(dirname $0)

# Check the fcm installation
check_install_fcm

# Check the fiat installation
check_install_fiat

# Create the build directory and set up the build system
builddir=arch_$ARCH
if [ -d $builddir ]; then
  echo "$builddir already exists. To rerun compilation, please enter this directory and use the compilation.sh script."
  echo "Otherwise, you can remove the $builddir directory and execute again this script."
  exit 1
fi
mkdir $builddir
if [ "$GMKFILE" != "" ]; then
  touch $builddir/arch.env
  gmkfile2arch $GMKFILE $builddir/arch.fcm
elif [ "$MESONHPROFILE" != "" ]; then
  touch $builddir/arch.env
  mesonhprofile2archenv $MESONHPROFILE $builddir/arch.fcm $builddir/arch.env
else
  cp ${ARCH_PATH}/arch-${ARCH}.env $builddir/arch.env
  cp ${ARCH_PATH}/arch-${ARCH}.fcm $builddir/arch.fcm 
fi
cp fcm-make.cfg $builddir
cd $builddir

# Populate the source directory with (modified) PHYEX source code
[ "$commit" == "" ] && commit=$PWD/../../.. #Current script run from within a PHYEX repository
if echo $commit | grep '/' | grep -v '^tags/' > /dev/null; then
  # We get the source code directly from a directory
  fromdir=$commit
else
  # We use a commit to checkout
  fromdir=''
fi
#Expand options
if [ $useexpand == 1 ]; then
  expand_options="-D MNH_EXPAND -D MNH_EXPAND_LOOP"
else
  expand_options=""
fi
PHYEXTOOLSDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/../../../tools #if run from within a PHYEX repository
UPDATEDPATH=$PATH
which prep_code.sh > /dev/null || export UPDATEDPATH=$PHYEXTOOLSDIR:$PATH
subs="$subs -s turb -s shallow -s turb_mnh -s micro -s aux -s ice_adjust -s rain_ice -s rain_ice_old -s support"
if [ "$fromdir" == '' ]; then
  echo "Clone repository, and checkout commit $commit (using prep_code.sh)"
  if [[ $commit == testprogs${separator}* ]]; then
    PATH=$UPDATEDPATH prep_code.sh -c $commit src #This commit is ready for inclusion
  else
    PATH=$UPDATEDPATH prep_code.sh -c $commit $expand_options $subs -m testprogs src
  fi
else
  echo "Copy $fromdir"
  mkdir src
  scp -q -r $fromdir/src src/
  PATH=$UPDATEDPATH prep_code.sh $expand_options $subs -m testprogs src
fi

# Add some code
cd src
ln -s ../../fiat/src fiat
cat <<EOF > dummyprog.F90
PROGRAM DUMMYPROG
  PRINT*, "CREATED TO FORCE FCM TO LINK SOMETHING"
END PROGRAM DUMMYPROG
EOF

# Build the compilation script and run it
cd ..
build_compilation_script src
./compilation.sh
ln -s build/bin/libphyex.so .

# Check if python can open the resulting shared lib
python3 -c "from ctypes import cdll; cdll.LoadLibrary('./libphyex.so')"

# ldd -r ./libphyex.so should also give interesting results
