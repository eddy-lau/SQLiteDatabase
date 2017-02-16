//
//  SQLiteDatabase.h
//  Browser
//
//  Created by Eddie Hiu-Fung Lau on 24/02/2011.
//  Copyright 2011 TouchUtility.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLOperation.h"

struct sqlite3;
typedef struct sqlite3 sqlite3;

typedef void (^SQLiteDatabaseQueryResultBlock)(NSDictionary *row);

@interface SQLiteDatabase : NSObject {	
	sqlite3          *db;
	NSString         *path;
	NSOperationQueue *opQueue;
}

- (id)   initWithPath:(NSString *)path;
- (BOOL) open;
- (void) close;
- (BOOL) execSQL:(NSString *)sql;
- (BOOL) queryWithSQL:(NSString *)sql withQueryResultBlock:(SQLiteDatabaseQueryResultBlock)block;
- (NSString *) evalSQL:(NSString *)sql;
- (NSArray *) arrayOfColumnNamesOfTableNamed:(NSString *)name;
- (NSSet *) setOfTableNames;
- (void) beginTransaction;
- (void) commit;

- (void) queuedExecSQL:(NSString *)sql;
- (void) queuedExecSQLs:(NSArray *)sqls;

/**
 * Perform the query asynchronously
 * 
 * Selector must have this format:
 * 
 * - (void) queryCompleted:(NSDictionary *)result;
 * 
 * where the result is a dictionary having:
 *    @"queryResult" -> NSArray of rows, 
 *    @"userInfo" -> the passed in userInfo
 */
- (void) queuedQuerySQL:(NSString *)sql target:(id)target selector:(SEL)selector userInfo:(NSDictionary *)userInfo;



- (void) queuedEvalSQL:(NSString *)sql target:(id)target selector:(SEL)selector userInfo:(NSDictionary *)userInfo;

@property (nonatomic,readonly) NSString *path;

@end
