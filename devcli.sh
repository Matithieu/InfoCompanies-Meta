#!/bin/bash
#!/bin/zsh

# Color codes for styling
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load environment variables from .env file
if [ -f .env ]; then
    export "$(grep -v '^#' .env | xargs)"
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
    CSV_FILE="final.csv"
    if [ "$1" = "template" ]; then
        CSV_FILE="template.csv"
    fi

    echo "Insertion de données dans la base de données..."
    if sudo -E sh ./InfoCompanies-Data-Model/db.sh "$CSV_FILE"; then
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

# Function to clone or update a repository
clone_or_update_repo() {
    REPO_URL="$1"
    REPO_DIR="$2"

    if [ ! -d "$REPO_DIR" ]; then
        echo "Cloning $REPO_URL into $REPO_DIR"
        if git clone "$REPO_URL" "$REPO_DIR"; then
            echo -e "${GREEN}Cloned $REPO_URL successfully.${NC}"
        else
            echo -e "${RED}Failed to clone $REPO_URL${NC}"
            exit 1
        fi
    else
        echo "Updating $REPO_DIR"
        cd "$REPO_DIR" || {
            echo -e "${RED}Failed to enter $REPO_DIR directory.${NC}"
            exit 1
        }
        if git pull; then
            echo -e "${GREEN}Updated $REPO_DIR successfully.${NC}"
        else
            echo -e "${RED}Failed to update $REPO_DIR${NC}"
            exit 1
        fi
        cd ..
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

    clone_or_update_repo "$REPO1_URL" "InfoCompanies-API"
    clone_or_update_repo "$REPO2_URL" "InfoCompanies-Front"
    clone_or_update_repo "$REPO3_URL" "InfoCompanies-Scraping-API"
    clone_or_update_repo "$REPO4_URL" "InfoCompanies-Data-Model"

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

# Function to initialize the environment
init() {
    echo "Initializing the environment..."
    install
    create_env
    insert_db "template"
    echo -e "${GREEN}Environment initialized successfully!${NC}"
}

# Function to reload the backend API container
reload_backend() {
    if [ -z "$1" ]; then
        echo -e "${RED}No environment specified. Please use 'dev' or 'prod'.${NC}"
        exit 1
    fi

    ENV=$1

    echo "Building the Docker image for backend..."
    if docker-compose -f "docker-compose-$ENV.yml" stop backend; then
        echo -e "${GREEN}Docker image built successfully.${NC}"
    else
        echo -e "${RED}Failed to build Docker image.${NC}"
        exit 1
    fi

    echo "Stopping the backend container..."
    if docker-compose -f "docker-compose-$ENV.yml" build backend; then
        echo -e "${GREEN}Container stopped successfully.${NC}"
    else
        echo -e "${RED}Failed to stop container.${NC}"
        exit 1
    fi

    echo "Starting a new backend container with the updated image..."
    if docker-compose -f "docker-compose-$ENV.yml" up -d backend; then
        echo -e "${GREEN}Container started successfully!${NC}"
    else
        echo -e "${RED}Failed to start container.${NC}"
        exit 1
    fi
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
    if [ "$2" = "template" ]; then
        insert_db "template"
    else
        insert_db
    fi
    ;;
install)
    install
    ;;
remove_volumes)
    if [ "$2" = "dev" ] || [ "$2" = "prod" ]; then
        remove_volumes "$2"
    else
        echo -e "${YELLOW}Usage: ./devcli.sh remove_volumes {dev|prod}${NC}"
        exit 1
    fi
    ;;
create_env)
    create_env
    ;;
init)
    init
    ;;
reload_backend)
    if [ "$2" = "dev" ] || [ "$2" = "prod" ]; then
        reload_backend "$2"
    else
        echo -e "${YELLOW}Usage: ./devcli.sh reload_backend {dev|prod}${NC}"
        exit 1
    fi
    ;;
*)
    echo -e "${YELLOW}Usage: ./devcli.sh {start|stop|insert_db|install|remove_volumes|create_env|init|reload_backend} {dev|prod}${NC}"
    exit 1
    ;;
esac
