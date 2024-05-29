#!/bin/zsh

# Color codes for styling
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo -e "${RED}.env file not found. Please create one with the required variables.${NC}"
    exit 1
fi

# Function to start docker containers
start() {
    if [ -z "$1" ]; then
        echo -e "${RED}No environment specified. Please use 'dev' or 'prod'.${NC}"
        exit 1
    fi

    echo "Starting docker containers..."
    if [ "$1" = "dev" ]; then
        if docker-compose -f "docker-compose-$1.yml" up --build; then
            echo -e "${GREEN}Containers are up!${NC}"
        else
            echo -e "${RED}Failed to start docker containers.${NC}"
            exit 1
        fi
    elif [ "$1" = "prod" ]; then
        if docker-compose -f "docker-compose-$1.yml" up --build; then
            echo -e "${GREEN}Containers are up!${NC}"
        else
            echo -e "${RED}Failed to start docker containers.${NC}"
            exit 1
        fi
    fi
}

stop() {
    if [ -z "$1" ]; then
        echo -e "${RED}No environment specified. Please use 'dev' or 'prod'.${NC}"
        exit 1
    fi

    echo "Stopping docker containers..."
    if docker-compose -f "docker-compose-$1.yml" down; then
        echo -e "${GREEN}Containers are down!${NC}"
    else
        echo -e "${RED}Failed to stop docker containers.${NC}"
        exit 1
    fi
}

# Function to insert data into the database
insert_db() {
    echo "Insertion de données dans la base de données..."
    if sudo -E sh ./InfoCompanies-Data-Model/db.sh; then
        echo -e "${GREEN}Data inserted successfully.${NC}"
    else
        echo -e "${RED}Failed to insert data.${NC}"
        exit 1
    fi
}

# Function to validate a repository URL
validate_repo() {
    REPO_URL="$1"
    if git ls-remote "$REPO_URL" &>/dev/null; then
        echo -e "${GREEN}Repository $REPO_URL is valid.${NC}"
        return 0
    else
        echo -e "${RED}Repository $REPO_URL is invalid or inaccessible.${NC}"
        return 1
    fi
}

# Function to remove volumes
remove_volumes() {
    echo "Removing volumes for $1 environment..."
    if docker-compose -f "docker-compose-$1.yml" down -v; then
        echo -e "${GREEN}Volumes removed for $1 environment!${NC}"
    else
        echo -e "${RED}Failed to remove volumes for $1 environment.${NC}"
        exit 1
    fi
}

# Function to install repositories from GitHub
install() {
    echo "Fetching repositories from GitHub..."

    REPO1_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@${REPO1}"
    REPO2_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@${REPO2}"

    # Validate repositories
    validate_repo "$REPO1_URL" || exit 1
    validate_repo "$REPO2_URL" || exit 1

    REPO1_DIR="InfoCompanies-API"
    REPO2_DIR="infoCompanies"

    # Clone or update repository 1
    if [ ! -d "$REPO1_DIR" ]; then
        echo "Cloning $REPO1_URL into $REPO1_DIR"
        if git clone "$REPO1_URL" "$REPO1_DIR"; then
            echo -e "${GREEN}Cloned $REPO1_URL successfully.${NC}"
        else
            echo -e "${RED}Failed to clone $REPO1_URL${NC}"
            exit 1
        fi
    else
        echo "Updating $REPO1_DIR"
        cd "$REPO1_DIR" || { echo -e "${RED}Failed to enter $REPO1_DIR directory.${NC}"; exit 1; }
        if git pull; then
            echo -e "${GREEN}Updated $REPO1_DIR successfully.${NC}"
        else
            echo -e "${RED}Failed to update $REPO1_DIR${NC}"
            exit 1
        fi
        cd ..
    fi

    # Clone or update repository 2
    if [ ! -d "$REPO2_DIR" ]; then
        echo "Cloning $REPO2_URL into $REPO2_DIR"
        if git clone "$REPO2_URL" "$REPO2_DIR"; then
            echo -e "${GREEN}Cloned $REPO2_URL successfully.${NC}"
        else
            echo -e "${RED}Failed to clone $REPO2_URL${NC}"
            exit 1
        fi
    else
        echo "Updating $REPO2_DIR"
        cd "$REPO2_DIR" || { echo -e "${RED}Failed to enter $REPO2_DIR directory.${NC}"; exit 1; }
        if git pull; then
            echo -e "${GREEN}Updated $REPO2_DIR successfully.${NC}"
        else
            echo -e "${RED}Failed to update $REPO2_DIR${NC}"
            exit 1
        fi
        cd ..
    fi

    echo -e "${GREEN}Repositories are up-to-date!${NC}"
}

# Check the arguments passed to the script
case "$1" in
    start)
        if [ "$2" = "dev" ] || [ "$2" = "prod" ]; then
            start "$2"
        else
            echo -e "${YELLOW}Usage: ./devcli.sh start {dev|prod}${NC}"
            exit 1
        fi
        ;;
    stop)
        if [ "$2" = "dev" ] || [ "$2" = "prod" ]; then
            stop "$2"
        else
            echo -e "${YELLOW}Usage: ./devcli.sh stop {dev|prod}${NC}"
            exit 1
        fi
        ;;
    insert_db)
        insert_db
        ;;
    install)
        install
        ;;
    remove_volumes)
        if [ "$2" = "dev" ] || [ "$2" = "prod" ]; then
            remove_volumes "$2"
        else
            echo -e "${YELLOW}Usage: ./script.sh remove_volumes {dev|prod}${NC}"
            exit 1
        fi
        ;;
    *)
        echo -e "${YELLOW}Usage: ./devcli.sh {start|stop|insert_db|create_keycloak_user|install} {dev|prod}${NC}"
        exit 1
        ;;
esac
