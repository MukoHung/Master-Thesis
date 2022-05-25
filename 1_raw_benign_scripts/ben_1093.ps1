name: <container_group_name>
apiVersion: '2018-10-01'
location: '<location>'
tags: {}
properties:
  containers:
  - name: <container_name>
    properties:
      image: pihole/pihole:latest
      ports:
      - protocol: UDP
        port: 53
      - protocol: UDP
        port: 67
      - protocol: TCP
        port: 80
      - protocol: TCP
        port: 443
      environmentVariables:
      - name: TZ
        value: Asia/Kolkata
      - name: WEBPASSWORD
        value: <custom_large_string>
      resources:
        requests:
          memoryInGB: 1
          cpu: 1
      volumeMounts:
      - name: pihole
        mountPath: /etc/pihole/
        readOnly: false
      - name: dnsmasq
        mountPath: /etc/dnsmasq.d/
        readOnly: false
  restartPolicy: Always
  ipAddress:
    ports:
    - protocol: UDP
      port: 53
    - protocol: UDP
      port: 67
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
    type: public
    dnsNameLabel: <custom_dnsname>
  osType: Linux
  volumes:
  - name: pihole
    azureFile:
      shareName: etc-pihole
      readOnly: false
      storageAccountName: <storage_name>
      storageAccountKey: <value of $STORAGE_KEY>
  - name: dnsmasq
    azureFile:
      shareName: etc-dnsmasq
      readOnly: false
      storageAccountName: <storage_name>
      storageAccountKey: <value of $STORAGE_KEY>
