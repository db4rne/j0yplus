# stolen from https://www.das-labor.org/trac/browser/microcontroller-2/make/avr.mk

# Default values
OUT           ?= image
MCU_TARGET    ?= atmega88p
MCU_FTARGET   ?= m88p
MCU_CC        ?= avr-gcc
OPTIMIZE      ?= -Os
WARNINGS      ?= -Wall
DEFS          ?= -DF_CPU=8000000
CFLAGS        += -MMD -g -mmcu=$(MCU_TARGET) $(OPTIMIZE) $(WARNINGS) $(DEFS)
ASFLAGS       ?=  
ASFLAGS       += -g $(DEFS) 
LDFLAGS        = -Wl,-Map,$(OUT).map
CANADDR       ?= XXX

# External Tools
OBJCOPY       ?= avr-objcopy
OBJDUMP       ?= avr-objdump
FLASHCMD      ?= uisp -dprog=bsd --upload if=$(OUT).hex 
ERASECMD      ?= uisp -dprog=bsd --erase 
FLASHUSBCMD   ?= avrdude -c avr910 -p m32 -P $(AVRPROGDEV) -e -U flash:w:image.hex
LAPFLASHCMD   ?= lapcontrol -s rl

#############################################################################
# Rules
all: $(OUT).elf lst text eeprom

term:
	 gtkterm -p /dev/ttyUSB3 -s 19200

boot:
	 ./../../../launch-bootloader /dev/ttyUSB0 115200

clean:
	rm -rf $(OUT) *.o *.d *.lst *.map *.hex *.bin *.srec
	rm -rf *.srec $(OUT).elf

flashusbasp:
	avrdude -p $(MCU_FTARGET) -c usbasp -U f:w:image.hex -F

flashUSB0:
	avrdude -p $(MCU_FTARGET) -b 115200 -u -c avr109 -P /dev/ttyUSB0 -U f:w:image.hex -F

flashusb: $(OUT).hex
	$(FLASHUSBCMD)

canflash: $(OUT).hex
	$(LAPFLASHCMD) flash $(CANADDR) $(OUT).hex

#############################################################################
# Building Rules 
$(OUT).elf: $(OBJ)
	$(MCU_CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

%.o: %.c
	$(MCU_CC) $(CFLAGS) -c $<

%.o: %.S
	$(MCU_CC) -mmcu=$(MCU_TARGET) $(ASFLAGS) -c $<

lst: $(OUT).lst

%.lst: %.elf
	$(OBJDUMP) -h -S $< > $@

# Rules for building the .text rom images
text: hex bin srec

hex:  $(OUT).hex
bin:  $(OUT).bin
srec: $(OUT).srec

%.hex: %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

%.srec: %.elf
	$(OBJCOPY) -j .text -j .data -O srec $< $@

%.bin: %.elf
	$(OBJCOPY) -j .text -j .data -O binary $< $@


# Rules for building the .eeprom rom images

eeprom: ehex ebin esrec

ehex:  $(OUT)_eeprom.hex
ebin:  $(OUT)_eeprom.bin
esrec: $(OUT)_eeprom.srec




%_eeprom.hex: %.elf
	$(OBJCOPY) -j .eeprom --change-section-lma .eeprom=0 -O ihex $< $@

%_eeprom.srec: %.elf
	$(OBJCOPY) -j .eeprom --change-section-lma .eeprom=0 -O srec $< $@

%_eeprom.bin: %.elf
	$(OBJCOPY) -j .eeprom --change-section-lma .eeprom=0 -O binary $< $@ 

DEPS := $(wildcard *.d)
ifneq ($(DEPS),)
include $(DEPS)
endif
