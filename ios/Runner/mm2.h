#ifndef mm2_h
#define mm2_h

#include <stdint.h>

char* writeable_dir (void);

void start_mm2 (const char* mm2_conf);

/// Checks if the MM2 singleton thread is currently running or not.  
/// 0 .. not running.  
/// 1 .. running, but no context yet.  
/// 2 .. context, but no RPC yet.  
/// 3 .. RPC is up.
int8_t mm2_main_status (void);

/// Defined in "common/for_c.rs".
uint8_t is_loopback_ip (const char* ip);
/// Defined in "mm2_lib.rs".
int8_t mm2_main (const char* conf, void (*log_cb) (const char* line));

/// Defined in "mm2_lib.rs".
/// 0 .. MM2 has been stopped successfully.
/// 1 .. not running.
/// 2 .. error stopping an MM2 instance.
int8_t mm2_stop (void);

void lsof (void);

/// Measurement of application metrics: network traffic, CPU usage, etc.
const char* metrics (void);

/// Corresponds to the `applicationDocumentsDirectory` used in Dart.
const char* documentDirectory (void);

#endif /* mm2_h */
