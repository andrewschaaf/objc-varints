## Base 128 Varints

This is the same varint encoding that protobuf uses.

New to this encoding?
Read [Google's introduction](https://developers.google.com/protocol-buffers/docs/encoding#varints)
and/or
[my didactic Varint128Spec.m](https://github.com/andrewschaaf/objc-varints/blob/master/tests/VarintsTests/Varint128Spec.m).


    #import "Varint128.h"
    
    [Varint128 dataWithUnsignedInt:...]
    [Varint128 dataWithUnsignedInteger:...]


## License: MIT
