#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <orbis/libkernel.h>
#include <orbis/Usbd.h>
#include <orbis/UserService.h>
#include "controllers.h"

void notify(const char* message) {
    OrbisNotificationRequest req;
    memset(&req, 0, sizeof(OrbisNotificationRequest));
    req.type = OrbisNotificationRequestType::NotificationRequest;
    req.unk3 = 0;
    req.useIconImageUri = 1;
    req.targetId = -1;
    strncpy(req.message, message, sizeof(req.message) - 1);
    sceKernelSendNotificationRequest(0, &req, sizeof(req), 0);
}

int main() {
    // تهيئة مكتبة USB في نظام PS4
    int ret = sceUsbdInit();
    if (ret < 0) {
        notify("خطأ: فشل تهيئة نظام USB");
        return -1;
    }

    notify("تم تشغيل Controller Bridge - بانتظار توصيل اليد...");

    libusb_device **list;
    while (true) {
        ssize_t count = sceUsbdGetDeviceList(&list);
        for (ssize_t i = 0; i < count; i++) {
            libusb_device_descriptor desc;
            if (sceUsbdGetDeviceDescriptor(list[i], &desc) == 0) {
                for (const auto& ctrl : SUPPORTED_CONTROLLERS) {
                    if (desc.idVendor == ctrl.vid && desc.idProduct == ctrl.pid) {
                        char msg[128];
                        snprintf(msg, sizeof(msg), "تم اكتشاف: %s", ctrl.name);
                        notify(msg);
                    }
                }
            }
        }
        if (count > 0) {
            sceUsbdFreeDeviceList(list, 1);
        }
        sleep(3); // فحص كل 3 ثوانٍ
    }

    sceUsbdExit();
    return 0;
}
