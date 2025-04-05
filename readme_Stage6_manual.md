# Stage-6 Manual

1.  **Create Azure PostgreSQL:**
    *   Admin user login: `alireza`
    *   Password: `*****`

    1. **Create `appdb` database from Azure portal**
    2. **Connect to the db via DBeaver**

    3.  **Create `appuser` with DBeaver:**

        ```sql
        CREATE USER appuser WITH ENCRYPTED PASSWORD 'appuser';
        GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;
        GRANT ALL PRIVILEGES ON SCHEMA public TO appuser;
        ```

    4.  **Connect with `appuser` and create `advanced_chats` table:**

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

2.  **Create Azure Storage account, and container and save SAS URL.**

3.  **Create a VM and connect to it:**
    *   Use Conda.
    *   Create a virtual environment.
    *   Clone a Git repo or create a project folder.

4.  **Create Project Files and Folders:**
    *   `.env`
    *   `chatbot.py`
    *   `backend.py`
    *   `/chat_logs`
    *   `/chromadb`
    *   `/pdf_store`

    **Contents of `.env` file:**

    ```
    OPENAI_API_KEY=***
    DB_NAME=appdb
    DB_USER=appuser
    DB_PASSWORD=appuser
    DB_HOST=stage6-chatbotproject.postgres.database.azure.com
    DB_PORT=5432
    AZURE_STORAGE_SAS_URL=***
    AZURE_STORAGE_CONTAINER=stage6
    CHROMADB_HOST=localhost
    CHROMADB_PORT=8000
    ```

5.  **`requirements.txt`** (Make sure this file exists and contains necessary packages)

6.  **Activate and Install:**
    *   Activate the Conda environment `myenv2`:  `conda activate myenv2`
    *   Install the requirements: `pip install -r requirements.txt`
    *   Restart ChromaDB, backend, and frontend services.
    *   Check the status of the services.

7.  **Create and Run Systemd Services:**

    **4.5 Create Systemd Services**

    *   **ChromaDB Service (`/etc/systemd/system/chromadb.service`):**

        ```bash
        cat <<EOF | sudo tee /etc/systemd/system/chromadb.service
        [Unit]
        Description=ChromaDB
        After=network.target

        [Service]
        Type=simple
        User=azureuser
        WorkingDirectory=/home/azureuser/chatbot-bootcampt
        ExecStart=/home/azureuser/miniconda3/envs/stage6/bin/chroma run --path /home/azureuser/chatbot-bootcamp/mydata
        Restart=always

        [Install]
        WantedBy=multi-user.target
        EOF
        ```

    *   **Backend Service (`/etc/systemd/system/backend.service`):**

        ```bash
        cat <<EOF | sudo tee /etc/systemd/system/backend.service
        [Unit]
        Description=backend
        After=network.target

        [Service]
        Type=simple
        User=azureuser
        WorkingDirectory=/home/azureuser/chatbot-bootcamp
        ExecStart=/home/azureuser/miniconda3/envs/stage6/bin/uvicorn backend:app --reload --port 5000
        Restart=always

        [Install]
        WantedBy=multi-user.target
        EOF
        ```

    *   **Frontend Service (`/etc/systemd/system/frontend.service`):**

        ```bash
        cat <<EOF | sudo tee /etc/systemd/system/frontend.service
        [Unit]
        Description=Streamlit
        After=network.target

        [Service]
        Type=simple
        User=azureuser
        WorkingDirectory=/home/azureuser/chatbot-bootcamp
        ExecStart=/home/azureuser/miniconda3/envs/stage6/bin/streamlit run chatbot.py
        Restart=always

        [Install]
        WantedBy=multi-user.target
        EOF
        ```

    *   **Reload Systemd, Enable, and Start Services:**

        ```bash
        sudo systemctl daemon-reload
        sudo systemctl enable chromadb && sudo systemctl start chromadb
        sudo systemctl enable backend && sudo systemctl start backend
        sudo systemctl enable frontend && sudo systemctl start frontend
        ```

    *   **Check Service Status:**

        ```bash
        sudo systemctl status chromadb
        sudo systemctl status backend
        sudo systemctl status frontend
        ```

**Important:** Make sure you have the correct folder addresses in the service files.  Adjust the `WorkingDirectory` and `ExecStart` paths to match your actual project setup.
