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
FetchMyLyrics_FILES = _tweak/FMLHook.xm \
					  _tweak/FMLController.m \
					  _tweak/FMLLyricsWrapper.m \
					  _common/NSObject+InstanceVariable.m
FetchMyLyrics_FRAMEWORKS = Foundation CoreFoundation MediaPlayer UIKit
FetchMyLyrics_PRIVATE_FRAMEWORKS = iPodUI
FetchMyLyrics_CFLAGS = -I./_tweak -I./_common -I/usr/include/objc
FetchMyLyrics_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

BUNDLE_NAME = FMLLyricsWikiOperation FMLAZLyricsOperation
FMLLyricsWikiOperation_FILES = _bundles/FMLLyricsWikiOperation/FMLLyricsWikiOperation.m \
							   _common/NSRegularExpression+Extra.m
FMLLyricsWikiOperation_FRAMEWORKS = Foundation
FMLLyricsWikiOperation_CFLAGS = -I./_bundles/FMLLyricsWikiOperation -I./_common
FMLLyricsWikiOperation_INSTALL_PATH = /Library/FetchMyLyrics/LyricsOperations/
FMLAZLyricsOperation_FILES = _bundles/FMLAZLyricsOperation/FMLAZLyricsOperation.m
FMLAZLyricsOperation_FRAMEWORKS = Foundation
FMLAZLyricsOperation_CFLAGS = -I./_bundles/FMLAZLyricsOperation -I./_common
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
