# test-nginx-dns-resolution-failures
Adhoc scripts to reproduce nginx dns resolution failures  

## Steps to reproduce 

### Environment Config  
If you’re using MAC silicon then this you have installed both [brew](https://brew.sh/) and rosetta. To install rosetta:

```bash
softwareupdate --install-rosetta
```

1. Install kind.
```bash
brew install kind
```

2. Deploy a multi-node cluster.
```bash
kind create cluster --config ./infra/cluster.yaml
```

3. Build a custom nginx to be used as a reverse proxy.
```
# Requires to set a TAG value.
$ docker build -t custom-nginx:$TAG . 
```

4. Register the image to the kind cluster.
```bash
kind load docker-image custom-nginx:$TAG
```

5. Deploy ingress-nginx controller
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
./scripts/create-ns && helm -n ingress-ngix install my-ingress-nginx ingress-nginx/ingress-nginx --version 4.10.0
```

6. Deploy reverse-proxy (with tcpdump side-car container) and expose deployment
```bash
# Assumes you're kind cluster context is named `kind-kind`.
kubectl --context kind-kind apply -f ./infra/nginx.yaml
kubectl expose deploy reverse-proxy --port 8080
```

7. Deploy a backend app, service and ingress:
```bash
find ./app/*.yaml | xargs -I {} kubectl --context kind-kind apply -f {}  
```

8. Create a port-forward resource to hit the ingress controller
```bash
# Uses port 8080
kubectl --context kind-kind -n ingress-nginx port-forward svc/ingress-nginx-controller 8080:80
```

9. Test
```bash
counter=0
curl -H "Host: test${counter}.hello-test.internal" "http://127.0.0.1:8080"
```