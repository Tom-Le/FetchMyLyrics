include theos/makefiles/common.mk

TWEAK_NAME = LyricsGrabber
LyricsGrabber_FILES = LGRHook.xm LGRController.xm LGRLyricsWrapper.xm LGRLyricsOperation.xm LGRLyricsWikiAPIParser.xm LGRLyricsWikiPageParser.xm
LyricsGrabber_FRAMEWORKS = Foundation UIKit MediaPlayer CoreGraphics
LyricsGrabber_PRIVATE_FRAMEWORKS = iPodUI

CFLAGS = -I/usr/include/objc -I./headers
LDFLAGS = -F./Frameworks -F./PrivateFrameworks

include $(THEOS_MAKE_PATH)/tweak.mk
