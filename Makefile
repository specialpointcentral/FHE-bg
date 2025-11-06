LATEX=pdflatex
TARGET=main

.PHONY: all clean

all: $(TARGET).pdf

$(TARGET).pdf: $(TARGET).tex
	$(LATEX) -interaction=nonstopmode $(TARGET).tex
	$(LATEX) -interaction=nonstopmode $(TARGET).tex

clean:
	rm -f $(TARGET).aux $(TARGET).log $(TARGET).nav \
		$(TARGET).out $(TARGET).snm $(TARGET).toc $(TARGET).vrb $(TARGET).pdf
