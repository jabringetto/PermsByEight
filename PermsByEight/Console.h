//
//  Console.h
//  PermsByEight
//
//  Created by Jeremy Bringetto on 4/28/17.
//  Copyright © 2017 Jeremy Bringetto. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConsoleDelegate 

-(void)receiveConsoleInput:(NSString*)input;

@end

@interface Console : NSObject

@property (weak) id <ConsoleDelegate> delegate;

-(void)getConsoleInput;
-(void)passInputToDelegate:(NSString*)input;
-(void)writeToConsole:(NSString *)message;
-(NSString*)sanitizeConsoleInput:(NSString*)input;

@end
