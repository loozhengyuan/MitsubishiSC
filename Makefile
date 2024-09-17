# Project Variables
BUILD = release
SRC_DIR = src
INC_DIR = include
LIB_DIR = lib
OUT_DIR = build

# Project Source Files
ASM_FILES = $(wildcard $(SRC_DIR)/*.s)
SRC_FILES = $(wildcard $(SRC_DIR)/*.c)
CXX_FILES = $(wildcard $(SRC_DIR)/*.cpp)
LD_SCRIPT = $(LIB_DIR)/stm32cubel4/Projects/NUCLEO-L432KC/Templates/STM32CubeIDE/STM32L432KCUX_FLASH.ld

# Project Include Files
INCLUDES = -I$(INC_DIR)

# Vendor Source Files
# TODO: Use `shell find`?
ASM_FILES += $(LIB_DIR)/stm32cubel4/Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/gcc/startup_stm32l432xx.s
SRC_FILES += $(LIB_DIR)/stm32cubel4/Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/system_stm32l4xx.c
SRC_FILES += $(LIB_DIR)/stm32cubel4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal.c
SRC_FILES += $(LIB_DIR)/stm32cubel4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_gpio.c
SRC_FILES += $(LIB_DIR)/stm32cubel4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_cortex.c
SRC_FILES += $(LIB_DIR)/stm32cubel4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_rcc.c
SRC_FILES += $(LIB_DIR)/stm32cubel4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_pwr.c
SRC_FILES += $(LIB_DIR)/stm32cubel4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_pwr_ex.c

# Vendor Include Files
# TODO: Use `addprefix`?
INCLUDES += -I$(LIB_DIR)/stm32cubel4/Drivers/CMSIS/Core/Include
INCLUDES += -I$(LIB_DIR)/stm32cubel4/Drivers/CMSIS/Device/ST/STM32L4xx/Include
INCLUDES += -I$(LIB_DIR)/stm32cubel4/Drivers/STM32L4xx_HAL_Driver/Inc
INCLUDES += -I$(LIB_DIR)/stm32cubel4/Drivers/BSP/STM32L4xx_Nucleo_32

# Toolchain
# https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html
TOOLCHAIN_PREFIX = arm-none-eabi-
CC  = $(TOOLCHAIN_PREFIX)gcc
CXX = $(TOOLCHAIN_PREFIX)gcc
AS  = $(TOOLCHAIN_PREFIX)gcc
LD  = $(TOOLCHAIN_PREFIX)gcc
SZ  = $(TOOLCHAIN_PREFIX)size
OC  = $(TOOLCHAIN_PREFIX)objcopy

# Compiler Flags - Generic
# https://interrupt.memfault.com/blog/best-and-worst-gcc-clang-compiler-flags
CPPFLAGS += -Wall -Wextra
CPPFLAGS += -MMD -MP
CPPFLAGS += -mcpu=cortex-m4 -mthumb -mlittle-endian -mthumb-interwork -mfloat-abi=hard -mfpu=fpv4-sp-d16
CPPFLAGS += -DUSE_HAL_DRIVER -DSTM32L432xx -DUSE_STM32L4XX_NUCLEO_32
CPPFLAGS += $(INCLUDES)

# Compiler Flags - Build Specific Options
ifeq ($(BUILD), debug)
	CPPFLAGS += -DDEBUG
	CPPFLAGS += -g3 -O0
endif
ifeq ($(BUILD), release)
	CPPFLAGS += -g0 -O3
endif

# Compiler Flags - C Language Options
CFLAGS += -ffreestanding

# Compiler Flags - C++ Language Options
CXXFLAGS += -fno-threadsafe-statics
CXXFLAGS += -fno-rtti
CXXFLAGS += -fno-exceptions
CXXFLAGS += -fno-unwind-tables

# Compiler Flags - Assembly Language Options
ASFLAGS +=

# Linker Flags
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,--print-memory-usage
LDFLAGS += -Wl,--no-undefined
LDFLAGS += -Wl,-T$(LD_SCRIPT)

# Objects
OBJS += $(patsubst %.c,$(OUT_DIR)/$(BUILD)/%.o,$(SRC_FILES))
OBJS += $(patsubst %.cpp,$(OUT_DIR)/$(BUILD)/%.o,$(CXX_FILES))
OBJS += $(patsubst %.s,$(OUT_DIR)/$(BUILD)/%.o,$(ASM_FILES))

DEPS = $(OBJS:.o=.d)
-include $(DEPS)

.PHONY: all
all: $(OUT_DIR)/$(BUILD)/firmware.bin

# Rule for C files
$(OUT_DIR)/$(BUILD)/%.o: %.c
	@echo "[CC] $@"
	mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# Rule for C files
$(OUT_DIR)/$(BUILD)/%.o: %.cpp
	@echo "[CC] $@"
	mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

# Rule for Assembly files
$(OUT_DIR)/$(BUILD)/%.o: %.s
	@echo "[AS] $@"
	mkdir -p $(dir $@)
	$(AS) $(CPPFLAGS) $(ASFLAGS) -c $< -o $@

# Link all objects to ELF file
$(OUT_DIR)/$(BUILD)/firmware.elf: $(OBJS)
	@echo "[LD] $@"
	mkdir -p $(dir $@)
	$(LD) $(CPPFLAGS) $(LDFLAGS) $(OBJS) -o $@
	$(SZ) $@

# Generate binary from ELF
$(OUT_DIR)/$(BUILD)/firmware.bin: $(OUT_DIR)/$(BUILD)/firmware.elf
	@echo "[OBJCOPY] $@"
	mkdir -p $(dir $@)
	$(OC) -O binary $< $@

# Flash the binary to the device
# https://www.mankier.com/1/st-flash
.PHONY: flash
flash: $(OUT_DIR)/$(BUILD)/firmware.bin
	@echo "[FLASH] Flashing $(OUT_DIR)/$(BUILD)/firmware.bin to the target"
	st-info --probe --connect-under-reset
	st-flash --connect-under-reset erase
	st-flash --connect-under-reset write $(OUT_DIR)/$(BUILD)/firmware.bin 0x8000000

# Clean all generated files
.PHONY: clean
clean:
	@echo "[CLEAN] Cleaning everything"
	rm -rfv $(OUT_DIR)
