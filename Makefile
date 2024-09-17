# Project Variables
BUILD = release
SRC_DIR = src
INC_DIR = include
LIB_DIR = lib
OUT_DIR = build

# Project Source Files
ASM_FILES = $(wildcard $(SRC_DIR)/*.s)
SRC_FILES = $(wildcard $(SRC_DIR)/*.c)
SRC_FILES += $(SRC_DIR)/STM32_WPAN/App/app_thread.c
SRC_FILES += $(SRC_DIR)/STM32_WPAN/App/app_ble.c
SRC_FILES += $(SRC_DIR)/STM32_WPAN/Target/hw_ipcc.c
CXX_FILES = $(wildcard $(SRC_DIR)/*.cpp)
LD_SCRIPT = $(LIB_DIR)/stm32cubewb/Drivers/CMSIS/Device/ST/STM32WBxx/Source/Templates/gcc/linker/stm32wb5mxx_flash_cm4.ld

# Project Include Files
INCLUDES = -I$(INC_DIR)
INCLUDES += -I$(INC_DIR)/STM32_WPAN/App

# Vendor Source Files
# TODO: Use `shell find`?
ASM_FILES += $(LIB_DIR)/x-cube-matter/Drivers/CMSIS/Device/ST/STM32WBxx/Source/Templates/gcc/startup_stm32wb5mxx_cm4.s
# SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/CMSIS/Device/ST/STM32WBxx/Source/Templates/system_stm32wbxx.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_gpio.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_cortex.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_rng.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_ipcc.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_rcc.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_rcc_ex.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_rtc.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_rtc_ex.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_pwr.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_pwr_ex.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_flash.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_flash_ex.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_dma.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_dma_ex.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_i2c.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_i2c_ex.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_tim.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_tim_ex.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_uart.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_uart_ex.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_exti.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_hsem.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Src/stm32wbxx_hal_spi.c
# SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS/cmsis_os.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2/cmsis_os2.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/interface/patterns/ble_thread/tl/tl_thread_hci.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/interface/patterns/ble_thread/tl/shci_tl.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/interface/patterns/ble_thread/tl/shci_tl_if.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/interface/patterns/ble_thread/tl/tl_mbox.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/interface/patterns/ble_thread/shci/shci.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/ble/core/auto/ble_hal_aci.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/channel_manager.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/channel_monitor.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/child_supervision.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/coap.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/coap_secure.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/commissioner.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/crypto.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/dataset.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/dataset_ftd.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/diag.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/dns.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/icmp6.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/instance.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/ip6.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/jam_detection.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/joiner.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/link.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/link_raw.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/message.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/netdata.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/openthread.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/openthread_api_wb.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/server.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/tasklet.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/thread.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/thread_ftd.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/udp.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/radio.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/border_agent.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/border_router.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/entropy.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/errors.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/logging.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/network_time.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/random_crypto.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/random_noncrypto.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api/sntp.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/utilities/dbg_trace.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/utilities/otp.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/utilities/stm_list.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/utilities/advanced_memory_manager.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/utilities/stm32_mm.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/utilities/heap_4.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/utilities/stm_queue.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4_MPU/port.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/FreeRTOS/Source/portable/Common/mpu_wrappers.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/FreeRTOS/Source/stream_buffer.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/FreeRTOS/Source/tasks.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/FreeRTOS/Source/queue.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/FreeRTOS/Source/list.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/mbedtls/library/threading.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/mbedtls/library/memory_buffer_alloc.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Drivers/BSP/STM32WB5MM-DK/stm32wb5mm_dk.c
SRC_FILES += $(LIB_DIR)/x-cube-matter/Utilities/lpm/tiny_lpm/stm32_lpm.c
CXX_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/connectedhomeip/src/app/clusters/switch-server/switch-server.cpp
CXX_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/connectedhomeip/src/lib/support/logging/TextOnlyLogging.cpp
# CXX_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/connectedhomeip/src/platform/stm32/PlatformManagerImpl.cpp
# CXX_FILES += $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/connectedhomeip/src/platform/stm32/STM32FreeRtosHooks.cpp
CXX_FILES += $(wildcard $(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/connectedhomeip/src/platform/stm32/*.cpp)


# Vendor Include Files
# TODO: Use `addprefix`?
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Drivers/CMSIS/Include # Check
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Drivers/CMSIS/Core/Include
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Drivers/CMSIS/Device/ST/STM32WBxx/Include
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Inc
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Drivers/STM32WBxx_HAL_Driver/Inc/Legacy # Check
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Drivers/BSP/Components/Common
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Drivers/BSP/Components/ssd1315
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Drivers/BSP/STM32WB5MM-DK
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/utilities
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/ble
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/ble/core
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/ble/core/auto
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/ble/core/template
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/core/openthread_api
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/stack/src/core
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/stack/include
# INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/stack/include/openthread/platform # Check
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/thread/openthread/stack/include/openthread
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/interface/patterns/ble_thread
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/interface/patterns/ble_thread/shci
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/ST/STM32_WPAN/interface/patterns/ble_thread/tl
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/connectedhomeip/src
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/connectedhomeip/src/include
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/connectedhomeip/src/lib
# INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/connectedhomeip/src/lib/dnssd
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/connectedhomeip/src/platform/stm32
# INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/connectedhomeip/src/platform
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/connectedhomeip/src/system
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/connectedhomeip/devices/generic-switch-app
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/nlassert/include
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/nlio/include
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/FreeRTOS/Source/include
# INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/FreeRTOS/Source/portable/Common
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4_MPU
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/mbedtls/library
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/mbedtls/include
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Middlewares/Third_Party/mbedtls/include/mbedtls
# INCLUDES += -I$(LIB_DIR)/x-cube-matter/Projects/STM32WB5MM-DK/Applications/Thread/Thread_Coap_Generic/STM32_WPAN/App
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Utilities/lpm/tiny_lpm
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Utilities/LCD
INCLUDES += -I$(LIB_DIR)/x-cube-matter/Utilities/sequencer # Check

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
# CPPFLAGS += -Wall -Wextra
CPPFLAGS += -MMD -MP
CPPFLAGS += -mcpu=cortex-m4 -mthumb -mlittle-endian -mthumb-interwork -mfloat-abi=hard -mfpu=fpv4-sp-d16
CPPFLAGS += -DUSE_HAL_DRIVER -DSTM32WB5Mxx -DUSE_STM32WB5M_DK -DTHREAD_WB -DOPENTHREAD_CONFIG_FILE=\"openthread_api_config_matter.h\" -DCHIP_ADDRESS_RESOLVE_IMPL_INCLUDE_HEADER=\"lib/address_resolve/AddressResolve_DefaultImpl.h\" -DCHIP_HAVE_CONFIG_H
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
