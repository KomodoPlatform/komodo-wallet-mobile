#include "mm2.h"

#import <sys/types.h>
#import <fcntl.h>
#import <errno.h>
#import <sys/param.h>
#import <stdio.h>
#import <os/log.h>  // os_log

#include <mach/mach.h>  // task_info, mach_task_self

#include <string.h>  // strcpy
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

void metrics (void) {
  mach_port_t self = mach_task_self();
  if (self == MACH_PORT_NULL || self == MACH_PORT_DEAD) return;

  // cf. https://forums.developer.apple.com/thread/105088#357415
  int32_t footprint = 0;
  task_vm_info_data_t vmInfo;
  mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
  kern_return_t rc = task_info (self, TASK_VM_INFO, (task_info_t) &vmInfo, &count);
  if (rc == KERN_SUCCESS) footprint = (int32_t) vmInfo.phys_footprint / (1024 * 1024);

  // iOS applications are in danger of being killed if the number of iterrupts is too high,
  // so it might be interesting to maintain some statistics on the number of interrupts.
  int64_t wakeups = 0;
  task_power_info_data_t powInfo;
  count = TASK_POWER_INFO_COUNT;
  rc = task_info (self, TASK_POWER_INFO, (task_info_t) &powInfo, &count);
  if (rc == KERN_SUCCESS) wakeups = (int64_t) powInfo.task_interrupt_wakeups;

  os_log (OS_LOG_DEFAULT, "phys_footprint %d MiB; wakeups %lld", footprint, wakeups);
}

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
