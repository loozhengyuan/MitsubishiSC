# MitsubishiSC

Smart controller for Mitsubishi Electric HVAC systems.

## Concepts

### Protocol

The CN105 connector exposes the UART interface via the RX and TX pins. As [discovered by Hadley Rich](https://nicegear.nz/blog/hacking-a-mitsubishi-heat-pump-air-conditioner/), this uses 5V TTL 2400 8-E-1.

Since the ESP32/STM32 runs on 3.3V while the UART runs on 5V, there is a need to use a logic level shifter. [BSS138](https://www.onsemi.com/pdf/datasheet/bss138-d.pdf) is a N-channel MOSFET with a low $V_{GS(th)}$, which makes it [more ideal than other NMOS components](https://electronics.stackexchange.com/questions/242424/what-can-i-replace-a-bss138-n-channel-mosfet-with).

## Hardware

### Connector

The Mitsubishi Electric air conditioner has a `CN105` port that appears to be a [JST PA](https://www.jst.com/products/appliance-connectors/pa-family/) connector. To fit this, we should use `PAP-05V-S` housing with `SPHD-001T-P0.5`/`SPHD-002T-P0.5` contacts.

DigiKey stocks the `APALPA22K305`/`APAPA22K305` pre-crimped cables in 22 AWG, 12" cables.

According to the [LCSC](https://www.lcsc.com) team, the HCTL [`HC-PA-5Y`](https://www.lcsc.com/product-detail/Rectangular-Connectors-Housings_HCTL_C2962360.html) and [`HC-PA-T`](https://www.lcsc.com/product-detail/Line-Pressing-Terminals_HCTL-HC-PA-T_C2962368.html) are equivalent replacements for this part.

### Power Supply

The STM32/ESP32 runs on 3.3V but the `CN105` connector only exposes 12V and 5V power rails.

To power the MCU, we use a low-dropout linear regulator to regulate 5V to 3.3V. `MCP1700` is chosen for its low quiescent current ($I_Q$) but any modern LDO should work.

## License

[MIT](https://choosealicense.com/licenses/mit/)
