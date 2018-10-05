# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Docker image file that describes an Ubuntu 18.04 image with PowerShell 6.1.0, SQL Server ODBC Driver and MS-SQL tools
# installed from Microsoft APT Repo
#
# PowerShel Modules UniversalDashboard.Community and DscDashboard are then added for the Web Frontend and Backend
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# The powershell:6.1.0-ubuntu-18.04 base image also supports Microsoft ODBC Driver 17 for SQL Server install via apt
FROM mcr.microsoft.com/powershell:6.1.0-ubuntu-18.04

ARG VERSION=0.0.1
ARG IMAGE_NAME=dscdashboard:${VERSION}

LABEL maintainer="NetwiZe.be" \
      readme.md="https://github.com/fvanroie/DscDashboard/blob/master/README.md" \
      description="This Dockerfile will an image for hosting DscDashboard." \
      org.label-schema.vcs-url="https://github.com/fvanroie/DscDashboard/" \
      org.label-schema.name="dscdashboard" \
      org.label-schema.vendor="NetwiZe.be" \
      org.label-schema.version=${VERSION} \
      org.label-schema.docker.cmd.devel="docker run ${IMAGE_NAME} pwsh" \
      org.label-schema.docker.cmd="docker run ${IMAGE_NAME}"

#      org.label-schema.vcs-ref=${VCS_REF} \
#      org.label-schema.schema-version="1.0" \
#      org.label-schema.usage="https://github.com/PowerShell/PowerShell/tree/master/docker#run-the-docker-image-you-built" \
#      org.label-schema.url="https://github.com/PowerShell/PowerShell/blob/master/docker/README.md" \
#      org.label-schema.docker.cmd.test="docker run ${IMAGE_NAME} pwsh" \
#      org.label-schema.docker.cmd.help="docker run ${IMAGE_NAME} pwsh --help"

# Suppress Dialog warning from msodbcsql17 and mssql-tools packages because we are running unattended
ENV DEBIAN_FRONTEND noninteractive

# Install msodbcsql17 unixodbc (optionally add mssql-tools if needed)
RUN apt-get update \
    && ACCEPT_EULA=Y apt-get install msodbcsql17 unixodbc -y --no-install-recommends \
    && apt-get dist-upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy local PowerShell DscDashboard Module into the image
#COPY DscDashboard /usr/local/share/powershell/Modules/DscDashboard

# Set Environment Variables
ENV DSC_SQL "Server={0}; UID={1}; PWD={2}"

# Create ODBC DSN
RUN echo "[DscDashboard] \
        \nDRIVER   = ODBC Driver 17 for SQL Server \
        \nDATABASE = DSC \
        \nTrustServerCertificate = yes \
        \nEncrypt  = yes \
    " > /etc/odbc.ini \
    \
    && echo "Download UniversalDashboard.Community from the PowerShell Gallery and check the 2 modules can be found" \
    && pwsh -c ' \
        $ProgressPreference = "SilentlyContinue"; \
        \
        Find-Module "DscDashboard" -Min 0.0.1 | \
        Save-Module -Path "/usr/local/share/powershell/Modules/" -AcceptLicense -Verbose; \
        \
        Find-Module "UniversalDashboard.Community" -Min 2.0.1 | \
        Save-Module -Path "/usr/local/share/powershell/Modules/" -AcceptLicense -Verbose; \
        \
        If ((Get-Module "DscDashboard","UniversalDashboard.Community" -List).Count -ne 2) { \
            Throw "Required Modules not available!" \
        } \
    ' \
    && echo '& /usr/local/share/powershell/Modules/DscDashboard/dashboard.ps1' > /dashboard.ps1

EXPOSE 80

# The container will run the dashboard.ps1 file
ENTRYPOINT [ "pwsh" ]
CMD [ "dashboard.ps1" ]