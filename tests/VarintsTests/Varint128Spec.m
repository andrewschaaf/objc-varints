#import "Kiwi.h"
#import "Varint128.h"

SPEC_BEGIN(Varint128Spec)

describe(@"Varint128", ^{
    describe(@"+dataWithUnsignedInteger:", ^{
        
        describe(@"introductory examples", ^{

            it(@"maps 0 -> 00", ^{
                uint8_t bytes[1] = {0};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                [[[Varint128 dataWithUnsignedInteger:0] should] equal:data];
            });

            it(@"maps 1 -> 01", ^{
                uint8_t bytes[1] = {1};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                [[[Varint128 dataWithUnsignedInteger:1] should] equal:data];
            });

            // 127 = 0b1111111 = varint128("01111111")
            it(@"maps 127 -> 7F", ^{
                uint8_t bytes[1] = {0x7F};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                [[[Varint128 dataWithUnsignedInteger:127] should] equal:data];
            });

            // 128 = 0b10000000 = little_endian_128(" 0000000  0000001")
            //                  =         varint128("10000000 00000001")
            it(@"maps 128 -> 80 01", ^{
                uint8_t bytes[2] = {0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                [[[Varint128 dataWithUnsignedInteger:128] should] equal:data];
            });

            // 130 = 0b10000001 = little_endian_128(" 0000010  0000001")
            //                  =         varint128("10000010 00000001")
            it(@"maps 130 -> 82 01", ^{
                uint8_t bytes[2] = {0x82, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                [[[Varint128 dataWithUnsignedInteger:130] should] equal:data];
            });

            // 128**2 = 0b100000000000000 = little_endian_128(" 0000000  0000000  0000001 ")
            //                            =         varint128("10000000 10000000 00000001 ")
            it(@"maps 128**2 -> 80 80 01", ^{
                uint8_t bytes[3] = {0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:3];
                [[[Varint128 dataWithUnsignedInteger:(128 * 128)] should] equal:data];
            });

            // 300 = 0b100101100 = little_endian_128(" 0101100  0000010")
            //                   =         varint128("10101100 00000010")
            it(@"maps 300 -> AC 02", ^{
                uint8_t bytes[2] = {0xAC, 0x02};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                [[[Varint128 dataWithUnsignedInteger:300] should] equal:data];
            });

            // 31415926 = 0b1110111110101111001110110
            //          = little_endian_128(" 1110110  0111100  1111101  0001110")
            //          =         varint128("11110110 10111100 11111101 00001110")
            //          =         varint128(0xF6BCFD0E)
            it(@"maps 31415926 -> F6 BC FD 0E", ^{
                uint8_t bytes[4] = {0xF6, 0xBC, 0xFD, 0x0E};
                NSData *data = [NSData dataWithBytes:bytes length:4];
                [[[Varint128 dataWithUnsignedInteger:31415926] should] equal:data];
            });

            // (2**32 - 1) = 0b11111111111111111111111111111111
            //             = little_endian_128(" 1111111  1111111  1111111  1111111  0001111")
            //             =         varint128("11111111 11111111 11111111 11111111 00001111")
            it(@"maps (2**32 - 1) -> FF FF FF FF 8F", ^{
                uint8_t bytes[5] = {0xFF, 0xFF, 0xFF, 0xFF, 0x0F};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                [[[Varint128 dataWithUnsignedInteger:4294967295] should] equal:data];
            });
        });

        describe(@"larger powers of two", ^{
            it(@"maps 128**3 -> 80 80 80 01", ^{
                uint8_t bytes[4] = {0x80, 0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:4];
                [[[Varint128 dataWithUnsignedInteger:(128 * 128 * 128)] should] equal:data];
            });
            it(@"maps 128**4 -> 80 80 80 80 01", ^{
                uint8_t bytes[5] = {0x80, 0x80, 0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                [[[Varint128 dataWithUnsignedInteger:(128 * 128 * 128 * 128)] should] equal:data];
            });
        });
    });
});

SPEC_END
