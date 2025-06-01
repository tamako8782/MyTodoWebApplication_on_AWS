apiVersion: v1
kind: Config
clusters:
- cluster:
    server: ${cluster_endpoint}
    certificate-authority-data: ${cluster_ca}
  name: ${cluster_name}
contexts:
- context:
    cluster: ${cluster_name}
    user: aws
  name: aws
current-context: aws
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - eks
        - get-token
        - --cluster-name
        - ${cluster_name}
        - --region
        - ${aws_region}