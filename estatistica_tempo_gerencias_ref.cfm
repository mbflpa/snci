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

<link href="css.css" rel="stylesheet" type="text/css">

</head>

<body>
<p align="center">
  <!--- Área de conteúdo   --->
</p>
<form action="estatistica_tempo_gerencias.cfm" method="post">
      <table width="60%" align="center"><br><br>
        <tr>
          <td colspan="5">&nbsp;</td>
        </tr>
        <tr>
        <td colspan="5"><p align="center" class="titulo1"><strong>  <strong>tempo de solu&Ccedil;&Atilde;o por &Aacute;REAS </strong></strong></p>
            <p class="exibir"></td>
      </tr> 
	 	    
	 	 <tr>
	 	      <td colspan="4">&nbsp;</td>
        </tr>
		
	 	    <tr>
	 	      <td width="250">&nbsp;</td>
        <td width="250"><span class="exibir"><strong>
          <label title="label">Data Inicial:</label></strong></span></td>

        <td colspan="2"><span class="exibir">
          <input name="dtInic" type="text" vazio="false" nome="Data Inic" tabindex="1" size="12" maxlength="10" class="form" onKeyPress="numericos()" passthrough="onKeyDown='Mascara_Data(this);'">
		  
        </span></td>
        </tr>
		
      <tr>
        <td>&nbsp;</td>
        <td><span class="exibir"><strong>Data Final: </strong></span></td>

        <td colspan="2"><span class="exibir">
          <input name="dtFim" type="text" tabindex="2" size="12" vazio="false" nome="Data Fim" maxlength="10" class="form" onKeyPress="numericos()" passthrough="onKeyDown='Mascara_Data(this);'">
        </span>        </td>
        </tr>

      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>

      <td width="328"><input name="Submit2" type="submit" class="botao" value="Confirmar"></td>
      <td width="319">&nbsp;</td>
      </table>
</form>


</body>
</html>
