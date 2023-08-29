<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>


<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
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
//================
function Mascara_Data(data)
{
	switch (data.value.length)
	{
		case 2:
		   if (data.value < 1 || data.value > 31) {
		      alert('Valor para o dia inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
		case 5:
			if (data.value.substring(3,5) < 1 || data.value.substring(3,5) > 12) {
		      alert('Valor para o Mês inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
	}
}
//=============================
</script>


<cfquery name="rsReop" datasource="#dsn_inspecao#">
SELECT Rep_Codigo, Rep_Nome
FROM Reops WHERE  Rep_Status = 'A'
</cfquery>
<link href="css.css" rel="stylesheet" type="text/css">

</head>

<body>
<p align="center">
  <!--- Área de conteúdo   --->
</p>
<cfinclude template="cabecalho.cfm">
<form action="itens_unidades_controle_respostas_reop_data.cfm" method="post" target="_blank">
      <table width="85%" align="center">
      <tr>
        <td colspan="4"><p align="center" class="titulo1">&nbsp;</p>
          <p align="center" class="titulo1"><strong>PONTOS de AUDITORIA Por &Oacute;rg&Atilde;o Subordinador </strong></p>
          <p class="exibir"></td>
      </tr>
      
	 	    <tr>
	 	      <td colspan="3"><div align="left"><strong class="exibir">Pesquisando por:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<!--- <cfoutput><span class="titulo1">#form.cktipo#</span></cfoutput>---></strong></div></td>
        </tr>
	 	    <tr>
	 	      <td colspan="3">&nbsp;</td>
        </tr>
		<!---<cfif IsDefined("form.ckTipo") and form.ckTipo neq "Itens Pendentes">--->
	 	    <tr>
        <td width="166"><span class="exibir"><strong>
          <label title="label">Data Inicial:</label></strong></span></td>

        <td colspan="2"><span class="exibir">
          <input name="dtinic" type="text" vazio="false" nome="Data Inicial" tabindex="1" size="12" maxlength="10" class="form" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)">
		  
        </span></td>
        </tr>
		
      <tr>
        <td><span class="exibir"><strong>Data Final: </strong></span></td>

        <td colspan="2"><span class="exibir">
          <input name="dtfinal" type="text" tabindex="2" size="12" vazio="false" nome="Data Final" maxlength="10" class="form" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)">
        </span>        </td>
        </tr>
		<!---</cfif>--->
      <tr>
        <td><span class="exibir"><strong>&Oacute;rg&atilde;o Subordinador:</strong></span></td>

        <td colspan="2"><span class="exibir">
          <select name="reop" class="form">
            <cfoutput query="rsReop">		    	
              <option value="#Rep_Codigo#">#Rep_Nome#</option>			
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