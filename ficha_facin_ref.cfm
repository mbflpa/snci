<cfprocessingdirective pageEncoding ="utf-8"/> 
<cfparam name = "numinsp" default = ''> 
<!---
<cfparam name = "grpitem" default = ''> 
<cfparam name = "acao" default = ''> 
--->
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_Matricula,Usu_GrupoAcesso 
	from usuarios 
	where Usu_login = '#cgi.REMOTE_USER#'
</cfquery>
<cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>
<cfoutput>
	<!--- ================= --->
	<cfif isDefined("url.acao") And (url.acao is 'buscar') and len(trim(url.numinsp)) eq 10>
		<cfquery datasource="#dsn_inspecao#" name="rsIncluir">
			SELECT  RIP_NumGrupo,RIP_NumItem,Fun_Nome
			FROM Resultado_Inspecao 
			INNER JOIN Inspecao ON (RIP_Unidade = INP_Unidade) AND (RIP_NumInspecao = INP_NumInspecao) 
			INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
			left JOIN UN_Ficha_Facin_Avaliador ON (RIP_Unidade = FACA_Unidade) AND (RIP_NumInspecao = FACA_Avaliacao) and (RIP_NumGrupo=FACA_grupo) and (RIP_NumItem=FACA_Item)
			WHERE RIP_NumInspecao = convert(varchar,'#url.numinsp#') and RIP_Resposta <> 'A' and FACA_Avaliacao is null
			<cfif grpacesso eq 'INSPETORES'>
				AND RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
			</cfif>
			order by RIP_NumGrupo, RIP_NumItem
		</cfquery>	
		<cfquery datasource="#dsn_inspecao#" name="rsalter">
			SELECT  RIP_NumGrupo,RIP_NumItem,Fun_Nome
			FROM Resultado_Inspecao 
			INNER JOIN Inspecao ON (RIP_Unidade = INP_Unidade) AND (RIP_NumInspecao = INP_NumInspecao) 
			INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
			INNER JOIN UN_Ficha_Facin_Avaliador ON (RIP_Unidade = FACA_Unidade) AND (RIP_NumInspecao = FACA_Avaliacao) and (RIP_NumGrupo=FACA_grupo) and (RIP_NumItem=FACA_Item)
			WHERE RIP_NumInspecao = convert(varchar,'#url.numinsp#') and RIP_Resposta <> 'A' and FACA_Matricula = '#qAcesso.Usu_Matricula#'
			<cfif grpacesso eq 'INSPETORES'>
				AND RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
			</cfif>
			order by RIP_NumGrupo, RIP_NumItem
		</cfquery>
	<cfelse>
	<!--- 	<cfset url.acao = ''> --->
	</cfif>


	<!--- =================== --->
</cfoutput>

<script language="JavaScript">

function numericos() {
var tecla = window.event.keyCode;
//permite digitar das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
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
</script>

<script type="text/javascript">
//Validação de campos vazios em formulario
function valida_form() {
	var numinsp = document.form1.numinsp.value;
	if (numinsp.length != 10) {
		document.form1.numinsp.focus();
		return false;
	}
 // inicio criticas para o bot�o Salvar manifestaçao
  if (document.form1.acao.value != '')
  {
	document.formx.numinsp.value = numinsp;
	//document.formx.grpitem.value = document.form1.grpitem.value;
	document.formx.acao.value = document.form1.acao.value;
    document.formx.submit();
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
<cfif grpacesso neq 'INSPETORES'>
	<cfif isDefined("url.acao") and url.acao eq 'buscar'>
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
</cfif> 

<p align="center" class="titulo1"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Ficha Avaliação do Controle Interno (FACIN)</strong></font></p>
</p>
<form name="form1" id="form1" method="get" onSubmit="return valida_form()" action="ficha_facin_ref.cfm" target="_self">
  <table width="481" align="center">
    <tr>
      <td>
		<span class="exibir"><strong>Nº Avaliação:</strong></span>&nbsp;&nbsp;<input id="numinsp" name="numinsp" type="text" vazio="false" size="14" maxlength="10" class="form" onKeyPress="numericos()" value="<cfoutput>#numinsp#</cfoutput>" onChange="if (this != '') {document.form1.acao.value = 'buscar'; document.form1.submit()};">
	  </td>
	  <td>
		<input name="buscar" type="button" class="botao" value="Buscar Grupo/Item" align="center">
	</td>
    </tr>

	<tr>

	</tr>
	<cfif isDefined("acao")>
		<tr>
			<td></td>
		</tr>
		<tr>
			<td></td>
		</tr>
		<tr>
			<td colspan="3"><hr></td>
		</tr>
		<tr>
			<td colspan="3" class="exibir" align="left"><strong>Grupo/Item</strong></td>
		</tr>

		<tr>
			<td class="exibir"><strong>Incluir</strong></td>
			<td class="exibir"><strong>Alterar</strong></td>
		</tr>
		<tr>
			<td colspan="3"><hr></td>
		</tr>
		<tr>
			<td></td>
		</tr>
		<tr>
			<td></td>
		</tr>
		<tr>
			<td>
				<select name="grpitem" id="grpitem" class="form">
					<cfoutput query="rsIncluir">
						<cfset grpitm = RIP_NumGrupo & ',' & RIP_NumItem>
						<cfset nomegrpitm = RIP_NumGrupo & '_' & RIP_NumItem & ' - ' & trim(Fun_Nome)>
						<option value="#grpitm#">#nomegrpitm#</option>
					</cfoutput>
				</select>
			</td>

			<td>
				<select name="grpitem2" id="grpitem2" class="form">
					<cfoutput query="rsalter">
						<cfset grpitm = RIP_NumGrupo & ',' & RIP_NumItem>
						<cfset nomegrpitm = RIP_NumGrupo & '_' & RIP_NumItem& ' - ' & trim(Fun_Nome)>
						<option value="#grpitm#">#nomegrpitm#</option>
					</cfoutput>
				</select>
			</td>

		</tr>	  
<cfset btninc = ''>
<cfset btnalt = ''>
<cfif rsIncluir.recordcount lte 0>
	<cfset btninc = 'disabled'>
</cfif>
<cfif rsalter.recordcount lte 0>
	<cfset btnalt = 'disabled'>
</cfif>
<tr>
	<td></td>
</tr>
<tr>
	<td></td>
</tr>
<tr>
	<td></td>
</tr>
		<tr>
			<td><input name="Submit1" type="button" class="botao" value="Incluir (FACIN)" onClick="document.form1.acao.value = 'inc';document.formx.grpitem.value = document.form1.grpitem.value;valida_form();" <cfoutput>#btninc#</cfoutput>></td>
			<td><input name="Submit2" type="button" class="botao" value="Alterar (FACIN)" onClick="document.form1.acao.value = 'alt';document.formx.grpitem.value = document.form1.grpitem2.value;valida_form();" <cfoutput>#btnalt#</cfoutput>></td>
		</tr>
	</cfif>
	<tr>
	  <td colspan="2" class="exibir">&nbsp;</td>
    </tr>


 </table>
   <input type="hidden" id="acao" name="acao" value="">
  </form>
  <form name="formx" method="post" action="ficha_facin.cfm" target="_self">
	<input type="hidden" id="numinsp" name="numinsp" value="">
	<input type="hidden" id="grpitem" name="grpitem" value="">
	<input type="hidden" id="acao" name="acao" value="">
  </form>
</body>
</html>