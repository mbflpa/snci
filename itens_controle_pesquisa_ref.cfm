<!--- <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> --->

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspe��es</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">
function numericos() {
var tecla = window.event.keyCode;
//permite digita��o das teclas num�ricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
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
		      alert('Valor para o dia inv�lido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
		case 5:
			if (data.value.substring(3,5) < 1 || data.value.substring(3,5) > 12) {
		      alert('Valor para o M�s inv�lido!');
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

<body onLoad="desabilita_campos()" onFocus="desabilita_campos()">
<p align="center">
  <!--- �rea de conte�do   --->
</p>
<form action="itens_controle_pesquisa.cfm" method="post" target="_blank">
      <table width="39%" align="center">
      <tr>
        <td colspan="2">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="2">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="2"><p align="center" class="titulo1"><strong>An&Aacute;lise das pesquisas  </strong></p>
            <p class="exibir"></td>
      </tr>
	 	    <tr>
	 	      <td colspan="2">&nbsp;</td>
        </tr>
		    <!--- <cfif IsDefined("form.ckTipo") and form.ckTipo neq "Itens Pendentes"> --->
            <tr>
              <td width="232"><span class="exibir"><strong>
                <label title="label">Data Inicial:</label>
              </strong></span></td>
              <td width="88"><span class="exibir">
                <input name="dtinic" type="text" vazio="false" nome="Data Inicial" tabindex="1" size="12" maxlength="10" class="form" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)">
              </span></td>
            </tr>
            <tr>
              <td><span class="exibir"><strong>Data Final: </strong></span></td>
              <td><span class="exibir">
                <input name="dtfinal" type="text" tabindex="2" size="12" vazio="false" nome="Data Final" maxlength="10" class="form" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)">
              </span> </td>
            </tr>
            <!--- 		</cfif> --->

            <tr>
              <td colspan="2">&nbsp;</td>
        <tr>
        <td>&nbsp;</td>

      <td><input name="Submit2" type="submit" class="botao" value="Confirmar"></td>
      </table>
</form>


</body>
</html>
