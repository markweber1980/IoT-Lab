# IoT Seminar Lab 8 : PKI Deployment Script for Lab 5 pre-requirements

## English

### Overview
This repository contains a script for the easy deployment of a Public Key Infrastructure (PKI) based on Lab 5. It's designed to help students implement PKI with minimal hassle in Lab 8.

### What does this script do

1. Create a new user called **iotlab** with password **iotlab2022**
2. Update and upgrade all installed packages
3. Install **sudo**
4. Install **nano** and **openssl**
5. Create **PKI** folder under /home/iotlab
6. Download file **pki-openssl-sample.conf**
7. Create a copy of **pki-openssl-sample.conf** called **pki-openssl.conf**
8. Set **pki-openssl.conf** as OPENSSL_CONF environment variable
9. Create the **folder structure** for RootCA
10. Generate **private key** for RootCA
11. Generate **self-signed certificate** for RootCA
12. Create **folder structure** for HTBCA
13. Generate **private key** for HTBCA
14. Generate **certificate request** for HTBCA
15. Move certificate request to RootCA reqs folder
16. Sign **certificate request** of HTBCA with RootCA
17. Move certificate back to HTBCA certs folder
18. Generate **certificate chain** for HTBCA

### Commands
Follow these steps to deploy the PKI:

```
apt update && apt install -y wget && apt-get install adduser
wget https://git.thm.de/iot-lab/lab8/-/raw/master/lab8_script.sh
sh lab8_script.sh
cd /home/iotlab/PKI
su iotlab
export OPENSSL_CONF=/home/iotlab/PKI/pki-openssl.conf
```

### Requirements
- Ubuntu container shell running

## Deutsh

### Überblick
Dieses Repository enthält ein Skript für den einfachen Einsatz einer Public Key Infrastructure (PKI) auf der Grundlage von Lab 5. Es soll den Studierenden helfen, eine PKI mit minimalem Aufwand in Lab 8 zu implementieren.

### Was macht dieses Skript

1. Erstellen eines neuen Benutzers namens **iotlab** mit dem Passwort **iotlab2022**.
2. Aktualisierung und Upgrade aller installierten Pakete
3. Installieren Sie **sudo**.
4. Installieren Sie **nano** und **openssl**.
5. Erstellen Sie den Ordner **PKI** unter /home/iotlab
6. Laden Sie die Datei **pki-openssl-sample.conf** herunter.
7. Erstellen Sie eine Kopie von **pki-openssl-sample.conf** mit dem Namen **pki-openssl.conf**.
8. Setzen Sie **pki-openssl.conf** als Umgebungsvariable OPENSSL_CONF
9. Erstellen Sie die **Ordnerstruktur** für RootCA
10. Erzeugen Sie den **privaten Schlüssel** für RootCA
11. Erzeugen Sie ein **selbstsigniertes Zertifikat** für RootCA
12. Erstellen einer **Ordnerstruktur** für HTBCA
13. **privaten Schlüssel** für HTBCA erzeugen
14. Erzeugen einer **Zertifikatsanforderung** für HTBCA
15. Zertifikatsanforderung in den Ordner RootCA reqs verschieben
16. Signiere **Zertifikatsanforderung** von HTBCA mit RootCA
17. Zertifikat zurück in den HTBCA certs Ordner verschieben
18. Erzeuge **Zertifikatskette** für HTBCA

### Befehle
Befolgen Sie diese Schritte, um die PKI einzurichten:

```
apt update && apt install -y wget && apt-get install adduser
wget https://git.thm.de/iot-lab/lab8/-/raw/master/lab8_script.sh
sh lab8_script.sh
cd /home/iotlab/PKI
su iotlab
export OPENSSL_CONF=/home/iotlab/PKI/pki-openssl.conf
```

### Voraussetzungen
- Ubuntu Container-Shell läuft
