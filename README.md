# simple-deploy-pipeline

To pull from the registry, add registry host to /etc/docker/daemon.json

Example /etc/docker/daemon.json, assuming that the registry is running on host 192.168.1.123 on port 5000.
```JSON  
{
  "insecure-registries":["192.168.1.123:5000"]
}
```    

Query registry with:
```
curl -X GET http://[RegistryHost]:5000/v2/_catalog
```
