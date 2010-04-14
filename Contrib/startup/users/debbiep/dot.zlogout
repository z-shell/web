#
# .zlogout: for logging out from login shells
# Written by Deborah Pickett <debbiep@csse.monash.edu.au>
# with large wads (or not) taken from others.
#

# This file is sourced when logging out from a login shell (zsh -l).

# goofey signoff 1-liner, chosen randomly.
if [[ ${+USE_GOOFEY} -eq 1 && "$(goofey -lq)" -eq 1 ]]
then
  # Disable the signoff line until I can find some witty one-liners.
  goofey -x
  # Pick a random signoff line.
  #randline=$(( $RANDOM % $(wc -l < $HOME/etc/1lines) + 1 ))
  #goofey -x - "`sed -n ${randline}p $HOME/etc/1lines`"
fi


