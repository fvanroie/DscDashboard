# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#   Docker image file that describes an Ubuntu 18.04 base image with PowerShell 6.1.0.
#   SQL Server ODBC Driver (and optional MS-SQL tools) are installed from the Microsoft Repos.
#
#   PowerShel Modules UniversalDashboard.Community and DscDashboard are added for the
#   Web Frontend and Backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

FROM mcr.microsoft.com/powershell:6.1.0-ubuntu-18.04

ARG VERSION=0.0.1
ARG IMAGE_NAME=dscdashboard:${VERSION}

LABEL maintainer="NetwiZe.be" \
      readme.md="https://github.com/fvanroie/DscDashboard/blob/master/README.md" \
      description="This Dockerfile will build an image for hosting a DscDashboard instance." \
      org.label-schema.vcs-url="https://github.com/fvanroie/DscDashboard/" \
      org.label-schema.name="dscdashboard" \
      org.label-schema.vendor="NetwiZe.be" \
      org.label-schema.version=${VERSION} \
      org.label-schema.docker.cmd.devel="docker run --rm -it -p 80:80 ${IMAGE_NAME} -c pwsh" \
      org.label-schema.docker.cmd="docker run -p 80:80 ${IMAGE_NAME}"

# Set ConnectionString Environment Variable, needed for the ODBC connection to SQL Server!
ENV DSC_SQL "Server={0}; UID={1}; PWD={2}"

# Suppress dialog warning from msodbcsql17 and mssql-tools because we are running unattended
ENV DEBIAN_FRONTEND noninteractive

# a. Install msodbcsql17 and unixodbc (optionally add mssql-tools if it is needed)
# b. Create ODBC DSN file
# c. Create the Module path
# d. Download 2 modules from the PowerShell Gallery and check if both can be found.
# e. Create the dashboard.ps1 launcher in root
RUN apt-get update \
    && ACCEPT_EULA=Y apt-get install msodbcsql17 unixodbc -y --no-install-recommends \
    && apt-get dist-upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    \
    && echo "[DscDashboard] \
        \nDRIVER   = ODBC Driver 17 for SQL Server \
        \nDATABASE = DSC \
        \nTrustServerCertificate = yes \
        \nEncrypt  = yes \
    " > /etc/odbc.ini \
    \
    && mkdir -p "/usr/local/share/powershell/Modules/" \
    \
    && pwsh -c ' \
        $ProgressPreference = "SilentlyContinue"; \
        \
        Find-Module "DscDashboard" -Min 0.0.2 | \
             Save-Module -Path "/usr/local/share/powershell/Modules/" -Verbose; \
        \
        Find-Module "UniversalDashboard.Community" -Min 2.0.1 | \
             Save-Module -Path "/usr/local/share/powershell/Modules/" -AcceptLicense -Verbose; \
        \
        If ((Get-Module "DscDashboard","UniversalDashboard.Community" -List).Count -ne 2) { \
            Throw "Failed to download the required Modules!" \
        }; \
        $dashboard = (Get-Module -ListAvailable "DscDashboard").Path | \
            Split-Path -Parent | \
            Join-Path -ChildPath "dashboard.ps1"; \
        \
        Set-Content -Path "/dashboard.ps1" -Value "& $dashboard"; \
    '

EXPOSE 80

# The container will run the dashboard.ps1 file
ENTRYPOINT [ "pwsh" ]
CMD [ "dashboard.ps1" ]