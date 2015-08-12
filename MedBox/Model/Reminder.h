//
//  Reminder.h
//  MedBox
//
//  Created by Athul Sai on 21/07/15.
//  Copyright (c) 2015 Incture Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reminder : NSObject

@property (nonatomic, strong) NSString *remId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *form;
@property (nonatomic, strong) NSString *strength;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic) BOOL repeat;

-(id)initWithData:(NSDictionary *)data;

@end
