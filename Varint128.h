#import <Foundation/Foundation.h>

@interface Varint128 : NSObject

+ (NSData *)dataWithUnsignedInt:(unsigned int)value;
+ (NSData *)dataWithUnsignedInteger:(NSUInteger)value;

@end
