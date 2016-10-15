# BUILD
docker build -t template/debian .

# RUN
docker run -it --name server1 template/debian bash

# EXEC
docker exec -it server1 bash