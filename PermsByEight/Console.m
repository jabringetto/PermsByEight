//
//  Console.m
//  PermsByEight
//
//  Created by Jeremy Bringetto on 4/28/17.
//  Copyright © 2017 Jeremy Bringetto. All rights reserved.
//

#import "Console.h"

@implementation Console

-(void)getConsoleInput
{
    NSString *carrot = @"\nPlease enter a number at the prompt below. This program will inform you whether any permutation of the number you entered is divisible by 8.\n\n>";
    [carrot writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    NSFileHandle *keyboard = [NSFileHandle fileHandleWithStandardInput];
    NSData *data = [keyboard availableData];
    NSString* input = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    input = [self sanitizeConsoleInput:input];
    BOOL onlyNumbers = [self containsOnlyNumbers:input];
    if(onlyNumbers)
    {
       [self.delegate receiveConsoleInput:input]; 
    }
    else
    {
        NSString *warning = @"\nThe string you entered was not numeric, please try again.\n";
         [warning writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
        [self getConsoleInput];
    }
}
-(void)writeToConsole:(NSString *)message
{
    NSString *spc = @"\n>";
    [spc writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    [message writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    [spc writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}
-(BOOL)containsOnlyNumbers:(NSString *)input
{
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    BOOL onlyNumbers = NO;
    BOOL notEmpty = input.length > 0;
    BOOL allDigits = [input rangeOfCharacterFromSet:notDigits].location == NSNotFound;
    
    if(notEmpty && allDigits)
    {
        onlyNumbers = YES;
    }
    return onlyNumbers;
}
-(NSString*)sanitizeConsoleInput:(NSString*)input
{
    NSString *emptyString = @"";
    NSString *s =input;
    
    if(s)
    {
        BOOL nonEmptyString = [s isKindOfClass:[NSString class]] && s.length > 0;
        if(nonEmptyString)
        {
            s = [s stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            NSArray* words = [s componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
            s = [words componentsJoinedByString:@""];

            return s;
        }
        else
        {
            return emptyString;
        }
        
    }
    else
    {
        return emptyString;
    }
    
}
-(void)passInputToDelegate:(NSString*)input
{
    input = [self sanitizeConsoleInput:input];
    [self.delegate receiveConsoleInput:input];
}


@end
