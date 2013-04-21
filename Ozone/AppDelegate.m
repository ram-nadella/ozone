//
//  AppDelegate.m
//  Ozone
//
//  Created by Ramakrishna Nadella on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void) awakeFromNib {
    // set the menubar icon
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [statusItem setHighlightMode:YES];
//    [statusItem setImage:[NSImage imageNamed:@"lab"]];
    [statusItem setMenu:statusMenu];
    
    dragView = [[DragStatusView alloc] initWithFrame:NSMakeRect(0, 0, 24, 24)];

    [statusItem setView:dragView];
    [statusItem setMenu:statusMenu];

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

//    [_window setBackgroundColor:[NSColor whiteColor]];

    [domainInput heightAdjustLimit];
    
    NSFont *fixedFont = [NSFont fontWithName:@"Menlo" size:13]; 
    [digOutput setFont:fixedFont];
    [headersOutput setFont:fixedFont];
    [nameserverOutput setFont:fixedFont];
}

/**
 
 Currently blocks UI while waiting to read the output of executed command
 
 See http://stackoverflow.com/questions/7676508/nstask-blocking-the-main-thread?rq=1
 to change this to run on a background thread instead of the main thread
 
 */

- (NSString *)createTask:(NSString *)taskPath withArgs:(NSArray *)arguments {

    NSTask *task;
    task = [[NSTask alloc]init];
    [task setLaunchPath: taskPath];

    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *commandOutput;
    commandOutput = [[NSString alloc] initWithData: data
                                          encoding: NSUTF8StringEncoding];
    
    return commandOutput;
}

- (NSOperation*)taskWithData:(id)data {
    NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                        selector:@selector(myTaskMethod:) object:data];
    
    return theOp;
}

// instrospection time :)
- (IBAction)performDomainIntrospection:(id)sender {
    NSString *domainName = [domainInput stringValue];
    [self fetchData:sender forDomain:domainName];
}

// duplicate of above digDomain function but takes domain as input param

- (IBAction)fetchData:(id)sender forDomain:(NSString*)domain {

    // clear the ouputs from previous run
    [self clearOuputs:sender];
    
    // argument list for commands, reused (repopulated)
    NSArray *arguments;
    
    // get name servers
    arguments = [NSArray arrayWithObjects: @"+short", @"NS", domain, nil];
    NSString *nameservers = [self createTask:@"/usr/bin/dig" withArgs:arguments];
    [nameserverOutput setString:nameservers];
    
    // get server header
    arguments = [NSArray arrayWithObjects: @"-X", @"GET", @"-I", @"--max-time", @"30", @"-s", domain, nil];
    NSString *headers = [self createTask:@"/usr/bin/curl" withArgs:arguments];
    [headersOutput setString:headers];
    NSRange serverHeaderRange = [headers rangeOfString:@"Server: cloudflare-nginx"];
    if (serverHeaderRange.location != NSNotFound) {
        [headersOutput setSelectedRange:serverHeaderRange];
    }

    // get dig output (with no args)
    arguments = [NSArray arrayWithObjects: @"@8.8.8.8", domain, nil];
    NSString *digResponse = [self createTask:@"/usr/bin/dig" withArgs:arguments];
    [digOutput setString:digResponse];
    NSRange answerSectionRange = [digResponse rangeOfString:@";; ANSWER SECTION:"];
    if (answerSectionRange.location != NSNotFound) {
        [digOutput setSelectedRange:answerSectionRange];
    }
}

- (IBAction)replaceDomainInput:(id)sender withDomain:(NSString*)domainName {
    [domainInput setStringValue:domainName];
}

- (IBAction)clearOuputs:(id)sender {
    [nameserverOutput setString:@""];
    [headersOutput setString:@""];
    [digOutput setString:@""];
}

- (IBAction)showWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [_window makeKeyAndOrderFront:nil];
}

@end
