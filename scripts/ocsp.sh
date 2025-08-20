#!/bin/bash

# Script pour vérifier l'état d'un certificat via OCSP
# Usage: ./ocsp.sh <certificate> <issuer>

CERTIFICATE="$1"
ISSUER="$2" 

# Assure que OpenSSL est installé
if ! command -v openssl &> /dev/null; then
    echo "OpenSSL n'est pas installé. Veuillez l'installer et réessayer."
    exit 1
fi

# Vérifier si les certificats ont été fournis
if [ -z "$CERTIFICATE" ] || [ -z "$ISSUER" ]; then
    echo "Erreur de paramètres." 
    echo "Utilisation: $0 <certificate> <issuer>"
    exit 1
fi

# Vérifier si le fichier de certificat existe
if [ ! -f "$CERTIFICATE" ]; then
    echo "Fichier de certificat '$CERTIFICATE' n'existe pas."
    exit 1
fi      
# Vérifier si le fichier de l'émetteur existe
if [ ! -f "$ISSUER" ]; then
    echo "Fichier de l'émetteur '$ISSUER' n'existe pas."
    exit 1
fi

# Extraire l'URL du serveur OCSP du certificat
FULL_OCSP=$(openssl x509 -in $CERTIFICATE -text | grep OCSP) 

# Extraire l'URL du serveur OCSP
OCSP_SERVER="${FULL_OCSP#*URI:}"
echo "Demande au serveur OCSP à l'adresse: " $OCSP_SERVER

# Préparer la requête OCSP
openssl ocsp -noverify -no_nonce -reqout tmp-ocsp.req -issuer $ISSUER -cert $CERTIFICATE -header "HOST=icp-preprod.asea.cqen.ca" -text 
# Encode la requête OCSP en base64
base64 -i tmp-ocsp.req -o tmp-ocsp.req.enc

# Envoyer la requête OCSP et récupérer la réponse
curl --url $OCSP_SERVER/$(cat tmp-ocsp.req.enc) --output tmp-ocsp.resp

# Vérifier la réponse OCSP reçue
openssl ocsp -CAfile $ISSUER -respin tmp-ocsp.resp -text -noverify

# Clean up des fichiers temporaires
rm -f tmp-ocsp*
