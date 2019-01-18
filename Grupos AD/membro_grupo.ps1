

foreach($grupo in Get-Content '.\grupos.txt'){

    dsquery group -name $grupo | dsget group -members -expand | dsget user -display > .\Resultado\$grupo.txt
    
}

