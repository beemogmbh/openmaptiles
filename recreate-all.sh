make clean-docker
make clean
make
docker-compose up -d postgres
sleep 10
make forced-clean-sql
docker-compose run --rm import-water
docker-compose run --rm import-osmborder
docker-compose run --rm import-natural-earth
docker-compose run --rm import-lakelines
docker-compose run --rm import-osm
docker-compose run --rm import-poi-all
docker-compose run --rm import-sql
