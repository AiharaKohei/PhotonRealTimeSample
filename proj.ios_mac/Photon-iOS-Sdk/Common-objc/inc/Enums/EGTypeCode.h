#pragma once

#define EGTypeCode_BYTE               ('b') ///<nByte
#define EGTypeCode_SHORT              ('k') ///<short
#define EGTypeCode_INTEGER            ('i') ///<int
#define EGTypeCode_LONG               ('l') ///<int64
#define EGTypeCode_FLOAT              ('f') ///<float
#define EGTypeCode_DOUBLE             ('d') ///<double
#define EGTypeCode_BOOLEAN            ('o') ///<bool
#define EGTypeCode_STRING             ('s') ///<@if CPP JString@endif @if OBJC NSString@endif
#define EGTypeCode_HASHTABLE          ('h') ///<@if CPP Hashtable@endif @if OBJC NSDictionary@endif
#define EGTypeCode_DICTIONARY         ('D') ///<@if CPP Dictionary@endif @if OBJC EGDictionary@endif
#define EGTypeCode_OBJECT             ('z') ///<@if CPP Object@endif @if OBJC NSObject@endif, only allowed for arrays!
#define EGTypeCode_ARRAY              ('y') ///<internal only
#define EGTypeCode_BYTEARRAY          ('x') ///<internal only
#define EGTypeCode_PHOTON_COMMAND     ('p') ///<internal only@internal used for photon commands
#define EGTypeCode_EG_NULL            ('*') ///<internal only@internal for adding NULL as a value to a HashTable
#define EGTypeCode_CUSTOM             ('c') ///<internal only@internal for custom data, (de-)serialized by callbacks, implemented by the application
#define EGTypeCode_UNKNOWN            (0) ///<internal only@internal used instead of OBJECT for values inside an Dictionary