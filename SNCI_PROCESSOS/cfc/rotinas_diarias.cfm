<cfprocessingdirective pageencoding = "utf-8">	


<cfquery name="rsPontoSuspensoPrazoVencido" datasource="#application.dsn_processos#">
    SELECT pc_avaliacao_orientacoes.*, pc_avaliacoes.pc_aval_processo
    FROM pc_avaliacao_orientacoes
    INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
    WHERE pc_aval_orientacao_status = 16 and DATEDIFF(DAY, pc_aval_orientacao_dataPrevistaResp, GETDATE()) >0
</cfquery>


<cfoutput query= "rsPontoSuspensoPrazoVencido" >
  				
    <cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoio"/>
    <cfinvoke component="#pc_cfcPaginasApoio#" method="obterDataPrevista" returnVariable="obterDataPrevista" qtdDias='15' />
    <cfset posicionamento = "Prezado gestor,<br>Solicita-se atualizar as informações do andamento das ações para regularização do item apontado considerando sua última manifestação quanto as tratativas com órgão externo. Incluir no SNCI as evidências das tratativas/ações adotadas."/>						
    <cfset dataCFQUERY = "#DateFormat(obterDataPrevista.Data_Prevista,'YYYY-MM-DD')#">	
    
    <cftransaction >

        <cfquery datasource="#application.dsn_processos#">
            UPDATE pc_avaliacao_orientacoes 
            SET    
                pc_aval_orientacao_status = 5,
                pc_aval_orientacao_dataPrevistaResp =#obterDataPrevista.Data_Prevista#
            WHERE pc_aval_orientacao_id = #pc_aval_orientacao_id#
        </cfquery>

        <cfquery datasource="#application.dsn_processos#">
            INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status, pc_aval_posic_enviado)
            VALUES (
                    <cfqueryparam value="#pc_aval_orientacao_id#" cfsqltype="cf_sql_numeric">
                    ,<cfqueryparam value="#posicionamento#" cfsqltype="cf_sql_varchar">
                    ,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
                    ,'99999999'
                    ,'00436699'
                    ,'#pc_aval_orientacao_mcu_orgaoResp#'
                    ,'#dataCFQUERY#'
                    ,5
                    ,1
                   )
        </cfquery>

        <cftry>
            <!--Informações do órgão responsável-->
            <cfquery name="rsOrgaoResp" datasource="#application.dsn_processos#">
                SELECT pc_org_emaiL, pc_org_sigla FROM pc_orgaos
                WHERE pc_org_mcu = <cfqueryparam value="#pc_aval_orientacao_mcu_orgaoResp#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfset to = "#LTrim(RTrim(rsOrgaoResp.pc_org_email))#">
            <cfset siglaOrgaoResponsavel = "#LTrim(RTrim(rsOrgaoResp.pc_org_sigla))#">
            <cfset pronomeTrat = "Senhor(a) Gestor da #siglaOrgaoResponsavel#">
            
            <cfset textoEmail = 'Solicita-se atualizar as informações do andamento das ações para regularização do item apontado (Orientação ID #pc_aval_orientacao_id#), no processo SNCI N° #pc_aval_processo#, considerando sua última manifestação quanto as tratativas com órgão externo. Incluir no SNCI as evidências das tratativas/ações adotadas. 

Orientamos a acessar o link abaixo, tela "Acompanhamento", aba "Propostas de Melhoria" e inserir sua resposta:

<a style="color:##fff" href="http://intranetsistemaspe/snci/snci_processos/index.cfm">http://intranetsistemaspe/snci/snci_processos/index.cfm</a>'>
                        
            <cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoioDist"/>
            <cfinvoke component="#pc_cfcPaginasApoioDist#" method="EnviaEmails" returnVariable="sucessoEmail" 
                        para = "#to#"
                        pronomeTratamento = "#pronomeTrat#"
                        texto="#textoEmail#"
            />
            <cfcatch type="any">
            <cfset de="SNCI@correios.com.br">
            <cfif application.auxsite eq "localhost">
                <cfset de="mbflpa@yahoo.com.br">
            </cfif>
                <cfmail from="#de#" to="#application.rsUsuarioParametros.pc_usu_email#"  subject=" ERRO -SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
                    <cfoutput>Erro rotina "distribuirMelhoria" de distribuição de propostas de melhoria: #cfcatch.message#</cfoutput>
                </cfmail>
            </cfcatch>
        </cftry>

        
    </cftransaction>
    <cfquery name="rsStatusTrocado" datasource="#application.dsn_processos#">
        SELECT pc_avaliacao_posicionamentos.* FROM pc_avaliacao_posicionamentos
        where pc_aval_posic_num_orientacao = #pc_aval_orientacao_id#
    </cfquery>
<cfdump var="#rsStatusTrocado#">
</cfoutput>


<cfquery name="rsPontoSuspenso" datasource="#application.dsn_processos#">
    SELECT pc_aval_orientacao_id, pc_aval_orientacao_dataPrevistaResp, pc_aval_orientacao_status
    FROM pc_avaliacao_orientacoes
    WHERE pc_aval_orientacao_status = 16 
</cfquery>
<cfdump var="#rsPontoSuspenso#">