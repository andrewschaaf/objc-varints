#import "Varint128.h"

@implementation Varint128

+ (NSData *)dataWithUnsignedInt:(unsigned int)value {
    return [self dataWithUnsignedInteger:value];
}

+ (NSData *)dataWithUnsignedInteger:(NSUInteger)x {
    uint8_t bytes[5];
    int i = 0;
    bytes[0] = 0;
    while (x > 0) {
        bytes[i] = (x & 0x7F);
        x = x >> 7;
        if (x > 0) {
            bytes[i] = bytes[i] | 0x80;
            i++;
        }
    }
    i++;
    return [NSData dataWithBytes:bytes length:i];
}

@end
