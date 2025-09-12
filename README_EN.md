# PicoCalc Transfer

[日本語](README.md) | **English**

A batch script for automatically transferring PicoMite BASIC programs from PC to PicoCalc device via editor. For reliable transfer, we recommend using XMODEM.

## Features

- **Automatic Transfer**: Transfer BASIC program files via serial communication to the editor
- **GUI File Selection**: File selection dialog opens when run without file specification
- **Auto Execution**: Automatically runs the program after transfer completion
- **Command Line Support**: COM port and file can be specified via options

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- PicoCalc (USB-C connection)

## Installation

1. Clone or download this repository
```bash
git clone https://github.com/PochiGit2021/picocalc-transfer.git
cd picocalc-transfer
```

2. Connect PicoCalc to PC via USB

3. Check COM port number in Device Manager

## Configuration

Default settings can be changed in `transfer.bat`:

```bat
:: Default configuration
set "COMPORT=COM3"        :: Default COM port
set "LOCAL_FILE=sample.bas"  :: Default file
set "BAUDRATE=115200"     :: Communication speed
set "LINE_DELAY=1"        :: Line transmission interval (seconds)
```

## Usage

### Basic Usage

```bash
# Select file via GUI and transfer
.\transfer.bat

# Transfer specific file
.\transfer.bat -f myprogram.bas

# Specify COM port
.\transfer.bat -c COM6

# Specify both COM port and file
.\transfer.bat -c COM6 -f myprogram.bas
```

### Options

| Option | Description | Example |
|--------|-------------|---------|
| `-c`, `--com` | Specify COM port | `-c COM6` |
| `-f`, `--file` | Specify BASIC file to transfer | `-f myprogram.bas` |
| `-h`, `--help` | Show help | `--help` |

### Transfer Process

The script automatically executes the following steps:

1. **COM Port Setup** - Configure specified COM port at 115200bps
2. **Delete Existing File** - Remove file with same name if exists
3. **Clear Memory** - Clear program memory with `NEW` command
4. **Start Editor** - Enter editor mode with `EDIT` command
5. **File Transfer** - Send program line by line
6. **Save & Exit** - Save and exit editor with F1 key
7. **Run Program** - Execute program with `RUN` command

## File Structure

```
picocalc-transfer/
├── transfer.bat          # Main script
├── sample.bas           # Sample BASIC program
├── README.md            # Japanese documentation
├── README_EN.md         # This file (English documentation)
└── LICENSE              # MIT License
```

## Sample Program

`sample.bas` contains a simple test program:

```basic
10 PRINT "Hello, PicoCalc!"
20 END
```

## License

This project is released under the MIT License. See [LICENSE](LICENSE) file for details.