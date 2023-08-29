<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<script language="javascript">
//Validação de campos vazios em formulário
function valida_form(form) {
 var frm = document.forms[form];
 var quant = frm.elements.length;
 for (var i=0; i<quant; i++) {
   var elemento = document.forms[form].elements[i];
   if (elemento.getAttribute('vazio') == 'false') {
	 if (elemento.value == '') {
	   var nome = elemento.getAttribute('nome');
	   alert('Informe o campo ' + nome + '!');
	   elemento.focus();
	   return false;
	   break;
	 }
   }
 }
}
</script>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">

</head>
<body onLoad="document.frmObjeto.dtinic.focus();">
<cfinclude template="valida.cfm">
<table width="800" height="450">
<tr>
	  <td valign="top">
<!--- Área de conteúdo   --->
	<form action="Itens_controle_respostas.cfm" method="Post"  name="frmObjeto" onSubmit="return valida_form(this.name)">
      <table width="417" align="center">
      <tr>
        <td colspan="3"><p align="center" class="titulo1"><strong>Relatorio De Verifica&ccedil;&atilde;o Mensal </strong></p>
            <p class="exibir"></td>
      </tr>
      <tr>
        <td width="122"><span class="exibir"><strong>Data da Inspe&ccedil;&atilde;o:</strong></span></td>
        <td width="223"><input name="dtinic" vazio="false" nome="Data da inspeção" class="form" id="dc" onKeyPress="event.returnValue=false" value="" size="11">
          <a href="javascript:void(0)" onClick="if(self.gfPop)gfPop.fPopCalendar(document.frmObjeto.dc);return false;"><img class="PopcalTrigger" align="absmiddle" src="calbtn.gif" width="34" height="22" border="0" alt=""></a>        </td>
    </tr>
	  <tr>
        <td><span class="exibir"><strong>N&ordm; Inspe&ccedil;&atilde;o: </strong></span></td>
        <td><input name="nu_inspecao" type="text" tabindex="2" size="12" maxlength="10" vazio="false" nome="Nº Inspeção" onKeyPress="sohNumeros();" class="form">
          <DIV align=center></DIV>        </td>
      </tr>

      <tr>
      <td>&nbsp;      </td>
      <td><input name="Submit2" type="submit" class="botao" value="Confirmar"></td>
      </tr>
      </table>
    </form>
<iframe width=174 height=189 name="gToday:normal:agenda.js" id="gToday:normal:agenda.js" src="ipopeng.cfm" scrolling="no" frameborder="0" style="visibility:visible; z-index:999; position:absolute; top:-500px; left:-500px;">
</iframe>

<!--- Fim Área de conteúdo --->
	  </td>
  </tr>
</table>
</body>
</html>