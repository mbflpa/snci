<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>

<link href="CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 12px}
-->
</style>

<!---<link href="CSS.css" rel="stylesheet" type="text/css"><style type="text/css">

.style1 {
	font-size: 14px;
	font-weight: bold;
}
</style>--->
</head>
<body>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT Usu_DR FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfparam name="PageNum_qNoticias" default="1">
<cfquery datasource="#dsn_inspecao#" name="qArea">
    SELECT Ars_Codigo, Ars_Sigla, Ars_Descricao, Ars_Status, Ars_Email, Ars_EmailCoordenador
	FROM Areas WHERE (Ars_Codigo Like '#qUsuario.Usu_DR#%')
	ORDER BY Ars_Status, Ars_Descricao 
</cfquery>

<cfset MaxRows_qNoticias=15>
<cfset StartRow_qNoticias=Min((PageNum_qNoticias-1)*MaxRows_qNoticias+1,Max(qArea.RecordCount,1))>
<cfset EndRow_qNoticias=Min(StartRow_qNoticias+MaxRows_qNoticias-1,qArea.RecordCount)>
<cfset TotalPages_qNoticias=Ceiling(qArea.RecordCount/MaxRows_qNoticias)>
<cfset QueryString_qNoticias=Iif(CGI.QUERY_STRING NEQ "",DE("&"&XMLFormat(CGI.QUERY_STRING)),DE(""))>
<cfset tempPos=ListContainsNoCase(QueryString_qNoticias,"PageNum_qNoticias=","&")>

<cfif tempPos NEQ 0>
  <cfset QueryString_qNoticias=ListDeleteAt(QueryString_qNoticias,tempPos,"&")>
</cfif>

<div align="center">
  <table width="67%" border="0" class="exibir">
    <br><br>
    <tr>
      <td colspan="8" class="titulo1"><div align="center">Áreas</div></td>
    </tr>
    <tr>
      <td colspan="8">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2"><div align="center"><span class="titulos">C&oacute;digo</span></div></td>
      <td width="30"><div align="center"><span class="titulos">Sigla</span></div></td>
      <td width="163"><div align="center"><span class="titulos">Descri&ccedil;&atilde;o</span></div></td>
      <td width="160"><div align="center"><span class="titulos">Email &Aacute;rea</span></div></td>
      <td width="153"><div align="center"><span class="titulos">Email Coordenador</span></div></td>
      <td width="19"><span class="titulos">Sit.</span></td>
      <td width="53">&nbsp;</td>
    </tr>

  <cfoutput query="qArea" startrow="#StartRow_qNoticias#" maxrows="#MaxRows_qNoticias#">
      <tr>
        <td width="50">
        <input type="text" name="txtCodigo" size="10" maxlength="10" class="form" id="txtCodigo" value="#Ars_Codigo#" readonly=""></td>
        <td colspan="2"><div align="center">
          <input type="text" name="sigla" size="10" maxlength="10" class="form" id="sigla" value="#Ars_Sigla#" readonly="">
        </div></td>
        <td><input type="text" name="txtDescricao" size="40" maxlength="60" class="form" id="txtDescricao" value="#Ars_Descricao#" readonly=""></td>
        <td><input type="text" name="txtEmailArea" size="25" maxlength="40" class="form" id="txtEmailArea" value="#Ars_Email#" readonly=""></td>
        <td><input type="text" name="txtEmailCoordenador" size="25" maxlength="50" class="form" id="txtEmailCoordenador" value="#Ars_EmailCoordenador#" readonly=""></td>
        <td><div align="justify">
          <input type="text" name="txtStatus" size="1" maxlength="1" class="form" id="txtStatus" value="#Ars_Status#" readonly="">
        </div></td>

		  <form name="form1" action="alterar_dados_area.cfm" method="post">
		   <td>
		     <input type="hidden" value="#Ars_Codigo#" name="codigo">
		     <input type="submit" name="Alterar" value="Alterar" class="botao">
           </td>
		  </form>

      </tr>
    </cfoutput>
    <tr>
      <td colspan="8"><div align="center">
          <label><strong>Situa&ccedil;&atilde;o: &nbsp;&nbsp;&nbsp; A - Ativado &nbsp;&nbsp; D - Desativado</strong></label>
      </div></td>
    </tr>
    <tr>
      <td colspan="8">&nbsp;</td>
    </tr>
       <cfoutput>
	      <tr>
	        <td></td>
	        <td colspan="6" align="center">
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
	        <td width="53">&nbsp;</td>
	      </tr>
        </cfoutput>
    <tr>
      <td colspan="8">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8">
          <div align="center">
            <input type="submit" name="Adicionar" value="Cadastrar Nova Área" class="botao" onClick="window.open('Adicionar_area.cfm?','_self')">
       </div></td>
    </tr>
  </table>
  <input type="hidden" name="MM_UpdateRecord" value="frm_area">
</div>
</body>
</html>
