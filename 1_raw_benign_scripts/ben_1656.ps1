### [Pass the Ticket (T1097)](https://attack.mitre.org/wiki/Technique/T1097)
#### Collection
Get-KerberosTicketGrantingTicket is a PowerShell script that queries each Logon Session for their associated Kerberos Ticket Granting Ticket. The output object contains information about the ticket itself, as well as, the Logon Session to which it belongs.
#### Detections
Test-KerberosTicketGrantingTicket is a script that provides a set of Unit Tests for "normal" Ticket Granting Ticket behavior. Below you will find a list of detections that are being used by the test script.
* Logon Session User != Ticket Client
* Ticket Lifetime != Expected Lifetime (Default 10 hours)
* Ticket Renewal Length != Expected Renewal Length (Default 7 days)
* Encryption Type != aes256_cts_hmac_sha1_96 (rc4 is common for inter-forest/domain tickets)
* Session Authentication Package == (Kerberos || Negotiate)

Some of these detections are more behavior focused than others. For instance, a Golden Ticket made by Mimikatz with default arguments will have a 10 year Ticket Lifetime and Renewal Length, but Mimikatz also provides a command line option to set these values however the attacker pleases. Alternatively, a Logon Session should typically have a ticket for the user for whom the Logon Session belongs to.

I'd love to hear how accurate these detections are in production.