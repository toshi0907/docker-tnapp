# TN API Server (Docker Compose版)


```bash
git clone https://github.com/toshi0907/docker-tnapp.git
cd docker-tnapp
mkdir -p data

git clone https://github.com/toshi0907/tnapp.git
cd tnapp
cp .env.example .env

cd ..

docker compose up -d
```