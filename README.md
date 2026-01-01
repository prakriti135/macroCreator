# IST Document Generator

The **IST Document Generator** is a full-stack application designed to streamline the creation, management, and compilation of **Integrated Satellite Test (IST)** documentation. It combines a user-friendly Flutter Web interface with a robust Go backend to manage data and generate high-quality PDF documents using the **Typst** typesetting system.

## 🚀 Features

*   **Web-Based Editor**: A responsive Flutter web client for easy editing of document sections (Introduction, Checkout Details, Test Details, etc.).
*   **Structured Data**: Enforces a strict document structure tailored for satellite testing requirements.
*   **Rich Content Support**: Supports Text, Rich Text, Images, Dynamic Tables, Code Blocks, and Excel file imports.
*   **PDF Generation**: Uses **Typst** to compile structured data into professional, standardized PDF documents.
*   **Offline Deployment**: Capable of being built and deployed as a self-contained offline application.
*   **Embedded Database**: Uses **Bitcask** for fast, reliable, and zero-configuration storage.

## 🛠️ Technology Stack

*   **Frontend**: Flutter (Dart)
*   **Backend**: Go (Golang)
*   **Database**: Bitcask
*   **PDF Compiler**: Typst
*   **Communication**: REST API (JSON)

## 📋 Prerequisites

Before building or running the project, ensure you have the following installed:

1.  **Go**: Version 1.25 or later.
2.  **Flutter SDK**: Version 3.10.4 or later.
3.  **Typst CLI**: The `typst` executable must be in your system PATH for PDF generation to work.
    *   [Install Typst](https://github.com/typst/typst)

## 🏗️ Installation & Setup

The project includes a `Makefile` to simplify the build process for both the client and the server.

### 1. Build the Application

To build both the Flutter web client and the Go server binary, run:

```bash
make build
```

This command will:
1.  Build the Flutter web application (`client/`) in release mode.
2.  Copy the web assets to the server's static directory (`server/web/`).
3.  Compile the Go server (`server/`) and embed the version information.
4.  Produce a binary named `istDocument-server` in the root directory.

### 2. Clean Build Artifacts

To clean up generated files and build artifacts:

```bash
make clean
```

## ▶️ Usage

### Running the Server

After building, you can start the server directly:

```bash
./istDocument-server
```

By default, the server will start and serve the web application.

### Configuration

The server configuration (e.g., port, database path) is managed via `config/config.json`. The server expects this file to exist or can be pointed to a specific config file using flags (check `server/main.go` or run `./istDocument-server --help` if implemented).

### Generating Documents

1.  Open your browser and navigate to the server address (e.g., `http://localhost:8080`).
2.  Create a new document or select an existing one.
3.  Fill in the details for **Introduction**, **Checkout**, and **Test Details**.
4.  Use the **Generate PDF** button in the sidebar to compile and download the final PDF.

## 📂 Project Structure

*   `client/`: Flutter web application source code.
*   `server/`: Go server source code.
    *   `client/`: API Handlers (REST).
    *   `database/`: Bitcask storage logic and data models.
    *   `typst/`: Logic to convert data models into Typst markup and compile PDFs.
*   `interface/`: (Legacy) Protobuf definitions (currently unused).
*   `DESIGN.md`: Detailed design documentation.
# macroCreator
