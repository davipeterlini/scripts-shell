#!/bin/bash

# Color definitions
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;37m'
NC='\033[0m' # No Color

# Function to display information messages
function print_info() {
  echo -e "\n${BLUE}ℹ️  $1${NC}"
}

# Function to display success messages
function print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

# Function to display alert messages
function print_alert() {
  echo -e "\n${YELLOW}⚠️  $1${NC}"
}

# Function to display alert messages
function print_alert_question() {
  echo -n -e "\n${YELLOW}⚠️  $1${NC}"
}

# Function to display error messages
function print_error() {
  echo -e "${RED}❌ Error: $1${NC}"
}

# Function to display plain messages
function print() {
  echo -e "${CYAN}$1${NC}"
}

# Function to display formatted messages
function print_header() {
  echo -e "\n${YELLOW}===========================================================================${NC}"
  echo -e "${GREEN}$1${NC}"
  echo -e "${YELLOW}===========================================================================${NC}"
}

# Function to display formatted messages
function print_header_info() {
  echo -e "\n${CYAN}===========================================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${CYAN}===========================================================================${NC}"
}

# Function to display alert messages
function print_yellow() {
  echo -e "${YELLOW}$1${NC}"
}

# Function to display error messages
function print_red() {
  echo -e "${RED}$1${NC}"
}
