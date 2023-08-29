
<!--- <cfdump var="#url#">
<cfabort>  --->

<cfset evento = 'document.frm1.arquivo.focus()'>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> 

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
</head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<body text="#FFFFFF" link="#FFFFFF" vlink="#FFFFFF" alink="#FFFFFF" class="link1">

<div id="Layer1" style="position:absolute; left:11px; top:6px; width:7px; height:6px; z-index:1"></div>

<a name="Inicio" id="Inicio"></a>
<cfinclude template="cabecalho.cfm">

<form name="frm1" action="itens_inspetores_receber_anexo.cfm" enctype="multipart/form-data" method="post">

<table width="80%" border="0" align="center">
  <tr>
    <td colspan="2" class="titulo1">Envio de arquivo anexo </td>
    </tr>
  <tr>
    <td width="18%">&nbsp;</td>
    <td width="82%">&nbsp;</td>
  </tr>
  <tr>
    <td class="titulos">Arquivo:</td>
    <td><input name="arquivo" class="botao" type="file"></td>
  </tr>
  <tr>
   <td class="titulos">&nbsp;</td>
   <td>
	   <input type="hidden" name="numero_inspecao" size="16" class="form" value="<cfoutput>#url.ninsp#</cfoutput>">
	   <input type="hidden" name="numero_unidade" size="16" class="form" value="<cfoutput>#url.unid#</cfoutput>">
	   <input type="hidden" name="numero_grupo" size="16" class="form" value="<cfoutput>#url.ngrup#</cfoutput>">
	   <input type="hidden" name="numero_item" size="16" class="form" value="<cfoutput>#url.nitem#</cfoutput>">
	   <input type="hidden" name="numero_cktipo" size="16" class="form" value="<cfoutput>#url.cktipo#</cfoutput>">
	   <input type="hidden" name="numero_dtfim" size="16" class="form" value="<cfoutput>#url.dtfim#</cfoutput>">
	   <input type="hidden" name="numero_dtinic" size="16" class="form" value="<cfoutput>#url.dtinic#</cfoutput>">
	   <input type="hidden" name="numero_reop" size="16" class="form" value="<cfoutput>#url.reop#</cfoutput>">
	   <input type="hidden" name="numero_mat" size="16" class="form" value="<cfoutput>#matricula#</cfoutput>">
   </td>
  </tr> 
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><input name="confirmar" type="submit" class="botao" value="Anexar"></td>
  </tr> 
</table>
</form>
</body>
</html>