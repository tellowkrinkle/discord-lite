//
//  DLUser.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/2/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncHTTPGetRequest.h"

#define AvatarCDNRoot "https://cdn.discordapp.com/avatars"

@class DLUser;

@protocol DLUserDelegate <NSObject>
@optional
-(void)user:(DLUser *)u avatarDidUpdateWithData:(NSData *)data;
@end

@protocol DLUserTypingDelegate <NSObject>
@optional
-(void)userDidStopTyping:(DLUser *)u;
@end

@interface DLUser : NSObject <AsyncHTTPRequestDelegate> {
    NSString *userID;
    NSString *username;
    NSString *avatarID;
    NSData *avatarImageData;
    NSString *discriminator;
    NSTimer *typingTimer;
    BOOL typing;
    AsyncHTTPRequestTracker *outstandingRequests;
    id<DLUserDelegate> delegate;
    id<DLUserTypingDelegate> typingDelegate;
}

-(id)init;
-(id)initWithDict:(NSDictionary *)d;

-(NSString *)userID;
-(NSString *)username;
-(NSString *)avatarID;
-(NSData *)avatarImageData;
-(NSString *)discriminator;

-(BOOL)isEqual:(DLUser *)object;

-(void)setTyping:(BOOL)isTyping;

-(void)loadAvatarData;

-(void)setDelegate:(id<DLUserDelegate>)inDelegate;
-(void)setTypingDelegate:(id<DLUserTypingDelegate>)inTypingDelegate;

@end
