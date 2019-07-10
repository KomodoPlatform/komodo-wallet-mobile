#include "mm2.h"

#import <Foundation/Foundation.h>
#import <os/log.h>

#include <string.h>  // for strdup

// Defined in "common/for_c.rs".
uint8_t is_loopback_ip (const char* ip);
// Defined in "mm2_lib.rs".
int8_t mm2_main (const char* conf, void (*log_cb) (const char* line));

void log_cb (const char* line) {
   os_log (OS_LOG_DEFAULT, "mm2] %{public}s", line);
    
    // printf("mm2] %s\n", line);

    NSDictionary *myData = @{@"log" : [NSString stringWithFormat:@"mm2] %s\n", line]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logMM2" object:nil userInfo:myData];
}

char* writeable_dir() {
    // Find a writeable directory.
    // cf. https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/AccessingFilesandDirectories/AccessingFilesandDirectories.html#//apple_ref/doc/uid/TP40010672-CH3-SW11
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray<NSURL*>* urls = [sharedFM URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    for (NSURL* url in urls) {
        os_log (OS_LOG_DEFAULT, "start_mm2] supp dir: %{public}s", url.fileSystemRepresentation);
        printf ("start_mm2] supp dir: %s\n", url.fileSystemRepresentation);
    }
    if (urls.count < 1) {
        os_log (OS_LOG_DEFAULT, "start_mm2] Can't get a NSApplicationSupportDirectory");
        printf ("start_mm2] Can't get a NSApplicationSupportDirectory\n");
        return 0;
    }
    const char* wr_dir = urls[0].fileSystemRepresentation;
    return strdup (wr_dir);
}

void start_mm2 (const char* mm2_conf) {
    // `os_log` works with the Console but is missing from XCUITestOutput\d+.
    // `os_log` also shows in BrowserStack RAW Device Logs.
    int l1 = (int) is_loopback_ip ("127.0.0.1");
    int l2 = (int) is_loopback_ip ("8.8.8.8");
    if (l1 != 1 || l2 != 0) {
        os_log (OS_LOG_DEFAULT, "start_mm2] is_loopback_ip check failed!");
        printf ("start_mm2] is_loopback_ip check failed!\n");
        return;
    } else {
        os_log (OS_LOG_DEFAULT, "start_mm2] is_loopback_ip check passed");
        printf ("start_mm2] is_loopback_ip check passed\n");
    }

    int rc = (int) mm2_main (mm2_conf, log_cb);
    printf ("start_mm2] mm2_main rc is %i\n", rc);
    os_log (OS_LOG_DEFAULT, "start_mm2] mm2_main rc is %i", rc);
}
