//
//  DLMessageEditor.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/28/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLMessageEditor.h"

@implementation DLMessageEditor

-(id)init {
    self = [super init];
    mentionedUsers = [[NSMutableArray alloc] init];
    attachments = [[NSMutableArray alloc] init];
    return self;
}
-(void)setDelegate:(id<DLMessageEditorDelegate>)inDelegate {
    delegate = inDelegate;
}


-(NSAttributedString *)attributedUserString {
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:userContent];
    NSInteger lastLocation = -1;
    NSInteger index = 0;
    [as addAttribute:NSForegroundColorAttributeName value:[NSColor textColor] range:NSMakeRange(0, [as string].length)];
    while (lastLocation != NSNotFound) {
        lastLocation = [userContent rangeOfString:@"@" options:0 range:NSMakeRange(lastLocation + 1, userContent.length - (lastLocation + 1))].location;
        if (lastLocation != NSNotFound) {
            if (mentionedUsers.count >= index + 1) {
                DLUser *user = [mentionedUsers objectAtIndex:index];
                if ([user username].length <= userContent.length - (lastLocation + 1)) {
                    NSString *username = [userContent substringWithRange:NSMakeRange(lastLocation + 1, [user username].length)];
                    if ([username isEqualToString:[user username]]) {
                        NSRange tagRange = NSMakeRange(lastLocation, [user username].length + 1);
                        [as addAttribute:NSBackgroundColorAttributeName value:[NSColor yellowColor] range:tagRange];
                        [as addAttribute:@kTagAttribute value:[NSNumber numberWithBool:YES] range:tagRange];
                        [as addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:tagRange];
                        [as addAttribute:NSForegroundColorAttributeName value:[NSColor textColor] range:NSMakeRange(tagRange.location + tagRange.length + 1, [as string].length - (tagRange.location + tagRange.length + 1))];
                        index++;
                    }
                }
            }
        }
    }
    return [as autorelease];
}

-(void)setContent:(NSString *)inContent {
    userContent = inContent;
}
-(void)addMentionedUser:(DLUser *)u byReplacingStringInRange:(NSRange)range {
    
    NSString *previousTags = [userContent substringToIndex:range.location];
    NSInteger insertionIndex = 0;
    NSInteger lastLocation = -1;
    while (lastLocation != NSNotFound) {
        lastLocation = [previousTags rangeOfString:@"@" options:0 range:NSMakeRange(lastLocation + 1, previousTags.length - (lastLocation + 1))].location;
        if (lastLocation != NSNotFound) {
            if (mentionedUsers.count >= insertionIndex + 1) {
                DLUser *user = [mentionedUsers objectAtIndex:insertionIndex];
                if ([user username].length <= previousTags.length - (lastLocation + 1)) {
                    NSString *username = [previousTags substringWithRange:NSMakeRange(lastLocation + 1, [user username].length)];
                    if ([username isEqualToString:[user username]]) {
                        insertionIndex++;
                    }
                }
            }
        }
    }
    [mentionedUsers insertObject:u atIndex:insertionIndex];
    NSMutableString *contentTemp = [userContent mutableCopy];
    [contentTemp replaceCharactersInRange:range withString:[NSString stringWithFormat:@"@%@ ", [u username]]];
    userContent = [contentTemp copy];
    [delegate editorContentDidUpdateWithAttributedString:[self attributedUserString]];
}
-(void)removeMentionedUserAtStringIndex:(NSInteger)sIndex {
    NSAttributedString *as = [self attributedUserString];
    NSInteger indexToRemove = 0;
    NSInteger lastLocation = -1;
    while ((lastLocation != NSNotFound) && (lastLocation <= sIndex)) {
        lastLocation = [[as string] rangeOfString:@"@" options:0 range:NSMakeRange(lastLocation + 1, as.length - (lastLocation + 1))].location;
        if (lastLocation != NSNotFound) {
            NSDictionary *attributes = [as attributesAtIndex:lastLocation effectiveRange:nil];
            if ([[attributes objectForKey:@kTagAttribute] boolValue]) {
                indexToRemove++;
            }
        }
    }
    [mentionedUsers removeObjectAtIndex:indexToRemove];
    [delegate editorContentDidUpdateWithAttributedString:[self attributedUserString]];
    
}
-(void)addAttachment:(DLAttachment *)a {
    [attachments addObject:a];
}
-(void)removeAttachment:(DLAttachment *)a {
    [attachments removeObject:a];
}

-(void)setReferencedMessage:(DLMessage *)m {
    [referencedMessage release];
    [m retain];
    referencedMessage = m;
}
-(void)removeReferencedMessage {
    [referencedMessage release];
    referencedMessage = nil;
}

-(DLMessage *)finalizedMessage {
    
    NSMutableString *rawContent = [userContent mutableCopy];
    NSEnumerator *e = [mentionedUsers objectEnumerator];
    DLUser *user;
    NSInteger lastLocation = -1;
    while (user = [e nextObject]) {
        NSRange tagRange = [rawContent rangeOfString:[NSString stringWithFormat:@"@%@", [user username]] options:0 range:NSMakeRange(lastLocation + 1, rawContent.length - (lastLocation + 1))];
        if (tagRange.location != NSNotFound) {
            lastLocation = tagRange.location;
            [rawContent replaceCharactersInRange:tagRange withString:[NSString stringWithFormat:@"<@%@>", [user userID]]];
        }
    }
    DLMessage *m = [[DLMessage alloc] init];
    [m setContent:rawContent];
    [m setAttachments:attachments];
    [m setReferencedMessage:referencedMessage];
    return m;
}

-(void)clear {
    [mentionedUsers removeAllObjects];
    [attachments removeAllObjects];
    [referencedMessage release];
    referencedMessage = nil;
    userContent = @"";
}

@end
