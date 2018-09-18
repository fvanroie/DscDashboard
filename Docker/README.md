# DSC Dashboard Dockerfile

[Docker](http://docker.com) container to use [DscDashboard](https://github.com/fvanroie/DscDashboard).

## Description

This [Docker](http://docker.com) container hosts the [DscDashboard](https://github.com/fvanroie/DscDashboard) and all of its dependencies.
It can be used to quickly test the DSC Dashboard in your environment.

The container has these packages installed:
- Ubuntu 18.04 LTS
- PowerShell 6.1.0
    - DscDashboard module
    - UniversalDashboard.Community module
- ODBC Driver for SQL Server

## Usage

### Install

Build `dscdashboard` from source:

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

## Disclaimer

You can also set the `DSC_SQL` environment variable inside the Dockerfile and rebuild the image.

> This container is provided for proof-of-concept purposes only.
> If you want to run the DSC dashboard in a production environment
> consider using IIS with Domain authentication and https binding.
>
> The information in the DSC database should be regarded as extrememy sensitive because it contains
> the configurations of your environment!

## Services

Service     | Port | Usage
------------|------|------
DscDashboard|   80 | When using `dscdashboard run`, visit `http://localhost:8080` in your browser.


## Volumes

Volume          | Description
----------------|-------------
none            | No volumes are required
