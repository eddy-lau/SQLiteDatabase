//
//  SQLite.h
//  TouchEbook
//
//  Created by Eddie Lau on 02/12/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>

typedef int (^SQLiteCallbackBlock)(int argc, char **argv, char **azColName);

@interface SQLite : NSObject {

}

+ (sqlite3 *) open:(NSString *)path; 
+ (int) exec:(sqlite3 *)db sql:(NSString *)sql callback:(SQLiteCallbackBlock)callback errorMessage:(NSMutableString *)errorMessage;
+ (int) exec:(sqlite3 *)db sql:(NSString *)sql callback:(SQLiteCallbackBlock)callback;
+ (int) exec:(sqlite3 *)db sql:(NSString *)sql;
+ (void) beginTransaction:(sqlite3 *)db;
+ (void) commit:(sqlite3 *)db;
+ (NSString *) eval:(sqlite3 *)db sql:(NSString *)sql;
+ (int) evalInt:(sqlite3 *)db sql:(NSString *)sql;


@end
