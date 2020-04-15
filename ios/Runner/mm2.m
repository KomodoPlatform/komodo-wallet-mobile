#include "mm2.h"

#import <sys/types.h>
#import <fcntl.h>
#import <errno.h>
#import <sys/param.h>
#import <stdio.h>
#import <os/log.h>  // os_log
#import <Foundation/Foundation.h>  // NSException

#include <net/if.h>
#include <ifaddrs.h>

#include <mach/mach.h>  // task_info, mach_task_self

#include <string.h>  // strcpy
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

// Note that the network interface traffic is not the same as the application traffic.
// Might still be useful with picking some trends in how the application is using the network,
// and for troubleshooting.
void network (NSMutableDictionary* ret) {
  // https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/getifaddrs.3.html
  struct ifaddrs *addrs = NULL;
  int rc = getifaddrs (&addrs);
  if (rc != 0) return;

  for (struct ifaddrs *addr = addrs; addr != NULL; addr = addr->ifa_next) {
    if (addr->ifa_addr->sa_family != AF_LINK) continue;

    // Known aliases: “en0” is wi-fi, “pdp_ip0” is mobile.
    // AG: “lo0” on my iPhone 5s seems to be measuring the Wi-Fi traffic.
    const char* name = addr->ifa_name;

    struct if_data *stats = (struct if_data*) addr->ifa_data;
    if (name == NULL || stats == NULL) continue;
    if (stats->ifi_ipackets == 0 || stats->ifi_opackets == 0) continue;

    int8_t log = 0;
    if (log == 1) os_log (OS_LOG_DEFAULT,
      "network] if %{public}s ipackets %lld ibytes %lld opackets %lld obytes %lld",
      name,
      (int64_t) stats->ifi_ipackets,
      (int64_t) stats->ifi_ibytes,
      (int64_t) stats->ifi_opackets,
      (int64_t) stats->ifi_obytes);

    NSDictionary* readings = @{
      @"ipackets": @((int64_t) stats->ifi_ipackets),
      @"ibytes": @((int64_t) stats->ifi_ibytes),
      @"opackets": @((int64_t) stats->ifi_opackets),
      @"obytes": @((int64_t) stats->ifi_obytes)};
    NSString* key = [[NSString alloc] initWithUTF8String:name];
    [ret setObject:readings forKey:key];}

  freeifaddrs (addrs);}

// Results in a `EXC_CRASH (SIGABRT)` crash log.
void throw_example (void) {
  @throw [NSException exceptionWithName:@"exceptionName" reason:@"throw_example" userInfo:nil];}

const char* documentDirectory (void) {
  NSFileManager* sharedFM = [NSFileManager defaultManager];
  NSArray<NSURL*>* urls = [sharedFM URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
  //for (NSURL* url in urls) os_log (OS_LOG_DEFAULT, "documentDirectory] supp dir: %{public}s\n", url.fileSystemRepresentation);
  if (urls.count < 1) {os_log (OS_LOG_DEFAULT, "documentDirectory] Can't get a NSApplicationSupportDirectory"); return NULL;}
  const char* wr_dir = urls[0].fileSystemRepresentation;
  return wr_dir;
}

// “in_use” stops at 256.
void file_example (void) {
  const char* documents = documentDirectory();
  NSString* dir = [[NSString alloc] initWithUTF8String:documents];
  NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:NULL];
  static int32_t total = 0;
  [files enumerateObjectsUsingBlock:^ (id obj, NSUInteger idx, BOOL *stop) {
    NSString* filename = (NSString*) obj;
    os_log (OS_LOG_DEFAULT, "file_example] filename: %{public}s", filename.UTF8String);

    NSString* path = [NSString stringWithFormat:@"%@/%@", dir, filename];
    int fd = open (path.UTF8String, O_RDWR);
    if (fd > 0) ++total;}];

  int32_t in_use = 0;
  for (int fd = 0; fd < (int) FD_SETSIZE; ++fd) if (fcntl (fd, F_GETFD, 0) != -1) ++in_use;

  os_log (OS_LOG_DEFAULT, "file_example] leaked %d; in_use %d / %d", total, in_use, (int32_t) FD_SETSIZE);}

// On iPhone 5s the app stopped at “phys_footprint 646 MiB; rs 19 MiB”.
// It didn't get to a memory allocation failure but was killed by Jetsam instead
// (“JetsamEvent-2020-04-03-175018.ips” was generated in the iTunes crash logs directory).
void leak_example (void) {
  static int8_t* leaks[9999];  // Preserve the pointers for GC
  static int32_t next_leak = 0;
  int32_t size = 9 * 1024 * 1024;
  os_log (OS_LOG_DEFAULT, "leak_example] Leaking %d MiB…", size / 1024 / 1024);
  int8_t* leak = malloc (size);
  if (leak == NULL) {os_log (OS_LOG_DEFAULT, "leak_example] Allocation failed"); return;}
  leaks[next_leak++] = leak;
  // Fill with random junk to workaround memory compression
  for (int ix = 0; ix < size; ++ix) leak[ix] = (int8_t) rand();
  os_log (OS_LOG_DEFAULT, "leak_example] Leak %d, allocated %d MiB", next_leak, size / 1024 / 1024);}

int32_t fds_simple (void) {
  int32_t fds = 0;
  for (int fd = 0; fd < (int) FD_SETSIZE; ++fd) if (fcntl (fd, F_GETFD, 0) != -1) ++fds;
  return fds;}

int32_t fds (void) {
  // fds_simple is likely to generate a number of interrupts
  // (FD_SETSIZE of 1024 would likely mean 1024 interrupts).
  // We should actually check it: maybe it will help us with reproducing the high number of `wakeups`.
  // But for production use we want to reduce the number of `fcntl` invocations.

  // We'll skip the first portion of file descriptors because most of the time we have them opened anyway.
  int fd = 66;
  int32_t fds = 66;
  int32_t gap = 0;

  while (fd < (int) FD_SETSIZE && fd < 333) {
    if (fcntl (fd, F_GETFD, 0) != -1) {  // If file descriptor exists
      gap = 0;
      if (fd < 220) {
        // We will count the files by ten, hoping that iOS traditionally fills the gaps.
        fd += 10;
        fds += 10;
      } else {
        // Unless we're close to the limit, where we want more precision.
        ++fd; ++fds;}
      continue;}
    // Sample with increasing step while inside the gap.
    int step = 1 + gap / 3;
    fd += step;
    gap += step;}

  return fds;}

const char* metrics (void) {
  //file_example();
  //leak_example();

  mach_port_t self = mach_task_self();
  if (self == MACH_PORT_NULL || self == MACH_PORT_DEAD) return "{}";

  // cf. https://forums.developer.apple.com/thread/105088#357415
  int32_t footprint = 0, rs = 0;
  task_vm_info_data_t vmInfo;
  mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
  kern_return_t rc = task_info (self, TASK_VM_INFO, (task_info_t) &vmInfo, &count);
  if (rc == KERN_SUCCESS) {
    footprint = (int32_t) vmInfo.phys_footprint / (1024 * 1024);
    rs = (int32_t) vmInfo.resident_size / (1024 * 1024);}

  // iOS applications are in danger of being killed if the number of iterrupts is too high,
  // so it might be interesting to maintain some statistics on the number of interrupts.
  int64_t wakeups = 0;
  task_power_info_data_t powInfo;
  count = TASK_POWER_INFO_COUNT;
  rc = task_info (self, TASK_POWER_INFO, (task_info_t) &powInfo, &count);
  if (rc == KERN_SUCCESS) wakeups = (int64_t) powInfo.task_interrupt_wakeups;

  int32_t files = fds();

  NSMutableDictionary* ret = [NSMutableDictionary new];

  //os_log (OS_LOG_DEFAULT,
  //  "metrics] phys_footprint %d MiB; rs %d MiB; wakeups %lld; files %d", footprint, rs, wakeups, files);
  ret[@"footprint"] = @(footprint);
  ret[@"rs"] = @(rs);
  ret[@"wakeups"] = @(wakeups);
  ret[@"files"] = @(files);

  network (ret);

  NSError *err;
  NSData *js = [NSJSONSerialization dataWithJSONObject:ret options:0 error: &err];
  if (js == NULL) {os_log (OS_LOG_DEFAULT, "metrics] !json: %@", err); return "{}";}
  NSString *jss = [[NSString alloc] initWithData:js encoding:NSUTF8StringEncoding];
  const char *cs = [jss UTF8String];
  return cs;}

void lsof (void)
{
    // AG: For now `os_log` allows me to see the information in the logs,
    // but in the future we might want to return the information to Flutter
    // in order to gather statistics on the use of file descriptors in the app, etc.

    int flags;
    int fd;
    char buf[MAXPATHLEN+1] ;
    int n = 1 ;

    for (fd = 0; fd < (int) FD_SETSIZE; fd++) {
        errno = 0;
        flags = fcntl(fd, F_GETFD, 0);
        if (flags == -1 && errno) {
            if (errno != EBADF) {
                return ;
            }
            else
                continue;
        }
        if (fcntl(fd , F_GETPATH, buf ) >= 0)
        {
            printf("File Descriptor %d number %d in use for: %s\n", fd, n, buf);
            os_log (OS_LOG_DEFAULT, "lsof] File Descriptor %d number %d in use for: %{public}s", fd, n, buf);
        }
        else
        {
                //[...]

                struct sockaddr_in addr;
                socklen_t addr_size = sizeof(struct sockaddr);
                int res = getpeername(fd, (struct sockaddr*)&addr, &addr_size);
                if (res >= 0)
                {
                    char clientip[20];
                    strcpy(clientip, inet_ntoa(addr.sin_addr));
                    uint16_t port = \
                      (uint16_t)((((uint16_t)(addr.sin_port) & 0xff00) >> 8) | \
                                 (((uint16_t)(addr.sin_port) & 0x00ff) << 8));
                    printf("File Descriptor %d, %s:%d \n", fd, clientip, port);
                    os_log (OS_LOG_DEFAULT, "lsof] File Descriptor %d, %{public}s:%d", fd, clientip, port);
                }
                else {
                    printf("File Descriptor %d number %d couldn't get path or socket\n", fd, n);
                    os_log (OS_LOG_DEFAULT, "lsof] File Descriptor %d number %d couldn't get path or socket", fd, n);
                }
        }
        ++n ;
    }
}
