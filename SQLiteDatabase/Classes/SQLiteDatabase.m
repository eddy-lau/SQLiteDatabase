//
//  SQLiteDatabase.m
//  Browser
//
//  Created by Eddie Hiu-Fung Lau on 24/02/2011.
//  Copyright 2011 TouchUtility.com. All rights reserved.
//

#import "SQLiteDatabase.h"
#import "SQLite.h"
#import "SQLOperation.h"

@implementation SQLiteDatabase

@synthesize path;

- (id) initWithPath:(NSString *)_path {
    
    self = [super init];
	if (self) {
		path = [_path copy];
		opQueue = [[NSOperationQueue alloc] init];
		[opQueue setMaxConcurrentOperationCount:1];
	}
	return self;
}

- (void) dealloc {
	
	[self close];
	[opQueue release];
	[path release];
	[super dealloc];
}

- (BOOL) open {

	if (db == NULL) {
		db = [SQLite open:path];
		return db != NULL;
	} else {
		NSLog (@"Database already open");
		return NO;
	}
	
}

- (void) close {
	if (db != NULL) {	
		[opQueue cancelAllOperations];		
		[opQueue waitUntilAllOperationsAreFinished];		
		sqlite3_close(db);
		db = NULL;
	}
}

- (BOOL) execSQL:(NSString *)sql {
	if ([SQLite exec:db sql:sql] != SQLITE_OK) {
		NSLog (@"Error executing SQL '%@': %s", sql, sqlite3_errmsg(db));
		return NO;
	}
	return YES;
}

- (NSString *) evalSQL:(NSString *)sql {
	return [SQLite eval:db sql:sql];
}

- (BOOL) queryWithSQL:(NSString *)sql withQueryResultBlock:(SQLiteDatabaseQueryResultBlock)block {
	
	if (SQLITE_OK != [SQLite exec:db sql:sql callback:^(int argc, char **argv, char **colNames) {
	
		if (block != NULL) {
			
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:argc];
			
			for (int i = 0; i<argc; i++) {
				
				NSString *value;
				if (argv[i] != NULL) {
					value = [NSString stringWithUTF8String:argv[i]];
				} else {
					value = @"";
				}
				
				NSString *colName = [NSString stringWithUTF8String:colNames[i]];
				
				[dict setValue:value forKey:colName];
			}
			
			block(dict);			
		}
		
		return 0;
	}] ) {
		NSLog (@"Error executing SQL '%@': %s", sql, sqlite3_errmsg(db));
		return NO;
	} else {
		return YES;
	}
	
	
}

- (void) beginTransaction {
	[SQLite beginTransaction:db];
}

- (void) commit {
	[SQLite commit:db];
}

- (NSArray *) arrayOfColumnNamesOfTableNamed:(NSString *)name {
	
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
	
	NSString *sql = [NSString stringWithFormat:@"pragma table_info(%@)",name];
	
	[self queryWithSQL:sql withQueryResultBlock:^(NSDictionary *dict) {
		[array addObject:[[dict allValues] objectAtIndex:0]];
	}];
	
	return array;
}

- (NSSet *) setOfTableNames {
	
	NSMutableSet *set = [NSMutableSet set];
	
	[self queryWithSQL:@"select * from sqlite_master" withQueryResultBlock:^(NSDictionary *dict) {
		
		NSString *type = [dict valueForKey:@"type"];
		NSString *name = [dict valueForKey:@"name"];
		
		if ([type isEqualToString:@"table"]) {
			[set addObject:name];
		}
		
	}];
	
	return set;
	
}

- (SQLOperation *) operationOfSQL:(NSString *)sql {
	
	return [[[SQLOperation alloc] initWithDatabase:self sql:sql] autorelease];
	
}

- (SQLOperation *) operationOfQuerySQL:(NSString *)sql {
	
	return [[[SQLOperation alloc] initWithDatabase:self querySQL:sql] autorelease];
	
}

- (SQLOperation *) operationOfSQLs:(NSArray *)sqls {
	
	return [[[SQLOperation alloc] initWithDatabase:self sqls:sqls] autorelease];
	
}

- (SQLOperation *) operationOfEvalSQL:(NSString *)sql {
	
	return [[[SQLOperation alloc] initWithDatabase:self evalSQL:sql] autorelease];
	
}



- (void) queuedExecSQL:(NSString *)sql {
	
	SQLOperation *op = [self operationOfSQL:sql];
	[opQueue addOperation:op];
	
}

- (void) queuedExecSQLs:(NSArray *)sqls {
	
	SQLOperation *op = [self operationOfSQLs:sqls];
	[opQueue addOperation:op];
	
}


- (void) queuedQueryCompleted:(SQLOperation *)op {

	NSDictionary *myInfo = op.userInfo;
	id target = [myInfo objectForKey:@"target"];
	SEL selector = [(NSValue *)[myInfo objectForKey:@"selector"] pointerValue];
	NSDictionary *userInfo = [myInfo objectForKey:@"userInfo"];
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:op.queryResult,@"queryResult",userInfo,@"userInfo",nil];
	
	[target performSelector:selector withObject:dict];
}

- (void) queuedQuerySQL:(NSString *)sql target:(id)target selector:(SEL)selector userInfo:(NSDictionary *)userInfo {
	
	NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:target,@"target",[NSValue valueWithPointer:selector],@"selector",userInfo,@"userInfo", nil];
	
	SQLOperation *op = [self operationOfQuerySQL:sql];
	[op setTarget:self selector:@selector(queuedQueryCompleted:) userInfo:myInfo];
	[opQueue addOperation:op];
	
	
	
}

- (void) evalCompleted:(SQLOperation *)op {
	
	NSDictionary *myInfo = op.userInfo;
	id target = [myInfo objectForKey:@"target"];
	SEL selector = [(NSValue *)[myInfo objectForKey:@"selector"] pointerValue];
	NSDictionary *userInfo = [myInfo objectForKey:@"userInfo"];
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:op.evalResult,@"evalResult",userInfo,@"userInfo",nil];
	
	[target performSelector:selector withObject:dict];
}

- (void) queuedEvalSQL:(NSString *)sql target:(id)target selector:(SEL)selector userInfo:(NSDictionary *)userInfo {
	
	NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:target,@"target",[NSValue valueWithPointer:selector],@"selector",userInfo,@"userInfo", nil];
	
	SQLOperation *op = [self operationOfEvalSQL:sql];
	[op setTarget:self selector:@selector(evalCompleted:) userInfo:myInfo];
	[opQueue addOperation:op];
	
}

@end
