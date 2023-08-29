<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">
function valida_form() {
  var frm = document.forms[0];
  if (frm.ckTipo[0].checked){
    if (frm.dtinic.value==''){
	  alert('Informe a data inicial!');
	  frm.dtinic.focus();
	  return false;
	}
	if (frm.dtfim.value==''){
	  alert('Informe a data final!');
	  frm.dtfim.focus();
	  return false;
	}
  } else {
    if (frm.txtNum_Inspecao.value==''){
	  alert('Informe o Número da Auditoria!');
	  frm.txtNum_Inspecao.focus();
	  return false;
	}
  }
  return true;
}

function desabilita_campos(){
  var frm = document.forms[0];
  if (frm.ckTipo[0].checked){
	frm.txtNum_Inspecao.value='';
	frm.txtNum_Inspecao.disabled=true;
	frm.dtinic.disabled=false;
	frm.dtfim.disabled=false;
	frm.dtinic.focus();
  }
  if (frm.ckTipo[1].checked){
	frm.dtinic.value='';
	frm.dtinic.disabled=true;
	frm.dtfim.value='';
	frm.dtfim.disabled=true;
	frm.txtNum_Inspecao.disabled=false;
	frm.txtNum_Inspecao.focus();
  }
}

//================
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
<br><br><br>
<body onLoad="desabilita_campos()" onFocus="desabilita_campos()">
<cfinclude template="cabecalho.cfm">
<p align="center" class="titulo1"><strong>Verifica&Ccedil;&Atilde;o das Respostas </strong></p>

<!--- Área de conteúdo   --->
	<form action="itens_inspetores_controle_respostas2.cfm" method="get" target="_blank" name="frmObjeto" onSubmit="return valida_form()">
      <table width="423" align="center">
      <tr>
        <td width="106"><span class="exibir"><strong>Pesquisa por: </strong></span></td>
        <td width="112" class="exibir"><strong>
          <input name="ckTipo" type="radio" value="periodo" onClick="desabilita_campos()">
        Per&iacute;odo</strong></td>
        <td width="189"><strong>
          <input name="ckTipo" type="radio" value="inspecao" checked onClick="desabilita_campos()">
        </strong><strong class="exibir">N&uacute;mero da inspe&ccedil;&atilde;o</strong></td>
      </tr>
	  <tr>
        <td width="106">&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
	  </tr>
	  <tr>
        <td width="106"><div id="dDtInicio" class="exibir"><strong>Data Inicial:</strong></div></td>
        <td><input name="dtinic" type="text" class="form" id="dtinic" tabindex="1" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="12" maxlength="10">        </td>
        <td><strong><div id="dNInsp" class="exibir">Digite o n&uacute;mero da inspe&ccedil;&atilde;o: </div></strong></td>
	  </tr>
      <tr>
       <td><div id="dDtFinal" class="exibir"><strong>Data Final:</strong></div></td>
        <td><input name="dtfim" type="text" class="form" id="dtfim" tabindex="2" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)"  size="12" maxlength="10"></td>
        <td><input name="txtNum_Inspecao" type="text" size="12" maxlength="10" tabindex="3" class="form"></td>
      </tr>
	  <tr>
       <td colspan="3">&nbsp;</td>
        </tr>
      <tr>
      <td>&nbsp;      </td>
      <td colspan="2"><input name="Submit2" type="submit" class="botao" value="Confirmar"></td>
      </tr>
      </table>
</form>
</body>
</html>
