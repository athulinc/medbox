//
//  Reminder.m
//  MedBox
//
//  Created by Athul Sai on 21/07/15.
//  Copyright (c) 2015 Incture Technologies. All rights reserved.
//

#import "Reminder.h"

@implementation Reminder

-(id)initWithData:(NSDictionary *)data {
    
    self = [super init];
    
    if(self){
        self.remId = data[MED_ID];
        self.name = data[MED_NAME];
        self.form = data[MED_FORM];
        self.strength = data[MED_STRENGTH];
        self.notes = data[MED_NOTES];
        self.start = data[MED_TIME_DATE];
        self.repeat = [data[MED_REPEAT] boolValue];
        self.imageName = data[MED_IMAGE];
    }
    
    return self;

}

-(id)init {
    
    self = [self initWithData:nil];
    
    return self;
}
@end
