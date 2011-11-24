include theos/makefiles/common.mk

TWEAK_NAME = FetchMyLyrics
FetchMyLyrics_FILES = classes/FMLHook.xm \
					  classes/FMLController.m \
					  classes/FMLOperation.m \
					  classes/FMLLyricsWrapper.m \
					  classes/FMLLyricsWikiOperation.m \
					  classes/FMLLyricsWikiAPIParser.m \
					  classes/FMLLyricsWikiPageParser.m \
					  classes/FMLAZLyricsOperation.m \
					  classes/FMLAZLyricsPageParser.m
FetchMyLyrics_FRAMEWORKS = Foundation UIKit MediaPlayer CoreGraphics
FetchMyLyrics_PRIVATE_FRAMEWORKS = iPodUI

APPLICATION_NAME = FML
FML_FILES = classes/FMLApp-main.m \
			classes/FMLAppDelegate.m \
			classes/FMLRootViewController.m

CFLAGS = -I./classes -I./headers -I/usr/include/objc 

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/application.mk
