
#Importa arquivo CSV com headers para identificação de cada coluna e delimitador ;
$csv = Import-Csv 'D:\Users\iscmpa\Desktop\PS AD\Resete senha\POR CRACHA\cp.csv' -Header "Nome","Usuario","Cracha" -Delimiter ";"

#Importa modulo AD
Import-Module ActiveDirectory

foreach ($linha in $csv){
    
    $resposta = 0  #Por padrao o filtro do crachá é feito com 'F' na frente do número, caso seja informado '2' na resposta
                   # o 'F' é retirado e filtro se repete sem

    Do{

        if($resposta -eq 3){
            
            #FILTRO
            #*************************Variavel usuario filtra pelo NOME no campo * e recebe o usuário AD
            
            #$usuario = Get-ADUser -Filter "description -like '*$cracha*'" | Select -ExpandProperty sAMAccountName
            #$nome = Get-ADUser -Filter "description -like '*$cracha*'" | Select -ExpandProperty name
        }

        if($resposta -eq 0 -or 2){
            
            
            if($resposta -eq 2){ 
                $cracha = $linha.Cracha   #Primeiro loop o filtro passa da condição e realiza o filtro padrão
                                            #Segundo loop entra na condição resposta 2 e retira o 'F'
            }else{
                $cracha = 'f'+$linha.Cracha
            }

            #FILTROS
            #Variavel usuario filtra pelo cracha no campo descrição e recebe o usuário AD
            #Variavel nome filtra pelo cracha no campo descrição e recebe o nome display AD
            #Variavel status recebe o status da conta inativo ou ativo como booleano
  
            $usuario = Get-ADUser -Filter "description -like '*$cracha*'" | Select -ExpandProperty sAMAccountName
            $nome = Get-ADUser -Filter "description -like '*$cracha*'" | Select -ExpandProperty name
            $status = Get-ADUser -Filter "description -like '*$cracha*'" | Select -ExpandProperty enabled


        }
                
        

        Write-Host "Nome", $linha.Nome  #Exibe o nome esperado do colaborador na planilha
        Write-Host "Nome AD: ", $nome   #Exibe nome AD resultante do filtro
        Write-Host "Status: ", $status  #Exibe bool true ativo false inativo
    
    
        $resposta = Read-Host "1- Correto | 2-Sem F | 3-Por Nome | 0-Avaliar"  #Define ação à tomar

    

        if($resposta -eq 1){
        
            $linha.Usuario = $usuario #Campo usuario recebe usuário AD
        
            #Reseta senha do usuário
            Get-ADUser $usuario | Set-ADAccountPassword -NewPassword (ConvertTo-SecureString -AsPlainText "senha" -Force) -Reset
	    
            #Flega campo 'Usuário deve alterar no próximo logon'
            Get-ADUser $usuario  | Set-AdUser -ChangePasswordAtLogon $true
            #Desbloqueia usuário caso esteja bloqueado por erro de senha
            Get-ADUser $usuario  | Unlock-ADAccount

            Write-Host "                       "
            Write-Host "###################### "
            Write-Host "###### Resetado ###### "
            Write-Host "###################### "
            Write-Host "                       "
        
        }
    
    
        if($resposta -eq 0){
            $linha.Usuario = 'Avaliar' #Insere 'Avaliar' caso nenhum dos filtros esteja correto 
        }


    }while($resposta -eq 2 -or $reposta -eq 3) #Repete até senha for redefinida ou Flag Avaliar seja inserida
    

}


$csv| Export-Csv 'D:\Users\iscmpa\Desktop\PS AD\Resete senha\POR CRACHA\cp.csv' -NoTypeInformation -Delimiter ";" 

#Insere o usuário na planiha csv



