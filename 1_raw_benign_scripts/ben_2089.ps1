#
# �������� ��������� ���������� IP ������� �� �����. ������� CheckIpAddress.exe
#
#[Green] + ������� ������� ��� ����� "����� IP"
clear

.\IPRangeCheck.ps1 -NetMask 1.0.1.1 -IP 1.0.1.1 -ExpErrLev 0
.\IPRangeCheck.ps1 -NetMask 1.0.1.1 -IP 1.0.1.1 -ExpErrLev 2 -inv

.\IPRangeCheck.ps1 -NetMask 127.0.0.0 -IP 127.0.0.0 -ExpErrLev 0
.\IPRangeCheck.ps1 -NetMask 127.0.0.0 -IP 127.0.0.0 -ExpErrLev 2 -Inv

.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 1.1.1.1 -ExpErrLev 2
.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 1.1.1.1 -ExpErrLev 0 -Inv

.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 255.255.255.255 -ExpErrLev 2
.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 255.255.255.255 -ExpErrLev 0 -Inv

.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 255.255.255.255 -ExpErrLev 0 -Inv
.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 255.255.255.255 -ExpErrLev 2

.\IPRangeCheck.ps1 -NetMask 1.0.1.1 -IP 1.0.1.1 -ExpErrLev 2 -inv
.\IPRangeCheck.ps1 -NetMask 1.0.1.1 -IP 1.0.1.1 -ExpErrLev 0

.\IPRangeCheck.ps1 -NetMask 4.255.2.1 -IP 0.0.0.0 -ExpErrLev 2
.\IPRangeCheck.ps1 -NetMask 4.255.2.1 -IP 0.0.0.0 -ExpErrLev 0 -Inv

.\IPRangeCheck.ps1 -NetMask 4.255.2.1 -IP 00005.00006.00007.0008 -ExpErrLev 2
.\IPRangeCheck.ps1 -NetMask 4.255.2.1 -IP 00005.00006.00007.0008 -ExpErrLev 0 -Inv

.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 0.0.0.0 -ExpErrLev 0
.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 0.0.0.0 -ExpErrLev 2 -Inv

.\IPRangeCheck.ps1 -NetMask 255.255.255.255 -IP 255.255.255.255 -ExpErrLev 0
.\IPRangeCheck.ps1 -NetMask 255.255.255.255 -IP 255.255.255.255 -ExpErrLev 2 -inv

.\IPRangeCheck.ps1 -NetMask 255.255.255.255 -IP 0.0.0.0 -ExpErrLev 2
.\IPRangeCheck.ps1 -NetMask 255.255.255.255 -IP 0.0.0.0 -ExpErrLev 0 -Inv

.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 255.255.255.255 -ExpErrLev 2
.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 255.255.255.255 -ExpErrLev 0 -Inv


.\IPRangeCheck.ps1 -NetMask 255.255.255.255 -IP 0.0.0.255 -ExpErrLev 2 -ExeptMasks "*.*.*.255;*.*.*.0000255"
.\IPRangeCheck.ps1 -NetMask 255.255.255.255 -IP 0.0.0.255 -ExpErrLev 0 -Inv -ExeptMasks "*.*.*.255;*.*.*.0000255"

.\IPRangeCheck.ps1 -NetMask 4.255.2.1 -IP 0.0.0.0 -ExpErrLev 0 -Inv
.\IPRangeCheck.ps1 -NetMask 4.255.2.1 -IP 0.0.0.0 -ExpErrLev 2

.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 256.0.0.0 -ExpErrLev 3 -Inv 
.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 256.0.0.0 -ExpErrLev 3 -ExeptMasks "*;*.*;*.*.*;*.*.*.*"

.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 0.333.0.0 -ExpErrLev 3 -Inv 
.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 0.333.0.0 -ExpErrLev 3 -ExeptMasks "*;*.*;*.*.*;*.*.*.*"

.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 0.0.666.0 -ExpErrLev 3 -Inv 
.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 0.0.666.0 -ExpErrLev 3 -ExeptMasks "*;*.*;*.*.*;*.*.*.*"

.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 0.0.0.256 -ExpErrLev 3 -Inv 
.\IPRangeCheck.ps1 -NetMask 0.0.0.0 -IP 0.0.0.256 -ExpErrLev 3 -ExeptMasks "*;*.*;*.*.*;*.*.*.*"

.\IPRangeCheck.ps1 -NetMask 111111.666.11111.11111 -IP 0.0.0.0 -ExpErrLev 4 -Inv
.\IPRangeCheck.ps1 -NetMask 111111.666.11111.11111 -IP 0.0.0.0 -ExpErrLev 4

.\IPRangeCheck.ps1 -NetMask 127.0.0.0 -IP 126.0.0.100 -ExpErrLev 0 -Inv -ExeptMasks "*.0.0.*;*.00000.00000000.*;*.0.*.*;*.000000.*.*;*.*.0.*;*.*.00000.*"
.\IPRangeCheck.ps1 -NetMask 127.0.0.0 -IP 126.0.0.100 -ExpErrLev 2 -ExeptMasks "*.0.0.*;*.00000.00000000.*;*.0.*.*;*.000000.*.*;*.*.0.*;*.*.00000.*"

.\IPRangeCheck.ps1 -NetMask -1.-1.-1.-1 -IP 255.255.255.255 -ExpErrLev 4 -Inv
.\IPRangeCheck.ps1 -NetMask -1.-1.-1.-1 -IP 255.255.255.255 -ExpErrLev 4

.\IPRangeCheck.ps1 -NetMask -1.-1.-1.-1 -IP 1.1.1.1 -ExpErrLev 4 -Inv
.\IPRangeCheck.ps1 -NetMask -1.-1.-1.-1 -IP 1.1.1.1 -ExpErrLev 4

.\IPRangeCheck.ps1 -NetMask 1.1.1.1 -IP 1.1.-100000.1 -ExpErrLev 3 -ExeptMasks "*;*.*;*.*.*;*.*.*.*"
.\IPRangeCheck.ps1 -NetMask 1.1.1.1 -IP 1.1.-100000.1 -ExpErrLev 3 -Inv -ExeptMasks "*;*.*;*.*.*;*.*.*.*"

.\IPRangeCheck.ps1 -NetMask 1.1.1.1 -IP -1.1.1.1 -ExpErrLev 3 -ExeptMasks "*;*.*;*.*.*;*.*.*.*"
.\IPRangeCheck.ps1 -NetMask 1.1.1.1 -IP -1.1.1.1 -ExpErrLev 3 -Inv -ExeptMasks "*;*.*;*.*.*;*.*.*.*"

.\IPRangeCheck.ps1 -NetMask 1.1.1.1 -IP 1.-1.1.1 -ExpErrLev 3 -ExeptMasks "*;*.*;*.*.*;*.*.*.*"
.\IPRangeCheck.ps1 -NetMask 1.1.1.1 -IP 1.-1.1.1 -ExpErrLev 3 -Inv -ExeptMasks "*;*.*;*.*.*;*.*.*.*"

.\IPRangeCheck.ps1 -NetMask 1.1.1.1 -IP 1.1.-1.1 -ExpErrLev 3 -ExeptMasks "*;*.*;*.*.*;*.*.*.*"
.\IPRangeCheck.ps1 -NetMask 1.1.1.1 -IP 1.1.-1.1 -ExpErrLev 3 -Inv -ExeptMasks "*;*.*;*.*.*;*.*.*.*"

.\IPRangeCheck.ps1 -NetMask 1.1.1.1 -IP 1.1.1.-1 -ExpErrLev 3 -ExeptMasks "*;*.*;*.*.*;*.*.*.*"
.\IPRangeCheck.ps1 -NetMask 1.1.1.1 -IP 1.1.1.-1 -ExpErrLev 3 -Inv -ExeptMasks "*;*.*;*.*.*;*.*.*.*"

.\IPRangeCheck.ps1 -NetMask a.a.a.a -IP -1.1.1.1 -ExpErrLev 4 -Inv -ExeptMasks "*;*.*;*.*.*;*.*.*.*"
.\IPRangeCheck.ps1 -NetMask a.a.a.a -IP -1.1.1.1 -ExpErrLev 4 -ExeptMasks "*;*.*;*.*.*;*.*.*.*"

.\IPRangeCheck.ps1 -NetMask 1.1.1.1 -IP 1.1.-1.1 -ExpErrLev 3 -ExeptMasks "*;*.*;*.*.*;*.*.*.*"
.\IPRangeCheck.ps1 -NetMask 1.1.1.1 -IP 1.1.-1.1 -ExpErrLev 3 -Inv -ExeptMasks "*;*.*;*.*.*;*.*.*.*"

.\IPRangeCheck.ps1 -NetMask 4.255.2.1 -IP 4.3.2.1 -ExpErrLev 2 -ExeptMasks "4.*;000004.*;4.*.*;00004.*.*;4.*.*.1;00004.*.*.000001;4.*.*.*;00004.*.*.*;*.*.*.1;*.*.*.00001;*.*.2.1;*.*.00002.00001;4.*.2.1;0004.*.0002.0001;*.*.2.*;*.*.00002.*"
.\IPRangeCheck.ps1 -NetMask 4.255.2.1 -IP 4.3.2.1 -ExpErrLev 2 -inv -ExeptMasks "4.255.2.1;0004.000255.0002.0001;04.255.2.1;004.255.2.1;0004.255.2.1;4.0255.2.1;4.00255.2.1;4.255.00002.1;4.255.2.00000001;4.255.*.*;00004.00000255.*.*;*.255.2.1;*.0000255.00002.00001;4.255.*.1;00004.0000255.*.00001;4.255.2.*;00004.000255.0002.*;*.255.*.1;*.00255.*.001;*.255.2.*;*.0000255.00000002.*;*.255.*.*;*.00000255.*.*"


break
#[������ ����� �������]






# [Not All Green]
.\IPRangeCheck.ps1 -NetMask 4.255.2.1 -IP 4.3.2.1 -ExpErrLev 0


# Errors
# [�� ������ ���� ������� � ������. ������ ���� �� ���������]

# .\IPRangeCheck.ps1 -NetMask 10.20.10.10 -IP 10.10.10.10 -ExpErrLev 2 -Inv