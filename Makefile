#
# Makefile for a Video Disk Recorder plugin
#
# $Id: Makefile 1.8 2002/12/13 14:54:14 kls Exp $

# The official name of this plugin.
# This name will be used in the '-P...' option of VDR to load the plugin.
# By default the main source file also carries this name.
#
PLUGIN = playlist

### The version number of this plugin (taken from the main source file):

VERSION = $(shell grep 'static const char \*VERSION *=' $(PLUGIN).c | awk '{ print $$6 }' | sed -e 's/[";]//g')

### The C++ compiler and options:

CXX      ?= g++
CXXFLAGS ?= -fPIC -O2 -Wall -Woverloaded-virtual

### Allow user defined options to overwrite defaults:

-include $(VDRDIR)/Make.config

### The directory environment:

DVBDIR = ../../../../DVB
VDRDIR = ../../..
LIBDIR = ../../lib
TMPDIR = /tmp

### The version number of VDR (taken from VDR's "config.h"):

VDRVERSION = $(shell grep 'define VDRVERSION ' $(VDRDIR)/config.h | awk '{ print $$3 }' | sed -e 's/"//g')
VDRVERSNUM = $(shell grep 'define VDRVERSNUM ' $(VDRDIR)/config.h | awk '{ print $$3 }' | sed -e 's/"//g')

### DEFINES += -DVDRVERSNUM=$(VDRVERSNUM)

### The name of the distribution archive:

ARCHIVE = $(PLUGIN)-$(VERSION)
PACKAGE = vdr-$(ARCHIVE)

### Includes and Defines (add further entries here):

INCLUDES += -I$(VDRDIR)/include -I$(DVBDIR)/include

DEFINES += -DPLUGIN_NAME_I18N='"$(PLUGIN)"'
DEFINES += -D_GNU_SOURCE

### Test Elchi

#ELCHIVERSION = $(shell grep 'define ELCHIAIOVERSION ' $(VDRDIR)/config.h | awk '{ print $$3 }' | sed -e 's/"//g')

ifeq ($(shell test -f $(VDRDIR)/theme.h ; echo $$?),0)
  DEFINES += -DHAVE_ELCHI
endif

### Test wareagle-patch

ifeq ($(shell test -f $(VDRDIR)/iconpatch.h ; echo $$?),0)
  DEFINES += -DHAVE_ICONPATCH
endif

#for more debug lines
#DEFINES += -DPL_Debug1
#DEFINES += -DPL_Debug2
#DEFINES += -DPL_Debug3
#CXXFLAGS += -g

### The object files (add further files here):

OBJS = $(PLUGIN).o dataplaylist.o menucontrol.o menuplaylist.o menuplaylists.o menusetup.o i18n.o vdrtools.o

ifeq ($(shell test $(VDRVERSNUM) -lt 10307 ; echo $$?),0)
  OBJS += menuitemtext.o
endif

### Implicit rules:

%.o: %.c
	$(CXX) $(CXXFLAGS) -c $(DEFINES) $(INCLUDES) $<

# Dependencies:

MAKEDEP = g++ -MM -MG
DEPFILE = .dependencies
$(DEPFILE): Makefile
	@$(MAKEDEP) $(DEFINES) $(INCLUDES) $(OBJS:%.o=%.c) > $@

-include $(DEPFILE)

### Targets:

all: libvdr-$(PLUGIN).so

libvdr-$(PLUGIN).so: $(OBJS)
	$(CXX) $(CXXFLAGS) -shared $(OBJS) -o $@
	@cp $@ $(LIBDIR)/$@.$(VDRVERSION)

dist:	clean
	@-rm -rf $(TMPDIR)/$(ARCHIVE)
	@mkdir $(TMPDIR)/$(ARCHIVE)
	@cp -a * $(TMPDIR)/$(ARCHIVE)
	@tar czf $(PACKAGE).tgz -C $(TMPDIR) $(ARCHIVE)
	@-rm -rf $(TMPDIR)/$(ARCHIVE)
	@echo Distribution package created as $(PACKAGE).tgz

clean:
	@-rm -f $(OBJS) $(DEPFILE) *.so *.tgz core* *~
