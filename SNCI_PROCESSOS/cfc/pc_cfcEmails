<cfcomponent>
    <cfcomponent pageencoding = "utf-8">
        
    <cffunction name="EnviaEmails" access="public" hint="Cria o formado dos e-mails e envia.">
            
        <cfargument name="para" type="string" required="true">
        <cfargument name="copiaPara" type="string" required="false">
        <cfargument name="pronomeTratamento" type="string" required="true">
        <cfargument name="texto" type="string" required="true">

        <cfset to = "#arguments.para#">
        <cfif application.auxsite neq "intranetsistemaspe">
            <cfset to = "#application.rsUsuarioParametros.pc_usu_nome#">
        </cfif>

        <cfset cc = "">
        <cfif isdefined("arguments.copiaPara") and arguments.copiaPara neq "">
            <cfset cc = "#arguments.copiaPara#">
        </cfif>

        <cfmail from="SNCI@correios.com.br" to="#to#" cc="#cc#" subject="SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
            <div style="background-color: ##00416B; color:##fff; border-radius: 10px; padding: 20px; box-shadow: 0px 0px 10px ##888888; max-width: 600px; margin: 0 auto; float: left;">
                <p style="font-size:20px">#titulo#</p> 
                <cfoutput>
                    <p>#arguments.pronomeTratamento#,</p>
                    <pre>#texto#</pre>
                    <p>Estamos à disposição para prestar informações adicionais a respeito do 
                       assunto, caso seja necessário.<br>
                       CS/DIGOE/SUGOV/DCINT/GPCI - Gerência de Planejamento de Controle Interno
                    </p>
                    <p><strong>Obs:</strong> Este é um e-mail automático, por favor não responda.</p>
                </cfoutput>
            </div>
        </cfmail>
        <cfset sucesso = true>
        <cfcatch type="any">
            <cfset sucesso = false>
        </cfcatch>

        <cfreturn #sucesso# />
    </cftry>
		
    </cffunction>
	

</cfcomponent>