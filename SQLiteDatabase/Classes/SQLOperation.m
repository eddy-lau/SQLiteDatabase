//
//  SQLOperation.m
//  Browser
//
//  Created by Eddie Hiu-Fung Lau on 11/03/2011.
//  Copyright 2011 TouchUtility.com. All rights reserved.
//

#import "SQLOperation.h"
#import "SQLiteDatabase.h"

@interface SQLOperationRunner : NSObject {
}
@end

@implementation SQLOperationRunner

- (void) run:(SQLOperation *)op {
    
	if (op.queryResult == nil) {
		if (op.evalResult != nil) {
			NSString *sql = [op.sqls objectAtIndex:0];
			[op.evalResult appendString:[op.db evalSQL:sql]];
		} else {
			for (NSString *sql in op.sqls) {
				[op.db execSQL:sql];
			}
		}
	} else {
		
		NSString *sql = [op.sqls objectAtIndex:0];
		[op.db queryWithSQL:sql withQueryResultBlock:^(NSDictionary *row) {
			[op.queryResult addObject:row];
		}];
	}
	[op.target performSelectorOnMainThread:op.selector withObject:self waitUntilDone:YES];
}

@end

@implementation SQLOperation

@synthesize queryResult,evalResult,userInfo,sqls,db,target,selector;

- (id) initWithDatabase:(SQLiteDatabase *)_db sql:(NSString *)sql {
	
    self = [super initWithTarget:self selector:@selector(run) object:nil];
	if (self) {
		
		db = [_db retain];
		sqls = [[NSArray arrayWithObject:sql] retain];
		
	}
	return self;
	
}

- (id) initWithDatabase:(SQLiteDatabase *)_db evalSQL:(NSString *)sql {
	
    self = [super initWithTarget:self selector:@selector(run) object:nil];
	if (self) {
		
		db = [_db retain];
		sqls = [[NSArray arrayWithObject:sql] retain];
		evalResult = [[NSMutableString alloc] initWithString:@""];
	}
	return self;
	
}


- (id) initWithDatabase:(SQLiteDatabase *)_db querySQL:(NSString *)sql {
	
    self = [self initWithDatabase:_db sql:sql];
	if (self) {
		queryResult = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}

- (id) initWithDatabase:(SQLiteDatabase *)_db sqls:(NSArray *)_sqls {
	
    self = [super initWithTarget:self selector:@selector(run) object:nil];
	if (self) {
		
		db = [_db retain];
		sqls = [[NSArray arrayWithArray:_sqls] retain];
		
	}
	return self;
	
}


- (void) dealloc {
	[evalResult release];
	[queryResult release];
	[target release];
	[userInfo release];
	[db release];
	[sqls release];
	[super dealloc];
}

- (void) run {
	
	if (queryResult == nil) {
		if (evalResult != nil) {
			NSString *sql = [sqls objectAtIndex:0];
			[evalResult appendString:[db evalSQL:sql]];
		} else {
			for (NSString *sql in sqls) {
				[db execSQL:sql];
			}
		}
	} else {
		
		NSString *sql = [sqls objectAtIndex:0];
		[db queryWithSQL:sql withQueryResultBlock:^(NSDictionary *row) {
			[queryResult addObject:row];
		}];
	}
	[target performSelectorOnMainThread:selector withObject:self waitUntilDone:YES];
    
	[evalResult release];
    evalResult = nil;
    
	[queryResult release];
    queryResult = nil;
    
	[target release];
    target = nil;
    
	[userInfo release];
    userInfo = nil;
    
	[db release];
    db = nil;
    
	[sqls release];
    sqls = nil;
    
    
}

- (void) setTarget:(id)_target selector:(SEL)_selector userInfo:(NSDictionary *)_userInfo{
	
	if (target != _target) {
		[target release];
		target = [_target retain];
	}
	
	if (userInfo != _userInfo) {
		[userInfo release];
		userInfo = [_userInfo retain];
	}
	
	selector = _selector;	
}

@end
