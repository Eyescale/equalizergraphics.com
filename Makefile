
TOP = ..

TARGET = build

FILES = \
	$(wildcard downloads/*gz) \
	api.html \
	configuration.html \
	contact.html \
	contributors.html \
	doc_developer.html \
	documentation.html \
	downloads.html \
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
	stylesheet.css \
	useCases.html \
        robots.txt \
	documents/CV_Stefan_Eilemann.pdf \
	documents/Equalizer.html \
	documents/Equalizer.html_files \
	documents/Equalizer.pdf \
	documents/EqualizerGuide.html \
	documents/EqualizerGuide.html_files \
	documents/EqualizerGuide.pdf \
	documents/EqualizerTeaser.html \
	documents/EqualizerTeaser.html_files \
	documents/EqualizerTeaser.pdf \
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
	documents/WhitePapers/ParallelRenderingSystems.pdf \
	documents/WhitePapers/ProjectEqualizer.pdf \
	documents/design/anaglyph.html \
	documents/design/compounds.html \
	documents/design/eventHandling.html \
	documents/design/dynamicNearFar.html \
	documents/design/environment.html \
	documents/design/fileFormat.html \
	documents/design/frames.html \
	documents/design/imageCompression.html \
	documents/design/immersive.html \
	documents/design/loadBalancing.html \
	documents/design/nodeFailure.html \
	documents/design/objects.html \
	documents/design/packets.html \
	documents/design/roi.html \
	documents/design/statistics.html \
	documents/design/taskMethods.html \
	documents/design/threads.txt \
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
	news/Release_0.1.html \
	news/Release_0.2.html \
	news/tungsten.html \
	$(IMAGES)

IMAGES_SRC = \
	$(wildcard images/*png) \
	documents/design/codingStyle.png \
	documents/design/frames.png \
	documents/design/images/eventHandling.png \
	documents/design/images/mono.png \
	documents/design/images/packets.png \
	documents/design/images/immersive.png \
	documents/design/images/stereo.png \
	$(wildcard screenshots/*) \

INCLUDES = \
	include/header.shtml \
	include/footer.shtml

TARGETS  = $(FILES:%=$(TARGET)/%) 
IMAGES   = $(IMAGES_SRC) $(IMAGES_SRC:%.png=%-small.png) \
	   $(IMAGES_SRC:%.jpg=%-small.jpg)

CPP_HTML = gcc -xc -ansi -E -C -Iinclude \
           -DUPDATE="`svn info $< | grep 'Last Changed Date' | sed 's/.*, \(.*\))/\1/'`" \
           -DCHANGEURL=\"http://equalizer.svn.sourceforge.net/viewvc/equalizer/trunk/website/$<\"

all: $(TARGETS) $(INCLUDES)

clean:
	rm -rf $(TARGETS)

install: all
	rsync -avz --exclude=".svn" -e ssh $(TARGET)/ eile@equalizergraphics.com:var/www/htdocs/www.equalizergraphics.com

.SUFFIXES: .html .css

$(TARGET)/%.html : %.shtml $(INCLUDES)
	@mkdir -p $(@D)
	$(CPP_HTML) $< | sed 's/^#.*//' > $@

$(TARGET)/stylesheet.css: stylesheet.css
	cp stylesheet.css $@

$(TARGET)/documents/WhitePapers/%.pdf: ../doc/WhitePapers/%/paper.pdf
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/documents/%.html : ../doc/%.shtml $(INCLUDES)
	@mkdir -p $(@D)
	$(CPP_HTML) -DBASE $< | sed 's/^#.*//' > $@

$(TARGET)/documents/%-small.png: ../doc/%.png
	@mkdir -p $(@D)
	convert $< -geometry 300x1000 $@

$(TARGET)/documents/%: ../doc/%
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/%-small.jpg: %.jpg
	@mkdir -p $(@D)
	convert $< -geometry 200x1000 $@

$(TARGET)/%-small.png: %.png
	@mkdir -p $(@D)
	convert $< -geometry 200x1000 $@

$(TARGET)/% : %
	@mkdir -p $(@D)
	cp -r $< $(@D)
