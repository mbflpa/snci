<cfprocessingdirective pageEncoding ="utf-8"> 
<cfquery name="qVisualiza" datasource="#dsn_inspecao#">
  SELECT Fun_Matric, Fun_Nome, Fun_DR, Fun_Status, Fun_Lotacao, Fun_Email  
  FROM Funcionarios
  WHERE Fun_Matric = '#form.txtmatricula#'
</cfquery>

<cfquery name="qdr" datasource ="#dsn_inspecao#">
  SELECT Dir_Codigo, Dir_Descricao FROM Diretoria WHERE Dir_Status = 'A' and Dir_Codigo = '#qVisualiza.Fun_DR#'
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
//=========================
function confirmThis(message) 
{
	if(confirm(message)) return true;
	return false;
}
//==========================
function validarform(){
//8.505.107-1
	var auxmatric = document.alterar_dados_funcionario.matricula.value;
	if (auxmatric.length != 11)
	{
		alert('Informar a matrícula com 8 dígitos ex. X.XXX.XXX-X');
		return false;
	}
	var auxnome = document.alterar_dados_funcionario.txtnome.value;
	if (auxnome.length <= 10)
	{
		alert('Informar o nome completo');
		return false;
	}
	
	if (document.alterar_dados_funcionario.dr.value == '')
	{
		alert('Informar a SE');
		return false;
	}
	
	if (document.alterar_dados_funcionario.Lotacao.value == '')
	{
		alert('Informar a Lotação');
		return false;
	}	
	
	if (document.alterar_dados_funcionario.email.value == '')
	{
		alert('Informar o e-mail');
		return false;
	}		
}
// ==============================
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
<body onLoad="" text="#FFFFFF" link="#FFFFFF" vlink="#FFFFFF" alink="#FFFFFF" class="link1">
<!--- <body onLoad="<cfoutput>#evento#</cfoutput>" text="#FFFFFF" link="#FFFFFF" vlink="#FFFFFF" alink="#FFFFFF" class="link1"> --->
<div align="center"></div>
<TABLE width="780" border="0" cellpadding="0" cellspacing="0" class="exibir">
  <tr align="center" valign="top">
    <td width="20%" rowspan="2" align="left" valign="top">&nbsp;</td>
    <td width="80%" align="left" valign="top" class="link1 style5">&nbsp;</td>
  </tr>
  <tr valign="top">
    <td height="19" align="left" valign="bottom" class="link1">&nbsp;&nbsp;<a href="principal.cfm" class="link1">Página Inicial</a></td>
  </tr>
  <tr valign="top">
    <td rowspan="2" class="link1">
  <!---    <cfinclude template="menu.cfm"> --->      
    </td>
    <td height="43" align="left" class="link1">
	
	

 <table width="100%"  border="0" class="exibir">
  <tr>
    <td colspan="4"><div align="center" class="titulo1">Funcionário</div></td>
  </tr>

<form method="post" name="alterar_dados_funcionario" onSubmit="return validarform()" action="alterar_funcionario_acao.cfm"> 
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="14%">&nbsp;</td>
      <td width="86%">&nbsp;</td>
    </tr>
    <tr>
	     <cfset mat = qVisualiza.Fun_Matric>
		 <cfset matricula = Left(mat,1) & '.' & Mid(mat,2,3) & '.' & Mid(mat,5,3) & '-' & Right(mat,1)>        
      <td class="style3"><label><strong>Matrícula:</strong></label>&nbsp;</td>
      <td><input name="matricula" type="text" class="form" value="<cfoutput>#matricula#</cfoutput>" size="14" maxlength="11" readonly="yes";></td>
    </tr>
    <tr>
      <td><span class="style3">
        <label><strong>Nome:</strong></label>
		</span></td>		
      <td><input name="txtnome" type="text" class="form"  size="52"  maxlength="50" value="<cfoutput>#trim(qVisualiza.Fun_Nome)#</cfoutput>"></td>
    </tr>
	<tr>
	  <td><span class="style3">
	    <label><strong>SE:</strong> </label>
	  </span></td>	
	  <td><cfset vdr = qVisualiza.Fun_DR>	 
	  <select name="dr" class="form">	                   
      <cfoutput query="qdr">
        <option value="#Dir_Codigo#" <cfif qdr.Dir_Codigo is vdr>selected</cfif>>#qdr.Dir_Descricao#</option>
      </cfoutput>
      </select></td>
	</tr>
	<tr>
	  <td><span class="style3">
	    <label><strong>Situação:</strong></label>
	  </span></td>	
	  <td><select name="status" class="form">
             <cfset vStatus = qVisualiza.Fun_Status>
               <option value="A" <cfif vStatus is 'A'>selected</cfif>>Ativo</option>  
               <option value="D" <cfif vStatus is 'D'>selected</cfif>>Desligado</option>
               <option value="F" <cfif vStatus is 'F'>selected</cfif>>Afastado</option>
               <option value="P" <cfif vStatus is 'P'>selected</cfif>>Aposentado</option>                        
          </select>
      </td>
	</tr>
	<tr>
	  <td><span class="style3">
	    <label><strong>Lotação:</strong></label>
      </span></td>
	  <td><input name="Lotacao" type="text" class="form"  size="32"  maxlength="30" value="<cfoutput>#trim(qVisualiza.Fun_Lotacao)#</cfoutput>"></td>
	</tr>
	<tr>
	  <td><span class="style3">
	    <label><strong>Email:</strong></label>
	  </span></td>	
	  <td><input name="email" type="text" class="form" size="60"  maxlength="50" value="<cfoutput>#trim(qVisualiza.Fun_Email)#</cfoutput>"></td>
	</tr>	
	<tr>
	   <td colspan="2"></td>
	</tr>
	<tr>
	   <td colspan="2"></td>
	</tr>
	<tr>
		<td colspan="4" class="style3"><div align="center">
		  <label></label>
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