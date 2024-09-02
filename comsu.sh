#!/bin/bash

# Check if the API key environment variable is set
if [[ -z "$GOOGLE_AI_STUDIO_API_KEY" ]]; then
    echo "Error: The GOOGLE_AI_STUDIO_API_KEY environment variable is not set."
    exit 1
fi

# URL of the Google Generative AI API endpoint
API_URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$GOOGLE_AI_STUDIO_API_KEY"

# Function to get the staged changes from Git
get_staged_changes() {
    # Get the staged changes using git diff --cached
    changes=$(git diff --cached)

    # Clean up changes: remove newlines and escape double quotes
    clean_changes=$(echo "$changes" | sed ':a;N;$!ba;s/\n/ /g' | sed 's/"/\\"/g' | sed "s/'/\\'/g")

    echo "$clean_changes"
}

# Function to generate commit messages using Google Generative AI
generate_commit_messages() {
    local changes="$1"
    PROMPT_FILE="/usr/local/share/comsu/prompt"

    # Check if the prompt file exists
    if [[ ! -f "$PROMPT_FILE" ]]; then
        echo "Error: $PROMPT_FILE file not found!"
        exit 1
    fi

    # Load prompt from the file
    prompt_template=$(< "$PROMPT_FILE")

    # Combine the prompt with changes
    prompt="${prompt_template} Changes: $changes"

    # Prepare the JSON payload using the cleaned-up prompt
    json_payload=$(jq -n --arg text "$prompt" '{"contents":[{"parts":[{"text":$text}]}]}')

    # Make a request to the Google Generative AI API using curl
    response=$(curl -s \
      -H "Content-Type: application/json" \
      -d "$json_payload" \
      -X POST "$API_URL")

    # Extract and print the response text using jq
    echo "Suggested Commit Messages:"
    echo "$response" | jq -r '.candidates[0].content.parts[0].text'
}

# Main execution
main() {
    # Get the staged changes
    changes=$(get_staged_changes)

    # If there are no changes, exit the script
    if [ -z "$changes" ]; then
        echo "No staged changes found."
        exit 1
    fi

    # Generate commit message suggestions
    generate_commit_messages "$changes"
}

# Run the main function
main