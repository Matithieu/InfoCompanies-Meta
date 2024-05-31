#!/bin/bash
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
    if [ "$1" = "dev" ] || [ "$1" = "prod" ]; then
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
    REPO3_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@${REPO3}"
    REPO4_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@${REPO4}"

    # Validate repositories
    validate_repo "$REPO1_URL" || exit 1
    validate_repo "$REPO2_URL" || exit 1
    validate_repo "$REPO3_URL" || exit 1
    validate_repo "$REPO4_URL" || exit 1

    REPO1_DIR="InfoCompanies-API"
    REPO2_DIR="InfoCompanies-Front"
    REPO3_DIR="InfoCompanies-Scraping-API"
    REPO4_DIR="InfoCompanies-Data-Model"

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

    # Clone or update repository 3
    if [ ! -d "$REPO3_DIR" ]; then
        echo "Cloning $REPO3_URL into $REPO3_DIR"
        if git clone "$REPO3_URL" "$REPO3_DIR"; then
            echo -e "${GREEN}Cloned $REPO3_URL successfully.${NC}"
        else
            echo -e "${RED}Failed to clone $REPO3_URL${NC}"
            exit 1
        fi
    else
        echo "Updating $REPO3_DIR"
        cd "$REPO3_DIR" || { echo -e "${RED}Failed to enter $REPO3_DIR directory.${NC}"; exit 1; }
        if git pull; then
            echo -e "${GREEN}Updated $REPO3_DIR successfully.${NC}"
        else
            echo -e "${RED}Failed to update $REPO3_DIR${NC}"
            exit 1
        fi
        cd ..
    fi

    # Clone or update repository 4
    if [ ! -d "$REPO4_DIR" ]; then
        echo "Cloning $REPO4_URL into $REPO4_DIR"
        if git clone "$REPO4_URL" "$REPO4_DIR"; then
            echo -e "${GREEN}Cloned $REPO4_URL successfully.${NC}"
        else
            echo -e "${RED}Failed to clone $REPO4_URL${NC}"
            exit 1
        fi
    else
        echo "Updating $REPO4_DIR"
        cd "$REPO4_DIR" || { echo -e "${RED}Failed to enter $REPO4_DIR directory.${NC}"; exit 1; }
        if git pull; then
            echo -e "${GREEN}Updated $REPO4_DIR successfully.${NC}"
        else
            echo -e "${RED}Failed to update $REPO4_DIR${NC}"
            exit 1
        fi
        cd ..
    fi

    echo -e "${GREEN}Repositories are up-to-date!${NC}"
}

# Function to create .env files from .template.env files
create_env() {
    for dir in InfoCompanies-API InfoCompanies-Scraping-API; do
        TEMPLATE_FILE="$dir/template.env"
        ENV_FILE="$dir/.env"
        if [ -f "$TEMPLATE_FILE" ]; then
            cp "$TEMPLATE_FILE" "$ENV_FILE"
            echo -e "${GREEN}Created .env file in $dir from $TEMPLATE_FILE.${NC}"
        else
            echo -e "${RED}$TEMPLATE_FILE not found in $dir.${NC}"
            exit 1
        fi
    done
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
    create_env)
        create_env
        ;;
    *)
        echo -e "${YELLOW}Usage: ./devcli.sh {start|stop|insert_db|install|remove_volumes|create_env} {dev|prod}${NC}"
        exit 1
        ;;
esac
