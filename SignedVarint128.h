#import <Foundation/Foundation.h>

@interface SignedVarint128 : NSObject

+ (NSData *)dataWithInt:(int)value;
+ (NSData *)dataWithSInt32:(SInt32)value;
+ (NSData *)dataWithSInt64:(SInt64)value;

@end
