# My Old LG TV

I have an old LG TV.  It is not WebOS.  It has its own proprietary protocol.

Thus dumb thing refuses to turn off via ARC/CEC when my Onkyo receiver turns off.  I don't know why.  Because of this I decided to make a SmartThings Edge driver that allows me to turn off the TV through SmartThings so that I can make rules to do it when I want (when the Onkyo receiver turns off, for example).  

This only allows you to turn off the TV if it is on, and it will tell you if your TV is on or off.  The old LG TVs don't have a real "standby" mode so the API isn't always available, so it determines this via network connectivity.


