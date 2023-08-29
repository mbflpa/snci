<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {
	font-size: 14px;
	font-weight: bold;
}
-->
</style>
</head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<body onLoad="<cfoutput>#evento#</cfoutput>" link="#FFFFFF" vlink="#FFFFFF" alink="#FFFFFF" class="link1">

<div id="Layer1" style="position:absolute; left:11px; top:6px; width:7px; height:6px; z-index:1"></div>

<div align="center"></div>
<a name="Inicio" id="Inicio"></a>
<cfinclude template="cabecalho.cfm">

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
<div align="left"></div>
<cfform action="Alterar_datas_ref2.cfm" method="Post" name="frmObjeto" o>
  <div align="left"></div>
  <table width="80%" align="center">
  <tr>
    <td colspan="2" class="exibir"><div align="left"><span class="titulo1">ALTERAR DATAS DA INSPE&Ccedil;&Atilde;O </span></div></td>
  </tr>
  
  <tr>
    <td colspan="2">&nbsp;</td>
    </tr>
  <tr>
        <td><span class="exibir"><strong>N&ordm; Inspe&ccedil;&atilde;o: </strong></span></td>
        <td><label>
          <input type="text" name="num_insp" size="16" class="form" onKeyPress="numericos()">
        </label></td>
    </tr>
      <tr>
        <td width="27%"><span class="exibir"><strong>Data Inicial da Inspe&ccedil;&atilde;o:</strong></span></td>
        <td width="73%"><cfinput name="data_inicial" type="text" maxlength="10" tabindex="1" size="12" required="yes" message="Data Inicial inválida (dd/mm/aaaa)" validate="eurodate" class="form" onKeyPress="numericos()" passthrough="onKeyDown='Mascara_Data(this);'">        </td>
      </tr>
      <tr>
        <td><strong><span class="exibir"><strong>Data Final da Inspe&ccedil;&atilde;o:</strong></span></strong></td>
        <td><cfinput name="data_final" type="text" size="12" maxlength="10" tabindex="2" required="yes" message="Data Final inválida (dd/mm/aaaa)" validate="eurodate" class="form"  onKeyPress="numericos()" passthrough="onKeyDown='Mascara_Data(this);'"></td>
      </tr>
      
      <tr>
      <td height="29">&nbsp;      </td>
      <td><input name="Submit2" type="submit" class="botao"  value="Confirmar"></td>
      </tr>
  </table>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
</cfform>

</body>
</html>