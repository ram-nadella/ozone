//
//  DragStatusView.m
//  Ozone
//
//  Created by Ram on 1/18/13.
//
//

// Code based on
// http://stackoverflow.com/questions/5663887/drag-and-drop-with-nsstatusitem/6493240#6493240

#import "DragStatusView.h"
#import "AppDelegate.h"

@implementation DragStatusView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        //register for drags
        [self registerForDraggedTypes:[NSArray arrayWithObjects: NSStringPboardType, nil]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.

    NSImage *statusIconImage = [NSImage imageNamed:@"lab"];
    NSPoint centerPoint = NSMakePoint(2.0, 2.0);

//    [statusIconImage drawAtPoint:centerPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    [statusIconImage drawAtPoint:centerPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    
    // set an image in a pre defined rectangle
//    NSRect statusIconRect = NSMakeRect(0, 0, 24, 24);
//    [self drawRect:statusIconRect];
//    [statusIconImage drawInRect:statusIconRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
//    
//    NSFrameRect(statusIconRect);
    
    
    // to just fill a color
    //    [[NSColor yellowColor] set];
    //    NSRectFill([self bounds]);
    
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];

    if ( [[pboard types] containsObject:NSStringPboardType] ) {
        NSString *input = [pboard propertyListForType:NSStringPboardType];
        NSLog(@"Dragged - %@ %@", input, [input className]);
        AppDelegate *appDelegate = [NSApp delegate];
        [appDelegate showWindow:self];
        [appDelegate replaceDomainInput:self withDomain:input];
        [appDelegate fetchData:self forDomain:input];
    }

    return YES;    
}

- (void)mouseDown:(NSEvent *)event {
    NSLog(@"clicked");
}

@end
