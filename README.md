# InfoCompanies Project

This project is a collection of services and tools to manage company information. It includes several sub-projects, each with a specific role.

## Installation

1. Clone the repository:

   ```sh
    git clone https://github.com/Matithieu/InfoCompanies-Meta.git
   ```

   Clone the other repos:

   ```
   ./devcli install
   ```

2. Configure the environment variables:
   Copy the file [`template.env`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2FUsers%2Fmathieu.yahiaamar%2FPerso%2FInfoCompanies-Meta%2Ftemplate.env%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%2C%22e267c601-5969-4b5b-9edb-ade0a8d97d9e%22%5D '/Users/mathieu.yahiaamar/Perso/InfoCompanies-Meta/template.env') to [`.env`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2FUsers%2Fmathieu.yahiaamar%2FPerso%2FInfoCompanies-Meta%2F.env%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%2C%22e267c601-5969-4b5b-9edb-ade0a8d97d9e%22%5D '/Users/mathieu.yahiaamar/Perso/InfoCompanies-Meta/.env') and modify the values as needed.

3. Install the dependencies for end-to-end tests:
   ```sh
   cd e2e
   pnpm install
   ```

## Usage

### Start the services

To start the services in development mode:

```sh
./devcli.sh start dev
```

To start the services in production mode:

```sh
./devcli.sh start prod
```

### Other useful commands

- Stop the services:

  ```sh
  ./devcli.sh stop {dev|prod}
  ```

- Insert data into the database:

  ```sh
  ./devcli.sh insert_db {template}
  ```

- Install repositories or update them:

  ```sh
  ./devcli.sh install
  ```

- Remove Docker volumes:

  ```sh
  ./devcli.sh remove_volumes {dev|prod}
  ```

- Create an environment on all repositories:

  ```sh
  ./devcli.sh create_env
  ```

- Initialize certificates for production mode (Modify Nginx and DNS server config):

  ```sh
  ./devcli.sh init
  ```

- Generate certificates (for development mode):

  ```sh
  ./devcli.sh generate_certificates
  ```

- Reload a service:
  ```sh
  ./devcli.sh reload {dev|prod} {service_name}
  ```

## Configuration

### Nginx

The Nginx configuration file is located at [`config/nginx/setup.conf`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2FUsers%2Fmathieu.yahiaamar%2FPerso%2FInfoCompanies-Meta%2Fconfig%2Fnginx%2Fsetup.conf%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%2C%22e267c601-5969-4b5b-9edb-ade0a8d97d9e%22%5D '/Users/mathieu.yahiaamar/Perso/InfoCompanies-Meta/config/nginx/setup.conf').

### End-to-end test environment

The configurations for end-to-end tests are located at [`e2e/src/config/env.config.ts`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2FUsers%2Fmathieu.yahiaamar%2FPerso%2FInfoCompanies-Meta%2Fe2e%2Fsrc%2Fconfig%2Fenv.config.ts%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%2C%22e267c601-5969-4b5b-9edb-ade0a8d97d9e%22%5D '/Users/mathieu.yahiaamar/Perso/InfoCompanies-Meta/e2e/src/config/env.config.ts').

## Contribution

Contributions are welcome. Please submit a pull request for any changes.

## License

This project is licensed under .

```

```
