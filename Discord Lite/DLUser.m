//
//  DLUser.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/2/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLUser.h"

@implementation DLUser

const NSTimeInterval TYPING_INTERVAL = 10.0;

-(id)init {
    self = [super init];
    typing = NO;
    avatarImageData = [[NSData dataWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"discord_placeholder.png"]] retain];
    outstandingRequests = [[AsyncHTTPRequestTracker alloc] init];
    return self;
}
-(id)initWithDict:(NSDictionary *)d {
    self = [self init];
    userID = [[d objectForKey:@"id"] retain];
    username = [[d objectForKey:@"username"] retain];
    avatarID = [[d objectForKey:@"avatar"] retain];
    discriminator = [[d objectForKey:@"discriminator"] retain];
    return self;
}

-(void)setDelegate:(id<DLUserDelegate>)inDelegate {
    delegate = inDelegate;
}

-(void)setTypingDelegate:(id<DLUserTypingDelegate>)inTypingDelegate {
    typingDelegate = inTypingDelegate;
}

-(void)loadAvatarData {
    if (avatarID && ![avatarID isKindOfClass:[NSNull class]]) {
        AsyncHTTPGetRequest* req = [[AsyncHTTPGetRequest alloc] init];
        [req setDelegate:self];
        [req setUrl:[NSURL URLWithString:[@AvatarCDNRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.png?size=128", userID, avatarID]]]];
        [req setCached:YES];
        [req start];
        [outstandingRequests addRequest:req];
        [req release];
    }
}
-(NSString *)userID {
    return userID;
}
-(NSString *)username {
    return username;
}
-(NSString *)avatarID {
    return avatarID;
}
-(NSData *)avatarImageData {
    return avatarImageData;
}

-(NSString *)discriminator {
    return discriminator;
}

-(BOOL)isEqual:(DLUser *)object {
    return [userID isEqualToString:[object userID]];
}

-(void)updateTypingTimeout {
    typing = NO;
    [typingDelegate userDidStopTyping:self];
    if (typingTimer) {
        [typingTimer invalidate];
        typingTimer = nil;
    }
}

-(void)setTyping:(BOOL)isTyping {
    typing = isTyping;
    if (typingTimer) {
        [typingTimer invalidate];
        typingTimer = nil;
    }
    if (isTyping) {
        typingTimer = [NSTimer scheduledTimerWithTimeInterval:TYPING_INTERVAL target:self selector:@selector(updateTypingTimeout) userInfo:nil repeats:NO];
    }
}

-(void)dealloc {
    [userID release];
    [username release];
    [avatarID release];
    [avatarImageData release];
    [discriminator release];
    [typingTimer release];
    [outstandingRequests release];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)requestDidFinishLoading:(AsyncHTTPRequest *)request {
    
    if ([request result] == HTTPResultOK) {
        [avatarImageData release];
        avatarImageData = [[request responseData] retain];
        [delegate user:self avatarDidUpdateWithData:avatarImageData];
    }
    [outstandingRequests removeRequest:request];
}

@end
