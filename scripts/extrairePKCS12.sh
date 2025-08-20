#!/bin/bash 

# Exporte le certificat d'un fichier PKCS#12 vers un fichier au format PEM.
# Utilisation: ./export.sh INFILE.p12
# Example: ./export.sh mycert.p12

# Assure que OpenSSL est installé
if ! command -v openssl &> /dev/null; then
    echo "OpenSSL n'est pas installé. Veuillez l'installer et réessayer."    
    exit 1
fi

# Vérifier si le nombre correct d'arguments est fourni
if [ "$#" -ne 1 ]; then
    echo "Utilisation: $0 INFILE.p12"
    exit 1
fi

# Attribuer le nom du fichier d'entrée
INFILE="$1"

# Vérifier si le fichier d'entrée est fourni
if [ ! -f "$INFILE" ]; then
    echo "Fichier non trouvé: $INFILE"
    exit 1
fi

# Vérifier que l'extension du fichier est .p12
if [[ "$INFILE" != *.p12 ]]; then
    echo "Erreur: Fichier d'entrée doit avoir l'extension .p12"
    exit 1
fi

# Créer le nom du fichier de sortie en supprimant l'extension .p12
OUTFILE="${INFILE%.p12}.crt"

# Vérifier si le fichier de sortie existe déjà
if [ -f "$OUTFILE" ]; then
    echo "Fichier en sortie existant: $OUTFILE. Aucune action prise."
    # exit 1
fi

# Convertir le fichier PKCS#12 en un fichier de certificat au format PEM
openssl pkcs12 -in $INFILE -out $OUTFILE -nodes -nokeys
if [ $? -ne 0 ]; then
    echo "Erreur lors de l'exportation du certificat depuis $INFILE"
    exit 1
fi
echo "Certificat exporté avec succès vers $OUTFILE"

# Exporter la clé privée vers un fichier PEM séparé
KEYFILE="${INFILE%.p12}.key"
if [ -f "$KEYFILE" ]; then
    echo "Output key file already exists: $KEYFILE. No action taken."
    echo "Fichier de clé privé existant: $KEYFILE. Aucune action prise."
    # Décommenter la ligne suivante si vous souhaitez quitter lorsque le fichier de clé existe
    # exit 1
fi
openssl pkcs12 -in $INFILE -out $KEYFILE -nocerts -nodes
if [ $? -ne 0 ]; then
    echo "Erreur lors de l'exportation de la clé privée depuis $INFILE"
    exit 1
fi
echo "Clé privée exportée avec succès vers $KEYFILE"

# Exporter les certificats CA vers un fichier PEM séparé
CAFILE="${INFILE%.p12}-ca.crt"
if [ -f "$CAFILE" ]; then
    echo "Fichier CA existant: $CAFILE. Aucune action prise."
    # Décommenter la ligne suivante si vous souhaitez quitter lorsque le fichier de clé existe
    # exit 1
fi
openssl pkcs12 -in $INFILE -out $CAFILE -cacerts -nokeys
if [ $? -ne 0 ]; then
    echo "Erreur lors de l'exportation des certificats CA depuis $INFILE"
    exit 1
fi

echo "Certificats CA exportés avec succès vers $CAFILE"

# Imprimer le message de fin
echo "Tous les exports ont été effectués avec succès."

# Print the output files
echo "Output files:"
echo "- Certificate: $OUTFILE"
echo "- Private Key: $KEYFILE"
echo "- CA Certificates: $CAFILE"
# End of script
# Ensure the script is executable
chmod +x export.sh
# Usage example
# ./export.sh mycert.p12
# Note: Make sure to keep the private key secure and do not share it publicly.
# End of export.sh
