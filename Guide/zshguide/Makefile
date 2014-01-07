# You need Yodl to handle this.  I have 1.31.16 and this Makefile works
# around a few problems in that version.

.SUFFIXES: .yo .txt .html .tex .latex .dvi .ps .pdf

CHAPTERS = c1.yo c2.yo c3.yo c4.yo c5.yo c6.yo c7.yo
SRC_DIST = Makefile zshguide.yo $(CHAPTERS)
DTD = <!doctype html public "-//w3c//dtd html 4.0 transitional//en">

.latex.pdf:
	while pdflatex $< | perl -pe '/should run.*again/ && $$run++; '\
	'/^LaTeX Warning:.*Rerun/ && $$run++; '\
	'eof && exit(!$$run);'; do true; done
.yo.txt:
	yodl2txt $<

.yo.html:
	yodl2html $<
	for file in $(<:%.yo=%)*.html; do \
	  { echo '$(DTD)'; cat $$file; } > $$file.tmp; \
	  mv $$file.tmp $$file; \
	done

# Yuk, sorry.
# Inline xlatin1.tex, because most people don't have that.
# Remove excrescent space after `begin{verbatim}'.
# Fix whitespace problem after \textbackslash: one space should
# be ignored, two spaces indicate that one of them is `real' so
# needs escaping.
# This is becase verb() constructs have been squeezed as far as
# possible to work around variant handling of the <pre> blocks
# in the HTML versions.  You can't fool all the formatting tools
# all the time.
PERLCOMMON = "\\usepackage[T1]{fontenc}\n", \
	  "\\usepackage{newcent}\n", "\\usepackage{courier}\n", \
	  "\\pretolerance=10000\n\n"; \
	  $$print = 1; } elsif (/^\\input\{(.*xlatin1\.tex)/) { \
	    open(TMP, "$$1") || die ("cant open $$1\n"); \
	    while(<TMP>) { print unless /endinput/; } \
	    close(TMP); \
	  } elsif ($$print) { \
		s/(\{verbatim\}) /$$1/g; \
		s/(\\textbackslash)  /$$1\\ /g; \
		print; \
	  }

.yo.latex:
	yodl2latex $<
	cp $@ tmp.latex
	perl -ne 'if (/^\\usepackage/) { \
	  print "\\documentclass[a4paper]{book}\n", '\
	'  "\\usepackage{a4wide}\n", $(PERLCOMMON)' \
	$@ > $@.tmp  &&  mv $@.tmp $@
	perl -ne 'if (/^\\usepackage/) { '\
	'  print "\\documentclass{book}\n", '\
	'  $(PERLCOMMON)' \
	tmp.latex > $*_us.latex
	rm -f tmp.latex

.latex.dvi:
	if latex $< | perl -pe '/should run.*again/ && $$run++; '\
	'/^LaTeX Warning:.*Rerun/ && $$run++; '\
	'eof && exit(!$$run);'; then \
	latex $<; \
	fi
.dvi.ps:
	dvips $<

most: zshguide.html zshguide.latex zshguide.txt

all: zshguide.html zshguide.latex zshguide.txt zshguide.pdf \
	zshguide_us.pdf

zshguide.txt zshguide.html zshguide.latex: zshguide.yo $(CHAPTERS)

zshguide.pdf zshguide_us.pdf zshguide.dvi: zshguide.latex

# zshguide.ps: zshguide.dvi

.PHONY: web clean

GUIDE_WEB = ..

web:    zshguide.html zshguide.latex zshguide.pdf zshguide_us.pdf
	rm -rf zshguide
	mkdir zshguide
	cp $(SRC_DIST) zshguide
	tar cvzf zshguide.tar.gz zshguide
	mv zshguide.tar.gz $(GUIDE_WEB)
	cp zshguide*.html zshguide.latex zshguide.pdf zshguide_us.pdf \
	  $(GUIDE_WEB)

clean:
	rm -f zshguide*.html zshguide*.txt zshguide*.tex zshguide*.latex \
	zshguide*.dvi zshguide.pdf zshguide*.ps zshguide.aux zshguide.toc \
	zshguide*.log zshguide*.pdf *~ zshguide*.aux zshguide*.toc \
	zshguide*.tmp tmp.latex
