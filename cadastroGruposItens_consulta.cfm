<cfprocessingdirective pageEncoding ="utf-8">
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfif isDefined("form.formConsulta") >
    <cfparam name="form.acao" default="#form.acao#">
    <cfparam name="form.selAnoConsulta" default="#form.selAnoConsulta#"> 
    <cfparam name="form.selTipoConsulta" default="#form.selTipoConsulta#"> 
    <cfparam name="form.selModConsulta" default="#form.selModConsulta#">
    <cfparam name="form.selGrupoConsulta" default="#form.selGrupoConsulta#"> 
    <cfparam name="form.selSitConsulta" default="#form.selSitConsulta#">
    <cfparam name="form.selValDecConsulta" default="#form.selValDecConsulta#">

<cfelse>
    <cfparam name="form.acao" default="">
    <cfparam name="form.selAnoConsulta" default="">
    <cfparam name="form.selTipoConsulta" default=""> 
    <cfparam name="form.selModConsulta" default="">
    <cfparam name="form.selGrupoConsulta" default=""> 
    <cfparam name="form.selSitConsulta" default="">
    <cfparam name="form.selValDecConsulta" default="">
</cfif>

<cfquery datasource="#dsn_inspecao#" name="rsAnoFiltro">
    SELECT DISTINCT Grp_Ano FROM Grupos_Verificacao  ORDER BY Grp_Ano desc
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsTipoFiltro">
    SELECT DISTINCT TUN_Codigo, TUN_Descricao FROM Tipo_Unidades
    INNER JOIN TipoUnidade_ItemVerificacao ON TUI_TipoUnid = TUN_Codigo AND TUI_Ano = '#form.selAnoConsulta#'
    ORDER BY TUN_Descricao
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsModFiltro">
    SELECT DISTINCT TUI_Modalidade FROM TipoUnidade_ItemVerificacao
    WHERE TUI_Ano = '#form.selAnoConsulta#'
    <cfif '#form.selTipoConsulta#' neq ''>
            AND TUI_TipoUnid = '#form.selTipoConsulta#'
    </cfif>
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsGrupoFiltro">
    SELECT DISTINCT Grp_Codigo, Grp_Descricao FROM Grupos_Verificacao 
    INNER JOIN TipoUnidade_ItemVerificacao ON TUI_GrupoItem = Grp_Codigo AND TUI_Ano = Grp_Ano
    WHERE TUI_Ano = '#form.selAnoConsulta#'
    <cfif '#form.selTipoConsulta#' neq ''>
        AND TUI_TipoUnid = '#form.selTipoConsulta#'
    </cfif>
    <cfif '#form.selModConsulta#' neq '2' and '#form.selModConsulta#' neq ''>
        AND TUI_Modalidade = '#form.selModConsulta#'
   </cfif>
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsSitFiltro">
    SELECT DISTINCT TUI_Ativo FROM TipoUnidade_ItemVerificacao
    WHERE TUI_Ano = '#form.selAnoConsulta#'
    <cfif '#form.selTipoConsulta#' neq ''>
        AND TUI_TipoUnid = '#form.selTipoConsulta#'
    </cfif>
    <cfif '#form.selModConsulta#' neq '2' and '#form.selModConsulta#' neq ''>
        AND TUI_Modalidade = '#form.selModConsulta#'
    </cfif>
    <cfif '#form.selGrupoConsulta#' neq ''>
        AND TUI_GrupoItem = '#form.selGrupoConsulta#'
    </cfif>
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsVlrDecFiltro">
    SELECT DISTINCT Itn_ValorDeclarado FROM Itens_Verificacao
    INNER JOIN TipoUnidade_ItemVerificacao ON Itn_Ano = TUI_Ano and TUI_Modalidade=Itn_Modalidade and Itn_NumGrupo = TUI_GrupoItem AND Itn_NumItem = TUI_ItemVerif AND TUI_TipoUnid=Itn_TipoUnidade 
    WHERE TUI_Ano = '#form.selAnoConsulta#'
        <cfif '#form.selTipoConsulta#' neq ''>
            AND TUI_TipoUnid = '#form.selTipoConsulta#'
        </cfif>
        <cfif '#form.selModConsulta#' neq '2' and '#form.selModConsulta#' neq ''>
            AND TUI_Modalidade = '#form.selModConsulta#'
        </cfif>
        <cfif '#form.selGrupoConsulta#' neq ''>
            AND TUI_GrupoItem = '#form.selGrupoConsulta#'
        </cfif>
        <cfif '#form.selSitConsulta#' neq ''>
            AND TUI_Ativo = #form.selSitConsulta#
        </cfif>
</cfquery>

<cfif isDefined("form.acao") and '#form.acao#' eq 'filtrar'>
    <script>aguarde();</script>
    <cfquery datasource="#dsn_inspecao#" name="rsChecklistFiltrado">
        SELECT TUI_Modalidade,TUI_TipoUnid,TUI_Ativo, TUI_Ano, TUI_GRUPOITEM, TUI_ITEMVERIF, TUN_Descricao,  Grp_Descricao, Itn_Descricao,Itn_ValorDeclarado, Itn_TipoUnidade 
        FROM TipoUnidade_ItemVerificacao 
        INNER JOIN Grupos_Verificacao ON Grp_Codigo = TUI_GrupoItem AND Grp_Ano = TUI_Ano 
        INNER JOIN Itens_Verificacao ON Grp_Ano = Itn_Ano and TUI_Modalidade=Itn_Modalidade and Itn_NumGrupo = TUI_GrupoItem and Itn_NumItem = TUI_ItemVerif AND TUI_TipoUnid = Itn_TipoUnidade
        INNER JOIN Tipo_Unidades ON TUN_Codigo = TUI_TipoUnid
        WHERE TUI_Ano = '#form.selAnoConsulta#'
        <cfif '#form.selTipoConsulta#' neq ''>
            AND TUI_TipoUnid = '#form.selTipoConsulta#'
        </cfif>
        <cfif '#form.selModConsulta#' neq '2' and '#form.selModConsulta#' neq ''>
            AND TUI_Modalidade = '#form.selModConsulta#'
        </cfif>
        <cfif '#form.selGrupoConsulta#' neq ''>
            AND TUI_GrupoItem = '#form.selGrupoConsulta#'
        </cfif>
        <cfif '#form.selSitConsulta#' neq ''>
            AND TUI_Ativo = #form.selSitConsulta#
        </cfif>
        <cfif '#form.selValDecConsulta#' neq ''>
            AND Itn_ValorDeclarado = '#form.selValDecConsulta#'
        </cfif>
        ORDER BY TUI_GRUPOITEM, TUI_ITEMVERIF, TUN_Descricao  
    </cfquery>
    <script>aguarde();</script>
</cfif>

<!DOCTYPE html>
<html lang="pt-BR">

    <head>
        <title>SNCI - CADASTRO DE GRUPOS E ITENS</title>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
       

    <style type="text/css">    
        .tituloDivConsulta{
            padding:5px;
            position:relative;
            top: -19px;
            background: #003366;
            border: 1px solid #fff;
        }
        :hover 
            { background-color: #000000; 
                transition: 0.5s;
                opacity: 0.7;
                
            }

        .divTabela {
            overflow-y: scroll;
            overflow-x: hidden;
        }

        thead tr {
            position: relative;
            top: expression(this.offsetParent.scrollTop);
            z-index: 1000;
        }

        tbody {
            height: auto;
        }

            
    </style>

    <script type="text/javascript">
$(document).on('click', 'a', function(e){ 
    e.preventDefault(); 
    var url = $(this).attr('href'); 
    window.open(url, '_blank');
});        
  
        function mudarFiltroAno(){
            var frm = document.getElementById('formConsulta');
            frm.selModConsulta.value = '';
            frm.selGrupoConsulta.value = '';
            frm.selSitConsulta.value = '';
            frm.selValDecConsulta.value = '';    
        }
        function mudarFiltroTipo(){
            var frm = document.getElementById('formConsulta');
            frm.selModConsulta.value = '';
            frm.selGrupoConsulta.value = '';
            frm.selSitConsulta.value = '';
            frm.selValDecConsulta.value = '';
            <cfoutput>
                <cfif '#rsModFiltro.recordcount#' gt 1 and '#form.selModConsulta#' eq ''>
                    <cfset form.selModConsulta = '2'>
                </cfif>  
            </cfoutput>  
        }
        function mudarFiltroMod(){
            var frm = document.getElementById('formConsulta');
            frm.selGrupoConsulta.value = '';
            frm.selSitConsulta.value = '';
            frm.selValDecConsulta.value = '';    
        }
        function mudarFiltroGrupo(){
            var frm = document.getElementById('formConsulta');
            frm.selSitConsulta.value = '';
            frm.selValDecConsulta.value = '';    
        }
        function mudarFiltroSit(){
            var frm = document.getElementById('formConsulta');
            frm.selValDecConsulta.value = '';    
        }

        
        function mudarFiltro(){
            var frm = document.getElementById('formConsulta');
            aguarde();
            setTimeout('javascript:formConsulta.submit();',2000);
        }

        function submeterForm(){
            var frm = document.getElementById('formConsulta');
            if(frm.selAnoConsulta.value==''){
                alert('Necessário selecionar, pelo menos, o ano!');
                frm.selAnoConsulta.focus();
                return false;
            }
            aguarde();
            frm.acao.value = 'filtrar';
            setTimeout('javascript:formConsulta.submit();',2000);
        }

        //In�cio fun��o de filtro de tabela
        function doDestacaTexto(Texto, termoBusca){

            /*******************************************************************/
            // CASO QUEIRA MODIFICAR O ESTILO DA MARCA��O ALTERE ESSAS VARI�VEIS
            /*******************************************************************/
            inicioTag = "<font style='color:#000;background-color:#A0FFFF'><b>";
            fimTag = "</b></font>";

            var novoTexto = "";
            var i = -1;
            var lcTermoBusca = termoBusca.toLowerCase();
            var lcTexto = Texto.toLowerCase();

            while (Texto.length > 0){
                i = lcTexto.indexOf(lcTermoBusca, i+1);
                if (i < 0){
                    novoTexto += Texto;
                    Texto = "";
                }
                else{
                    if (Texto.lastIndexOf(">", i) >= Texto.lastIndexOf("<", i)){
                        if (lcTexto.lastIndexOf("/script>", i) >= lcTexto.lastIndexOf("<script", i)){
                            novoTexto += Texto.substring(0, i) + inicioTag + Texto.substr(i, termoBusca.length) + fimTag;
                            Texto = Texto.substr(i + termoBusca.length);
                            lcTexto = Texto.toLowerCase();
                            i = -1;
                        }
                    }
                }
            }
            return novoTexto;
        }

        function searchTable() {
            var input, filter, found, table, tr, td, i, j, qLinhas, h1;
            input = document.getElementById("myInput");
            filter = input.value.toUpperCase();
            table = document.getElementById("tabChecklistFiltrado");
            tr = table.getElementsByTagName("tr");
            //i = 2 para iniciar o filtro pela tr da tabela
            qLinhas =0;
            for (i = 1; i < tr.length; i++) {
                td = tr[i].getElementsByTagName("td");
                
                if (td[4].innerHTML.toUpperCase().indexOf(filter) > -1) {
                    found = true;
                    if(td[4].innerHTML!=''){
                        qLinhas++  
                    }
                }
                
                if (found) {
                    tr[i].style.display = "";
                    found = false;
                } else {
                    tr[i].style.display = "none";
                }
               
            
            }
            h1 = document.getElementById('qItens');
            h1.innerHTML = "PLANO DE TESTE FILTRADO: " + qLinhas +  " registros encontrados";
            td = tr.getElementsByTagName("td");
            
        }
        //Fim fun��o de filtro de tabela
        

    </script>
       
    </head>

    <body id="main_body" style="background:#fff" onLoad="">
   
        <div align="left">
            <form id="formConsulta" nome="formConsulta" enctype="multipart/form-data" method="post" >
            <input type="hidden" value="" id="acao" name="acao">
                <div align="left" style="padding:10px;border:1px solid #fff;margin-bottom:10px">
                        <div align="left">
								<span class="tituloDivConsulta" >Consultar PLANO DE TESTE</span>
						</div>
                       
                        <div align="left" style="">
                            <div style="margin-bottom:10px;float:left;margin-right:10px;">
                                <label  for="selAnoConsulta" style="color:#369;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px"><strong>ANO:*</strong></label>
                                <div ></div>	
                                <select name="selAnoConsulta" id="selAnoConsulta" onChange="mudarFiltroAno();mudarFiltro();" class="form" style="display:inline-block;">										   
                                    <option selected="selected" value=""></option>
                                    <cfoutput query="rsAnoFiltro">
                                        <option  <cfif "#Grp_Ano#" eq "#form.selAnoConsulta#">selected</cfif> value="#Grp_Ano#">#Grp_Ano#</option>
                                    </cfoutput>
                                </select>		
                            </div>
                            <div style="margin-bottom:10px;float:left;margin-right:10px;">
                                <label  for="selTipoConsulta" style="color:#369;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px"><strong>TIPO UNID.:</strong></label>
                                <div ></div>
                                <select name="selTipoConsulta" id="selTipoConsulta" class="form" onChange="mudarFiltroTipo();submeterForm()"  
                                        style="display:inline-block;width:100px;">
                                    <option selected value=""></option>
                                    <cfif '#rsTipoFiltro.recordcount#' gt 1>			
									    <option selected value="">TODOS</option>
                                    </cfif>
									<cfif rsTipoFiltro.recordcount neq 0>
										<cfoutput query="rsTipoFiltro">
											<option  <cfif '#form.selTipoConsulta#' eq '#rsTipoFiltro.TUN_Codigo#'>selected</cfif> value="#TUN_Codigo#">#TUN_Descricao#</option>
										</cfoutput>
									</cfif>
								</select>
							</div> 
                            <div style="margin-bottom:10px;float:left;margin-right:10px;">
                                <label  for="selModConsulta" style="color:#369;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                <strong>MODALIDADE:</strong></label>
                                <br>	
                                <select name="selModConsulta" id="selModConsulta"  class="form" onChange="mudarFiltroMod();submeterForm()" 
                                style="display:inline-block;width:110px;">
                                    
                                    <cfif '#rsModFiltro.recordcount#' gt 1>
                                         <option selected="selected" value="2">TODAS</option>
                                    </cfif>
                                    <cfif '#rsModFiltro.recordcount#' eq 0 >
                                         <option selected="selected" value=""></option>
                                    </cfif> 

                                    <cfoutput query="rsModFiltro">
                                        <option <cfif '#form.selModConsulta#' eq '#TUI_Modalidade#' >selected</cfif> value="#TUI_Modalidade#"><cfif #TUI_Modalidade# eq 0>PRESENCIAL<cfelse>A DIST�NCIA</cfif></option>                                   
                                    </cfoutput>
                                </select>
						    </div>
                        
                            <div style="margin-bottom:10px;float:left;margin-right:10px;">
                                <label  for="selGrupoConsulta" style="color:#369;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                <strong>GRUPO:</strong></label>
                                <div ></div>	
                                        <select name="selGrupoConsulta" id="selGrupoConsulta"   class="form" onChange="mudarFiltroGrupo();submeterForm()"
                                        style="display:inline-block;width:290px;">										
                                            
                                            <cfif '#rsGrupoFiltro.recordcount#' gt 1>
                                                <option selected="selected" value="">TODOS</option>
                                            </cfif>
                                            <cfif '#rsGrupoFiltro.recordcount#' eq 0>
                                                <option selected="selected" value=""></option>
                                            </cfif>
                                            <cfoutput query="rsGrupoFiltro">
                                                <option  <cfif "#Grp_Codigo#" eq "#form.selGrupoConsulta#">selected</cfif> value="#Grp_Codigo#">#Grp_Codigo# - #Grp_Descricao#</option>
                                            </cfoutput>
                                            
                                        </select>              		
                            </div>
                            <div style="margin-bottom:10px;float:left;margin-right:10px;">
                                <label  for="selSitConsulta" style="color:#369;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px"><strong>SITUAÇÃO:</strong></label>
                                <div ></div>
                                <select name="selSitConsulta" id="selSitConsulta" class="form"  onchange="mudarFiltroSit();submeterForm()" 
                                        style="display:inline-block;width:110px;">
                                    
                                    <cfif '#rsSitFiltro.recordcount#' gt 1>    			
									    <option selected value="">TODAS</option>
									</cfif>
			
									
                                    <cfoutput query="rsSitFiltro">
                                        <option  <cfif '#form.selSitConsulta#' eq '#TUI_Ativo#'>selected</cfif> value="#TUI_Ativo#"><cfif #TUI_Ativo# eq 0>DESATIVADO<cfelse>ATIVADO</cfif></option>
                                    </cfoutput>
                                </select>
							</div>
                            <div style="margin-bottom:10px;">
                                <label  for="selValDecConsulta" style="color:#369;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px"><strong>VAL.DEC.:</strong></label>
                                <div ></div>
                                <select name="selValDecConsulta" id="selValDecConsulta" class="form" onChange="submeterForm()"
                                        style="display:inline-block;width:100px;">
                                   		
                                    <cfif '#rsVlrDecFiltro.recordcount#' gt 1>  
                                        <option selected value="">TODOS</option>
                                    </cfif>
                                    <cfoutput query="rsVlrDecFiltro">
                                        <option  <cfif '#form.selValDecConsulta#' eq '#Itn_ValorDeclarado#'>selected</cfif> value="#Itn_ValorDeclarado#"><cfif '#Itn_ValorDeclarado#' eq 'S'>SIM<cfelse>NÃO</cfif></option>
                                    </cfoutput>        
								</select>
							</div>
                                   
                        </div> 
        
                </div> 
                <cfif isDefined("form.acao") and '#form.acao#' eq 'filtrar'>
                    <cfif rsChecklistFiltrado.recordCount neq 0>
                        <div align="center" style="width:250px;float:right;margin-bottom:10px">
                                <cfset modalidade ='#form.selModConsulta#'>
                                <cfif '#modalidade#' eq ''>
                                  <cfset modalidade ='#rsModFiltro.TUI_Modalidade#'>
                                </cfif>
                                <div align="center" style="color:#036;width:70px;float:left;cursor:pointer" onClick="window.open('GeraRelatorio/gerador/dsp/PlanodeTeste_com_pontuacao.cfm?ano=<cfoutput>#form.selAnoConsulta#</cfoutput>&tipo=<cfoutput>#form.selTipoConsulta#</cfoutput>&mod=<cfoutput>#modalidade#</cfoutput>&grupo=<cfoutput>#form.selGrupoConsulta#</cfoutput>&sit=<cfoutput>#form.selSitConsulta#</cfoutput>&valDec=<cfoutput>#form.selValDecConsulta#</cfoutput>&comOrientacao=n,_blank')">
                                    <div style="position:relative;top:10px">
                                        <img src="figuras/print.png" width="25"  border="0"></img>
                                    </div>
                                    <br>
                                    <div >
                                        <span style="font-size:10px">Pontuações / Classificações</span>
                                    </div>   
                                </div>
																
                                <div align="center" style="color:#036;width:60px;float:left;cursor:pointer" onClick="<cfoutput>window.open('GeraRelatorio/gerador/dsp/planoDeTeste.cfm?ano=#form.selAnoConsulta#&tipo=#form.selTipoConsulta#&mod=#modalidade#&grupo=#form.selGrupoConsulta#&sit=#form.selSitConsulta#&valDec=#form.selValDecConsulta#&comOrientacao=n,_blank')</cfoutput>">
                                    <div style="color:#036;position:relative;top:10px">
                                        <img src="figuras/print.png" width="25"  border="0"></img>
                                    </div>
                                    <br>
                                    <div >
                                        <span style="font-size:10px">s/ Como Executar</span>
                                    </div>   
                                </div>
                            
                                <div align="center" style="color:#036;width:60px;float:left;cursor:pointer" onClick="<cfoutput>window.open('GeraRelatorio/gerador/dsp/planoDeTeste.cfm?ano=#form.selAnoConsulta#&tipo=#form.selTipoConsulta#&mod=#modalidade#&grupo=#form.selGrupoConsulta#&sit=#form.selSitConsulta#&valDec=#form.selValDecConsulta#&comOrientacao=s,_blank')</cfoutput>">
                                    <div style="color:#036;position:relative;top:10px">
                                        <img src="figuras/print.png" width="25"  border="0"></img>
                                    </div>
                                    <br>
                                    <div>
                                        <span style="font-size:10px">c/Como Executar</span>
                                    </div>   
                                </div>
                                <div align="center" style="color:#036;width:60px;float:left;cursor:pointer" onClick="<cfoutput>window.open('Gerar_planilha_relevancia.cfm?ano=#form.selAnoConsulta#&tipo=#form.selTipoConsulta#&mod=#modalidade#&grupo=#form.selGrupoConsulta#&sit=#form.selSitConsulta#&valDec=#form.selValDecConsulta#&comOrientacao=s,_blank')</cfoutput>">
                                    <div style="color:#036;position:relative;top:10px">
                                        <img src="figuras/print.png" width="25"  border="0"></img>
                                    </div>
                                    <br>
                                    <div>
                                        <span style="font-size:10px">Relevância</span>
                                    </div>   
                                </div>						  
        
                        </div>
                        
                    </cfif>
                </cfif>
                <div class="row"></div>
                <div align="left" >
                    <cfif isDefined("form.acao") and '#form.acao#' eq 'filtrar'>
                        <cfif rsChecklistFiltrado.recordCount neq 0>
                          <div style="position:relative;left:-20px;top:35px;"> 
                            <img src="figuras/lupa.png" width="16"  style="position:relative; left:25px;top:2px;">
                            <input name="text" type="text"  id="myInput" onBlur='searchTable()' onChange="searchTable();"  onKeyUp="searchTable();">
                          </div>
                         
                          <div align="left" style="position:relative;left:152px;top:13px;">
                            <h1 id="qItens" style="color:#369;font-size:10px;background:transparent"><strong>PLANO DE TESTE FILTRADO: <cfoutput>#rsChecklistFiltrado.recordcount#</cfoutput> registros encontrados</strong></h1>
                          </div>
                                                   
                            <div id="form_container" style="width:840px;height:300px;overflow-y:auto;">
                                 
                              
                                <table width="99%" align="left" id="tabChecklistFiltrado" >
                                            <thead>                                               
                                                <tr bgcolor="003366" class="exibir" align="center" style="color:#fff">
                                                
                                                    <th width="9%">
                                                  <div align="center">Ano</div>                                                    </th>
                                                    
                                                    <th width="10%">
                                                  <div align="center">Tp Unidade</div>                                                    </th>
                                                    <th width="13%">
                                                  <div align="center">Modalidade</div>                                                    </th>
                                                    <th width="17%">
                                                  <div align="center">Grupo</div>                                                    </th>
                                                    <th width="30%">
                                                  <div align="center">Item</div>                                                    </th>
                                                    <th width="9%">
                                                  <div align="center">Valor Declarado</div>                                                    </th>
                                                    <th width="12%">
                                                  <div align="center">Situação</div>                                                    </th>
                                                </tr>
                                            </thead>
                                            <cfset scor='white'>
                                                <cfoutput query="rsChecklistFiltrado">
                                                    <form id="formChecklistFiltrado" action="" method="POST">
                                                    <div>
                                                        <tr id="#rsChecklistFiltrado.CurrentRow#" 
                                                            onMouseOver="mouseOver(this);" 
                                                            onMouseOut="mouseOut(this);"
                                                            onclick="gravaOrdLinha(this);abrirPopup('cadastroGruposItens_consultaPopup.cfm?selAnoConsulta=#TUI_Ano#&selTipoConsulta=#TUI_TipoUnid#&selModConsulta=#TUI_Modalidade#&selGrupoConsulta=#TUI_GrupoItem#&selItemConsulta=#TUI_ItemVerif#',800,400);" 
                                                            valign="middle" bgcolor="#scor#" class="exibir" 
                                                            style="cursor:pointer;text-align: justify;"
                                                            title="Clique para visualizar as orientações para este item.">
                                                            
                                                            
                                                            <td width="9%">
                                                          <div align="center">#TUI_Ano#</div>  
													      <cfset tudesc = TUN_Descricao>                                                          </td>
                                                            <td width="10%">
                                                          <div align="center">#tudesc#</div>                                                            </td>
                                                            <td width="13%">
                                                          <div align="center"><cfif #TUI_Modalidade# eq 0>Presencial<cfelse>A Distância</cfif></div>                                                            </td>
                                                            <td width="17%">
                                                          <div >#TUI_GrupoItem#-#Grp_Descricao#</div>                                                            </td>
                                                            <td width="30%"  >
                                                          <div style="padding:5px" >#TUI_ItemVerif#-#Itn_Descricao#</div>                                                            </td>
                                                            <td width="9%">
                                                          <div align="center"><cfif #Itn_ValorDeclarado# eq 'S'>SIM<cfelse>NÃO</cfif></div>                                                            </td>
                                                            <td width="12%">
                                                                    <div align="center"><cfif '#TUI_Ativo#' eq 0><span style="color:red">DESATIVADO</span><cfelse><strong>ATIVO</strong></cfif></div>
                                                          <div align="center" title='"VISUALIZAÇÃO BLOQUEADA" significa que o item não será visível para tratamento.' style="margin-top:5px"><cfif '#Itn_TipoUnidade#' eq 99><span style="color:red;font-size:8px;"><i><strong>VISUALIZAÇÃO BLOQUEADA</strong></i></span></cfif></div>                                                            </td>
                                                        </tr>
                                                        
                                                    </form>

                                                    <cfif scor eq 'white'>
                                                        <cfset scor='f7f7f7'>
                                                    <cfelse>
                                                        <cfset scor='white'>
                                                    </cfif>
                                                </cfoutput>
                              </table>
                          </div>
                        <cfelse>
                        <div align="center"><label>NÃO FORAM LOCALIZADOS REGISTROS PARA OS PARÂMETROS SELECIONADOS</label></div>
                        </cfif> 
                    </cfif>       
                </div>
                         
              
              
            </form>


        </div>
         
           
    </body>
   
</html>