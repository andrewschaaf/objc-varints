## Varint128

This is the same unsigned varint encoding that protobuf uses.

New to this encoding?
Read [Google's introduction](https://developers.google.com/protocol-buffers/docs/encoding#varints)
and/or
[my didactic Varint128Spec.m](https://github.com/andrewschaaf/objc-varints/blob/master/tests/VarintsTests/Varint128Spec.m).

    #import "Varint128.h"
    
    [Varint128 dataWithUnsignedInt:...]
    [Varint128 dataWithUnsignedInteger:...]


## SignedVarint128

This is the same signed varint encoding that protobuf uses.

See
[Google's introduction](https://developers.google.com/protocol-buffers/docs/encoding#types)
and/or
[SignedVarint128Spec.m](https://github.com/andrewschaaf/objc-varints/blob/master/tests/VarintsTests/SignedVarint128Spec.m).

    #import "SignedVarint128.h"
    
    [SignedVarint128 dataWithInt:...]
    [SignedVarint128 dataWithSInt32:...]


## License: MIT
