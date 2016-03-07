<#
.SYNOPSIS
Get PrivatBank exchange rate for USD/UAH

.DESCRIPTION
Performs WebRequset to capture https://privatbank.ua/ html page and parse USD/UAH exchange rate for purchase by Card.
Multiplies this rate by supplied int

.PARAMETER USD
Specify amount of dollars to convert

.EXAMPLE
Get-PBExchangeRate -Currency USD 20
Converts USD to UAH and returns amount of UAH
#>
function Get-PBExchangeRate {
	#[CmdletBinding()]
	param(
		#[Parameter(Mandatory=$true)]
		[double]$Amount = 1.0,

		[ValidateSet('USD', 'EUR')]
		[string]$Currency = 'USD'
	)

	try
	{
		$uri = "https://privatbank.ua/"
		#Retrieve course exchange table from selectByCard body of course-table-pb table
		$html = Invoke-WebRequest -Uri $uri
		$tr = $html.ParsedHtml.getElementById("selectByCard").childNodes | Where-Object { $_.tagName -eq "tr" }
		$td = $tr.childNodes | Where-Object { $_.tagName -eq "td" }

		#Collect all data from this table (for future use - converting values for all currency types)
		$course = @()
		foreach ($item in $td) { $course += $item.innerText }
		#Get USD/UAH buy rate - number 5 for USD, number 2 for EUR
		switch ($Currency) {
			'USD'	{ $exch = $course.Get(5) -as [double] }
			'EUR'	{ $exch = $course.Get(2) -as [double] }
		}

		#Multiply by amount
		$result = $Amount * $exch
		Write-Output "Exchange rate: $exch"
		Write-Output "UAH $result"
	} catch [System.Exception]	{
		Write-Error -Message "https://privatbank.ua/ is not accessible" -Category ConnectionError
	}
} ; New-Alias -Name pb -Value Get-PBExchangeRate