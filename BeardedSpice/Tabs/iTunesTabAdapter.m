//
//  iTunesTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "iTunesTabAdapter.h"
#import "runningSBApplication.h"
#import "BSMediaStrategy.h"
#import "BSTrack.h"
#import "NSString+Utils.h"

#define ERROR_TRACE                         NSLog(@"Error trace - %s[%p]: %@", __FILE__, self, NSStringFromSelector(_cmd));

#define APPID_ITUNES            @"com.apple.iTunes"
#define APPNAME_ITUNES          @"iTunes"

@implementation iTunesTabAdapter

+ (id)tabAdapterWithApplication:(runningSBApplication *)application {

    iTunesTabAdapter *tab = [super tabAdapterWithApplication:application];
    if (tab) {
        tab->iTunesNeedDisplayNotification = YES;
    }

    return tab;
}

+ (NSString *)displayName{

    return APPNAME_ITUNES;
}

+ (NSString *)bundleId{

    return APPID_ITUNES;
}

- (NSString *)title{

    @autoreleasepool {

        iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
        iTunesTrack *currentTrack = [iTunes currentTrack];

        NSString *title;
        if (currentTrack) {

            if (![NSString isNullOrEmpty:currentTrack.name])
                title = currentTrack.name;

            if (![NSString isNullOrEmpty:currentTrack.artist]) {

                if (title) title = [title stringByAppendingFormat:@" - %@", currentTrack.artist];
                else
                    title = currentTrack.artist;
            }
        }

        if ([NSString isNullOrEmpty:title]) {
            title = NSLocalizedString(@"No Track", @"iTunesTabAdapter");
        }

        return [NSString stringWithFormat:@"%@ (%@)", title, APPNAME_ITUNES];
    }
}

- (NSString *)URL{

    return @"iTunes";
}

// We have only one window.
- (NSString *)key{

    return @"A:ITUNES";
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{

    if (otherTab == nil || ![otherTab isKindOfClass:[iTunesTabAdapter class]]) return NO;

    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

- (void)toggle{

    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {
        [iTunes playpause];
    }
    iTunesNeedDisplayNotification = YES;
}
- (void)pause{

    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {
        [iTunes pause];
    }
    iTunesNeedDisplayNotification = YES;
}
- (void)next{

    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {
        [iTunes nextTrack];
    }
    iTunesNeedDisplayNotification = NO;
}
- (void)previous{

    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {
        [iTunes previousTrack];
    }
    iTunesNeedDisplayNotification = NO;
}

- (void)favorite{

    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {
        iTunesTrack *track = [iTunes currentTrack];
        @try {
            if ([track loved])
                track.loved = NO;
            else
                track.loved = YES;
        }
        @catch (NSException *exception) {

            NSLog(@"Error when calling [iTunes loved]: %@", exception);
            ERROR_TRACE;
        }
    }

}

- (BSTrack *)trackInfo{

    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {

        iTunesTrack *iTrack = [iTunes currentTrack];
        if (iTrack) {
            BSTrack *track = [BSTrack new];

            track.track = iTrack.name;
            track.album = iTrack.album;
            track.artist = iTrack.artist;

            NSArray *artworks = [iTrack artworks];
            iTunesArtwork *art = [artworks firstObject];
            track.image = art.data;

            @try {
                track.favorited = @(iTrack.loved);
            }
            @catch (NSException *exception) {
                NSLog(@"Error when calling [iTunes loved]: %@", exception);
                ERROR_TRACE;
            }

            return track;
        }
    }

    return nil;
}

- (BOOL)isPlaying{

    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {

        switch (iTunes.playerState) {

            case iTunesEPlSPaused:
            case iTunesEPlSStopped:

                return NO;

            default:

                return YES;
        }
    }

    return NO;
}

- (BOOL)showNotifications{
    return iTunesNeedDisplayNotification;
}

@end
