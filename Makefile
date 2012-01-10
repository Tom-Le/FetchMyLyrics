ifeq ($(shell [ -f ./theos/makefiles/common.mk ] && echo 1 || echo 0),0)
all clean package install::
	@git submodule update --init --merge --recursive 2> /dev/null # clone theos
	@$(MAKE) $(MAKEFLAGS) MAKELEVEL=0 $@
else

ifeq ($(shell [ -f ./theos/bin/ldid ] && echo 1 || echo 0),0)
all package install::
	@echo "ERROR: ldid not present in ./theos/bin/"
	@echo "Find a copy of ldid (on the Internet), then put it in ./theos/bin/"
	@exit 1
else

# Absolute path to theos
THEOS = $(shell cd ./theos/; pwd;)
# SSH info
THEOS_DEVICE_PORT = 2222
THEOS_DEVICE_IP   = localhost

# Tweak meta
TWEAK_NAME = FetchMyLyrics
FetchMyLyrics_FILES = src/FMLHook.xm \
					  src/FMLController.m \
					  src/FMLOperation.m \
					  src/FMLLyricsWrapper.m \
					  src/FMLLyricsWikiOperation.m \
					  src/FMLLyricsWikiPageParser.m \
					  src/FMLAZLyricsOperation.m
FetchMyLyrics_FRAMEWORKS = Foundation UIKit MediaPlayer CoreGraphics
FetchMyLyrics_PRIVATE_FRAMEWORKS = iPodUI
FetchMyLyrics_CFLAGS = -I./src -I./headers -I/usr/include/objc
FetchMyLyrics_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 5.0

# Uncomment the following lines (and modify as appropriate) if you are
# not on OS X, and want to specify a custom location for the frameworks
# FetchMyLyrics_LDFLAGS = -F/path/to/Frameworks -F/path/to/PrivateFrameworks

include ./theos/makefiles/common.mk
include ./theos/makefiles/tweak.mk

endif

endif
