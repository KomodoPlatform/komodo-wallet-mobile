#include "audio.h"
#include "mm2.h"

// Working with audio from Objective-C in case it gives us advantage:
// "The bridge approach is preferred. As Chris Adamson said in media framework talk you have to Render unto Caesar the things that are Caesar's, and unto God the things that are God's i.e use C for C API and Swift for swifty things" - https://stackoverflow.com/a/44153603/257568

// Our use case is basically https://youtu.be/FlMaxen2eyw?t=272 - scheduling a number of buffers on a player.
// Nodes are source nodes, process nodes and destination nodes.
// There is an implicit mixer node (mainMixerNode).
// Player puts scheduled nodes at the end of the queue by default,
// use AVAudioPlayerNodeBufferInterrupts to overwrite the remaining queue instead.

// TBD: Fanfare60.wav from https://www2.cs.uic.edu/~i101/SoundFiles/ wouldn't load when copied to "maker.mp3",
// should investigate whether the wrong file extension is the reason,
// plus we should now be able to implement checking the files when they are picked by the user.

// TBD: Consider loading streams from www.internet-radio.com

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import <os/log.h>  // os_log

#include <stdatomic.h>  // atomic_fetch_add

void audio_hi (const char* assets_maker) {
  static AVAudioEngine* engine;
  static AVAudioPlayerNode* player;
  static AVAudioFile* file;

  // The number of files in the `player` queue.
  static volatile atomic_int_fast32_t scheduled = 0;

  if (file) {  // Called a second time.
    while (atomic_load (&scheduled) < 33) {
      [player scheduleFile: file atTime: nil completionHandler: ^() {
        atomic_fetch_sub (&scheduled, 1);
        os_log (OS_LOG_DEFAULT, "audio_hi] file finished; queue: %d", atomic_load (&scheduled));}];
      atomic_fetch_add (&scheduled, 1);}
    return;}

  os_log (OS_LOG_DEFAULT, "audio_hi] first run");

  engine = [[AVAudioEngine alloc] init];
  player = [[AVAudioPlayerNode alloc] init];
  [engine attachNode:player];

  const char* documents = documentDirectory();
  if (documents == NULL) {os_log (OS_LOG_DEFAULT, "audio_hi] !documents"); return;}

  NSString* documents_ns = [[NSString alloc] initWithUTF8String: documents];
  NSArray* documents_a = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: documents_ns error: NULL];
  [documents_a enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
    NSString* filename = (NSString*) obj;
    os_log (OS_LOG_DEFAULT, "audio_hi] documents file: %{public}s", filename.UTF8String);}];

  NSString* path = [NSString stringWithFormat:@"%s", assets_maker];

//  NSString* path = [NSString stringWithFormat:@"%s/%s", documents, "maker.mp3"];
//  os_log (OS_LOG_DEFAULT, "audio_hi] path: %{public}@", path);

  NSURL* url = [[NSURL alloc] initFileURLWithPath: path];
  NSError* err;
  file = [[AVAudioFile alloc] initForReading: url error: &err];
  if (err) {os_log (OS_LOG_DEFAULT, "audio_hi] !file: %{public}@", err); return;}

  AVAudioMixerNode* mixer = [engine mainMixerNode];
  os_log (OS_LOG_DEFAULT, "audio_hi] attaching..");
  [engine connect:player to:mixer format:file.processingFormat];

  audio_hi (assets_maker);  // Schedule the `file`

  os_log (OS_LOG_DEFAULT, "audio_hi] category..");
  err = nil;
  [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &err];
  if (err) {os_log (OS_LOG_DEFAULT, "audio_hi] !setCategory: %{public}@", err); return;}

  os_log (OS_LOG_DEFAULT, "audio_hi] starting..");
  err = nil;
  [engine startAndReturnError: &err];
  if (err) {os_log (OS_LOG_DEFAULT, "audio_hi] !start: %{public}@", err); return;}
  [player play];
  [player setVolume: 0.1];
  //[mixer setVolume: 1];
  //[mixer setOutputVolume: 1];
}
