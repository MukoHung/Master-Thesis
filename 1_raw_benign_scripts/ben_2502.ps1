
Enum BookCategory {
    GeneralFiction
    Horror
    Romance
    Literary
    Mystery
    Thriller
    ScienceFiction
    NonFiction
}

Class myBook {

[ValidateNotNullorEmpty()][string]$Title
[ValidateNotNullorEmpty()][string]$Author
[datetime]$PublishedDate = (Get-Date).AddDays(- (Get-Random -Minimum 100 -Maximum 1000))
[BookCategory]$Category = [BookCategory]::GeneralFiction
[ValidateNotNullorEmpty()][int]$PageCount
[string]$Owner = $env:USERNAME
hidden [datetime]$PurchaseDate = (Get-Date)
hidden [int]$PagesRead

#methods
[void]Sell([string]$NewOwnerName) {
    $this.Owner = $NewOwnerName
    $this.PurchaseDate = (Get-Date)
    $this.PagesRead = 0
}

[void]Read([int]$Pages) {
  if ($this.GetProgress() -eq 100) {
    Write-Host "You have finished this book." -ForegroundColor Magenta
  }
  else {
    Write-Verbose "Reading $pages"
    $this.PagesRead+=$pages
  }
}

[int]GetProgress() {
  $r = ($this.PagesRead/$this.PageCount)*100
  If ($r -ge 100) {
    return 100
  }
  else {
    Return $r
  }
}

[timespan]GetPublishedAge() {
  $t = (Get-Date) - $this.PublishedDate
  return $t
}

[timespan]GetLibraryAge() {
 $t = (Get-Date) - $this.PurchaseDate
 return $t
}

#constructor
myBook ([string]$Title,[string]$Author,[int]$PageCount) {
    $this.Title = $Title
    $this.Author = $Author
    $this.PageCount = $PageCount
}

} #class

#$book = New-Object myBook -ArgumentList "I am the Walrus","Anonymous",123  

Function New-Book {
Param(
[string]$Title,[string]$Author,[int]$PageCount,[bookCategory]$Category
)

$book = New-Object myBook -ArgumentList $Title,$author,$PageCount
$book.Category = $Category
$book

}  
Function Set-Book {
[CmdletBinding(DefaultParameterSetName="read")]
param(
[Parameter(ValueFromPipeline)]
[myBook]$Book,
[Parameter(ParameterSetName="read")]
[int]$PagesRead =1,
[Parameter(ParameterSetName="modify")]
[bookCategory]$Category,
[Parameter(ParameterSetName="sell")]
[string]$NewOwner,
[switch]$Passthru
)

Begin {}
Process {
  Switch ($PSCmdlet.ParameterSetName) {

  "sell" { $book.Sell($NewOwner)}
  "read" { $book.Read($pagesRead) }
  "modify" { $book.Category = $Category}
  }

  if ($Passthru) {
    $book
  }
}
End {}
}
Function Get-Book {
[cmdletbinding()]
Param(
[Parameter(valueFromPipeline)]
[myBook]$Book
)
begin {}
Process {
  $book | Select Title,Author,Category,PageCount,
  @{Name="PagesRead";Expression = {$_.pagesread}},
  @{Name="Progress";Expression = {"$($_.getProgress())%"}},
  @{Name="LibraryAge";Expression = {$_.getLibraryAge()}}
}
end {}
}

<#
$bk = New-Book -title "Life is Hard" -author "Leo Tolstoy" -pageCount 700 -category 'Literary'
$bk
$bk | set-book -pagesread 30 -verbose
$bk | set-book -pagesread 3 -passthru

$bk | get-book

$bk | set-book -newowner Lars -pass | get-book

#>
