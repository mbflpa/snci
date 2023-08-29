<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<td align="center"><cfinclude template="cabecalho.cfm"></td>

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

<cfquery name="rsPermissaoReop" datasource="#dsn_inspecao#">
	SELECT Usu_Login, Usu_Lotacao, Usu_GrupoAcesso
	FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' and Usu_GrupoAcesso = 'ORGAOSUBORDINADOR'
	ORDER BY Usu_Lotacao ASC
</cfquery>

<link href="css.css" rel="stylesheet" type="text/css">

</head>

<body>
<p align="center">
  <!--- Área de conteúdo   --->
</p>
<form action="itens_subordinador_controle_respostas_reop.cfm" method="post" target="_blank">
      <table width="85%" align="center"><br><br><br><br><br><br>
	     <tr>
	 	     <td colspan="5">&nbsp;</td>
         </tr>
      <tr>
          <td colspan="5" align="center" class="titulo1"><strong>Relatório por Unidade</strong></td>
      </tr>
	      <tr>
	 	      <td colspan="5">&nbsp;</td>
         </tr>

		<input name="reop" type="hidden" id="reop" value="<cfoutput>#rsPermissaoReop.Usu_Lotacao#</cfoutput>">
	 	    <tr>
	 	      <td colspan="5">&nbsp;</td>
           </tr>
            <tr>
              <td width="30%" colspan="2" align="right"><span class="exibir"><strong><label title="label">Data Inicial:</label></strong></span></td>
              <!--- <td>&nbsp;</td> --->
			  <td><span class="exibir">
                <input name="dtinic" type="text" vazio="false" nome="Data Inicial" tabindex="1" size="14" maxlength="10" class="form" onKeyDown="Mascara_Data(this)" onKeyPress="numericos()">
              </span></td>
			  <td>&nbsp;</td>
            </tr>
            <tr>
              <td width="30%" colspan="2" align="right"><span class="exibir"><strong>Data Final:</strong></span></td>
              <td><span class="exibir"><input name="dtfinal" type="text" tabindex="2" size="14" vazio="false" nome="Data Final" maxlength="10" class="form" onKeyDown="Mascara_Data(this)" onKeyPress="numericos()">
              </span></td>
            </tr>

      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr>
        <td align="center"><div align="right">
          <input type="button" class="botao" value="Voltar" onClick="window.open('itens_unidades_controle_respostas_reop_ref.cfm?flush=true','_self')">
&nbsp;&nbsp; </div></td>
	    <td colspan="4" align="center"><div align="left">
	       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input name="Submit2" type="submit" class="botao" value="Confirmar">
        </div></td>
	    </tr>
      </table>
</form>
</body>
</html>
