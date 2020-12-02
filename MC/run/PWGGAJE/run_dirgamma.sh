#!/usr/bin/env bash

# Generate gamma-jet events, Pythia8 in a given pt hard bin.
# Execute: ./run_dirgamma.sh 
# Set at least before running PTHATBIN with 1 to 6

#set -x 

# ----------- LOAD UTILITY FUNCTIONS --------------------------
. ${O2_ROOT}/share/scripts/jobutils.sh

# ----------- START ACTUAL JOB  ----------------------------- 

RNDSEED=${RNDSEED:-0}   # [default = 0] time-based random seed

NSIGEVENTS=${NSIGEVENTS:-20}
NWORKERS=${NWORKERS:-8}
MODULES="--skipModules ZDC" #"PIPE ITS TPC EMCAL"
CONFIG_ENERGY=${CONFIG_ENERGY:-5020.0}
CONFIG_NUCLEUSA=${CONFIG_NUCLEUSA:-2212}
CONFIG_NUCLEUSB=${CONFIG_NUCLEUSB:-2212}

# Define the pt hat bin arrays
pthatbin_loweredges=(5 11 21 36 57 84)
pthatbin_higheredges=(11 21 36 57 84 -1)

# Recover environmental vars for pt binning
#PTHATBIN=${PTHATBIN:-1} 

if [ -z "$PTHATBIN" ]; then
    echo "Pt-hat bin (env. var. PTHATBIN) not set, abort."
    exit 1
fi

PTHATMIN=${pthatbin_loweredges[$PTHATBIN]}
PTHATMAX=${pthatbin_higheredges[$PTHATBIN]}

# Generate Pythia8 gamma-jet configuration
${O2DPG_ROOT}/MC/config/common/pythia8/utils/mkpy8cfg.py \
        --output=pythia8_dirgamma.cfg \
        --seed=${RNDSEED}             \
        --idA=${CONFIG_NUCLEUSA}      \
        --idB=${CONFIG_NUCLEUSB}      \
        --eCM=${CONFIG_ENERGY}        \
        --process=dirgamma            \
        --ptHatMin=${PTHATMIN}        \
        --ptHatMax=${PTHATMAX}

# Generate signal 
taskwrapper sgnsim.log o2-sim -j ${NWORKERS} -n ${NSIGEVENTS}               \
           -g pythia8 -m ${MODULES}                                         \
           --configKeyValues "GeneratorPythia8.config=pythia8_dirgamma.cfg" \
           -o sgn
 
# We need to exit for the ALIEN JOB HANDLER!
exit 0
