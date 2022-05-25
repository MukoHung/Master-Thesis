 # Usage:
 # This script is designed to be run after you have Solr running locally without SSL
 # It will generate a trusted, self-signed certificate for LOCAL DEV (this must be modified for production)
 
 # Notes: The keystore must be under server/etc on Solr root, and MUST be named solr-ssl.keystore.jks
 # The cert will be added to locally trusted certs, so no security warnings in browsers
 # You must still reconfigure Solr to use the keystore and restart it after running this script
 #
 # THIS SCRIPT REQUIRES WINDOWS 10 (for the SSL trust); without 10 remove the lines around trusting the cert.
 
 # License: MIT
 
 .\solrssl.ps1 -KeystoreFile C:\Solr\apache-solr\server\etc\solr-ssl.keystore.jks