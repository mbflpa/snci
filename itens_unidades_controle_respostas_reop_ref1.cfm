<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>


<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">
function numericos() {
var tecla = window.event.keyCode;
//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {
	if ((tecla < 48) || (tecla > 57)) {
	//  if () {
		event.returnValue = false;
	 // }
	}
}
}
function Mascara_Data(data)
{
	switch (data.value.length)
	{
		case 2:
			data.value += "/";
			break;
		case 5:
			data.value += "/";
			break;
	}
}
</script>


<cfquery name="rsReop" datasource="#dsn_inspecao#">
  SELECT Rep_Codigo, Rep_Nome
  FROM Reops WHERE  Rep_Status = 'A'
</cfquery>
<link href="css.css" rel="stylesheet" type="text/css">

</head>

<body onLoad="desabilita_campos()" onFocus="desabilita_campos()">
<p align="center">
  <!--- Área de conteúdo   --->
</p>
<cfinclude template="cabecalho.cfm">
<form action="itens_unidades_controle_respostas_reop.cfm" method="post" target="_self">
      <table width="85%" align="center">
      <tr>
        <td colspan="4"><p align="center" class="titulo1"><strong>PONTOS de AUDITORIA Por &Oacute;rg&Atilde;o Subordinador </strong></p>
            <p class="exibir"></td>
      </tr>
	 	    <tr>
	 	      <td colspan="3">&nbsp;</td>
        </tr>
      <tr>
        <td><span class="exibir"><strong>&Oacute;rg&atilde;o Subordinador:</strong></span></td>

        <td colspan="2"><span class="exibir">
          <select name="reop" class="form">
            <cfoutput query="rsReop">
			<cfif Trim(UCASE(Rep_Nome)) is Trim(UCASE(Session.vReop))>
              <option value="#Rep_Codigo#">#Rep_Nome#</option>
			</cfif>
            </cfoutput>
          </select>
        </span><span class="exibir">
        </span></td>
        </tr>

      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      <tr>
        <td>&nbsp;</td>

      <td width="328"><input name="Submit2" type="submit" class="botao" value="Confirmar"></td>
      <td width="319">&nbsp;</td>
      </table>
</form>
</body>
</html>
 <!--- <script>
	document.forms[0].submit();
</script> --->