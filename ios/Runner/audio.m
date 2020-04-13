#include "audio.h"

// Working with audio from Objective-C in case it gives us advantage:
// "The bridge approach is preferred. As Chris Adamson said in media framework talk you have to Render unto Caesar the things that are Caesar's, and unto God the things that are God's i.e use C for C API and Swift for swifty things" - https://stackoverflow.com/a/44153603/257568

#import <Foundation/Foundation.h>

#import <os/log.h>  // os_log

void audio_hi (void) {
  os_log (OS_LOG_DEFAULT, "os-log-audio-hi");
}
