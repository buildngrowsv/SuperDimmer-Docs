#!/bin/bash

###############################################################################
# SuperDimmer Freeze Debugging Script
# 
# This script helps diagnose app freezes by capturing multiple diagnostic
# reports simultaneously when the app is frozen.
#
# Usage:
#   ./debug-freeze.sh              # Interactive mode - prompts when to capture
#   ./debug-freeze.sh --auto       # Auto mode - captures when CPU is 0% or 100%
#   ./debug-freeze.sh --monitor    # Monitor mode - watches and alerts
#
# Output: Creates timestamped folder with all diagnostic files
###############################################################################

set -e

APP_NAME="SuperDimmer"
OUTPUT_DIR="$HOME/Desktop/SuperDimmer-Debug-$(date +%Y%m%d-%H%M%S)"
CONSOLE_LOG_DURATION="5m"  # How far back to capture Console logs

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

###############################################################################
# Helper Functions
###############################################################################

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
}

print_step() {
    echo -e "${GREEN}▶ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Check if app is running
is_app_running() {
    pgrep -x "$APP_NAME" > /dev/null 2>&1
}

# Get app PID
get_app_pid() {
    pgrep -x "$APP_NAME" | head -1
}

# Get CPU usage for app
get_cpu_usage() {
    local pid=$1
    ps -p "$pid" -o %cpu= | tr -d ' '
}

# Get memory usage for app (in MB)
get_memory_usage() {
    local pid=$1
    ps -p "$pid" -o rss= | awk '{print int($1/1024)}'
}

# Get thread count
get_thread_count() {
    local pid=$1
    ps -M "$pid" 2>/dev/null | wc -l | tr -d ' '
}

# Check if app appears frozen (CPU at 0% or 100% for extended period)
check_if_frozen() {
    local pid=$1
    local cpu=$(get_cpu_usage "$pid")
    
    # Remove decimal point for comparison
    cpu_int=${cpu%.*}
    
    if [ "$cpu_int" -eq 0 ] || [ "$cpu_int" -ge 95 ]; then
        return 0  # Appears frozen
    else
        return 1  # Appears normal
    fi
}

###############################################################################
# Diagnostic Capture Functions
###############################################################################

capture_spindump() {
    print_step "Capturing spindump (this takes ~10-15 seconds)..."
    
    if sudo spindump "$APP_NAME" -file "$OUTPUT_DIR/spindump.txt" 2>/dev/null; then
        print_success "Spindump captured"
        return 0
    else
        print_error "Failed to capture spindump (may need sudo password)"
        return 1
    fi
}

capture_sample() {
    print_step "Capturing sample (10 seconds)..."
    
    if sample "$APP_NAME" 10 -file "$OUTPUT_DIR/sample.txt" 2>/dev/null; then
        print_success "Sample captured"
        return 0
    else
        print_error "Failed to capture sample"
        return 1
    fi
}

capture_console_logs() {
    print_step "Capturing Console logs (last $CONSOLE_LOG_DURATION)..."
    
    # Capture all logs for the process
    log show --predicate "process == \"$APP_NAME\"" --last "$CONSOLE_LOG_DURATION" > "$OUTPUT_DIR/console-logs.txt" 2>/dev/null || true
    
    # Also capture system-wide logs mentioning the app
    log show --predicate "eventMessage CONTAINS \"$APP_NAME\"" --last "$CONSOLE_LOG_DURATION" > "$OUTPUT_DIR/system-logs.txt" 2>/dev/null || true
    
    print_success "Console logs captured"
}

capture_process_info() {
    local pid=$1
    print_step "Capturing process information..."
    
    {
        echo "═══════════════════════════════════════════════════════════"
        echo "Process Information for $APP_NAME (PID: $pid)"
        echo "Captured at: $(date)"
        echo "═══════════════════════════════════════════════════════════"
        echo ""
        
        echo "--- Basic Info ---"
        ps -p "$pid" -o pid,ppid,user,%cpu,%mem,vsz,rss,tt,stat,start,time,command
        echo ""
        
        echo "--- Thread Info ---"
        echo "Thread count: $(get_thread_count "$pid")"
        echo ""
        echo "Threads:"
        ps -M "$pid" 2>/dev/null | head -20
        echo ""
        
        echo "--- Memory Info ---"
        echo "Memory usage: $(get_memory_usage "$pid") MB"
        echo ""
        
        echo "--- Open Files ---"
        lsof -p "$pid" 2>/dev/null | head -50
        echo ""
        
        echo "--- Network Connections ---"
        lsof -i -n -P -p "$pid" 2>/dev/null
        echo ""
        
    } > "$OUTPUT_DIR/process-info.txt"
    
    print_success "Process info captured"
}

capture_activity_monitor_snapshot() {
    print_step "Capturing Activity Monitor data..."
    
    {
        echo "═══════════════════════════════════════════════════════════"
        echo "Activity Monitor Snapshot"
        echo "Captured at: $(date)"
        echo "═══════════════════════════════════════════════════════════"
        echo ""
        
        echo "--- Top Processes by CPU ---"
        top -l 1 -o cpu -n 10 -stats pid,command,cpu,mem,threads
        echo ""
        
        echo "--- Top Processes by Memory ---"
        top -l 1 -o mem -n 10 -stats pid,command,cpu,mem,threads
        echo ""
        
        echo "--- System Load ---"
        uptime
        echo ""
        
        echo "--- Memory Pressure ---"
        memory_pressure
        echo ""
        
    } > "$OUTPUT_DIR/activity-monitor.txt"
    
    print_success "Activity Monitor data captured"
}

capture_crash_logs() {
    print_step "Checking for crash/hang logs..."
    
    # Check for recent crash logs
    local crash_dir="$HOME/Library/Logs/DiagnosticReports"
    if [ -d "$crash_dir" ]; then
        # Find crash logs from last hour
        find "$crash_dir" -name "$APP_NAME*.crash" -mmin -60 -exec cp {} "$OUTPUT_DIR/" \; 2>/dev/null || true
        find "$crash_dir" -name "$APP_NAME*.hang" -mmin -60 -exec cp {} "$OUTPUT_DIR/" \; 2>/dev/null || true
        find "$crash_dir" -name "$APP_NAME*.spin" -mmin -60 -exec cp {} "$OUTPUT_DIR/" \; 2>/dev/null || true
    fi
    
    print_success "Crash logs checked"
}

create_summary() {
    local pid=$1
    print_step "Creating summary report..."
    
    {
        echo "═══════════════════════════════════════════════════════════"
        echo "SuperDimmer Freeze Debug Summary"
        echo "═══════════════════════════════════════════════════════════"
        echo ""
        echo "Captured at: $(date)"
        echo "PID: $pid"
        echo "CPU Usage: $(get_cpu_usage "$pid")%"
        echo "Memory Usage: $(get_memory_usage "$pid") MB"
        echo "Thread Count: $(get_thread_count "$pid")"
        echo ""
        echo "═══════════════════════════════════════════════════════════"
        echo "Files Captured:"
        echo "═══════════════════════════════════════════════════════════"
        ls -lh "$OUTPUT_DIR" | tail -n +2
        echo ""
        echo "═══════════════════════════════════════════════════════════"
        echo "Next Steps:"
        echo "═══════════════════════════════════════════════════════════"
        echo "1. Review spindump.txt for thread states and stack traces"
        echo "2. Check console-logs.txt for log messages before freeze"
        echo "3. Review process-info.txt for resource usage"
        echo "4. Look for patterns in sample.txt"
        echo ""
        echo "Key things to look for:"
        echo "- Threads in 'Blocked' state (deadlock)"
        echo "- High CPU in specific function (infinite loop)"
        echo "- Growing memory/thread count (leak)"
        echo "- Repeated log messages (runaway timer)"
        echo ""
    } > "$OUTPUT_DIR/SUMMARY.txt"
    
    print_success "Summary created"
}

###############################################################################
# Main Capture Function
###############################################################################

capture_diagnostics() {
    if ! is_app_running; then
        print_error "$APP_NAME is not running!"
        exit 1
    fi
    
    local pid=$(get_app_pid)
    
    print_header "Capturing Diagnostics for $APP_NAME (PID: $pid)"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    print_success "Created output directory: $OUTPUT_DIR"
    echo ""
    
    # Capture all diagnostics
    capture_process_info "$pid"
    capture_activity_monitor_snapshot
    capture_console_logs
    capture_sample &  # Run in background (takes 10 seconds)
    SAMPLE_PID=$!
    capture_spindump  # This takes longest (10-15 seconds)
    wait $SAMPLE_PID  # Wait for sample to finish
    capture_crash_logs
    create_summary "$pid"
    
    echo ""
    print_header "Diagnostics Capture Complete!"
    echo ""
    echo "Output directory: $OUTPUT_DIR"
    echo ""
    echo "To view the summary:"
    echo "  cat \"$OUTPUT_DIR/SUMMARY.txt\""
    echo ""
    echo "To view the spindump (most important):"
    echo "  less \"$OUTPUT_DIR/spindump.txt\""
    echo ""
}

###############################################################################
# Monitor Mode
###############################################################################

monitor_mode() {
    print_header "Monitoring $APP_NAME for Freeze Conditions"
    echo ""
    echo "Watching for:"
    echo "  - CPU at 0% for >5 seconds (deadlock)"
    echo "  - CPU at 100% for >5 seconds (infinite loop)"
    echo "  - Memory growth >50MB/minute"
    echo ""
    echo "Press Ctrl+C to stop monitoring"
    echo ""
    
    local freeze_counter=0
    local last_memory=0
    local check_interval=2  # Check every 2 seconds
    
    while true; do
        if ! is_app_running; then
            print_warning "$APP_NAME is not running. Waiting..."
            sleep 5
            continue
        fi
        
        local pid=$(get_app_pid)
        local cpu=$(get_cpu_usage "$pid")
        local memory=$(get_memory_usage "$pid")
        local threads=$(get_thread_count "$pid")
        
        # Display current stats
        echo -ne "\r$(date +%H:%M:%S) | CPU: ${cpu}% | Memory: ${memory}MB | Threads: ${threads}  "
        
        # Check for freeze conditions
        if check_if_frozen "$pid"; then
            freeze_counter=$((freeze_counter + check_interval))
            
            if [ $freeze_counter -ge 5 ]; then
                echo ""
                print_warning "FREEZE DETECTED! CPU at ${cpu}% for ${freeze_counter} seconds"
                echo ""
                read -p "Capture diagnostics now? (y/n) " -n 1 -r
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    capture_diagnostics
                    exit 0
                else
                    freeze_counter=0
                fi
            fi
        else
            freeze_counter=0
        fi
        
        # Check for memory growth
        if [ $last_memory -gt 0 ]; then
            local memory_diff=$((memory - last_memory))
            if [ $memory_diff -gt 50 ]; then
                echo ""
                print_warning "Memory grew by ${memory_diff}MB in last minute!"
            fi
        fi
        last_memory=$memory
        
        sleep $check_interval
    done
}

###############################################################################
# Auto Mode
###############################################################################

auto_mode() {
    print_header "Auto-Capture Mode for $APP_NAME"
    echo ""
    echo "Will automatically capture diagnostics when freeze is detected"
    echo "Press Ctrl+C to stop"
    echo ""
    
    local freeze_counter=0
    local check_interval=2
    
    while true; do
        if ! is_app_running; then
            print_warning "$APP_NAME is not running. Waiting..."
            sleep 5
            continue
        fi
        
        local pid=$(get_app_pid)
        local cpu=$(get_cpu_usage "$pid")
        
        echo -ne "\r$(date +%H:%M:%S) | Monitoring... CPU: ${cpu}%  "
        
        if check_if_frozen "$pid"; then
            freeze_counter=$((freeze_counter + check_interval))
            
            if [ $freeze_counter -ge 5 ]; then
                echo ""
                print_warning "FREEZE DETECTED! Auto-capturing diagnostics..."
                echo ""
                capture_diagnostics
                exit 0
            fi
        else
            freeze_counter=0
        fi
        
        sleep $check_interval
    done
}

###############################################################################
# Main Script
###############################################################################

main() {
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script only works on macOS"
        exit 1
    fi
    
    # Parse arguments
    case "${1:-}" in
        --auto)
            auto_mode
            ;;
        --monitor)
            monitor_mode
            ;;
        --help|-h)
            cat << EOF
SuperDimmer Freeze Debugging Script

Usage:
  $0              Interactive mode - prompts when to capture
  $0 --auto       Auto mode - captures when CPU is 0% or 100%
  $0 --monitor    Monitor mode - watches and alerts
  $0 --help       Show this help

What it captures:
  - Spindump (thread states and stack traces)
  - Sample (10-second performance snapshot)
  - Console logs (last 5 minutes)
  - Process information (CPU, memory, threads)
  - Activity Monitor data
  - Recent crash/hang logs

Output:
  Creates a timestamped folder on Desktop with all diagnostic files

EOF
            exit 0
            ;;
        "")
            # Interactive mode
            if ! is_app_running; then
                print_error "$APP_NAME is not running!"
                echo ""
                echo "Please start $APP_NAME and reproduce the freeze, then run this script again."
                exit 1
            fi
            
            local pid=$(get_app_pid)
            print_header "SuperDimmer Freeze Debugger - Interactive Mode"
            echo ""
            echo "Current status:"
            echo "  PID: $pid"
            echo "  CPU: $(get_cpu_usage "$pid")%"
            echo "  Memory: $(get_memory_usage "$pid") MB"
            echo "  Threads: $(get_thread_count "$pid")"
            echo ""
            echo "Is the app currently frozen?"
            echo ""
            read -p "Capture diagnostics now? (y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                capture_diagnostics
            else
                echo "Cancelled."
                exit 0
            fi
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
