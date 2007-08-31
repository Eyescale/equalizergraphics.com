
.PHONY: update

TOP = ..

TARGET = build

FILES = \
	$(wildcard downloads/*gz) \
	$(wildcard downloads/*rpm) \
	api.html \
	changes.html \
	compatibility.html \
	configuration.html \
	contact.html \
	contributors.html \
	doc_developer.html \
	documentation.html \
	downloads.html \
	events.html \
	favicon.ico \
	features.html \
	impressum.html \
	index.html \
	lists.html \
	news.html \
	relnotes.html \
	scalability.html \
	screenshots.html \
	search.html \
	print.css \
	stylesheet.css \
	useCases.html \
        robots.txt \
	documents/CV_Stefan_Eilemann.pdf \
	documents/Developer/ProgrammingGuide.pdf \
	documents/EGPGV07.html \
	documents/EGPGV07.html_files \
	documents/EGPGV07.pdf \
	documents/Equalizer.html \
	documents/Equalizer.html_files \
	documents/Equalizer.pdf \
	documents/EqualizerGuide.html \
	documents/EqualizerGuide.html_files \
	documents/EqualizerGuide.pdf \
	documents/EqualizerTeaser.html \
	documents/EqualizerTeaser.html_files \
	documents/EqualizerTeaser.pdf \
	documents/EqualizerTR.pdf \
	documents/EqualizerVizSIG06.html \
	documents/EqualizerVizSIG06.html_files \
	documents/EqualizerVizSIG06.pdf \
	documents/Flyer.pdf \
	documents/FlyerWeb.pdf \
	documents/ParallelGraphicsProgramming.pdf \
	documents/ParallelGraphicsProgramming.html \
	documents/ParallelGraphicsProgramming.html_files \
	documents/Projects_Stefan_Eilemann.pdf \
	documents/RelNotes/RelNotes_0.1.0.html \
	documents/RelNotes/RelNotes_0.2.0.html \
	documents/RelNotes/RelNotes_0.3.0.html \
	documents/RelNotes/RelNotes_0.4.0.html \
	documents/WhitePapers/ParallelRenderingSystems.pdf \
	documents/WhitePapers/ProjectEqualizer.pdf \
	documents/design/anaglyph.html \
	documents/design/aspectRatio.html \
	documents/design/configInit.html \
	documents/design/compositor.html \
	documents/design/compounds.html \
	documents/design/eventHandling.html \
	documents/design/dataTransmission.html \
	documents/design/depthTransferOpt.html \
	documents/design/dynamicNearFar.html \
	documents/design/environment.html \
	documents/design/fileFormat.html \
	documents/design/frames.html \
	documents/design/imageCompression.html \
	documents/design/immersive.html \
	documents/design/infiniBand.html \
	documents/design/loadBalancing.html \
	documents/design/nodeConnect.html \
	documents/design/nonthreaded.html \
	documents/design/environment.html \
	documents/design/nodeFailure.html \
	documents/design/objects.html \
	documents/design/objectManager.html \
	documents/design/packets.html \
	documents/design/residentNodes.html \
	documents/design/roi.html \
	documents/design/standalone.html \
	documents/design/statistics.html \
	documents/design/taskMethods.html \
	documents/design/threads.html \
	documents/design/transparency.html \
	documents/design/volumeRendering.html \
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
	documents/user/configTool.html \
	documents/user/crComparison.html \
	documents/user/eqPly.html \
	news/EqualizerNewsJuly07.html \
	news/Release_0.1.html \
	news/Release_0.2.html \
	news/Release_0.3.html \
	news/tungsten.html \
	restricted/index.html \
	$(IMAGES)

IMAGES_SRC = \
	$(wildcard images/*png) \
	$(wildcard images/*jpg) \
	$(wildcard images/NewsJune07/*gif) \
	$(wildcard images/NewsJune07/*jpg) \
	$(wildcard documents/design/images/*png) \
	$(wildcard screenshots/*) \

INCLUDES = \
	include/header.shtml \
	include/footer.shtml

TARGETS  = $(FILES:%=$(TARGET)/%) 
IMAGES   = $(IMAGES_SRC) $(IMAGES_SRC:%.png=%-small.jpg) \
	   $(IMAGES_SRC:%.jpg=%-small.jpg)

CPP_HTML = gcc -xc -ansi -E -C -Iinclude \
           -DUPDATE="`svn info $< | grep 'Last Changed Date' | sed 's/.*, \(.*\))/\1/'`" \
           -DCHANGEURL=\"http://equalizer.svn.sourceforge.net/viewvc/equalizer/trunk/website/$<\" \
           -DPAGEURL=$(@:$(TARGET)%=%)

all: $(TARGETS) $(INCLUDES)

clean:
	rm -rf $(TARGETS)

install: update all
	rsync -avz --exclude=".svn" -e ssh $(TARGET)/ eile@equalizergraphics.com:var/www/htdocs/www.equalizergraphics.com

update:
	svn update . ../doc/Developer/ProgrammingGuide
	rm changes_log.html

.SUFFIXES: .html .css

$(TARGET)/%.html : %.shtml $(INCLUDES)
	@mkdir -p $(@D)
	$(CPP_HTML) $< | sed 's/^#.*//' > $@

$(TARGET)/stylesheet.css: stylesheet.css
	cp stylesheet.css $@

$(TARGET)/documents/WhitePapers/%.pdf: documents/WhitePapers/%/paper.pdf
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/documents/Developer/%.pdf: ../doc/Developer/%/paper.pdf
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/documents/%-small.jpg: documents/%.png
	@mkdir -p $(@D)
	convert $< -geometry 300x1000 $@

$(TARGET)/%-small.jpg: %.jpg
	@mkdir -p $(@D)
	convert $< -geometry 200x1000 $@

$(TARGET)/%-small.jpg: %.png
	@mkdir -p $(@D)
	convert $< -geometry 200x1000 $@

$(TARGET)/% : %
	@mkdir -p $(@D)
	cp -r $< $(@D)

$(TARGET)/changes.html: changes.shtml changes_log.html

changes_log.html:
	./changes.pl > $@
