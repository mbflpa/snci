<cfprocessingdirective pageEncoding ="utf-8">  
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="permissao_negada.htm">
	<cfabort>
</cfif>  
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfif isDefined("form.formCadItem")>
    <cfparam name="form.acao" default="#form.acao#">
    <cfparam name="form.selCadItemAno" default="#form.selCadItemAno#">
    <cfparam name="form.tiposCad" default="#form.tiposCad#">
    <cfparam name="form.cadfrmptos" default="#form.cadfrmptos#">
	<cfparam name="form.cadfrmptosAGF" default="#form.cadfrmptosAGF#">	
<cfelse>
    <cfparam name="form.acao" default="">
    <cfparam name="form.selCadItemAno" default="">
    <cfparam name="form.tiposCad" default="">
	<cfparam name="form.cadfrmptos" default="">
	<cfparam name="form.cadfrmptosAGF" default="">	
</cfif>
    <!--- Este método retorna grupos --->
    <cfquery name="rsAnoPontuacao" datasource="#dsn_inspecao#">    
        SELECT PTC_Ano 
        FROM Pontuacao 
        GROUP BY PTC_Ano 
        HAVING (PTC_Ano) >= '#year(now())#'
        order by PTC_Ano desc
    </cfquery>    
    <cfquery name="rsPta" datasource="#dsn_inspecao#">
        SELECT PTC_Seq, PTC_Valor, PTC_Descricao, PTC_Status, PTC_dtultatu, PTC_Username, PTC_Franquia 
        FROM Pontuacao 
        WHERE PTC_Ano = '#year(now())#'
    </cfquery>

<cfif isDefined("form.selCadItemAno") and '#form.selCadItemAno#' neq ''>      
    <cfquery name="rsPta" datasource="#dsn_inspecao#">
        SELECT PTC_Seq, PTC_Valor, PTC_Descricao, PTC_Status, PTC_dtultatu, PTC_Username, PTC_Franquia 
        FROM Pontuacao 
        WHERE PTC_Ano = '#form.selCadItemAno#'
    </cfquery>    
	<cfif rsPta.recordcount lte 0>
	   <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=BASE CADASTRAL: Falta informar os dados na tabela PONTUACAO para o ano: #form.selCadItemAno#">
	</cfif>
	<!---  --->
    <cfquery datasource="#dsn_inspecao#" name="rsGrupo">
        SELECT * FROM Grupos_Verificacao WHERE Grp_Ano = '#form.selCadItemAno#'
    </cfquery>
    <cfif '#rsGrupo.recordcount#' eq 0>
       <script>
       <cfoutput>
         alert('Não existem Grupos cadastrados para o ano ' + '#form.selCadItemAno#' + '.');
       </cfoutput>
       </script>
    </cfif>
</cfif>

<cfquery name="qTipoUnidades" datasource="#dsn_inspecao#">
    SELECT * FROM Tipo_Unidades
	ORDER BY TUN_Descricao
</cfquery>

<cfif isDefined("form.acao") and "#form.acao#" eq 'cadItem'>

    <cfquery datasource="#dsn_inspecao#" name="rsItemExiste">
        SELECT Itn_Descricao FROM Itens_Verificacao 
        WHERE Itn_Descricao = '#form.cadItemDescricao#' AND Itn_Ano = #form.selCadItemAno# 
        AND Itn_NumGrupo = '#form.selCadItemGrupo#'
    </cfquery>

    <cfif '#rsItemExiste.recordcount#' eq 0>
         <!--- Retorna o maior código de item cadastrado para o grupo selecionado e adiciona 1 para gerar o código do item a ser cadastrado ---> 
        <cfquery datasource="#dsn_inspecao#" name="rsNumItem">
            SELECT MAX(Itn_NumItem) + 1 as numItem FROM Itens_Verificacao
            WHERE Itn_Ano = #form.selCadItemAno# AND Itn_NumGrupo = '#form.selCadItemGrupo#'
        </cfquery>
        <cfset numItem = 1>
        <cfif '#rsNumItem.numItem#' neq ''>
            <cfset numItem = '#rsNumItem.numItem#'>  
        </cfif> 
        <cfset itnreincidentes = #trim(form.selcadreindencias)#>
        <cfset itnreincidentes = #form.selCadItemGrupo# & '_' & #numItem# & "," & #itnreincidentes#>
        <cfset tiposunidcad = form.tiposCad>
        <cfloop list="#tiposunidcad#" index="j">   
            <cfset tipoCad = j>    
            <!--- Obter a Pontuação max pelo ano e tipo da unidade --->
            <cfquery name="rsPtoMax" datasource="#dsn_inspecao#">
                SELECT TUP_PontuacaoMaxima 
                FROM Tipo_Unidade_Pontuacao 
                WHERE TUP_Ano = '#form.selCadItemAno#' AND TUP_Tun_Codigo in (#tipoCad#)
            </cfquery>

            <cfif rsPtoMax.recordcount lte 0>
                <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=BASE CADASTRAL: Falta informar os dados na tabela TIPO_UNIDADE_PONTUACAO para o ano: #form.selCadItemAno# e Cod_Tipo_Unidade = #tipo#">
            </cfif>
			<!--- calcular o perc de classificacao do item --->	
            <cfif tipoCad eq 12>
                <cfset pontuacao = #form.pontuacaoCalculadaCadAGF#>
                <cfset altpontuacaoseq = #form.checkpontuacaocadagfseq#>
				<cfset PercClassifItem = NumberFormat(((#pontuacao# / rsPtoMax.TUP_PontuacaoMaxima) * 100),999)>	
            <cfelse>
                <cfset pontuacao = #form.pontuacaoCalculadaCad#>
                <cfset altpontuacaoseq = #form.checkpontuacaocadseq#>
                <cfset PercClassifItem = NumberFormat(((#pontuacao# / rsPtoMax.TUP_PontuacaoMaxima) * 100),999)>	
            </cfif>  
            <cfset itnimpactartipos= #form.selcadfalta# & ',' & #form.selcadsobra# & ',' & #form.selcadrisco#>                  
            <!--- calculo da descricao do item a saber GRAVE, MEDIANO ou LEVE --->
            <cfif PercClassifItem gt 40>
                <cfset ClassifITEM = 'GRAVE'> 
            <cfelseif PercClassifItem gt 10 and PercClassifItem lte 40>
                <cfset ClassifITEM = 'MEDIANO'> 
            <cfelseif PercClassifItem lte 10>
                <cfset ClassifITEM = 'LEVE'> 
            </cfif>	

            <!--- Ajustes de campos para Não aplicar Processo N1 --->
            <cfif form.processon1naoaplicarSN eq 'S'>
                <cfset processon1 = 0>
                <cfset processon2 = 0>
                <cfset processon3 = 0>
            <cfelse>
                <cfset processon1 = #form.macroprocesson1#>
                <cfset processon2 = #form.macroprocesson2#>
                <cfset processon3 = #form.macroprocesson3#>
                <cfif form.processon3outrosSN eq 'S'>
                    <cfset processon3 = 0>
                </cfif>
            </cfif>
         
            <!--- Fim ajustes de campos para Não aplicar Processo N1 --->          
            <cfif '#form.selCadModalidade#' eq '2'>
                    <cfquery datasource="#dsn_inspecao#">
                        INSERT INTO TipoUnidade_ItemVerificacao 
                            (TUI_Ano,TUI_Modalidade,TUI_TipoUnid,TUI_GrupoItem,TUI_ItemVerif,TUI_DtUltAtu,TUI_UserName,TUI_Ativo,TUI_Pontuacao,TUI_Pontuacao_Seq,TUI_Classificacao)
                        VALUES 
                            (#form.selCadItemAno#,'0',#tipoCad#,#form.selCadItemGrupo#,#numItem#,CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#',0,#pontuacao#,'#altpontuacaoseq#','#ClassifITEM#') 
                    </cfquery>
                    <cfquery datasource="#dsn_inspecao#">
                        INSERT INTO Itens_Verificacao 
                            (Itn_Modalidade,Itn_Ano,Itn_TipoUnidade,Itn_NumGrupo,Itn_NumItem,Itn_Descricao,Itn_Orientacao,Itn_Situacao,Itn_DtUltAtu,Itn_UserName,Itn_ValorDeclarado,Itn_Amostra,Itn_Norma,Itn_ValidacaoObrigatoria,Itn_PreRelato,Itn_OrientacaoRelato,Itn_Pontuacao,Itn_PTC_Seq,Itn_Reincidentes,Itn_ImpactarTipos,Itn_Classificacao,Itn_Manchete,Itn_ClassificacaoControle,Itn_ControleTestado,Itn_CategoriaControle,Itn_RiscoIdentificado,Itn_RiscoIdentificadoOutros,Itn_MacroProcesso,Itn_ProcessoN1,Itn_ProcessoN1NaoAplicar,Itn_ProcessoN2,Itn_ProcessoN3,Itn_ProcessoN3Outros,Itn_GestorProcessoDir,Itn_GestorProcessoDepto,Itn_ObjetivoEstrategico,Itn_RiscoEstrategico,Itn_IndicadorEstrategico,Itn_Coso2013Componente,Itn_Coso2013Principios)
                        VALUES 
                            ('0',#form.selCadItemAno#,#tipoCad#,#form.selCadItemGrupo#,#numItem#,'#form.cadItemDescricao#','#form.cadItemOrientacao#','D',CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#','#form.selCadItemValorDec#','#form.cadItemAmostra#','#form.cadItemNorma#','#form.selCadItemValidObrig#','#form.cadItemPreRelato#','#form.cadItemOrientacaoRelato#',#pontuacao#,'#altpontuacaoseq#','#itnreincidentes#','#itnimpactartipos#','#ClassifITEM#','#form.cadItemManchete#','#form.itnclassificacontrole#','#form.controletestado#','#form.itncategoriacontrole#',#form.categoriarisco#,'#form.categoriariscooutros#',#form.macroprocesso#,#processon1#,'#form.macroprocesson1naoseaplica#',#processon2#,#processon3#,'#form.macroprocesson3outros#',#form.gestordir#,'#form.gestordepto#','#form.itnobjetivoestrategico#','#form.itnriscoestrategico#','#form.itnindicadorestrategico#',#form.componentecoso#,#form.principioscoso#)                                    
                    </cfquery>                    
                    <cfquery datasource="#dsn_inspecao#">
                        INSERT INTO TipoUnidade_ItemVerificacao 
                            (TUI_Ano,TUI_Modalidade,TUI_TipoUnid,TUI_GrupoItem,TUI_ItemVerif,TUI_DtUltAtu,TUI_UserName,TUI_Ativo,TUI_Pontuacao,TUI_Pontuacao_Seq,TUI_Classificacao)
                        VALUES 
                            (#form.selCadItemAno#,'1',#tipoCad#,#form.selCadItemGrupo#,#numItem#,CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#',0,#pontuacao#,'#altpontuacaoseq#','#ClassifITEM#') 
                    </cfquery>
                    <cfquery datasource="#dsn_inspecao#">
                        INSERT INTO Itens_Verificacao 
                            (Itn_Modalidade,Itn_Ano,Itn_TipoUnidade,Itn_NumGrupo,Itn_NumItem,Itn_Descricao,Itn_Orientacao,Itn_Situacao,Itn_DtUltAtu,Itn_UserName,Itn_ValorDeclarado,Itn_Amostra,Itn_Norma,Itn_ValidacaoObrigatoria,Itn_PreRelato,Itn_OrientacaoRelato,Itn_Pontuacao,Itn_PTC_Seq,Itn_Reincidentes,Itn_ImpactarTipos,Itn_Classificacao,Itn_Manchete,Itn_ClassificacaoControle,Itn_ControleTestado,Itn_CategoriaControle,Itn_RiscoIdentificado,Itn_RiscoIdentificadoOutros,Itn_MacroProcesso,Itn_ProcessoN1,Itn_ProcessoN1NaoAplicar,Itn_ProcessoN2,Itn_ProcessoN3,Itn_ProcessoN3Outros,Itn_GestorProcessoDir,Itn_GestorProcessoDepto,Itn_ObjetivoEstrategico,Itn_RiscoEstrategico,Itn_IndicadorEstrategico,Itn_Coso2013Componente,Itn_Coso2013Principios)
                        VALUES 
                            ('1',#form.selCadItemAno#,#tipoCad#,#form.selCadItemGrupo#,#numItem#,'#form.cadItemDescricao#','#form.cadItemOrientacao#','D',CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#','#form.selCadItemValorDec#','#form.cadItemAmostra#','#form.cadItemNorma#','#form.selCadItemValidObrig#','#form.cadItemPreRelato#','#form.cadItemOrientacaoRelato#',#pontuacao#,'#altpontuacaoseq#','#itnreincidentes#','#itnimpactartipos#','#ClassifITEM#','#form.cadItemManchete#','#form.itnclassificacontrole#','#form.controletestado#','#form.itncategoriacontrole#',#form.categoriarisco#,'#form.categoriariscooutros#',#form.macroprocesso#,#processon1#,'#form.macroprocesson1naoseaplica#',#processon2#,#processon3#,'#form.macroprocesson3outros#',#form.gestordir#,'#form.gestordepto#','#form.itnobjetivoestrategico#','#form.itnriscoestrategico#','#form.itnindicadorestrategico#',#form.componentecoso#,#form.principioscoso#)                                    
                    </cfquery>   		
            <cfelse>                   
                <cfquery datasource="#dsn_inspecao#">
                    INSERT INTO TipoUnidade_ItemVerificacao 
                        (TUI_Ano,TUI_Modalidade,TUI_TipoUnid,TUI_GrupoItem,TUI_ItemVerif,TUI_DtUltAtu,TUI_UserName,TUI_Ativo,TUI_Pontuacao,TUI_Pontuacao_Seq,TUI_Classificacao)
                    VALUES 
                        (#form.selCadItemAno#,'#form.selCadModalidade#',#tipoCad#,#form.selCadItemGrupo#,#numItem#,CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#',0,#pontuacao#,'#altpontuacaoseq#','#ClassifITEM#') 
                </cfquery>
              
                <cfquery datasource="#dsn_inspecao#">
                    INSERT INTO Itens_Verificacao 
                        (Itn_Modalidade,Itn_Ano,Itn_TipoUnidade,Itn_NumGrupo,Itn_NumItem,Itn_Descricao,Itn_Orientacao,Itn_Situacao,Itn_DtUltAtu,Itn_UserName,Itn_ValorDeclarado,Itn_Amostra,Itn_Norma,Itn_ValidacaoObrigatoria,Itn_PreRelato,Itn_OrientacaoRelato,Itn_Pontuacao,Itn_PTC_Seq,Itn_Reincidentes,Itn_ImpactarTipos,Itn_Classificacao,Itn_Manchete,Itn_ClassificacaoControle,Itn_ControleTestado,Itn_CategoriaControle,Itn_RiscoIdentificado,Itn_RiscoIdentificadoOutros,Itn_MacroProcesso,Itn_ProcessoN1,Itn_ProcessoN1NaoAplicar,Itn_ProcessoN2,Itn_ProcessoN3,Itn_ProcessoN3Outros,Itn_GestorProcessoDir,Itn_GestorProcessoDepto,Itn_ObjetivoEstrategico,Itn_RiscoEstrategico,Itn_IndicadorEstrategico,Itn_Coso2013Componente,Itn_Coso2013Principios)
                    VALUES 
                        ('#form.selCadModalidade#',#form.selCadItemAno#,#tipoCad#,#form.selCadItemGrupo#,#numItem#,'#form.cadItemDescricao#','#form.cadItemOrientacao#','D',CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#','#form.selCadItemValorDec#','#form.cadItemAmostra#','#form.cadItemNorma#','#form.selCadItemValidObrig#','#form.cadItemPreRelato#','#form.cadItemOrientacaoRelato#',#pontuacao#,'#altpontuacaoseq#','#itnreincidentes#','#itnimpactartipos#','#ClassifITEM#','#form.cadItemManchete#','#form.itnclassificacontrole#','#form.controletestado#','#form.itncategoriacontrole#',#form.categoriarisco#,'#form.categoriariscooutros#',#form.macroprocesso#,#processon1#,'#form.macroprocesson1naoseaplica#',#processon2#,#processon3#,'#form.macroprocesson3outros#',#form.gestordir#,'#form.gestordepto#','#form.itnobjetivoestrategico#','#form.itnriscoestrategico#','#form.itnindicadorestrategico#',#form.componentecoso#,#form.principioscoso#)                                    
                </cfquery>  
            </cfif> 
        </cfloop>

        <script>
            var numItem = <cfoutput>#form.selCadItemGrupo#.#numItem#</cfoutput>;
            alert('Item Cadastrado com sucesso!\n\nNº do Item gerado automaticamente: ' + numItem + '\n\nSituação: DESATIVADO');
            window.open('cadastroGruposItens.cfm','_self');
        </script>
    <cfelse>
      <script>
        alert('Já existe um item cadastrado com a mesma Descrição e Ano.\n\nEsta ação foi Cancelada.');
      </script>
    </cfif> 

</cfif>

<!DOCTYPE html>
<html lang="pt-BR">
    <head>
        <title>SNCI - CADASTRO DE GRUPOS E ITENS</title>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <script type="text/javascript" src="ckeditor/ckeditor.js"></script>
        <link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">     
        <style type="text/css">    
            .tituloDivCadGrupo{
                padding:5px;
                position:relative;
                top: -29px;
                background: #003366;
                border: 1px solid #fff;
            }           
        </style>
    </head>
    <body id="main_body" style="background:#ccc;" onLoad="">
        <div align="left" style="background:#003366">
            <form id="formCadItem" nome="formCadItem" enctype="multipart/form-data" method="post" >
                <input type="hidden" value="" id="acao" name="acao">
                <input type="hidden" value="" id="tiposCad" name="tiposCad"> 
				<input type="hidden" value="" id="cadfrmptos" name="cadfrmptos">
				<input type="hidden" value="" id="cadfrmptosAGF" name="cadfrmptosAGF">  
                <div align="left" style="margin-bottom:10px;padding:10px;border:1px solid #fff;">
                    <div align="left">
                        <span class="tituloDivAltGrupo">Cadastrar Item PLANO DE TESTE</span>
                    </div>                                                                     
                </div> 
                <div style="background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                    <h2 class="entrada" id="cadum">
                        <button  type="button" style="background:#ccf;color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                            <strong>ANO / GRUPO / MODALIDADE / VALOR DECLARADO / VALIDAÇÃO OBRIGATÓRIA / REINCIDÊNCIA(S)</strong>
                        </button>
                    </h2>
                    <div class="entrada" aria-labelledby="cadum" data-bs-parent="">
                        <div class="accordion-body">
                            <div class="row">
                                <div class="col">
                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">Ano</label>
                                </div>
                                <div class="col">
                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">Grupos</label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col">
                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                        <select name="selCadItemAno" id="selCadItemAno" class="form-select" aria-label="Default select example">									                                                                                                                     
                                            <option value="" selected>---</option>   
                                            <cfloop query="rsAnoPontuacao">                                             
                                                <option value="<cfoutput>#rsAnoPontuacao.PTC_Ano#</cfoutput>"><cfoutput>#rsAnoPontuacao.PTC_Ano#</cfoutput></option>
                                            </cfloop>
                                        </select>	
                                    </label>
                                </div>
                                <div class="col">
                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                        <select name="selCadItemGrupo" id="selCadItemGrupo" class="form-select" aria-label="Default select example">										
                                        </select> 
                                    </label>
                                </div>
                            </div> 
                            <br>
                            <div class="row">
                                <div class="col">
                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">Modalidade</label>
                                </div>
                                <div class="col">
                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">Valor declarado</label>
                                </div>
                                <div class="col">
                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">Validação obrigatória</label>
                                </div>                           
                            </div>  
                            <br>                         
                            <div class="row">
                                <div class="col">
                                    <select name="selCadModalidade" id="selCadModalidade" class="form-select" aria-label="Default select example">
                                        <option selected="selected" value="">---</option>
                                        <option value="0">PRESENCIAL</option>
                                        <option value="1">A DISTÁNCIA</option>
                                        <option value="2">TODAS</option>
                                    </select>                                        
                                </div>                                    
                                <div class="col">
                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                        <select name="selCadItemValorDec" id="selCadItemValorDec" class="form-select" aria-label="Default select example">
                                            <option value="" selected>---</option>
                                            <option value="N">Não</option>
                                            <option value="S">Sim</option>
                                        </select>
                                    </label>
                                </div>
                                <div class="col">
                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                        <select name="selCadItemValidObrig" id="selCadItemValidObrig" class="form-select" aria-label="Default select example">
                                            <option value="" selected>---</option>
                                            <option value="0">Não</option>
                                            <option value="1">Sim</option>
                                        </select>
                                    </label>
                                </div>
                            </div> 
                            <br>
                            <div class="row">
                                <div class="col">
                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">Reincidência(s) (grupo/item)</label><label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:11px;">&nbsp; ex. 1000_1  ou 230_1,242_3,230_1,241_1,242_3,230_1,241_1,242_3,243_3</label>
                                </div>   
                            </div>                                  
                            <div class="row">                            
                                <div class="col">
                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                        <input name="selcadreindencias" id="selcadreindencias" type="text" class="form-control-sm" value="" size="110" maxlength="100" onKeyPress="cadformatoreincidentes()">
                                    </label>
                                </div>
                            </div>                                           
                        </div>
                    </div>
                </div>                
                <!--- Inicio acordeon --->
                <div class="accordion" id="acordion-cadgrpitm">
                    <!--- final cadprimeiro --->
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="caddois">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#cadsegundo" aria-expanded="false" aria-controls="cadsegundo" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                            <strong>DESCRIÇÃO DO ITEM</strong>
                            </button>
                        </h2>
                        <div id="cadsegundo" class="accordion-collapse collapse" aria-labelledby="caddois" data-bs-parent="#acordion-cadgrpitm">
                            <div class="accordion-body">
                                <textarea  name="cadItemDescricao"  id="cadItemDescricao" cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>		
                            </div>
                        </div>
                    </div>
                    <!--- final cadsegundo --->      
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="cadtres">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#cadterceiro" aria-expanded="false" aria-controls="cadterceiro" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                <strong>MANCHETE</strong>
                            </button>
                        </h2>
                        <div id="cadterceiro" class="accordion-collapse collapse" aria-labelledby="cadtres" data-bs-parent="#acordion-cadgrpitm">
                            <div class="accordion-body">
                                <textarea  name="cadItemManchete"  id="cadItemManchete" cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>		            
                            </div>
                        </div>
                    </div>
                    <!--- final cadterceiro --->      
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="cadquatro">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#cadquarto" aria-expanded="false" aria-controls="cadquarto" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                            <strong>COMO EXECUTAR/PROCEDIMENTOS ADOTADOS</strong>
                            </button>
                        </h2>
                        <div id="cadquarto" class="accordion-collapse collapse" aria-labelledby="cadquatro" data-bs-parent="#acordion-cadgrpitm">
                            <div class="accordion-body">
                                <textarea  name="cadItemOrientacao" id="cadItemOrientacao" cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>
                            </div>
                        </div>
                    </div>
                    <!--- final cadquarto ---> 
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="cadcinco">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#cadquinto" aria-expanded="false" aria-controls="cadquinto" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                <strong>AMOSTRA</strong>
                            </button>
                        </h2>
                        <div id="cadquinto" class="accordion-collapse collapse" aria-labelledby="cadcinco"data-bs-parent="#acordion-cadgrpitm">
                            <div class="accordion-body">
                                <textarea  name="cadItemAmostra" id="cadItemAmostra"  cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>		
                            </div>
                        </div>
                    </div>
                    <!---  final cinco --->       
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="cadseis">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#cadsexto" aria-expanded="false" aria-controls="cadsexto" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                <strong>NORMA</strong>
                            </button>
                        </h2>
                        <div id="cadsexto" class="accordion-collapse collapse" aria-labelledby="cadseis" data-bs-parent="#acordion-cadgrpitm">
                            <div class="accordion-body">
                                <textarea  name="cadItemNorma" id="cadItemNorma" cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>
                            </div>
                        </div>
                    </div>
                    <!--- final cadsexto --->    
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="cadsete">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#cadsetimo" aria-expanded="false" aria-controls="cadsetimo" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                            <strong>RELATO MODELO / PRÉ-RELATO</strong>
                            </button>
                        </h2>
                        <div id="cadsetimo" class="accordion-collapse collapse" aria-labelledby="cadsete" data-bs-parent="#acordion-cadgrpitm">
                            <div class="accordion-body">
                                <textarea  name="cadItemPreRelato" id="cadItemPreRelato" cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>
                            </div>
                        </div>
                    </div>
                    <!--- final cadsetimo --->    
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="cadoito">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#cadoitavo" aria-expanded="false" aria-controls="cadoitavo" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                               <strong>ORIENTAÇÕES UNIDADE/ÓRGÃO</strong>
                            </button>
                        </h2>
                        <div id="cadoitavo" class="accordion-collapse collapse" aria-labelledby="cadoito" data-bs-parent="#acordion-cadgrpitm">
                            <div class="accordion-body">
                                <textarea  name="cadItemOrientacaoRelato" id="cadItemOrientacaoRelato" cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>
                            </div>
                        </div>
                    </div>
                    <!--- final cadoitavo --->  
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="cadnove">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#cadnono" aria-expanded="false" aria-controls="cadnono" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                            <strong>CONTROLE / RISCOS / PROCESSOS / ESTRATÉGIA / COSO-2013</strong>
                            </button>
                        </h2>
                        <div id="cadnono" class="accordion-collapse collapse" aria-labelledby="cadnove" data-bs-parent="#acordion-cadgrpitm">
                            <div class="accordion-body">
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">CLASSIFICAÇÃO DO CONTROLE</label>
                                    </div>
                                </div>   
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <select id="classifcontrole" name="classifcontrole" multiple="multiple" class="form-select" aria-label="Default select example">
                                            </select>
                                        </label>
                                    </div>
                                </div> 
                                <p></p> 
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">CONTROLE TESTADO</label>
                                    </div>
                                </div>   
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                                <textarea  name="controletestado" id="controletestado" cols="125" rows="2" wrap="VIRTUAL" class="form-control" placeholder="Pode existir mais de um controle testado por item"></textarea>
                                            </label>
                                        </label>
                                    </div>
                                </div> 
                                <p></p>  
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">CATEGORIA DO CONTROLE</label>
                                        <br>
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <select id="categcontrole" name="categcontrole" multiple="multiple" class="form-select" aria-label="Default select example">
                                            </select>  
                                        </label>                                        
                                    </div>
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________________________________________________________________________________________</label>
                                        </div>
                                    </div>                                        
                                </div>  
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">RISCO IDENTIFICADO</label>
                                        <br>
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <select id="categoriarisco" name="categoriarisco" class="form-select" aria-label="Default select example">
                                            </select>
                                        </label>  
                                        <div class="row">
                                            <div id="riscoidentif-outros"><textarea name="categoriariscooutros" id="categoriariscooutros" cols="105" rows="2" wrap="VIRTUAL" class="form-control" placeholder="Outros - Informar Descrição aqui."></textarea></div>
                                        </div>                                       
                                    </div>
                                    <div class="row"> 
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________________________________________________________________________________________</label>
                                        </div>
                                    </div>
                                </div>  
                                <div class="row">
                                    <div class="row"> 
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;"><strong>TIPO AVALIAÇÃO</strong></label>
                                        </div>
                                    </div>                                     
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">MACROPROCESSO</label>
                                        </div>
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">PROCESSO N1</label>
                                        </div>
                                    </div>                                        
                                    <br>
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                                <select id="macroprocesso" name="macroprocesso" class="form-select" aria-label="Default select example">
                                                </select>
                                            </label>
                                        </div>
                                        <br>
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">          
                                                <select id="macroprocesson1" name="macroprocesson1" class="form-select" aria-label="Default select example">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" id="cd_macroprocesson1" name="cd_macroprocesson1" title="">&nbsp;<strong>Não se Aplica</strong>
                                                </select>
                                                <div class="row">
                                                    <div id="macroprocesson1-naoseaplica"><textarea name="macroprocesson1naoseaplica" id="macroprocesson1naoseaplica" cols="125" rows="2" wrap="VIRTUAL" class="form-control" placeholder="Não se aplica - Informar Descrição aqui."></textarea></div>
                                                </div>
                                            </label>
                                        </div>
                                    </div>  
                                    <p></p>
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">PROCESSO N2</label>
                                        </div>
                                    </div>   
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                                <select id="macroprocesson2" name="macroprocesson2" class="form-select" aria-label="Default select example">
                                                </select>
                                            </label>
                                        </div>
                                    </div> 
                                    <p></p>   
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">PROCESSO N3</label>
                                        </div>
                                    </div> 
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                                <select id="macroprocesson3" name="macroprocesson3" class="form-select" aria-label="Default select example"><input type="checkbox" id="cd_macroprocesson3" name="cd_macroprocesson3" title="">&nbsp;<strong>Outros</strong>
                                                </select>
                                            </label>
                                            <div class="row">
                                                <div id="macroprocesson3-outros">
                                                    <textarea name="macroprocesson3outros" id="macroprocesson3outros" cols="100" rows="2" wrap="VIRTUAL" class="form-control" placeholder="Outros - Informar Descrição aqui."></textarea>
                                                </div>
                                            </div>                                            
                                        </div>
                                        <div class="row"> 
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________________________________________________________________________________________</label>
                                            </div>
                                        </div>                                            
                                    </div>   
                                </div>                               
                                <p></p>                                                             
                                <div class="row">
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">Diretoria do Processo</label>
                                        </div>
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">Departamento do Processo</label>
                                        </div>
                                    </div>  
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                                <select id="gestordir" name="gestordir" class="form-select" aria-label="Default select example">
                                                </select>
                                            </label>                                        
                                        </div>                                        
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                                <select id="gestordepto" name="gestordepto" multiple="multiple" class="form-select" aria-label="Default select example">
                                                </select>
                                            </label>                                        
                                        </div>
                                    </div>
                                    <div class="row"> 
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________________________________________________________________________________________</label>
                                        </div>
                                    </div>
                                </div>                             
                                <p></p>                             
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">OBJETIVO ESTRATÉGICO</label>
                                        <br>
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <select id="objetivoestrategico" name="objetivoestrategico" multiple="multiple" class="form-select" aria-label="Default select example">
                                            </select>
                                        </label>                                        
                                    </div>
                                </div>                                 
                                <p></p>
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">RISCO ESTRATÉGICO</label>
                                        <br>
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <select id="riscoestrategico" name="riscoestrategico" multiple="multiple" class="form-select" aria-label="Default select example">
                                            </select>
                                        </label>                                        
                                    </div>
                                </div> 
                                <p></p>
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">INDICADOR ESTRATÉGICO</label>
                                        <br>
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <select id="indicadorestrategico" name="indicadorestrategico" multiple="multiple" class="form-select" aria-label="Default select example">
                                            </select>
                                        </label>                                        
                                    </div>
                                    <div class="row"> 
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________________________________________________________________________________________</label>
                                        </div>
                                    </div>
                                </div> 
                                <div class="row"> 
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;"><strong>COSO 2013</strong></label>
                                    </div> 
                                </div> 
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">COMPONENTE</label>
                                    </div>
                                </div>                                        
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <select id="componentecoso" name="componentecoso" class="form-select" aria-label="Default select example">
                                            </select>
                                        </label>
                                    </div>
                                </div>                                        
                                <p></p>  
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">PRINCÍPIOS</label>
                                    </div>   
                                </div>                                  
                                <div class="row">                            
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <select id="principioscoso" name="principioscoso" class="form-select" aria-label="Default select example">
                                            </select>
                                        </label>
                                    </div>

                                </div>   
                            </div>
                        </div>
                    </div>
                    <!--- final cadnono --->                                                                                                                                                                 
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="caddez">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#caddecimo" aria-expanded="false" aria-controls="caddecimo" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                <strong>PLANO DE TESTE / CARACTERÍSTICAS DE ALCANCE DO IMPACTO FINANCEIRO DIRETO</strong>
                            </button>
                        </h2>
                        <div id="caddecimo" class="accordion-collapse collapse" aria-labelledby="caddez" data-bs-parent="#acordion-cadgrpitm">
                            <div class="accordion-body">
                                <div align="left" style="margin-top:5px;margin-bottom:5px;padding:10px;border:1px solid #009;">
                                    <label for="selCadItemTipoUnidade"  style="color:#009; font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                        <strong>TIPOS DE UNIDADE:</strong> <span style="color:#009">(Selecione os tipos de unidade que terão este item em seu PLANO DE TESTE)</span>
                                    </label>
                                    <div class="row"> 
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">____________________________________________________________________________________________________________________________________________________________________________________________________________</label>
                                        </div>
                                    </div>
                                    <table width="95%" border="0" class="exibir">
                                        <cfset qtdcol = 0>
                                        <tr>	  
                                            <cfloop query="qTipoUnidades">
                                                <cfset ntam = len(trim(#TUN_Descricao#))>
                                                <cfset ntam = (20 - ntam) / 2>
                                                <cfset ntam = int(ntam)>
                                                <cfset strnome = trim(#TUN_Descricao#)>
                                                <cfif ntam lte 4>
                                                    <cfset strnome = trim(#TUN_Descricao#)>
                                                <cfelse>
                                                    <cfset ntam = (ntam + 2)>
                                                    <cfset strnome = RepeatString(" ",ntam) & trim(#TUN_Descricao#) & RepeatString(" ",ntam)>
                                                </cfif>
                                                 
                                                <cfif qtdcol gte 3>
                                                    <tr>		  </tr> 
                                                    <cfset qtdcol = 0>
                                                </cfif>
                                                <td>
                                                    <div align="center">
                                                        <div align="left">
                                                            <input title="0" class="tipounid btn btn-primary" id="<cfoutput>#qTipoUnidades.TUN_Codigo#</cfoutput>" name="<cfoutput>#qTipoUnidades.TUN_Descricao#</cfoutput>" type="button" value="<cfoutput>#strnome#</cfoutput>">
                                                        </div>
                                                        <br>
                                                    </div>	  
                                                </td>
                                                <cfset qtdcol = qtdcol + 1>
                                            </cfloop>
                                        </tr>
                                    </table>
                                    <div id="proprias">
                                        <div class="row"> 
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">_____________________________________________________________________________________________________________________</label>
                                            </div>
                                        </div>                                     
                                        <div class="row"> 
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;"><strong>PRÓPRIAS</strong></label>
                                            </div> 
                                        </div> 
                                        <div id="ptoproprias" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">      
                                            <cfoutput query="rsPta">
                                                <cfif rsPta.PTC_Franquia is 'N'>
                                                    <div class="row">
                                                        <label style="color:##009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">
                                                            <input type="checkbox" class="checkPontuacaoCad" name="checkPontuacaoCad" title="#rsPta.PTC_Seq#" value="#rsPta.PTC_Valor#">&nbsp;&nbsp;#rsPta.PTC_Descricao# = <strong>#rsPta.PTC_Valor# pontos</strong></input>
                                                        </label>
                                                    </div>
                                                </cfif>
                                            </cfoutput>      
                                        </div>
                                        <div id="totalDivCad">
                                            <div class="row">
                                                <div class="col">
                                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">________________________________________________________________________________________________________________________________________________________________________________________________</label>
                                                </div>  
                                            </div>
                                            <div class="row">                           
                                                <div class="col">
                                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;"><strong>TOTAL:</strong></label>                                              
                                                    <input type="text" id="pontuacaoCalculadaCad" name="pontuacaoCalculadaCad" readonly  size="3" class="form-control" style="color:#009;font-size:26px;text-align:center;" value="0"></strong></input>
                                                </div>
                                            </div>  
                                        </div>                                       
                                    </div>
                                    <div id="franquia">
                                        <div class="row"> 
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">________________________________________________________________________________________________________________________________________________________________________________________________</label>
                                            </div>
                                        </div>                                      
                                        <div class="row"> 
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;"><strong>AGF (ponto adicional)</strong></label>
                                            </div>
                                        </div>  
                                        <div id="ptoagf" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">     
                                            <!---        <input type="radio" class="checkPontuacaoCadAGF checkponto" name="checkPontuacaoCadAGF" title="0" value="0" checked>&nbsp;&nbsp;Pontuação Inicial</input> --->
                                            <cfoutput query="rsPta">
                                                <cfif rsPta.PTC_Franquia is 'S'>
                                                    <div class="row">
                                                        <label style="color:##009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">
                                                            <input  type="radio" class="checkPontuacaoCadAGF checkponto" title="#rsPta.PTC_Seq#" name="checkPontuacaoCadAGF" value="#rsPta.PTC_Valor#">&nbsp;&nbsp;#rsPta.PTC_Descricao# = <strong>#rsPta.PTC_Valor# pontos</strong></input> 
                                                        </label>
                                                    </div>
                                                </cfif>
                                            </cfoutput>                                                       
                                        </div>
                                        <div id="totalDivAGF">
                                            <div class="row"> 
                                                <div class="col">
                                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">_____________________________________________________________________________________________________________________</label>
                                                </div>
                                            </div>                                                 
                                            <div class="row">                                   
                                                <div class="col">
                                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;"><strong>TOTAL:</strong></label>
                                                    <p></p>                                                
                                                    <input type="text" id="pontuacaoCalculadaCadAGF" name="pontuacaoCalculadaCadAGF" readonly  class="form-control" size="3" style="color:#009;font-size:26px;text-align:center;" value="0"></strong></input>
                                                </div>
                                            </div> 
                                        </div>
                                    </div>
                                    <div id="cadimpactartipos">
                                        <br>
                                        <div class="row">
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">________________________________________________________________________________________________________________________________________________________________________________________________</label>
                                            </div>  
                                        </div>                                            
                                        <div class="row"> 
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;"><strong>CARACTERÍSTICAS DE ALCANCE DO IMPACTO FINANCEIRO DIRETO</strong></label>
                                            </div> 
                                        </div>                                             
                                        <div class="row">
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">Estimado a Recuperar(R$)</label>
                                            </div>
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">Estimado Não Planejado/Extrapolado/Sobra(R$)</label>
                                            </div>
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">Estimado em Risco ou Envolvido(R$)</label>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                                    <select name="selcadfalta" id="selcadfalta" class="form-select" aria-label="Default select example">									                                                                                                                     
                                                        <option value="N" selected>N</option>
                                                        <option value="F">F</option> 
                                                    </select>	
                                                </label>
                                            </div>
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                                    <select name="selcadsobra" id="selcadsobra" class="form-select" aria-label="Default select example">                                      
                                                        <option value="N" selected>N</option>
                                                        <option value="S">S</option> 
                                                    </select>     
                                                </label>                                  
                                            </div>
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                                    <select name="selcadrisco" id="selcadrisco" class="form-select" aria-label="Default select example">                                      
                                                        <option value="N" selected>N</option>
                                                        <option value="R">R</option> 
                                                    </select>     
                                                </label>                                  
                                            </div>
                                        </div>
                                    </div>                                       
                                </div>
                            </div>
                        </div>
                    </div>
                    <!--- final caddecimo --->  
                </div>
<!--- Final acordeon geral --->   
                <div class="row">   
                    <p></p> 
                    <div class="col" align="center">                                         
                        <a type="button" onClick="return valida_formCadItem()" class="btn btn-primary">Cadastrar</a>     
                    </div>
                    <div class="col" align="center">    
                        <a type="button" onClick="javascript:if(confirm('Deseja cancelar este cadastro?\n\nObs: Esta ação não cancela cadastros já confirmados.\n\nCaso afirmativo, clique em OK.')){window.open('cadastroGruposItens.cfm','_self')}" href="#" class="btn btn-danger">Cancelar</a>
                    </div>
                    <p></p> 
                </div>    
                <input type="hidden" id="itnclassificacontrole" name="itnclassificacontrole" value="">    
                <input type="hidden" id="itncategoriacontrole" name="itncategoriacontrole" value="">   
                <input type="hidden" id="itnobjetivoestrategico" name="itnobjetivoestrategico" value="">  
                <input type="hidden" id="itnriscoestrategico" name="itnriscoestrategico" value="">  
                <input type="hidden" id="itnindicadorestrategico" name="itnindicadorestrategico" value=""> 
                <input type="hidden" id="processon1naoaplicarSN" name="processon1naoaplicarSN" value="N"> 
                <input type="hidden" id="processon3outrosSN" name="processon3outrosSN" value="N"> 
                <input type="hidden" id="riscoidentificadoSN" name="riscoidentificadoSN" value="N"> 
                <input type="hidden" id="checkpontuacaocadseq" name="checkpontuacaocadseq" value=""> 
                <input type="hidden" id="checkpontuacaocadagfseq" name="checkpontuacaocadagfseq" value=""> 
                
            </form>
        </div>


        <script src="public/bootstrap/bootstrap.bundle.min.js"></script>
        <script src="public/jquery-3.7.1.min.js"></script>
        <script type="text/javascript" src="public/axios.min.js"></script>
<script type="text/javascript"> 
//alert('Dom inicializado!');     

//  var local = "parametros.cfm";
 
        CKEDITOR.replace('cadItemOrientacao', {
            width: '100%',
            height: 50,   
            removePlugins: 'scayt',
            disableNativeSpellChecker: false,
            toolbar: [
                ['Preview', 'Print', '-' ],
                [ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript'],
                [ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
                '/',
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
            ]

        });

        CKEDITOR.replace('cadItemPreRelato', {
            width: '100%',
            height: 50,
            removePlugins: 'scayt',//corretor ortografico
            disableNativeSpellChecker: false,
            toolbar: [
                ['Preview', 'Print', '-' ],
                [ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript' ],
                [ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
                 '/',               
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
            ]

        });

        CKEDITOR.replace('cadItemOrientacaoRelato', {
            width: '100%',
            height: 50,
            removePlugins: 'scayt',//corretor ortografico
            disableNativeSpellChecker: false,
            toolbar: [
                ['Preview', 'Print', '-' ],
                [ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript' ],
                [ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'],
                '/',
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
            ]
        });

        CKEDITOR.replace('cadItemAmostra', {
        width: '100%',
        height: 50,
        toolbar: [
                ['Preview', 'Print', '-' ],
                [ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript' ],
                [ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'],
                '/',
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
            ]				
        });

        CKEDITOR.replace('cadItemNorma', {
        width: '100%',
        height: 50,
        toolbar: [
                ['Preview', 'Print', '-' ],
                [ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript' ],
                [ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'],
                '/',
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
            ]
        });
       $(function(e){
        //alert('Dom inicializado!');        
        //alert('aqui');        
            $('#cadimpactartipos').hide()
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "classifctrl"
              }
            })
            .then(data =>{
                  let prots = ''
                  //console.log(data.data)
                  //console.log(data.data.indexOf("COLUMNS"));
                  var vlr_ini = data.data.indexOf("COLUMNS");
                  var vlr_fin = data.data.length
                  vlr_ini = (vlr_ini - 2);
                // console.log('valor inicial: ' + vlr_fin);
                  const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                  //console.log(json);
                  const dados = json.DATA;
                  dados.map((ret) => {
                  prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
                });
              $("#classifcontrole").html(prots);
            })    
            //busca da categoria   
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "categcontrole"
              }
            })
            .then(data =>{
                let prots = ''
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#categcontrole").html(prots);
            })  

            //buscar categoria risco     
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "categoriarisco"
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#categoriarisco").html(prots);
            })  

            // buscar macroprocesso   
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "macroprocesso"
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#macroprocesso").html(prots);
            }) 
            // buscar diretoria do processo  
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "gestordiretoria"
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#gestordir").html(prots);
            })   
              
            //busca da objetivo estrategico     
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "objetivoestrategico"
              }
            })
            .then(data =>{
              let prots = '';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#objetivoestrategico").html(prots);
              //$("#mensagem").html(prots);
            })  
             
            //busca da risco estrategico  
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "riscoestrategico"
              }
            })
            .then(data =>{
                let prots = ''
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#riscoestrategico").html(prots);
              //$("#mensagem").html(prots);
            })  
              
            //busca da indicador estrategico      
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "indicadorestrategico"
              }
            })
            .then(data =>{
                let prots = ''
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#indicadorestrategico").html(prots);
              //$("#mensagem").html(prots);
            })  
             //componentecoso2013 
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "componentecoso"
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#componentecoso").html(prots);
              //$("#mensagem").html(prots);
            })                                                  
            processosajustes('abertura');  
            //ajustes de divs plano de teste
            //$("#salvar").hide();
            $("#proprias").hide();  
            $("#franquia").hide();  
                    
        }) 
        // fim abertura do DOM                 
//==========================================================================================
        $('#selCadItemAno').change(function(e){
            //buscar os grupos por ano selecionado
            let anogrupo = $(this).val()
            if(anogrupo==''){
                $('#selCadItemGrupo').html('<option value="" selected>---</option>')
                $('#selCadModalidade').html('<option value="" selected>---</option>')
                $('#selCadItemValorDec').html('<option value="" selected>---</option>')
                $('#selCadItemValidObrig').html('<option value="" selected>---</option>')
            }
            //alert('modalgrupo: '+modalgrupo +' anogrupo: '+anogrupo);
            //buscar Grupos
            axios.get("CFC/grupoitem.cfc",{
                params: {
                method: "cadgruposverificacao",
                anogrupo: anogrupo
                }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                //console.log(data.data)
                //console.log(data.data.indexOf("COLUMNS"));
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                // console.log('valor inicial: ' + vlr_fin);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                //console.log(json);
                const dados = json.DATA;
                let usadoSN=''
                //Grp_Codigo, Grp_Descricao, Itn_NumItem
                //    0            1              2
                dados.map((ret) => {
                    usadoSN=''
                    if(ret[2] == undefined){usadoSN = '(sem itens) '}
                    prots += '<option value="' + ret[0] + '">' +usadoSN+ret[0]+'-'+ret[1]+'</option>';
                })
                $('#selCadItemGrupo').html(prots)
            })               
        })   
      
        //buscar macroporcessoN1
        $('#macroprocesso').change(function(e){
            let prots = '<option value="" selected>---</option>';
            $("#macroprocesson1").html(prots);
            $("#macroprocesson2").html(prots);
            $("#macroprocesson3").html(prots);
            processosajustes('macroprocesso');
            var PCN1MAPCID = $(this).val();          
            axios.get("CFC/grupoitem.cfc",{
                params: {
                method: "macroprocesson1",
                PCN1MAPCID: PCN1MAPCID
                }
            })
            .then(data =>{
                  let prots = '<option value="" selected>---</option>';
                  var vlr_ini = data.data.indexOf("COLUMNS");
                  var vlr_fin = data.data.length
                  vlr_ini = (vlr_ini - 2);
                  const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                  const dados = json.DATA;
                  dados.map((ret) => {
                  prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
                });
                $("#macroprocesson1").html(prots);
            })  
          })     
          // inicio macroprocesson1 -  Não se aplica
          $('#cd_macroprocesson1').click(function(){
            $("#macroprocesson1-naoseaplica").hide();
            $("#macroprocesson3-outros").hide();
            $("#cd_macroprocesson3").prop("checked", false);
            $("#cd_macroprocesson3").attr('disabled', true);
            var prots = '<option value="" selected>---</option>';
            $("#macroprocesson1").html(prots);
            $("#macroprocesson2").html(prots);
            $("#macroprocesson3").html(prots);
           // processosajustes('macroprocesson1');
            if($(this).is(':checked')) {
              $("#macroprocesson1").attr('disabled', true);
              $("#macroprocesson2").attr('disabled', true);
              $("#macroprocesson3").attr('disabled', true);
              $("#macroprocesson1-naoseaplica").show();
              $("#processon1naoaplicarSN").val('S');
            }else{
              $("#processon1naoaplicarSN").val('N');
              $("#macroprocesson1").attr('disabled', false);
              //realizar nova busca e preecher o macroprocesson1
              var PCN1MAPCID = $("#macroprocesso").val();
              axios.get("CFC/grupoitem.cfc",{
                params: {
                method: "macroprocesson1",
                PCN1MAPCID: PCN1MAPCID
                }
              })
              .then(data =>{
                  let prots = '<option value="" selected>---</option>';
                  var vlr_ini = data.data.indexOf("COLUMNS");
                  var vlr_fin = data.data.length
                  vlr_ini = (vlr_ini - 2);
                  const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                  const dados = json.DATA;
                  dados.map((ret) => {
                  prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
                });
                $("#macroprocesson1").html(prots);
              })           
            }
          })       
          // fim macroprocesson1-Não se aplica            
        //buscar macroporcessoN2
        $('#macroprocesson1').change(function(e){
            let prots = '<option value="" selected>---</option>';
            $("#macroprocesson3").html(prots);
            $("#macroprocesson3-outros").hide();
            $("#macroprocesson2").html(prots);
            processosajustes('macroprocesson1');
            var PCN1MAPCID = $("#macroprocesso").val();
            var PCN1ID = $(this).val();
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "macroprocesson2",
              PCN1MAPCID: PCN1MAPCID,
              PCN1ID: PCN1ID
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
                $("#macroprocesson2").html(prots);
                //$("#mensagem").html(prots);
            })  
        })//final buscar macroporcessoN2   
        //inicio buscar macroprocessoN3
        $('#macroprocesson2').change(function(e){
            $("#cd_macroprocesson3").attr('disabled', false);
            $("#macroprocesson3-outros").hide();
            let prots = '<option value="" selected>---</option>';
            $("#macroprocesson3").attr('disabled', false);
            $("#macroprocesson3").html(prots);
            processosajustes('macroprocesson2');
            var PCN3PCN2PCN1MAPCID = $("#macroprocesso").val();
            var PCN3PCN2PCN1ID = $("#macroprocesson1").val();
            var PCN3PCN2ID = $(this).val();
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "macroprocesson3",
              PCN3PCN2PCN1MAPCID: PCN3PCN2PCN1MAPCID,
              PCN3PCN2PCN1ID: PCN3PCN2PCN1ID,
              PCN3PCN2ID: PCN3PCN2ID
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
                $("#macroprocesson3").html(prots);
                //$("#mensagem").html(prots);
            }) 
 
        })   
        //final buscar macroprocessoN3  
        // inicio macroprocesson3-Outros
        //==============================
        $('#cd_macroprocesson3').click(function(){
          $("#macroprocesson3-outros").hide();
          let prots = '<option value="" selected>---</option>';
          $("#macroprocesson3").html(prots);
          if($(this).is(':checked')) {
            $("#macroprocesson3").attr('disabled', true);
            $("#macroprocesson3-outros").show();
            $("#processon3outrosSN").val('S');
          }else{
            $("#processon3outrosSN").val('N');
            $("#macroprocesson3").attr('disabled', false);
            //realizar nova busca e preecher o macroprocesson1
            var PCN3PCN2PCN1MAPCID = $("#macroprocesso").val();
            var PCN3PCN2PCN1ID = $("#macroprocesson1").val();
            var PCN3PCN2ID = $("#macroprocesson2").val();
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "macroprocesson3",
              PCN3PCN2PCN1MAPCID: PCN3PCN2PCN1MAPCID,
              PCN3PCN2PCN1ID: PCN3PCN2PCN1ID,
              PCN3PCN2ID: PCN3PCN2ID
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
                $("#macroprocesson3").html(prots);
                //$("#mensagem").html(prots);
            }) 
          }
    //alert($("#processon3outrosSN").val())               
     })       
     // fim macroprocesson3-Outros                                       
        //buscar o principios do coso passando filtro do componentecoso
        $('#componentecoso').change(function(e){
          let prots = '<option value="" selected>---</option>';
            $("#principioscoso").attr('disabled', false);
            var PRCSCPCSID = $(this).val();
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "principioscoso",
              PRCSCPCSID: PRCSCPCSID
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
                $("#principioscoso").html(prots);
                //$("#mensagem").html(prots);
            }) 
        }) 
        //buscar o departamento do processo
        $('#gestordir').change(function(e){ 
            let prots = '<option value="" selected>---</option>';
            $("#gestordepto").html(prots);  
            let digpid = $(this).val(); 
            if(gestordir != ''){                         
                axios.get("CFC/grupoitem.cfc",{
                    params: {
                        method: "gestorprocesso",
                        digpid: digpid
                    }
                })
                .then(data =>{
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                    prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
                });
                $("#gestordepto").html(prots);
                })  
            }
        })//fim buscar o departamento do processo
        function processosajustes(a){
          if (a == 'abertura'){
          //  alert(a);
              $("#riscoidentif-outros").hide();
              $("#macroprocesson1-naoseaplica").hide();
              $("#macroprocesson3-outros").hide();
             // $("#exibir-objetivoestrategico").hide();
              $("#cd_macroprocesson1").attr('disabled', true);
              $("#cd_macroprocesson3").attr('disabled', true);
              $("#principioscoso").attr('disabled', true);
              $("#macroprocesson1").attr('disabled', true);
              $("#macroprocesson2").attr('disabled', true);
              $("#macroprocesson3").attr('disabled', true);
          }
          if (a == 'macroprocesso'){
         //   alert(a);
            $("#cd_macroprocesson1").attr('disabled', false);
            $("#cd_macroprocesson1").prop("checked", false);
            $("#cd_macroprocesson3").attr('disabled', true);
            $("#cd_macroprocesson3").prop("checked", false);
            $("#macroprocesson1-naoseaplica").hide();
            $("#macroprocesson3-outros").hide();
            $("#macroprocesson1").attr('disabled', false);
            $("#macroprocesson2").attr('disabled', true);
            $("#macroprocesson3").attr('disabled', true);
          }
          if (a == 'macroprocesson1'){
           // alert(a);
            $("#macroprocesson2").attr('disabled', false);
            $("#cd_macroprocesson3").attr('disabled', true);
            $("#cd_macroprocesson3").prop("checked", false);
            $("#macroprocesson3-outros").hide();
            $("#macroprocesson3").attr('disabled', true);
          }  
          if (a == 'macroprocesson2'){
           // alert(a);
            $("#cd_macroprocesson3").attr('disabled', false);
            $("#cd_macroprocesson3").prop("checked", false);
            $("#macroprocesson3-outros").hide();
            $("#macroprocesson3").attr('disabled', false);
          }                   
        }  
           
        // tratar as seleções do tipo de unidade               
        $('.tipounid').click(function(){
           var title = $(this).attr("title");
           //alert($(this).attr("id"));
           var outros = 0;
           var agfsn = 'N'
           let tpunid = ''

           //verificar outras seleção
            $( ".tipounid" ).each(function( index ) {
                if($(this).attr("title") != 0){
                    //alert( index + ": " + $(this).attr("title") );
                    outros = outros + 1
                    tpunid = $(this).attr("id")
                    if(tpunid == 12){agfsn = 'S'}
                }
            });

           if(title == 0){
                // tipo de unidade foi selecionada
                //alterar o title do botão
                $(this).attr("title","1");
                // alterar a class do botão
                $(this).attr("class","tipounid btn btn-success");
                $(this).css('box-shadow', '10px 10px 5px #888')
                title = 1
                tpunid = $(this).attr("id");
                if(tpunid == 12){agfsn = 'S'}
           }else{
                //tipo de unidade foi deselecionada
                //alterar o title do botão
                $(this).attr("title","0");
                // alterar a class do botão
                $(this).attr("class","tipounid btn btn-primary");
                $(this).css('box-shadow', '10px 10px 5px 0');  
                title = 0  
                tpunid = $(this).attr("id"); 
                if(tpunid == 12){agfsn = 'N'} 
           } 
            //alert(agfsn);                
           if((outros != 0) || (outros == 0 && title == 0) || title == 1){ 
                //$("#salvar").show(500);
                $("#proprias").show(500);
           }

           if(outros == 1 && title == 0){ 
                //$("#salvar").hide(500);
                $("#proprias").hide(500);
                $("#franquia").hide(500);
           }  
            if(agfsn == 'S'){$("#franquia").show(500);}                
            if(agfsn == 'N'){
                $( ".checkPontuacaoCadAGF" ).each(function( index ) {
                    if($(this).val() == 0){
                        $(this).prop('checked',true);
                        totalb = 0
                    }
                });
                somaragf();
                $("#franquia").hide(500);
            }
              // alert(outros + '  ' + title)   
                        
        })  
        //somatório pontuação unidades próprias
        $('.checkPontuacaoCad').click(function(){
        //alert('Aqui');
            var total = 0
            let tit = 0
            let impacto10sn = 'N'
            let frsprots = ''
            let selecionar = ''
            $( ".checkPontuacaoCad" ).each(function( index ) {
                if($(this).is(':checked')){
                    //alert( index + ": " + $(this).val());
                    total = total + eval($(this).val())
                    tit = $(this).attr("title")
                    if(tit == '10'){
                        impacto10sn = 'S'
                    }                    
                }
            })
            $('#pontuacaoCalculadaCad').val(total); 
            somaragf()
            if(impacto10sn == 'N'){
                $("#selcadfalta").html('<option value="N">N</option>') 
                $("#selcadsobra").html('<option value="N">N</option>') 
                $("#selcadrisco").html('<option value="N">N</option>') 
                $('#cadimpactartipos').hide()
            }else{
                $('#cadimpactartipos').show(500)
                frsprots = '<option value="N">N</option>'
                frsprots += '<option value="F">F</option>'
                $("#selcadfalta").html(frsprots) 
                frsprots = '<option value="N">N</option>'
                frsprots += '<option value="S">S</option>'
                $("#selcadsobra").html(frsprots) 
                frsprots = '<option value="N">N</option>'
                frsprots += '<option value="R">R</option>'
                $("#selcadrisco").html(frsprots)                         
            }            
        })
        //somatório pontuação unidade AGF
        $('.checkPontuacaoCadAGF').click(function(){
            var total = eval($(this).val())
            $('#pontuacaoCalculadaCadAGF').val(total); 
            somaragf()
        })        
        //calcular total AGF
        function somaragf(){
            var totala = 0
            $( ".checkPontuacaoCad" ).each(function( index ) {
                if($(this).is(':checked')){
                    //alert( index + ": " + $(this).val());
                    totala = totala + eval($(this).val())
                }
            });
            var totalb = 0
            $( ".checkPontuacaoCadAGF" ).each(function( index ) {
                if($(this).is(':checked')){
                    //alert( index + ": " + $(this).val());
                    totalb = totalb + eval($(this).val())
                }
            });
            var total = eval(totala) + eval(totalb) 
            $('#pontuacaoCalculadaCadAGF').val(total);
        }

        // Categoria do controle testado
        $('#categcontrole').click(function() {
              $("#exibir-categcontrole").hide();
              var auxselect = '';
              $('#categcontrole  > option:selected').each(function() {
               // auxselect += ($(this).text() + ' ' + $(this).val());
               if(auxselect == '') {
                  auxselect += $(this).text();
               }else{
                  auxselect += '#' + $(this).text();
               }
              }); 
              if(auxselect != '') { $("#exibir-categcontrole").show();}
              $("#exibir-categcontrole").html(auxselect);
              //campo a ser salvo 
              $('#itncategoriacontrole').val($(this).val());  
        }); 

        $('#categoriarisco').click(function() {
          $("#riscoidentif-outros").hide();
            var auxselect = '';
            $('#categoriarisco  > option:selected').each(function() {
              auxselect += $(this).text();
            })
            if(auxselect == 'Outros'){
              $("#riscoidentif-outros").show();
              $("#riscoidentificadoSN").val('S');
            }else{
                $("#riscoidentificadoSN").val('N');
            }
        }); 
        //Obter opções selecionadas para realizar a crítica do submit e salvar informação
        $('#classifcontrole').click(function() {
            $('#itnclassificacontrole').val($(this).val())
        }); 
        $('#objetivoestrategico').click(function() {
            $('#itnobjetivoestrategico').val($(this).val())
        }); 
        $('#riscoestrategico').click(function() {
            $('#itnriscoestrategico').val($(this).val())
           // alert($('#itnriscoestrategico').val())
        });
        $('#indicadorestrategico').click(function() {
            $('#itnindicadorestrategico').val($(this).val())
           // alert($('#itnindicadorestrategico').val())
        }); 
        // Preparo para as críticas do submit
        function tpunidselec() {
            var tpunid = ''
           //verificar os tipos selecionados
            $( ".tipounid" ).each(function( index ) {
                if($(this).attr("title") != 0){           
                    if(tpunid == '') {
                        tpunid = $(this).attr("id")
                    }else{
                        tpunid = tpunid + ','+$(this).attr("id")
                    }
                }
            })
            //alert(tpunid)
            return tpunid
        }   
        //Obter o valores PTC_Seq dos dos checkbox selecionados
        function ObterPtcSeqPropria(){
            var ptcseq = ''
            $( ".checkPontuacaoCad" ).each(function( index ) {
                if($(this).is(':checked')){
                    if(ptcseq == '') {
                        ptcseq = $(this).attr("title")
                    }else{
                        ptcseq = ptcseq + ','+$(this).attr("title")
                    }
                }
            })
           // alert(ptcseq)
            return ptcseq              
        } 
        //Obter o valores PTC_Seq radiobox selecionado
        function ObterPtcSeqAGF(){
            var ptcseqagf = 0;
            $( ".checkPontuacaoCadAGF" ).each(function( index ) {
                if($(this).is(':checked')){
                    ptcseqagf = $(this).attr("title")
                }
            })
         //alert(ptcseqagf)
            return ptcseqagf              
        }
        //****************************************************
        //Críticas do form principal
        function valida_formCadItem(){
            var tiposSelecionados="";        
            //tiposSelecionados = selectChecbox('checkPontuacaoCad');       
            var frm = document.getElementById('formCadItem');
  
            // Obter os tipos de unidades           
            tiposSelecionados = tpunidselec();
            frm.tiposCad.value = tiposSelecionados;
            //alert("tiposSelecionados: " + frm.tiposCad.value);

            // Obter PtcSeqPropria
            ptcseq = ObterPtcSeqPropria();
            frm.checkpontuacaocadseq.value = ptcseq
            //alert("ptcseq " + ptcseq);

            // Obter PtcSeqAGF
            ptcseqagf = ObterPtcSeqAGF();
            //alert("ptcseqagf " + ptcseqagf);  
            if(ptcseqagf > 0){
                frm.checkpontuacaocadagfseq.value = ptcseq+','+ptcseqagf;
            }else{
                frm.checkpontuacaocadagfseq.value = ptcseq;
            }                     
            //alert(frm.checkpontuacaocadagfseq.value);

            if (frm.selCadItemAno.value == '') {
				alert('Informe o ano que este item será utilizado!');
				frm.selCadItemAno.focus();
				return false;
			}

            if (frm.selCadItemGrupo.value == '') {
				alert('Informe um grupo para item!');
				frm.selCadItemGrupo.focus();
				return false;
			}
            if (frm.selCadModalidade.value == '') {
				alert('Informe a modalidade do item do Plano de Teste!');
				frm.selCadModalidade.focus();
				return false;
			}
            if (frm.selCadItemValorDec.value == '') {
				alert('Informe se o item prevê ou não valor declarado!');
				frm.selCadItemValorDec.focus();
				return false;
			}
            
            if (frm.selCadItemValidObrig.value == '') {
				alert('Informe se o item deve obrigatoriamente ser validado pelo gestor em caso de avaliação "NÃO EXECUTA"!');
				frm.selCadItemValidObrig.focus();
				return false;
			}

            var frmselcadreindencias = frm.selcadreindencias.value
            if (frmselcadreindencias != '') {
                let recusarsn = 'N'
                let contarr = 0
                var arr = frmselcadreindencias.split(',')         
                $.each( arr, function( i, val ) {
                    if (val.indexOf(",") > 0 || val.indexOf("_") < 0) {
                        recusarsn = 'S'
                    }  
                    contarr++ 
                })

                if (contarr == 1) {
                    if ((frmselcadreindencias.indexOf(",") <= 0 && frmselcadreindencias.indexOf("_") != frmselcadreindencias.lastIndexOf("_"))) 
                    {
                        recusarsn = 'S'
                    } 
                }  
                              
                if (recusarsn == 'S') {
                    alert('Reincidência(s) (grupo/item), fora do padrão, verificar exemplos de preenchimento!');
                    frm.selcadreindencias.focus();
                    return false;
                }                    
            }

            if (frm.cadItemDescricao.value == '') {
				alert('Informe uma descrição para item!');
				frm.cadItemDescricao.focus();
				return false;
			}

            if (frm.cadItemManchete.value == '') {
				alert('Informar a Manchete para item!');
				frm.cadItemManchete.focus();
				return false;
			}

            if (CKEDITOR.instances.cadItemOrientacao.getData()== '') {
				alert('Informe "COMO EXECUTAR/PROCEDIMENTOS ADOTADOS" para o item!');
				CKEDITOR.instances.cadItemOrientacao.focus();
				return false;
			}

            if (CKEDITOR.instances.cadItemAmostra.getData()== '') {
				alert('Informe a Amostra para o item!');
				CKEDITOR.instances.cadItemAmostra.focus();
				return false;
			}

            if (CKEDITOR.instances.cadItemNorma.getData()== '') {
				alert('Informe a Norma para o item!');
				CKEDITOR.instances.cadItemNorma.focus();
				return false;
			}

            if (CKEDITOR.instances.cadItemPreRelato.getData()== '') {
				alert('Informe um modelo de relato para o item.');
				CKEDITOR.instances.cadItemPreRelato.focus();
				return false;
			}
            
            if (CKEDITOR.instances.cadItemOrientacaoRelato.getData()== '') {
				alert('Informe uma orientação para o órgão.');
				CKEDITOR.instances.cadItemOrientacaoRelato.focus();
				return false;
			}

            // críticas para os novos campos  Gilvan 16/10/2024
            if ($('#itnclassificacontrole').val() == '') {
                alert('Selecione uma ou mais Classificação do Controle.');
                frm.classifcontrole.focus();
                return false;
            }
            
            if ($('#controletestado').val() == '') {
                alert('Informe o Controle Testado.');
                frm.controletestado.focus();
                return false;
            }  

            if ($('#itncategoriacontrole').val() == '') {
                alert('Selecione uma ou mais Categoria do Controle.');
                frm.categcontrole.focus();
                return false;
            }   

            if ($('#riscoidentificadoSN').val() == 'N' && $('#categoriarisco').val() == '') {
                alert('Selecione um Risco Identificado.');
                frm.categoriarisco.focus();
                return false;
            } 

            if ($('#riscoidentificadoSN').val() == 'S' && $('#categoriariscooutros').val() == '') {
                alert('Informe a descrição para opção Outros selecionada como Risco Identificado.');
                frm.categoriariscooutros.focus();
                return false;
            } 

            if ($('#macroprocesso').val() == '') {
                alert('Selecione um Macroprocesso como Tipo de Avaliação.');
                frm.macroprocesso.focus();
                return false;
            }  

            if ($('#processon1naoaplicarSN').val() == 'S' && $('#macroprocesson1naoseaplica').val() == '') {
                alert('Informe a descrição para opção Não se Aplica selecionada como Processo N1.');
                frm.macroprocesson1naoseaplica.focus();
                return false;
            }  

            if ($('#processon1naoaplicarSN').val() == 'N' && $('#macroprocesson1').val() == '') {
                alert('Selecione um Processo N1 como Tipo de Avaliação.');
                frm.macroprocesson1.focus();
                return false;
            } 

            // críticas para os campos Processo N2 e Processo N3
            if ($('#processon1naoaplicarSN').val() == 'N') {
                if ($('#macroprocesson2').val() == '') {
                    alert('Selecione um Processo N2 como Tipo de Avaliação.');
                    frm.macroprocesson2.focus();
                    return false;
                }   
                if ($('#processon3outrosSN').val() == 'S'  && $('#macroprocesson3outros').val() == '') {
                    alert('Informe a descrição para opção Outros selecionada como Processo N3.');
                    frm.macroprocesson3outros.focus();
                    return false;
                }   
                if ($('#processon3outrosSN').val() == 'N'  && $('#macroprocesson3').val() == '') {
                    alert('Selecione um Processo N3 como Tipo de Avaliação.');
                    frm.macroprocesson3.focus();
                    return false;
                }                                            
            }  
            
            if ($('#gestordir').val() == '') {
                alert('Selecione uma Diretoria do Processo.');
                frm.gestordir.focus();
                return false;
            }   

            if ($('#gestordepto').val() == '') {
                alert('Selecione um Departamento do Processo.');
                frm.gestordepto.focus();
                return false;
            }  

            if ($('#itnobjetivoestrategico').val() == '') {
                alert('Selecione uma ou mais Objetivo(s) Estratégico.');
                frm.objetivoestrategico.focus();
                return false;
            }  

            if ($('#itnriscoestrategico').val() == '') {
                alert('Selecione uma ou mais Risco(s) Estratégico.');
                frm.riscoestrategico.focus();
                return false;
            } 

            if ($('#itnindicadorestrategico').val() == '') {
                alert('Selecione uma ou mais Indicador(es) Estratégico.');
                frm.indicadorestrategico.focus();
                return false;
            }  

            if ($('#componentecoso').val() == '') {
                alert('Selecione um Componente - COSO 2013.');
                frm.componentecoso.focus();
                return false;
            }  

            if ($('#principioscoso').val() == '') {
                alert('Selecione um Princípio - COSO 2013.');
                frm.principioscoso.focus();
                return false;
            }// final criticas dos novos campos

            if (frm.pontuacaoCalculadaCad.value == 0) {
				alert('Selecione, ao menos, 01(um) Tipo de Unidade para o qual o item será aplicado nas avaliações.\nSelecionar a Composição de Pontuação do Item!');
				return false;
			}
        
            if ((tiposSelecionados.indexOf(12) !== -1) && (frm.pontuacaoCalculadaCad.value == frm.pontuacaoCalculadaCadAGF.value)) {
                alert('Informar o ponto adicional para o tipo de unidade AGF!')
                return false;
            } 

            if(window.confirm('Deseja cadastrar  este Item?')){  
                //frm.tipos.value=tiposSelecionados; 
                frm.acao.value = 'cadItem';
			    aguarde();
                setTimeout('document.getElementById("formCadItem").submit();',1000);
                return true;	
            }else{ return false }
        } //fim das críticas do submit     

        function cadformatoreincidentes() {
            var tecla = window.event.keyCode;
            //alert(tecla)
            //permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)	
                if ((tecla < 48 || tecla > 57) && (tecla != 44 && tecla != 95)) {
                //alert(tecla);
                event.returnValue = false;
            }
        }                     
</script>
</body>
</html>