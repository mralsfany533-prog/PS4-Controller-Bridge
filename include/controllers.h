#pragma once
#include <stdint.h>

// Vendor IDs (VID)
#define VID_SONY      0x054C
#define VID_MICROSOFT 0x045E

// Product IDs (PID)
#define PID_DUALSENSE      0x0CE6 // يد PS5 العادية
#define PID_DUALSENSE_EDGE 0x0DF2 // يد PS5 Edge
#define PID_XBOX_ONE       0x02D1 // يد Xbox One
#define PID_XBOX_SERIES    0x0B12 // يد Xbox Series X/S

struct ControllerInfo {
    uint16_t vid;
    uint16_t pid;
    const char* name;
};

static const ControllerInfo SUPPORTED_CONTROLLERS[] = {
    { VID_SONY, PID_DUALSENSE, "Sony DualSense (PS5)" },
    { VID_SONY, PID_DUALSENSE_EDGE, "Sony DualSense Edge" },
    { VID_MICROSOFT, PID_XBOX_ONE, "Microsoft Xbox One Controller" },
    { VID_MICROSOFT, PID_XBOX_SERIES, "Microsoft Xbox Series X/S" }
};
