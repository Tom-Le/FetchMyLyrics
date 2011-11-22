include theos/makefiles/common.mk

TWEAK_NAME = lfetcher
lfetcher_FILES = classes/LGRHook.xm \
					  classes/LGRController.xm \
					  classes/LGROperation.xm \
					  classes/LGRLyricsWrapper.xm \
					  classes/LGRLyricsWikiOperation.xm \
					  classes/LGRLyricsWikiAPIParser.xm \
					  classes/LGRLyricsWikiPageParser.xm \
					  classes/LGRAZLyricsOperation.xm \
					  classes/LGRAZLyricsPageParser.xm
lfetcher_FRAMEWORKS = Foundation UIKit MediaPlayer CoreGraphics
lfetcher_PRIVATE_FRAMEWORKS = iPodUI

CFLAGS = -I./classes -I./ext -I./headers -I/usr/include/objc 

include $(THEOS_MAKE_PATH)/tweak.mk
