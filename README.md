# Check O365 Subscription Script

A Bash script for managing and auditing Office 365 event log subscriptions.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Options](#options)
- [Configuration](#configuration)
- [Dependencies](#dependencies)
- [Exit Codes](#exit-codes)
- [License](#license)
- [Author](#author)

---

## Overview

The `check_o365_subscription.sh` script interacts with Microsoft Office 365 to manage event log subscriptions. It enables administrators to:

- Check active subscription statuses
- Start or stop event log subscriptions
- Retrieve event logs for auditing purposes
- Activate debug and logging modes for troubleshooting

---

## Features

- **Subscription Management**: Easily check, start, or stop Office 365 subscriptions.
- **Event Log Retrieval**: Quickly obtain Office 365 event logs.
- **Debugging Mode**: Provides detailed information for troubleshooting API calls.
- **Logging**: Records script activities into timestamped log files.

---

## Installation

Clone the repository:

```
git clone https://github.com/yourusername/check-o365-subscription.git
cd check-o365-subscription
chmod +x check_o365_subscription.sh
```

Create the required `config.ini` file with your credentials in the same directory:

```
CLIENT_ID=your_client_id
TENANT_ID=your_tenant_id
CLIENT_SECRET=your_client_secret
PROXY_URL=NONE  # Or set your proxy URL
```

---

## Usage

Run the script directly:

```
./check_o365_subscription.sh [--debug] [--log] [--help]
```

Example usage with debug and logging enabled:

```
./check_o365_subscription.sh --debug --log
```

An interactive menu will appear with these options:

```
1. Check Subscription Status
2. Stop Subscription
3. Restart Subscription
4. Retrieve Event Logs
5. Exit
```

Choose the appropriate option by entering the corresponding number.

---

## Options

- `--debug` : Enables detailed debug output (API requests/responses).
- `--log` : Records detailed execution logs to a timestamped file.
- `--help` : Displays help message and usage instructions.

---

## Configuration

Ensure your `config.ini` file contains valid credentials and settings:

| Parameter       | Description                             |
|-----------------|-----------------------------------------|
| CLIENT_ID       | Microsoft Office 365 application ID.    |
| TENANT_ID       | Your Azure tenant ID.                   |
| CLIENT_SECRET   | Secret for your Office 365 application. |
| PROXY_URL       | Proxy URL or NONE if not applicable.    |

---

## Dependencies

- curl: Required to make HTTP requests to the Microsoft API.

---

## Exit Codes

| Code | Meaning                               |
|------|---------------------------------------|
| 0    | Success                               |
| 1    | Configuration file missing or invalid |
| 2    | Failed to obtain an access token      |
| 3    | API request error                     |

---

## License

This project is licensed under the Apache License 2.0.  
Full text: https://www.apache.org/licenses/LICENSE-2.0

---

## Author

- Pascal Weber (zoldax)
- Company: Abakus Sécurité  

## Disclaimer:

This project is not affiliated with, endorsed by, or supported by Microsoft in any way. "Microsoft" and "Office 365" are trademarks of Microsoft Corporation.

This software/code is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and non-infringement. In no event shall the authors or contributors be held liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use of this software.

Use at your own risk. By using this software, you acknowledge that you assume all responsibility and potential risks associated with its usage, including compliance with Microsoft's terms of service.

