//
//  AppDelegate.h
//  Ozone
//
//  Created by Ramakrishna Nadella on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragStatusView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSButton *digButton;
    IBOutlet NSTextField *domainInput;
    IBOutlet NSTextView *digOutput;
    IBOutlet NSTextView *headersOutput;
    IBOutlet NSTextView *nameserverOutput;

    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    
    DragStatusView *dragView;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction) performDomainIntrospection:(id) sender;
- (IBAction) fetchData:(id) sender forDomain:(NSString*) domain;
- (IBAction) replaceDomainInput:(id)sender withDomain:(NSString*)domainName;
- (IBAction) clearOuputs:(id) sender;
- (IBAction) showWindow:(id) sender;
@end
