<script language="javascript">
function confirmThis(message) 
{
	if(confirm(message)) return true;
	return false;
}
</script>

<cfquery name="qVisualiza" datasource="#dsn_inspecao#">
SELECT Ars_Codigo, Ars_Sigla, Ars_Descricao, Ars_Status, Ars_Email, Ars_EmailCoordenador  
FROM Areas
WHERE Ars_Codigo = '#form.Codigo#'
</cfquery>


<html>
<head><br><br>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<cfinclude template="cabecalho.cfm">
<link href="CSS.css" rel="stylesheet" type="text/css">
<STYLE type="text/css">
<!--
BODY {

scrollbar-face-color:#003063; <!--Cor da barra de rolagem-->
scrollbar-shadow-color: #003063;    
scrollbar-highlight-color:#FFFFFF; <!-- Barra Interna-->
scrollbar-3dlight-color: #FFFFFF;
scrollbar-darkshadow-color: #003063;
scrollbar-arrow-color: #FFFFFF; <!-- Cor da Seta-->

}
-->
</STYLE>

</head>
<script language="JavaScript">
  function menu(meuLayer,minhaImg) {
  	if (meuLayer.style.display=="none") {
  		meuLayer.style.display=""; 
  	}
  	else {
  	  meuLayer.style.display="none";	
  	}
  }
</script>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="JavaScript" type="text/JavaScript">
<!--
function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
MM_reloadPage(true);
//-->
</script>
<link href="css/CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	margin-left: 0px;
	margin-top: 0px;
	background-color: #FFFFFF;
	background-image:   url("Templates/Back.jpg");
}
.style5 {
	font-size: 12px;
	font-weight: bold;
}
-->
</style>
<body onLoad="<cfoutput>#evento#</cfoutput>" text="#FFFFFF" link="#FFFFFF" vlink="#FFFFFF" alink="#FFFFFF" class="link1">
<div align="center"></div>
<TABLE width="780" border="0" cellpadding="0" cellspacing="0" class="exibir">
  <tr align="center" valign="top">
    <td width="20%" rowspan="2" align="left" valign="top">&nbsp;</td>
    <td width="80%" align="left" valign="top" class="link1 style5">&nbsp;</td>
  </tr>
  <tr valign="top">
    <td height="19" align="left" valign="bottom" class="link1">&nbsp;&nbsp;<a href="principal.cfm" class="link1">P&aacute;gina Inicial</a></td>
  </tr>
  <tr valign="top">
    <td rowspan="2" class="link1">
  <!---    <cfinclude template="menu.cfm"> --->      
    </td>
    <td height="43" align="left" class="link1">
	
	

 <table width="100%"  border="0" class="exibir">
  <tr>
    <td colspan="4"><div align="center" class="titulo1">&Aacute;reas</div></td>
  </tr>

<form method="post" name="alterar_dados_area.cfm" action="alterar_area_acao.cfm"> 
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="21%">&nbsp;</td>
      <td width="79%">&nbsp;</td>
    </tr>
    <tr>
      <td class="style3"><label><strong>C&oacute;digo:</strong></label>&nbsp;</td>
      <td><input name="codigo" type="text" class="form" id="codigo" value="<cfoutput>#qVisualiza.Ars_Codigo#</cfoutput>" size="15" maxlength="12" readonly="yes";></td>
    </tr>
    <tr>
      <td><span class="style3">
        <label><strong>Sigla:</strong></label>
      </span></td>
      <td><input name="sigla" type="text" class="form"  id="sigla" size="25" value="<cfoutput>#qVisualiza.Ars_Sigla#</cfoutput>"></td>
    </tr>
	<tr>
	  <td><span class="style3">
	    <label><strong>Descri&ccedil;&atilde;o:</strong> </label></span></td>	
	  <td><input name="descricao" type="text" class="form" size="60" value="<cfoutput>#qVisualiza.Ars_Descricao#</cfoutput>"></td>
	</tr>
	<tr>
	  <td><span class="style3">
	    <label><strong>Situa&ccedil;&atilde;o:</strong></label>
	  </span></td>	
	  <td><input name="status" type="text" class="form" size="10" value="<cfoutput>#qVisualiza.Ars_Status#</cfoutput>"></td>
	</tr>
	<tr>
	  <td><span class="style3">
	    <label><strong>Email &Aacute;rea:</strong></label>
	  </span></td>	
	  <td><input name="email" type="text" class="form" size="60" value="<cfoutput>#qVisualiza.Ars_Email#</cfoutput>"></td>
	</tr>
	<tr>
	  <td><span class="style3">
	    <label><strong>Email Coordenador:</strong></label>
	  </span></td>	
	  <td><input name="emailCoordenador" type="text" class="form" size="60" value="<cfoutput>#qVisualiza.Ars_EmailCoordenador#</cfoutput>"></td>
	</tr>	
	<tr>
	   <td colspan="2"></td>
	</tr>
	<tr>
	   <td colspan="2"></td>
	</tr>
	<tr>
	  <td colspan="4">&nbsp;</td>
	  </tr>
	<tr>
		<td colspan="4" class="style3"><div align="center">
		  <label><strong>Situa&ccedil;&atilde;o: &nbsp;&nbsp;&nbsp; A - Ativado &nbsp;&nbsp; D - Desativado</strong></label> 
		  </div></td>
	</tr>
	<tr>
	  <td>&nbsp;</td>
	  <td colspan="3">&nbsp;</td>
	  </tr>
	<tr>
	  <td>&nbsp;
	  </td>    
	  <td colspan="3">      	  
	     <input name="cancelar" class="botao" type="button" value="Voltar" onClick="history.back()">&nbsp;&nbsp;
	     <input name="alterar" type="submit" class="botao" id="alterar" value="Confirmar" align="center">   
	  </td>        
    </tr>
	<br>
</form>
	<tr>
	   <td colspan="4">&nbsp;</td>
	</tr>
	
</table>
  <p>&nbsp;  </p>

</td>
  </tr>
  <tr valign="top">
    <td align="left" class="link1">&nbsp;</td>
  </tr>
</TABLE>

</body>
</html>