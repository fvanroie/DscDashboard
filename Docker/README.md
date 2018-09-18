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

You need to copy the UniversalDashboard.Community module into the current build directory.
The location of the directory may vary depending on your system:

    cp -r /usr/local/share/powershell/Modules/UniversalDashboard.Community ./
    sudo docker build -t dscdashboard -f Docker/Dockerfile .

If the UniversalDashboard.Community directory is missing the build will fail:

    Step 7/9: COPY UniversalDashboard.Community /usr/local/share/powershell/Modules/UniversalDashboard.Community
    COPY failed: stat /var/lib/docker/tmp/docker-builder/UniversalDashboard.Community: no such file or directory

If the build succeeded, you will see:

    Successfully built <imageid>
    Successfully tagged dscdashboard:latest

### Run

Run the image, binding associated ports and SQL Server connection string:

    docker run -p 80:80 --env DSC_CONNECTIONSTRING='SERVER=<hostname>; Uid=<user>; Pwd=<password>' dscdashboard

Change the `<hostname>`, `<readuser>` and `<password>` in the `DSC_CONNECTIONSTRING` to the appropriate values to
connect to the DSC database on the SQL Server. This should be a temporary *read-only* account on the DSC database
for testing purposes.

The DSC Dashboard module only uses SELECT queries and does not modify the database.

You can also set the `DSC_CONNECTIONSTRING` in the Dockerfile and rebuild the image.

## Services

Service     | Port | Usage
------------|------|------
DscDashboard|   80 | When using `dscdashboard run`, visit `http://localhost` in your browser.


## Volumes

Volume          | Description
----------------|-------------
`/app`          | The location of the DocPad application root.
