#!/bin/zsh

# Update version and file sizes in Doc/index.html and Arc/source.html and
# verify all downloads work and have valid GPG signatures.

set -eu
setopt extendedglob

update_last_modified() {
    local -a baks
    baks=( $^@.sedbak )
    sed -i.sedbak 's/^Last modified: .*/Last modified: '"$(date '+%Y-%m-%d')"'/' "$@"
    rm -f -- $baks # BSD sed requires back-ups with -i
}

formatted_size() {
    du -sh -- "$@" | awk '{print $1}' | sed 's/K$/KiB/; s/M$/MiB/;'
}
update_size() {
    local file=$1
    local size=$2
    shift
    shift
    perl -pi -e 's/\d+(?:\.\d+)?[KM]iB/'$size'/ if /'$file'/' "$@"
}


if [[ $# -ne 1 ]]; then
    echo "usage: $0 <zsh-version>" >&2
    exit 1
fi

export LC_ALL=C


# Update version in download files.
perl -pi -e 's#(zsh(?:-doc)?[ /-])[0-9]+\.[0-9]+(?:\.[0-9])?#${1}'$1'#g' \
    Arc/source.html

echo 'Downloading release files for GPG verification and size updates ...'
t=$(mktemp -d)
for x in $(grep -o 'https://sourceforge.net[^"]*' Arc/source.html | grep -F $1); do
    (cd $t && wget --content-disposition $x)
done
# wget doesn't seem to use the Content-Disposition name consistently, which
# (sometimes?) results in the addition of ?viasf=1 to the end of the file name.
# There's surely a better way to deal with this, but for now let's just manually
# strip any trailing ?*s from the downloaded file names
for x in $t/*\?*(#qN); do
    mv $x ${x%\?*}
done
for x in $t/*.asc; do
    gpg --verify-files $x
done
echo 'Verified download signatures'
for x in $t/*~*.asc; do
    update_size ${x:t} "$(formatted_size $x)" Arc/source.html
done
rm -r $t

update_last_modified Arc/source.html
echo 'Updated Arc/source.html'


for x in $(grep -E -o 'zsh[^"]+\.(gz|pdf)' Doc/index.html); do
    update_size ${x:t} "$(formatted_size Doc/$x)" Doc/index.html
done
update_last_modified Doc/index.html
echo 'Updated Doc/index.html'
