
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
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
<body onLoad="document.frmObjeto.NumInsp.focus();">
<cfinclude template="valida.cfm">
<cfinclude template="cabecalho.cfm">
<table width="80%" height="450" align="center">
<tr><br><br><br><br><br><br><br>
	  <td valign="baseline" align="center">
<!--- Área de conteúdo   --->
	<form action="GeraRelatorio/gerador/dsp/papeltrabalho.cfm" method="Post" name="frmObjeto" onSubmit="return valida_form(this.name)">
      <table width="80%"  align="center">
      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td colspan="3" align="center" class="titulo1">Papel de Trabalho</td>
      </tr>
	  <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
	  <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
	  <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>

      <tr>
        <td colspan="3" align="center"><span class="exibir"><strong>N&ordm; Relat&oacute;rio: </strong></span>
          <input name="id" type="text" class="form" id="id" tabindex="3" onKeyPress="numericos()" size="14" maxlength="10"></td>
       </tr>
	  <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
	  <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
         <td colspan="3" align="center"><input name="Submit2" type="submit" class="botao" value="Confirmar"></td>
      </tr>

      </table>
        </form>

<!--- Fim Área de conteúdo --->	  </td>
  </tr>
</table>
</body>
</html>