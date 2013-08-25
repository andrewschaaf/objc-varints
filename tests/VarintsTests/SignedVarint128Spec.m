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
});

SPEC_END
