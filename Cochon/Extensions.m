//
//  Extensions.m
//  Cochon
//
//  Created by Emma Houlé on 21/03/2015.
//  Copyright (c) 2015 Lyon 2. All rights reserved.
//

#import "Extensions.h"

@implementation SKEmitterNode (Extensions) 

+(SKEmitterNode *)nodeWithFile:(NSString *)filename;
{
    NSString *baseFileName = [filename stringByDeletingPathExtension];
    NSString *fileExtension = [filename pathExtension];
    if ([fileExtension length]==0) {
        fileExtension = @"sks";
    }
    
    NSString *filePath =[[NSBundle mainBundle] pathForResource:baseFileName ofType:@"sks"];
    SKEmitterNode *node = (id)[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return node;
}


@end
