#!/usr/bin/make -f

Q3A_HOMEPATH := $(realpath $(HOME)/.q3a)
Q3A_BASEGAME := baseq3

RADIANT_Q3_LOCAL_PREF := $(shell find ~/.radiant -path '*/q3.game/*local.pref' -print0 | xargs -0 ls -t1 | head -n1)
RADIANT_Q3_LASTMAP := $(shell sed -ne 's!.*<epair name="LastMap">\([^<]*\)<.*!\1!p' "$(RADIANT_Q3_LOCAL_PREF)")
RADIANT_Q3_MAPDIR := $(realpath $(dir $(RADIANT_Q3_LASTMAP)))
RADIANT_Q3_BASEPATH := $(realpath $(dir $(RADIANT_Q3_MAPDIR))/..)

# Use: q3.make FILENAME.pk3 INCLUDE='scripts/my.shader textures/my'
#INCLUDE := env/wbig scripts/wbig.shader textures/wbig

.PHONY: settings
settings:
	@echo Q3A_HOMEPATH = $(Q3A_HOMEPATH)
	@echo Q3A_BASEGAME = $(Q3A_BASEGAME)
	@echo RADIANT_Q3_LOCAL_PREF = $(RADIANT_Q3_LOCAL_PREF)
	@echo RADIANT_Q3_LASTMAP = $(RADIANT_Q3_LASTMAP)
	@echo RADIANT_Q3_MAPDIR = $(RADIANT_Q3_MAPDIR)
	@echo RADIANT_Q3_BASEPATH = $(RADIANT_Q3_BASEPATH)

# Auto variables $< $@ etc...
# https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html
.PRECIOUS: $(RADIANT_Q3_MAPDIR)/%.aas
$(RADIANT_Q3_MAPDIR)/%.aas: $(RADIANT_Q3_MAPDIR)/%.bsp
	cd /tmp && bspc -optimize -forcesidesvisible -bsp2aas "$<"

.PRECIOUS: $(RADIANT_Q3_MAPDIR)/%.bsp
$(RADIANT_Q3_MAPDIR)/%.bsp: $(RADIANT_Q3_MAPDIR)/%.map
	# First build lin, prt and srf. PRT only if there are leaks?
	q3map2 -v -game quake3 -fs_basepath "$(RADIANT_Q3_BASEPATH)" -meta "$<"
	# Build vis, needed for optimized map rendering.
	q3map2 -v -game quake3 -fs_basepath "$(RADIANT_Q3_BASEPATH)" -vis -saveprt "$<"
	# Full(ish) build
	q3map2 -v -game quake3 -fs_basepath "$(RADIANT_Q3_BASEPATH)" \
	  -light -fast -patchshadows -samples 2 -bounce 2 -dirty -gamma 2 \
	  -compensate 4 "$<"

.PRECIOUS: $(RADIANT_Q3_MAPDIR)/%/levelshots
$(RADIANT_Q3_MAPDIR)/%/levelshots:
	# Make levelshots dir, but also add sample JPG
	mkdir -p "$@"
	mapname=$(notdir $(realpath $(dir $@))) && \
	  cp -a "$(RADIANT_Q3_MAPDIR)/sample.jpg" "$@/$$mapname.jpg"

.PRECIOUS: $(RADIANT_Q3_MAPDIR)/%/scripts
$(RADIANT_Q3_MAPDIR)/%/scripts:
	# Make scripts dir, but also add sample ARENA file
	mkdir -p "$@"
	mapname=$(notdir $(realpath $(dir $@))) && \
	  printf '%s\n' \
		'{' \
		"map \"$$mapname\"" \
		"longname \"The $$mapname Map\"" \
		'bots "grunt doom major bones sorlag"' \
		'timelimit "20"' \
		'fraglimit 30' \
		'type "ctf team ffa tourney"' \
		'}' >"$@/$$mapname.arena"

.PRECIOUS: $(RADIANT_Q3_MAPDIR)/%
$(RADIANT_Q3_MAPDIR)/%:
	mkdir -p "$@"

.PRECIOUS: $(Q3A_HOMEPATH)/$(Q3A_BASEGAME)/%.pk3  # do not auto-delete
$(Q3A_HOMEPATH)/$(Q3A_BASEGAME)/%.pk3: \
    $(RADIANT_Q3_MAPDIR)/% \
    $(RADIANT_Q3_MAPDIR)/%/levelshots \
    $(RADIANT_Q3_MAPDIR)/%/scripts \
    $(RADIANT_Q3_MAPDIR)/%.aas \
    $(RADIANT_Q3_MAPDIR)/%.bsp \
    $(RADIANT_Q3_MAPDIR)/%.map
	mapdir="$(RADIANT_Q3_MAPDIR)/$(notdir $(basename $@))" && \
	  includesdir="$(RADIANT_Q3_BASEPATH)/$(Q3A_BASEGAME)" && \
	  mkdir -p "$$mapdir" && \
	  cd "$$includesdir" && \
	  if test -n "$(INCLUDE)"; then \
	    find $(INCLUDE) -type f | \
	      rsync -v --files-from=- . "$$mapdir/"; \
	  fi && \
	  cd "$$mapdir" && \
	  mkdir -p maps && \
	  cp ../$(basename $(notdir $@)).aas maps/ && \
	  cp ../$(basename $(notdir $@)).bsp maps/ && \
	  cp ../$(basename $(notdir $@)).map maps/ && \
	  zip -r $@ *

.PHONY: %.pk3
%.pk3: $(Q3A_HOMEPATH)/$(Q3A_BASEGAME)/%.pk3
	@echo RESOLVED $<
