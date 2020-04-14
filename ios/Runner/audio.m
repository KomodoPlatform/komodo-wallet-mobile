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

static AVAudioEngine* dex_engine;
static AVAudioPlayerNode* dex_player;

// Currently scheduled file.
// We keep a pointer to it in order to keep rescheduling it into the end of the `player` queue.
static AVAudioFile* dex_file;

// The number of files in the `player` queue.
static volatile atomic_int_fast32_t dex_scheduled = 0;

void audio_reschedule() {
  while (atomic_load (&dex_scheduled) < 2) {
    [dex_player scheduleFile: dex_file atTime: nil completionHandler: ^() {
      atomic_fetch_sub (&dex_scheduled, 1);
      int queue = atomic_load (&dex_scheduled);
      os_log (OS_LOG_DEFAULT, "audio_reschedule] File finished; queue: %d", queue);
      if (queue < 2) audio_reschedule();}];
    atomic_fetch_add (&dex_scheduled, 1);}}

void audio_init (const char* assets_maker) {
  os_log (OS_LOG_DEFAULT, "audio_init] Entered..");

  dex_engine = [[AVAudioEngine alloc] init];
  dex_player = [[AVAudioPlayerNode alloc] init];
  [dex_engine attachNode:dex_player];

  const char* documents = documentDirectory();
  if (documents == NULL) {os_log (OS_LOG_DEFAULT, "audio_init] !documents"); return;}

  NSString* documents_ns = [[NSString alloc] initWithUTF8String: documents];
  NSArray* documents_a = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: documents_ns error: NULL];
  [documents_a enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
    NSString* filename = (NSString*) obj;
    os_log (OS_LOG_DEFAULT, "audio_init] Documents file: %{public}s", filename.UTF8String);}];

  NSString* path = [NSString stringWithFormat:@"%s", assets_maker];

//  NSString* path = [NSString stringWithFormat:@"%s/%s", documents, "maker.mp3"];
//  os_log (OS_LOG_DEFAULT, "audio_init] path: %{public}@", path);

  NSURL* url = [[NSURL alloc] initFileURLWithPath: path];
  NSError* err;
  dex_file = [[AVAudioFile alloc] initForReading: url error: &err];
  if (err) {os_log (OS_LOG_DEFAULT, "audio_init] !file: %{public}@", err); return;}

  AVAudioMixerNode* mixer = [dex_engine mainMixerNode];
  os_log (OS_LOG_DEFAULT, "audio_init] Attaching..");
  [dex_engine connect:dex_player to:mixer format:dex_file.processingFormat];

  audio_hi (assets_maker);  // Schedule the `file`

  os_log (OS_LOG_DEFAULT, "audio_init] Category..");
  err = nil;
  [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &err];
  if (err) {os_log (OS_LOG_DEFAULT, "audio_init] !setCategory: %{public}@", err); return;}

  os_log (OS_LOG_DEFAULT, "audio_init] Starting..");
  err = nil;
  [dex_engine startAndReturnError: &err];
  if (err) {os_log (OS_LOG_DEFAULT, "audio_init] !start: %{public}@", err); return;}
  [dex_player play];
  [dex_player setVolume: 0.1];
  os_log (OS_LOG_DEFAULT, "audio_init] Done");}
