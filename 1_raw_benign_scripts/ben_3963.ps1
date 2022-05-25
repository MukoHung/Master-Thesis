#region Module Builder
$Domain = [AppDomain]::CurrentDomain
$DynAssembly = New-Object System.Reflection.AssemblyName(([guid]::NewGuid().ToString()))
$AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run) # Only run in memory
$ModuleBuilder = $AssemblyBuilder.DefineDynamicModule(([guid]::NewGuid().ToString()), $False)
#endregion Module Builder
#region STRUCTs
#Order of creating these Structs is important
#region MyStruct
$Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
$STRUCT_TypeBuilder = $ModuleBuilder.DefineType('Person', $Attributes, [System.ValueType], 8)
$FirstName_Field = $STRUCT_TypeBuilder.DefineField('FirstName', [string], 'Public')
$LastName_Field = $STRUCT_TypeBuilder.DefineField('LastName', [string], 'Public')
$Age_Field = $STRUCT_TypeBuilder.DefineField('Age', [int], 'Public')
 
#region Constructors
#Default Constructor
$ObjType = [Type]::GetType('System.Object')
$ctor = $ObjType.GetConstructor([type]::EmptyTypes)
$ConstructorBuilder = $STRUCT_TypeBuilder.DefineConstructor('Public', [System.Reflection.CallingConventions]::Standard, @())
$ILGen = $ConstructorBuilder.GetILGenerator()
$ILGen.Emit([Reflection.Emit.OpCodes]::Ldarg,0)
$ILGen.Emit([Reflection.Emit.OpCodes]::Call, $ctor)
$ILGen.Emit([Reflection.Emit.OpCodes]::Ret)
 
#First, Last and Age Constructor
$ObjType = [Type]::GetType('System.Object')
$ctor = $ObjType.GetConstructor([type]::EmptyTypes)
$ConstructorBuilder = $STRUCT_TypeBuilder.DefineConstructor('Public', [System.Reflection.CallingConventions]::Standard, @([string], [string], [int]))
$ILGen = $ConstructorBuilder.GetILGenerator()
$ILGen.Emit([Reflection.Emit.OpCodes]::Ldarg,0)
$ILGen.Emit([Reflection.Emit.OpCodes]::Call, $ctor)
$ILGen.Emit([Reflection.Emit.OpCodes]::Ldarg, 0)
$ILGen.Emit([Reflection.Emit.OpCodes]::Ldarg, 1)
$ILGen.Emit([Reflection.Emit.OpCodes]::Stfld, $FirstName_Field)
$ILGen.Emit([Reflection.Emit.OpCodes]::Ldarg, 0)
$ILGen.Emit([Reflection.Emit.OpCodes]::Ldarg, 2)
$ILGen.Emit([Reflection.Emit.OpCodes]::Stfld, $LastName_Field)
$ILGen.Emit([Reflection.Emit.OpCodes]::Ldarg, 0)
$ILGen.Emit([Reflection.Emit.OpCodes]::Ldarg, 3)
$ILGen.Emit([Reflection.Emit.OpCodes]::Stfld, $Age_Field)
$ILGen.Emit([Reflection.Emit.OpCodes]::Ret)
#endregion Constructors
 
#region Methods
#FirstName
$Method = $STRUCT_TypeBuilder.DefineMethod('_GetFirstName','Private', ([int]), $Null)
$MethodIL = $Method.GetILGenerator()
$MethodIL.Emit([Reflection.Emit.OpCodes]::Ldfld, $FirstName_Field)
$MethodIL.Emit([Reflection.Emit.OpCodes]::Ret)
 
#LastName
$Method = $STRUCT_TypeBuilder.DefineMethod('_GetLastName','Private', ([int]), $Null)
$MethodIL = $Method.GetILGenerator()
$MethodIL.Emit([Reflection.Emit.OpCodes]::Ldfld, $LastName_Field)
$MethodIL.Emit([Reflection.Emit.OpCodes]::Ret)
 
#Age
$Method = $STRUCT_TypeBuilder.DefineMethod('_GetAge','Private', ([int]), $Null)
$MethodIL = $Method.GetILGenerator()
$MethodIL.Emit([Reflection.Emit.OpCodes]::Ldfld, $Age_Field)
$MethodIL.Emit([Reflection.Emit.OpCodes]::Ret)
#endregion Methods
 
[void]$STRUCT_TypeBuilder.CreateType()
#endregion MyStruct

#Test it out
[Person]::New('Boe','Prox',36)
<#
FirstName LastName Age
--------- -------- ---
Boe       Prox      36
#>