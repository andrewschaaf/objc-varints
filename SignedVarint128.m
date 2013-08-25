#import "SignedVarint128.h"
#import "Varint128.h"

@implementation SignedVarint128

+ (NSData *)dataWithInt:(int)value {
    return [self dataWithSInt32:value];
}

+ (NSData *)dataWithSInt32:(SInt32)value {
    UInt32 encoded = (UInt32)((value << 1) ^ (value >> 31));
    return [Varint128 dataWithUInt32:encoded];
}

@end
