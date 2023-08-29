<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
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

<link href="css.css" rel="stylesheet" type="text/css">

</head>

<body onLoad="desabilita_campos()" onFocus="desabilita_campos()">
<p align="center">
  <!--- Área de conteúdo   --->
</p>
<form action="estatistica_itens_nao_conformes_area.cfm" method="post" target="_blank">
      <table width="60%" align="center">
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="3"><p align="center" class="titulo1"><strong>itens PENDENTES - &Aacute;REAs</strong></p>
        </td>
      </tr>
	 	    <tr>
	 	      <td colspan="3">&nbsp;</td>
        </tr>
	 	    <tr>
	 	      <td colspan="3">&nbsp;</td>
        </tr>
		    <!--- <cfif IsDefined("form.ckTipo") and form.ckTipo neq "Itens Pendentes"> --->
            <tr>
              <td width="411"><span class="exibir"><strong>
                <label title="label"> Data Inicial:</label>
              </strong></span></td>
              <td colspan="2"><span class="exibir">
                <input name="dtinic" type="text" vazio="false" nome="Data Inicial" tabindex="1" size="12" maxlength="10" class="form" onKeyPress="numericos()" passthrough="onKeyDown='Mascara_Data(this);'">
              </span></td>
            </tr>
            <tr>
              <td><span class="exibir"><strong>Data Final: </strong></span></td>
              <td colspan="2"><span class="exibir">
                <input name="dtfinal" type="text" tabindex="2" size="12" vazio="false" nome="Data Final" maxlength="10" class="form" onKeyPress="numericos()" passthrough="onKeyDown='Mascara_Data(this);'">
              </span> </td>
            </tr>
            <!--- 		</cfif> --->

      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      <tr>
        <td>&nbsp;</td>

      <td width="71"><input name="Submit2" type="submit" class="botao" value="Confirmar"></td>
      <td width="194">&nbsp;</td>
      </table>
</form>


</body>
</html>
