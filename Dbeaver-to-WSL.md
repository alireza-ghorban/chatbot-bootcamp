# 📌 Connecting DBeaver (Windows) to PostgreSQL in WSL

**Author:** Alireza  
**Purpose:** A guide to connect **DBeaver (Windows)** to **PostgreSQL running inside WSL (Ubuntu).**  

---

## **1️⃣ Problem: DBeaver Cannot Connect to WSL PostgreSQL**
### **❌ Error Message:**
```
Connection refused: getsockopt
```

This happens because PostgreSQL in WSL is **not listening on the correct network interface** or **Windows cannot reach it**.

---

## **2️⃣ Solution: Enable Remote Connections**

### **Step 1: Find WSL's IP Address**
Since WSL acts like a separate machine, find its **internal IP**:

```sh
ip addr show eth0 | grep "inet "
```

You’ll see output like:
```
inet 172.28.177.56/20 ...
```
Take note of the **IP address** (e.g., `172.28.177.56`).

---

### **Step 2: Allow PostgreSQL to Listen on All IPs**
Open PostgreSQL’s configuration file:

```sh
sudo nano /etc/postgresql/14/main/postgresql.conf
```
*(Replace `14` with your PostgreSQL version.)*

Find this line:
```
listen_addresses = 'localhost'
```
Change it to:
```
listen_addresses = '*'
```
Save (**CTRL + X, Y, Enter**).

---

### **Step 3: Allow Remote Connections in `pg_hba.conf`**
Open the authentication file:

```sh
sudo nano /etc/postgresql/14/main/pg_hba.conf
```
At the bottom, **add this line**:
```
host    all             all             0.0.0.0/0               md5
```
Save and exit (**CTRL + X, Y, Enter**).

Restart PostgreSQL:
```sh
sudo service postgresql restart
```

---

### **Step 4: Allow PostgreSQL Through Windows Defender Firewall**

1. Open **Windows Defender Firewall**.
2. Click **Advanced Settings**.
3. Go to **Inbound Rules** → Click **New Rule**.
4. Select **Port** → Click **Next**.
5. Choose **TCP** and enter **5432** → Click **Next**.
6. Select **Allow the Connection** → Click **Next**.
7. Apply the rule to **Private & Public Networks**.
8. Name it **PostgreSQL WSL** → Click **Finish**.

---

### **Step 5: Connect DBeaver to WSL PostgreSQL**
1. Open **DBeaver**.
2. Click **"New Database Connection"** (`Ctrl + N`).
3. Select **PostgreSQL** → Click **Next**.
4. Enter the connection details:
   - **Host**: `172.28.177.56` (your WSL IP)
   - **Port**: `5432`
   - **Database**: `project`
   - **Username**: `postgres`
   - **Password**: `123456`
5. Click **"Test Connection"**.
6. If successful, click **Finish**.

---

## **📌 Summary**

| Issue | Fix |
|-------|-----|
| `Connection refused: getsockopt` | Update `postgresql.conf`, restart PostgreSQL |
| Cannot find WSL IP | Run `ip addr show eth0 | grep "inet "` |
| `DBeaver cannot connect` | Allow remote connections in `pg_hba.conf` |
| Windows cannot reach WSL PostgreSQL | Add an inbound rule for TCP 5432 in Windows Firewall |

✅ **Now, DBeaver is successfully connected to PostgreSQL in WSL!** 🚀
