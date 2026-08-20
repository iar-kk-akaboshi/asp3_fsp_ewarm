#include <kernel.h>
#include <t_syslog.h>
#include <t_stdlib.h>
#include "syssvc/serial.h"
#include "syssvc/syslog.h"
#include "kernel_cfg.h"
#include "ex1.h"

void
task(EXINF exinf) {
      	syslog(LOG_NOTICE, "Start Task");

        while(1) {
        }
}