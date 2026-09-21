#!/bin/sh
# =====================================================================
# IoT-Seminar - Lab 5 prerequisites for Lab 8
# Creates the PKI (Global Trust Root CA + Hightech-Biz CA + chain)
# needed before generating the EMQX broker certificate in Lab 8.
#
# Run with:  sh lab8_script.sh
# (POSIX sh compatible - works with dash, the default /bin/sh on Ubuntu)
# =====================================================================

PASS="iotlab2022"
PKI="/home/iotlab/PKI"
CONF_URL="https://raw.githubusercontent.com/markweber1980/IoT-Lab/main/pki-openssl-sample.conf"

# ---- helper: run a command quietly; on failure show the error and stop ----
step() {
    desc="$1"; shift
    echo "[INFO] $desc"
    if ! out="$("$@" 2>&1)"; then
        echo "[ERROR] $desc FAILED:"
        echo "$out" | sed 's/^/        /'
        echo "[ERROR] Aborting - fix the problem above and re-run the script."
        exit 1
    fi
}

echo ""
echo "Welcome to the Lab 5 pre-requirements script (needed to start Lab 8)."
echo "It runs all the Lab 5 PKI commands: Root CA + Hightech-Biz CA + chain."
printf "Do you want to proceed? (yes/no) "
read yn
case "$yn" in
    yes|y|Y ) : ;;
    no|n|N )  echo "Exiting..."; exit 0 ;;
    * )       echo "Invalid response - exiting."; exit 1 ;;
esac

# ---- packages ----
echo "[INFO] Updating package lists and installing tools"
apt update           > /dev/null 2>&1
apt -y upgrade       > /dev/null 2>&1
# wget + ca-certificates are needed for the HTTPS download below,
# openssl for the PKI, sudo/nano for later manual steps.
step "Installing sudo nano openssl wget ca-certificates" \
    apt -y install sudo nano openssl wget ca-certificates

# ---- user iotlab ----
echo "[INFO] Creating user iotlab"
adduser iotlab --gecos "IoTLab,,," --disabled-password > /dev/null 2>&1
echo "iotlab:${PASS}" | chpasswd
usermod -aG sudo iotlab > /dev/null 2>&1

# ---- PKI working directory + OpenSSL config ----
step "Creating PKI folder ${PKI}" mkdir -p "${PKI}"
cd "${PKI}" || { echo "[ERROR] cannot cd to ${PKI}"; exit 1; }

echo "[INFO] Downloading pki-openssl-sample.conf"
if ! wget -q -O pki-openssl-sample.conf "${CONF_URL}"; then
    echo "[ERROR] Download failed: ${CONF_URL}"
    echo "[ERROR] Check your network / the URL, then re-run."
    exit 1
fi
# a login page or 404 returns HTML, not a conf - reject that, and require a
# real OpenSSL section header ("[ req ]") that an HTML page will never contain.
if [ ! -s pki-openssl-sample.conf ] \
   || grep -qi "<!DOCTYPE\|<html" pki-openssl-sample.conf \
   || ! grep -q "\[ *req *\]" pki-openssl-sample.conf; then
    echo "[ERROR] Downloaded config is not a valid OpenSSL conf (got HTML or wrong file)."
    echo "[ERROR] Check the URL/branch: ${CONF_URL}"
    echo "[ERROR] First lines were:"
    head -n 5 pki-openssl-sample.conf | sed 's/^/        /'
    exit 1
fi
cp pki-openssl-sample.conf pki-openssl.conf
export OPENSSL_CONF="${PKI}/pki-openssl.conf"

# =====================================================================
# Part 1 - Root CA "Global Trust"
# =====================================================================
step "Creating folder structure for RootCA" mkdir -p RootCA/certs RootCA/reqs RootCA/crl RootCA/private
chmod 700 RootCA/private
touch RootCA/index.txt

step "Generating private key for RootCA" \
    openssl genpkey -des3 -algorithm RSA -out RootCA/private/root-ca.key -pass "pass:${PASS}"

step "Generating self-signed certificate for RootCA" \
    openssl req -new -x509 -key RootCA/private/root-ca.key -out RootCA/certs/root-ca.crt -passin "pass:${PASS}" \
        -subj "/C=DE/ST=Hessen/L=Giessen/O=Global Trust/CN=Global Trust Root CA"

# =====================================================================
# Part 2 - Intermediate CA "Hightech-Biz", signed by Root CA
# =====================================================================
step "Creating folder structure for HTBCA" mkdir -p HTBCA/certs HTBCA/reqs HTBCA/crl HTBCA/private
chmod 700 HTBCA/private
touch HTBCA/index.txt

step "Generating private key for HTBCA" \
    openssl genpkey -des3 -algorithm RSA -out HTBCA/private/htb-ca.key -pass "pass:${PASS}"

step "Generating certificate request for HTBCA" \
    openssl req -new -key HTBCA/private/htb-ca.key -out HTBCA/reqs/htb-ca.csr -passin "pass:${PASS}" \
        -subj "/C=DE/ST=Hessen/L=Giessen/O=Hightech-Biz/CN=Hightech-Biz CA"

step "Signing HTBCA request with RootCA" \
    openssl x509 -req -extensions ca_cert -in HTBCA/reqs/htb-ca.csr \
        -CA RootCA/certs/root-ca.crt -CAkey RootCA/private/root-ca.key -CAcreateserial \
        -out HTBCA/certs/htb-ca.crt -days 365 -extfile pki-openssl.conf -passin "pass:${PASS}"

echo "[INFO] Building certificate chain htb-ca-chain.crt"
if ! cat HTBCA/certs/htb-ca.crt RootCA/certs/root-ca.crt > HTBCA/certs/htb-ca-chain.crt; then
    echo "[ERROR] Failed to build certificate chain."; exit 1
fi

# ---- give everything to the iotlab user ----
step "Setting ownership to iotlab" chown -R iotlab:iotlab "${PKI}"

echo ""
echo "[INFO] DONE. PKI created successfully under ${PKI}"
echo "[INFO] Next: su iotlab  &&  export OPENSSL_CONF=${PKI}/pki-openssl.conf"
echo "[INFO] Then continue with the Lab 8 EMQX certificate steps."
