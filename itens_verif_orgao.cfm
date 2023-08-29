<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  
<cfquery name="rsSE" datasource="#dsn_inspecao#">
	select Usu_DR, Usu_Lotacao, Usu_LotacaoNome, Usu_GrupoAcesso from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfquery name="qSE" datasource="#dsn_inspecao#">
	 SELECT Dir_Codigo, Dir_Sigla FROM Diretoria ORDER BY Dir_Sigla ASC
</cfquery>
<cfoutput>
	<cfset frmdr = rsSE.Usu_DR>
	<cfset dtini = "">
	<cfset dtfim = "">
	<!--- <cfif not isDefined("Form.acao")> --->
	  <cfquery name="rsUnid" datasource="#dsn_inspecao#">
		 SELECT Und_Codigo, Und_Descricao FROM Unidades where Und_CodDiretoria = '#rsSE.Usu_DR#' order by Und_Descricao
	  </cfquery>
	<!--- </cfif> --->
	<!--- ================= --->
	<cfif isDefined("Form.acao") And (Form.acao is 'buscar')>
      <cfset dtini = #form.dtinic#>
	  <cfset dtfim = #form.dtfinal#>
	   <cfset frmdr = form.SE>
	   <cfif frmdr eq "Todas">
		   <cfquery name="rsUnid" datasource="#dsn_inspecao#">
			 SELECT Und_Codigo, Und_Descricao FROM Unidades where Und_CodDiretoria = '9999' order by Und_Descricao
		   </cfquery>
	   <cfelse>
	       <cfquery name="rsUnid" datasource="#dsn_inspecao#">
			 SELECT Und_Codigo, Und_Descricao FROM Unidades where Und_CodDiretoria = '#frmdr#' order by Und_Descricao
		   </cfquery>
	  </cfif>
	
	</cfif>
	<!--- =================== --->
</cfoutput>
<script language="JavaScript">

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
function desab_unidade(x){
		var frm = document.forms[0];
		frm.unidade.selectedIndex = 0;
		frm.unidade.disabled=true;
}
</script>

<script type="text/javascript">
//Validação de campos vazios em formulário
function valida_form(form) {
 // inicio críticas para o botão Salvar manifestação
  if (document.form1.acao.value == 'Confirma')
  {
 // alert(document.form1.acao.value);
      var dtinicdig = document.form1.dtinic.value;
	  var dtfinaldig = document.form1.dtfinal.value;
//alert(dtinicdig);
//return false;	  
	  if (dtinicdig.length != 10 || dtfinaldig.length != 10)
	  {
		alert('Preencher campo: Data Inicial: ou Data Final: ex. DD/MM/AAAA');
		return false;
	  }

		 //alert(a);
		 var diaini = dtinicdig.substr(0,2);
		 var mesini = dtinicdig.substr(3,2);
		 var anoini = dtinicdig.substr(6,10);
		 var diafim = dtfinaldig.substr(0,2);
		 var mesfim = dtfinaldig.substr(3,2);
		 var anofim = dtfinaldig.substr(6,10);
		 
		 var dtinicdig_aaaammdd = anoini + mesini + diaini
		 var dtfinaldig_aaaammdd = anofim + mesfim + diafim

		 if (dtinicdig_aaaammdd > dtfinaldig_aaaammdd)
		 {
		  alert("Data Inicial é maior que a Data Final!")
		  //dtprazo(sit);
		  return false;
		 }
		// document.form1.acao.value = 'SIM';
		// alert(document.form1.acao.value);
		document.form1.unidade.disabled=false;
		 document.form1.action = 'itens_verif_orgao_action.cfm';
		 document.form1.submit();
  }	  
}
</script>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="form1.dtinic.focus()"><br>
<cfif isDefined("Form.acao")>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <cfinclude template="cabecalho.cfm">
    </table>
	<table width="100%" height="30%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr valign="top">
   <td width="25%">
   <cfinclude template="menu_sins.cfm">
   </td>
   <td align="center" valign="top">
   <br><br><br>
</cfif>

<p align="center" class="titulo1"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>PONTOS DE CONTROLE INTERNO</strong></font></p>
</p>
<form name="form1" id="form1" method="Post" onSubmit="return valida_form()" action="itens_verif_orgao.cfm" target="_self">
  <table width="481" align="center">
  <cfif isDefined("Form.acao")>
   <tr valign="top">
   <td width="25%">
 
	
  </cfif>
    <tr>
      <td width="127"><span class="exibir"><strong>Data Inicial:</strong></span></td>
      <td width="224">
	  <input name="dtinic" type="text" vazio="false" nome="Data Inicial" tabindex="1" size="14" maxlength="10" class="form" onKeyDown="Mascara_Data(this)" onKeyPress="numericos()" value="<cfoutput>#dtini#</cfoutput>"></td>
    </tr>
    <tr>
      <td><span class="exibir"><strong>Data Final:</strong></span></td>
      <td><input name="dtfinal" type="text" tabindex="2" size="14" vazio="false" nome="Data Final" maxlength="10" class="form" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" value="<cfoutput>#dtfim#</cfoutput>"></td>
    </tr>
	<tr>
	  <td class="exibir"><strong>Superintend&ecirc;ncia:</strong></td>
	  <td><select name="SE" id="SE" class="form" tabindex="3" onChange="if (this.value == 'Todas') {desab_unidade('Todas')} else {document.form1.acao.value = 'buscar'; document.form1.submit()}">
        <option selected="selected" value="Todas">Todas</option>
        <cfoutput query="qSE">
		 <option value="#Dir_Codigo#" <cfif #Dir_Codigo# is #frmdr#>selected</cfif>>#Dir_Sigla#</option>
        </cfoutput>
      </select></td>
    </tr>
	 <tr>
	  <td class="exibir"><strong>Unidade:</strong></td>
      <td><select name="unidade" class="form">
	  <option selected="selected" value="Todas">Todas</option>
	  <cfoutput query="rsUnid">
	  <option value="#Und_Codigo#">#Und_descricao#</option>
      </cfoutput>
	    </select></td>
    </tr> 
	<tr>
	  <td colspan="2" class="exibir">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><input name="Submit2" type="submit" class="botao" value="Confirmar" onClick="document.form1.acao.value = 'Confirma'"></td>
    </tr>
 </table>
  <cfif isDefined("Form.acao")>
  </td>
	   </tr>
   </table>
  </cfif>
  <input type="hidden" id="acao" name="acao" value="">
  </form>
</body>
</html>