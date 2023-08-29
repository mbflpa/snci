<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="CSS.css" rel="stylesheet" type="text/css"><style type="text/css">

.style1 {
	font-size: 14px;
	font-weight: bold;
}
</style>
</head>
<body>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT Usu_DR FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfparam name="PageNum_qNoticias" default="1">
<cfquery datasource="#dsn_inspecao#" name="qReop">     
    SELECT Rep_Codigo, Rep_CodDiretoria, Rep_Nome, Rep_Status, Rep_DtUltAtu, Rep_Email 
	FROM Reops where Rep_CodDiretoria = '#qUsuario.Usu_DR#'
	ORDER BY Rep_Status, Rep_Nome
</cfquery>

<cfset MaxRows_qNoticias=15>
<cfset StartRow_qNoticias=Min((PageNum_qNoticias-1)*MaxRows_qNoticias+1,Max(qReop.RecordCount,1))>
<cfset EndRow_qNoticias=Min(StartRow_qNoticias+MaxRows_qNoticias-1,qReop.RecordCount)>
<cfset TotalPages_qNoticias=Ceiling(qReop.RecordCount/MaxRows_qNoticias)>
<cfset QueryString_qNoticias=Iif(CGI.QUERY_STRING NEQ "",DE("&"&XMLFormat(CGI.QUERY_STRING)),DE(""))>
<cfset tempPos=ListContainsNoCase(QueryString_qNoticias,"PageNum_qNoticias=","&")>

<cfif tempPos NEQ 0>
  <cfset QueryString_qNoticias=ListDeleteAt(QueryString_qNoticias,tempPos,"&")>
</cfif>


<br>
<table width="57%" border="0" class="exibir" align="center">
  <tr>
    <td colspan="10" class="titulo1"><div align="center">&Oacute;rg&Atilde;o Subordinador </div></td>
  </tr>  
  <tr>
    <td colspan="10">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="10">&nbsp;</td>
  </tr>
  <br>
  <tr>
    <td colspan="3"><div align="center"><span class="titulos">C&oacute;digo</span></div></td>
    <td width="22"><div align="center"><span class="titulos">DR</span></div></td>
    <td width="200"><div align="center"><span class="titulos">Nome</span></div></td>
    <td width="197"><div align="center"><span class="titulos">Email &Oacute;rg&atilde;o Subordinador</span></div></td>
    <td colspan="3"><div align="center"><span class="titulos">Sit.</span></div></td>
    <td width="67">&nbsp;</td>
  </tr>
  
  <cfoutput query="qReop" startrow="#StartRow_qNoticias#" maxrows="#MaxRows_qNoticias#">
  <tr>
    <td width="14">&nbsp;&nbsp;&nbsp;</td>   
    <td width="25">
      <div align="center">
        <input type="text" name="txtCodigo"  align="middle" size="5" maxlength="10" class="form" id="txtCodigo" value="#Rep_Codigo#" readonly="">
      </div></td>
    <td colspan="2"><div align="center">
      <input type="text" name="txtdr" align="middle" size="5" maxlength="10" class="form" id="DR" value="#Rep_CodDiretoria#" readonly="">
    </div></td>
    <td><input type="text" name="txtNome" size="40" maxlength="60" class="form" id="Nome" value="#Rep_Nome#" readonly=""></td>
    <td colspan="3"><input type="text" name="txtEmailReop" size="40" maxlength="60" class="form" id="txtEmailReop" value="#Rep_Email#" readonly=""></td>
    <td width="19">        
        <div align="center">
          <input type="text"  align="center" name="txtStatus" size="3" maxlength="7" class="form" id="txtStatus" value="#Rep_Status#" readonly="">      
        </div></td>
	<form name="form1" action="alterar_dados_reop.cfm" method="post">
		  <td>
		     <input type="hidden" value="#Rep_Codigo#" name="codigo">
		     <input type="submit" name="Alterar" value="Alterar" class="botao">		
          </td>
   </form>    
   </tr>  
 </cfoutput>    
  <tr>
    <td colspan="10"><div align="center">
      <label><strong>Situa&ccedil;&atilde;o: &nbsp;&nbsp;&nbsp; A - Ativado &nbsp;&nbsp; D - Desativado</strong></label>
    </div></td>
  </tr>
  <tr>
    <td colspan="10">&nbsp;</td>
  </tr>
   <cfoutput>
		<tr>
		  <td></td>
		  <td colspan="8" align="center">
		    <cfif PageNum_qNoticias GT 1>
			  <a href="#CurrentPage#?PageNum_qNoticias=1#QueryString_qNoticias#"><span class="titulosclaro">Primeiro</span></a>
			&nbsp;&nbsp;
			</cfif>
		    <cfif PageNum_qNoticias GT 1>
			  <a href="#CurrentPage#?PageNum_qNoticias=#Max(DecrementValue(PageNum_qNoticias),1)##QueryString_qNoticias#"><span class="titulosclaro">Anterior</span></a>
			&nbsp;&nbsp;
			</cfif>
		    <cfif PageNum_qNoticias LT TotalPages_qNoticias>
			  <a href="#CurrentPage#?PageNum_qNoticias=#Min(IncrementValue(PageNum_qNoticias),TotalPages_qNoticias)##QueryString_qNoticias#"><span class="titulosclaro">Próximo</span></a>
			&nbsp;&nbsp;
			</cfif>
		    <cfif PageNum_qNoticias LT TotalPages_qNoticias>
			  <a href="#CurrentPage#?PageNum_qNoticias=#TotalPages_qNoticias##QueryString_qNoticias#"><span class="titulosclaro">Último</span></a>
			</cfif>
		  </td>
		  <td>&nbsp;</td>
		</tr>
  </cfoutput>
   <tr>
     <td colspan="10">&nbsp;</td>
   </tr>
  <tr>
    <td colspan="10">        
        <div align="center">
          <input type="submit" name="Adicionar" value="Cadastrar Novo Órgão Subordinador" class="botao" onClick="window.open('Adicionar_reop.cfm?','_self')"">
     </div></td>
  </tr>
</table>
<!---<input type="hidden" name="MM_UpdateRecord" value="frm_area">--->
</body>
</html>
