# DSC Dashboard Dockerfile

## Description

This [Docker](http://docker.com) container hosts the [DscDashboard](https://github.com/fvanroie/DscDashboard) module and all of its dependencies.
It can be used to quickly test the DSC Dashboard in your environment. The following packages are isntalled:
- Ubuntu 18.04 LTS
- PowerShell 6.1.0
    - [DscDashboard](https://github.com/fvanroie/DscDashboard) module
    - [UniversalDashboard.Community](http://poshud.com) module
- ODBC Driver for SQL Server

#### Disclaimer

> *This container is provided for proof-of-concept for testing purposes only.
> If you want to run the DSC dashboard in a production environment
> consider using [IIS with Domain authentication and https binding](#).*
>
> *The information in the DSC database should be regarded as extremely sensitive because it contains
> the configurations of your environment!*


## Usage

### Installation

To build `dscdashboard` from source:

    git clone https://github.com/fvanroie/DscDashboard.git
    cd DscDashboard
    sudo docker build -t dscdashboard -f Docker/Dockerfile .

If the build succeeded, you will see:

    Successfully built <imageid>
    Successfully tagged dscdashboard:latest

### Run

Run the image, binding associated ports and SQL Server connection string:

    docker run -p 8080:80 --env DSC_SQL='SERVER=<hostname>; Uid=<user>; Pwd=<password>' dscdashboard

Change the `<hostname>`, `<readuser>` and `<password>` in the `DSC_SQL` to the appropriate values to
connect to the DSC database on the SQL Server. This should be a temporary *read-only* account on the DSC database
for testing purposes.

The DSC Dashboard module only uses SELECT queries and does not modify the database.

You can also set the `DSC_SQL` environment variable inside the Dockerfile and rebuild the image.


### Services

Service     | Port | Usage
------------|------|------
DscDashboard|   80 | When using `dscdashboard run`, visit `http://localhost:8080` in your browser.


### Volumes

Volume          | Description
----------------|-------------
none            | No volumes are required
