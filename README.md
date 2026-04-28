 
# Flask App with MySQL Docker Setup

This is a simple Flask app that interacts with a MySQL database. The app allows users to submit messages, which are then stored in the database and displayed on the frontend.

1. Launch a EC2 Instances by selecting type, security, storage And create.
   
2. Now access the instance and clonse your project from github.
   ```bash
   git clone https://github.com/Siddik2202/two-tier-flask-app.git
   ```
3. Now build your dockerfile and build and run this application.
   ```bash
   docker build -t flaskapp .
   ```
4. Now, make sure that you have created a network using following command
```bash
docker network create twotier
```

5. Attach both the containers in the same network, so that they can communicate with each other

i) MySQL container 
```bash
docker run -d \
    --name mysql \
    -v mysql-data:/var/lib/mysql \
    --network=twotier \
    -e MYSQL_DATABASE=mydb \
    -e MYSQL_ROOT_PASSWORD=admin \
    -p 3306:3306 \
    mysql:5.7

```
ii) Backend container
```bash
docker run -d \
    --name flaskapp \
    --network=twotier \
    -e MYSQL_HOST=mysql \
    -e MYSQL_USER=root \
    -e MYSQL_PASSWORD=admin \
    -e MYSQL_DB=mydb \
    -p 5000:5000 \
    flaskapp:latest

```
6. Open the `.env` file and add your MySQL configuration:

   ```
   MYSQL_HOST=mysql
   MYSQL_USER=your_username
   MYSQL_PASSWORD=your_password
   MYSQL_DB=your_database
   ```

7.  Create the `messages` table in your MySQL database:

   - Use a MySQL client or tool (e.g., phpMyAdmin) to execute the following SQL commands:
     ```bahs
     docker exec -it <mysql container id> bash 
     mysql -u root -p
     # Enter Password and chnaged to database and create table.
     ```
   
     ```sql
     CREATE TABLE messages (
         id INT AUTO_INCREMENT PRIMARY KEY,
         message TEXT
     );
     ```
### Using Docker Compose
1. Start the containers using Docker Compose, Befor that you need to logIn, add tag on image and push to DockerHub.

   ```bash
   docker-compose up --build
   ```

2. Access the Flask app in your web browser:

   - Frontend: http://localhost
   - Backend: http://localhost:5000

 
   - Visit http://localhost to see the frontend. You can submit new messages using the form.
   - Visit http://localhost:5000/insert_sql to insert a message directly into the `messages` table via an SQL query.

### Using kubeadm we add some advanced features.

1. First setup kubernetes kubeadm cluster

2. Move to k8s directory cd two-tier-flask-app/k8s

3. Now, execute below commands one by one
```bash
kubectl apply -f twotier-deployment.yml
kubectl apply -f twotier-deployment-svc.yml
kubectl apply -f mysql-deployment.yml
kubectl apply -f mysql-deployment-svc.yml
kubectl apply -f persistent-volume.yml
kubectl apply -f persistent-volume-claim.yml
```

### Using Helm we add some advanced features.



