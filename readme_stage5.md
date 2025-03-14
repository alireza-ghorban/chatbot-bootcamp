Below is a rewritten and modified version of your text file in Markdown format, suitable for inclusion in the Stage 5 README file of your repository. I’ve organized it into sections, added clarity, corrected typos, improved instructions, and ensured consistency with the Stage 4 codebase (e.g., database schema and port settings). I’ve also incorporated best practices for readability and deployment guidance.

---

# SDA Bootcamp Project - Stage 5: Deploying the Chatbot on an Azure VM

## Overview
This stage involves deploying the RAG Chatbot with Chat History (from Stage 4) onto an Azure Virtual Machine (VM). The process includes setting up the VM environment with Miniconda, PostgreSQL, and the project dependencies, cloning the repository, configuring the environment, and running the application with Chroma, FastAPI, and Streamlit. Version control steps are included to manage changes and create a pull request.

## Prerequisites
- An Azure account with permissions to create and manage VMs.
- A public-private SSH key pair (e.g., `stage5-vm_key.pem`) for VM access.
- The `.env` file from your WSL environment containing `OPENAI_API_KEY` and PostgreSQL credentials.

## Step-by-Step Instructions

### 1. Create and Configure the Azure VM
Run the following bash script to set up the VM environment:
```bash
#!/bin/bash

# Update package list and install required tools
sudo apt update
sudo apt install -y gnupg2 wget

# Install Miniconda for the azureuser
sudo -u azureuser mkdir -p /home/azureuser/miniconda3
sudo -u azureuser wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /home/azureuser/miniconda3/miniconda.sh
sudo -u azureuser bash /home/azureuser/miniconda3/miniconda.sh -b -u -p /home/azureuser/miniconda3
sudo -u azureuser rm /home/azureuser/miniconda3/miniconda.sh

# Add Miniconda to PATH
echo 'export PATH="/home/azureuser/miniconda3/bin:$PATH"' | sudo -u azureuser tee -a /home/azureuser/.bashrc

# Install PostgreSQL 16
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
sudo apt update
sudo apt install -y postgresql-16 postgresql-contrib-16 postgresql-client-16

# Start and enable PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 2. Connect to the VM via SSH
- Use VS Code’s SSH extension to connect to the VM using the private key (e.g., `stage5-vm_key.pem`).
- If connection fails due to permissions:
  - On Windows, run PowerShell as Administrator and adjust permissions:
    ```powershell
    icacls.exe "C:\Users\YourUsername\Downloads\stage5-vm_key.pem" /inheritance:r /grant:r "$($env:USERNAME):(R)"
    ```
  - Replace `YourUsername` with your actual Windows username.

### 3. Configure the Shell Environment
- Edit the `.bashrc` file to activate Miniconda automatically:
  ```bash
  nano /home/azureuser/.bashrc
  ```
- Add the following line at the end of the file:
  ```bash
  source ~/miniconda3/bin/activate
  ```
- Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`), then reload the shell:
  ```bash
  source /home/azureuser/.bashrc
  ```

### 4. Set Up the Conda Environment
- Create a new Conda environment with Python 3.11:
  ```bash
  conda create -n stage5 python=3.11
  ```
- Activate the environment:
  ```bash
  conda activate stage5
  ```

### 5. Clone the Repository
- Clone the Stage 4 repository (replace `stage-4-link` with the actual GitHub URL):
  ```bash
  git clone stage-4-link
  ```
- Navigate to the project directory:
  ```bash
  cd chatbot_project
  ```

### 6. Install Project Dependencies
- Install the required packages:
  ```bash
  pip install -r requirements.txt
  ```

### 7. Create a New Git Branch
- Create and switch to a new branch for Stage 5:
  ```bash
  git checkout -b stage-5
  ```

### 8. Configure Environment Variables
- Create a `.env` file in the `chatbot_project` directory:
  ```bash
  nano .env
  ```
- Copy the contents of your WSL `.env` file (containing `OPENAI_API_KEY`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`) and paste them here. Example:
  ```
  OPENAI_API_KEY=your-openai-api-key
  DB_NAME=your-db-name
  DB_USER=your-db-user
  DB_PASSWORD=your-db-password
  DB_HOST=localhost
  DB_PORT=5432
  ```
- Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

### 9. Set Up the PostgreSQL Database
- Access the PostgreSQL prompt as the `postgres` user:
  ```bash
  sudo -u postgres psql
  ```
- Change the `postgres` user password:
  ```sql
  ALTER USER postgres PASSWORD 'weclouddata';
  ```
- Create a new database:
  ```sql
  CREATE DATABASE project;
  ```
- Connect to the `project` database:
  ```sql
  \c project
  ```
- Create the `advanced_chats` table:
  ```sql
  CREATE TABLE IF NOT EXISTS advanced_chats (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      file_path TEXT NOT NULL,
      last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      pdf_path TEXT,
      pdf_name TEXT,
      pdf_uuid TEXT
  );
  ```
- Exit the PostgreSQL prompt:
  ```sql
  \q
  ```

### 10. Run the Application Services
Open three separate terminal sessions on the VM and activate the Conda environment in each.

#### Session 1: Start Chroma
- Activate the environment:
  ```bash
  conda activate stage5
  ```
- Navigate to the project directory:
  ```bash
  cd /home/azureuser/chatbot_project
  ```
- Run Chroma (will use port 8000):
  ```bash
  chroma run --path /home/azureuser/chatbot_project/chroma_db/
  ```

#### Session 2: Start FastAPI Backend
- Activate the environment:
  ```bash
  conda activate stage5
  ```
- Navigate to the project directory:
  ```bash
  cd /home/azureuser/chatbot_project
  ```
- Run the FastAPI server (will use port 5000):
  ```bash
  uvicorn backend:app --reload --port 5000
  ```

#### Session 3: Start Streamlit Frontend
- Activate the environment:
  ```bash
  conda activate stage5
  ```
- Navigate to the project directory:
  ```bash
  cd /home/azureuser/chatbot_project
  ```
- Run the Streamlit app (will use port 8501):
  ```bash
  streamlit run chatbot.py
  ```

### 11. Configure Azure VM Networking
- In the Azure Portal:
  - Navigate to the VM’s "Networking" settings.
  - Add inbound security rules for ports 8000, 5000, and 8501:
    - **Source**: Your IP address (e.g., "My IP Address").
    - **Destination Port Ranges**: 8000, 5000, 8501.
    - **Protocol**: TCP.
    - **Action**: Allow.
  - Save the rules.

### 12. Commit and Push Changes
- After verifying the application runs successfully:
  - Check the status:
    ```bash
    git status
    ```
  - Stage all changes:
    ```bash
    git add .
    ```
  - Commit with a meaningful message:
    ```bash
    git commit -m "Deployed Stage 5 chatbot on Azure VM with Chroma, FastAPI, and Streamlit"
    ```
  - Push to the remote branch:
    ```bash
    git push origin stage-5
    ```

### 13. Create a Pull Request
- Go to your GitHub repository.
- Create a pull request from `stage-5` to `main`.

### 14. Sync Local Main Branch
- In VS Code (or locally):
  - Switch to the `main` branch:
    ```bash
    git checkout main
    ```
  - Pull the latest changes:
    ```bash
    git pull
    ```

## Troubleshooting
- **Raw HTML Response**: If the chatbot displays HTML instead of text, ensure the FastAPI server is running on port 5000 and that inbound rules are correctly configured. Check for port conflicts with `sudo netstat -tuln | grep 5000` and adjust if necessary.
- **Connection Issues**: Verify the VM’s public IP and SSH key permissions.
- **Dependency Errors**: Ensure all packages in `requirements.txt` are installed in the `stage5` Conda environment.

## Additional Notes
- Replace `stage-5-link` with the actual GitHub repository URL.
- Ensure the VM has sufficient resources (e.g., 2 vCPUs, 4 GB RAM) to run Chroma, FastAPI, and Streamlit concurrently.
- The `.env` file should be added to `.gitignore` to avoid exposing sensitive credentials.

