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

```bash
git clone https://github.com/fvanroie/DscDashboard.git
cd DscDashboard
sudo docker build -t dscdashboard -f Docker/Dockerfile .
```

If the build succeeded, you will see:

    Successfully built <imageid>
    Successfully tagged dscdashboard:latest


### Test

Test the newly built image, bind associated public port and provide a SQL Server connection string:

```bash
docker run -rm -p 8080:80 -e DSC_SQL='SERVER=<hostname>; Uid=<user>; Pwd=<password>' --name dsc dscdashboard
```

Change the `<hostname>`, `<user>` and `<password>` in the `DSC_SQL` argument to the appropriate values to
connect to the DSC database on the SQL Server. This should be a temporary *read-only* account on the DSC database
for testing purposes.

You can also set the `DSC_SQL` environment variable by editing the Dockerfile and rebuilding the image.


After a little while you should see this message:

    Now listening on: http://0.0.0.0:80
    Application started. Press Ctrl+C to shut down.

Browse to the http://<ipaddress:port> to test the DSC Dashboard. Press Ctrl-C to stop the website and exit the container when done testing.

![Dashboard](../docs/images/dashboard.png)

### Run

To run the container in the background:

```bash
docker run -d -p 8080:80 -e DSC_SQL='SERVER=<hostname>; Uid=<user>; Pwd=<password>' --name dsc dscdashboard
```


### Debug

You can troubleshoot or debug the containter with the following command:

```bash
docker run -it -p 8080:80 --name dsc dscdashboard -c pwsh -noexit -interactive
```

This will give you an interactive PowerShell prompt. Type `exit` to stop the container session.


### Services

Service     | Port | Usage
------------|------|------
DscDashboard|   80 | Use `dscdashboard run` and visit `http://localhost:8080` in your browser.


### Volumes

Volume          | Description
----------------|-------------
none            | No volumes are required
