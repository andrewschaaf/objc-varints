#import "Kiwi.h"
#import "SignedVarint128.h"

SPEC_BEGIN(SignedVarint128Spec)

describe(@"SignedVarint128", ^{

    describe(@"+dataWithInt", ^{
        it(@"uses +dataWithSInt32", ^{
            NSData *expectedData = [@"Foo" dataUsingEncoding:NSUTF8StringEncoding];
            [[SignedVarint128 stubAndReturn:expectedData] dataWithSInt32:123];
            [[[SignedVarint128 dataWithInt:123] should] equal:expectedData];
        });
    });

    describe(@"+dataWithSInt32:", ^{
        it(@"maps 0 -> 00", ^{
            uint8_t bytes[1] = {0x00};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            [[[SignedVarint128 dataWithSInt32:0] should] equal:data];
        });
        it(@"maps -1 -> 01", ^{
            uint8_t bytes[1] = {0x01};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            [[[SignedVarint128 dataWithSInt32:-1] should] equal:data];
        });
        it(@"maps 1 -> 02", ^{
            uint8_t bytes[1] = {0x02};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            [[[SignedVarint128 dataWithSInt32:1] should] equal:data];
        });
        it(@"maps -2 -> 03", ^{
            uint8_t bytes[1] = {0x03};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            [[[SignedVarint128 dataWithSInt32:-2] should] equal:data];
        });
        it(@"maps 2147483647 -> varint128(4294967294) = FE FF FF FF 0F", ^{
            uint8_t bytes[5] = {0xFE, 0xFF, 0xFF, 0xFF, 0x0F};
            NSData *data = [NSData dataWithBytes:bytes length:5];
            [[[SignedVarint128 dataWithSInt32:2147483647] should] equal:data];
        });
        it(@"maps -2147483648 -> varint128(4294967295) = FF FF FF FF 0F", ^{
            uint8_t bytes[5] = {0xFF, 0xFF, 0xFF, 0xFF, 0x0F};
            NSData *data = [NSData dataWithBytes:bytes length:5];
            [[[SignedVarint128 dataWithSInt32:-2147483648] should] equal:data];
        });
    });

    describe(@"+dataWithSInt64:", ^{
        it(@"maps 0 -> 00", ^{
            uint8_t bytes[1] = {0x00};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            [[[SignedVarint128 dataWithSInt64:0] should] equal:data];
        });
        it(@"maps -1 -> 01", ^{
            uint8_t bytes[1] = {0x01};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            [[[SignedVarint128 dataWithSInt64:-1] should] equal:data];
        });
        it(@"maps 1 -> 02", ^{
            uint8_t bytes[1] = {0x02};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            [[[SignedVarint128 dataWithSInt64:1] should] equal:data];
        });
        it(@"maps -2 -> 03", ^{
            uint8_t bytes[1] = {0x03};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            [[[SignedVarint128 dataWithSInt64:-2] should] equal:data];
        });
        it(@"maps 2147483647 -> varint128(4294967294) = FE FF FF FF 0F", ^{
            uint8_t bytes[5] = {0xFE, 0xFF, 0xFF, 0xFF, 0x0F};
            NSData *data = [NSData dataWithBytes:bytes length:5];
            [[[SignedVarint128 dataWithSInt64:2147483647] should] equal:data];
        });
        it(@"maps -2147483648 -> varint128(4294967295) = FF FF FF FF 0F", ^{
            uint8_t bytes[5] = {0xFF, 0xFF, 0xFF, 0xFF, 0x0F};
            NSData *data = [NSData dataWithBytes:bytes length:5];
            [[[SignedVarint128 dataWithSInt64:-2147483648] should] equal:data];
        });
        it(@"maps 2147483648 -> varint128(4294967296) = 80 80 80 80 10", ^{
            uint8_t bytes[5] = {0x80, 0x80, 0x80, 0x80, 0x10};
            NSData *data = [NSData dataWithBytes:bytes length:5];
            [[[SignedVarint128 dataWithSInt64:2147483648] should] equal:data];
        });
        it(@"maps -2147483649 -> varint128(4294967297) = 81 80 80 80 10", ^{
            uint8_t bytes[5] = {0x81, 0x80, 0x80, 0x80, 0x10};
            NSData *data = [NSData dataWithBytes:bytes length:5];
            [[[SignedVarint128 dataWithSInt64:-2147483649] should] equal:data];
        });
    });

    describe(@"+decode32FromBytes:offset:", ^{
        it(@"maps 00 -> 0", ^{
            uint8_t bytes[1] = {0x00};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(0)];
            [[theValue(offset) should] equal:theValue(1)];
        });
        it(@"maps 01 -> -1", ^{
            uint8_t bytes[1] = {0x01};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(-1)];
            [[theValue(offset) should] equal:theValue(1)];
        });
        it(@"maps 02 -> 1", ^{
            uint8_t bytes[1] = {0x02};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(1)];
            [[theValue(offset) should] equal:theValue(1)];
        });
        it(@"maps 03 -> -2", ^{
            uint8_t bytes[1] = {0x03};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(-2)];
            [[theValue(offset) should] equal:theValue(1)];
        });
        it(@"maps FE FF FF FF 0F -> 2147483647", ^{
            uint8_t bytes[5] = {0xFE, 0xFF, 0xFF, 0xFF, 0x0F};
            NSData *data = [NSData dataWithBytes:bytes length:5];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(2147483647)];
            [[theValue(offset) should] equal:theValue(5)];
        });
        it(@"maps FF FF FF FF 0F -> -2147483648", ^{
            uint8_t bytes[5] = {0xFF, 0xFF, 0xFF, 0xFF, 0x0F};
            NSData *data = [NSData dataWithBytes:bytes length:5];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode32FromBytes:data.bytes offset:&offset]) should] equal:theValue(-2147483648)];
            [[theValue(offset) should] equal:theValue(5)];
        });
    });

    describe(@"+decode64FromBytes:offset:", ^{
        it(@"maps 00 -> 0", ^{
            uint8_t bytes[1] = {0x00};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(0)];
            [[theValue(offset) should] equal:theValue(1)];
        });
        it(@"maps 01 -> -1", ^{
            uint8_t bytes[1] = {0x01};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(-1)];
            [[theValue(offset) should] equal:theValue(1)];
        });
        it(@"maps 02 -> 1", ^{
            uint8_t bytes[1] = {0x02};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(1)];
            [[theValue(offset) should] equal:theValue(1)];
        });
        it(@"maps 03 -> -2", ^{
            uint8_t bytes[1] = {0x03};
            NSData *data = [NSData dataWithBytes:bytes length:1];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(-2)];
            [[theValue(offset) should] equal:theValue(1)];
        });
        it(@"maps FE FF FF FF 0F -> 2147483647", ^{
            uint8_t bytes[5] = {0xFE, 0xFF, 0xFF, 0xFF, 0x0F};
            NSData *data = [NSData dataWithBytes:bytes length:5];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(2147483647)];
            [[theValue(offset) should] equal:theValue(5)];
        });
        it(@"maps FF FF FF FF 0F -> -2147483648", ^{
            uint8_t bytes[5] = {0xFF, 0xFF, 0xFF, 0xFF, 0x0F};
            NSData *data = [NSData dataWithBytes:bytes length:5];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(-2147483648)];
            [[theValue(offset) should] equal:theValue(5)];
        });
        it(@"maps 80 80 80 80 10 -> 2147483648", ^{
            uint8_t bytes[5] = {0x80, 0x80, 0x80, 0x80, 0x10};
            NSData *data = [NSData dataWithBytes:bytes length:5];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(2147483648)];
            [[theValue(offset) should] equal:theValue(5)];
        });
        it(@"maps 81 80 80 80 10 -> -2147483649", ^{
            uint8_t bytes[5] = {0x81, 0x80, 0x80, 0x80, 0x10};
            NSData *data = [NSData dataWithBytes:bytes length:5];
            UInt32 offset = 0;
            [[theValue([SignedVarint128 decode64FromBytes:data.bytes offset:&offset]) should] equal:theValue(-2147483649)];
            [[theValue(offset) should] equal:theValue(5)];
        });
    });
});

SPEC_END
