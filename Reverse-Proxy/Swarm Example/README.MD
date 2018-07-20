Run Following CMD -

1. docker build -t viveksoni56/pyapp pyapp/Dockerfile

2. docker build -t viveksoni56/reverseproxy nginx/Dockerfile

3. Run  YAML File - docker stack deploy -c docker-compose-nginx.yml prod


