#import <Foundation/Foundation.h>

@interface Varint128 : NSObject

+ (NSData *)dataWithUnsignedInt:(unsigned int)value;
+ (NSData *)dataWithUInt32:(UInt32)value;

@end
