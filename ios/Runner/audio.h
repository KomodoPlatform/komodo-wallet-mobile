#ifndef audio_h
#define audio_h

#import <Foundation/Foundation.h>

void audio_init (const char* assets_maker);

/// Start playing a file in a background loop.
///
/// `rpath` is relative to documents and/or assets.
/// Pass an empty `rpath` to stop the background audio loop.
///
/// Returns: `0` if it went all right, negative value if there was an error.
int audio_bg (NSString* rpath);

/// Play a file once in foreground.
/// When the file is finished, the background file (`audio_bg`) will be again rescheduled in a loop.
///
/// `rpath` is relative to documents and/or assets.
///
/// Returns: `0` if it went all right, negative value if there was an error.
int audio_fg (NSString* rpath);

int audio_volume (NSNumber* volume);

void audio_resume(void);

#endif /* audio_h */
