<cfprocessingdirective pageEncoding ="utf-8">
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfif isDefined("form.formCadGrupo") >
    <cfparam name="form.acao" default="#form.acao#">
 <cfelse>
    <cfparam name="form.acao" default="">
 </cfif>


<cfset numGrupo ="">
<cfset descGrupo = ''>
<cfset sitGrupo = ''>
<cfset anoGrupo = ''>
<cfif isDefined("form.acao") and "#form.acao#" eq 'cadGrupo'>

    <cfquery datasource="#dsn_inspecao#" name="rsGrupoExiste">
        SELECT * FROM Grupos_Verificacao WHERE Grp_Descricao = '#form.cadGrupoDescricao#' AND Grp_Ano = #form.selCadGrupoAno#
    </cfquery>
    <cfif '#rsGrupoExiste.recordcount#' eq 0>
        <cfquery datasource="#dsn_inspecao#" name="rsNumGrupo">
            SELECT MAX(Grp_Codigo) as numGrupo FROM Grupos_Verificacao
        </cfquery>

        <cfif '#rsNumGrupo.numGrupo#' gt 0>
            <cfset numGrupo = '#rsNumGrupo.numGrupo#' + 1>
        <cfelse>
            <cfset numGrupo = '1'> 
        </cfif>
        <cfset gpDesc = '#ucase(form.cadGrupoDescricao)#'>
        <cfset orientacao ="Vide orientações em cada item do grupo (opção do Sistema - Ajuda a Comentário do Item)">
        <cfquery datasource="#dsn_inspecao#">
            INSERT INTO Grupos_Verificacao VALUES('#numGrupo#','#gpDesc#','#orientacao#'
                                                ,'D', CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#'
                                                , 2, #form.selCadGrupoAno#)
        </cfquery>
        <cfquery datasource="#dsn_inspecao#" name="rsGrupoCadastrado">
            SELECT * FROM Grupos_Verificacao WHERE Grp_Codigo = '#numGrupo#' and Grp_Ano = #form.selCadGrupoAno#
        </cfquery>

        <cfset numGrupo = '#rsGrupoCadastrado.Grp_Codigo#'>
        <cfset descGrupo = '#rsGrupoCadastrado.Grp_Descricao#'>
        <cfset orientGrupo = '#rsGrupoCadastrado.Grp_Orientacao#'>
        <cfset sitGrupo = '#rsGrupoCadastrado.Grp_Situacao#'>
        <cfset anoGrupo = '#rsGrupoCadastrado.Grp_Ano#'>
    <cfelse>
      <script>
        alert('Já existe um grupo cadastrado com a mesma Descrição e Ano.\n\nEsta ação foi cancelada.');
      </script>
    </cfif> 

</cfif>


<!DOCTYPE html>
<html lang="pt-BR">

    <head>
        <title>SNCI - CADASTRO DE GRUPOS E ITENS</title>
    <!--- 	<cfinclude template="cabecalho.cfm"> --->
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <link rel="stylesheet" type="text/css" href="view.css" media="all">
    </head>

    <style type="text/css">    
        .tituloDivCadGrupo{
            padding:5px;
            position:relative;
            top: -29px;
            background: #003366;
            border: 1px solid #036;

        }
    </style>

    <script language="JavaScript" type="text/JavaScript">
        
      
        function valida_formCadGrupo(){
            
            var frm = document.getElementById('formCadGrupo');
            if (frm.selCadGrupoAno.value == '') {
				alert('Informe o ano que este grupo será utilizado!');
				frm.selCadGrupoAno.focus();
				return false;
			}
            if (frm.cadGrupoDescricao.value == '') {
				alert('Informe a Descrição do Grupo!');
				frm.cadGrupoDescricao.focus();
				return false;
			}
            
            
           
            if(window.confirm('Deseja cadastrar este Grupo?')){  
                frm.acao.value = 'cadGrupo';
			    aguarde();
                setTimeout('document.getElementById("formCadGrupo").submit();',2000);
                return true;	
            }else{
                return false;
            }
        }
    </script>

    <body id="main_body" style="background:#036;"  >
        <div align="left" style="background: #036">
            <form id="formCadGrupo" nome="formCadGrupo" enctype="multipart/form-data" method="post" >
                <input type="hidden" value="" id="acao" name="acao">   
                <div align="left" style="float: left;padding:20px;border:1px solid: #036">
                    <div align="left" style="position:relative;top:-10px">
                        <span class="tituloDivAltGrupo">Cadastrar Grupo</span>
                    </div> 
                    <div style="margin-bottom:10px;">
						<label  for="selCadGrupoAno" style="color:#036;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">ANO:</label>
						<br>
                        <select name="selCadGrupoAno" id="selCadGrupoAno" class="form-select" onkeyup="this.value = this.value.toUpperCase();" style="display:inline-block;">										
							<cfset anoInic = year(Now())> 							
							<cfset anoFinal = anoInic + 1>
							<option selected="selected" value="">---</option>
							<cfoutput>
								<option  value="#anoFinal#">#anoFinal#</option>                                
								<option  value="#anoInic#">#anoInic#</option>
							</cfoutput>
						</select>		
					</div>
					<div style="margin-bottom:10px;">
						<label  for="cadGrupoDescricao" class="form-control">DESCRIÇÃO:</label>	
						<br>
                        <textarea  name="cadGrupoDescricao"  id="cadGrupoDescricao" style="background:#fff;text-transform: uppercase" cols="50" rows="2" wrap="VIRTUAL" class="form" style="font-family:Verdana, Arial, Helvetica, sans-serif"></textarea>		
					</div>	
             	
                    <div align="center">
						<a type="button" onclick="return valida_formCadGrupo()" href="#" class="btn btn-primary">Cadastrar</a>     
                         <a type="button" onclick="javascript:if(confirm('Deseja cancelar este cadastro?\n\nObs: Esta ação não cancela cadastros já confirmados.\n\nCaso afirmativo, clique em OK.')){window.open('cadastroGruposItens.cfm','_self')}" href="#" class="btn btn-danger">Cancelar</a>
                    </div>    
                
                </div>
                <cfif '#anoGrupo#' neq "">
                    <div align="left" style="float: left;margin-left:10px;padding:20px;border:1px solid #fff;height:199px">
                        <div align="center">
								<span class="tituloDivCadGrupo" >Grupo Cadastrado</span>
						</div>
                        <div >
                            <span >Cód. do Grupo: <cfoutput><strong>#numGrupo#</strong></cfoutput></span>
                            <br><br>
                            <span >Ano: <cfoutput><strong>#anoGrupo#</strong></cfoutput></span>	
                            <span style="margin-left:20px">Situação: <cfoutput><strong><cfif #sitGrupo# eq 'D'>Desativado<cfelse>Ativo</cfif></strong></cfoutput></span>	
                        </div>
                        <div style="margin-bottom:10px;">
                            <label  for="cadGrupoDescricao2" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">DESCRIÇÃO:</label>	
                            <br>
                            <textarea readonly  name="cadGrupoDescricao2"   id="cadGrupoDescricao2" style="background:#fff;" cols="50" rows="2" wrap="VIRTUAL" class="form" 
                            style="font-family:Verdana, Arial, Helvetica, sans-serif;"><cfoutput>#descGrupo#</cfoutput></textarea>		
                        </div>	

                    
                    </div>
                </cfif>
            </form>
        </div>
    </body>
</html>