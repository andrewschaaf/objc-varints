#import "Varint128.h"

@implementation Varint128

+ (NSData *)dataWithUnsignedInt:(unsigned int)value {
    return [NSData data];
}

+ (NSData *)dataWithUnsignedInteger:(NSUInteger)value {
    uint8_t bytes[5];
    int size;
    if (value < 128) {
        bytes[0] = value;
        size = 1;
    } else if (value < (128 * 128)) {
        bytes[0] = 0x80 | ((value >> 0) & 0x7F);
        bytes[1] = 0x00 | ((value >> 7) & 0x7F);
        size = 2;
    } else if (value < (128 * 128 * 128)) {
        bytes[0] = 0x80 | ((value >> (7 * 0)) & 0x7F);
        bytes[1] = 0x80 | ((value >> (7 * 1)) & 0x7F);
        bytes[2] = 0x00 | ((value >> (7 * 2)) & 0x7F);
        size = 3;
    } else if (value < (128 * 128 * 128 * 128)) {
        bytes[0] = 0x80 | ((value >> (7 * 0)) & 0x7F);
        bytes[1] = 0x80 | ((value >> (7 * 1)) & 0x7F);
        bytes[2] = 0x80 | ((value >> (7 * 2)) & 0x7F);
        bytes[3] = 0x00 | ((value >> (7 * 3)) & 0x7F);
        size = 4;
    } else {
        bytes[0] = 0x80 | ((value >> (7 * 0)) & 0x7F);
        bytes[1] = 0x80 | ((value >> (7 * 1)) & 0x7F);
        bytes[2] = 0x80 | ((value >> (7 * 2)) & 0x7F);
        bytes[3] = 0x80 | ((value >> (7 * 3)) & 0x7F);
        bytes[4] = 0x00 | ((value >> (7 * 4)) & 0x7F);
        size = 5;
    }
    return [NSData dataWithBytes:bytes length:size];
}

@end
