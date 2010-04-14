########################################
#
# .zshenv: zsh environment settings
# Written by Deborah Pickett <debbiep@csse.monash.edu.au>
# with large wads taken from others.
#
########################################

# Since .zshenv is sourced for every invocation of zsh, it is vital that
# it run quickly.  Only environment variables that must be set for
# a noninteractive shell are set here.  If external commands must be run
# here they are kept to a bare minimum and exported shell variables
# remember the results to keep them from needing to be run again.

###############
# zsh functions

# Most functions are auto-loaded later on, but some are defined
# explicitly since they're needed by the startup files and would
# automatically be loaded in any case.

# rationalize-path()
# Later we'll need to trim down the paths that follow because the ones
# given here are for all my accounts, some of which have unusual
# paths in them.  rationalize-path will remove
# nonexistent directories from an array.
rationalize-path () {             
  # Note that this works only on arrays, not colon-delimited strings.
  # Not that this is a problem now that there is typeset -T.
  local element
  local build
  build=()
  # Evil quoting to survive an eval and to make sure that
  # this works even with variables containing IFS characters, if I'm
  # crazy enough to setopt shwordsplit.
  eval '
  foreach element in "$'"$1"'[@]"
  do
    if [[ -d "$element" ]]
    then
      build=("$build[@]" "$element")
    fi
  done
  '"$1"'=( "$build[@]" )
  '
}

# zsh-version
# Return true (0) if the running version of ZSH is equal to
# or more recent than the one requested.  I need this because of all the
# bleeding-edge zsh features I use here. :)  Cache the results for
# speed, if associative arrays are available.
# The zsh distribution comes with the is-at-least function to do the
# same job, but I'd already written this before I found that out. :)

zsh-version ()
{
  # If this result is cached . . 
  if [[ ${+zshversioncache} -eq 1 && ${+zshversioncache[$1]} -eq 1 ]]
  then
    return $zshversioncache[$1]
  fi

  local running
  local wanted

  # Split the things to compare into two arrays.
  running=(${(s:.:)ZSH_VERSION})
  wanted=(${(s:.:)1})

  # Compare parts until we have an answer.
  while [[ $#running -gt 0 ]]
  do
    # Now compare each first part.
    if [[ $running[1] -lt $wanted[1] ]]
    then
      if [[ ${+zshversioncache} -eq 1 ]]
      then
         zshversioncache[$1]=1
      fi
      return 1    # Failure, want more recent than we have
    elif [[ $running[1] -gt $wanted[1] ]]
    then
      if [[ ${+zshversioncache} -eq 1 ]]
      then
         zshversioncache[$1]=0
      fi
      return 0    # Success, running newer version
    else
      shift running  # Look at next part of version
      shift wanted
    fi
  done
  if [[ $#wanted -gt 0 ]]
  then
    if [[ ${+zshversioncache} -eq 1 ]]
    then
       zshversioncache[$1]=1
    fi
    return 1  # Failure, wanted version has an extra part and is thus later
  else
    if [[ ${+zshversioncache} -eq 1 ]]
    then
       zshversioncache[$1]=0
    fi
    return 0  # Exactly the same version
  fi
}
if zsh-version 3.1.6
then
  # Associative arrays are available.
  typeset -A zshversioncache
  zshversioncache=( )
fi

###############
# Shell options

# These are the options that apply to noninteractive shells.
# Ones in capitals are variations from the default ZSH behaviour.
setopt \
  no_allexport \
  badpattern \
  no_bsdecho \
  no_chaselinks \
  NO_CLOBBER \
  no_cshjunkieloops \
  no_cshjunkiequotes \
  no_cshnullglob \
  equals \
  no_errexit \
  exec \
  EXTENDEDGLOB \
  functionargzero \
  glob \
  no_globassign \
  GLOBDOTS \
  no_globsubst \
  hashcmds \
  hashdirs \
  no_ignorebraces \
  no_ksharrays \
  no_localoptions \
  no_magicequalsubst \
  no_markdirs \
  multios \
  nomatch \
  no_nullglob \
  NUMERICGLOBSORT \
  no_pathdirs \
  no_posixbuiltins \
  no_printexitvalue \
  PUSHDIGNOREDUPS \
  PUSHDMINUS \
  PUSHDSILENT \
  PUSHDTOHOME \
  no_rcexpandparam \
  no_rcquotes \
  rcs \
  no_shfileexpansion \
  no_shglob \
  no_shoptionletters \
  shortloops \
  no_shwordsplit \
  unset
if zsh-version 3.0.6
then
  setopt \
    bareglobqual \
    no_kshautoload \
    no_kshglob \
    no_printeightbit \
    no_restricted
fi
if zsh-version 3.1.6
then
  setopt \
    no_chasedots \
    globalrcs \
    no_localtraps
fi
if zsh-version 3.1.8
then
  setopt \
    no_cshnullcmd \
    NO_GLOBALEXPORT \
    no_octalzeroes \
    no_shnullcmd
fi

###############
# Paths for zsh

# Path for cd to search; used to need to explicitly set "." for the cdmatch
# function (and retained for backward compatibility).
cdpath=( . )
export CDPATH
# Only unique entries please.
typeset -U cdpath

# Path to search for autoloadable functions.
fpath=( $HOME/lib/zsh/func "$fpath[@]" )
export FPATH
# Only unique entries please.
typeset -U fpath

# Include function path in script path so that we can run them even
# though a subshell may not know about functions.
# PATH should already be exported, but in case not. . .
path=(
  "$HOME/bin/$MACHTYPE-$OSTYPE"
  "$HOME/bin"
  /usr/local/bin
  /usr/local/sbin
  /usr/local/etc
  /sbin
  /etc
  /bin
  /usr/bin
  /usr/sbin
  /usr/ucb
  /usr/bsd
  /usr/X11/bin
  /usr/bin/X11
  /usr/local/X11/bin
  /usr/monash/X11/bin
  /usr/monash/bin
  /usr/monash/etc
  /usr/monash/gnu/bin
  /usr/monash/contrib/bin
  /usr/monash/contrib/etc
  /usr/monash/contrib/X11/bin
  /usr/local/contrib/lib/kde/bin
  /usr/local/tex/bin
  /usr/local/lib/zsh/scr
  /usr/monash/contrib/games
  /usr/local/games
  /usr/monash/games
  /usr/games
  "$path[@]"
  "$fpath[@]"
)
export PATH
# Only unique entries please.
typeset -U path
# Remove entries that don't exist on this system.  Just for sanity's
# sake more than anything.
rationalize-path path

# My mail folders
mailpath=(
"/usr/spool/mail/$LOGNAME?You inexplicably have new mail in /usr/spool/mail/$LOGNAME"
"$HOME/Mail/inbox?You have new mail in ~/Mail/inbox"
"$HOME/Mail/junk?You have junk mail in ~/Mail/junk"
"$HOME/Mail/uni?You have university mail in ~/Mail/uni"
"$HOME/Mail/fdcmuck?You have FDCMuck mail in ~/Mail/fdcmuck"
"$HOME/Mail/mermaid?You have mermaid-list mail in ~/Mail/mermaid"
"$HOME/Mail/moderators?You have moderators-list mail in ~/Mail/moderators"
"$HOME/Mail/picture?You have picture-list mail in ~/Mail/picture"
"$HOME/Mail/life-l?You have life-list mail in ~/Mail/life-l"
"$HOME/Mail/murp-l?You have murp-list mail in ~/Mail/murp-l"
"$HOME/Mail/zsh?You have zsh mail in ~/Mail/zsh"
"$HOME/Mail/billabong?You have billabong mail in ~/Mail/billabong"
"$HOME/Mail/dryland?You have dryland mail in ~/Mail/dryland"
"$HOME/Mail/fdcoz?You have FDCoz mail in ~/Mail/fdcoz"
"$HOME/Mail/ldl?You have linux-dell-laptops mail in ~/Mail/ldl"
)
export MAILPATH


######################
# functions, continued

# Now that FPATH is set correctly, do autoloaded functions.
# autoload all functions in $FPATH - that is, all files in
# each component of the array $fpath.  If there are none, feed the list
# it prints into /dev/null.
for paths in "$fpath[@]"
do
  # -U switch is more recent.
  if zsh-version 3.1.6
  then
    autoload -U "$paths"/*(N:t) >/dev/null
  else
    autoload "$paths"/*(N:t) >/dev/null
  fi
done
unset paths


#################
# zsh environment

# The mail folder my mail clients default to.
export MAIL="$HOME/Mail/inbox"

# Command to use when redirecting from/to a null command.
# READNULLCMD is redefined in .zshrc for interactive shells.
READNULLCMD=cat
NULLCMD=cat

# Size of the directory stack (pushd et al)
DIRSTACKSIZE=12

# Size of history list
HISTSIZE=200

# Unix groups: remember the original group ID.  (For prompts.)
if [[ ${+ORIGGID} -eq 0 ]]
then
  export ORIGGID="$GID"
fi


######################################
# Other programs' environment settings

# MANPATH: path for the man command to search.
# Look at the manpath command's output and prepend
# my own manual paths manually (ahem).
if [[ ${+MANPATH} -eq 0 ]]
then
  # Only do this if the MANPATH variable isn't already set.
  if whence manpath >/dev/null 2>&1
  then
    # Get the original manpath, then modify it.
    MANPATH="`manpath`"
    manpath=(
      "$HOME/man"
      "$manpath[@]"
    )
  else
    # This list is out of date, but it will suffice.
    manpath=(
      "$HOME/man"
      /usr/monash/contrib/man
      /usr/monash/gnu/man
      /usr/local/man
      /usr/monash/man
      /usr/man
      /usr/man/preformat
      /usr/X11/man
      /use/openwin/man
      /usr/monash/tex/man
    )
    rationalize-path manpath
  fi
  # And, as always, no duplicate entries are needed.
  typeset -U manpath
  export MANPATH
fi

# Path for info, the Anti-man(tm), to search.
export INFOPATH=/usr/monash/contrib/info:/usr/local/info:/usr/monash/info:\
/usr/info:/usr/emacs/info:.
# Do the usual path-y things.  The lowercase array one isn't used by the
# info command, but it helps us to rationalize-path it.
if zsh-version 3.1.6
then
  typeset -T INFOPATH infopath
  rationalize-path infopath
  typeset -U infopath
fi

# Path to Qt, needed for KDE.
export QTDIR=/usr/monash/contrib/lib/qt

# Path for dynamic loading of libraries.
export LD_LIBRARY_PATH=/usr/monash/contrib/lib:\
/usr/monash/contrib/lib/qt/lib:\
/usr/monash/contrib/lib/kde/lib:\
"$HOME/lib/$MACHTYPE-$OSTYPE"
# Do the usual path-y things.  The lowercase array one isn't used by the
# system, but it helps us to rationalize-path it.
if zsh-version 3.1.6
then
  typeset -T LD_LIBRARY_PATH ld_library_path
  rationalize-path ld_library_path
  typeset -U ld_library_path
fi

# less options.
if [[ ${+LESS} -eq 0 ]]
then
  export LESS='-deiq'
  # Underline non-printable characters and print them in hex
  # inside square brackets.
  export LESSBINFMT='*u[%X]'
  export LESSCHARSET=latin1
fi

# default pager
if [[ ${+PAGER} -eq 0 ]]
then
  if whence less >/dev/null 2>&1
  then
    export PAGER="`whence less`"
  fi
fi

# default editor
if [[ ${+EDITOR} -eq 0 ]]
then
  if whence vim >/dev/null 2>&1
  then
    export EDITOR="`whence vim`"
  fi
fi

# perl
# Search these places for perl include files.  Other paths are hopefully
# configured properly already.
export PERL5LIB="$HOME/lib/perl5:$HOME/lib/perl5/site_perl"

# NNTP server for news
export NNTPSERVER=newsserver.cc.monash.edu.au

# ispell
export WORDLIST="$HOME/.ispell_words"

# goofey
# Goofey is a chat-style program used at Monash University.  It predates
# ICQ and other newfangled notions by several years.  I don't always use
# it, since it requires a fairly reliable net connection.
# If there is a file ~/.usegoofey then we'll try to use goofey on this
# system.  Otherwise we'll pretend it doesn't exist and skip all
# related things in startup files and periodic checks.
if [[ ${+USE_GOOFEY} -eq 0 && ${+NO_USE_GOOFEY} -eq 0 && -f $HOME/.usegoofey ]]
then
  # note goofey is being used
  export USE_GOOFEY=1
  #export GOOFEYUSER=debbie
else
  # note that it isn't being used.
  export NO_USE_GOOFEY=
fi

# Note that we're now running under a ZSH, so that future subshells can
# skip some of these steps if they want.  (Not that this is used at the
# moment, but it's there in case I do want to do it.)
export UNDERZSH=$$

