#import "Kiwi.h"
#import "Varint128.h"

SPEC_BEGIN(Varint128Spec)

describe(@"Varint128", ^{

    describe(@"+dataWithUnsignedInt", ^{
        it(@"uses +dataWithUInt32", ^{
            NSData *expectedData = [@"Foo" dataUsingEncoding:NSUTF8StringEncoding];
            [[Varint128 stubAndReturn:expectedData] dataWithUInt32:123];
            [[[Varint128 dataWithUnsignedInt:123] should] equal:expectedData];
        });
    });

    describe(@"+dataWithUInt32:", ^{
        
        describe(@"introductory examples", ^{

            it(@"maps 0 -> 00", ^{
                uint8_t bytes[1] = {0};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                [[[Varint128 dataWithUInt32:0] should] equal:data];
            });

            it(@"maps 1 -> 01", ^{
                uint8_t bytes[1] = {1};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                [[[Varint128 dataWithUInt32:1] should] equal:data];
            });

            // 127 = 0b1111111 = varint128("01111111")
            it(@"maps 127 -> 7F", ^{
                uint8_t bytes[1] = {0x7F};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                [[[Varint128 dataWithUInt32:127] should] equal:data];
            });

            // 128 = 0b10000000 = little_endian_128(" 0000000  0000001")
            //                  =         varint128("10000000 00000001")
            it(@"maps 128 -> 80 01", ^{
                uint8_t bytes[2] = {0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                [[[Varint128 dataWithUInt32:128] should] equal:data];
            });

            // 130 = 0b10000001 = little_endian_128(" 0000010  0000001")
            //                  =         varint128("10000010 00000001")
            it(@"maps 130 -> 82 01", ^{
                uint8_t bytes[2] = {0x82, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                [[[Varint128 dataWithUInt32:130] should] equal:data];
            });

            // 128**2 = 0b100000000000000 = little_endian_128(" 0000000  0000000  0000001 ")
            //                            =         varint128("10000000 10000000 00000001 ")
            it(@"maps 128**2 -> 80 80 01", ^{
                uint8_t bytes[3] = {0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:3];
                [[[Varint128 dataWithUInt32:(128 * 128)] should] equal:data];
            });

            // 300 = 0b100101100 = little_endian_128(" 0101100  0000010")
            //                   =         varint128("10101100 00000010")
            it(@"maps 300 -> AC 02", ^{
                uint8_t bytes[2] = {0xAC, 0x02};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                [[[Varint128 dataWithUInt32:300] should] equal:data];
            });

            // 31415926 = 0b1110111110101111001110110
            //          = little_endian_128(" 1110110  0111100  1111101  0001110")
            //          =         varint128("11110110 10111100 11111101 00001110")
            //          =         varint128(0xF6BCFD0E)
            it(@"maps 31415926 -> F6 BC FD 0E", ^{
                uint8_t bytes[4] = {0xF6, 0xBC, 0xFD, 0x0E};
                NSData *data = [NSData dataWithBytes:bytes length:4];
                [[[Varint128 dataWithUInt32:31415926] should] equal:data];
            });

            // (2**32 - 2) = 0b11111111111111111111111111111110
            //             = little_endian_128(" 1111110  1111111  1111111  1111111  0001111")
            //             =         varint128("11111110 11111111 11111111 11111111 00001111")
            it(@"maps (2**32 - 2) -> FE FF FF FF 0F", ^{
                uint8_t bytes[5] = {0xFE, 0xFF, 0xFF, 0xFF, 0x0F};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                [[[Varint128 dataWithUInt32:4294967294] should] equal:data];
            });

            // (2**32 - 1) = 0b11111111111111111111111111111111
            //             = little_endian_128(" 1111111  1111111  1111111  1111111  0001111")
            //             =         varint128("11111111 11111111 11111111 11111111 00001111")
            it(@"maps (2**32 - 1) -> FF FF FF FF 0F", ^{
                uint8_t bytes[5] = {0xFF, 0xFF, 0xFF, 0xFF, 0x0F};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                [[[Varint128 dataWithUInt32:4294967295] should] equal:data];
            });
        });

        describe(@"larger powers of two", ^{
            it(@"maps 128**3 -> 80 80 80 01", ^{
                uint8_t bytes[4] = {0x80, 0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:4];
                [[[Varint128 dataWithUInt32:(128 * 128 * 128)] should] equal:data];
            });
            it(@"maps 128**4 -> 80 80 80 80 01", ^{
                uint8_t bytes[5] = {0x80, 0x80, 0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                [[[Varint128 dataWithUInt32:(128 * 128 * 128 * 128)] should] equal:data];
            });
        });
    });

    describe(@"+dataWithUInt64:", ^{

        describe(@"inputs >= 2**32", ^{

            // 2**32 = 0b100000000000000000000000000000000
            //       = little_endian_128(" 0000000  0000000  0000000  0000000  0010000")
            //       =         varint128("10000000 10000000 10000000 10000000 00010000")
            it(@"maps 2**32 -> (80 four times) + 0x10", ^{
                uint8_t bytes[5] = {0x80, 0x80, 0x80, 0x80, 0x10};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                [[[Varint128 dataWithUInt64:4294967296] should] equal:data];
            });

            // 2**64 - 1
            // = 0b(11111111 11111111 11111111 11111111  11111111 11111111 11111111 11111111)
            // = little_endian_128(" 1111111  1111111  1111111  1111111  1111111  1111111  1111111  1111111  1111111  0000001")
            // =         varint128("11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111111 00000001")
            it(@"maps (2**64 - 1) -> (FF nine times) + 01", ^{
                uint8_t bytes[10] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:10];
                [[[Varint128 dataWithUInt64:18446744073709551615ull] should] equal:data];
            });

        });

        describe(@"introductory examples", ^{

            it(@"maps 0 -> 00", ^{
                uint8_t bytes[1] = {0};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                [[[Varint128 dataWithUInt64:0] should] equal:data];
            });

            it(@"maps 1 -> 01", ^{
                uint8_t bytes[1] = {1};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                [[[Varint128 dataWithUInt64:1] should] equal:data];
            });

            // 127 = 0b1111111 = varint128("01111111")
            it(@"maps 127 -> 7F", ^{
                uint8_t bytes[1] = {0x7F};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                [[[Varint128 dataWithUInt64:127] should] equal:data];
            });

            // 128 = 0b10000000 = little_endian_128(" 0000000  0000001")
            //                  =         varint128("10000000 00000001")
            it(@"maps 128 -> 80 01", ^{
                uint8_t bytes[2] = {0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                [[[Varint128 dataWithUInt64:128] should] equal:data];
            });

            // 130 = 0b10000001 = little_endian_128(" 0000010  0000001")
            //                  =         varint128("10000010 00000001")
            it(@"maps 130 -> 82 01", ^{
                uint8_t bytes[2] = {0x82, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                [[[Varint128 dataWithUInt64:130] should] equal:data];
            });

            // 128**2 = 0b100000000000000 = little_endian_128(" 0000000  0000000  0000001 ")
            //                            =         varint128("10000000 10000000 00000001 ")
            it(@"maps 128**2 -> 80 80 01", ^{
                uint8_t bytes[3] = {0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:3];
                [[[Varint128 dataWithUInt64:(128 * 128)] should] equal:data];
            });

            // 300 = 0b100101100 = little_endian_128(" 0101100  0000010")
            //                   =         varint128("10101100 00000010")
            it(@"maps 300 -> AC 02", ^{
                uint8_t bytes[2] = {0xAC, 0x02};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                [[[Varint128 dataWithUInt64:300] should] equal:data];
            });

            // 31415926 = 0b1110111110101111001110110
            //          = little_endian_128(" 1110110  0111100  1111101  0001110")
            //          =         varint128("11110110 10111100 11111101 00001110")
            //          =         varint128(0xF6BCFD0E)
            it(@"maps 31415926 -> F6 BC FD 0E", ^{
                uint8_t bytes[4] = {0xF6, 0xBC, 0xFD, 0x0E};
                NSData *data = [NSData dataWithBytes:bytes length:4];
                [[[Varint128 dataWithUInt64:31415926] should] equal:data];
            });

            // (2**32 - 2) = 0b11111111111111111111111111111110
            //             = little_endian_128(" 1111110  1111111  1111111  1111111  0001111")
            //             =         varint128("11111110 11111111 11111111 11111111 00001111")
            it(@"maps (2**32 - 2) -> FE FF FF FF 0F", ^{
                uint8_t bytes[5] = {0xFE, 0xFF, 0xFF, 0xFF, 0x0F};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                [[[Varint128 dataWithUInt64:4294967294] should] equal:data];
            });

            // (2**32 - 1) = 0b11111111111111111111111111111111
            //             = little_endian_128(" 1111111  1111111  1111111  1111111  0001111")
            //             =         varint128("11111111 11111111 11111111 11111111 00001111")
            it(@"maps (2**32 - 1) -> FF FF FF FF 0F", ^{
                uint8_t bytes[5] = {0xFF, 0xFF, 0xFF, 0xFF, 0x0F};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                [[[Varint128 dataWithUInt64:4294967295] should] equal:data];
            });
        });

        describe(@"larger powers of two", ^{
            it(@"maps 128**3 -> 80 80 80 01", ^{
                uint8_t bytes[4] = {0x80, 0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:4];
                [[[Varint128 dataWithUInt64:(128 * 128 * 128)] should] equal:data];
            });
            it(@"maps 128**4 -> 80 80 80 80 01", ^{
                uint8_t bytes[5] = {0x80, 0x80, 0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                [[[Varint128 dataWithUInt64:(128 * 128 * 128 * 128)] should] equal:data];
            });
        });
    });

    describe(@"+decode32FromBytes:offset:", ^{

        describe(@"introductory examples", ^{

            it(@"maps 00 -> 0 and increments the offset", ^{
                uint8_t bytes[1] = {0};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                UInt32 offset = 0;
                [[theValue([Varint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(0)];
                [[theValue(offset) should] equal:theValue(1)];
            });

            it(@"maps 01 -> 1 and increments the offset", ^{
                uint8_t bytes[1] = {1};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                UInt32 offset = 0;
                [[theValue([Varint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(1)];
                [[theValue(offset) should] equal:theValue(1)];
            });

            it(@"maps 7F -> 127 and increments the offset", ^{
                uint8_t bytes[1] = {0x7F};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                UInt32 offset = 0;
                [[theValue([Varint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(127)];
                [[theValue(offset) should] equal:theValue(1)];
            });

            it(@"maps 80 01 -> 128 and increments the offset", ^{
                uint8_t bytes[2] = {0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                UInt32 offset = 0;
                [[theValue([Varint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(128)];
                [[theValue(offset) should] equal:theValue(2)];
            });

            it(@"maps 82 01 -> 130 and increments the offset", ^{
                uint8_t bytes[2] = {0x82, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                UInt32 offset = 0;
                [[theValue([Varint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(130)];
                [[theValue(offset) should] equal:theValue(2)];
            });

            it(@"maps 80 80 01 -> 128**2 and increments the offset", ^{
                uint8_t bytes[3] = {0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:3];
                UInt32 offset = 0;
                [[theValue([Varint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(128 * 128)];
                [[theValue(offset) should] equal:theValue(3)];
            });

            it(@"maps AC 02 -> 300 and increments the offset", ^{
                uint8_t bytes[2] = {0xAC, 0x02};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                UInt32 offset = 0;
                [[theValue([Varint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(300)];
                [[theValue(offset) should] equal:theValue(2)];
            });

            it(@"maps F6 BC FD 0E -> 31415926 and increments the offset", ^{
                uint8_t bytes[4] = {0xF6, 0xBC, 0xFD, 0x0E};
                NSData *data = [NSData dataWithBytes:bytes length:4];
                UInt32 offset = 0;
                [[theValue([Varint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(31415926)];
                [[theValue(offset) should] equal:theValue(4)];
            });

            it(@"maps FE FF FF FF 0F -> (2**32 - 2) and increments the offset", ^{
                uint8_t bytes[5] = {0xFE, 0xFF, 0xFF, 0xFF, 0x0F};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                UInt32 offset = 0;
                [[theValue([Varint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(4294967294)];
                [[theValue(offset) should] equal:theValue(5)];
            });

            it(@"maps FF FF FF FF 0F -> (2**32 - 1) and increments the offset", ^{
                uint8_t bytes[5] = {0xFF, 0xFF, 0xFF, 0xFF, 0x0F};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                UInt32 offset = 0;
                [[theValue([Varint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(4294967295)];
                [[theValue(offset) should] equal:theValue(5)];
            });
        });

        describe(@"larger powers of two", ^{

            it(@"maps 80 80 80 01 -> 128**3 and increments the offset", ^{
                uint8_t bytes[4] = {0x80, 0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:4];
                UInt32 offset = 0;
                [[theValue([Varint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(128 * 128 * 128)];
                [[theValue(offset) should] equal:theValue(4)];
            });

            it(@"maps 80 80 80 80 01 -> 128**4 and increments the offset", ^{
                uint8_t bytes[5] = {0x80, 0x80, 0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                UInt32 offset = 0;
                [[theValue([Varint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(128 * 128 * 128 * 128)];
                [[theValue(offset) should] equal:theValue(5)];
            });
        });
    });

    describe(@"+decode64FromBytes:offset:", ^{

        describe(@"inputs >= 2**32", ^{

            it(@"maps ((80 four times) + 0x10) -> 2**32 and increments the offset", ^{
                uint8_t bytes[5] = {0x80, 0x80, 0x80, 0x80, 0x10};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(4294967296)];
                [[theValue(offset) should] equal:theValue(5)];
            });

            it(@"maps ((FF nine times) + 01) -> (2**64 - 1) and increments the offset", ^{
                uint8_t bytes[10] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:10];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(18446744073709551615ull)];
                [[theValue(offset) should] equal:theValue(10)];
            });
        });

        describe(@"introductory examples", ^{

            it(@"maps 00 -> 0 and increments the offset", ^{
                uint8_t bytes[1] = {0};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(0)];
                [[theValue(offset) should] equal:theValue(1)];
            });

            it(@"maps 01 -> 1 and increments the offset", ^{
                uint8_t bytes[1] = {1};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(1)];
                [[theValue(offset) should] equal:theValue(1)];
            });

            it(@"maps 7F -> 127 and increments the offset", ^{
                uint8_t bytes[1] = {0x7F};
                NSData *data = [NSData dataWithBytes:bytes length:1];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(127)];
                [[theValue(offset) should] equal:theValue(1)];
            });

            it(@"maps 80 01 -> 128 and increments the offset", ^{
                uint8_t bytes[2] = {0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(128)];
                [[theValue(offset) should] equal:theValue(2)];
            });

            it(@"maps 82 01 -> 130 and increments the offset", ^{
                uint8_t bytes[2] = {0x82, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(130)];
                [[theValue(offset) should] equal:theValue(2)];
            });

            it(@"maps 80 80 01 -> 128**2 and increments the offset", ^{
                uint8_t bytes[3] = {0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:3];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(128 * 128)];
                [[theValue(offset) should] equal:theValue(3)];
            });

            it(@"maps AC 02 -> 300 and increments the offset", ^{
                uint8_t bytes[2] = {0xAC, 0x02};
                NSData *data = [NSData dataWithBytes:bytes length:2];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(300)];
                [[theValue(offset) should] equal:theValue(2)];
            });

            it(@"maps F6 BC FD 0E -> 31415926 and increments the offset", ^{
                uint8_t bytes[4] = {0xF6, 0xBC, 0xFD, 0x0E};
                NSData *data = [NSData dataWithBytes:bytes length:4];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(31415926)];
                [[theValue(offset) should] equal:theValue(4)];
            });

            it(@"maps FE FF FF FF 0F -> (2**32 - 2) and increments the offset", ^{
                uint8_t bytes[5] = {0xFE, 0xFF, 0xFF, 0xFF, 0x0F};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(4294967294)];
                [[theValue(offset) should] equal:theValue(5)];
            });

            it(@"maps FF FF FF FF 0F -> (2**32 - 1) and increments the offset", ^{
                uint8_t bytes[5] = {0xFF, 0xFF, 0xFF, 0xFF, 0x0F};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(4294967295)];
                [[theValue(offset) should] equal:theValue(5)];
            });
        });

        describe(@"larger powers of two", ^{

            it(@"maps 80 80 80 01 -> 128**3 and increments the offset", ^{
                uint8_t bytes[4] = {0x80, 0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:4];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(128 * 128 * 128)];
                [[theValue(offset) should] equal:theValue(4)];
            });

            it(@"maps 80 80 80 80 01 -> 128**4 and increments the offset", ^{
                uint8_t bytes[5] = {0x80, 0x80, 0x80, 0x80, 0x01};
                NSData *data = [NSData dataWithBytes:bytes length:5];
                UInt32 offset = 0;
                [[theValue([Varint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(128 * 128 * 128 * 128)];
                [[theValue(offset) should] equal:theValue(5)];
            });
        });
    });
});

SPEC_END
