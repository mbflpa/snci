<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
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
<link href="css.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="frmObjeto.dtinic.focus()">
	<cfform action="Itens_verif_mensal.cfm" method="Post" target="_blank" name="frmObjeto">
      <table width="471" align="center">
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="2">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="2"><div align="center"><span class="titulo1"><strong>Pontos de Auditorias por per&Iacute;odo</strong></span></div></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td width="163" height="20"><div align="right"><span class="exibir"><strong>Data Inicial:</strong></span></div></td>
        <td width="296"><cfinput name="dtinic" type="text" maxlength="10" tabindex="3" size="12" required="yes" message="Data Inicial inválida (dd/mm/aaaa)" validate="eurodate" class="form" onKeyPress="numericos()" passthrough="onKeyDown='Mascara_Data(this);'">        </td>
      </tr>
      <tr>
       <td><div align="right"><span class="exibir"><strong>Data Final:</strong></span></div></td>
        <td><cfinput name="dtfinal" type="text" size="12" maxlength="10" tabindex="3" required="yes" message="Data Final inválida (dd/mm/aaaa)" validate="eurodate" class="form" onKeyPress="numericos()" passthrough="onKeyDown='Mascara_Data(this);'">        </td>
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
      <td><input name="Submit2" type="submit" class="botao" value="Confirmar"></td>
      </tr>
      </table>
    </cfform>

</body>
</html>