.PHONY: update srcupdate docset update_and_targets
.SUFFIXES: .html .css

TARGET = build
TAR ?= tar

FILES = \
	print.css \
	stylesheet.css \
	api.html \
	applications.html \
	compatibility.html \
	configuration.html \
	contributions.html \
	documentation.html \
	documentation/developer.html \
	documentation/publications.html \
	documentation/user.html \
	documentation/user/configTool.html \
	documentation/user/configuration.html \
	documentation/user/synchronization.html \
	downloads.html \
	$(wildcard downloads/*.gz) \
	$(wildcard downloads/*.exe) \
	$(wildcard downloads/*.zip) \
	$(wildcard downloads/*.dmg) \
	$(wildcard downloads/*.bib) \
	$(wildcard gpu-sd/downloads/*.gz) \
	$(wildcard gpu-sd/downloads/*.exe) \
	$(wildcard gpu-sd/downloads/*.zip) \
	$(wildcard gpu-sd/downloads/*.dmg) \
	events.html \
	equalizer.rdf \
	favicon.ico \
	features.html \
	feedback.html \
	forum.html \
	impressum.html \
	index.html \
	lists.html \
	news.html \
	relnotes.html \
	scalability.html \
	gallery.html \
	search.html \
	support.html \
	survey.html \
	useCases.html \
        robots.txt \
	applications/index.html \
	applications/eqHello.html \
	applications/eqPly.html \
	applications/eVolve.html \
	applications/osgScaleViewer.html \
	applications/thirdParty.html \
	applications/UniSiegen.html \
	collage/print.css \
	collage/stylesheet.css \
        collage/robots.txt \
	collage/index.html \
	collage/documentation.html \
	documentation/parallelOpenGLFAQ.html \
	documentation/performance.html \
	documents/CV_Stefan_Eilemann.pdf \
	documents/directSend.pdf \
	documents/Developer/eqPly.pdf \
	documents/Developer/eqPlyPresentation.pdf \
	documents/EGPGV07.html \
	documents/EGPGV07.html_files \
	documents/EGPGV07.pdf \
	documents/Equalizer.html \
	documents/Equalizer.html_files \
	documents/Equalizer.pdf \
	documents/EqualizerGuide.html \
	documents/EqualizerGuide.html_files \
	documents/EqualizerGuide.pdf \
	documents/EqualizerGuide-0.4.pdf \
	documents/EqualizerTeaser.html \
	documents/EqualizerTeaser.html_files \
	documents/EqualizerTeaser.pdf \
	documents/EqualizerTR.pdf \
	documents/EqualizerVizSIG06.html \
	documents/EqualizerVizSIG06.html_files \
	documents/EqualizerVizSIG06.pdf \
	documents/FlyerWeb.pdf \
	documents/ParallelGraphicsProgramming.pdf \
	documents/ParallelGraphicsProgramming.html \
	documents/ParallelGraphicsProgramming.html_files \
	documents/EGPGV10_compositing.html \
	documents/EGPGV10_compositing.html_files \
	documents/EGPGV10_compositing.pdf \
	documents/EGPGV10_raster.html \
	documents/EGPGV10_raster.html_files \
	documents/EGPGV10_raster.pdf \
	documents/EGPGV12 \
	documents/EGPGV12.pdf \
	documents/Presentations/EqualizerBOF2009.pdf \
	documents/Presentations/EqualizerBOF2009.html \
	documents/Presentations/EqualizerBOF2009.html_files \
	documents/Presentations/EqualizerBOF2009_USG.pdf \
	documents/Presentations/EqualizerBOF2009_USG.html \
	documents/Presentations/EqualizerBOF2009_USG.html_files \
	documents/Presentations/EqualizerBOF2009_UZH.pdf \
	documents/Presentations/EqualizerBOF2009_UZH.html \
	documents/Presentations/EqualizerBOF2009_UZH.html_files \
	documents/Presentations/EqualizerBOF2009_UZH.html_files \
	documents/Projects_Stefan_Eilemann.pdf \
	documents/RelNotes/RelNotes_0.1.0.html \
	documents/RelNotes/RelNotes_0.2.0.html \
	documents/RelNotes/RelNotes_0.3.0.html \
	documents/RelNotes/RelNotes_0.4.0.html \
	documents/RelNotes/RelNotes_0.4.1.html \
	documents/RelNotes/RelNotes_0.5.0.html \
	documents/RelNotes/RelNotes_0.5.1.html \
	documents/RelNotes/RelNotes_0.5.2.html \
	documents/RelNotes/RelNotes_0.5.3.html \
	documents/RelNotes/RelNotes_0.5.4.html \
	documents/RelNotes/RelNotes_0.5.5.html \
	documents/RelNotes/RelNotes_0.6-rc1.html \
	documents/RelNotes/RelNotes_0.6.html \
	documents/RelNotes/RelNotes_0.9.html \
	documents/RelNotes/RelNotes_0.9.1.html \
	documents/RelNotes/RelNotes_0.9.2.html \
	documents/RelNotes/RelNotes_0.9.3.html \
	documents/RelNotes/RelNotes_1.0.html \
	documents/RelNotes/RelNotes_1.0.1.html \
	documents/RelNotes/RelNotes_1.0.2.html \
	documents/RelNotes/RelNotes_1.1.7.html \
	documents/RelNotes/RelNotes_1.2.html \
	documents/RelNotes/RelNotes_1.2.1.html \
	documents/RelNotes/RelNotes_1.3.5.html \
	documents/RelNotes/RelNotes_1.3.6.html \
	documents/RelNotes/RelNotes_1.4.0.html \
	documents/RelNotes/RelNotes_1.4.1.html \
	documents/glAsync/CHANGELOG \
	documents/glAsync/annotated.html \
	documents/glAsync/classglAsync_1_1Thread-members.html \
	documents/glAsync/classglAsync_1_1Thread.html \
	documents/glAsync/doxygen.css \
	documents/glAsync/doxygen.png \
	documents/glAsync/files.html \
	documents/glAsync/functions.html \
	documents/glAsync/functions_func.html \
	documents/glAsync/glAsync_8h-source.html \
	documents/glAsync/glAsync_8h.html \
	documents/glAsync/globals.html \
	documents/glAsync/globals_defs.html \
	documents/glAsync/globals_func.html \
	documents/glAsync/hierarchy.html \
	documents/glAsync/index.html \
	documents/glAsync/namespaceglAsync.html \
	documents/glAsync/namespacemembers.html \
	documents/glAsync/namespacemembers_func.html \
	documents/glAsync/namespaces.html \
	documents/glAsync/tab_b.gif \
	documents/glAsync/tab_l.gif \
	documents/glAsync/tab_r.gif \
	documents/glAsync/tabs.css \
	documents/Howtos/glutToEqualizer.html \
	documents/user/crComparison.html \
	downloads/DBCAAF49A0C0/ProgrammingUserGuide.pdf \
	downloads/DBCAAF49A0C0/index.html \
	downloads/developer.html \
	downloads/major.html \
	downloads/plugins.html \
	downloads/tools.html \
	downloads/source.html \
	gpu-sd/index.html \
	news/EgBof.html \
	news/EqualizerNewsJuly07.html \
	news/EqualizerNewsDecember07.html \
	news/Newsletter200910 \
	news/Release_0.1.html \
	news/Release_0.2.html \
	news/Release_0.3.html \
	news/Release_0.4.html \
	news/Release_0.5.html \
	news/Release_0.6.html \
	news/Release_0.9.html \
	news/Release_0.9.2.html \
	news/Release_1.0.html \
	news/Release_1.2.html \
	news/Release_1.4.html \
	news/tungsten.html \
	restricted/index.html \
	scalability/2D.html \
	scalability/DB.html \
	scalability/dfrEqualizer.html \
	scalability/DPlex.html \
	scalability/loadEqualizer.html \
	scalability/mixed.html \
	scalability/monitorEqualizer.html \
	scalability/multiview.html \
	scalability/paracomp.html \
	scalability/pixel.html \
	scalability/stereo.html \
	scalability/subpixel.html \
	scalability/tile.html \
	scalability/viewEqualizer.html \
	$(wildcard documents/WhitePapers/*.pdf) \
	$(IMAGES) \
	$(PAGES)

IMAGES_SRC = \
	$(wildcard images/*png) \
	$(wildcard images/*jpg) \
	$(wildcard collage/images/*png) \
	$(wildcard collage/images/*jpg) \
	$(wildcard images/NewsJune07/*gif) \
	$(wildcard images/NewsJune07/*jpg) \
	$(wildcard applications/images/*png) \
	$(wildcard applications/images/*jpg) \
	$(wildcard applications/images/UniSiegen/*jpg) \
	$(wildcard scalability/images/*png) \
	$(wildcard documents/design/images/*png) \
	$(wildcard screenshots/*)

MD_SRC = $(wildcard Equalizer.wiki/*.md)
HTML_SRC = $(wildcard documents/design/*.shtml) \
           $(MD_SRC:Equalizer.wiki/%.md=documents/design/%.shtml)

INCLUDES = \
	include/header.shtml \
	include/footer.shtml \
	include/collage.shtml \
	include/equalizer.shtml

TARGETS  = $(FILES:%=$(TARGET)/%)
IMAGES   = $(IMAGES_SRC) \
	   $(IMAGES_SRC:%.png=%-small.jpg) \
	   $(IMAGES_SRC:%.jpg=%-small.jpg)
PAGES    = $(HTML_SRC:%.shtml=%.html)
SITEMAP  = $(TARGET)/sitemap.xml.gz

GIT ?= git
MD2HTML ?= markdown_py-2.6 -x toc -x fenced_code
CPP_HTML = gcc -xc -ansi -E -C -Iinclude -Wno-extra-tokes -Wno-invalid-pp-token\
           -DUPDATE="`$(GIT) log -1 $< | grep 'Date:' | sed 's/Date:   //'`" \
           -DCHANGEURL=\"https://github.com/Eyescale/equalizergraphics.com/commits/master/$<\" \
           -DFULLURL=$(@:$(TARGET)%=http://www.equalizergraphics.com%) \
           -DPAGEURL=$(@:$(TARGET)%=%) \
           -DWIKIURL=$(<:documents/design/%.shtml=http://github.com/Eyescale/Equalizer/wiki/%)

all: $(TARGETS)

$(TARGETS):

clean:
	rm -rf $(TARGETS)

install: $(SITEMAP) srcbuild
	rsync -avz --exclude=".git" --exclude "*.docset" -e ssh $(TARGET)/ 80.74.159.177:var/www/www.equalizergraphics.com

install_web: $(SITEMAP)
	rsync -avz --exclude=".git" --exclude "*.docset" -e ssh $(TARGET)/ 80.74.159.177:var/www/www.equalizergraphics.com

install_only: all
	rsync -avz --exclude=".git" --exclude "*.docset" -e ssh $(TARGET)/ 80.74.159.177:var/www/www.equalizergraphics.com

auxinst: all
	rsync -avz --exclude=".git" --exclude "*.docset" --exclude "*.html" -e ssh $(TARGET)/ 80.74.159.177:var/www/www.equalizergraphics.com

$(SITEMAP): update_and_targets
	@sitemap_gen --config=sitemap_config.xml

update_and_targets: update
	 @$(MAKE) all

update: srcupdate nightlyupdate
	rm -f changes_log.html

srcupdate: this_up src_up docs_up wiki_up

this_up:
	-$(GIT) pull
src_up:
	-cd ../Equalizer; $(GIT) pull
docs_up:
	-cd ../EqDocs; $(GIT) pull
wiki_up:
	-cd Equalizer.wiki; $(GIT) pull

nightlyupdate:
	@mkdir -p $(TARGET)/downloads/nightly
	-rsync -avx eyescale.local:Software/equalizer/release/Equalizer-\* $(TARGET)/downloads/nightly

srcbuild:
	$(MAKE) BUILD=Release -C ../.. Lunchbox-doxygen
	$(MAKE) BUILD=Release -C ../.. gpu-sd-doxygen
	$(MAKE) BUILD=Release -C ../.. Equalizer-package

docset:
	$(MAKE) -C $(TARGET)/documents/Developer/API > 2&>1 > /dev/null
	@rm -f $(TARGET)/documents/Developer/API/ch.eyescale.Equalizer.docset.zip
	cd $(TARGET)/documents/Developer/API; \
	  zip -qr ch.eyescale.Equalizer.docset.zip ch.eyescale.Equalizer.docset

$(TARGET)/%.html : %.shtml $(INCLUDES)
	@mkdir -p $(@D)
	$(CPP_HTML) $< | sed 's/^#.*//' > $@

$(TARGET)/documents/RelNotes/RelNotes_%.html : documents/RelNotes/RelNotes-%.shtml $(INCLUDES) Equalizer-%/libs/RelNotes.dox
	@mkdir -p $(@D)
	$(CPP_HTML) $< | sed 's/^#.*//' > $@

Equalizer-%/libs/RelNotes.dox: downloads/Equalizer-%.tar.gz
	@tar xvzf $< $@

documents/design/%.shtml: Equalizer.wiki/%.md
	@mkdir -p $(@D)
	@head -1 $< | sed 's/# /#define TITLE /' > $@
	@cat include/mdHeader.shtml >> $@
	$(MD2HTML) $< | sed 's/\<h1 .*//' | sed 's/label{[a-zA-Z]*}//'>> $@
	@cat include/mdFooter.shtml >> $@

gpu-sd/index.shtml: ../hwsd/README.md
	@mkdir -p $(@D)
	@head -1 $< | sed 's/# /#define TITLE /' > $@
	@echo "#define S_GPUSD" >> $@
	@cat include/mdHeader.shtml >> $@
	$(MD2HTML) $< | sed 's/\<h1 .*//' | sed 's/label{[a-zA-Z]*}//'>> $@
	@cat include/mdFooter.shtml >> $@

$(TARGET)/documents/WhitePapers/%.pdf: documents/WhitePapers/%/paper.pdf
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/documents/Developer/%.pdf: ../EqDocs/Developer/%/paper.pdf
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/documents/Developer/eqPlyPresentation.pdf: ../EqDocs/Developer/eqPly/presentation/eqPly.pdf
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/documents/Developer/eqPly.pdf: ../EqDocs/Developer/eqPly/Semesterarbeit.pdf
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/downloads/DBCAAF49A0C0/ProgrammingUserGuide.pdf: ../EqDocs/Developer/ProgrammingGuide/paper.pdf
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/documents/%-small.jpg: documents/%.png
	@mkdir -p $(@D)
	convert $< -geometry 300x1000 $@

$(TARGET)/applications/%-small.jpg: applications/%.png
	@mkdir -p $(@D)
	convert $< -geometry 150x1000 $@

$(TARGET)/scalability/%-small.jpg: scalability/%.png
	@mkdir -p $(@D)
	convert $< -geometry 150x150 $@

$(TARGET)/%-small.jpg: %.jpg
	@mkdir -p $(@D)
	convert $< -geometry 200x1000 $@

$(TARGET)/%-small.jpg: %.png
	@mkdir -p $(@D)
	convert $< -geometry 200x1000 $@

$(TARGET)/% : %
	@mkdir -p $(@D)
	cp -rf $< $(@D)
