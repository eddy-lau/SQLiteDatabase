//
//  SQLite.m
//  TouchEbook
//
//  Created by Eddie Lau on 02/12/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SQLite.h"


@implementation SQLite

static int 
callback(void *userData, int argc, char **argv, char **azColName) {

    if (userData != NULL) {
        SQLiteCallbackBlock callbackBlock = userData;
        return callbackBlock(argc, argv, azColName);
    } else {
        return 0;
    }
    
}

+ (sqlite3 *) open:(NSString *)path {
	
	sqlite3 *db = NULL;
	if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
		db = NULL;
	}

	return db;
}

+ (int) exec:(sqlite3 *)db sql:(NSString *)sql callback:(SQLiteCallbackBlock)callbackBlock errorMessage:(NSMutableString *)errorMessage {
    
    const char *sqlUTF8String = [sql UTF8String];
        
    char *errMsg = NULL;
    int result = sqlite3_exec(db, sqlUTF8String, callback, callbackBlock, &errMsg);
    
    if (errMsg != NULL) {
        if (errorMessage != nil) {
            [errorMessage setString:@""];
            [errorMessage appendFormat:@"%s", errMsg];
        } else {
            fprintf(stderr, "SQL Error: %s", errMsg);
        }
        
        sqlite3_free(errMsg);
    }
    
    return result;
}

+ (int) exec:(sqlite3 *)db sql:(NSString *)sql callback:(SQLiteCallbackBlock)callback {
    return [SQLite exec:db sql:sql callback:callback errorMessage:nil];
}

+ (int) exec:(sqlite3 *)db sql:(NSString *)sql {
    return [SQLite exec:db sql:sql callback:NULL];
}

+ (void) beginTransaction:(sqlite3 *)db {
    [SQLite exec:db sql:@"begin transaction"];
}

+ (void) commit:(sqlite3 *)db {
    [SQLite exec:db sql:@"commit"];
}

+ (NSString *) eval:(sqlite3 *)db sql:(NSString *)sql {
    
    NSMutableString *result = [NSMutableString stringWithString:@""];

    [SQLite exec:db sql:sql callback:^(int argc, char **argv, char **colNames) {
        
        [result appendString:[NSString stringWithUTF8String:argv[0]]];
        return 0;
        
    }];
    
    return result;
    
}

+ (int) evalInt:(sqlite3 *)db sql:(NSString *)sql {
    
    NSString *result = [SQLite eval:db sql:sql];
    return [result intValue];
    
}


@end
