//
//  LookinObject.m
//  Lookin
//
//  Created by Li Kai on 2019/4/20.
//  https://lookin.work
//

#ifdef CAN_COMPILE_LOOKIN_SERVER

#import "LookinObject.h"
#import "LookinIvarTrace.h"

#import "NSArray+Lookin.h"
#import "NSString+Lookin.h"

#import "NSObject+LookinServer.h"

@implementation LookinObject

#if TARGET_OS_IPHONE
+ (instancetype)instanceWithObject:(NSObject *)object {
    LookinObject *lookinObj = [LookinObject new];
    lookinObj.oid = [object lks_registerOid];
    
    lookinObj.memoryAddress = [NSString stringWithFormat:@"%p", object];
    lookinObj.classChainList = [object lks_classChainListWithSwiftPrefix:YES];
    
    lookinObj.specialTrace = object.lks_specialTrace;
    lookinObj.ivarTraces = object.lks_ivarTraces;
    
    return lookinObj;
}
#endif

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    LookinObject *newObject = [[LookinObject allocWithZone:zone] init];
    newObject.oid = self.oid;
    newObject.memoryAddress = self.memoryAddress;
    newObject.classChainList = self.classChainList;
    newObject.specialTrace = self.specialTrace;
    newObject.ivarTraces = [self.ivarTraces lookin_map:^id(NSUInteger idx, LookinIvarTrace *value) {
        return value.copy;
    }];
    return newObject;
}

#pragma mark - <NSSecureCoding>

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.oid) forKey:@"oid"];
    [aCoder encodeObject:self.memoryAddress forKey:@"memoryAddress"];
    [aCoder encodeObject:self.classChainList forKey:@"classChainList"];
    [aCoder encodeObject:self.specialTrace forKey:@"specialTrace"];
    [aCoder encodeObject:self.ivarTraces forKey:@"ivarTraces"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.oid = [(NSNumber *)[aDecoder decodeObjectForKey:@"oid"] unsignedLongValue];
        self.memoryAddress = [aDecoder decodeObjectForKey:@"memoryAddress"];
        self.classChainList = [aDecoder decodeObjectForKey:@"classChainList"];
        self.specialTrace = [aDecoder decodeObjectForKey:@"specialTrace"];
        self.ivarTraces = [aDecoder decodeObjectForKey:@"ivarTraces"];
    }
    return self;
}

- (void)setClassChainList:(NSArray<NSString *> *)classChainList {
    _classChainList = classChainList;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSString *)completedSelfClassName {
    return self.classChainList.firstObject;
}

- (NSString *)shortSelfClassName {
    return [[self completedSelfClassName] lookin_shortClassNameString];
}

@end

#endif
