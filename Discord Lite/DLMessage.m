//
//  DLMessage.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/2/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLMessage.h"

@implementation DLMessage

-(id)init {
    self = [super init];
    mentionedEveryone = NO;
    return self;
}
-(id)initWithDict:(NSDictionary *)d {
    self = [self init];
    messageID = [[d objectForKey:@"id"] retain];
    content = [[d objectForKey:@"content"] retain];
    channelID = [[d objectForKey:@"channel_id"] retain];
    author = [[DLUser alloc] initWithDict:[d objectForKey:@"author"]];
    NSMutableArray *attachmentData = [[NSMutableArray alloc] init];
    NSEnumerator *e = [[d objectForKey:@"attachments"] objectEnumerator];
    NSDictionary *attachmentDict;
    while (attachmentDict = [e nextObject]) {
        DLAttachment *a = [[DLAttachment alloc] initWithDict:attachmentDict];
        [attachmentData addObject:a];
        [a release];
    }
    attachments = attachmentData;
    NSString *timestampString = [d objectForKey:@"timestamp"];
    if (timestampString && ![timestampString isKindOfClass:[NSNull class]]) {
        if ([timestampString rangeOfString:@"."].location != NSNotFound) {
            timestampString = [timestampString substringToIndex:[timestampString rangeOfString:@"."].location];
        } else {
            timestampString = [timestampString substringToIndex:[timestampString rangeOfString:@"+"].location];
        }
        timestampString = [timestampString stringByAppendingString:@"+0000"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        timestamp = [formatter dateFromString:timestampString];
        [formatter release];
    }
    NSMutableArray *mentionedUsersTemp = [[NSMutableArray alloc] init];
    e = [[d objectForKey:@"mentions"] objectEnumerator];
    NSDictionary *mentionedUserData;
    while (mentionedUserData = [e nextObject]) {
        DLUser *u = [[DLUser alloc] initWithDict:mentionedUserData];
        [mentionedUsersTemp addObject:u];
        [u release];
    }
    mentionedUsers = mentionedUsersTemp;
    mentionedEveryone = [[d objectForKey:@"mention_everyone"] boolValue];
    if ([d objectForKey:@"referenced_message"] && ![[d objectForKey:@"referenced_message"] isKindOfClass:[NSNull class]]) {
        referencedMessage = [[DLMessage alloc] initWithDict:[d objectForKey:@"referenced_message"]];
    }
    return self;
}


-(NSDictionary *)dictRepresentation {
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:content, [NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"content", @"tts", nil]] autorelease];
    if (referencedMessage) {
        NSMutableDictionary *refMsg = [[[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[referencedMessage channelID], [referencedMessage messageID], nil] forKeys:[NSArray arrayWithObjects:@"channel_id", @"message_id", nil]] autorelease];
        if ([referencedMessage serverID]) {
            [refMsg setObject:[referencedMessage serverID] forKey:@"guild_id"];
        }
        
        [dict setObject:refMsg forKey:@"message_reference"];
    }
    return dict;
}

-(NSString *)messageID {
    return messageID;
}
-(NSString *)content {
    return content;
}
-(NSString *)channelID {
    return channelID;
}
-(NSString *)serverID {
    return serverID;
}
-(DLUser *)author {
    return author;
}
-(NSArray *)attachments {
    return attachments;
}
-(NSDate *)timestamp {
    return timestamp;
}
-(NSArray *)mentionedUsers {
    return mentionedUsers;
}
-(DLMessage *)referencedMessage {
    return referencedMessage;
}
-(BOOL)mentionedEveryone {
    return mentionedEveryone;
}

-(void)setContent:(NSString *)inContent {
    [content release];
    [inContent retain];
    content = inContent;
}

-(void)setAttachments:(NSArray *)inAttachments {
    [attachments release];
    [inAttachments retain];
    attachments = inAttachments;
}

-(void)setReferencedMessage:(DLMessage *)m {
    [referencedMessage release];
    [m retain];
    referencedMessage = m;
}
-(void)setServerID:(NSString *)inServerID {
    [serverID release];
    [inServerID retain];
    serverID = inServerID;
}

-(void)dealloc {
    [messageID release];
    [content release];
    [channelID release];
    [serverID release];
    [author release];
    [attachments release];
    [timestamp release];
    [mentionedUsers release];
    [referencedMessage release];
    [super dealloc];
}

@end
