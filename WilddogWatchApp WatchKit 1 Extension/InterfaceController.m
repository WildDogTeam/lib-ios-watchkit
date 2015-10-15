//
//  InterfaceController.m
//  WilddogWatchApp WatchKit 1 Extension
//
//  Created by Garin on 15/9/25.
//  Copyright © 2015年 wilddog. All rights reserved.
//

#import "InterfaceController.h"
#import <Wilddog/Wilddog.h>

@interface InterfaceController()

@property (strong, nonatomic) Wilddog *ref;

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *labelUpdate;
@end



@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
//    self.ref = [[Wilddog alloc]initWithUrl:@"http://<your-wilddog-app>.wilddogio.com/updates"];
    self.ref = [[Wilddog alloc]initWithUrl:@"http://wilddogwatch.wilddogio.com/updates"];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self.ref observeEventType:WEventTypeChildAdded withBlock:^(WDataSnapshot *snapshot) {
        NSLog(@"%@",snapshot.value);
        if([snapshot exists]){
            [self.labelUpdate setText:[snapshot.value stringValue]];
        }else{
            [self.labelUpdate setText:@"No update"];
        }
    }];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [self.ref removeAllObservers];
}

- (IBAction)updateButtonDidTouch {
    
    [[self.ref childByAutoId]setValue:kWilddogServerValueTimestamp];
}

@end



