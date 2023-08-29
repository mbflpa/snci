<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfif isDefined("form.formAltGrupo") >
    <cfparam name="form.acao" default="#form.acao#">
<cfelse>
    <cfparam name="form.acao" default="">
</cfif>

<cfif isDefined("form.acao") and "#form.acao#" eq 'altGrupo'>
    <cfset gpDesc = '#Ucase(form.altGrupoDescricao)#'>
    <cfquery datasource="#dsn_inspecao#" >
        UPDATE Grupos_Verificacao SET Grp_Descricao = '#gpDesc#'
                                    , Grp_DtUltAtu = CONVERT(char, getdate(), 120)
                                    , Grp_UserName = '#qAcesso.Usu_Matricula#'
        WHERE Grp_Ano = '#form.selAltGrupoAno#' and Grp_Codigo = '#form.selAltGrupo#'
    </cfquery>
    <script>
        alert('Alteração realizada com sucesso!');
    </script>
    
</cfif>

<cfif isDefined("form.acao") and "#form.acao#" eq 'excluirGrupo'>

    <cfquery datasource="#dsn_inspecao#" >
        DELETE FROM TipoUnidade_ItemVerificacao WHERE TUI_Ano = '#form.selAltGrupoAno#' and TUI_GrupoItem = '#form.selAltGrupo#'
    </cfquery>
    <cfquery datasource="#dsn_inspecao#" >
        DELETE FROM Itens_Verificacao WHERE Itn_Ano = '#form.selAltGrupoAno#' and Itn_NumGrupo = '#form.selAltGrupo#'
    </cfquery>
    <cfquery datasource="#dsn_inspecao#" >
        DELETE FROM Grupos_Verificacao WHERE Grp_Ano = '#form.selAltGrupoAno#' and Grp_Codigo = '#form.selAltGrupo#'
    </cfquery>

    <script>
        alert('Exclusão realizada com sucesso!');
        window.open('cadastroGruposItens.cfm','_self');
    </script>

</cfif>

<cfif isDefined("form.selAltGrupo") and "#form.selAltGrupo#" neq ''>
    <cfquery datasource="#dsn_inspecao#" name="rsGrupoSelecionado">
        SELECT * FROM Grupos_Verificacao WHERE Grp_Ano = '#form.selAltGrupoAno#' and Grp_Codigo = '#form.selAltGrupo#'
    </cfquery>
    <!--- Verifica o grupo selecionado está associado a algum item--->
    <cfquery datasource="#dsn_inspecao#" name="rsItemGrupo">
        SELECT count(Itn_NumGrupo) as quantItens FROM Itens_Verificacao WHERE Itn_Ano = '#form.selAltGrupoAno#' and Itn_NumGrupo = '#form.selAltGrupo#'
    </cfquery>

    <!--- Verifica o grupo selecionado está associado a algum checkList--->
    <cfquery datasource="#dsn_inspecao#" name="rsCheckList">
        SELECT count(TUI_GrupoItem) as quantCheckList FROM TipoUnidade_ItemVerificacao WHERE TUI_Ano = '#form.selAltGrupoAno#' and TUI_GrupoItem = '#form.selAltGrupo#'
    </cfquery>

    <!--- Verifica o grupo selecionado está associado a alguma avaliação--->
    <cfquery datasource="#dsn_inspecao#" name="rsAvaliacoes">
        SELECT DISTINCT RIP_NumInspecao  FROM Resultado_Inspecao WHERE RIP_Ano = '#form.selAltGrupoAno#' and RIP_NumGrupo = '#form.selAltGrupo#'
    </cfquery>
</cfif>

<!--- Retorna todos os anos cadastrados na tabela  Grupos_Verificacao --->
<cfquery datasource="#dsn_inspecao#" name="rsAnoGrupo">
    SELECT DISTINCT Grp_Ano FROM Grupos_Verificacao
</cfquery>

<cfif isDefined("form.selAltGrupoAno") and "#form.selAltGrupoAno#" neq ''>
    <cfquery datasource="#dsn_inspecao#" name="rsGrupo">
        SELECT * FROM Grupos_Verificacao WHERE Grp_Ano = '#form.selAltGrupoAno#'
    </cfquery>
    <cfif '#rsGrupo.recordcount#' eq 0>
       <script>
        <cfoutput>
            alert('Não existem Grupos cadastrados para o ano ' + '#form.selAltGrupoAno#' + '.');
        </cfoutput>
       </script>
    </cfif>
</cfif>



<html xmlns="http://www.w3.org/1999/xhtml">

    <head>
        <title>SNCI - CADASTRO DE GRUPOS E ITENS</title>
    <!--- 	<cfinclude template="cabecalho.cfm"> --->
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <link rel="stylesheet" type="text/css" href="view.css" media="all">
    </head>

    <style type="text/css">    
        .tituloDivAltGrupo{
            padding:5px;
            position:relative;
            top: -19px;
            background: #003366;
            border: 1px solid #fff;

        }
    </style>

    <script language="JavaScript" type="text/JavaScript">
        
        function valida_formAltGrupo(){
            
            var frm = document.getElementById('formaltGrupo');
            if (frm.selAltGrupoAno.value == '') {
				alert('Informe o ano que este grupo será utilizado!');
				frm.selAltGrupoAno.focus();
				return false;
			}
            if (frm.altGrupoDescricao.value == '') {
				alert('Informe a Descrição do Grupo!');
				frm.altGrupoDescricao.focus();
				return false;
			}

            <cfoutput>
                <cfif isDefined("form.selAltGrupo") and "#form.selAltGrupo#" neq ''>
                    var quantItens = "#rsItemGrupo.quantItens#";
                    var quantCheckList = "#rsCheckList.quantCheckList#";
                    var quantAvaliacoes = "#rsAvaliacoes.recordcount#";
                </cfif>
            </cfoutput>
            if(quantAvaliacoes > 0){
                mens = "Este Grupo faz parte do Plano de Teste de " + quantAvaliacoes + " avaliações já cadastradas no SNCI.\n\nEsta alteração poderá ser visualizada em todas estas avaliações.\n\nDeseja prosseguir?"
                if(window.confirm(mens)){
                    frm.acao.value = 'altGrupo';
                    aguarde();
                    setTimeout('document.getElementById("formAltGrupo").submit();',2000);	
                    return true;
                }else{
                    return false;
                }
            }else{
                if(window.confirm('Deseja alterar este Grupo?')){  
                    frm.acao.value = 'altGrupo';
                    aguarde();
                    setTimeout('document.getElementById("formAltGrupo").submit();',2000);
                    return true;	
                }else{
                    return false;
                }
            }
        }

        function valida_formExcGrupo(){
            var frm = document.getElementById('formaltGrupo');
            <cfoutput>
                <cfif isDefined("form.selAltGrupo") and "#form.selAltGrupo#" neq ''>
                    var quantItens = "#rsItemGrupo.quantItens#";
                    var quantCheckList = "#rsCheckList.quantCheckList#";
                    var quantAvaliacoes = "#rsAvaliacoes.recordcount#";
                </cfif>               
            </cfoutput> 
            if(quantAvaliacoes > 0){
                mens = "Este Grupo faz parte do Plano de Teste de " + quantAvaliacoes + " avaliações já cadastradas no SNCI, portanto, sua exclusão não será permitida.";
                alert(mens);
                return false;
            }else{
                if(quantItens > 0 && quantCheckList > 0){
                    mensExc = 'A exclusão do Grupo implicará na exclusão de todos dos itens a ele vinculados. O Grupo e os itens serão eliminados dos Planos de Testes.\n\nDeseja continuar?'            
                }else{
                    if(quantItens > 0){
                      mensExc = 'O item será excluído do Plano de Teste do tipo de unidade selecionada.\n\nDeseja continuar?'            
                    }else{
                      mensExc = 'Confirma a exclusão deste grupo?'            
                    }
                }
                if(window.confirm(mensExc)){
                    frm.acao.value = 'excluirGrupo';
                    aguarde();
                    setTimeout('document.getElementById("formAltGrupo").submit();',2000);	
                    return true;
                }else{
                    return false;
                }          
            }
        }    
    </script>

    <body id="main_body" style="background:#fff"  >
        
            <form id="formAltGrupo" nome="formAltGrupo" enctype="multipart/form-data" method="post" >
                <input type="hidden" value="" id="acao" name="acao">   
                <div align="left" style="margin-left:100px;margin-left:140px">
                    <div align="left" style="padding:10px;border:1px solid #fff;width:523px;">
                        <div align="left">
								<span class="tituloDivAltGrupo" >Filtro</span>
						</div>
                        <div style="margin-bottom:10px;float: left;">
                            <label  for="selAltGrupoAno" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                            ANO:</label>
                            <br>
                            <select name="selAltGrupoAno" id="selAltGrupoAno" class="form" style="display:inline-block;background:#c5d4ea"
                            onchange="aguarde(); setTimeout('javascript:formAltGrupo.submit();',2000)">										
                                <option selected="selected" value=""></option>
                                    <cfoutput query="rsAnoGrupo">
                                        <option <cfif isDefined("form.selAltGrupoAno") and '#form.selAltGrupoAno#' eq "#Grp_Ano#">selected</cfif> value="#Grp_Ano#">#Grp_Ano#</option>
                                    </cfoutput>
                                
                            </select>		
                        </div>

                        <div style="margin-bottom:10px;">
                            <label  for="selAltGrupo" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                            GRUPO:</label>
                            <br>
                            <select name="selAltGrupo" id="selAltGrupo"  class="form" style="display:inline-block;width:443px;background:#c5d4ea"
                                    onchange="aguarde(); setTimeout('javascript:formAltGrupo.submit();',2000)">										 
                                <option selected="selected" value=""></option>
                                <cfif isDefined("form.selAltGrupoAno") and '#form.selAltGrupoAno#' neq ''>  
                                    <cfoutput query="rsGrupo">
                                        <option <cfif isDefined("form.selAltGrupo") and '#form.selAltGrupo#' eq "#Grp_Codigo#">selected</cfif>  value="#Grp_Codigo#">#Grp_Codigo# - #Grp_Descricao#</option>
                                    </cfoutput>
                                </cfif>
                            </select>              		
                        </div> 
                        
                    </div> 
                      
                    <cfif isDefined("form.selAltGrupo") and "#form.selAltGrupo#" neq ''>

                        <div align="left" style="padding:10px;border:1px solid #fff;width:523px;margin-top:30px">
                            <div align="left">
                                    <span class="tituloDivAltGrupo" >Informações disponíveis para alteração</span>
                            </div>
                                
                                <div  style="margin-bottom:10px;">
                                    <label  for="altGrupoDescricao" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                    DESCRIÇÃO:</label>	
                                    <br>
                                    <textarea  name="altGrupoDescricao" id="altGrupoDescricao" onkeyup="this.value = this.value.toUpperCase();" style="background:#fff;width:500px;" cols="50" rows="2" class="form" style="font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsGrupoSelecionado.Grp_Descricao#</cfoutput></textarea>		
                                </div>	

                                <div align="center">
                                    <a type="button" onClick="return valida_formAltGrupo()" href="#" class="botaoCad" style="background:blue;color:#fff;font-size:12px;">
                                    Alterar</a> 
                                    <a type="button" onClick="return valida_formExcGrupo()" href="#" class="botaoCad" style="margin-left:100px;background:red;color:#fff;font-size:12px;">
                                    Excluir este Grupo</a>   
                                    <a type="button" onClick="javascript:if(confirm('Deseja cancelar as alterações realizadas?\n\nObs.: Esta ação não cancela as alterações já confirmadas.\n\nCaso afirmativo, clique em OK.')){window.open('cadastroGruposItens.cfm','_self')}" href="#" class="botaoCad" style="margin-left:50px;background:red;color:#fff;font-size:12px;">
                                    Cancelar</a>
                                </div> 
                         </div> 
  
                    </cfif>
               
                
            </form>


        </div>
    </body>
</html>