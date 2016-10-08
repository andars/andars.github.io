# config
EXT_IN ?= page
EXT_OUT ?= html

# directories and files
ETC ?= $(CURDIR)/etc
CONTENT ?= $(CURDIR)/content
DEST ?= $(CURDIR)/build

FILES := $(shell find $(CONTENT) -type f)
FILES := $(FILES:.$(EXT_IN)=.$(EXT_OUT))
FILES := $(FILES:$(CONTENT)/%=$(DEST)/%)

export PATH := .:$(PATH)


all: $(FILES)
.PHONY: all

$(DEST)/%.$(EXT_OUT): $(CONTENT)/%.meta $(CONTENT)/%.mk
	@mkdir -p $(@D)
	@jinja2 $(word 2, $^) $< --format yaml > build/tmp # render body
	@render_page $< build/tmp > $@ # insert body in layout page
	@rm build/tmp

$(CONTENT)/%.mk: $(CONTENT)/%.$(EXT_IN)
	@cat $< | \
		fm -s | \
		pandoc --katex --highlight-style pygments -t html > $@

$(CONTENT)/%.meta: $(CONTENT)/%.$(EXT_IN)
	@cat $< | fm > $@

$(DEST)/%: $(CONTENT)/%
	@mkdir -p $(@D)
	@cp $< $@

.PHONY: clean
clean:
	@rm -rf build/
