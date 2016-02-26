//
//  QueueObj.m
//  MySee
//
//  Created by tommy on 16/1/14.
//  Copyright (c) 2016年 ml . All rights reserved.
//

#import "QueueObj.h"
#include<list>
using namespace std;
@implementation QueueObj{
    list<NSObject*> mylist;
}

- (void) addObject:(id)obj{
    mylist.push_back(obj);
}
- (id) lastObject{
    list<NSObject*>::iterator it=mylist.begin();
    /*
    int i=0;
    for (list<NSObject*>::iterator it = mylist.begin(); it != mylist.end(); ++it)
    {
        int strTemp=(int)(*it);
        NSLog(@"mylist i=%d",strTemp);
        i++;
    }
    if(mylist.size()>0)
        NSLog(@"mylist begin=%d",(int)(*it));*/
    
    return *it;
}
- (void) removeLastObject{
    mylist.pop_front();
}
-(int) count{
    return mylist.size();
}

-(NSString*)getlist{
    int i=0;
    NSString* str=@"";
    for (list<NSObject*>::iterator it = mylist.begin(); it != mylist.end(); ++it)
    {
       /* int strTemp=(int)(*it);
         if (i==0) {
            str=[NSString stringWithFormat:@"mylist %d=%d,",i,strTemp];
        }
        else{
            str=[NSString stringWithFormat:@"%@, %d=%d,",str,i,strTemp];
        }*/
        
       // NSLog(@"mylist i=%d",strTemp);
        i++;
    }
    return str;
}

@end
