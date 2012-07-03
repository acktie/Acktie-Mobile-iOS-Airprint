/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiModule.h"

@interface ComAcktieMobileIosAirprintModule : TiModule <UIPrintInteractionControllerDelegate, UIWebViewDelegate>
{
    @private KrollCallback *sentToPrinter;
}

-(void) print: (id)args;
-(id) canPrint;
- (NSData *) convertImageToPDF: (UIImage *) image;
- (NSData *) convertImageToPDF: (UIImage *) image withResolution: (double) resolution;
- (NSData *) convertImageToPDF: (UIImage *) image withHorizontalResolution: (double) horzRes verticalResolution: (double) vertRes;
- (NSData *) convertImageToPDF: (UIImage *) image withResolution: (double) resolution maxBoundsRect: (CGRect) boundsRect pageSize: (CGSize) pageSize;

@end
