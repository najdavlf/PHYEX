#!/bin/bash

fcm_version=tags/2021.05.0
fiat_version=1295120464c3905e5edcbb887e4921686653eab8

function parse_args()
{
    # default values
    ARCH_PATH=$PWD/arch
    ARCH=gnu
    # pass unrecognized arguments to fcm
    FCM_ARGS=""
    
    while (($# > 0))
    do
	OPTION="$1" ; shift
	case "$OPTION" in
	    "-h") cat <<EOF
	    Usage :
$0 [options]
--help -h   help
--arch-path ARCH_PATH directory for architecture specific files (see below) [./arch]
--arch ARCH  	        build using arch files $ARCH_PATH/arch-ARCH.* [gnu]

Unrecognized options are passed to the fcm build command. Useful options include :
--full                  clean build tree before building
--jobs N                parallel build, similar to make -j N
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
	    *)
		FCM_ARGS="$FCM_ARGS $OPTION"
		;;
	esac
    done
}

function check_install_fcm()
{
  if [ ! -f fcm/bin/fcm ]; then
    echo "Performing FCM installation..."
    cd fcm
    rm -f .gitkeep
    git clone https://github.com/metomi/fcm.git .
    git checkout tags/$fcm_version
    touch .gitkeep
    cd ..
    echo "...FCM installation done"
  fi
}

function check_install_fiat()
{
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

function build_compilation_script()
{
cat <<EOF > compilation.sh
#!/bin/bash

. arch.env

COMPIL_FFLAGS="%PROD_FFLAGS"
COMPIL_FFLAGS="\$COMPIL_FFLAGS %OMP_FFLAGS"

LD_FLAGS="%BASE_LD"
LD_FLAGS="\$LD_FLAGS %OMP_LD"

#DEPS_LIB="\$NETCDF_LIBDIR \$NETCDF_LIB \$HDF5_LIBDIR \$HDF5_LIB"

FCM_ARGS=$FCM_ARGS

echo "%COMPIL_FFLAGS \$COMPIL_FFLAGS" > config.fcm
echo "%LD_FLAGS \$LD_FLAGS" >> config.fcm
echo "%CPP_KEY \$CPP_KEY" >> config.fcm
echo "%LIB">> config.fcm

export PATH=$PWD/../fcm/bin/:\$PATH

echo "This script has generated config.fcm which is included by bld.cfg, the FCM configuration file."
echo "Running : fcm build \$FCM_ARGS"
echo "Be patient while FCM first pre-processes all .F90 source files which may take about 30s."

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

# Create the build directory and populate it
builddir=arch_$ARCH
if [ -d $builddir ]; then
  echo "$builddir already exists. To rerun compilation, please enter this directory and use the compilation.sh script."
  echo "Otherwise, you can remove the $builddir directory and execute again this script."
  exit 1
fi
mkdir $builddir
cp ${ARCH_PATH}/arch-${ARCH}.env $builddir/arch.env
cp ${ARCH_PATH}/arch-${ARCH}.fcm $builddir/arch.fcm 
cp fcm-make.cfg $builddir
cd $builddir
mkdir src
cd src
ln -s ../../../../src/common .
ln -s ../../fiat/src fiat
cd ..
build_compilation_script

# Run the compilation
./compilation.sh
