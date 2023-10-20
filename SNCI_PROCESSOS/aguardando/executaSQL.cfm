<cfprocessingdirective pageencoding = "utf-8">	
<cfset this.loginRequired="false" />
<cfset titulo = "SNCI - Processos - #application.auxsite#">
<cfmail from="SNCI@correios.com.br" to="marceloferreira@correios.com.br" subject="Bem-vindo ao SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
    <div style="background-color: ##00416B; color:##fff; border-radius: 10px; padding: 20px; box-shadow: 0px 0px 10px ##888888; max-width: 600px; margin: 0 auto; float: left;">
       <p style="font-size:20px">#titulo#</p> 
        <p>Prezado Usuário,</p>
        <p style="text-align: justify;">Estamos felizes em tê-lo como parte da nossa comunidade no SNCI. Você agora faz parte do nosso sistema de controle interno, onde pode gerenciar e monitorar atividades importantes.</p>
        <p>Para começar, faça login na sua conta usando suas credenciais.</p>
        <p><strong>Link de Acesso:</strong> <a href="https://www.snci.com.br" style="color: ##007bff;">https://www.snci.com.br</a></p>
        <p>Obrigado por se juntar a nós!</p>
        <p>Atenciosamente,</p>
        <p>A Equipe do SNCI</p>
        <p><strong>Obs:</strong> Este é um e-mail automático, por favor não responda.</p>
    </div>
</cfmail>
