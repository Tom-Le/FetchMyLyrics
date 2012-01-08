# If theos is not present, clone it first
ifeq ($(shell [ -f ./theos/makefiles/common.mk ] && echo 1 || echo 0),0)
all clean package install::
	@git submodule update --init --merge --recursive 2> /dev/null
	@$(MAKE) $(MAKEFLAGS) MAKELEVEL=0 $@
else
# Absolute path to theos
THEOS = $(shell cd ./theos/; pwd;)
# SSH info
THEOS_DEVICE_PORT = 2222
THEOS_DEVICE_IP   = localhost

# Tweak meta
TWEAK_NAME = FetchMyLyrics
FetchMyLyrics_FILES = classes/FMLHook.xm \
					  classes/FMLController.m \
					  classes/FMLOperation.m \
					  classes/FMLLyricsWrapper.m \
					  classes/FMLLyricsWikiOperation.m \
					  classes/FMLLyricsWikiPageParser.m \
					  classes/FMLAZLyricsOperation.m
FetchMyLyrics_FRAMEWORKS = Foundation UIKit MediaPlayer CoreGraphics
FetchMyLyrics_PRIVATE_FRAMEWORKS = iPodUI
FetchMyLyrics_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 5.0

CFLAGS = -I./classes -I./headers -I/usr/include/objc

include ./theos/makefiles/common.mk
include ./theos/makefiles/tweak.mk

endif
