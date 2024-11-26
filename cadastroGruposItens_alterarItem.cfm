<cfprocessingdirective pageEncoding ="utf-8">
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="permissao_negada.htm">
	<cfabort>
</cfif>     
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfif isDefined("form.formAltItem") >
    <cfparam name="form.acaoalt" default="#form.acao#">
    <cfparam name="form.selAltItemAno" default="#form.selAltItemAno#">
    <cfparam name="form.selAltItemGrupo" default="#form.selAltItemGrupo#">
    <cfparam name="form.selAltItem" default="#form.selAltItem#">
    <cfparam name="form.selAltModalidade" default="#form.selAltModalidade#">
    <cfparam name="form.modalidades" default="#form.modalidades#">
<cfelse>
    <cfparam name="form.acaoalt" default="">
    <cfparam name="form.selAltItemAno" default="">
    <cfparam name="form.selAltItemGrupo" default="">
    <cfparam name="form.selAltItem" default="">
    <cfparam name="form.selAltModalidade" default="">
    <cfparam name="form.modalidades" default="">
</cfif>
<cfquery name="rsPta" datasource="#dsn_inspecao#">
    SELECT PTC_Seq, PTC_Valor, PTC_Descricao, PTC_Status, PTC_dtultatu, PTC_Username, PTC_Franquia 
    FROM Pontuacao WHERE PTC_Ano = '#year(now())#'
</cfquery> 
<cfif isDefined("form.acaoalt") and "#form.acaoalt#" eq 'altItem'>  
    <cfquery name="rsPta" datasource="#dsn_inspecao#">
        SELECT PTC_Seq, PTC_Valor, PTC_Descricao, PTC_Status, PTC_dtultatu, PTC_Username, PTC_Franquia 
        FROM Pontuacao WHERE PTC_Ano = '#form.selAltItemAno#'
    </cfquery> 
    <cfif rsPta.recordcount lte 0>
        <cfoutput>
            <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=BASE CADASTRAL: Falta informar os dados na tabela PONTUACAO para o ano: #form.selAltItemAno#">
        </cfoutput>
    </cfif>
    <!--- Tipos de unidades não selecionados para o ano,modalidade,grupo e item  tabela TipoUnidade_ItemVerificacao --->
    <cfset tiposunidselec = form.tiposalt>
    <cfquery datasource="#dsn_inspecao#">
        DELETE FROM TipoUnidade_ItemVerificacao
        WHERE TUI_Ano='#form.selAltItemAno#' AND 
        TUI_Modalidade='#form.selAltModalidade#' AND 
        TUI_GrupoItem=#form.selAltItemGrupo# AND 
        TUI_ItemVerif=#form.selAltItem# AND 
        TUI_TipoUnid Not In (#tiposunidselec#)
    </cfquery>
    <!--- Tipos de unidades não selecionados para o ano,modalidade,grupo e item  tabela Itens_Verificacao --->
    <cfquery datasource="#dsn_inspecao#">
        DELETE FROM Itens_Verificacao
        WHERE Itn_Ano = '#form.selAltItemAno#' AND 
        Itn_Modalidade = '#form.selAltModalidade#' AND 
        Itn_NumGrupo = #form.selAltItemGrupo# AND 
        Itn_NumItem = #form.selAltItem# and
        Itn_TipoUnidade Not In (#tiposunidselec#) 
    </cfquery>
        
    <cftransaction>
<!--- 				    
    frm.tiposalt.value ==> Tipos de unidades selecionadas
    frm.pontuacaoCalculadaAlt.value    ==> pontuação unidades próprias
    frm.pontuacaoCalculadaAltAGF.value ==> pontuação unidade AGF
    frm.checkPontuacaoAltseq.value     ==> Itn_PTC_Seq unidadde próprias
    frm.checkPontuacaoAltagfseq.value  ==> Itn_PTC_Seq unidade AGF
--->	

        <!---Iincluir ou Alterar as tabelas TipoUnidade_ItemVerificacao e Itens_Verificacao --->               
        <cfloop list="#tiposunidselec#" index="i">
            <cfset tipo = "#i#">
           	<!--- Obter a pontuação max pelo ano e tipo da unidade --->
            <cfquery name="rsPtoMax" datasource="#dsn_inspecao#">
                SELECT TUP_PontuacaoMaxima 
                FROM Tipo_Unidade_Pontuacao 
                WHERE TUP_Ano = '#form.selAltItemAno#' AND TUP_Tun_Codigo in (#tipo#)
            </cfquery>
            <cfif rsPtoMax.recordcount lte 0>
                <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=BASE CADASTRAL: Falta informar os dados na tabela TIPO_UNIDADE_PONTUACAO para o ano: #form.selAltItemAno# e Cod_Tipo_Unidade = #tipo#">
            </cfif>					
			<!--- calcular o perc de classificacao do item --->	
            <cfif tipo eq 12>
                <cfset pontuacao = #form.pontuacaoCalculadaAltAGF#>
                <cfset altpontuacaoseq = #form.checkPontuacaoAltagfseq#>
				<cfset PercClassifItem = NumberFormat(((#pontuacao# / rsPtoMax.TUP_PontuacaoMaxima) * 100),999)>	
            <cfelse>
                <cfset pontuacao = #form.pontuacaoCalculadaAlt#>
                <cfset altpontuacaoseq = #form.checkPontuacaoAltseq#>
                <cfset PercClassifItem = NumberFormat(((#pontuacao# / rsPtoMax.TUP_PontuacaoMaxima) * 100),999)>	
            </cfif>                    
            <!--- calculo da descricao do item a saber GRAVE, MEDIANO ou LEVE --->
            <cfif PercClassifItem gt 40>
                <cfset ClassifITEM = 'GRAVE'> 
            <cfelseif PercClassifItem gt 10 and PercClassifItem lte 40>
                <cfset ClassifITEM = 'MEDIANO'> 
            <cfelseif PercClassifItem lte 10>
                <cfset ClassifITEM = 'LEVE'> 
            </cfif>		
            <!--- Ajustes de campos para Não aplicar Processo N1 --->
            <cfif form.processon1naoaplicarSNAlt eq 'S'>
                <cfset altprocesson1 = 0>
                <cfset altprocesson2 = 0>
                <cfset altprocesson3 = 0>
                <cfset form.altprocesson3outros=''>
                <cfset form.processon3outrosSNAlt='S'>
            <cfelse>
                <cfset altprocesson1 = #form.altprocesson1#>
                <cfset form.altprocesson1naoseaplica=''>
                <cfset altprocesson2 = #form.altprocesson2#>
            </cfif>

            <cfif form.processon3outrosSNAlt eq 'S'>
                <cfset altprocesson3 = 0>
            <cfelse>
                <cfset form.altprocesson3outros=''>
                <cfset altprocesson3 = #form.altprocesson3#>                    
            </cfif>
         	
			<!--- Incluir ou alterar a tabela TipoUnidade_ItemVerificacao --->
            <cfquery datasource="#dsn_inspecao#" name="rsExisteTPITEM">
                select TUI_Modalidade
                FROM TipoUnidade_ItemVerificacao
                WHERE TUI_Ano=#form.selAltItemAno# AND 
                TUI_Modalidade='#form.selAltModalidade#' AND 
                TUI_GrupoItem=#form.selAltItemGrupo# AND 
                TUI_ItemVerif=#form.selAltItem# AND 
                TUI_TipoUnid = #tipo#
            </cfquery>

            <cfif rsExisteTPITEM.recordcount lte 0>
                <!-- Inclusão -->
                <cfquery datasource="#dsn_inspecao#">
                    INSERT INTO TipoUnidade_ItemVerificacao 
                    (TUI_Ano,TUI_Modalidade,TUI_TipoUnid,TUI_GrupoItem,TUI_ItemVerif,TUI_DtUltAtu,TUI_UserName,TUI_Ativo,TUI_Pontuacao,TUI_Pontuacao_Seq,TUI_Classificacao)
                    VALUES 
                    (#form.selAltItemAno#,'#form.selAltModalidade#',#tipo#,#form.selAltItemGrupo#,#form.selAltItem#,CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#',0,#pontuacao#,'#altpontuacaoseq#','#ClassifITEM#') 
                </cfquery>
              
            <cfelse>
                <!-- Alteração -->
                <cfquery datasource="#dsn_inspecao#">
                    UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = #pontuacao#
                    , TUI_Pontuacao_Seq = '#altpontuacaoseq#'
                    , TUI_Classificacao = '#ClassifITEM#'
                    , TUI_DtUltAtu = CONVERT(DATETIME, getdate(), 103)
                    , TUI_UserName = '#qAcesso.Usu_Matricula#'
                    WHERE 
                    TUI_Ano = #form.selAltItemAno# AND 
                    TUI_Modalidade = '#form.selAltModalidade#' and 
                    TUI_TipoUnid = #tipo# AND 
                    TUI_GrupoItem = #form.selAltItemGrupo# AND 
                    TUI_ItemVerif = #form.selAltItem# 
                </cfquery>                
            </cfif>
            <!--- Incluir ou alterar a tabela Itens_Verificacao --->
            <cfquery datasource="#dsn_inspecao#" name="rsExisteItemVerif">
                select Itn_Ano
                    from Itens_Verificacao 
                WHERE 
                    Itn_Modalidade = '#form.selAltModalidade#' AND 
                    Itn_Ano = #form.selAltItemAno# AND 
                    Itn_TipoUnidade = #tipo# AND 
                    Itn_NumGrupo = #form.selAltItemGrupo# AND 
                    Itn_NumItem = #form.selAltItem# 
            </cfquery>
            <cfif rsExisteItemVerif.recordcount lte 0>
                <!-- Inclusão -->
                <cfquery datasource="#dsn_inspecao#">
                    INSERT INTO Itens_Verificacao 
                        (Itn_Modalidade,Itn_Ano,Itn_TipoUnidade,Itn_NumGrupo,Itn_NumItem,Itn_Descricao,Itn_Orientacao,Itn_Situacao,Itn_DtUltAtu,Itn_UserName,Itn_ValorDeclarado,Itn_Amostra,Itn_Norma,Itn_ValidacaoObrigatoria,Itn_PreRelato,Itn_OrientacaoRelato,Itn_Pontuacao,Itn_PTC_Seq,Itn_Classificacao,Itn_Manchete,Itn_ClassificacaoControle,Itn_ControleTestado,Itn_CategoriaControle,Itn_RiscoIdentificado,Itn_RiscoIdentificadoOutros,Itn_MacroProcesso,Itn_ProcessoN1,Itn_ProcessoN1NaoAplicar,Itn_ProcessoN2,Itn_ProcessoN3,Itn_ProcessoN3Outros,Itn_GestorProcessoDir,Itn_GestorProcessoDepto,Itn_ObjetivoEstrategico,Itn_RiscoEstrategico,Itn_IndicadorEstrategico,Itn_Coso2013Componente,Itn_Coso2013Principios)
                    VALUES 
                        ('#form.selAltModalidade#',#form.selAltItemAno#,#tipo#,#form.selAltItemGrupo#,#form.selAltItem#,'#form.altItemDescricao#','#form.altItemOrientacao#','D',CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#','#form.selAltItemValorDec#','#form.altItemAmostra#','#form.altItemNorma#','#form.selAltValidObrig#','#form.altItemPreRelato#','#form.altItemOrientacaoRelato#',#pontuacao#,'#altpontuacaoseq#','#ClassifITEM#','#form.altItemManchete#','#form.altclassifcontrole#','#form.altcontroletestado#','#form.itncategoriacontroleAlt#',#form.altcategoriarisco#,'#form.altcategoriariscooutros#',#form.altmacroprocesso#,#altprocesson1#,'#form.altprocesson1naoseaplica#',#altprocesson2#,#altprocesson3#,'#form.altprocesson3outros#',#form.altgestordir#,#form.altgestordepto#,'#form.itnaltobjetivoestrategicoAlt#','#form.itnaltriscoestrategicoAlt#','#form.itnaltindicadorestrategicoAlt#',#form.altcomponentecoso#,#form.altprincipioscoso#)                                    
                </cfquery>	 
            <cfelse>
                <!-- Alteração -->
                <cfquery datasource="#dsn_inspecao#">
							UPDATE Itens_Verificacao SET
                                Itn_Descricao='#form.altItemDescricao#'
                                ,Itn_Orientacao='#form.altItemOrientacao#'
                                ,Itn_Situacao='D'
                                ,Itn_DtUltAtu=CONVERT(DATETIME, getdate(), 103)
                                ,Itn_UserName='#qAcesso.Usu_Matricula#'
                                ,Itn_ValorDeclarado='#form.selAltItemValorDec#'
                                ,Itn_Amostra='#form.altItemAmostra#'
                                ,Itn_Norma='#form.altItemNorma#'
                                ,Itn_ValidacaoObrigatoria='#form.selAltValidObrig#'
                                ,Itn_PreRelato='#form.altItemPreRelato#'
                                ,Itn_OrientacaoRelato='#form.altItemOrientacaoRelato#'
                                ,Itn_Pontuacao=#pontuacao#
                                ,Itn_PTC_Seq='#altpontuacaoseq#'
                                ,Itn_Classificacao='#ClassifITEM#'
                                ,Itn_Manchete='#form.altItemManchete#'
                                ,Itn_ClassificacaoControle='#form.altclassifcontrole#'
                                ,Itn_ControleTestado='#form.altcontroletestado#'
                                ,Itn_CategoriaControle='#form.itncategoriacontroleAlt#'
                                ,Itn_RiscoIdentificado=#form.altcategoriarisco#
                                ,Itn_RiscoIdentificadoOutros='#form.altcategoriariscooutros#'
                                ,Itn_MacroProcesso=#form.altmacroprocesso#
                                ,Itn_ProcessoN1=#altprocesson1#
                                ,Itn_ProcessoN1NaoAplicar='#form.altprocesson1naoseaplica#'
                                ,Itn_ProcessoN2=#altprocesson2#
                                ,Itn_ProcessoN3=#altprocesson3#
                                ,Itn_ProcessoN3Outros='#form.altprocesson3outros#'
                                ,Itn_GestorProcessoDir=#form.altgestordir#
                                ,Itn_GestorProcessoDepto=#form.altgestordepto#
                                ,Itn_ObjetivoEstrategico='#form.itnaltobjetivoestrategicoAlt#'
                                ,Itn_RiscoEstrategico='#form.itnaltriscoestrategicoAlt#'
                                ,Itn_IndicadorEstrategico='#form.itnaltindicadorestrategicoAlt#'
                                ,Itn_Coso2013Componente=#form.altcomponentecoso#
                                ,Itn_Coso2013Principios=#form.altprincipioscoso#
                            WHERE
                                Itn_Modalidade = '#form.selAltModalidade#' AND 
                                Itn_Ano = #form.selAltItemAno# AND 
                                Itn_TipoUnidade = #tipo# AND 
                                Itn_NumGrupo = #form.selAltItemGrupo# AND 
                                Itn_NumItem = #form.selAltItem#                             
                </cfquery>                
            </cfif> 
            <cfset RIPCaractvlr = 'NAO QUANTIFICADO'>
            <cfif listfind('#altpontuacaoseq#','10')>
                <cfset RIPCaractvlr = 'QUANTIFICADO'>
            </cfif>	   
            <cfquery datasource="#dsn_inspecao#">
                UPDATE Resultado_Inspecao SET 
                    RIP_Caractvlr = '#RIPCaractvlr#'
                WHERE 
                    RIP_Ano = #form.selAltItemAno# AND 
                    RIP_NumGrupo = #form.selAltItemGrupo# AND 
                    RIP_NumItem = #form.selAltItem#
            </cfquery>	            
        </cfloop>
        <script type="text/javascript"> 
            alert('Item Alterado com sucesso!');
            //var frm = document.getElementById('formAltItem');   
            window.open('cadastroGruposItens.cfm','_self');         
        </script>        
    </cftransaction>
</cfif>
<cfif isDefined("form.acaoalt") and "#form.acaoalt#" eq 'excItem'>
    <cftransaction>
        <cfquery datasource="#dsn_inspecao#" >
            DELETE FROM TipoUnidade_ItemVerificacao 
            WHERE 
                TUI_Ano = '#form.selAltItemAno#' and 
                TUI_GrupoItem = #form.selAltItemGrupo# and 
                TUI_ItemVerif =#form.selAltItem#  
        </cfquery> 

        <cfquery datasource="#dsn_inspecao#" >
            DELETE FROM Itens_Verificacao 
            WHERE 
                Itn_Ano = '#form.selAltItemAno#' and 
                Itn_NumGrupo = #form.selAltItemGrupo# AND 
                Itn_NumItem = #form.selAltItem#
        </cfquery> 
    </cftransaction>
    <script type="text/javascript">           
        alert('Item Excluído com sucesso!');
        window.open('cadastroGruposItens.cfm','_self');           
    </script>
</cfif>

<cfquery name="qTipoUnidades" datasource="#dsn_inspecao#">
    SELECT * FROM Tipo_Unidades
	ORDER BY TUN_Descricao
</cfquery>

<!DOCTYPE html>
<html lang="pt-BR">
    <head>
        <title>SNCI - CADASTRO DE GRUPOS E ITENS</title>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

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
    <body id="main_body_alt" style="background:#ccc;">
        <div align="left" style="background:#003366">   
            <form id="formAltItem" nome="formAltItem" enctype="multipart/form-data" method="post">
                <input type="hidden" value="" id="acaoalt" name="acaoalt">
                <input type="hidden" value="" id="itmemuso" name="itmemuso">
                <input type="hidden" value="" id="tiposalt" name="tiposalt">  
                <div align="left" style="margin-bottom:10px;padding:10px;border:1px solid #fff;">
                    <div align="left">
                        <span class="tituloDivAltGrupo">Alterar Item PLANO DE TESTE</span>
                    </div>                                                                     
                </div> 
                <!--- Inicio acordeon --->
                <div class="accordion" id="acordion-altgrpitm">
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="altum">
                            <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#altprimeiro" aria-expanded="true" aria-controls="altprimeiro" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                <strong>ANO / GRUPO / ITEM / MODALIDADE</strong>
                            </button>
                        </h2>
                        <div id="altprimeiro" class="accordion-collapse collapse show" aria-labelledby="altum" data-bs-parent="#acordion-altgrpitm">
                            <div class="accordion-body">
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">Ano</label>
                                    </div>
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">Grupo</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <select name="selAltItemAno" id="selAltItemAno" class="form-select" aria-label="Default select example">									                                                                                                                     
                                                <option value="" selected>---</option>   
                                                <cfloop query="rsAnoPontuacao">                                             
                                                    <option value="<cfoutput>#rsAnoPontuacao.PTC_Ano#</cfoutput>"><cfoutput>#rsAnoPontuacao.PTC_Ano#</cfoutput></option>
                                                </cfloop>
                                            </select>	
                                        </label>
                                    </div>
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">           
                                            <select name="selAltItemGrupo" id="selAltItemGrupo" class="form-select" aria-label="Default select example">	
                                                <option selected="selected" value="">---</option>									
                                            </select> 
                                        </label>
                                    </div>
                                </div>   
                                <div class="row"> 
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________</label>
                                    </div>
                                </div>   
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">Item</label>
                                    </div>   
                                </div>                                  
                                <div class="row">                            
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <select id="selAltItem" name="selAltItem" class="form-select" aria-label="Default select example">
                                                <option selected="selected" value="">---</option>
                                            </select>
                                        </label>
                                    </div>
                                </div>   
                                <div class="row"> 
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________

                                        </label>
                                    </div>
                                </div>  
                                <label for="selAltModalidade" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                    Modalidade
                                </label>
                                <select name="selAltModalidade" id="selAltModalidade" class="form-select" aria-label="Default select example">                                      
                                    <option selected="selected" value="">---</option>
                                </select>                                                                    
                            </div>
                        </div>
                    </div>
                    <!--- final altprimeiro --->
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="altdois">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#altsegundo" aria-expanded="false" aria-controls="altsegundo" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                <strong>DESCRIÇÃO DO ITEM</strong>
                            </button>
                        </h2>
                        <div id="altsegundo" class="accordion-collapse collapse" aria-labelledby="altdois" data-bs-parent="#acordion-altgrpitm">
                            <div class="accordion-body">
                                <textarea  name="altItemDescricao"  id="altItemDescricao" cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>		
                            </div>
                        </div>
                    </div>
                    <!--- final altsegundo --->      
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="alttres">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#altterceiro" aria-expanded="false" aria-controls="altterceiro" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                <strong>MANCHETE</strong>
                            </button>
                        </h2>
                        <div id="altterceiro" class="accordion-collapse collapse" aria-labelledby="alttres" data-bs-parent="#acordion-altgrpitm">
                            <div class="accordion-body">
                                <textarea  name="altItemManchete"  id="altItemManchete" cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>		            
                            </div>
                        </div>
                    </div>
                    <!--- final altterceiro --->    
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="alttresmeio">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#altterceiromeio" aria-expanded="false" aria-controls="altterceiromeio" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                <strong>VALOR / VISUALIZAÇÃO / VALIDAÇÃO</strong>
                            </button>
                        </h2>
                        <div id="altterceiromeio" class="accordion-collapse collapse" aria-labelledby="alttresmeio" data-bs-parent="#acordion-altgrpitm">
                            <div class="accordion-body">
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">VALOR DECLARADO</label>
                                    </div>
                                    <div class="col" title="Impede a visualização e tratamento do item em todas as páginas.">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">VISUALIZAÇÃO</label>
                                    </div>                                    
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">VALIDAÇÃO OBRIGATÓRIA</label>
                                    </div>
                                </div>     		 										
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                            <select name="selAltItemValorDec" id="selAltItemValorDec" class="form-select" aria-label="Default select example">
                                                <option value="" selected>---</option>
                                            </select>
                                        </label>
                                    </div>
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                            <select name="selAltVisualizacao" id="selAltVisualizacao" class="form-select" aria-label="Default select example">
                                                <option value="" selected>---</option>
                                            </select>	
                                        </label>
                                    </div>                                    
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                            <select name="selAltValidObrig" id="selAltValidObrig" class="form-select" aria-label="Default select example">
                                                <option value="" selected>---</option>
                                            </select>
                                        </label>
                                    </div>
                                </div>      
                            </div> <!--- ACCORDION-BODY--->
                        </div>
                    </div>
                    <!--- final altterceiromeio --->                       
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="altquatro">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#altquarto" aria-expanded="false" aria-controls="altquarto" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                            <strong>COMO EXECUTAR/PROCEDIMENTOS ADOTADOS</strong>
                            </button>
                        </h2>
                        <div id="altquarto" class="accordion-collapse collapse" aria-labelledby="altquatro" data-bs-parent="#acordion-altgrpitm">
                            <div class="accordion-body">
                                <textarea name="altItemOrientacao" id="altItemOrientacao" cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>
                            </div>
                        </div>
                    </div>
                    <!--- final altquarto ---> 
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="altcinco">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#altquinto" aria-expanded="false" aria-controls="altquinto" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                <strong>AMOSTRA</strong>
                            </button>
                        </h2>
                        <div id="altquinto" class="accordion-collapse collapse" aria-labelledby="altcinco"data-bs-parent="#acordion-altgrpitm">
                            <div class="accordion-body">
                                <textarea  name="altItemAmostra" id="altItemAmostra"  cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>		
                            </div>
                        </div>
                    </div>
                    <!---  final altquinto --->       
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="altseis">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#altsexto" aria-expanded="false" aria-controls="altsexto" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                <strong>NORMA</strong>
                            </button>
                        </h2>
                        <div id="altsexto" class="accordion-collapse collapse" aria-labelledby="altseis" data-bs-parent="#acordion-altgrpitm">
                            <div class="accordion-body">
                                <textarea  name="altItemNorma" id="altItemNorma" cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>
                            </div>
                        </div>
                    </div>
                    <!--- final altsexto --->    
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="altsete">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#altsetimo" aria-expanded="false" aria-controls="altsetimo" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                            <strong>RELATO MODELO / PRÉ-RELATO</strong>
                            </button>
                        </h2>
                        <div id="altsetimo" class="accordion-collapse collapse" aria-labelledby="altsete" data-bs-parent="#acordion-altgrpitm">
                            <div class="accordion-body">
                                <textarea  name="altItemPreRelato" id="altItemPreRelato" cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>
                            </div>
                        </div>
                    </div>
                    <!--- final altsetimo --->    
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="altoito">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#altoitavo" aria-expanded="false" aria-controls="altoitavo" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                <strong>ORIENTAÇÕES UNIDADE/ÓRGÃO</strong>
                            </button>
                        </h2>
                        <div id="altoitavo" class="accordion-collapse collapse" aria-labelledby="altoito" data-bs-parent="#acordion-altgrpitm">
                            <div class="accordion-body">
                                <textarea  name="altItemOrientacaoRelato" id="altItemOrientacaoRelato" cols="94" rows="2" wrap="VIRTUAL" class="form-control"></textarea>
                            </div>
                        </div>
                    </div>
                    <!--- final altoitavo --->  
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="altnove">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#altnono" aria-expanded="false" aria-controls="altnono" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                            <strong>CONTROLE / RISCOS / PROCESSOS / ESTRATÉGIA / COSO-2013</strong>
                            </button>
                        </h2>
                        <div id="altnono" class="accordion-collapse collapse" aria-labelledby="altnove" data-bs-parent="#acordion-altgrpitm">
                            <div class="accordion-body">
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">CLASSIFICAÇÃO DO CONTROLE</label>
                                    </div>
                                </div>   
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <select id="altclassifcontrole" name="altclassifcontrole" multiple="multiple" class="form-select" aria-label="Default select example">
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
                                                <textarea  name="altcontroletestado" id="altcontroletestado" cols="125" rows="2" wrap="VIRTUAL" class="form-control" placeholder="Pode existir mais de um controle testado por item"></textarea>
                                            </label>
                                        </label>
                                    </div>
                                </div> 
                                <p></p>  
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">CATEGORIA DO CONTROLE</label>
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <select id="altcategcontrole" name="altcategcontrole" multiple="multiple" class="form-select" aria-label="Default select example">
                                            </select>  
                                        </label>                                        
                                    </div>
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________</label>
                                            <p></p>
                                        </div>
                                    </div>                                        
                                </div>  
                                
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">RISCO IDENTIFICADO</label>                                     
                                    </div>
                                    <div class="row">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                            <select id="altcategoriarisco" name="altcategoriarisco" class="form-select" aria-label="Default select example">
                                            </select>
                                        </label>  
                                    </div>
                                    <div class="row">
                                        <div id="altriscoidentif-outros"><textarea name="altcategoriariscooutros" id="altcategoriariscooutros" cols="105" rows="2" wrap="VIRTUAL" class="form-control" placeholder="Outros - Informar Descrição aqui."></textarea></div>
                                    </div>  
                                    <div class="row"> 
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________</label>
                                        </div>
                                    </div>
                                </div>  
                                <div class="row">
                                    <p></p>
                                    <div class="row"> 
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;"><strong>TIPO AVALIAÇÃO</strong></label>
                                        </div>
                                    </div>    
                                    <div class="row"> 
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________</label>
                                        </div>
                                    </div>  
                                    <p></p>                               
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">MACROPROCESSO</label>
                                        </div>
                                    </div>  
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                                <select id="altmacroprocesso" name="altmacroprocesso" class="form-select" aria-label="Default select example">
                                                </select>
                                            </label>
                                        </div>
                                    </div>                                                                            
                                    <p></p>
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">PROCESSO N1</label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">          
                                                <select id="altprocesson1" name="altprocesson1" class="form-select" aria-label="Default select example">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" id="cd_altprocesson1" name="cd_altprocesson1" title="">&nbsp;<strong>Não se Aplica</strong>
                                                </select>
                                                <div class="row">
                                                    <div id="altprocesson1-naoseaplica">
                                                        <textarea name="altprocesson1naoseaplica" id="altprocesson1naoseaplica" cols="125" rows="2" wrap="VIRTUAL" class="form-control" placeholder="Não se aplica - Informar Descrição aqui."></textarea>
                                                    </div>
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
                                                <select id="altprocesson2" name="altprocesson2" class="form-select" aria-label="Default select example">
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
                                                <select id="altprocesson3" name="altprocesson3" class="form-select" aria-label="Default select example"><input type="checkbox" id="cd_altprocesson3" name="cd_altprocesson3" title="">&nbsp;<strong>Outros</strong>
                                                </select>
                                            </label>
                                            <div class="row">
                                                <div id="altprocesson3-outros">
                                                    <textarea name="altprocesson3outros" id="altprocesson3outros" cols="100" rows="2" wrap="VIRTUAL" class="form-control" placeholder="Outros - Informar Descrição aqui."></textarea>
                                                </div>
                                            </div>                                            
                                        </div>
                                        <div class="row"> 
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________</label>
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
                                                <select id="altgestordir" name="altgestordir" class="form-select" aria-label="Default select example">
                                                </select>
                                            </label>                                        
                                        </div>                                        
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                                <select id="altgestordepto" name="altgestordepto" class="form-select" aria-label="Default select example">
                                                </select>
                                            </label>                                        
                                        </div>
                                    </div>                                                                        
                                    <div class="row"> 
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________
                                            </label>
                                        </div>
                                    </div>
                                </div>                             
                                <p></p>                             
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">OBJETIVO ESTRATÉGICO</label>
                                        <div class="row">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                                <select id="altobjetivoestrategico" name="altobjetivoestrategico" multiple="multiple" class="form-select" aria-label="Default select example">
                                                </select>
                                            </label>  
                                        </div>                                      
                                    </div>
                                </div>                                 
                                <p></p>
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">RISCO ESTRATÉGICO</label>
                                        <div class="row">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                                <select id="altriscoestrategico" name="altriscoestrategico" multiple="multiple" class="form-select" aria-label="Default select example">
                                                </select>
                                            </label>  
                                        </div>                                                                                   
                                    </div>
                                </div> 
                                <p></p>
                                <div class="row">
                                    <div class="col">
                                        <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">INDICADOR ESTRATÉGICO</label>
                                        <div class="row">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">            
                                                <select id="altindicadorestrategico" name="altindicadorestrategico" multiple="multiple" class="form-select" aria-label="Default select example">
                                                </select>
                                            </label>   
                                        </div>                                                                                 
                                    </div>
                                    <div class="row"> 
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________</label>
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
                                            <select id="altcomponentecoso" name="altcomponentecoso" class="form-select" aria-label="Default select example">
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
                                            <select id="altprincipioscoso" name="altprincipioscoso" class="form-select" aria-label="Default select example">
                                            </select>
                                        </label>
                                    </div>
                                </div>   
                            </div>
                        </div>
                    </div>
                    <!--- final cadnono --->                                                                                                                                                                 
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="altdez">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#altdecimo" aria-expanded="false" aria-controls="altdecimo" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                <strong>PLANO DE TESTE</strong>
                            </button>
                        </h2>
                        <div id="altdecimo" class="accordion-collapse collapse" aria-labelledby="altdez" data-bs-parent="#acordion-altgrpitm">
                            <div class="accordion-body">
                                <div align="left" style="margin-top:10px;margin-bottom:10px;padding:10px;border:1px solid #009;">
                                    <label for="selAltItemTipoUnidade"  style="color:#009; font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                        <strong>TIPOS DE UNIDADE:</strong> <span style="color:#009">(Selecione os tipos de unidade que terão este item em seu PLANO DE TESTE)</span>
                                    </label>
                                    <div class="row"> 
                                        <div class="col">
                                            <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">___________________________________________________________________________________________________________________________</label>
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
                                                            <input title="" class="alttipounid btn btn-primary" id="<cfoutput>#qTipoUnidades.TUN_Codigo#</cfoutput>" name="<cfoutput>#trim(qTipoUnidades.TUN_Descricao)#</cfoutput>" type="button" value="<cfoutput>#strnome#</cfoutput>">
                                                        </div>
                                                        <p></p>
                                                    </div>	  
                                                </td>
                                                <cfset qtdcol = qtdcol + 1>
                                            </cfloop>
                                        </tr>
                                    </table>
                                    <div id="propriasalt">
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
                                        <div id="ptopropriasalt" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">      
                                            <cfoutput query="rsPta">
                                                <cfif rsPta.PTC_Franquia is 'N'>
                                                    <div class="row">
                                                        <label style="color:##009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">
                                                            <input type="checkbox" class="checkPontuacaoAlt checkponto" name="checkPontuacaoAlt" title="#rsPta.PTC_Seq#" value="#rsPta.PTC_Valor#">&nbsp;&nbsp;#rsPta.PTC_Descricao# = <strong>#rsPta.PTC_Valor# pontos</strong></input>
                                                        </label>
                                                    </div>
                                                </cfif>
                                            </cfoutput>      
                                        </div>
                                        <div id="totalDivAlt">
                                            <div class="row"> 
                                                <div class="col">
                                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">_____________________________________________________________________________________________________________________
                                                    </label>
                                                </div>                                    
                                                <div class="col">
                                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;"><strong>TOTAL:</strong></label>
                                                    <p></p>                                                
                                                    <input type="text" id="pontuacaoCalculadaAlt" name="pontuacaoCalculadaAlt" readonly  size="3" class="form-control" style="color:#009;font-size:26px;text-align:center;" value="0"></strong></input>
                                                </div>
                                            </div>  
                                        </div>                                         
                                    </div>
                                    <div id="franquiaalt">
                                        <div class="row"> 
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">_____________________________________________________________________________________________________________________
                                                </label>
                                            </div>
                                        </div>                                    
                                        <div class="row"> 
                                            <div class="col">
                                                <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;"><strong>AGF (ponto adicional)</strong></label>
                                            </div>
                                        </div>  
                                        <div id="ptoagfalt" style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">     
<!---                                            <input type="radio" class="checkPontuacaoAltAGF checkponto" name="checkPontuacaoAltAGF" title="0" value="0" checked>&nbsp;&nbsp;Pontuação Inicial</input> --->
                                            <cfoutput query="rsPta">
                                                <cfif rsPta.PTC_Franquia is 'S'>
                                                    <div class="row">
                                                        <label style="color:##009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;">
                                                            <input  type="radio" class="checkPontuacaoAltAGF checkponto" title="#rsPta.PTC_Seq#" name="checkPontuacaoAltAGF" value="#rsPta.PTC_Valor#">&nbsp;&nbsp;#rsPta.PTC_Descricao# = <strong>#rsPta.PTC_Valor# pontos</strong></input> 
                                                        </label>
                                                    </div>
                                                </cfif>
                                            </cfoutput>                                                       
                                        </div>
                                        <div id="totalDivAltAGF">
                                            <div class="row"> 
                                                <div class="col">
                                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">_____________________________________________________________________________________________________________________</label>
                                                </div>                                    
                                                <div class="col">
                                                    <label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;"><strong>TOTAL:</strong></label>                                              
                                                    <input type="text" id="pontuacaoCalculadaAltAGF" name="pontuacaoCalculadaAltAGF" readonly  class="form-control" size="3" style="color:#009;font-size:26px;text-align:center;" value="0"></strong></input>
                                                </div>
                                            </div> 
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!--- final altdecimo --->  
                </div>
    <!--- Final acordeon geral ---> 
                <div class="row"> 
                    <p></p>  
                    <div class="col" align="center">                                         
                        <a type="button" onClick="return valida_formAltItem()" class="btn btn-success">Alterar</a>     
                    </div>
                    <div class="col" align="center">    
                        <a type="button" onClick="return valida_formExcItem()" href="#" class="btn btn-warning">Excluir este Item</a>
                    </div>                    
                    <div class="col" align="center">    
                        <a type="button" onClick="javascript:if(confirm('Deseja cancelar as alterações realizadas?\n\nObs.: Esta ação não cancela as alterações já confirmadas.\n\nCaso afirmativo, clique em OK.')){window.open('cadastroGruposItens.cfm','_self')}" href="#" class="btn btn-danger">Cancelar</a>
                    </div>
                    <p></p>
                </div>    
                <input type="hidden" id="itnclassificacontrolealt" name="itnclassificacontrolealt" value="">    
                <input type="hidden" id="itncategoriacontroleAlt" name="itncategoriacontroleAlt" value="">   
                <input type="hidden" id="itnaltobjetivoestrategicoAlt" name="itnaltobjetivoestrategicoAlt" value="">  
                <input type="hidden" id="itnaltriscoestrategicoAlt" name="itnaltriscoestrategicoAlt" value="">  
                <input type="hidden" id="itnaltindicadorestrategicoAlt" name="itnaltindicadorestrategicoAlt" value=""> 
                <input type="hidden" id="processon1naoaplicarSNAlt" name="processon1naoaplicarSNAlt" value="N"> 
                <input type="hidden" id="processon3outrosSNAlt" name="processon3outrosSNAlt" value="N"> 
                <input type="hidden" id="riscoidentificadoSNAlt" name="riscoidentificadoSNAlt" value="N"> 
                <input type="hidden" id="checkPontuacaoAltseq" name="checkPontuacaoAltseq" value=""> 
                <input type="hidden" id="checkPontuacaoAltagfseq" name="checkPontuacaoAltagfseq" value=""> 
                <input type="hidden" id="altmacroprocesso_sel" name="altmacroprocesso_sel" value=""> 
                <input type="hidden" id="altprocesson1_sel" name="altprocesson1_sel" value=""> 
                <input type="hidden" id="altprocesson2_sel" name="altprocesson2_sel" value=""> 
                <input type="hidden" id="altprocesson3_sel" name="altprocesson3_sel" value=""> 
            </form>
        </div>

        <script src="public/bootstrap/bootstrap.bundle.min.js"></script>
        <script src="public/jquery-3.7.1.min.js"></script>
        <script type="text/javascript" src="public/axios.min.js"></script>
        <script type="text/javascript"> 
            //alert('Dom inicializado!');     

            //var local = "parametros.cfm";
            function editar_altItemOrientacao(){
                CKEDITOR.replace('altItemOrientacao', {
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
            }

            function altItem_PreRelato(){    
                CKEDITOR.replace('altItemPreRelato', {
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
            }   

            function altItem_altItemOrientacaoRelato(){      
                CKEDITOR.replace('altItemOrientacaoRelato', {
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
            }

            function altItem_altItemAmostra(){       
                CKEDITOR.replace('altItemAmostra', {
                width: '100%',
                height: 50,
                toolbar: [	
                    [ 'Preview', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo','-', 'Bold', 'Italic', '-', 'SelectAll','-','NumberedList', 'BulvaredList','SpecialChar','-'],
                    '/',
                    ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-','TextColor','Maximize','Table']
                ]				
                });
            }

            function altItem_altItemNorma(){ 
                CKEDITOR.replace('altItemNorma', {
                width: '100%',
                height: 50,
                toolbar: [	
                    [ 'Preview', 'Paste', 'PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo','-', 'Bold', 'Italic', '-', 'SelectAll','-','NumberedList', 'BulvaredList','SpecialChar','-'],
                    '/',
                    ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-','TextColor','Maximize', 'Table' ]
                ]	
                });
            }
            // BUSCAR OS GRUPOS PELO ANO SELECIONADO  
            $('#selAltItemAno').change(function(e){
                var anogrupo = $(this).val(); 
                //alert(anogrupo);
                //buscar Grupos
                axios.get("CFC/grupoitem.cfc",{
                    params: {
                    method: "gruposverificacao",
                    anogrupo: anogrupo
                }
                })
                .then(data =>{
                    let prots = '<option value="">---</option>';
                    $('#selAltItemGrupo').html(prots);
                    $('#selAltItem').html(prots);
                    $('#selAltModalidade').html(prots);
                    //console.log(data.data)
                    //console.log(data.data.indexOf("COLUMNS"));
                    var vlr_ini = data.data.indexOf("COLUMNS");
                    var vlr_fin = data.data.length
                    vlr_ini = (vlr_ini - 2);
                    // console.log('valor inicial: ' + vlr_fin);
                    const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                    //console.log(json);
                    const dados = json.DATA;
                    //Grp_Codigo,trim(Grp_Descricao)
                    dados.map((ret) => {
                        prots += '<option value="'+ret[0]+'">'+ret[0]+'-'+ret[1]+'</option>';
                    });
                    $('#selAltItemGrupo').html(prots);
                })
            }) // FIM BUSCAR OS GRUPOS PELO ANO SELECIONADO       
            // BUSCAR OS ITENS DO GRUPO SELECIONADO
            $('#selAltItemGrupo').change(function(e){
                let ano = $('#selAltItemAno').val();
                let grupo = $(this).val(); 
                //buscar Grupos
                axios.get("CFC/grupoitem.cfc",{
                    params: {
                    method: "itensverificacao",
                    ano: ano,
                    grupo: grupo
                }
                })
                .then(data =>{
                    let prots = '<option value="">---</option>';
                    $('#selAltItem').html(prots);
                    $('#selAltModalidade').html(prots);
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
                    //prots += '<option value="'+ret[0]+'">'+ret[1]+'</option>';
                    prots += '<option value="'+ret[0]+'">'+ret[0]+'-'+ret[1]+'</option>';
                    });
                    $('#selAltItem').html(prots);
                })
            })  // FIM BUSCAR OS ITENS DO GRUPO SELECIONADO
            // BUSCAR AS MODALIDADES DO ITEM SELECIONADO
            $('#selAltItem').change(function(e){
                let ano = $('#selAltItemAno').val();
                let grupo = $('#selAltItemGrupo').val();
                let itm = $(this).val();
                // alert(tpunid)
                // alert(grupo);
                //buscar Grupos
                axios.get("CFC/grupoitem.cfc",{
                    params: {
                    method: "modalidade",
                    ano: ano,
                    grupo: grupo,
                    itm: itm
                }
                })
                .then(data =>{
                    let prots = '<option value="">---</option>';
                    $('#selAltModalidade').html(prots);
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
                    prots += '<option value="' + ret[0] + '">'+ret[1]+'</option>';
                    });
                    $('#selAltModalidade').html(prots);
                })
            })  // FIM BUSCAR AS MODALIDADES DO ITEM SELECIONADO   
            // BUSCAR dados para alteração com o evento selAltModalidade.change() 
            $('#selAltModalidade').change(function(e){
                let ano = $('#selAltItemAno').val();
                let grupo = $('#selAltItemGrupo').val();
                let itm = $('#selAltItem').val();
                let modal = $(this).val();
                if (modal == '') {return false}
                let resultado = 0
                //Verificar item se está em uso na tabela ResultadoInspecao
                axios.get("CFC/grupoitem.cfc",{
                    params: {
                    method: "verificarUsoItem",
                    ano: ano,
                    grupo: grupo,
                    itm: itm,
                    modal: modal
                    }
                })
                .then(data =>{
                    var vlr_ini = data.data.indexOf("COLUMNS");
                    var vlr_fin = data.data.length
                    vlr_ini = (vlr_ini - 2);
                    // console.log('valor inicial: ' + vlr_fin);
                    const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                    //console.log(json);
                    const dados = json.DATA;
                    dados.map((ret) => {
                        if(ret[0] !== '') {resultado = 1}

                    });
                    //alert(resultado)
                    $('#itmemuso').val(resultado)
                })//Verificar item se está em uso na tabela ResultadoInspecao
                //Buscar os dados do item a serem alterados
                axios.get("CFC/grupoitem.cfc",{
                    params: {
                    method: "alteraritens",
                    ano: ano,
                    grupo: grupo,
                    itm: itm,
                    modal: modal
                }
                })
                .then(data =>{
                    let prots = '<option value="">---</option>';
                    let vlrdeclarado = '';
                    let visualizar = '';
                    let validarobrig = '';
                    $('#selAltItemValorDec').html(prots);
                    $('#selAltVisualizacao').html(prots);
                    $('#selAltValidObrig').html(prots);
                    $("#propriasalt").hide(500);
                    $("#franquiaalt").hide(500);
                    
                    let classcontrole = '';
                    let catctrl = '';
                    let catriscoident = '';
                    let catriscoidentoutros = '';
                    let macropro = ''
                    let procn1 = ''
                    let procn2 = ''
                    let procn3 = ''
                    let dirproc = ''
                    let deptoproc = ''
                    let objestrat = ''
                    let indicestrat = ''
                    let compcoso2013 = ''
                    let princoso2013 = ''
                    let itnptcseq=''
                    let itntpunid='0'
                    
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
                        $('#altItemDescricao').val(ret[1]) // descrição do item
                        $('#altItemManchete').val(ret[2])  // manchete do item
                        visualizar = ret[0] 
                        vlrdeclarado = ret[3] 
                        validarobrig = ret[4]                  
                        $('#altItemOrientacao').val(ret[5])  // Como executar/Procedimentos Adotados
                        $('#altItemAmostra').val(ret[6])  // Amostras
                        $('#altItemNorma').val(ret[7])  // Normas
                        $('#altItemPreRelato').val(ret[8])  // Relato Modelo - (Itn_PreRelato)
                        $('#altItemOrientacaoRelato').val(ret[9])  // Orientações Unidade/órgão - (Itn_OrientacaoRelato)
                        classcontrole = ret[10]
                        $('#altcontroletestado').val(ret[11])  // Orientações Unidade/órgão - (Itn_OrientacaoRelato)
                        catctrl = ret[12]
                        catriscoident = ret[13]
                        $('#altcategoriariscooutros').val(ret[14])
                        macropro = ret[15]
                        $('#altmacroprocesso_sel').val(ret[15]) 
                        procn1 = ret[16] 
                        $('#altprocesson1_sel').val(ret[16])               
                        $('#altprocesson1naoseaplica').val(ret[17])        
                        procn2 = ret[18]
                        $('#altprocesson2_sel').val(ret[18])
                        procn3 = ret[19]
                        $('#altprocesson3_sel').val(ret[19])
                        $('#altprocesson3outros').val(ret[20]) 
                        dirproc = ret[21]                 
                        deptoproc = ret[22]
                        objestrat = ret[23]
                        riscoestrat = ret[24]
                        indicestrat = ret[25]
                        compcoso2013 = ret[26]
                        princoso2013 = ret[27]
                        if(itnptcseq.length < ret[28].length) {itnptcseq = ret[28]}
                        itntpunid += ','+ret[0]
                    });
                    if(visualizar == '99') {
                        visualizar = '<option value="">---</option>'
                        visualizar += '<option value="S" selected>Sim</option>'
                        visualizar += '<option value="N">Não</option>'
                    }else{
                        visualizar = '<option value="">---</option>'
                        visualizar += '<option value="S">Sim</option>'
                        visualizar += '<option value="N" selected>Não</option>'
                    }  // visualização                     
                    if(vlrdeclarado == 'S') {
                        vlrdeclarado = '<option value="">---</option>'
                        vlrdeclarado += '<option value="S" selected>Sim</option>'
                        vlrdeclarado += '<option value="N">Não</option>'
                    }else{
                        vlrdeclarado = '<option value="">---</option>'
                        vlrdeclarado += '<option value="S">Sim</option>'
                        vlrdeclarado += '<option value="N" selected>Não</option>'
                    } // valor declarado
                    if(validarobrig == '1') {
                        validarobrig = '<option value="">---</option>'
                        validarobrig += '<option value="S" selected>Sim</option>'
                        validarobrig += '<option value="N">Não</option>'
                    }else{
                        validarobrig = '<option value="">---</option>'
                        validarobrig += '<option value="S">Sim</option>'
                        validarobrig += '<option value="N" selected>Não</option>'
                    }  // validação obrigatória                     
                    $('#selAltItemValorDec').html(vlrdeclarado);
                    $('#selAltVisualizacao').html(visualizar);
                    $('#selAltValidObrig').html(validarobrig);
                    $("#altriscoidentif-outros").hide(500);
                    if ($('#altcategoriariscooutros').val() != '') {$('#altriscoidentif-outros').show(500)}
                    
                    //$('#processon3outrosSNAlt').val('N')
                   // if($('#altprocesson3outros').val() !== '') {$('#processon3outrosSNAlt').val('S')}  
                    editar_altItemOrientacao();
                    altItem_altItemAmostra();
                    altItem_altItemNorma();
                    altItem_PreRelato();
                    altItem_altItemOrientacaoRelato();
                    classificacaocontrole("'"+classcontrole+"'");
                    categoriacontrole("'"+catctrl+"'")
                    categoriarisco("'"+catriscoident+"'")
                    macroprocesso("'"+macropro+"'")
                    $("#altprocesson1-naoseaplica").hide(500);
                    if ($('#altprocesson1naoseaplica').val() != '') {
                            $('#altprocesson1-naoseaplica').show(500)
                            $("#cd_altprocesson1").prop("checked", true);
                            $("#altprocesson1").html(prots);
                            $("#altprocesson1").attr('disabled', true);
                            $("#altprocesson2").attr('disabled', true);
                            $("#altprocesson3").attr('disabled', true);
                            $("#cd_altprocesson3").attr('disabled', true);
                            $("#altprocesson3-outros").hide(500);
                            $('#processon3outrosSNAlt').val('N')
                            $('#processon1naoaplicarSNAlt').val('S')
                        }else{
                            $('#processon1naoaplicarSNAlt').val('N')
                            ProcessoN1(macropro,"'"+procn1+"'")
                            $("#cd_altprocesson1").prop("checked", false);
                            ProcessoN2(macropro,procn1,"'"+procn2+"'")
                            if ($('#altprocesson3outros').val() != '') {
                                $("#altprocesson3").html(prots);
                                $("#altprocesson3").attr('disabled', true);
                                $('#altprocesson3-outros').show(500)
                                $("#cd_altprocesson3").prop("checked", true); 
                                $('#processon3outrosSNAlt').val('S')
                            }else{
                                $('#processon3outrosSNAlt').val('N')
                                $('#altprocesson3-outros').hide(500)
                                ProcessoN3(macropro,procn1,procn2,"'"+procn3+"'")  
                                $("#cd_altprocesson3").prop("checked", false); 
                            }                    
                    }  
                    dirprocesso("'"+dirproc+"'") 
                    deptoprocesso(dirproc,"'"+deptoproc+"'")
                    objetivoestrategico("'"+objestrat+"'")
                    riscoestrategico("'"+riscoestrat+"'")
                    indicadorestrategico("'"+indicestrat+"'")
                    componentecoso("'"+compcoso2013+"'")
                    principioscoso(compcoso2013,"'"+princoso2013+"'")
                    exibirplanoteste(itntpunid,itnptcseq)
                    
                })
                }) // FIM BUSCAR dados para alteração dos tipos de Unidades    
                //Classificação do controle     
                function  classificacaocontrole(a){
                    axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "classifctrl"
                        }
                    })
                    .then(data =>{
                        let prots = '<option value="">---</option>';
                        let selecionar = ''
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
                            selecionar = ''
                            if (a.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                            prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                        $("#altclassifcontrole").html(prots);
                    })
                } // Fim Classificação do controle  
                //Categoria do Controle     
                function  categoriacontrole(a){           
                    //busca da categoria   
                    axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "categcontrole"
                        }
                    })
                    .then(data =>{
                        let prots = '<option value="">---</option>';
                        let selecionar = ''
                        var vlr_ini = data.data.indexOf("COLUMNS");
                        var vlr_fin = data.data.length
                        vlr_ini = (vlr_ini - 2);
                        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                        const dados = json.DATA;
                        dados.map((ret) => {
                            selecionar = ''
                            if (a.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                            prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                        $("#altcategcontrole").html(prots);
                    }) 
                } 
                //Risco Identificado
                function categoriarisco(a){       
                    //buscar categoria risco     
                    axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "categoriarisco"
                        }
                    })
                    .then(data =>{
                        let prots = '<option value="">---</option>';
                        let selecionar = ''
                        var vlr_ini = data.data.indexOf("COLUMNS");
                        var vlr_fin = data.data.length
                        vlr_ini = (vlr_ini - 2);
                        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                        const dados = json.DATA;
                        dados.map((ret) => {
                            selecionar = ''
                            if (a.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                            prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                        $("#altcategoriarisco").html(prots);
                    })   
                }             
                // buscar macroprocesso             
                function macroprocesso(a) { 
                    axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "macroprocesso"
                        }
                    })
                    .then(data =>{
                        let prots = '<option value="">---</option>';
                        let selecionar = ''
                        var vlr_ini = data.data.indexOf("COLUMNS");
                        var vlr_fin = data.data.length
                        vlr_ini = (vlr_ini - 2);
                        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                        const dados = json.DATA;
                        dados.map((ret) => {
                            selecionar = ''
                            if (a.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                            prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                        $("#altmacroprocesso").html(prots);
                    })             
                }  
                //buscar ProcessoN1
                function ProcessoN1(a,b) {      
                    //var PCN1MAPCID = $('#altmacroprocesso').val();          
                    axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "macroprocesson1",
                        PCN1MAPCID: a
                        }
                    })
                    .then(data =>{
                        let prots = '<option value="">---</option>';
                        let selecionar = ''
                        var vlr_ini = data.data.indexOf("COLUMNS");
                        var vlr_fin = data.data.length
                        vlr_ini = (vlr_ini - 2);
                        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                        const dados = json.DATA;
                        dados.map((ret) => {
                            selecionar = ''
                            if (b.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                            prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                        $("#altprocesson1").html(prots);
                    })  
                }     
                //buscar ProcessoN2
                function ProcessoN2(a,b,c) { 
                    //var PCN1MAPCID = $("#macroprocesso").val();
                    //var PCN1ID = $(this).val();
                    axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "macroprocesson2",
                        PCN1MAPCID: a,
                        PCN1ID: b
                        }
                    })
                    .then(data =>{
                        let prots = '<option value="">---</option>';
                        let selecionar = ''
                        var vlr_ini = data.data.indexOf("COLUMNS");
                        var vlr_fin = data.data.length
                        vlr_ini = (vlr_ini - 2);
                        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                        const dados = json.DATA;
                        dados.map((ret) => {
                            selecionar = ''
                            if (c.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                            prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                        $("#altprocesson2").html(prots);
                    }) 
                } //final buscar altProcessoN2  
                //inicio buscar altprocessoN3
                function ProcessoN3(a,b,c,d) { 
                    axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "macroprocesson3",
                        PCN3PCN2PCN1MAPCID: a,
                        PCN3PCN2PCN1ID: b,
                        PCN3PCN2ID: c
                        }
                    })
                    .then(data =>{
                        let prots = '<option value="">---</option>';
                        let selecionar = ''
                        var vlr_ini = data.data.indexOf("COLUMNS");
                        var vlr_fin = data.data.length
                        vlr_ini = (vlr_ini - 2);
                        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                        const dados = json.DATA;
                        dados.map((ret) => {
                            selecionar = ''
                            if (d.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                            prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                        $("#altprocesson3").html(prots);
                    })
                } //final buscar altprocessoN3   
                // buscar diretoria do processo
                function dirprocesso(a){
                    axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "gestordiretoria"
                        }
                    })
                    .then(data =>{
                        let prots = '<option value="">---</option>';
                        let selecionar = ''
                        var vlr_ini = data.data.indexOf("COLUMNS");
                        var vlr_fin = data.data.length
                        vlr_ini = (vlr_ini - 2);
                        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                        const dados = json.DATA;
                        dados.map((ret) => {
                            selecionar = ''
                            if (a.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                            prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                        $("#altgestordir").html(prots);
                    })  
                } // buscar diretoria do processo                  
                // buscar depto do processo
                function deptoprocesso(a,b){
                    axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "gestorprocesso",
                        digpid: a
                        }
                    })
                    .then(data =>{
                        let prots = '<option value="">---</option>';
                        let selecionar = ''
                        var vlr_ini = data.data.indexOf("COLUMNS");
                        var vlr_fin = data.data.length
                        vlr_ini = (vlr_ini - 2);
                        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                        const dados = json.DATA;
                        dados.map((ret) => {
                            selecionar = ''
                            if (b.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                            prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                        $("#altgestordepto").html(prots);
                    })  
                } // buscar depto do processo   
                //busca do objetivo estrategico  
                function objetivoestrategico(a) {    
                    axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "objetivoestrategico"
                        }
                    })
                    .then(data =>{
                        let prots = '<option value="">---</option>';
                        let selecionar = ''
                        var vlr_ini = data.data.indexOf("COLUMNS");
                        var vlr_fin = data.data.length
                        vlr_ini = (vlr_ini - 2);
                        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                        const dados = json.DATA;
                        dados.map((ret) => {
                            selecionar = ''
                            if (a.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                            prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                        $("#altobjetivoestrategico").html(prots);
                    })          
                }//busca do objetivo estrategico 
                //busca do risco estrategico          
                function riscoestrategico(a){ 
                    axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "riscoestrategico"
                        }
                    })
                    .then(data =>{
                        let prots = '<option value="">---</option>';
                        let selecionar = ''
                        var vlr_ini = data.data.indexOf("COLUMNS");
                        var vlr_fin = data.data.length
                        vlr_ini = (vlr_ini - 2);
                        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                        const dados = json.DATA;
                        dados.map((ret) => {
                            selecionar = ''
                            if (a.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                            prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                        $("#altriscoestrategico").html(prots);
                    })  
                }//busca do risco estrategico   
                //busca da indicador estrategico 
                function indicadorestrategico(a){
                    //busca da indicador estrategico      
                    axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "indicadorestrategico"
                        }
                    })
                    .then(data =>{
                        let prots = '<option value="">---</option>';
                        let selecionar = ''
                        var vlr_ini = data.data.indexOf("COLUMNS");
                        var vlr_fin = data.data.length
                        vlr_ini = (vlr_ini - 2);
                        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                        const dados = json.DATA;
                        dados.map((ret) => {
                            selecionar = ''
                            if (a.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                            prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                        $("#altindicadorestrategico").html(prots);
                    })    
                }//busca da indicador estrategico   
                //componentecoso2013        
                function componentecoso(a) { 
                    axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "componentecoso"
                        }
                    })
                    .then(data =>{
                        let prots = '<option value="">---</option>';
                        let selecionar = ''
                        var vlr_ini = data.data.indexOf("COLUMNS");
                        var vlr_fin = data.data.length
                        vlr_ini = (vlr_ini - 2);
                        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                        const dados = json.DATA;
                        dados.map((ret) => {
                            selecionar = ''
                            if (a.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                            prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                        $("#altcomponentecoso").html(prots);
                    })                                                      
                }//componentecoso2013  
                //buscar o principios do coso2013
                function principioscoso(a,b){
                        axios.get("CFC/grupoitem.cfc",{
                        params: {
                        method: "principioscoso",
                        PRCSCPCSID: a
                        }
                        })
                        .then(data =>{
                            let prots = '<option value="">---</option>';
                            var vlr_ini = data.data.indexOf("COLUMNS");
                            var vlr_fin = data.data.length
                            vlr_ini = (vlr_ini - 2);
                            const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                            const dados = json.DATA;
                            dados.map((ret) => {
                                selecionar = ''
                                if (b.indexOf(ret[0]) !== -1) {selecionar = 'selected'}
                                prots += '<option value="' + ret[0] + '"'+selecionar+'>' + ret[1] + '</option>';
                        });
                            $("#altprincipioscoso").html(prots);
                        }) 
                } //buscar o principios do coso2013                                                                                    
                //************************************************
                $('#altcategoriarisco').click(function() {
                    $("#altriscoidentif-outros").hide(500);
                    var auxselect = '';
                    $('#altcategoriarisco  > option:selected').each(function() {
                        auxselect += $(this).text();
                    })
                    if(auxselect == 'Outros'){
                        $("#altriscoidentif-outros").show(500);
                        $("#riscoidentificadoSNAlt").val('S');
                    }else{
                        $("#riscoidentificadoSNAlt").val('N');
                    }
                }); 
                //buscar altprocessoN1 
                $('#altmacroprocesso').change(function(e){
                    let prots = '<option value="" selected>---</option>';
                    $("#altprocesson1").html(prots);
                    $("#altprocesson2").html(prots);
                    $("#altprocesson3").html(prots);
                    let PCN1MAPCID = $(this).val(); 
                    if(PCN1MAPCID == ''){
                        $("#altprocesson1").attr('disabled', true);
                        $('#altprocesson1-naoseaplica').hide(500)
                        $("#cd_altprocesson1").prop("checked", false); 
                        $("#cd_altprocesson1").attr('disabled', true);  

                        $("#altprocesson2").attr('disabled', true);

                        $("#altprocesson3").attr('disabled', true);
                        $('#altprocesson3outros').hide(500)
                        $("#cd_altprocesson3").prop("checked", false); 
                        $("#cd_altprocesson3").attr('disabled', true);                  
                    }else{                        
                        $("#altprocesson1").attr('disabled', false);
                        $('#altprocesson1-naoseaplica').hide(500)
                        $("#cd_altprocesson1").prop("checked", false); 
                        $("#cd_altprocesson1").attr('disabled', false);          
                        axios.get("CFC/grupoitem.cfc",{
                            params: {
                                method: "macroprocesson1",
                                PCN1MAPCID: PCN1MAPCID
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
                            $("#altprocesson1").html(prots);
                        })  
                    }
                }) //buscar altprocessoN1
                //buscar altprocessoN2
                $('#altprocesson1').change(function(e){
                    let prots = '<option value="" selected>---</option>';
                    $("#altprocesson2").html(prots);
                    $("#altprocesson3").html(prots);
                    let PCN1MAPCID = $("#altmacroprocesso").val();
                    let PCN1ID = $(this).val();
                    if(PCN1ID == ''){
                        $("#altprocesson2").attr('disabled', true);

                        $("#altprocesson3").attr('disabled', true);
                        $('#altprocesson3outros').hide(500)
                        $("#cd_altprocesson3").prop("checked", false); 
                        $("#cd_altprocesson3").attr('disabled', true);                  
                    }else{ 
                        $("#altprocesson2").attr('disabled', false);
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
                            $("#altprocesson2").html(prots);
                        })  
                    }
                })//final buscar altprocessoN2 
                //inicio buscar altprocessoN3
                $('#altprocesson2').change(function(e){
                    let prots = '<option value="" selected>---</option>';
                    $("#altprocesson3").html(prots);
                    var PCN3PCN2PCN1MAPCID = $("#altmacroprocesso").val();
                    var PCN3PCN2PCN1ID = $("#altprocesson1").val();
                    var PCN3PCN2ID = $(this).val();
                    if(PCN3PCN2ID == ''){
                        $("#altprocesson3").attr('disabled', true);
                        $('#altprocesson3outros').hide(500)
                        $("#cd_altprocesson3").prop("checked", false); 
                        $("#cd_altprocesson3").attr('disabled', true);                  
                    }else{ 
                        $("#altprocesson3").attr('disabled', false);
                        $("#cd_altprocesson3").attr('disabled', false); 
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
                            $("#altprocesson3").html(prots);
                        }) 
                    }
                })//final buscar altprocessoN3  
                // inicio cd_altprocesson3
                //==============================
                $('#cd_altprocesson3').click(function(){
                    let prots = '<option value="" selected>---</option>';
                   // $("#altprocesson3-outros").hide(500);
                    $("#altprocesson3").html(prots);
                    if($(this).is(':checked')) {
                        $("#altprocesson3").attr('disabled', true);
                        $("#altprocesson3-outros").show(500);
                        $("#processon3outrosSNAlt").val('S');
                    }else{
                        $("#processon3outrosSNAlt").val('N');
                        $("#altprocesson3").attr('disabled', false);
                        //realizar nova busca e preecher o altprocesson1
                        var PCN3PCN2PCN1MAPCID = $("#altmacroprocesso").val();
                        var PCN3PCN2PCN1ID = $("#altprocesson1").val();
                        var PCN3PCN2ID = $("#altprocesson2").val();
                        axios.get("CFC/grupoitem.cfc",{
                            params: {
                                method: "macroprocesson3",
                                PCN3PCN2PCN1MAPCID: PCN3PCN2PCN1MAPCID,
                                PCN3PCN2PCN1ID: PCN3PCN2PCN1ID,
                                PCN3PCN2ID: PCN3PCN2ID
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
                            $("#altprocesson3").html(prots);
                        }) 
                    }            
                })// fim cd_altprocesson3  
                //buscar o principios do coso passando filtro do componentecoso
                $('#altcomponentecoso').change(function(e){
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
                        $("#altprincipioscoso").html(prots);
                    }) 
                }) //buscar o principios do coso passando filtro do componentecoso                                 
                // Ocultar ou Recompor o select processon1/processon2/processon3
                $('#cd_altprocesson1').click(function(){
                    let prots = '<option value="" selected>---</option>';
                    $("#processon1naoaplicarSNAlt").val('N');
                    $('#altprocesson3-outros').hide(500)
                    if($(this).is(':checked')) {
                        $("#altprocesson1_sel").val($("#altprocesson1").val());
                        $("#altprocesson2_sel").val($("#altprocesson2").val());
                        $("#altprocesson3_sel").val($("#altprocesson3").val());
                        $('#altprocesson1-naoseaplica').show(500)
                        $("#processon1naoaplicarSNAlt").val('S');
                        $("#altprocesson1").html(prots);
                        $("#altprocesson1").attr('disabled', true);
                        $("#altprocesson2").html(prots);
                        $("#altprocesson2").attr('disabled', true);
                        $("#altprocesson3").html(prots);
                        $("#altprocesson3").attr('disabled', true);
                        $("#cd_altprocesson3").attr('disabled', true);
                    }else{
                        $('#altprocesson1-naoseaplica').hide(500)
                        $("#altprocesson1").attr('disabled', false);
                        $("#altprocesson2").attr('disabled', false);
                        $("#altprocesson3").attr('disabled', false); 
                        let macropro = $("#altmacroprocesso").val();
                        let procn1 = $("#altprocesson1_sel").val();
                        ProcessoN1(macropro,"'"+procn1+"'")   
                        let procn2 = $("#altprocesson2_sel").val();
                        ProcessoN2(macropro,procn1,"'"+procn2+"'")   
                        if ($('#altprocesson3outros').val() != '') {
                            $("#altprocesson3").html(prots);
                            $("#altprocesson3").attr('disabled', true);
                            $('#altprocesson3-outros').show(500)
                            $("#cd_altprocesson3").prop("checked", true); 
                            $("#cd_altprocesson3").attr('disabled', true);
                        }else{
                            $('#altprocesson3-outros').hide(500)
                            let procn3 = $("#altprocesson3_sel").val();
                            ProcessoN3(macropro,procn1,procn2,"'"+procn3+"'")  
                            $("#cd_altprocesson3").prop("checked", false); 
                            $("#cd_altprocesson3").attr('disabled', false);
                        }                      
                    }
                })//Ocultar ou Recompor o select processon1/processon2/processon3
                //Ocultar ou Recompor o select processon3
                $('#cd_altprocesson3').click(function(){
                    let prots = '<option value="" selected>---</option>';
                    //$('#altprocesson3-outros').hide(500)
                    if($(this).is(':checked')) {
                        $("#altprocesson3_sel").val($("#altprocesson3").val());
                        $("#altprocesson3").html(prots);
                        $("#altprocesson3").attr('disabled', true)
                        $('#altprocesson3-outros').show(500)
                    }else{
                        $("#altprocesson3").attr('disabled', false)
                        let macropro = $("#altmacroprocesso").val();
                        let procn1 = $("#altprocesson1").val();
                        let procn2 = $("#altprocesson2").val();
                        let procn3 = $("#altprocesson3_sel").val();
                        $('#altprocesson3-outros').hide(500)
                        ProcessoN3(macropro,procn1,procn2,"'"+procn3+"'") 
                        //alert(macropro+' '+procn1+' '+procn2+' '+procn3)
                    }             
                }) //Ocultar ou Recompor o select processon3                  
                //**************************************************        
                //Ajustar os tipos e os check/radio e a pontuação         
                function exibirplanoteste(a,b){                   
                    //alert(a + '  '+b)
                    let altArray = a.split(',')
                    let alttpunid = ''
                    var selecionarsn = ''
                    $('.alttipounid').each(function( index ) {
                        alttpunid = $(this).attr("id");
                        selecionarsn = 'N'
                        $(this).attr("title","0");
                        // alterar a class do botão
                        $(this).attr("class","alttipounid btn btn-primary");
                        $(this).css('box-shadow', '10px 10px 5px 0');                          
                        //alert(alttpunid)
                        $.each(altArray, function( key, value ) {
                            //alert('value: '+value)
                            if (value == alttpunid) {
                                selecionarsn = 'S'
                                if (alttpunid==12) {$("#franquiaalt").show(500)}
                                //alert('value: '+value)
                            }
                        })
                        if (selecionarsn == 'S') {
                                selecionarsn = 'S'
                                $(this).attr("title","1");
                                //alterar a class do botão
                                $(this).attr("class","alttipounid btn btn-success");
                                $(this).css('box-shadow', '10px 10px 5px #888')
                        }
                    }) 
                    
                    let ponto =''
                    let altseqarray=b.split(',')
                   // alert(altseqarray)
                    $('.checkponto').each(function( index ) {
                        selecionarsn = 'N'
                        ponto = $(this).attr("title");
                        //alert(ponto)
                        $.each(altseqarray, function( key, value ) {
                            //alert('value: '+value)
                            if (value == ponto) {
                                selecionarsn = 'S'
                                //alert('value: '+value)
                            }
                        })
                        
                        if (selecionarsn == 'S') {
                            $(this).prop('checked',true);
                            //alert(ponto)
                        }else{
                            $(this).prop('checked',false);
                            //alert(ponto)
                        }
                    }) 
                    
                    var totala = 0
                    $( ".checkPontuacaoAlt" ).each(function( index ) {
                        if($(this).is(':checked')){
                            totala = totala + eval($(this).val())
                        }
                    });               
                    if(totala !== 0){$("#propriasalt").show(500)}
                    $('#pontuacaoCalculadaAlt').val(totala); 

                    var totalb = 0
                    $( ".checkPontuacaoAltAGF" ).each(function( index ) {
                       // alert( index + ": " + $(this).val());
                        if($(this).is(':checked')){
                           // alert( index + ": " + $(this).val());
                            totalb = totalb + eval($(this).val())
                        }
                    });
                   // $("#franquiaalt").show();
                    if(totalb !== 0){$("#franquiaalt").show(500)}
                    var total = eval(totala) + eval(totalb) 
                    $('#pontuacaoCalculadaAltAGF').val(total);                
                }//Ajustar os tipos e os check/radio e a pontuação    
                //Tipo de Unidade Própria foi clicado
                $('.checkPontuacaoAlt').click(function(){
                    var total = 0
                    $( ".checkPontuacaoAlt" ).each(function( index ) {
                        if($(this).is(':checked')){
                            total = total + eval($(this).val())
                        }
                    });
                    $('#pontuacaoCalculadaAlt').val(total); 
                    altsomaragf()
                })//Tipo de Unidade Própria foi clicado 
                //Tipo de Unidade AGF foi clicado
                $('.checkPontuacaoAltAGF').click(function(){
                    var total = eval($(this).val())
                    $('#pontuacaoCalculadaAltAGF').val(total); 
                    altsomaragf()
                })//Tipo de Unidade AGF foi clicado    
                //calcular total AGF
                function altsomaragf(){
                    var totala = 0
                    $( ".checkPontuacaoAlt" ).each(function( index ) {
                        if($(this).is(':checked')){
                            totala = totala + eval($(this).val())
                        }
                    });
                    var totalb = 0
                    $( ".checkPontuacaoAltAGF" ).each(function( index ) {
                        if($(this).is(':checked')){
                            totalb = totalb + eval($(this).val())
                        }
                    });
                    var total = eval(totala) + eval(totalb) 
                    $('#pontuacaoCalculadaAltAGF').val(total);
                } //calcular total AGF 
                // Botão do Tipo de unidade foi clicado   no Plano de Teste           
                $('.alttipounid').click(function(){
                    var title = $(this).attr("title");
                    //alert($(this).attr("id"));
                    var altoutros = 0;
                    var altagfsn = 'N'
                    let alttpunid = ''

                    //verificar outras seleção
                    $( ".alttipounid" ).each(function( index ) {
                        if($(this).attr("title") != 0){
                            //alert( index + ": " + $(this).attr("title") );
                            altoutros = altoutros + 1
                            alttpunid = $(this).attr("id")
                            if(alttpunid == 12){altagfsn = 'S'}
                        }
                    });

                    if(title == 0){
                        // tipo de unidade foi selecionada
                        //alterar o title do botão
                        $(this).attr("title","1");
                        // alterar a class do botão
                        $(this).attr("class","alttipounid btn btn-success");
                        $(this).css('box-shadow', '10px 10px 5px #888')
                        title = 1
                        alttpunid = $(this).attr("id");
                        if(alttpunid == 12){altagfsn = 'S'}
                    }else{
                        //tipo de unidade foi deselecionada
                        //alterar o title do botão
                        $(this).attr("title","0");
                        // alterar a class do botão
                        $(this).attr("class","alttipounid btn btn-primary");
                        $(this).css('box-shadow', '10px 10px 5px 0');  
                        title = 0   
                        alttpunid = $(this).attr("id")
                        if(alttpunid == 12){altagfsn = 'N'} 
                    } 
                    //alert(altagfsn); 
                    if((altoutros != 0) || (altoutros == 0 && title == 0) || title == 1){ 
                        $("#propriasalt").show(500);
                    }
                    if(altoutros == 1 && title == 0){ 
                        $("#propriasalt").hide(500);
                        $("#franquiaalt").hide(500);
                    }  
                    if(altagfsn == 'S'){$("#franquiaalt").show(500);}                
                    if(altagfsn == 'N'){
                        $( ".checkPontuacaoAltAGF" ).each(function( index ) {
                            if($(this).val() == 0){
                                // $(this).prop('checked',true);
                                totalb = 0
                            }
                        });
                        altsomaragf();
                        $("#franquiaalt").hide(500);
                    }// alert(altoutros + '  ' + title)           
            }) // fim // BUSCAR dados para alteração com o evento selAltModalidade.change()
            //buscar o departamento do processo
            $('#altgestordir').change(function(e){ 
                let prots = '<option value="" selected>---</option>';
                $("#altgestordepto").html(prots);  
                let digpid = $(this).val(); 
                if(altgestordir != ''){                         
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
                    $("#altgestordepto").html(prots);
                    })  
                }
            })//fim buscar o departamento do processo            
            //=======================================================================         
            // Para realizar a críticas do submit
            function alttpunidselec() {
                var alttpunid = ''
                //verificar os tipos selecionados
                $( ".alttipounid" ).each(function( index ) {
                    if($(this).attr("title") != 0){           
                        if(alttpunid == '') {
                            alttpunid = $(this).attr("id")
                        }else{
                            alttpunid = alttpunid + ','+$(this).attr("id")
                        }
                    }
                })
                //alert(alttpunid)
                return alttpunid
            } 
            //Obter o valores PTC_Seq dos dos checkbox selecionados
            function altObterPtcSeqPropria(){
                var ptcseq = ''
                $( ".checkPontuacaoAlt" ).each(function( index ) {
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
            function altObterPtcSeqAGF(){
                var altptcseqagf = 0;
                $( ".checkPontuacaoAltAGF" ).each(function( index ) {
                    if($(this).is(':checked')){
                        altptcseqagf = $(this).attr("title")
                    }
                })
                //alert(altptcseqagf()
                return altptcseqagf              
            }       
            //Obter opções selecionadas para realizar a crítica do submit e salvar informação
            $('#altclassifcontrole').click(function() {
                $('#itnclassificacontrolealt').val($(this).val())
            }); 
            $('#altobjetivoestrategico').click(function() {
                $('#itnobjetivoestrategicoalt').val($(this).val())
            }); 
            $('#altriscoestrategico').click(function() {
                $('#itnriscoestrategico').val($(this).val())
                // alert($('#itnriscoestrategicoalt').val())
            });
            $('#altindicadorestrategico').click(function() {
                $('#itnindicadorestrategicoalt').val($(this).val())
                // alert($('#itnindicadorestrategico').val())
            });                   
            //============================================================================   
            // críticas do submit da tela
            //Críticas do form principal
            function valida_formAltItem(){
                var tiposSelec="";        
                var frm = document.getElementById('formAltItem');

                // Obter os tipos de unidades           
                tiposSelec = alttpunidselec();
                frm.tiposalt.value = tiposSelec;
                //alert("tiposSelec: "+tiposSelec)
                // Obter PtcSeqPropria
                altptcseq = altObterPtcSeqPropria();
                frm.checkPontuacaoAltseq.value = altptcseq
                //alert("altptcseq " + altptcseq);
        
                // Obter PtcSeqAGF
                altptcseqagf = altObterPtcSeqAGF();
                //alert("altptcseqagf: " + altptcseqagf);  
                if(altptcseqagf > 0){
                    frm.checkPontuacaoAltagfseq.value = altptcseq+','+altptcseqagf;
                }else{
                    frm.checkPontuacaoAltagfseq.value = altptcseq;
                }          
                
                //alert(frm.checkPontuacaoAltagfseq.value);

                if (frm.selAltItemAno.value == '') {
                    alert('Informe o ano que este item será utilizado!');
                    frm.selAltItemAno.focus();
                    return false;
                }

                if (frm.selAltItemGrupo.value == '') {
                    alert('Informe um grupo para item!');
                    frm.selAltItemGrupo.focus();
                    return false;
                }

                if (frm.selAltItem.value == '') {
                    alert('Selecione o Item para realizar a Operação!');
                    frm.selAltItem.focus();
                    return false;
                }

                if (frm.selAltModalidade.value == '') {
                    alert('Selecione a Modalidade para item!');
                    frm.selAltModalidade.focus();
                    return false;
                }

                if (frm.altItemDescricao.value == '') {
                    alert('Informe uma descrição para item!');
                    frm.altItemDescricao.focus();
                    return false;
                }

                if (frm.altItemManchete.value == '') {
                    alert('Informar a Manchete para item!');
                    frm.altItemManchete.focus();
                    return false;
                }
        
                if (frm.selAltItemValorDec.value == '') {
                    alert('Informe se o item prevê ou não valor declarado!');
                    frm.selAltItemValorDec.focus();
                    return false;
                }

                if (frm.selAltVisualizacao.value == '') {
                    alert('Informe se o item prevê ou não Visualização!');
                    frm.selAltVisualizacao.focus();
                    return false;
                }

                if (frm.selAltValidObrig.value == '') {
                    alert('Informe se o item deve obrigatoriamente ser validado pelo gestor em caso de avaliação "NÃO EXECUTA"!');
                    frm.selAltValidObrig.focus();
                    return false;
                }

                if (CKEDITOR.instances.altItemOrientacao.getData()== '') {
                    alert('Informe "COMO EXECUTAR/PROCEDIMENTOS ADOTADOS" para o item!');
                    CKEDITOR.instances.altItemOrientacao.focus();
                    return false;
                }

                if (CKEDITOR.instances.altItemAmostra.getData()== '') {
                    alert('Informe a Amostra para o item!');
                    CKEDITOR.instances.altItemAmostra.focus();
                    return false;
                }

                if (CKEDITOR.instances.altItemNorma.getData()== '') {
                    alert('Informe a Norma para o item!');
                    CKEDITOR.instances.altItemNorma.focus();
                    return false;
                }

                if (CKEDITOR.instances.altItemPreRelato.getData()== '') {
                    alert('Informe o Relato/Pré-Relato Modelo para o item.');
                    CKEDITOR.instances.altItemPreRelato.focus();
                    return false;
                }
                    
                if (CKEDITOR.instances.altItemOrientacaoRelato.getData()== '') {
                    alert('Informe as Orientações para Unidade/Órgão do Item!');
                    CKEDITOR.instances.altItemOrientacaoRelato.focus();
                    return false;
                }
                // críticas para os novos campos  Gilvan 31/10/2024
                $('#itnclassificacontrolealt').val($('#altclassifcontrole').val())
                if ($('#itnclassificacontrolealt').val() == '') {
                    alert('Selecione uma ou mais Classificação do Controle.');
                    frm.altclassifcontrole.focus();
                    return false;
                }
                //alert('itnclassificacontrolealt: '+$('#itnclassificacontrolealt').val())          
                if ($('#altcontroletestado').val() == '') {
                    alert('Informe o Controle Testado.');
                    frm.altcontroletestado.focus();
                    return false;
                }  
                
                $('#itncategoriacontroleAlt').val($('#altcategcontrole').val())
                if ($('#itncategoriacontroleAlt').val() == '') {
                    alert('Selecione uma ou mais Categoria do Controle.');
                    frm.altcategcontrole.focus();
                    return false;
                }   
                //alert('itncategoriacontroleAlt: '+$('#itncategoriacontroleAlt').val())

                if ($('#riscoidentificadoSNAlt').val() == 'N' && $('#altcategoriarisco').val() == '') {
                    alert('Selecione um Risco Identificado.');
                    frm.altcategoriarisco.focus();
                    return false;
                }  

                //alert('riscoidentificadoSNAlt: '+$('#riscoidentificadoSNAlt').val() + ' altcategoriarisco: '+$('#altcategoriarisco').val()) 
                if ($('#riscoidentificadoSNAlt').val() == 'S' && $('#altcategoriariscooutros').val() == '') {
                    alert('Informe a descrição para opção Outros selecionada como Risco Identificado.');
                    frm.altcategoriariscooutros.focus();
                    return false;
                } 
                //alert('riscoidentificadoSNAlt: '+$('#riscoidentificadoSNAlt').val() + ' altcategoriarisco: '+$('#altcategoriariscooutros').val())            

                if ($('#altmacroprocesso').val() == '') {
                    alert('Selecione um Macroprocesso como Tipo de Avaliação.');
                    frm.altmacroprocesso.focus();
                    return false;
                } 

                if ($('#processon1naoaplicarSNAlt').val() == 'S' && $('#altprocesson1naoseaplica').val() == '') {
                    alert('Informe a descrição para opção Não se Aplica selecionada como Processo N1.');
                    frm.altprocesson1naoseaplica.focus();
                    return false;
                }  
                //alert('processon1naoaplicarSNAlt: '+$('#processon1naoaplicarSNAlt').val() + ' altprocesson1naoseaplica: '+$('#altprocesson1naoseaplica').val())   
                //alert('processon1naoaplicarSNAlt: '+$('#processon1naoaplicarSNAlt').val() + ' altprocesson1: '+$('#altprocesson1').val())                     
                if ($('#processon1naoaplicarSNAlt').val() == 'N' && $('#altprocesson1').val() == '') {
                    alert('Selecione um Processo N1 como Tipo de Avaliação.');
                    frm.altprocesson1.focus();
                    return false;
                } 
                //alert('processon1naoaplicarSNAlt: '+$('#processon1naoaplicarSNAlt').val() + ' altprocesson1: '+$('#altprocesson1').val())             
                // críticas para os campos Processo N2 e Processo N3
                if ($('#processon1naoaplicarSNAlt').val() == 'N') {
                    if ($('#altprocesson2').val() == '') {
                        alert('Selecione um Processo N2 como Tipo de Avaliação.');
                        frm.altprocesson2.focus();
                        return false;
                    }                    
                    if ($('#processon3outrosSNAlt').val() == 'S'  && $('#altprocesson3outros').val() == '') {
                        alert('Informe a descrição para opção Outros selecionada como Processo N3.');
                        frm.altprocesson3outros.focus();
                        return false;
                    }  
                    //alert($('#processon3outrosSNAlt').val()) 
                    if ($('#processon3outrosSNAlt').val() == 'N'  && $('#altprocesson3').val() == '') {
                        alert('Selecione um Processo N3 como Tipo de Avaliação.');
                        frm.altprocesson3.focus();
                        return false;
                    }                                            
                }  
                if ($('#altgestordir').val() == '') {
                    alert('Selecione uma Diretoria do Processo.');
                    frm.altgestordir.focus();
                    return false;
                } 
                if ($('#altgestordepto').val() == '') {
                    alert('Selecione um Departamento do Processo.');
                    frm.altgestordepto.focus();
                    return false;
                } 
                    
                $('#itnaltobjetivoestrategicoAlt').val($('#altobjetivoestrategico').val())
                if ($('#itnaltobjetivoestrategicoAlt').val() == '') {
                    alert('Selecione uma ou mais Objetivo(s) Estratégico.');
                    frm.altobjetivoestrategico.focus();
                    return false;
                } 

                $('#itnaltriscoestrategicoAlt').val($('#altriscoestrategico').val())
                if ($('#itnaltriscoestrategicoAlt').val() == '') {
                    alert('Selecione uma ou mais Risco(s) Estratégico.');
                    frm.altriscoestrategico.focus();
                    return false;
                }   

                $('#itnaltindicadorestrategicoAlt').val($('#altindicadorestrategico').val())            
                if ($('#itnaltindicadorestrategicoAlt').val() == '') {
                    alert('Selecione uma ou mais Indicador(es) Estratégico.');
                    frm.altindicadorestrategico.focus();
                    return false;
                }  
                
                if ($('#altcomponentecoso').val() == '') {
                    alert('Selecione um Componente - COSO 2013.');
                    frm.altcomponentecoso.focus();
                    return false;
                }  

                if ($('#altprincipioscoso').val() == '') {
                    alert('Selecione um Princípio - COSO 2013.');
                    frm.altprincipioscoso.focus();
                    return false;
                }                       
                // final criticas dos novos campos

                if (frm.tiposalt.value == '') {
                    alert('Selecione, pelo menos, 01(um) tipo de unidade para a qual o item será aplicado.');
                    return false;
                }

                if (frm.pontuacaoCalculadaAlt.value == 0) {
                    alert('Selecione, pelo menos, 01(um) Tipo de Unidade para o qual o item será aplicado nas avaliações\nSelecionar a Composição de Pontuação do Item!');
                    return false;
                }

                if (frm.pontuacaoCalculadaAlt.value == 0 && frm.pontuacaoCalculadaAltAGF.value == 0) {
                  //  alert('Selecione, pelo menos, 01(um) Tipo de Unidade para o qual o item será aplicado nas avaliações\n\nSelecionar a composição da pontuação do Item!');
                 //   return false;
                }

                if ((tiposSelec.indexOf(12) !== -1) && (frm.pontuacaoCalculadaAlt.value == frm.pontuacaoCalculadaAltAGF.value)) {
                    alert('Informar o ponto adicional para o tipo de unidade AGF!')
                    return false;
                }      

                //alert("tiposSelec: "+frm.tiposalt.value)
                //alert(frm.pontuacaoCalculadaAlt.value)
                //alert(frm.pontuacaoCalculadaAltAGF.value)
                frm.acaoalt.value = ''
                if(window.confirm('Deseja alterar este Item?')){  
                    frm.acaoalt.value = 'altItem'
                    aguarde()
                    setTimeout('document.getElementById("formAltItem").submit();',2000)
                    return true	
                }else{
                    return false
                }

            }  
            
            function valida_formExcItem(){
                var frm = document.getElementById('formAltItem');
                        
                if (frm.itmemuso.value != 0) {
                    alert('Foram localizados registros de Avaliação para o Item.\n\n A exclusão não poderá ser realizada!')
                    return false;
                }
            
                if(frm.itmemuso.value == 0){
                    if(window.confirm('Confirma a exclusão definitiva do item?\n\nAtenção: O item será excluído do Plano de Teste de todas as modalidades de Avaliação!')){
                        frm.acaoalt.value = 'excItem';
                        aguarde();
                        setTimeout('document.getElementById("formAltItem").submit();',1000);
                        return true;
                    }else{return false;}
                }
            }            
            // fim da críticas do submit     
                                                     
        </script>
    </body>
</html>