# RTL-00 Test Load to RAM + RTL Console ROM

Testing RTL8710 + J-Link/STlink  

## pins:
* UART RX: GB0  
* UART TX: GB1  
* LED:     GC4  
* SWDIO:   GE3  
* SWCLK:   GE4  
## building:
```
make
```
## flashing:
```
JLinkGDB-WrFlash.bat
```
## reset:
```
JLink-Reset.bat
```
```
## Runing in ram:
```
JLink-RunRAM.bat
JLinkGDB-RunRAM.bat
```
## Read FullFlash
```
JLink-RdFullFlash.bat
```
## Debug RAM
```
export project to Eclipse...
```
## RTL00 Console ROM
```
JLink-RTL00ConsoleROM.bat
```


