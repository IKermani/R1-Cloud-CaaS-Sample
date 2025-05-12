helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install -f monitoring/values.yaml kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
