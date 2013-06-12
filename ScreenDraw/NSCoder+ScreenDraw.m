//
//  NSCoder+ScreenDraw.m
//  ScreenDraw
//
//  Created by Scott Delly on 6/11/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "NSCoder+ScreenDraw.h"

@implementation NSCoder (ScreenDraw)

//-(void)encodeCGPath:(CGPathRef)value forKey:(NSString *)key
//{
//	char *buf = CGPathToCString(value, 256, 256);
//	if ( buf == NULL )
//		return;
//	//MRLogD(@"Encode CGPath Buffer[%d]: '%s'", strlen(buf) + 1, buf);
//	NSAssert(buf[strlen(buf)] == '\0', @"");
//	[self encodeObject:[NSString stringWithCString:buf encoding:NSASCIIStringEncoding] forKey:key];
//	free(buf);
//}
//
//
//-(CGPathRef)decodeCGPathForKey:(NSString *)key
//{
//	NSString *buf = [self decodeObjectForKey:key];
//	//MRLogD(@"Decode CGPath Buffer[%d]: '%s'", len, buf);
//	PathParser *pp = [alloc (PathParser)init];
//	NSError *err = nil;
//	CGPathRef p = [pp parseString:buf trafo:NULL error:&err];
//	//	MRLogD(@"Error: %@", err);
//	NSAssert(p != NULL, @"");
//	NSAssert(err == nil, @"");
//	[pp release];
//	return p;
//}

@end
