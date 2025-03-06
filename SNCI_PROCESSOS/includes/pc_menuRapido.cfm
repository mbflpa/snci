<cfprocessingdirective pageencoding = "utf-8">
<cfquery name="rsMenuRapido" datasource="#application.dsn_processos#">
    SELECT "pc_controle_acesso".* FROM pc_controle_acesso 
    WHERE pc_controle_acesso_perfis LIKE '%#application.rsUsuarioParametros.pc_usu_perfil#%' 
    AND pc_controle_acesso_rapido_nome IS NOT NULL AND pc_controle_acesso_rapido_nome <> ''
    ORDER BY pc_controle_acesso_rapido_nome
</cfquery>


        
<div align="center" style="margin-bottom:20px;">	
    <div class="menuRapidoGrid">
        <div class="menuRapido_legendGrid ">Páginas Principais</div> 
        <cfloop query="rsMenuRapido">
            <cfoutput>
                <cfset link = "../SNCI_PROCESSOS/./" & pc_controle_acesso_pagina>
                <a href="#link#">
                    <div class="menuRapido_iconGrid">
                        <i class="fas #pc_controle_acesso_menu_icone#"></i>
                        <span class="font-weight-light">#pc_controle_acesso_rapido_nome#</span>
                    </div>
                </a>
            </cfoutput>
        </cfloop>
    </div>
</div>
