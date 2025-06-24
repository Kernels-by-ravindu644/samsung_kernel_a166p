#include "tyhx_log.h"
#include <linux/pm_wakeup.h>

#define KV_DRIVER_NAME "k250a" //i2c addr: 0x23

/* secchip wakelock */
#define secchip_wake_lock_init(dev, name) wakeup_source_register(dev, name)
#define secchip_wake_lock_destroy(ws) wakeup_source_destroy(ws)
#define secchip_wake_lock(ws) __pm_stay_awake(ws)
#define secchip_wake_unlock(ws) __pm_relax(ws)
#define secchip_wake_locked(ws) (ws->active)
