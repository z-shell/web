#
# .zlogin: for login shells (zsh -l)
# Written by Deborah Pickett <debbiep@csse.monash.edu.au>
# with large wads written by others.
#

# Here are various things that only apply to login shells.
# Since this is only run once per session, it supplies the
# usual login messages, such as trash directory usage and
# mail that may have arrived.

# re-alias lo to mean logout, not exit.
# just stops zsh printing logout when I type lo in a login shell 
alias lo=logout

# make a new .signature file
makesig >! ~/.signature

# register on goofey if I am using it
if [[ ${+USE_GOOFEY} -eq 1 ]]
then
  goofey -Fn
  fortcheck
fi

## turn on biff if it is present to alert me of new mail.
#if [[ -x /usr/ucb/biff ]]
#then
#  biff y
#fi

# tell me what mail I have
#frm -q -S
checkmail

# remove files I never want to see
if [[ ! -s "$HOME/.xsession-errors" ]]
then
  # only remove if it is empty.
  /bin/rm -f "$HOME/.xsession-errors"
fi

# Tell me how much stuff is in the .trash directory . . .
trash-purge -u
# . . . and list it (won't list anything if it's empty)
trash-purge -l

# Check to see if this is a console login from xdm
if [[ ${+ISACONSOLE} -eq 1 ]]
then
  # put the word "console" in the xterm title
  XTTITLECONS=' console'
  # unexport ISACONSOLE.  Don't unset it, just stop subshells from
  # getting it.
  typeset +x ISACONSOLE
fi

# Perform a null command to set exit status to zero at first prompt
:

