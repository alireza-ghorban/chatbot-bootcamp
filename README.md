# chatbot-bootcamp
This is my chatbot project
we have the stage-1 and stage-2
fix issues for stage-3:

# 📌 Troubleshooting PostgreSQL Issues in WSL for Bootcamp Students

**Author:** Alireza  
**Purpose:** A guide to resolve common PostgreSQL connection issues and database setup when working with **WSL (Ubuntu) and pgAdmin (Windows).**  

---

## **1️⃣ Fixing PostgreSQL Connection Issues**

### **❌ Problem**
- When running `uvicorn backend:app --reload`, you see:
  ```
  psycopg2.OperationalError: connection to server at "localhost" (127.0.0.1), port 5432 failed: Connection refused
  ```
- Or, when trying to log in with `psql`, you get:
  ```
  FATAL: password authentication failed for user "postgres"
  ```

### **✅ Solution: Ensure PostgreSQL Uses Password Authentication**

#### **Step 1: Edit `pg_hba.conf`**
Open the authentication configuration file in WSL:

```sh
sudo nano /etc/postgresql/14/main/pg_hba.conf
```
*(If this path does not exist, replace `14` with your PostgreSQL version.)*

Find these lines at the bottom:

```sql
local   all             postgres                                peer
host    all             all             127.0.0.1/32            scram-sha-256
```

Change **`peer` to `md5`** or **`scram-sha-256`**:

```sql
local   all             postgres                                md5
host    all             all             127.0.0.1/32            md5
```

Save the file (**CTRL + X**, then **Y**, then **Enter**).

#### **Step 2: Restart PostgreSQL**
```sh
sudo service postgresql restart
```

#### **Step 3: Try Logging in Again**
Now, try logging in to the PostgreSQL database:

```sh
psql -U postgres -h localhost -d project
```
If that does not work, try:

```sh
psql -U postgres -h 127.0.0.1 -d project
```

---

## **2️⃣ Checking the Database and Stored Chats**

### **❌ Problem**
- You want to verify whether chat history is stored in the `project` database.

### **✅ Solution: Check the Database**

#### **Step 1: Connect to the `project` Database**
```sh
psql -U postgres -h localhost -d project
```
If successful, you’ll see:
```
project=#
```

#### **Step 2: Check If the `chats` Table Exists**
```sql
\dt
```
If `chats` is listed, the table exists.

#### **Step 3: View the Table Schema**
```sql
\d chats
```
This will display the **columns** and **data types**.

#### **Step 4: Retrieve All Stored Chats**
```sql
SELECT * FROM chats;
```
If there is data, it will display stored chats.

#### **Step 5: Check for a Specific Chat**
If you want to see a **specific chat**, filter by `id`:
```sql
SELECT * FROM chats WHERE id = 'your_chat_id';
```

#### **Step 6: Exit PostgreSQL**
```sql
\q
```

---

## **📌 Summary**

| Issue | Fix |
|-------|-----|
| `Connection refused` | Update `pg_hba.conf`, restart PostgreSQL |
| `password authentication failed` | Set `md5` authentication and restart PostgreSQL |
| `project` database does not exist | Create it using `CREATE DATABASE project;` |
| Verify stored chat data | Use `SELECT * FROM chats;` inside PostgreSQL |

✅ **Now, you have a fully working PostgreSQL setup for WSL and FastAPI!** 🚀

