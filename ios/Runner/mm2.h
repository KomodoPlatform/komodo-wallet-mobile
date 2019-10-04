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

// Defined in "common/for_c.rs".
uint8_t is_loopback_ip (const char* ip);
// Defined in "mm2_lib.rs".
int8_t mm2_main (const char* conf, void (*log_cb) (const char* line));

#import <sys/types.h>
#import <fcntl.h>
#import <errno.h>
#import <sys/param.h>
#import <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

void lsof()
{
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
                    printf("File Descriptor %d, %s:%d \n", fd, clientip, ((__uint16_t)((((__uint16_t)(addr.sin_port) & 0xff00) >> 8) | \
                                                                                       (((__uint16_t)(addr.sin_port) & 0x00ff) << 8))));
                }
                else {
                    printf("File Descriptor %d number %d couldn't get path or socket\n", fd, n);
                }
        }
        ++n ;
    }
}

#endif /* mm2_h */
