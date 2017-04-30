//
//  main.m
//  PermsByEight
//
//  Created by Jeremy Bringetto on 4/28/17.
//  Copyright © 2017 Jeremy Bringetto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Console.h"
#import "PermDetector.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        PermDetector *permDetector = [[PermDetector alloc]init];
        [permDetector setup];
        [permDetector launchTheConsole];
    }
    return 0;
}
