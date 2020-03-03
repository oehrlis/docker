##############################################################################
# $Id: 06d582279558d4528ffa571876641e04ebc6fbf5 $
##############################################################################
#
# FILE:    .profile for oracle user on server machines
#
# AUTHOR:  TRIVADIS AG, M. Wunderli, D. Wapenaar, 28-May-1999
#

umask 022

typeset BE_OH

# if the Oracle software owner is not "oracle", change it accordingly!
BE_OH=~oracle  # [ -f ~oracle/...] will not work
if [ "$BE_HOME" = "" ]; then
  if [ -f "$HOME/.BE_HOME" ]; then
  . "$HOME/.BE_HOME"
  elif [ -f "${BE_OH}/.BE_HOME" ]; then
  . "${BE_OH}/.BE_HOME"
  fi
fi

# where is initial perl ?
if [ "$TVDPERL_HOME" = "" ]; then
  if [ -f "$HOME/.TVDPERL_HOME" ]; then
  . "$HOME/.TVDPERL_HOME"
  elif [ -f "${BE_OH}/.TVDPERL_HOME" ]; then
  . "${BE_OH}/.TVDPERL_HOME"
  fi
fi

tty >/dev/null 2>&1
pTty=$?

xtitle () {
    set -A SavedArg -- $* 2>/dev/null #ksh?
    if [ $? -eq 0 ] ; then
      if [ "$TERM" = "xterm" -o "$TERM" = "xterm-color" ]; then
        $BE_ECHO "\033]0;$*\007\c"
      fi
    else  #bash
      if [ "$TERM" = "xterm" -o "$TERM" = "xterm-color" ]; then
        export PROMPT_COMMAND="echo -ne \"\033]0;$*\007\""
      fi
    fi
}

unalias go >/dev/null 2>&1
# if you define "go" as a function, uncomment the "go" alias in basenv.conf!!!

go () {
       ssh -X -A -l ${ORACLE_USER:-oracle} $*
       xtitle "`hostname`:$LOGNAME"
}

#Check basenv aliases if in conflict with existing command (per default only checked at install)
#export CHECK_BINARY_IN_PATH=1

# in case of RAC: should the alias of <db_unique_name> point to a dummy-envoronment (1)
#                 or to the locally running SID (0 or unset)
#export BE_RACALIAS_IS_DUMMYSID=1

#to set the environment only for interactive work, uncomment the following "if" / "fi" lines
# if [ ${pTty} -eq 0 ]; then
  . ${BE_HOME}/bin/basenv.sh
# fi
 
if [ ${pTty} -eq 0 ]; then

    xtitle `hostname`:$LOGNAME
    #stty erase 
    ${BE_HOME}/bin/oraup.ksh

fi

## choose your "erase" character
#stty erase 
#stty erase 


# ------------------------------------------------------------------------------
# Below this line basenv is started, you can add user specific settings
# ------------------------------------------------------------------------------

#================================================================= EOF
