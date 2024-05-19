# MitsubishiSC

Smart controller for Mitsubishi Electric HVAC systems.

## Concepts

### Protocol

The CN105 connector exposes the UART interface via the RX and TX pins. As [discovered by Hadley Rich](https://nicegear.nz/blog/hacking-a-mitsubishi-heat-pump-air-conditioner/), this uses 5V TTL 2400 8-E-1.

Since the ESP32/STM32 runs on 3.3V while the UART runs on 5V, there is a need to use a logic level shifter. [BSS138](https://www.onsemi.com/pdf/datasheet/bss138-d.pdf) is a N-channel MOSFET with a low $V_{GS(th)}$, which makes it [more ideal than other NMOS components](https://electronics.stackexchange.com/questions/242424/what-can-i-replace-a-bss138-n-channel-mosfet-with).

For more information about the packets, refer to [mUART Protocol Reference](https://muart-group.github.io/developer/packet-reference).

## Hardware

### MCU

As part of the project goals, we want to build a device that leverages on the [Matter](https://csa-iot.org/all-solutions/matter/) standard for maximum compatibility and [Thread](https://www.threadgroup.org) for low-power, low-latency performance. The selected microcontroller should have the following features:

- Support for WiFi and Thread
- Support for Matter over WiFi/Thread

| Manufacturer         | MPN                                                                                                                       | Type | Price                                                                                                                             |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------- | ---- | --------------------------------------------------------------------------------------------------------------------------------- |
| Espressif Systems    | [`ESP32-C6FH4`](https://www.espressif.com/sites/default/files/documentation/esp32-c6_datasheet_en.pdf)                    | SoC  |                                                                                                                                   |
| Espressif Systems    | [`ESP32-C6-MINI-1`](https://www.espressif.com/sites/default/files/documentation/esp32-c6-mini-1_mini-1u_datasheet_en.pdf) | SoC  |                                                                                                                                   |
| STMicroelectronics   | [`STM32WB55CGU6`](https://www.st.com/resource/en/datasheet/stm32wb55cg.pdf)                                               | SoC  | [US$3.48](https://www.lcsc.com/product-detail/Microcontroller-Units-MCUs-MPUs-SOCs_STMicroelectronics-STM32WB55CGU6_C404023.html) |
| STMicroelectronics   | [`STM32WB5MMG`](https://www.st.com/resource/en/datasheet/stm32wb5mmg.pdf)                                                 | SoC  |                                                                                                                                   |
| Nordic Semiconductor | [`NRF52840-QIAA-R`](https://docs-be.nordicsemi.com/bundle/ps_nrf52840/attach/nRF52840_PS_v1.9.pdf)                        | SoC  | [US$3.41](https://www.lcsc.com/product-detail/RF-Transceiver-ICs_Nordic-Semicon-NRF52840-QIAA-R_C190794.html)                     |

_NOTE: The SKUs from [LCSC](https://www.lcsc.com) Popular Products are preferred to ensure good price and supply._

### Connector

The Mitsubishi Electric air conditioner has a `CN105` port that appears to be a [JST PA](https://www.jst.com/products/appliance-connectors/pa-family/) connector. To fit this, we should use `PAP-05V-S` housing with `SPHD-001T-P0.5`/`SPHD-002T-P0.5` contacts.

DigiKey stocks the `APALPA22K305`/`APAPA22K305` pre-crimped cables in 22 AWG, 12" cables.

According to the [LCSC](https://www.lcsc.com) team, the HCTL [`HC-PA-5Y`](https://www.lcsc.com/product-detail/Rectangular-Connectors-Housings_HCTL_C2962360.html) and [`HC-PA-T`](https://www.lcsc.com/product-detail/Line-Pressing-Terminals_HCTL-HC-PA-T_C2962368.html) are equivalent replacements for this part.

### Power Supply

The STM32/ESP32 runs on 3.3V but the `CN105` connector only exposes 12V and 5V power rails.

To power the MCU, we use a low-dropout linear regulator to regulate 5V to 3.3V. `MCP1700` is chosen for its low quiescent current ($I_Q$) but any modern LDO should work.

## License

[MIT](https://choosealicense.com/licenses/mit/)
