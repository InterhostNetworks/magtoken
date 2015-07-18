magtoken v0.1 (alpha)
1. for 2.6.16 replace /etc/init.d/usb-disks-handler.sh with usb-disks-handler-2.6.16.sh
2. create /root/magtoken/ folder and put all files inside
3. usbtoken should contain simple (yet) file called magtoken.sig (provided) on it's root directory.
4. create channel9 with channel ID 212 or change script accordingly. DONOT select "base channel", check "Bonus channel". API TARIFF server will add this channel to user's subscription upon successful verification of usbtoken for 30 minutes.
5. open APIv1 access in portal for 185.18.206.235 (IP auth only, passwordless).
6. STB will prolong its subscription every 25 minutes as long as usbtoken mounted and signature file exists.

notes:
- system yet very fragile in alpha stage. Make sure you test it before putting in production.
- account id in stalker must have a not NOT-NULL value.
