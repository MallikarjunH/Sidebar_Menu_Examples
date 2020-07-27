//
//  NSString+DateAsAppleTime.m
//  emSigner
//
//  Created by Emudhra on 28/12/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import "NSString+DateAsAppleTime.h"

@implementation NSString (DateAsAppleTime)

- (NSString*)transformedValue:(NSDate *)date
{
    // Initialize the formatter.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    // Initialize the calendar and flags.
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create reference date for supplied date.
    if (date == nil) {
               return @"";
           }
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate *suppliedDate = [calendar dateFromComponents:comps];
    
    // Iterate through the eight days (tomorrow, today, and the last six).
    int i;
    for (i = -1; i < 7; i++)
    {
        // Initialize reference date.
        comps = [calendar components:unitFlags fromDate:[NSDate date]];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        [comps setDay:[comps day] - i];
        NSDate *referenceDate = [calendar dateFromComponents:comps];
        // Get week day (starts at 1).
        long weekday = [[calendar components:unitFlags fromDate:referenceDate] weekday] - 1;
       
        
        if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == -1)
        {
            // Tomorrow
            return @"";
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 0)
        {
            // Today's time (a la iPhone Mail)
            formatter.dateFormat = @"HH:mm:ss";
            NSString *convertedString = [formatter stringFromDate:date];
            // [formatter setDateStyle:NSDateFormatterNoStyle];
            //[formatter setTimeStyle:NSDateFormatterShortStyle];
            return @"Today";
            
           // return [NSString stringWithFormat:@"Today %@",convertedString];
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 1)
        {
            // Today
            return @"Yesterday";
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame)
        {
            // Day of the week
            NSString *day = [[formatter weekdaySymbols] objectAtIndex:weekday];
            return day;
        }
    }
    
    // It's not in those eight days.
    NSString *defaultDate = [formatter stringFromDate:date];
    return defaultDate;
}

- (NSAttributedString*)refreshForDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor grayColor]
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    
    return attributedTitle;
}


@end
