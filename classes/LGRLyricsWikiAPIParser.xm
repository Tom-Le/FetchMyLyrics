/*******************************************************************************
 * LGRLyricsWikiAPIParser.xm
 * LyricsGrabber
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, available here: http://bit.ly/vSZSvM
 ******************************************************************************/

#import "LGRLyricsWikiAPIParser.h"
#import "LGRCommon.h"

@implementation LGRLyricsWikiAPIParser

@synthesize URLToAPIPage = _URLToAPIPage, done = _done, URLStringToLyricsPage = _URLStringToLyricsPage;

- (id)init
{
    if ((self = [super init]))
    {
        _URLToAPIPage = nil;
        _parser = nil;
        _done = YES; // Not running anything, so YES
        _URLStringToLyricsPage = nil;
        _mutableURLStringToLyricsPage = nil;
    }

    return self;
}

- (void)dealloc
{
    if (_parser)
    {
        [_parser abortParsing];
        _parser.delegate = nil;
        [_parser release];
    }
    if (_URLStringToLyricsPage)
        [_URLStringToLyricsPage release]; // Because we would "copy" the mutable string

    self.URLToAPIPage = nil;
    _URLStringToLyricsPage = nil;

    [super dealloc];
}

- (void)beginParsing
{
    if (!self.URLToAPIPage)
        return;

    // Download the whole XML
    NSData *data = [NSData dataWithContentsOfURL:self.URLToAPIPage];
    if (data)
    {
        // Set up NSXMLParser instance
        _parser = [[NSXMLParser alloc] initWithData:data]; 
        if (_parser)
        {
            _parser.delegate = self;
            _done = NO;
            [_parser parse];
        }
    }
    else
        _done = YES;
}

/*
 * Below are NSXMLParser delegate methods, which will extract the URL for us.
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                       qualifiedName:(NSString *)qualifiedName
                                          attributes:(NSDictionary *)attributedict
{
    // If element = <url>, begin reading element's text
    // by setting a flag to YES
    if ([elementName isEqualToString:@"url"])
    {
        _foundURLToLyricsPageElement = YES;
        _mutableURLStringToLyricsPage = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // If our flag is set, append text to our prepared NSString instance
    if (_foundURLToLyricsPageElement)
        [_mutableURLStringToLyricsPage appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                      namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qualifiedName
{
    // If element = <url>, stop reading element's text
    // by setting our flag to NO
    if ([elementName isEqualToString:@"url"])
    {
        _foundURLToLyricsPageElement = NO;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    // Parsing was successful, store the lyrics
    _URLStringToLyricsPage = [_mutableURLStringToLyricsPage copy];

    // We no longer need the mutable string
    [_mutableURLStringToLyricsPage release];
    _mutableURLStringToLyricsPage = nil;

    // Flag as done
    _done = YES;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccured:(NSError *)error
{
    // Parsing failed, discard everything
    _URLStringToLyricsPage = nil;
    [_mutableURLStringToLyricsPage release];
    _mutableURLStringToLyricsPage = nil;

    // Flag as done
    _done = YES;
}

- (void)parser:(NSXMLParser *)parser validationErrorOccured:(NSError *)error
{
    // Parsing failed, discard everything
    _URLStringToLyricsPage = nil;
    [_mutableURLStringToLyricsPage release];
    _mutableURLStringToLyricsPage = nil;

    // Flag as done
    _done = YES;
}

@end
