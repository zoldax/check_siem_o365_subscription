#!/bin/bash

# =============================================================================
# Script: check_o365_subscription.sh
# Author: Pascal WEBER (zoldax)
# Version: 1.0 
# Description:
# This script interacts with the Microsoft Office API to manage
# subscription status and retrieve event logs related to Office 365.
# It provides functionalities such as:
#   - Checking the status of active subscriptions
#   - Starting or stopping subscriptions for Office 365 event logs
#   - Retrieving event logs for auditing purposes
#   - Debug mode for troubleshooting API requests
#   - Logging mode to record script execution details
#
# Usage:
# Run the script with the following command:
#   ./check_o365_subscription.sh [--debug] [--log] [--help]
#
# Options:
#   --debug      Enables debug mode to print API requests and responses.
#   --log        Enables logging mode to save execution details to a log file.
#   --help       Display this help message and exit.
#
# Dependencies:
# - Requires curl to send API requests.
# - Configuration file (config.ini) must be present in the same directory,
#   containing the following keys:
#     CLIENT_ID=your_client_id
#     TENANT_ID=your_tenant_id
#     CLIENT_SECRET=your_client_secret
#     PROXY_URL=your_proxy_url (or NONE if not using a proxy)
#
# Exit Codes:
#   0  - Success
#   1  - Configuration file missing or invalid
#   2  - Failed to obtain an access token
#   3  - API request error
#
#Copyright 2025 Pascal Weber (zoldax) / Abakus Sécurité
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# =============================================================================

CONFIG_FILE="config.ini"
DEBUG_MODE=0
LOG_MODE=0
LOG_FILE="check_o365_subscription_$(date '+%Y%m%d_%H%M%S').log"

# Display help message
show_help() {
    echo -e "\nShort Documentation : "
    grep '^#' "$0" | grep -v '#!' | sed 's/^#//'
    exit 0
}

# Parse command-line arguments
for arg in "$@"; do
    case "$arg" in
        --debug)
            DEBUG_MODE=1
            echo "🛠 Debug mode enabled"
            ;;
        --log)
            LOG_MODE=1
            echo "📝 Logging mode enabled"
            ;;
        --help)
            show_help
            ;;
    esac
done

# Logging function
log() {
    if [[ $LOG_MODE -eq 1 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    fi
}

# Load configuration
load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "❌ Error: Config file $CONFIG_FILE not found!"
        log "Error: Config file missing"
        exit 1
    fi
    CLIENT_ID=$(grep "CLIENT_ID" "$CONFIG_FILE" | cut -d '=' -f2 | tr -d ' ')
    TENANT_ID=$(grep "TENANT_ID" "$CONFIG_FILE" | cut -d '=' -f2 | tr -d ' ')
    CLIENT_SECRET=$(grep "CLIENT_SECRET" "$CONFIG_FILE" | cut -d '=' -f2 | tr -d ' ')
    PROXY_URL=$(grep "PROXY_URL" "$CONFIG_FILE" | cut -d '=' -f2 | tr -d ' ')
}

load_config

AUTH_URL="https://login.microsoftonline.com/$TENANT_ID/oauth2/token"
SUBSCRIPTION_URL="https://manage.office.com/api/v1.0/$TENANT_ID/activity/feed/subscriptions"

get_access_token() {
    log "Obtaining access token"
    response=$(curl -s -X POST "$AUTH_URL" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&grant_type=client_credentials&resource=https://manage.office.com")

    log "OAuth Response: $response"

    token=$(echo "$response" | grep -o '"access_token":"[^"]*' | sed 's/"access_token":"//' | tr -d '"')
    if [[ -z "$token" || "$token" == "null" ]]; then
        echo "❌ Failed to retrieve access token."
        log "Failed to retrieve access token"
        exit 2
    fi
    log "Access token retrieved successfully"
    echo "$token"
}

ACCESS_TOKEN=$(get_access_token)

api_call() {
    local method="$1"
    local url="$2"
    local data="$3"

    local headers=(
        -H "Authorization: Bearer $ACCESS_TOKEN"
        -H "Content-Type: application/json"
    )

    local proxy_option=""
    if [ "$PROXY_URL" != "NONE" ]; then
        proxy_option="--proxy $PROXY_URL"
    fi

    [[ $DEBUG_MODE -eq 1 ]] && echo -e "DEBUG: API Request: $method $url $data"
    log "API Request: $method $url $data"
    
    local response

    if [[ -z "$data" ]]; then
    response=$(curl -s $proxy_option -X "$method" "$url" "${headers[@]}")
    else
    response=$(curl -s $proxy_option -X "$method" "$url" "${headers[@]}" -d "$data")
    fi

    if [[ "$DEBUG_MODE" -eq 1 ]]; then
    echo "🛠 Raw API response:"
    echo "$response"
    fi

    if [[ "$choice" -eq 1 ]]; then
    echo -e "\n✅ Subscription Status:"
    echo "$response" | tr '{}' '\n' | grep -Eo '"contentType":"[^"]+"|"status":"[^"]+"|"webhook":("[^"]+"|null)' | \
    while read -r line; do
        key=$(echo "$line" | cut -d':' -f1 | tr -d '"')
        value=$(echo "$line" | cut -d':' -f2- | tr -d '"')

        case "$key" in
            contentType)
                echo "- Content Type: $value"
                ;;
            status)
                echo "  Status: $value"
                ;;
            webhook)
                webhook=${value:-None}
                [ -z "$webhook" ] && webhook="None"
                echo -e "  Webhook: $webhook\n"
                ;;
        esac
    done
    fi

    if [[ "$choice" -eq 3 ]]; then
    echo -e "\n🔄 Restart Subscription:"
    echo "$response" | tr '{}' '\n' | grep -Eo '"contentType":"[^"]+"|"status":"[^"]+"|"webhook":"[^"]*"' | \
    while IFS=: read -r key value; do
        key=$(echo "$key" | tr -d '"')
        value=$(echo "$value" | tr -d '",')

        case "$key" in
            contentType)
                echo "- Content Type: $value"
                ;;
            status)
                echo "  Status: $value"
                ;;
            webhook)
                webhook=${value:-None}
                [ -z "$webhook" ] && webhook="None"
                echo "  Webhook: $webhook"
                ;;
        esac
    done
    fi

    if [[ "$choice" -eq 4 ]]; then
    echo -e "\n📋 Retrieved Event Logs:"
    echo "$response" | tr '{}' '\n' | grep -Eo '"contentUri":"[^"]+"|"contentId":"[^"]+"|"contentType":"[^"]+"|"contentCreated":"[^"]+"|"contentExpiration":"[^"]+"' | \
    while IFS=: read -r key value; do
        value=$(echo "$value" | sed 's/"//g')
        case "$key" in
            '"contentUri"')
                echo -e "\n🔗 Content URI: $value"
                ;;
            '"contentId"')
                echo "🆔 Content ID: $value"
                ;;
            '"contentType"')
                echo "📂 Content Type: $value"
                ;;
            '"contentCreated"')
                echo "🗓 Created: $value"
                ;;
            '"contentExpiration"')
                echo "⌛ Expires: $value"
                ;;
        esac
    done
    fi

    log "API Response: $response"
}

log "Script execution started"

# Main execution
log "Script execution started"

# Interactive menu
while true; do
	echo -e "\ncheck_siem_o365_subscription by Pascal Weber (zoldax)\n\nChoose an action:\n1. Check Subscription Status\n2. Stop Subscription\n3. Restart Subscription\n4. Retrieve Event Logs\n5. Exit"
    read -rp "Enter your choice [1-5]: " choice

    case $choice in
        1)
            log "Checking subscription status"
            api_call "GET" "$SUBSCRIPTION_URL/list"
            ;;
        2)
            log "Stopping subscription"
            api_call "POST" "$SUBSCRIPTION_URL/stop?contentType=Audit.AzureActiveDirectory" "{}"
            ;;
        3)
            log "Restarting subscription"
            api_call "POST" "$SUBSCRIPTION_URL/start?contentType=Audit.AzureActiveDirectory" "{}"
            ;;
        4)
            log "Retrieving event logs"
            api_call "GET" "$SUBSCRIPTION_URL/content?contentType=Audit.AzureActiveDirectory"
            ;;
        5)
            log "Exiting script"
            echo "Exiting..."
            exit 0
            ;;
        *)
            log "Invalid choice selected"
            echo "❌ Invalid choice. Please enter a number between 1 and 5."
            ;;
    esac
done
