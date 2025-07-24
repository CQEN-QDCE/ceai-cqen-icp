![SignServer](.github/signserver-community.svg)

# Helm Chart for SignServer Community

Helm chart for deploying SignServer in Kubernetes. Designed to be simple and flexible.

Welcome to SignServer – the Open Source Signing Software. Digitally sign documents, code, and timestamps while keeping your signature process and keys secure.

There are two versions of SignServer:

* **SignServer Community** (SignServer CE) - free and open source, OSI Certified Open Source Software, LGPL-licensed subset of SignServer Enterprise
* **SignServer Enterprise** (SignServer EE) - developed and commercially supported

OSI Certified is a certification mark of the Open Source Initiative.

## Community Support

In our Community we welcome contributions. The Community software is open source and community supported, there is no support SLA, but a helpful best-effort Community.

* To report a problem or suggest a new feature, use the **[Issues](../../issues)** tab.
* If you want to contribute actual bug fixes or proposed enhancements, use the **[Pull requests](../../pulls)** tab.
* Ask the community for ideas: **[SignServer Discussions](https://github.com/Keyfactor/signserver-ce/discussions)**.
* Read more in our documentation: **[SignServer Documentation](https://doc.primekey.com/signserver)**.
* See release information: **[SignServer Release information](https://doc.primekey.com/signserver/signserver-release-information)**.
* Read more on the open source project website: **[SignServer website](https://www.signserver.org/)**.

## Commercial Support
Commercial support is available for **[SignServer Enterprise](https://www.keyfactor.com/platform/keyfactor-signserver-enterprise/)**.

## License
SignServer Community is licensed under the LGPL license, please see **[LICENSE](LICENSE)**.


## Prerequisites

- [Kubernetes](http://kubernetes.io) v1.19+
- [Helm](https://helm.sh) v3+
- [EJBCA](https://www.ejbca.org), or another certificate authority for infrastructure and signer certificates.  

## Getting started

The **SignServer Community Helm Chart** bootstraps **SignServer Community** on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

SignServer depends on an existing PKI for infrastructure certificates (client TLS for administration and optionally server TLS) as well as for signer certificates for workers. [EJBCA](https://www.ejbca.org) is an open-source, enterprise-grade, PKI software that is [easy to get started](https://www.ejbca.org/use-cases/get-started-with-ejbca-pki/) with and [can be deployed in Kubernetes using Helm](https://github.com/Keyfactor/ejbca-community-helm).

### Add repo
```shell
helm repo add keyfactor https://keyfactor.github.io/ejbca-community-helm/
```

### Quick start

Deploying `signserver-community-helm` using default configurations will start SignServer with an ephemeral database and without the possibility of accessing the administration web interface. In order to be able to use SignServer, you should customize the deployment to allow admin web access and/or use pre-configured worker properties files.

### Custom deployment

To customize the installation, create and edit a custom values file with deployment parameters:
```shell
helm show values keyfactor/signserver-community-helm > signserver.yaml
```
Deploy `signserver-community-helm` on the Kubernetes cluster with custom configurations:
```shell
helm install signserver keyfactor/signserver-community-helm --namespace signserver --create-namespace --values signserver.yaml
```

## Example Custom Deployments

This section contains examples of how to customize the deployment for common scenarios.

## Connecting SignServer to an external database

All serious deployments of SignServer should use an external database for data persistence.
SignServer supports Microsoft SQL Server, MariaDB/MySQL, PostgreSQL, and Oracle databases. 

The following example shows modifications to the helm chart values file used to connect SignServer to a MariaDB database with server name `mariadb-server` and database name `signserverdb` using username `signserver` and password `foo123`:

```yaml
signserver:
  useEphemeralH2Database: false
  env:
    DATABASE_JDBC_URL: jdbc:mariadb://mariadb-server:3306/signserverdb?characterEncoding=UTF-8
    DATABASE_USER: signserver
    DATABASE_PASSWORD: foo123
```

This example connects SignServer to a PostgreSQL database and uses a Kubernetes secret for storing the database username and password:

```yaml
signserver:
  useEphemeralH2Database: false
  env:
    DATABASE_JDBC_URL: jdbc:postgresql://postgresql-server:5432/signserverdb
  envRaw:
    - name: DATABASE_PASSWORD
      valueFrom:
       secretKeyRef:
         name: signserver-db-credentials
         key: database_password
    - name: DATABASE_USER
      valueFrom:
       secretKeyRef:
         name: signserver-db-credentials
         key: database_user
```

Helm charts can be used to deploy a database in Kubernetes, for example the following by Bitnami:

- https://artifacthub.io/packages/helm/bitnami/postgresql
- https://artifacthub.io/packages/helm/bitnami/mariadb


### Configuring TLS termination in container for administrator access

The SignServer container can be provided with a custom keystore and truststore for TLS termination directly in the container. 

Create Kubernetes secrets using the following commands:

```shell
kubectl create secret generic keystore-secret --from-file=server.jks=server.jks --from-file=server.storepasswd=server.storepasswd

kubectl create secret generic truststore-secret --from-file=truststore.jks=ManagementCA-chain.jks --from-file=truststore.storepasswd=truststore.storepasswd
```

*server.jks* is the server keystore in JKS format, *server.storepasswd* is a text file containing the password to *server.jks*.

*truststore.jks* is the mTLS truststore and should contain certificate(s) of trusted CA(s) that issue administrator client TLS certificates.

Configure the helm chart to import keystore and truststore from the created secrets:

```yaml
signserver:
  importAppserverKeystore: true
  appserverKeystoreSecret: keystore-secret
  importAppserverTruststore: true
  appserverTruststoreSecret: truststore-secret
```

### Configuring SignServer to sit behind a reverse proxy 

It is best practice to place SignServer behind a reverse proxy server that handles TLS termination and/or load balancing.

The following example shows how to configure a deployment to expose an AJP proxy port as a ClusterIP service:

```yaml
services:
  directHttp:
    enabled: false
  proxyAJP:
    enabled: true
    type: ClusterIP
    bindIP: 0.0.0.0
    port: 8009
  proxyHttp:
    enabled: false
```

This example exposes two proxy HTTP ports, where port 8082 will accept the SSL_CLIENT_CERT HTTP header to enable mTLS:

```yaml
services:
  directHttp:
    enabled: false
  proxyAJP:
    enabled: false
  proxyHttp:
    enabled: true
    type: ClusterIP
    bindIP: 0.0.0.0
    httpPort: 8081
    httpsPort: 8082
```

### Enabling Ingress in front of SignServer

Ingress is a Kubernetes native way of exposing HTTP and HTTPS routes from outside to Kubernetes services.

The following example shows how Ingress can be enabled with this helm chart using proxy AJP. 
Note that a TLS secret containing `tls.crt` and `tls.key` with certificate and private key would need to be prepared in advance and that *nginx.ingress.kubernetes.io/auth-tls-secret* must reference a secret containing a file named `ca.crt` with CA certificates that allow authentication.

```yaml
services:
  directHttp:
    enabled: false
  proxyAJP:
    enabled: true
    type: ClusterIP
    bindIP: 0.0.0.0
    port: 8009
  proxyHttp:
    enabled: false

ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/auth-tls-verify-client: "on"
    nginx.ingress.kubernetes.io/auth-tls-secret: "default/managementca-secret"
    nginx.ingress.kubernetes.io/auth-tls-pass-certificate-to-upstream: "true"
  hosts:
    - host: "signserver.minikube.local"
      paths:
        - path: /signserver
          pathType: Prefix
  tls:
    - hosts:
        - signserver.minikube.local
      secretName: ingress-tls
```

### Importing signer keystores into SignServer container

Keystore files containing signer keys and certificates that should be used by SignServer workers can be imported from a Kubernetes secret.

Use the following command to create a secret containing one or more keystore files:

```shell
kubectl create secret generic signer-keystores-secret --from-file=signer_keystore.p12=signer_keystore.p12
```

Configure the chart to mount keystore files from the secret. `keystoresMountPath` is where the files should be placed in the container:

```yaml
signserver:
  importKeystores: true
  keystoresSecret: signer-keystores-secret
  keystoresMountPath: /mnt/external
```

### Configuring SignServer using worker properties files

SignServer can be fully configured using properties files. 

The example below configures two workers, a crypto worker that connects to keystore files located at `/mnt/external/signer_keystore.p12` and a PlainSigner that signs using the key signKey0001 from this keystore:

```
WORKER1.NAME=SignerCryptoToken
WORKER1.TYPE=CRYPTO_WORKER
WORKER1.IMPLEMENTATION_CLASS=org.signserver.server.signers.CryptoWorker
WORKER1.CRYPTOTOKEN_IMPLEMENTATION_CLASS=org.signserver.server.cryptotokens.KeystoreCryptoToken
WORKER1.KEYSTORETYPE=PKCS12
WORKER1.KEYSTOREPATH=/mnt/external/signer_keystore.p12
WORKER1.KEYSTOREPASSWORD=foo123
WORKER1.DEFAULTKEY=testKey

WORKER2.NAME=PlainSigner
WORKER2.TYPE=PROCESSABLE
WORKER2.IMPLEMENTATION_CLASS=org.signserver.module.cmssigner.PlainSigner
WORKER2.CRYPTOTOKEN=SignerCryptoToken
WORKER2.DEFAULTKEY=signKey0001
WORKER2.DISABLEKEYUSAGECOUNTER=true
WORKER2.AUTHTYPE=NOAUTH
```

Create a secret from one or more text files with worker properties:

```shell
kubectl create secret generic workers-secret --from-file=workers.properties=workers.properties
```

Configure the chart to import worker properties at start-up:

```yaml
signserver:
  importWorkerProperties: true
  workerPropertiesSecret: workers-secret
```

Sample properties files for different types of workers are available in the [SignServer GitHub repository](https://github.com/Keyfactor/signserver-ce/tree/main/signserver/doc/sample-configs).

Note that the samples prefix properties with `WORKERGENID1` which always creates a new worker. In order to handle container restarts, exact worker ID should be used like in the example above. This way the worker is created if it does not already exist, otherwise properties are applied to the existing worker with that ID.

## Parameters

### SignServer Deployment Parameters

| Name                                  | Description                                                                                            | Default |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------ | ------- |
| signserver.useEphemeralH2Database     | If in-memory internal H2 database should be used                                                       | true    |
| signserver.useH2Persistence           | If internal H2 database with persistence should be used. Requires existingH2PersistenceClaim to be set | false   |
| signserver.existingH2PersistenceClaim | PersistentVolumeClaim that internal H2 database can use for data persistence                           |         |
| signserver.importAppserverKeystore    | If an existing keystore should be used for TLS configurations when reverse proxy is not used           | false   |
| signserver.appserverKeystoreSecret    | Secret containing keystore for TLS configuration of SignServer application server                      |         |
| signserver.importAppserverTruststore  | If an existing truststore should be used for TLS configurations when reverse proxy is not used         | false   |
| signserver.appserverTruststoreSecret  | Secret containing truststore for TLS configuration of SignServer application server                    |         |
| signserver.importWorkerProperties     | If properties files should be used to configure SignServer                                             | false   |
| signserver.workerPropertiesSecret     | Secret containing properties files used for configuring SignServer at startup                          |         |
| signserver.importKeystores            | If keystore files should be mounted into the SignServer container                                      | false   |
| signserver.keystoresSecret            | Secret containing keystore files that can be used by SignServer workers                                |         |
| signserver.keystoresMountPath         | Mount path in the SignServer container for mounted keystore files                                      |         |
| signserver.env                        | Environment variables to pass to container                                                             |         |
| signserver.envRaw                     | Environment variables to pass to container in Kubernetes YAML format                                   |         |
| signserver.initContainers             | Extra init containers to be added to the deployment                                                    | []      |
| signserver.sidecarContainers          | Extra sidecar containers to be added to the deployment                                                 | []      |
| signserver.volumes                    | Extra volumes to be added to the deployment                                                            | []      |
| signserver.volumeMounts               | Extra volume mounts to be added to the deployment                                                      | []      |

### SignServer Environment Variables

| Name                                         | Description                                                                                                                                                                                                | Default |
| -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| signserver.env.DATABASE_JDBC_URL             | JDBC URL to external database                                                                                                                                                                              |         |
| signserver.env.DATABASE_USER                 | The username part of the credentials to access the external database                                                                                                                                       |         |
| signserver.env.DATABASE_PASSWORD             | The password part of the credentials to access the external database                                                                                                                                       |         |
| signserver.env.DATABASE_USER_PRIVILEGED      | The username part of the credentials to access the external database if separate account is used for creating tables and schema changes                                                                    |         |
| signserver.env.DATABASE_PASSWORD_PRIVILEGED  | The password part of the credentials to access the external database if separate account is used for creating tables and schema changes                                                                    |         |
| signserver.env.LOG_LEVEL_APP                 | Application log level                                                                                                                                                                                      |         |
| signserver.env.LOG_LEVEL_APP_WS_TRANSACTIONS | Application log level for WS transaction logging                                                                                                                                                           |         |
| signserver.env.LOG_LEVEL_SERVER              | Application server log level for main system                                                                                                                                                               |         |
| signserver.env.LOG_LEVEL_SERVER_SUBSYSTEMS   | Application server log level for sub-systems                                                                                                                                                               |         |
| signserver.env.LOG_STORAGE_LOCATION          | Path in the Container (directory) where the log will be saved, so it can be mounted to a host directory. The mounted location must be a writable directory                                                 |         |
| signserver.env.LOG_STORAGE_MAX_SIZE_MB       | Maximum total size of log files (in MB) before being discarded during log rotation. Minimum requirement: 2 (MB)                                                                                            |         |
| signserver.env.LOG_AUDIT_TO_DB               | Set this value to true if the internal SignServer audit log is needed                                                                                                                                      |         |
| signserver.env.TZ                            | TimeZone to use in the container                                                                                                                                                                           |         |
| signserver.env.APPSERVER_DEPLOYMENT_TIMEOUT  | This value controls the deployment timeout in seconds for the application server when starting the application                                                                                             |         |
| signserver.env.JAVA_OPTS_CUSTOM              | Allows you to override the default JAVA_OPTS that are set in the standalone.conf                                                                                                                           |         |
| signserver.env.PROXY_AJP_BIND                | Run container with an AJP proxy port :8009 bound to the IP address in this variable, e.g. PROXY_AJP_BIND=0.0.0.0                                                                                           |         |
| signserver.env.PROXY_HTTP_BIND               | Run container with two HTTP back-end proxy ports :8081 and :8082 configured bound to the IP address in this variable. Port 8082 will accepts the SSL_CLIENT_CERT HTTP header, e.g. PROXY_HTTP_BIND=0.0.0.0 |         |

### Services Parameters

| Name                          | Description                                                                                               | Default   |
| ----------------------------- | --------------------------------------------------------------------------------------------------------- | --------- |
| services.directHttp.enabled   | If service for communicating directly with SignServer container should be enabled                          | true      |
| services.directHttp.type      | Service type for communicating directly with SignServer container                                          | NodePort  |
| services.directHttp.httpPort  | HTTP port for communicating directly with SignServer container                                             | 31080     |
| services.directHttp.httpsPort | HTTPS port for communicating directly with SignServer container                                            | 31443     |
| services.proxyAJP.enabled     | If service for reverse proxy servers to communicate with SignServer container over AJP should be enabled  | false     |
| services.proxyAJP.type        | Service type for proxy AJP communication                                                                  | ClusterIP |
| services.proxyAJP.bindIP      | IP to bind for proxy AJP communication                                                                    | 0.0.0.0   |
| services.proxyAJP.port        | Service port for proxy AJP communication                                                                  | 8009      |
| services.proxyHttp.enabled    | If service for reverse proxy servers to communicate with SignServer container over HTTP should be enabled | false     |
| services.proxyHttp.type       | Service type for proxy HTTP communication                                                                 | ClusterIP |
| services.proxyHttp.bindIP     | IP to bind for proxy HTTP communication                                                                   | 0.0.0.0   |
| services.proxyHttp.httpPort   | Service port for proxy HTTP communication                                                                 | 8081      |
| services.proxyHttp.httpsPort  | Service port for proxy HTTP communication that accepts SSL_CLIENT_CERT header                             | 8082      |
| services.sidecarPorts         | Additional ports to expose in sidecar containers                                                          | []        |


### Ingress Parameters

| Name                | Description                                 | Default           |
| ------------------- | ------------------------------------------- | ----------------- |
| ingress.enabled     | If ingress should be created for SignServer | false             |
| ingress.className   | Ingress class name                          | "nginx"           |
| ingress.annotations | Ingress annotations                         | <see values.yaml> |
| ingress.hosts       | Ingress hosts configurations                | []                |
| ingress.tls         | Ingress TLS configurations                  | []                |

### Deployment Parameters

| Name                                          | Description                                                                                                            | Default                 |
| --------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| replicaCount                                  | Number of SignServer replicas                                                                                          | 1                       |
| image.repository                              | SignServer image repository                                                                                            | keyfactor/signserver-ce |
| image.pullPolicy                              | SignServer image pull policy                                                                                           | IfNotPresent            |
| image.tag                                     | Overrides the image tag whose default is the chart appVersion                                                          |                         |
| imagePullSecrets                              | SignServer image pull secrets                                                                                          | []                      |
| nameOverride                                  | Overrides the chart name                                                                                               | ""                      |
| fullnameOverride                              | Fully overrides generated name                                                                                         | ""                      |
| serviceAccount.create                         | Specifies whether a service account should be created                                                                  | true                    |
| serviceAccount.annotations                    | Annotations to add to the service account                                                                              | {}                      |
| serviceAccount.name                           | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | ""                      |
| podAnnotations                                | Additional pod annotations                                                                                             | {}                      |
| podSecurityContext                            | Pod security context                                                                                                   | {}                      |
| securityContext                               | Container security context                                                                                             | {}                      |
| resources                                     | Resource requests and limits                                                                                           | {}                      |
| autoscaling.enabled                           | If autoscaling should be used                                                                                          | false                   |
| autoscaling.minReplicas                       | Minimum number of replicas for autoscaling deployment                                                                  | 1                       |
| autoscaling.maxReplicas                       | Maximimum number of replicas for autoscaling deployment                                                                 | 5                       |
| autoscaling.targetCPUUtilizationPercentage    | Target CPU utilization for autoscaling deployment                                                                      | 80                      |
| autoscaling.targetMemoryUtilizationPercentage | Target memory utilization for autoscaling deployment                                                                   |                         |
| nodeSelector                                  | Node labels for pod assignment                                                                                         | {}                      |
| tolerations                                   | Tolerations for pod assignment                                                                                         | []                      |
| affinity                                      | Affinity for pod assignment                                                                                            | {}                      |
