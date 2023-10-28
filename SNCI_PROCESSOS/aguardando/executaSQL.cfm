<cfset titulo = "SNCI - Processos - #application.auxsite# - TESTE DE AGENDAMENTO">
<cfmail from="SNCI@correios.com.br" to="marceloferreira@correios.com.br,equipeweb@correios.com.br" subject="#titulo#" type="html">
    <div>
       <p style="font-size:20px">#titulo#</p> 
        <p>Testando o envio de e-mails via schedule.</p>
    </div>
</cfmail>
