/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComAcktieMobileIosAirprintModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiUIViewProxy.h"
#import "TiUIButtonProxy.h"
#import "TiUiWebView.h"

@implementation ComAcktieMobileIosAirprintModule

int webViewLoads_ = 0;
UIPrintInteractionController *printController = nil;
UIPrintInfo *printInfo = nil;
UIBarButtonItem* navBarButton = nil;
TiViewProxy* proxy = nil;
NSString *file = nil;
NSString *webPage = nil;
NSData *document = nil;
BOOL displayPageRange = true;
NSString* jobName = nil;

// PDF Create from Image
- (NSData *) convertImageToPDF: (UIImage *) image withResolution: (double) resolution {
    return [self convertImageToPDF: image withHorizontalResolution: resolution verticalResolution: resolution];
}

- (NSData *) convertImageToPDF: (UIImage *) image {
    return [self convertImageToPDF: image withResolution: 96];
}

- (NSData *) convertImageToPDF: (UIImage *) image withHorizontalResolution: (double) horzRes verticalResolution: (double) vertRes {
    if ((horzRes <= 0) || (vertRes <= 0)) {
        return nil;
    }
    
    double pageWidth = image.size.width * image.scale * 72 / horzRes;
    double pageHeight = image.size.height * image.scale * 72 / vertRes;
    
    NSMutableData *pdfFile = [[NSMutableData alloc] init];
    CGDataConsumerRef pdfConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)pdfFile);
    // The page size matches the image, no white borders.
    CGRect mediaBox = CGRectMake(0, 0, pageWidth, pageHeight);
    CGContextRef pdfContext = CGPDFContextCreate(pdfConsumer, &mediaBox, NULL);
    
    CGContextBeginPage(pdfContext, &mediaBox);
    CGContextDrawImage(pdfContext, mediaBox, [image CGImage]);
    CGContextEndPage(pdfContext);
    CGContextRelease(pdfContext);
    CGDataConsumerRelease(pdfConsumer);
    
    [pdfFile autorelease];
    return pdfFile;
}

- (NSData *) convertImageToPDF: (UIImage *) image withResolution: (double) resolution maxBoundsRect: (CGRect) boundsRect pageSize: (CGSize) pageSize {
    if (resolution <= 0) {
        return nil;
    }
    
    double imageWidth = image.size.width * image.scale * 72 / resolution;
    double imageHeight = image.size.height * image.scale * 72 / resolution;
    
    double sx = imageWidth / boundsRect.size.width;
    double sy = imageHeight / boundsRect.size.height;
    
    // At least one image edge is larger than maxBoundsRect
    if ((sx > 1) || (sy > 1)) {
        double maxScale = sx > sy ? sx : sy;
        imageWidth = imageWidth / maxScale;
        imageHeight = imageHeight / maxScale;
    }
    
    // Put the image in the top left corner of the bounding rectangle
    CGRect imageBox = CGRectMake(boundsRect.origin.x, boundsRect.origin.y + boundsRect.size.height - imageHeight, imageWidth, imageHeight);
    
    NSMutableData *pdfFile = [[NSMutableData alloc] init];
    CGDataConsumerRef pdfConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)pdfFile);
    
    CGRect mediaBox = CGRectMake(0, 0, pageSize.width, pageSize.height);
    CGContextRef pdfContext = CGPDFContextCreate(pdfConsumer, &mediaBox, NULL);
    
    CGContextBeginPage(pdfContext, &mediaBox);
    CGContextDrawImage(pdfContext, imageBox, [image CGImage]);
    CGContextEndPage(pdfContext);
    CGContextRelease(pdfContext);
    CGDataConsumerRelease(pdfConsumer);
    
    [pdfFile autorelease];
    return pdfFile;
}

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"e30249f1-8ddc-4230-afa9-2357c105c92a";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.acktie.mobile.ios.airprint";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(orientationDidChange:)
                                                 name: UIApplicationDidChangeStatusBarOrientationNotification
                                               object: nil];
     */
}

- (void) orientationDidChange: (NSNotification *) note
{
    /*
    UIInterfaceOrientation orientation = [[[note userInfo] objectForKey: UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    NSLog(@"Rotated!");
     */
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

- (void) openPrintDialog
{
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) 
    {
        id listener = [[sentToPrinter retain] autorelease];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:NUMBOOL(completed) forKey:@"completed"];
        NSLog(@"completionHandler, completed? : %d", completed);
        if (!completed && error) 
        {
            // Populate Callback data
            [dictionary setObject:NUMINT(error.code) forKey:@"code"];
            [dictionary setObject:error.domain forKey:@"message"];
            
            NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
        }
        
        NSLog(@"Calling Callback");
        [self _fireEventToListener:@"sentToPrinter" withObject:dictionary listener:listener thisObject:nil];
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        if(navBarButton != nil)
        {
            [printController presentFromBarButtonItem:navBarButton animated:YES completionHandler:completionHandler];
        }
        else
        {
            NSLog(@"proxy.view.frame : %@", NSStringFromCGRect(proxy.view.frame));
            [printController presentFromRect:proxy.view.frame inView:proxy.parent.view animated:YES completionHandler:completionHandler]; 
        }
    } 
    else 
    {
        [printController presentAnimated:YES completionHandler:completionHandler];
    }
}

- (void) initVariables
{
    webViewLoads_ = 0;
    printController = nil;
    printInfo = nil;
    navBarButton = nil;
    proxy = nil;
    file = nil;
    webPage = nil;
    document = nil;
    displayPageRange = true;
    jobName = nil;
}

#pragma Public APIs

-(void)print: (id)args
{
    NSLog(@"print");
    ENSURE_UI_THREAD(print, args);
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    [self initVariables];
    
    if([args objectForKey:@"file"] != nil)
    {
        BOOL keepScale = false;
        if([args objectForKey:@"keepScale"] != nil)
        {
            keepScale = [TiUtils boolValue:[args objectForKey:@"keepScale"]];
        }
        
        NSString* fileString = [TiUtils stringValue:[args objectForKey:@"file"]];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);
        
        file = [[paths lastObject] stringByAppendingPathComponent:fileString];
    
        if(keepScale && ![[file pathExtension] isEqualToString:@"pdf"])
        {            
            UIImage *image = [UIImage imageWithContentsOfFile:file];
            document = [self convertImageToPDF: image];
        }
        else
        {
            document = [NSData dataWithContentsOfFile:file];
        }
    }
    else if([args objectForKey:@"url"] != nil)
    {
        file = [TiUtils stringValue:[args objectForKey:@"url"]];
        NSURL *url = [NSURL URLWithString:file];
        
        document = [NSData dataWithContentsOfURL:url];
    }
    NSLog([NSString stringWithFormat:@"file: %@", file]);
    
    if([args objectForKey:@"displayPageRange"] != nil)
    {
        displayPageRange = [TiUtils boolValue:[args objectForKey:@"displayPageRange"]];
    }
    NSLog([NSString stringWithFormat:@"displayPageRange: %d", displayPageRange]);
    
    if([args objectForKey:@"jobName"] != nil)
    {
        jobName = [TiUtils stringValue:[args objectForKey:@"jobName"]];;
    }
    else
    {
        jobName = [file lastPathComponent];
    }
    NSLog([NSString stringWithFormat:@"jobName: %@", jobName]);
    
    if([args objectForKey:@"webPage"] != nil)
    {
        webPage = [TiUtils stringValue:[args objectForKey:@"webPage"]];;
    }
    NSLog([NSString stringWithFormat:@"webPage: %@", webPage]);
    
    if([args objectForKey:@"navBarButton"] != nil)
    {
        navBarButton = ((TiUIButtonProxy *)[args objectForKey:@"navBarButton"]).barButtonItem;
    }
    NSLog([NSString stringWithFormat:@"navBarButton: %@", navBarButton]);
    
    if([args objectForKey:@"view"] != nil)
    {
        proxy = (TiViewProxy*)[args objectForKey:@"view"];
    }
    NSLog([NSString stringWithFormat:@"proxy: %@", proxy]);
     
    if ([args objectForKey:@"sentToPrinter"] != nil)
    {
        NSLog(@"Received sentToPrinter callback");
        
        sentToPrinter = [args objectForKey:@"sentToPrinter"];
        ENSURE_TYPE_OR_NIL(sentToPrinter,KrollCallback);
        [sentToPrinter retain];
    }
    
    printController = [UIPrintInteractionController sharedPrintController];
    
    if(printController && [UIPrintInteractionController canPrintData:document]) {
        
        printController.delegate = self;
        
        printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = jobName;
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        printController.printInfo = printInfo;
        printController.showsPageRange = YES;
        
        printController.printingItem = document;
        [self openPrintDialog];
    }
}

-(id)canPrint
{
    return NUMBOOL([UIPrintInteractionController isPrintingAvailable]);
}
@end
