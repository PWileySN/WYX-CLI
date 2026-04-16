#!/bin/bash

# Concourse Deploy Command
# Uses fly CLI to interact with Concourse CI
# Supports multiple targets and interactive pipeline/job selection

# Check if fly CLI is installed
check_fly_installed() {
    if ! command -v fly &> /dev/null; then
        sys.log.error "fly CLI is not installed!"
        echo ""
        echo "Install fly CLI from: https://concourse-ci.org/download.html"
        echo "Or use: brew install --cask fly"
        return 1
    fi
    return 0
}

# Get list of configured fly targets
get_fly_targets() {
    fly targets 2>/dev/null | tail -n +2 | awk '{print $1}' | grep -v "^$"
}

# Select Concourse target
select_target() {
    local targets=($(get_fly_targets))
    
    if [ ${#targets[@]} -eq 0 ]; then
        sys.log.error "No fly targets configured!"
        echo ""
        echo "Login to a Concourse target first:"
        echo "  fly -t <target-name> login -c <concourse-url>"
        return 1
    fi
    
    if [ ${#targets[@]} -eq 1 ]; then
        echo "${targets[0]}"
        return 0
    fi
    
    echo ""
    sys.log.h1 "SELECT CONCOURSE TARGET"
    echo ""
    
    local index=1
    for target in "${targets[@]}"; do
        echo "  ${GREEN}$index${RESET}) $target"
        ((index++))
    done
    echo ""
    
    echo -n "${GREEN}Select target (1-${#targets[@]}): ${RESET}"
    read choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#targets[@]}" ]; then
        echo "${targets[$((choice-1))]}"
        return 0
    else
        sys.log.error "Invalid selection"
        return 1
    fi
}

# Get pipelines for a target
get_pipelines() {
    local target="$1"
    fly -t "$target" pipelines 2>/dev/null | tail -n +2 | awk '{print $1}' | grep -v "^$"
}

# Select pipeline
select_pipeline() {
    local target="$1"
    local pipelines=($(get_pipelines "$target"))
    
    if [ ${#pipelines[@]} -eq 0 ]; then
        sys.log.error "No pipelines found for target: $target"
        return 1
    fi
    
    echo ""
    sys.log.h1 "SELECT PIPELINE"
    echo ""
    
    local index=1
    for pipeline in "${pipelines[@]}"; do
        echo "  ${GREEN}$index${RESET}) $pipeline"
        ((index++))
    done
    echo ""
    
    echo -n "${GREEN}Select pipeline (1-${#pipelines[@]}): ${RESET}"
    read choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#pipelines[@]}" ]; then
        echo "${pipelines[$((choice-1))]}"
        return 0
    else
        sys.log.error "Invalid selection"
        return 1
    fi
}

# Get jobs for a pipeline
get_jobs() {
    local target="$1"
    local pipeline="$2"
    fly -t "$target" jobs -p "$pipeline" 2>/dev/null | tail -n +2 | awk '{print $1}' | grep -v "^$"
}

# Select job
select_job() {
    local target="$1"
    local pipeline="$2"
    local jobs=($(get_jobs "$target" "$pipeline"))
    
    if [ ${#jobs[@]} -eq 0 ]; then
        sys.log.error "No jobs found for pipeline: $pipeline"
        return 1
    fi
    
    echo ""
    sys.log.h1 "SELECT JOB"
    echo ""
    
    local index=1
    for job in "${jobs[@]}"; do
        echo "  ${GREEN}$index${RESET}) $job"
        ((index++))
    done
    echo ""
    
    echo -n "${GREEN}Select job (1-${#jobs[@]}): ${RESET}"
    read choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#jobs[@]}" ]; then
        echo "${jobs[$((choice-1))]}"
        return 0
    else
        sys.log.error "Invalid selection"
        return 1
    fi
}

# Main deploy action
deploy_action() {
    local target="$1"
    local pipeline="$2"
    local job="$3"
    
    echo ""
    sys.log.h1 "DEPLOYMENT ACTION"
    echo ""
    echo "  ${GREEN}1${RESET}) Trigger job"
    echo "  ${GREEN}2${RESET}) Trigger and watch job"
    echo "  ${GREEN}3${RESET}) Unpause pipeline"
    echo "  ${GREEN}4${RESET}) View pipeline in browser"
    echo "  ${GREEN}5${RESET}) Check job status"
    echo ""
    
    echo -n "${GREEN}Select action (1-5): ${RESET}"
    read action
    
    case "$action" in
        1)
            sys.log.info "Triggering job: $pipeline/$job"
            fly -t "$target" trigger-job -j "$pipeline/$job"
            ;;
        2)
            sys.log.info "Triggering and watching job: $pipeline/$job"
            fly -t "$target" trigger-job -j "$pipeline/$job" --watch
            ;;
        3)
            sys.log.info "Unpausing pipeline: $pipeline"
            fly -t "$target" unpause-pipeline -p "$pipeline"
            ;;
        4)
            sys.log.info "Opening pipeline in browser..."
            fly -t "$target" builds -j "$pipeline/$job" --count 1
            # Get Concourse URL and open browser
            local concourse_url=$(fly -t "$target" targets | grep "^$target" | awk '{print $2}')
            if [ -n "$concourse_url" ]; then
                open "${concourse_url}/teams/main/pipelines/${pipeline}/jobs/${job}"
            fi
            ;;
        5)
            sys.log.info "Recent builds for: $pipeline/$job"
            fly -t "$target" builds -j "$pipeline/$job" --count 5
            ;;
        *)
            sys.log.error "Invalid action"
            return 1
            ;;
    esac
}

# Main logic
main_deploy() {
    # Check if fly is installed
    if ! check_fly_installed; then
        return 1
    fi
    
    # Get target (from argument or select)
    local target=""
    local pipeline=""
    local job=""
    
    if toolboxd.arggt "1"; then
        target="$1"
        # Validate target exists
        if ! fly -t "$target" status &>/dev/null; then
            sys.log.error "Invalid target: $target"
            echo ""
            echo "Available targets:"
            get_fly_targets
            return 1
        fi
        
        # Get pipeline from second argument if provided
        if toolboxd.arggt "2"; then
            pipeline="$2"
        fi
        
        # Get job from third argument if provided
        if toolboxd.arggt "3"; then
            job="$3"
        fi
    else
        # Interactive target selection
        target=$(select_target)
        if [ -z "$target" ]; then
            return 1
        fi
    fi
    
    sys.log.info "Target: $target"
    
    # Select pipeline if not provided
    if [ -z "$pipeline" ]; then
        pipeline=$(select_pipeline "$target")
        if [ -z "$pipeline" ]; then
            return 1
        fi
    fi
    
    sys.log.info "Pipeline: $pipeline"
    
    # Select job if not provided
    if [ -z "$job" ]; then
        job=$(select_job "$target" "$pipeline")
        if [ -z "$job" ]; then
            return 1
        fi
    fi
    
    sys.log.info "Job: $job"
    
    # Perform deployment action
    deploy_action "$target" "$pipeline" "$job"
}

# Run main function with all arguments
main_deploy "$@"
