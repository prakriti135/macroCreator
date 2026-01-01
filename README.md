# Macro Creator

Macro Creator is a powerful tool designed to streamline the creation and management of macros and datasets. It features a Go-based backend server and a Flutter-based client application, enabling seamless interaction and data handling.

## Features

-   **Macro Creation**: Easily create and configure macros.
-   **Dataset Management**: Efficiently manage and organize datasets.
-   **Client-Server Architecture**: A robust backend supports a responsive frontend.

## Architecture

The project is built on a client-server model:

-   **Backend**: A Go-based server that handles data processing and storage. It exposes a set of API endpoints for client communication.
-   **Frontend**: A Flutter application that provides a user-friendly interface for interacting with the server.

## Getting Started

To get the project up and running, follow these steps:

### Prerequisites

-   Go
-   Flutter
-   Make

### Backend Setup

1.  **Navigate to the project directory**:
    `cd macro-creator`
2.  **Build the server**:
    `make server-build`
3.  **Run the server**:
    `./macro-server`

### Frontend Setup

1.  **Navigate to the client directory**:
    `cd macroclient`
2.  **Build the client**:
    `make client-build`

## API Endpoints

The server exposes the following endpoints:

-   `POST /saveCSVFiles`: Loads CSV files.
-   `POST /register`: Registers a new client.
-   `POST /getMacroDetails`: Retrieves macro information.
-   `POST /saveMacroDetails`: Saves macro information.
-   `POST /saveParameterValue`: Saves a single parameter value.
-   `POST /saveParameterValues`: Saves multiple parameter values.
-   `POST /getTCDatabase`: Retrieves the TC database.
-   `POST /getValue`: Retrieves a single value.
-   `POST /getMultipleValues`: Retrieves multiple values.
-   `POST /saveMacros`: Saves macro information.
-   `POST /getMacros`: Retrieves macro information.
-   `POST /saveDatasetDetails`: Saves dataset information.
-   `POST /getDatasets`: Retrieves dataset information.
-   `POST /getCompletedMacros`: Retrieves completed macros.

## Folder Structure

    .
    ├── Makefile
    ├── README.md
    ├── config.json
    ├── db
    ├── dbGenerated
    ├── go.mod
    ├── go.sum
    ├── macroclient
    ├── main.go
    ├── server
    ├── sqlc
    └── utils
