# Certificates cheatsheet

## X.509 Certificate

X.509 certificates contain public keys and identity information, and can be encoded as PEM (Base64 ASCII) or DER (binary) format.  

```bash
# View certificate details
openssl x509 -in cert.{pem, der} -text -noout
```

## PKCS#12 Certificate


## Kubernetes User Certificates
To create a user certificate for authentication, you can use OpenSSL to generate a private key and a certificate signing request (CSR). Then, sign the CSR with the cluster's Certificate Authority (CA).
```bash
# Generate a private key and CSR
openssl genrsa -out martin.key 2048
openssl req -new -key martin.key -subj "/CN=martin" -out martin.csr

# Sign the CSR with the cluster CA
openssl x509 -req -in martin.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -out martin.crt -CAcreateserial

# Configure kubeconfig for Martin
kubectl config set-credentials martin --client-certificate=martin.crt --client-key=martin.key
kubectl config set-context developer --cluster=kubernetes --user=martin
kubectl config use-context developer
```
