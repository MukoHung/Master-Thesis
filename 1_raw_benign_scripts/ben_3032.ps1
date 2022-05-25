# Copyright (c) Rafael Rivera
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Add-Type -TypeDefinition @"
// Copyright (c) Damien Guard. All rights reserved.
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Originally published at http://damieng.com/blog/2006/08/08/calculating_crc32_in_c_and_net
 
using System;
using System.Collections.Generic;
using System.Security.Cryptography;
 
public sealed class Crc32 : HashAlgorithm
{
   public const UInt32 DefaultPolynomial = 0xedb88320u;
   public const UInt32 DefaultSeed = 0xffffffffu;
 
   static UInt32[] defaultTable;
 
   readonly UInt32 seed;
   readonly UInt32[] table;
   UInt32 hash;
 
   public Crc32()
       : this(DefaultPolynomial, DefaultSeed)
   {
   }
 
   public Crc32(UInt32 polynomial, UInt32 seed)
   {
       table = InitializeTable(polynomial);
       this.seed = hash = seed;
   }
 
   public override void Initialize()
   {
       hash = seed;
   }
 
   protected override void HashCore(byte[] array, int ibStart, int cbSize)
   {
       hash = CalculateHash(table, hash, array, ibStart, cbSize);
   }
 
   protected override byte[] HashFinal()
   {
       var hashBuffer = UInt32ToBigEndianBytes(~hash);
       HashValue = hashBuffer;
       return hashBuffer;
   }
 
   public override int HashSize { get { return 32; } }
       
   public static UInt32 Compute(byte[] buffer)
   {
       return Compute(DefaultSeed, buffer);
   }
 
   public static UInt32 Compute(UInt32 seed, byte[] buffer)
   {
       return Compute(DefaultPolynomial, seed, buffer);
   }
 
   public static UInt32 Compute(UInt32 polynomial, UInt32 seed, byte[] buffer)
   {
       return ~CalculateHash(InitializeTable(polynomial), seed, buffer, 0, buffer.Length);
   }
 
   static UInt32[] InitializeTable(UInt32 polynomial)
   {
       if (polynomial == DefaultPolynomial && defaultTable != null)
           return defaultTable;
 
       var createTable = new UInt32[256];
       for (var i = 0; i < 256; i++)
       {
           var entry = (UInt32)i;
           for (var j = 0; j < 8; j++)
               if ((entry & 1) == 1)
                   entry = (entry >> 1) ^ polynomial;
               else
                   entry = entry >> 1;
           createTable[i] = entry;
       }
 
       if (polynomial == DefaultPolynomial)
           defaultTable = createTable;
 
       return createTable;
   }
 
   static UInt32 CalculateHash(UInt32[] table, UInt32 seed, IList<byte> buffer, int start, int size)
   {
       var crc = seed;
       for (var i = start; i < size - start; i++)
           crc = (crc >> 8) ^ table[buffer[i] ^ crc & 0xff];
       return crc;
   }
 
   static byte[] UInt32ToBigEndianBytes(UInt32 uint32)
   {
       var result = BitConverter.GetBytes(uint32);
 
       if (BitConverter.IsLittleEndian)
           Array.Reverse(result);
 
       return result;
   }
}
"@ -PassThru | Out-Null
 
function Get-Crc32
{
    Param (
        [Parameter(ValueFromPipeline)]
        [byte[]]$buffer
    )

    $crc32 = New-Object Crc32
    return $crc32.ComputeHash($buffer)
}

function Set-XboxPartitionAttributes()
{
    Param (
      [parameter(ValueFromPipeline)]
      $disk
    )

    # Read enough sector data to cover the GPT header and partition entries
    $reader = New-Object System.IO.BinaryReader([IO.File]::Open($disk.Path, "Open", "Read", "ReadWrite"))
    $reader.BaseStream.Position = 0
    $sectorData = $reader.ReadBytes(32768)
    $reader.Close()
    $reader.Dispose()

    # Zero out CRCs
    [Array]::Copy([byte[]]@(0) * 4, 0, $sectorData, 512 + 16, 4) # Header
    [Array]::Copy([byte[]]@(0) * 4, 0, $sectorData, 512 + 88, 4) # Partition array

    # Set Disk GUID
    $guidBytes = ([Guid]::Parse($XboxDisk.Guid)).ToByteArray()
    [Array]::Copy($guidBytes, 0, $sectorData, 512 + 56, $guidBytes.Length)

    # Adjust partition attributes
    for($i = 0; $i -lt $XboxDisk.Partitions.Count; $i++) {
        $partition = $XboxDisk.Partitions[$i]

        # Adjust partition GUID
        $guidBytes = ([Guid]::Parse($partition.Guid)).ToByteArray()
        [Array]::Copy($guidBytes, 0, $sectorData, 1024 + (128 * $i) + 16, $guidBytes.Length)

        # Adjust partition name (36 UTF16 LE units)
        $stringBytes = [Text.Encoding]::Unicode.GetBytes($partition.Name.PadRight(36, "`0"))
        [Array]::Copy($stringBytes, 0, $sectorData, 1024 + (128 * $i) + 56, $stringBytes.Length)
    }

    # Compute partition array CRC
    $partitionArrayCrc = Get-Crc32 $sectorData[1024..17407]
    [array]::Reverse($partitionArrayCrc)
    # Write-Host "Part. CRC: " ([BitConverter]::ToString($partitionArrayCrc))
    [Array]::Copy($partitionArrayCrc, 0, $sectorData, 512 + 88, $partitionArrayCrc.Length)

    $headerCrc = Get-Crc32 $sectorData[512..603]
    [array]::Reverse($headerCrc)
    # Write-Host "Header CRC: " ([BitConverter]::ToString($headerCrc))
    [Array]::Copy($headerCrc, 0, $sectorData, 512 + 16, $headerCrc.Length)

    # Write it all out to disk
    $writer = New-Object System.IO.BinaryWriter([IO.File]::Open($disk.Path, "Open", "Write", "ReadWrite"))
    $writer.Write($sectorData)

    # Write the backup GPT header, with LBAs swapped, to the last sector too
    $primaryLba = $sectorData[536..543]
    $backupLba = $sectorData[544..551]
    [Array]::Copy($backupLba, 0, $sectorData, 536, $primaryLba.Length)
    [Array]::Copy($primaryLba, 0, $sectorData, 544, $backupLba.Length)
    
    $writer.BaseStream.Seek($disk.Size - $disk.PhysicalSectorSize, "Begin")
    $writer.Write($sectorData[512..1024], 0, 512)

    $writer.Close()
    $writer.Dispose()
}

$XboxDisk = @"
{
    "Partitions": [
        {
            Name: "Temp Content",
            Guid: "{b3727da5-a3ac-4b3d-9fd6-2ea54441011b}",
            Size: 44023414784
        },

        {
            Name: "User Content",
            Guid: "{869bb5e0-3356-4be6-85f7-29323a675cc7}",
            Size: 0
        },

        {
            Name: "System Support",
            Guid: "{c90d7a47-ccb9-4cba-8c66-0459f6b85724}",
            Size: 42949672960
        },

        {
            Name: "System Update",
            Guid: "{9a056ad7-32ed-4141-aeb1-afb9bd5565dc}",
            Size: 12884901888
        },

        {
            Name: "System Update 2",
            Guid: "{24b2197c-9d01-45f9-a8e1-dbbcfa161eb2}",
            Size: 7516192768
        }
    ],

    Guid: "{a2344bdb-d6de-4766-9eb5-4109a12228e5}"
}
"@ | ConvertFrom-Json

# Change to match desired disk.
# There will be no data loss warnings so choose wisely.
$diskId = -42

If($diskId -lt 0)
{
  Write-Error "`$diskId must be changed to match the correct disk number (see below)."
  Get-Disk
  return
}

$disk = Get-Disk $diskId

$disk | Clear-Disk -RemoveData -Confirm:$False
$disk | Initialize-Disk -PartitionStyle GPT -Confirm:$False

# Remove the unwanted MSR partition
$disk | Get-Partition | Remove-Partition -Confirm:$False

$XboxDisk.Partitions[1].Size = [Math]::Truncate(
    $disk.LargestFreeExtent - ($XboxDisk.Partitions | Select -ExpandProperty Size | Measure-Object -Sum | Select -ExpandProperty Sum))

foreach($partition in $XboxDisk.Partitions) {
    $disk | New-Partition -Size $partition.Size -AssignDriveLetter |
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $partition.Name -Force
}

$disk | Set-XboxPartitionAttributes