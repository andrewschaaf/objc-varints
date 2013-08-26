## Varint128

This is the same unsigned varint encoding that protobuf uses.

New to this encoding?
Read [Google's introduction](https://developers.google.com/protocol-buffers/docs/encoding#varints)
and/or
[my didactic Varint128Spec.m](https://github.com/andrewschaaf/objc-varints/blob/master/tests/VarintsTests/Varint128Spec.m).

```objc
+ (NSData *)dataWithUnsignedInt:(unsigned int)value;
+ (NSData *)dataWithUInt32:(UInt32)value;
+ (NSData *)dataWithUInt64:(UInt64)value;
```


## SignedVarint128

This is the same signed varint encoding that protobuf uses.

See
[Google's introduction](https://developers.google.com/protocol-buffers/docs/encoding#types)
and/or
[SignedVarint128Spec.m](https://github.com/andrewschaaf/objc-varints/blob/master/tests/VarintsTests/SignedVarint128Spec.m).

```objc
+ (NSData *)dataWithInt:(int)value;
+ (NSData *)dataWithSInt32:(SInt32)value;
+ (NSData *)dataWithSInt64:(SInt64)value;
```


## License: MIT
