# Minimal ELK homelab (Docker Compose)

A single-node Elasticsearch + Kibana + Logstash setup for learning and local testing.
This is intentionally a small, unauthenticated lab, not a production deployment.
Ports are bound to `127.0.0.1` by default so the services are not exposed to your LAN.

## Requirements

- Docker Engine and the Docker Compose plugin
- 4 GB RAM minimum; 6–8 GB is more comfortable
- On Linux, set Elasticsearch's `vm.max_map_count` requirement:

```bash
sudo sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' | sudo tee /etc/sysctl.d/99-elasticsearch.conf
```

## Start

```bash
cd elk-homelab
docker compose up -d
docker compose ps
docker compose logs -f elasticsearch kibana logstash
```

Open Kibana on the same host: <http://127.0.0.1:5601>

## Send a test event

```bash
curl -X POST 'http://127.0.0.1:8080' \
  -H 'Content-Type: application/json' \
  -d '{"message":"hello from my homelab","source":"manual-test","level":"info"}'
```

Check that Elasticsearch created the index:

```bash
curl 'http://127.0.0.1:9200/_cat/indices/homelab-logs-*?v'
```

In Kibana, open **Discover** and create a data view matching `homelab-logs-*` with `@timestamp` as the time field.

## Open Kibana from another computer via SSH tunnel

Keep the localhost-only port bindings and run this on your client computer:

```bash
ssh -L 5601:127.0.0.1:5601 -L 8080:127.0.0.1:8080 USER@SERVER_IP
```

Then open <http://127.0.0.1:5601> in the client browser. Replace `USER` and `SERVER_IP`.

## Useful commands

```bash
docker compose logs -f logstash
docker compose restart logstash
docker compose down
```

`docker compose down` preserves Elasticsearch data in the named `esdata` volume.
**Destructive:** `docker compose down -v` also deletes that volume and all indexed data.

## Security note

`xpack.security.enabled=false` is used to reduce setup friction for a private lab. Do not expose Elasticsearch, Kibana, or Logstash directly to a LAN or the Internet in this configuration. For LAN access, enable authentication/TLS and configure the corresponding Logstash credentials and Kibana settings first.
