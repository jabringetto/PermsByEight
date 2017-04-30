//
//  PermDetector.h
//  PermsByEight
//
//  Created by Jeremy Bringetto on 4/28/17.
//  Copyright © 2017 Jeremy Bringetto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Console.h"

@interface PermDetector : NSObject <ConsoleDelegate>

-(void)setup;
-(void)launchTheConsole;

@end
