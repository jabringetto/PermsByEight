//
//  PermDetector.m
//  PermsByEight
//
//  Created by Jeremy Bringetto on 4/28/17.
//  Copyright © 2017 Jeremy Bringetto. All rights reserved.
//

#import "PermDetector.h"

@interface PermDetector()

@property (nonatomic) Console *console;
@property (nonatomic) NSString *consoleMessage;
@property (nonatomic) NSString *examplePermutation;
@property (nonatomic) NSDictionary *threeDigitPerms;


@end


@implementation PermDetector

# pragma mark Console Operations

-(void)launchTheConsole
{
    self.console = [[Console alloc]init];
    self.console.delegate = self;
    [self.console getConsoleInput];
    
}
-(void)receiveConsoleInput:(NSString*)input
{
    input = [self.console sanitizeConsoleInput:input];
    
    BOOL permsDivisibleBy8 = [self isAnyPermutationDivisbleBy8:input];
    self.consoleMessage = [self consoleMessage:permsDivisibleBy8:input];
    [self.console writeToConsole:self.consoleMessage];
    [self.console getConsoleInput];
}
-(NSString*)consoleMessage:(BOOL)permsDivisibleByEight :(NSString *)input
{
    NSString *msg = [NSString stringWithFormat: @"There are no permutations of %@ that are divisible by 8.",input]; 
    
    if(permsDivisibleByEight)
    {
        if(input.length > 3)
        {
            msg = [NSString stringWithFormat: @"%@ has permutations that are divisible by 8, for example ones that end with the following 3-digit series: %@",input,self.examplePermutation]; 
        }
        else
        {
            BOOL multipleOf8 = [input integerValue] % 8 == 0;
            if(multipleOf8)
            {
                msg = [NSString stringWithFormat:@"%@ is divisible by 8.",input];
            }
            else
            {
                switch (input.length)
                {
                        
                    case 3:
                        msg = [NSString stringWithFormat: @"%@ has permutations that are divisible by 8, for example: %@",input,self.examplePermutation]; 
                        break;
                        
                    case 2:
                        msg = [NSString stringWithFormat: @"%@ has permutations that are divisible by 8, for example: %@",input,self.examplePermutation]; 
                        break;
                        
                        
                    default:
                        
                        break;
                }
            }
     
        }
        
    }
    
    
    return msg;
}


# pragma mark Setup 

-(void)setup
{
    if(!self.threeDigitPerms)
    {
        self.threeDigitPerms = [self threeDigitMultiplesOfEightPerms]; 
    }
}


# pragma mark Divisibility by Eight Analysis

-(BOOL)isAnyPermutationDivisbleBy8:(NSString*)numericString
{
    // Analyse and condense:
    NSDictionary *analysis = [self divisibilityBy8Analysis:numericString];
    
    
    //check for less than 8 scenario
    NSInteger numericInteger = [numericString integerValue];
    if(numericInteger  < 8)
    {
        return NO;
    }
    
    // check for only odd numbers scenario
    NSNumber *allOdds = analysis[@"allOdds"];
    BOOL onlyOdds = [allOdds boolValue];
    if(onlyOdds)
    {
        return NO;
    }
    
    // handle the evens
    NSNumber *twoOrSix = analysis[@"containsTwoOrSix"];
    NSNumber *zeroFourOrEight = analysis[@"containsZeroFourOrEight"];
    BOOL contains2or6 = [twoOrSix boolValue];
    BOOL contains0or4or8 = [zeroFourOrEight boolValue];
    
    // if it ends in 2,6 it must have at least one 
    //odd number to be a multiple of eight.
    
    if(contains2or6 && !contains0or4or8)
    {
        NSNumber *numOdds = analysis[@"numOdds"];
        if([numOdds integerValue] == 0)
        {
            return NO;
        }
    }
    
    // if it ends in 0,4,8 it must have at least one 
    //additional even number to be a multiple of eight.
    
    if(!contains2or6 && contains0or4or8)
    {
        NSNumber *numEvens = analysis[@"numEvens"];
        BOOL twoOrMoreDigits = numericString.length > 1;
        
        if(twoOrMoreDigits && [numEvens integerValue] == 1)
        {
            return NO;
        }
    }
    
    
    //In the general case, we know that any 
    //number whose last three digits are
    //a multiple of eight is itself a 
    //multiple of eight. With this in
    //mind, we'll check to see if the input 
    //contains all the numbers found in 
    //any one of the three-digit permutations
    //of the multiples of eight, occuring
    //in the same or greater frequency.
    
    NSDictionary *inputDict = [self histogramByCharacter:numericString];
    
    for (NSDictionary *d in self.threeDigitPerms)
    {
        NSString *s = d[@"string"];
        NSDictionary *permDict = [self histogramByCharacter:s];
        NSInteger score = 0;
        for (NSString *key in [permDict allKeys])
        {
            NSNumber *n1 = inputDict[key];
            if(n1)
            {
                NSNumber *n2 = permDict[key];
                NSInteger val01 = [n1 integerValue];
                NSInteger val02 = [n2 integerValue];
                if(val01 >= val02)
                {
                    score += 1;
                }
            }
            
        }
        NSInteger min = [permDict allKeys].count;
        if([inputDict allKeys].count < min)
        {
            min = [inputDict allKeys].count;
        }
        if(score == min)
        {
            NSArray *perms = d[@"perms"];
            self.examplePermutation= perms[0];
            
            return YES;
        }
    }
    
    
    return NO;
    
}

-(NSDictionary*)divisibilityBy8Analysis:(NSString*)numericString
{
    NSMutableDictionary *results = [NSMutableDictionary new];
    NSArray *intsArray = [self arrayOfInts:numericString];
    NSDictionary *oddsAndEvens = [self oddsAndEvens:intsArray];
    
    BOOL allOddNumbers = [self allOddNumbers:intsArray];
    BOOL has2or6 = [self containsTwo_OR_Six:intsArray];
    BOOL has0or4or8 = [self containsZero_OR_Four_OR_Eight:intsArray];
    
    results[@"allOdds"] = [NSNumber numberWithBool:allOddNumbers];
    results[@"containsTwoOrSix"] = [NSNumber numberWithBool: has2or6];
    results[@"containsZeroFourOrEight"] = [NSNumber numberWithBool:has0or4or8];
    results[@"numOdds"] = oddsAndEvens[@"odds"];
    results[@"numEvens"] = oddsAndEvens[@"evens"];
    results[@"intsArray"] = intsArray;
    
    return [results copy];
}

-(BOOL)allOddNumbers:(NSArray*)arrayOfInts
{
    BOOL allOddNumbers = YES;
    for (NSNumber *num in arrayOfInts)
    {
        NSInteger n = [num integerValue];
        BOOL isOdd = [self numberIsOdd:n];
        if(!isOdd)
        {
            return NO;
            break;
        }
    }
    return allOddNumbers;
}
-(BOOL)containsTwo_OR_Six:(NSArray*)arrayOfInts
{
    for (NSNumber *num in arrayOfInts)
    {
        NSInteger n = [num integerValue];
        if (n == 2 || n==6)
        {
            return YES;
        }
    }
    return NO;
}
-(BOOL)containsZero_OR_Four_OR_Eight:(NSArray*)arrayOfInts
{
    
    for (NSNumber *num in arrayOfInts)
    {
        NSInteger n = [num integerValue];
        if (n == 0 || n == 4 || n == 8)
        {
            return YES;
        }
    }
    return NO;
    
}
-(NSDictionary*)oddsAndEvens:(NSArray*)arrayOfInts
{
    NSMutableDictionary *output = [NSMutableDictionary new];
    NSInteger numOdds = 0;
    NSInteger numEvens = 0;
    for (NSNumber *num in arrayOfInts)
    {
        if([self numberIsOdd:[num integerValue]])
        {
            numOdds += 1;
        }
        else
        {
            numEvens += 1;
        }
    }
    output[@"odds"] = [NSNumber numberWithInteger:numOdds];
    output[@"evens"] = [NSNumber numberWithInteger:numEvens];
    
    return [output copy];
}
-(NSDictionary *)threeDigitMultiplesOfEightPerms
{
    NSMutableArray *multipleOfEightPerms = [NSMutableArray new];
    NSMutableArray *usedStrings = [NSMutableArray new];
    NSMutableArray *usedPerms = [NSMutableArray new];
    
    for (int i=0; i< 1000; i++)
    {
        NSString *s = [self addLeadingZeros:[NSString stringWithFormat:@"%d",i]];
        NSArray *threeDigitPerms = [self uniquePermutationsForString:s];
        NSMutableArray *multsOfEight = [NSMutableArray new];
        
        for(NSString *perm in threeDigitPerms)
        {
            NSInteger m = [perm integerValue];
            if(m % 8 == 0)
            {
                BOOL permUsed = [usedPerms containsObject:perm];
                if(!permUsed)
                {
                    [multsOfEight addObject:perm];
                    [usedPerms addObject:perm];
                }
                
            }
        }
        BOOL stringUsed = [usedStrings containsObject:s];
        if(!stringUsed && multsOfEight.count > 0)
        {
            NSMutableDictionary *mult = [NSMutableDictionary new];
            mult[@"perms"] = multsOfEight;
            mult[@"string"] = s;
            [multipleOfEightPerms addObject:mult];
            [usedStrings addObject:s];
        }
    }
    
    return [multipleOfEightPerms  copy];
    
}

# pragma mark Parsing and Utility Functions

-(NSString *)addLeadingZeros:(NSString*)numericString
{
    NSString *output = numericString;
    NSString *zero = @"0";
    if(numericString.length == 1)
    {
        output = [NSString stringWithFormat:@"%@%@%@",zero,zero,numericString];
    }
    if(numericString.length == 2)
    {
        output = [zero stringByAppendingString:numericString];
    }
    
    return output;
    
}
-(NSString *)removeLeadingZeros:(NSString*)numericString
{
    NSInteger n = [numericString integerValue];
    NSString *output = [NSString stringWithFormat:@"%ld",n];
    return output;
}
-(NSArray*)arrayOfInts:(NSString*)numericString
{
    NSMutableArray *output = [NSMutableArray new];
    NSArray *chars = [self arrayOfCharacters:numericString];
    for (NSString *s in chars)
    {
        NSInteger n = [s integerValue];
        [output addObject:[NSNumber numberWithInteger:n]];
    }
    return [output copy];
    
}

-(BOOL)numberIsOdd:(NSInteger)number
{
    BOOL isOdd = YES;
    if(number %2 == 0)
    {
        isOdd = NO;
    }
    return isOdd;
}
-(NSMutableArray*)arrayOfCharacters:(NSString*)string
{
    NSMutableArray *chars = [[NSMutableArray alloc]init];
    for (int i=0; i<string.length; i++)
    {
        NSString *ch = [NSString stringWithFormat:@"%c",[string characterAtIndex:i]];
        [chars addObject:ch];
    }
    return  chars;
}
-(NSDictionary*)histogramByCharacter:(NSString*)word
{
    NSArray * chars = [self arrayOfCharacters:word];
    NSMutableDictionary *histogram = [NSMutableDictionary new];
    for (NSString *s in chars)
    {
        BOOL hasKey = [[histogram allKeys] containsObject:s];
        if(hasKey)
        {
            NSNumber *num = histogram[s];
            NSInteger n = [num integerValue] + 1;
            histogram[s] = [NSNumber numberWithInteger:n];
        }
        else
        {
            histogram[s] = [NSNumber numberWithInteger:1];
        }
        
    }
    return [histogram copy];    
}

#pragma mark Permuations Calculation

-(NSArray*)uniquePermutationsForString:(NSString*)string
{
    NSMutableArray *allPermutations = [[NSMutableArray alloc]init];
    NSInteger lastIndex = string.length-1;
    allPermutations = [[self permutations:string fromIndex:0 toIndex:lastIndex :allPermutations]mutableCopy];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:allPermutations];
    NSArray *noDuplicates = [orderedSet array];
    return noDuplicates;
}

-(NSArray*)permutations:(NSString*)inputString fromIndex:(NSInteger)l toIndex:(NSInteger)r :(NSMutableArray*)outputArray
{
    if(l == r)
    {
        [outputArray addObject:inputString];
    }
    else
    {
        NSMutableArray *characters = [self arrayOfCharacters:inputString];
        
        for (NSInteger j=l; j<characters.count ; j++)
        {
            [characters exchangeObjectAtIndex:l withObjectAtIndex:j];
            NSString *perm = [characters componentsJoinedByString:@""];
            
            if(l < r)
            {
                [self permutations:perm fromIndex:l+1 toIndex:r:outputArray];
            }
            [characters exchangeObjectAtIndex:l withObjectAtIndex:j];
        }
        
    }
    return [outputArray copy];
    
}


@end
