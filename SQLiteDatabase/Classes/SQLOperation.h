//
//  SQLOperation.h
//  Browser
//
//  Created by Eddie Hiu-Fung Lau on 11/03/2011.
//  Copyright 2011 TouchUtility.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQLiteDatabase;
@interface SQLOperation : NSInvocationOperation {

	SQLiteDatabase *db;
	NSArray        *sqls;
	id              target;
	SEL             selector;
	NSMutableArray *queryResult;
	NSDictionary   *userInfo;
	NSMutableString *evalResult;
	
}

- (id) initWithDatabase:(SQLiteDatabase *)db sql:(NSString *)sql;
- (id) initWithDatabase:(SQLiteDatabase *)db evalSQL:(NSString *)sql;
- (id) initWithDatabase:(SQLiteDatabase *)db querySQL:(NSString *)sql;
- (id) initWithDatabase:(SQLiteDatabase *)db sqls:(NSArray *)sqls;
- (void) setTarget:(id)target selector:(SEL)selector userInfo:(NSDictionary *)userInfo;

@property (nonatomic,readonly) NSMutableArray *queryResult;
@property (nonatomic,readonly) NSDictionary   *userInfo;
@property (nonatomic,readonly) NSMutableString *evalResult;
@property (nonatomic,readonly) NSArray      *sqls;
@property (nonatomic,readonly) SQLiteDatabase *db;
@property (nonatomic,readonly) id target;
@property (nonatomic,readonly) SEL selector;

@end
