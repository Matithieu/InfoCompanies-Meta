import requests
import os
import time
import logging

logging.basicConfig(level=logging.INFO)

KEYCLOAK_URL = os.getenv('KEYCLOAK_URL', 'http://keycloak:8180')
REALM = os.getenv('KEYCLOAK_REALM', 'infoCompanies')
CLIENT_ID = os.getenv('OAUTH2_PROXY_CLIENT_ID', 'spring-ba-infocompanies')
ADMIN_USERNAME = os.getenv('KEYCLOAK_ADMIN', 'admin')
ADMIN_PASSWORD = os.getenv('KEYCLOAK_ADMIN_PASSWORD', 'password')
ENV_FILE_PATH = '/app/.env'  # Path to the .env file at the root of the Docker Compose project

def get_access_token():
    url = f"{KEYCLOAK_URL}/realms/{REALM}/protocol/openid-connect/token"
    data = {
        'client_id': 'admin-cli',
        'username': ADMIN_USERNAME,
        'password': ADMIN_PASSWORD,
        'grant_type': 'password'
    }
    response = requests.post(url, data=data)
    response.raise_for_status()
    return response.json()['access_token']

def get_client_secret(access_token):
    url = f"{KEYCLOAK_URL}/admin/realms/{REALM}/clients"
    headers = {
        'Authorization': f"Bearer {access_token}"
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    clients = response.json()
    client = next(client for client in clients if client['clientId'] == CLIENT_ID)
    client_id = client['id']

    url = f"{KEYCLOAK_URL}/admin/realms/{REALM}/clients/{client_id}/client-secret"
    response = requests.post(url, headers=headers)
    response.raise_for_status()
    return response.json()['value']

def update_env_file(client_secret):
    logging.info(f"Updating .env file at {ENV_FILE_PATH} with client secret.")
    with open(ENV_FILE_PATH, 'r') as f:
        lines = f.readlines()
        logging.info("Current content of .env file:")
        for line in lines:
            logging.info(line.strip())
    found = False
    with open(ENV_FILE_PATH, 'w') as f:
        for line in lines:
            if line.startswith('OAUTH2_PROXY_CLIENT_SECRET='):
                f.write(f"OAUTH2_PROXY_CLIENT_SECRET={client_secret}\n")
                found = True
            else:
                f.write(line)
        if not found:
            # Append the client secret line at the end of the file
            f.write(f"OAUTH2_PROXY_CLIENT_SECRET={client_secret}\n")
    logging.info("Updated .env file successfully.")

def main():
    max_retries = 2
    for attempt in range(max_retries):
        try:
            logging.info("Fetching access token.")
            access_token = get_access_token()
            logging.info("Fetching client secret.")
            client_secret = get_client_secret(access_token)
            update_env_file(client_secret)
            return
        except requests.RequestException as e:
            logging.error(f"Error fetching client secret: {e}, attempt {attempt + 1} of {max_retries}")
            time.sleep(10)  # Adding delay before retry
    raise Exception("Failed to fetch client secret after several attempts")

if __name__ == "__main__":
    main()

