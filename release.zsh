#!/bin/zsh

# Update documentation and FAQ.

set -e
setopt nonomatch


if [[ -z $ZSHPATH ]]; then
    echo "ZSHPATH must be set to a zsh checkout."
    exit 1
fi

autoload -Uz zmv

# Cleanup old FAQ/ files.
rm -f FAQ/zshfaq.txt FAQ/zshfaq.yo FAQ/zshfaq*.html FAQ/zshfaq.html.tar.gz
# Create FAQ/ files.
(
    cd $ZSHPATH/Etc || exit 1
    make FAQ FAQ.html
    zmv 'FAQ(*).html' 'zshfaq$1.html'
    perl -i -pe 's{\./FAQ}{zshfaq}' zshfaq*.html
    # Create zshfaq.html.tar.gz.
    mkdir zshfaq
    cp zshfaq*.html zshfaq/
    chmod 0755 zshfaq; chmod 0644 zshfaq/*
    tar cfz zshfaq.html.tar.gz zshfaq
    rm -r zshfaq
) || exit 1
mv $ZSHPATH/Etc/zshfaq*.html $ZSHPATH/Etc/zshfaq.html.tar.gz FAQ/
cp $ZSHPATH/Etc/FAQ FAQ/zshfaq.txt
cp $ZSHPATH/Etc/FAQ.yo FAQ/zshfaq.yo

# Cleanup old Doc/ files, except some files which are not autogenerated.
rm -f Doc/zsh*
mv Doc/Release/{front.html,index-frame.html,indices.html,toc-chapters.html} .
rm -f Doc/Release/*(.)
mv {front.html,index-frame.html,indices.html,toc-chapters.html} Doc/Release
# Create Doc/ files.
(
    cd $ZSHPATH/Doc || exit 1
    make everything ps dvi pdf
    # Create zsh_html.tar.gz.
    mkdir zsh_html
    cp *.html zsh_html/
    chmod 0755 zsh_html; chmod 0644 zsh_html/*
    tar cfz zsh_html.tar.gz zsh_html
    rm -r zsh_html
    # Create zsh_info.tar.gz.
    mkdir zsh_info
    cp zsh.info* zsh_info/
    chmod 0755 zsh_info; chmod 0644 zsh_info/*
    tar cfz zsh_info.tar.gz zsh_info
    rm -r zsh_info
) || exit 1
cp $ZSHPATH/Doc/*.html Doc/Release/
mv $ZSHPATH/Doc/zsh_html.tar.gz $ZSHPATH/Doc/zsh_info.tar.gz Doc/
cp $ZSHPATH/Doc/zsh_*.ps $ZSHPATH/Doc/zsh.dvi $ZSHPATH/Doc/zsh.texi Doc/
cp $ZSHPATH/Doc/zsh.pdf Doc/zsh_a4.pdf
cd Doc && ps2pdf zsh_us.ps && cd ..
gzip --best Doc/zsh_*.ps Doc/zsh.dvi Doc/zsh.texi

# Cleanup old Intro/ files.
rm -f Intro/{intro.text,intro.*.ps.gz,intro*.pdf}
# Create Intro/ files. Only the PDF and PS versions are created from
# Doc/intro.ms - the texinfo version is no longer available, thus the HTML is
# also not up to date.
roff2text -ms < $ZSHPATH/Doc/intro.ms > Intro/intro.text
# Using pdfroff creates a PDF which contains the document twice, roff2pdf
# creates an empty PDF - thus use roff2ps (and we need the PS anyway).
roff2ps -ms -P-pa4     < $ZSHPATH/Doc/intro.ms > Intro/intro.a4.ps
roff2ps -ms -P-pletter < $ZSHPATH/Doc/intro.ms > Intro/intro.us.ps
(
    cd Intro || exit 1
    ps2pdf intro.a4.ps
    ps2pdf intro.us.ps
)
gzip --best Intro/intro.*.ps

echo "Done."
echo
echo "- Update date for 'News' in 'index.html'."
echo "- Add short release notes to 'News/index.html' (manually and from README)."
echo "- Add detailed release notes to 'releases.html' (mostly from NEWS)."
echo "- Don't forget to update the file names and sizes in:"
echo "  - Doc/index.html"
echo "  - Arc/source.html"
echo "- Commit."
echo "- Tag and sign the commits with git tag -s -m 'Release of zsh 5.X.X' zsh-5.X.X"
