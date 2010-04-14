MD5 = md5sum

.SUFFIXES: .yo .txt .html

.yo.txt:
	yodl2txt $<

.yo.html:
	yodl2html $<

all: index.html zshfaq.txt

index.html: zshfaq.html
	cp zshfaq.html index.html

zshfaq.txt: zshfaq.yo
zshfaq.html: zshfaq.yo

zshfaq.yo.uu: zshfaq.yo
	gzip <zshfaq.yo | uuencode zshfaq.yo.gz >zshfaq.yo.uu

zshfaq.txt.uu: zshfaq.txt
	gzip <zshfaq.txt | uuencode zshfaq.txt.gz >zshfaq.txt.uu

zshfaq.html.tar.gz.uu: zshfaq.html
	tar cvf - zshfaq*html | gzip | uuencode zshfaq.html.tar.gz >$@

.PHONY: post postfaq postsrc clean
post:  postfaq postdiffs postftp

postfaq: zshfaq.txt.uu
	mhmail -s 'Z-Shell (zsh) FAQ' <zshfaq.txt.uu \
	johanm@camline.com

postdiffs: faqpost.txt
	mhmail -s 'Z-Shell (zsh) FAQ changes this month' \
	<faqpost.txt zsh-users@sunsite.dk

postftp: zshfaq.txt
	$(MD5) zshfaq.txt | perl -pe 'tr/A-Z/a-z/' >md5.tmp
	echo unlink FAQ >msg.tmp
	echo create FAQ 0644 `awk '{ print $$1 }' md5.tmp` >>msg.tmp
	uuencode zshfaq.txt FAQ | sed '1d' >>msg.tmp
	pgp -sat -u pws@pwstephenson.fsnet.co.uk msg.tmp
	mhmail -s 'Latest version of FAQ' <msg.tmp.asc ftpupdate@zsh.org
	rm -f msg.tmp* md5.tmp

clean:
	rm -f zshfaq.txt *.uu *~ \#*\#
