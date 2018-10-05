# Installation

DSC Dashboard can be hosted either on the DSC Pull Server or another IIS webserver. IIS is the prefered
way of hosting the DSC Dashboard in a domain environment as it allows for integrated security.

Alternatively there is a [Docker](../Docker) container that has all the components installed to run the
DSC Dashboard and connect to a SQL Server hosting the DSC database.

## Installation Options

1. [On Windows IIS](Installation_IIS.md):
    - [DSC Configuration](Installation_IIS.md#dsc-configuration)
    - [Manual setup](Installation_IIS.md#manual-steps)

2. [Docker container](Docker.md)

## Configuration

- A System DSN named DSC_SQL is used to connect to the DSC SQL Server database