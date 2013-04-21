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
    [domainInput heightAdjustLimit];
    
    NSFont *fixedFont = [NSFont fontWithName:@"Menlo" size:13]; 
    [outputArea setFont:fixedFont];
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

- (IBAction)digDomain:(id)sender {
    
    // get the domain input
    
    NSString *domain = [domainInput stringValue];
    
    // get name servers
    
    NSArray *arguments;
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
    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/dig"];
    
//    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: domain, nil];
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
    //    NSLog (@"Dig response: \n%@", string);
    
    [outputArea setString:commandOutput];
    NSRange answerSectionRange = [commandOutput rangeOfString:@";; ANSWER SECTION:"];
    if (answerSectionRange.location != NSNotFound) {
        [outputArea setSelectedRange:answerSectionRange];
    }

}

- (IBAction)showWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [_window makeKeyAndOrderFront:nil];
}

@end
