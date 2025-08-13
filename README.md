**Based on:** `A166PXXU4BYE5`  
**Kernel version:** 5.15.167-android13-8  
**KernelSU-Next version:** v1.0.9  
**SuSFS version:** v1.5.9  

---

### 💛 Features:

- Latest KernelSU-Next and SuSFS.
- 32-bit `su` support.
- Built in Mediatek connectivity modules with additional fixes.
- Providing all the 550+ kernel modules for the maximum compatibility.
- Build with `Full LTO`.

---

### 🟢 Installation

**What you need:**
- Odin software on PC
- Phone with unlocked bootloader

**Step 1: Download Files**
1. Download the Kernel release zip from [releases](https://github.com/ravindu644/android_kernel_a166p/releases)
2. Download `SM-A166P-Fastbootd-patched-recovery.tar` from [here](https://github.com/ravindu644/android_kernel_a166p/releases/download/recovery/SM-A166P-Fastbootd-patched-recovery.tar)
3. Extract the Kernel zip - you'll get a `.tar` file and `vendor_dlkm.img` file

**Step 2: Flash with Odin**
1. Turn off phone, boot into Download Mode (Turn off the Phone -> Press and hold both `Vol Up` and `Vol Down` keys while plugging in to your PC)  
2. Connect phone to PC  
3. Open Odin  
4. Load both `.tar` files into any slots (AP, CP, CSC - doesn't matter which)  
5. Click Start and wait for "PASS"

**Step 3: Enter Recovery (Critical Timing!)**
1. **As soon as phone starts rebooting**, immediately hold `Vol Up + Power`
2. Release buttons when you see the bootloader warning screen
3. Phone should enter recovery mode

**Step 4: Flash Final Component**
1. In recovery, go to "Enter fastboot"
2. Connect phone to PC
3. Open command prompt in the folder where you extracted the kernel zip
4. Run this command:
```bash
fastboot flash vendor_dlkm vendor_dlkm.img && fastboot reboot
```

Done! Phone will reboot normally with KernelSU installed.
