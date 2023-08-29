<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="javascript">
//=============================
//permite digitaçao apenas de valores numéricos
function numericos() {
var tecla = window.event.keyCode;
//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
//if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {
	
	if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
		//alert(tecla);
	//  if () {
		event.returnValue = false;
	 // }
	}
//}
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
</head>
<body onLoad="document.frmObjeto.dtinic.focus();">
<cfinclude template="valida.cfm">
<cfinclude template="cabecalho.cfm">
<table width="780" height="450">
<tr><br><br><br><br>  
	  <td valign="baseline" align="center">
<!--- Área de conteúdo   --->
	<form action="Itens_unidades_controle_respostas.cfm" method="Post" name="frmObjeto" onSubmit="return valida_form(this.name)">     
      <table  align="center">
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="3"><p align="center" class="titulo1">Pontos de Auditoria </p>
            <p class="exibir"></td>
      </tr>
      <tr>
        <td width="2">&nbsp;</td>
        <td width="70">&nbsp;</td>
        <td width="111">&nbsp;</td>
      </tr>
   <!---<tr>
        <td width="56">&nbsp;</td>
        <td width="151"><span class="exibir"><strong>In&iacute;cio da Auditoria:</strong></span></td>
        <td width="194"><input name="dtinic" class="form" id="dc"  onKeyPress="numericos()"  onKeyDown="Mascara_Data(this)" size="12" maxlength="10" vazio="false" nome="Data da inspeção">
        </td>
    </tr>--->
	  <tr>
        <td>&nbsp;</td>
        <td><span class="exibir"><strong> Auditoria: </strong></span></td>
        <td><input name="nu_inspecao" type="text" tabindex="2" size="12" maxlength="10" vazio="false" nome="Nº Inspeção" onKeyPress="sohNumeros();" class="form">
          <DIV align=center></DIV>
        </td>
      </tr>

      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
      <td>&nbsp;
      </td>
      <td><input name="Submit2" type="submit" class="botao" value="Confirmar"></td>
      </tr>
     
      </table>
    </form>

<!--- Fim Área de conteúdo --->	  </td>
  </tr>
</table>
</body>
</html>