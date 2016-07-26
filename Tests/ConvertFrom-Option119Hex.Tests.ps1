. "$((Get-Item $PsScriptRoot).Parent.FullName)\Functions\ConvertFrom-Option119Hex.ps1"

Describe 'ConvertFrom-Option119Hex.ps1' {
    It 'Converts hex to domain' {
        $hex = '0x07', '0x63', '0x6F', '0x6E', '0x74', '0x6F', '0x73', '0x6F', '0x03', '0x63', '0x6F', '0x6D', '0x00'

        $result = ConvertFrom-Option119Hex -Hex $hex
        
        $result | Should Be 'contoso.com'
    }

    It 'Converts hex with multiple domains' {
        $hex = '0x07', '0x63', '0x6F', '0x6E', '0x74', '0x6F', '0x73', '0x6F', '0x03', '0x63', '0x6F', '0x6D', '0x00',
            '0x07', '0x65', '0x78', '0x61', '0x6D', '0x70', '0x6C', '0x65', '0x03', '0x6F', '0x72', '0x67', '0x00'
        
        #join domains to one string because Pester can't compare arrays
        $expectedresult = @('contoso.com', 'example.org') -join ' '

        $result = (ConvertFrom-Option119Hex -Hex $hex) -join ' '

        $result | Should Be $expectedresult
    }

    It 'Converts hex that uses pointer for compression' {
        $hex = '0x07', '0x63', '0x6F', '0x6E', '0x74', '0x6F', '0x73', '0x6F', '0x03', '0x63', '0x6F', '0x6D', '0x00',
            '0x07', '0x65', '0x78', '0x61', '0x6D', '0x70', '0x6C', '0x65', '0xC0', '0x08', '0x07', '0x65', '0x78', '0x61',
                '0x6D', '0x70', '0x6C', '0x65', '0x03', '0x6F', '0x72', '0x67', '0x00'

        $expectedresult = @('contoso.com', 'example.com', 'example.org') -join ' '

        $result = (ConvertFrom-Option119Hex -Hex $hex) -join ' '

        $result | Should Be $expectedresult
    }
}