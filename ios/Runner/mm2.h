#ifndef mm2_h
#define mm2_h

#include <stdint.h>

char* writeable_dir();

void start_mm2 (const char* mm2_conf);

/// Checks if the MM2 singleton thread is currently running or not.  
/// 0 .. not running.  
/// 1 .. running, but no context yet.  
/// 2 .. context, but no RPC yet.  
/// 3 .. RPC is up.
int8_t mm2_main_status (void);

#endif /* mm2_h */
