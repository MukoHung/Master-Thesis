<#

# �R���e���c�̃f�[�^�`��

HTTP���X�|���X�Ŏ�M����R���e���c�̃f�[�^�`���ɂ��āA�������Ă����܂��B
JSON�̓��N�G�X�g���ɂ��g�p����ꍇ����B
����������ƁAXML�Ń��N�G�X�g���邱�Ƃ����蓾�邩���B

## HTML

ConvertTo-Html�R�}���h���b�g

- ConvertFrom-Html�͑��݂��Ȃ��B
- [ConvertTo-Html (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/convertto-html)

COM���g�p���āAHTML���p�[�X������@�ł��B

#>
$sample = "<html><head><title>�T���v��</title></head>" +
  "<body><span id='text1' name='text1'>�T���v���y�[�W�ł��B</span></body></html>"
$html = New-Object -com "HTMLFILE"
$html.IHTMLDocument2_write($sample)
$html.Close()
echo $html.title
echo $html.getElementById("text1").innerText
$html.getElementsByName("text1") | %{ echo $_.innerText }
$html.getElementsByTagName("span") | %{ echo $_.innerText }
<#

## XML

.NET Framework �� XmlDocument�N���X���g�p���āAXML�̉�͂�g�ݗ��Ă��s���Ă݂܂����B

- .NET Framework 1.1 �ȍ~�iPowerShell 1.0 �ȍ~�j
- [XmlDocument �N���X (System.Xml) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.xml.xmldocument)

#>
# XML�I�u�W�F�N�g�̍쐬
$doc = New-Object System.Xml.XmlDocument
$doc.AppendChild($doc.CreateXmlDeclaration("1.0", "utf-8", $null)) | Out-Null
$root = $doc.AppendChild($doc.CreateElement("Root"))
$item1 = $root.AppendChild($doc.CreateElement("Item1"))
$item1.AppendChild($doc.CreateTextNode("text")) | Out-Null
# ������\��
Write-Output $doc.OuterXml
# �t�@�C���ɕۑ��iBOM�t��UTF8�j
$doc.Save('D:\tmp\tmp.xml')

# XML������̓ǂݍ���
$doc = [Xml]'<?xml version="1.0" encoding="utf-8"?><Root><Item1>text</Item1></Root>'
$doc = [System.Xml.XmlDocument]'<?xml version="1.0" encoding="utf-8"?><Root><Item1>text</Item1></Root>'
Write-Output $doc.Root.Item1 

# XML�t�@�C������ǂݍ��� 
$doc = New-Object System.Xml.XmlDocument 
$doc.Load('D:\tmp\tmp.xml') 
Write-Output $doc.Root.Item1
<#

## JSON

ConvertFrom-Json�R�}���h���b�g�AConvertTo-Json�R�}���h���b�g�𗘗p���܂����B

- PowerShell 3.0 �ȍ~
- [ConvertFrom-Json (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/convertfrom-json)
- [ConvertTo-Json (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/convertto-json)

#>
# �I�u�W�F�N�g��JSON������ɕϊ��BDepth�̍ő�l��100
$jsonstr = ConvertTo-Json -Depth 100 @{
  Number = 123;
  String = '���{�� �L��''"{}<>';
  DateTimeStr = Get-Date -Format "yyyy/MM/dd HH:mm:ss";
  Array = @(1,2,3);
  Hash = @{Key1="value1"; Key2="value2"};
  Null = $null;
}
# JSON��������I�u�W�F�N�g�ɕϊ�
$jsonobj = ConvertFrom-Json '{"Number":123, "String":"���{�� �L��''\"{}<>", "DateTimeStr":"2021/1/1 01:02:03", "Array":[1,2,3], "Hash":{"Key1":"value1", "Key2":"value2"}, "Null":null}'
# MakeMd SKIP_START
$jsonstr
$jsonobj
# MakeMd SKIP_END
<#

��L���ƁAPowerShell 3.0 �ȍ~�łȂ��Ɠ��삵�Ȃ��̂ŁA�Â����ł����삷��悤�ɁA�ȈՓI�Ȋ֐����l���Ă݂܂����B
�������A�n�b�V���f�[�^��JSON������ɕϊ�����֐��̂݁B���̋t�̕ϊ��́A��Ԃ������肻���Ȃ̂Ŋ����B

#>
function ConvertToJson($data) {
  if ($data -is [string]) {
    '"' + $data + '"'
  } elseif ($data -is [Array]) {
    $arr = $data | %{
      ConvertToJson $_
    }
    '[' + ($arr -join ', ') + ']'
  } elseif ($data -is [Hashtable]) {
    $arr = $data.GetEnumerator() | sort Key | %{
      '"' + $_.Key + '": ' + (ConvertToJson $_.Value)
    }
    '{' + ($arr -join ', ') + '}'
  } else {
    $data
  }
}
$hash = @{
  Number = 123;
  String = "abc";
  Array = @(1,2,3,@(4,5));
  Hash = @{Key1="value1"; Key2="value2"};
}
$jsonstr = ConvertToJson $hash
# MakeMd SKIP_START
$jsonstr
# MakeMd SKIP_END
