<cfinclude template="../../../parametros.cfm">

<cfquery name="rsChecklistFiltrado" datasource="#dsn_inspecao#">
    SELECT TUI_Modalidade,TUI_TipoUnid,TUI_Ativo, TUI_Ano, TUI_GRUPOITEM, TUI_ITEMVERIF, RTRIM(TUN_Descricao) AS TUN_Descricao,  Grp_Descricao, Itn_Descricao, Itn_Orientacao, Itn_ValorDeclarado 
    FROM TipoUnidade_ItemVerificacao 
    INNER JOIN Grupos_Verificacao ON Grp_Codigo = TUI_GrupoItem AND Grp_Ano = TUI_Ano 
    INNER JOIN Itens_Verificacao ON Itn_NumItem = TUI_ItemVerif AND Itn_NumGrupo = TUI_GrupoItem AND Itn_Ano = TUI_Ano AND TUI_TipoUnid = Itn_TipoUnidade and (TUI_Modalidade = Itn_Modalidade)
    INNER JOIN Tipo_Unidades ON TUN_Codigo = TUI_TipoUnid
    WHERE TUI_Ano = '#url.ano#' and Tui_Ativo = 1
    <cfif '#url.tipo#' neq ''>
            AND TUI_TipoUnid = '#url.tipo#'
    </cfif>
    <cfif '#url.mod#' neq ''>
        AND TUI_Modalidade = '#url.mod#'
    </cfif>
    <cfif '#url.grupo#' neq ''>
        AND TUI_GrupoItem = '#url.grupo#'
    </cfif>
    <cfif '#url.sit#' neq ''>
        AND TUI_Ativo = #url.sit#
    </cfif>
    <cfif '#url.valDec#' neq ''>
        AND Itn_ValorDeclarado = '#url.valDec#'
    </cfif>
    ORDER BY TUI_GRUPOITEM, TUI_ITEMVERIF, TUN_Descricao  
</cfquery>
<cfset nomeArquivo = "Plano_de_Teste_#rsChecklistFiltrado.TUN_Descricao#_#rsChecklistFiltrado.TUI_Ano#.pdf">
<cfdocument format="pdf" filename="#nomeArquivo#" overwrite="Yes" margintop="1" PAGETYPE = "A4">
    
     <cfdocumentsection>
                <cfdocumentitem type="header" >
                    <div align="center" style="font-size:50px;font-weight:bold;color:#053c5e;margin-bottom:30px;">
                        <br><br>
                        <img src="../../geral/img/logoCorreios.gif" alt="Logo ECT"  width="300px" style=""></img> 
                        <br><br>
                        DEPARTAMENTO DE CONTROLE INTERNO
                        <br>
                        PLANO DE TESTES
                    </div> 
                </cfdocumentitem>
                <div style="font-size:12px;color:#053c5e;margin-bottom:10px;width:auto;padding:5px"> 
                    <p style="margin-bottom:5px">Tipo de unidade: <CFOUTPUT><strong>#rsChecklistFiltrado.TUN_Descricao#</strong></CFOUTPUT></p>
                    <p style="margin-bottom:5px">Modalidade: <CFOUTPUT><strong><cfif #url.mod# eq 0>PRESENCIAL<cfelseif #url.mod# eq 1>A DISTÂNCIA<cfelse>PRESENCIAL e A DISTÂNCIA</cfif></strong></CFOUTPUT></p> 
                    <p style="margin-bottom:5px">Ano: <CFOUTPUT><strong>#rsChecklistFiltrado.TUI_Ano#</strong></CFOUTPUT></p>
                </div>
                <cfoutput query="rsChecklistFiltrado" group="TUI_GRUPOITEM">
                    <div style="font-size:12px;">
                        <div style="color:##053c5e;background:##f3f3f7;margin-bottom:10px"><strong>GRUPO: #TUI_GRUPOITEM# #Grp_Descricao#</strong></div>
                        <cfoutput> 
                            <div style="margin-left:10px;margin-bottom:20px;font-size:12px;text-align: justify;"><strong>Item: #TUI_GRUPOITEM#.#TUI_ITEMVERIF# - </strong>#Itn_Descricao#</div>
                        </cfoutput>
                    </div>    

                    <cfdocumentitem type="footer" >
                        <div align="right" style="color:##053c5e;margin-left:0px;margin-top:10px;margin-bottom:10px;font-size:10px;float:left">Page #cfdocument.currentpagenumber#/#cfdocument.totalpagecount# - SNCI - Sistema Nacional de Controle Interno</div>              
                        <div align="right" style="color:##053c5e;margin-right:0px;margin-top:10px;;margin-bottom:10px;font-size:10px">Data/Hora de Emissão:
                        <cfoutput>#DateFormat(Now(),"DD/MM/YYYY")#</cfoutput> - <cfoutput>#TimeFormat(Now(),'HH:MM')#</cfoutput></div>
                    </cfdocumentitem>
                </cfoutput> 

    </cfdocumentsection>
</cfdocument>
<cfheader name="Content-Disposition" value="attachment;filename=#nomeArquivo#"> 
<cfcontent type="application/octet-stream" file="#expandPath('.')#\#nomeArquivo#" deletefile="Yes">