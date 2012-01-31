ifeq ($(shell [ -f ./theos/makefiles/common.mk ] && echo 1 || echo 0),0)
all clean package install::
	@git submodule update --init --merge --recursive 2> /dev/null # clone theos
	@$(MAKE) $(MAKEFLAGS) MAKELEVEL=0 $@
else

# Absolute path to theos
THEOS = $(shell cd ./theos/; pwd;)
# SSH info
THEOS_DEVICE_PORT = 2222
THEOS_DEVICE_IP   = localhost

TWEAK_NAME = FetchMyLyrics
FetchMyLyrics_FILES = src/FMLHook.xm \
					  src/FMLController.m \
					  src/FMLLyricsWrapper.m \
					  src/NSRegularExpression+Extra.m \
					  src/NSObject+InstanceVariable.m
FetchMyLyrics_FRAMEWORKS = Foundation CoreFoundation MediaPlayer UIKit CoreGraphics QuartzCore
FetchMyLyrics_PRIVATE_FRAMEWORKS = iPodUI
FetchMyLyrics_CFLAGS = -I./src -I/usr/include/objc
FetchMyLyrics_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

BUNDLE_NAME = FMLLyricsWikiOperation FMLAZLyricsOperation
FMLLyricsWikiOperation_FILES = src/FMLLyricsWikiOperation.m
FMLLyricsWikiOperation_FRAMEWORKS = Foundation
FMLLyricsWikiOperation_CFLAGS = -I./src
FMLLyricsWikiOperation_INSTALL_PATH = /Library/FetchMyLyrics/LyricsOperations/
FMLAZLyricsOperation_FILES = src/FMLAZLyricsOperation.m
FMLAZLyricsOperation_FRAMEWORKS = Foundation
FMLAZLyricsOperation_CFLAGS = -I./src
FMLAZLyricsOperation_INSTALL_PATH = /Library/FetchMyLyrics/LyricsOperations/

TARGET_IPHONEOS_DEPLOYMENT_VERSION = 5.0

# Uncomment the following lines (and modify as appropriate) if you are
# not on OS X, and want to specify a custom location for the frameworks
# FetchMyLyrics_LDFLAGS = -F/path/to/Frameworks -F/path/to/PrivateFrameworks

include ./theos/makefiles/common.mk
include ./theos/makefiles/bundle.mk
include ./theos/makefiles/tweak.mk

package::
	@echo "Cleaning working directory..."
	@rm -rf $(THEOS_STAGING_DIR)

endif
