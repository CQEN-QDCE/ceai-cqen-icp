default: @deploy

# Création et suppression du projet des Services de Confiance
create:
	@echo "Creation du projet des Services de Confiance..."
	oc get project services-confiance-xroad || \
		oc new-project services-confiance-xroad --display-name "Services de Confiance X-Road" --description="Services de confiance pour l'ICP et TSA X-Road" 

delete:
	@echo "Suppression du projet des Services de Confiance..."
	oc delete secret management-ca-secret -n services-confiance-xroad || true
	oc delete all --all -n services-confiance-xroad || true
	oc delete project services-confiance-xroad || true

@deploy: deployEJBCA @installSignServer

# Installation de EJBCA
deployEJBCA: 
	@echo "Deploiement EJBCA..."
	oc process -f openshift/templates/ejbca.yaml --param-file=openshift/templates/ejbca.env.params | oc apply -f -

dryRunEJBCA: 
	@echo "Teste du deploiement EJBCA (dry run)..."
	oc process -f openshift/templates/ejbca.yaml --param-file=openshift/templates/ejbca.env.params

helmEJBCA:
	helm install ejbca charts/ejbca -n services-confiance-xroad



# Installation de SignServer
@installSignServer: cert deploySignServer 

cert: 
	@echo "Création du secrèt Management CA..."
	oc create secret generic management-ca-secret --from-file=ManagementCA.crt=certs/ManagementCA.pem -n services-confiance-xroad || true	

deploySignServer: 
	@echo "Deploiement SignServer..."
	oc process -f openshift/templates/signserver.yaml --param-file=openshift/templates/signserver.params.env | oc apply -f -
	
dryRunSignServer: 
	@echo "Test du deploiement SignServer..."
	oc process -f openshift/templates/signserver.yaml --param-file=openshift/templates/signserver.params.env

helmSignServer:
	helm install tsaServer charts/signserver -n services-confiance-xroad



# Targets de tâches clericales 
help: 
	@grep '^[a-zA-Z]' Makefile | sort | awk -F ':.*?## ' 'NF==2 {printf "  %-26s%s\n", $$1, $$2}' 

prune: 
	docker image prune -f
	docker container prune -f