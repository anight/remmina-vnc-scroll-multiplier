# Remmina VNC: mouse wheel multiplier

A patch for Remmina's VNC plugin (tested with Remmina 1.4.43) that makes the
mouse wheel usable with servers that scroll very little per wheel event, such
as macOS Screen Sharing.

What it changes:

- A new per-connection setting, **Mouse wheel multiplier** (Advanced tab,
  1-50, profile key `scrollmultiplier`): the number of RFB wheel events sent
  for each wheel step. The default is 1, the stock behaviour.
- Smooth scrolling no longer drops movement: the stock plugin sends one wheel
  event when the accumulated delta reaches 1.0 and then resets the
  accumulator, so a fast spin delivered as one large delta counts as a single
  step and the remainder is lost. The patched plugin sends one event for every
  whole step and keeps the remainder.

## Build and install

    sudo apt install build-essential pkg-config curl patch libgtk-3-dev libvncserver-dev
    ./build.sh

`build.sh` downloads the Remmina source of the installed version, applies the
patch, builds only the VNC plugin and copies it to
`~/.config/remmina/plugins/remmina-plugin-vnc.so`. Remmina loads that folder
before the system plugins and skips a system plugin of the same file name, so
the installed package stays untouched and no root is needed for the install.

Quit Remmina completely (tray icon, Quit) and start it again, then set the
multiplier in the connection's Advanced tab. For macOS 5-10 feels right.

To go back to the stock plugin, delete that file and restart Remmina. Rebuild
after a Remmina upgrade.

## License

The patch is a derivative of Remmina and is under the same license,
GPL-2.0-or-later with the OpenSSL exception.
