function ConvertFrom-Option119Hex
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string[]]
        $Hex
    )

    function hexToDomain 
    {
        param
        (
            [ValidateNotNullOrEmpty()]
            [int]
            $Pointer,

            [string[]]
            $Hex
        )

        [string] $domain = ''

        #Domain name will begin after first byte cointaining it's length
        $domainStrStart = $Pointer + 1

        #Doimani lengs is in first byte
        $domainStrEnd = [int]$Hex[$Pointer] + $Pointer

        $hex[$domainStrStart..$domainStrEnd].ForEach{ $domain = "{0}{1}" -f $domain,[char][byte]$_ }

        $nextPointer = $domainStrEnd + 1
        $nextByte = $Hex[$nextPointer]

        <#
            If followed by 0x00 domain name is complete. Return Domain and pointer to next domain.
            If domain is foloved by 0xC0 next byte is a pointer to concateneted domain name.
            Appent this domain name. Domain name is complete. Return it and pointer to next domain. 
            If followed by a number next domain part should be added.
            According to https://tools.ietf.org/search/rfc1035#section-4.1.4
        #>
        if ($nextByte -eq '0xC0')
        {
            $nextResultHash = hexToDomain -Pointer ([int]$Hex[$nextPointer + 1]) -Hex $Hex
            $domain = "{0}.{1}" -f $domain, $nextResultHash.Result
            $resultHash = @{Result = $domain; Pointer = $nextPointer +1}
            $resultHash
        }
        elseif ($nextByte -eq '0x00')
        {
            $resultHash = @{Result = $domain; Pointer = $nextPointer}
            $resultHash
        }
        else
        {
            $nextResultHash = hexToDomain -Pointer ($nextPointer) -Hex $Hex
            $domain = "{0}.{1}" -f $domain, $nextResultHash.Result
            $resultHash = @{Result = $domain; Pointer = $nextResultHash.Pointer}
            $resultHash
        }
    }

    function option119toDomain
    {
        param
        (
            [ValidateNotNullOrEmpty()]
            [int]
            $Pointer,

            [string[]]
            $Hex
        )

        [string[]] $domains = @()
        $resultHash = hexToDomain -Pointer $Pointer -Hex $Hex
        $domains += $resultHash.Result

        $nextPointer = $resultHash.Pointer + 1
        <#
            If next pointer is null return domain arrays.
            If next pointer is number look for new domain.
        #>
        if ($Hex[$nextPointer] -eq $null)
        {
            $domains
        }
        else
        {
            $domains += option119toDomain -Pointer $nextPointer -Hex $Hex
            $domains
        }
        
    }


    $result = option119toDomain -Pointer 0 -Hex $Hex
    $result
}