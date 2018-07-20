Run Following CMD -

1. docker build -t viveksoni56/webserver webserver/Dockerfile

2. docker run -d -p 8080:8080 --name webserver -t viveksoni56/webserver

3. docker build -t viveksoni56/nginx nginx/Dockerfile

4. docker run -d --name mynginx -p 80:80 --link=webserver  viveksoni56/nginx