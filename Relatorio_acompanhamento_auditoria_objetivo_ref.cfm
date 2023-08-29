<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfquery name="qtipo" datasource="#dsn_inspecao#">
SELECT TUN_Codigo, TUN_Descricao FROM Tipo_Unidades
WHERE TUN_Status = 'A'
ORDER BY TUN_Descricao
</cfquery>

<cfquery name="qobjetivo" datasource="#dsn_inspecao#">
SELECT Grp_Codigo FROM Grupos_Verificacao
ORDER BY Grp_Codigo
</cfquery>


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
 <form action="GeraRelatorio/gerador/dsp/relatorio_acompanhamento_objetivo.cfm" method="Post" name="frmHtml" target="_blank">
      <table width="75%" align="center"><br>
        <br>
        <tr>
          <td colspan="5">&nbsp;</td>
        </tr>
        <tr>
        <td colspan="5" align="center"><span class="titulo1"><strong>Relat&Oacute;rio de Acompanhamento por Objetivo</strong></span></td>
      </tr>	 	    
	 	 <tr>
	 	      <td colspan="5">&nbsp;</td>
        </tr>
		
	 	    <tr>
	 	      <td width="108">&nbsp;</td>
        <td width="136"><span class="exibir"><strong>
          <label title="label">Data Inicial:</label></strong></span></td>

        <td colspan="2"><span class="exibir">
          <input name="dtini"  id="dtini" type="text" vazio="false" nome="Data Inic" tabindex="1" size="12" maxlength="10" class="form" onKeyPress="numericos()"  onKeyDown="Mascara_Data(this)">          
	    </span></td>
		 <input name="ID" id="ID"  type="hidden" value="0">		
        </tr>		
      <tr>
        <td>&nbsp;</td>
        <td><span class="exibir"><strong>Data Final: </strong></span></td>

        <td colspan="2"><span class="exibir">
          <input name="dtfim"  id="dtfim" type="text" tabindex="2" size="12" vazio="false" nome="Data Fim" maxlength="10" class="form" onKeyPress="numericos()"  onKeyDown="Mascara_Data(this)">
        </span>        </td>
        </tr>

      <tr>
        <td>&nbsp;</td>
        <td><span class="exibir"><strong>Objetivo : </strong></span></td>
        <td><span class="exibir">
            <input name="objetivo" id="objetivo" type="text" size="6" maxlength="6" class="form">
        </span></td>
        <td>&nbsp;</td>
      <tr>
        <td>&nbsp;</td>
        <td><span class="exibir"><strong>Tipo de Unidade : </strong></span></td>
        <td><span class="exibir">
          <span class="exibir"><select name="tipo" class="form">
		    <option selected="selected" value="">Todos</option>
            <cfoutput query="qtipo">			
            <option value="#TUN_Codigo#">#TUN_Descricao#</option>			
            </cfoutput>
            </select></span>
        </span></td>
        <td>&nbsp;</td>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>

      <td width="176"><input name="Submit2" type="submit" class="botao" value="Confirmar"></td>
      <td width="305">&nbsp;</td>
   </table>
</form>


</body>
</html>
