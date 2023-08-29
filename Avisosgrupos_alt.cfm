<cfoutput> 

<cfif isDefined("form.acao") and form.acao is "alterar">
 	<cfset dtinic = CreateDate(year(now()),month(now()),day(now()))>
	<cfset dtfina = CreateDate(year(now()),month(now()),day(now()))>
	<cfset dtinic = dateformat(form.dtinic,"DD/MM/YYYY")>
	<cfset dtfina = dateformat(form.dtfim,"DD/MM/YYYY")>
	<cfquery datasource="#dsn_inspecao#">
		UPDATE AvisosGrupos SET AVGR_DT_INICIO = #createodbcdate(createdate(year(dtinic),month(dtinic),day(dtinic)))#, AVGR_DT_FINAL= #createodbcdate(createdate(year(dtfina),month(dtfina),day(dtfina)))#, AVGR_GRUPOACESSO='#form.frmgrupo#',AVGR_AVISO= '#form.frmmensagem#', AVGR_dtultatu = convert(char, getdate(), 102), AVGR_username = '#CGI.REMOTE_USER#', AVGR_TITULO = '#form.frmtitulo#'
		WHERE AVGR_ANO = '#form.frmx_ano#' AND AVGR_ID = #form.frmx_id#
	</cfquery>
	<cflocation url="index.cfm?opcao=permissao15">
</cfif> 

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena 
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfquery name="qArea" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso
FROM Usuarios
GROUP BY Usu_GrupoAcesso
HAVING (((Usu_GrupoAcesso)<>'DESENVOLVEDORES'))
</cfquery>

<cfquery name="rsalter" datasource="#dsn_inspecao#">
	SELECT AVGR_ANO, AVGR_ID, AVGR_DT_INICIO, AVGR_DT_FINAL, AVGR_GRUPOACESSO, AVGR_AVISO, AVGR_username, AVGR_dtultatu, AVGR_status, AVGR_DT_CAD, AVGR_DT_ATI, AVGR_DT_DES, AVGR_TITULO, AVGR_ANEXO, Usu_Apelido
	FROM AvisosGrupos INNER JOIN Usuarios ON AVGR_username = Usu_Login 
	WHERE AVGR_ANO = '#form.frmx_ano#' AND AVGR_ID = #form.frmx_id#
</cfquery>
</cfoutput>
<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<!--- <cfinclude template="cabecalho.cfm"> --->
<link href="CSS.css" rel="stylesheet" type="text/css">
<STYLE type="text/css">
<!--
BODY {

scrollbar-face-color:#003063; <!--Cor da barra de rolagem-->
scrollbar-shadow-color: #003063;    
scrollbar-highlight-color:#FFFFFF; <!-- Barra Interna-->
scrollbar-3dlight-color: #FFFFFF;
scrollbar-darkshadow-color: #003063;
scrollbar-arrow-color: #FFFFFF; <!-- Cor da Seta-->

}
-->
</STYLE>

</head>
<script language="JavaScript">
  function menu(meuLayer,minhaImg) {
  	if (meuLayer.style.display=="none") {
  		meuLayer.style.display=""; 
  	}
  	else {
  	  meuLayer.style.display="none";	
  	}
  }
//=============================
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
function voltar(){
    document.formvolta.submit();
 }
//========================
function valida_form() {
var frm = document.forms[0];

if (frm.dtinic.value == ''){
	  alert('Informe a Data Inicial!');
	  frm.dtinic.focus();
	  return false;
}

if (frm.dtfim.value == ''){
	  alert('Informe a Data Final!');
	  frm.dtinic.focus();
	  return false;
	}

if (frm.dtinic.value.length != 10){
	alert("Preencher campo: Data Inicial ex. DD/MM/AAAA");
	frm.dtinic.focus();
	return false;
	}
	
if (frm.dtfim.value.length != 10){
	alert("Preencher campo: Data Final ex. DD/MM/AAAA");
	frm.dtfim.focus();
	return false;
	}	

var dtini_yyyymmdd = frm.dtinic.value;
var dtfin_yyyymmdd = frm.dtfim.value;

var diai = dtini_yyyymmdd.substr(0,2);
var mesi = dtini_yyyymmdd.substr(3,2);
var anoi = dtini_yyyymmdd.substr(6,10);
var dtini_yyyymmdd = anoi + mesi + diai;



var diaf = dtfin_yyyymmdd.substr(0,2);
var mesf = dtfin_yyyymmdd.substr(3,2);
var anof = dtfin_yyyymmdd.substr(6,10);
var dtfin_yyyymmdd = anof + mesf + diaf;

//alert(dtini_yyyymmdd + ' ' + dtfin_yyyymmdd);

 if (frm.frm1dthoje.value > dtini_yyyymmdd)
 {
	alert("Data Inicial é menor que a data do dia!")
	frm.dtinic.focus();
	return false
 }
	
 if (frm.frm1dthoje.value > dtfin_yyyymmdd)
 {
	alert("Data Final é menor que a data do dia!")
	frm.dtfim.focus();
	return false
 }
 
  if (dtini_yyyymmdd > dtfin_yyyymmdd)
 {
	alert("Data Inicial é maior que a data Final!")
	frm.dtinic.focus();
	return false
 }
//==============================
var auxmesinic = Math.round(mesi);
auxmesinic--
var auxmesfina = Math.round(mesf);
auxmesfina--
 
var totfimsem = 0;
var one_day = 1000 * 60 * 60 * 24
var inicial_date = new Date(anoi, auxmesinic, diai);
var final_date = new Date(anof, auxmesfina, diaf);

var Result = Math.round(final_date.getTime() - inicial_date.getTime()) / (one_day);
var Final_Result = Result.toFixed(0);
var datavariar = inicial_date;
for (x = 0 ; x <= Final_Result ; x++)
    {
	if (datavariar.getDay() == 0 || datavariar.getDay() == 6)
	{ 
	totfimsem++
	}
	datavariar.setDate(datavariar.getDate() + 1)
	 }

if ((Final_Result - totfimsem) > 10){
	  alert('O período de vigência (Data Inicial - Data Final) não pode exceder os 10(dez) dias úteis');
	  frm.dtinic.focus();
	  return false;
}
//============================== 
if (frm.frmtitulo.value == ''){
  alert('Favor informar Titulo!');
  frm.frmtitulo.focus();
  return false;
}
if (frm.frmgrupo.value == ''){
  alert('Favor informar o Grupo de Acesso!');
  frm.frmgrupo.focus();
  return false;
}
if (frm.frmmensagem.value == ''){
  alert('Favor informar Mensagem!');
  frm.frmmensagem.focus();
  return false;
}

//return false;

}
</script>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">


<link href="css/CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	margin-left: 0px;
	margin-top: 0px;
	background-color: #FFFFFF;
	background-image:   url("Templates/Back.jpg");
}
.style5 {
	font-size: 12px;
	font-weight: bold;
}
-->
</style>
<cfinclude template="cabecalho.cfm">
<body>
<div align="center"></div>
<TABLE width="85%" border="0" align="left" cellpadding="0" cellspacing="0" class="exibir">
  <cfif isDefined("url.dtinic")>
  <tr align="center" valign="top">
      <td width="2%" align="left" valign="top">
        <cfinclude template="cabecalho.cfm">
		    </td>
    <td width="80%" align="left" valign="top" class="link1 style5">&nbsp;</td>
  </tr>
   </cfif>
<!---   <tr valign="top">
    <td height="19" align="left" valign="bottom" class="link1">&nbsp;&nbsp;<a href="principal.cfm" class="link1">P&aacute;gina Inicial</a></td>
  </tr> --->
  <tr valign="top">
    <td height="43" align="left" class="link1">
	
	

 <table width="1057"  border="0" align="left" class="exibir">
  <tr>
    <td colspan="10">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="10">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="10"><div align="center" class="titulo1">avisos - snci </div></td>
  </tr>

<cfoutput query="rsalter">
<cfset AVGRDTINICIO = dateformat(AVGR_DT_INICIO,"DD/MM/YYYY")>
<cfset AVGRDTFINAL = dateformat(AVGR_DT_FINAL,"DD/MM/YYYY")>
<cfif len(AVGR_ID) is 1>
	<cfset auxid = '000' & AVGR_ID>
<cfelseif len(AVGR_ID) is 2>
	<cfset auxid = '00' & AVGR_ID>
<cfelseif len(AVGR_ID) is 3>
	<cfset auxid = '0' & AVGR_ID>		
</cfif>
<cfset auxanoid = AVGR_ANO & '/' & auxid>

<form action="avisosgrupos_alt.cfm" method="post" target="_parent" name="frmObjeto" onSubmit="return valida_form()">
    <tr>
      <td colspan="9">&nbsp;</td>
      </tr>
    <tr>
      <td colspan="9">&nbsp;</td>
      </tr>
    <tr>
      <td class="style3"><div align="left"><strong>Ano/Num.</strong>
            </label>
  &nbsp;</div></td>
      <td width="89" class="titulos">#auxanoid#</td>
      <td width="138" class="titulos"><label> &Uacute;ltima atua. : </label></td>
      <td width="53" class="titulos">#dateformat(AVGR_dtultatu,"dd/mm/yyyy")#</td>
      <td width="115" class="titulos"><strong>Status:</strong></td>
      <td width="61" class="titulos">#AVGR_status#</td>
      <td class="titulos"><strong>Responsável</strong></td>
      <td colspan="2" class="titulos">#Usu_Apelido#</td>
      </tr>
    <tr>

      <td width="80" class="style3">
      <td>
        </label>
      <td><span class="titulos">Cadastro</span>
      <td><span class="titulos">#dateformat(AVGR_DT_CAD,"dd/mm/yyyy")#</span>
      <td><span class="titulos"><strong>Ativado:</strong></span>
      <td><span class="titulos">#dateformat(AVGR_DT_ATI,"dd/mm/yyyy")#</span>
      <td width="112" class="titulos"><strong>Desativado</strong></td>
	  <td width="112" class="titulos">#dateformat(AVGR_DT_DES,"dd/mm/yyyy")#</td>
      </tr>
    <tr>
      <td width="80" class="style3"><label>
        <div align="left"><strong>Data Inicial :</strong>
            </label>
          &nbsp;</div></td>
      <td colspan="8"><input name="dtinic" type="text" class="form" id="dtinic" tabindex="1"  onKeyPress="numericos()"  onKeyDown="Mascara_Data(this)" value="#AVGRDTINICIO#" size="14" maxlength="10" ></td>
    </tr>
    <tr>
      <td><div align="left"><span class="style3">
        </span><span class="style3">
          </span><span class="style3"><strong>Data Final : </strong></span><span class="style3">
            </label>
            </span></div></td>
      <td colspan="8"><input name="dtfim" type="text" class="form" id="dtfim" tabindex="2" onKeyPress="numericos()"  onKeyDown="Mascara_Data(this)"  value="#AVGRDTFINAL#" size="14" maxlength="10"></td>
    </tr>
	
	<tr>
	  <td><div align="left"><span class="style3"> </span><span class="style3"> </span><span class="style3"><strong>T&iacute;tulo : </strong></span><span class="style3">
          </label>
      </span></div></td>
	  <td colspan="9"><input name="frmtitulo" type="text" class="form" id="frmtitulo" tabindex="2" size="120" maxlength="100" value="#AVGR_TITULO#"></td>
	  </tr>
	<tr>
	  <td><div align="left"><span class="style3">
	    </span><span class="style3">
	      </span><span class="style3"><strong>Grupo de Acesso: </strong> </span><span class="style3">
	        </label>
	          </span></div></td>	
	  <td colspan="9">
	  		   <select name="frmgrupo" id="frmgrupo" class="form">
		       <option value="GERAL">GERAL</option>
			   <option <cfif #ucase(trim(rsalter.AVGR_GRUPOACESSO))# eq 'GESTORINSPETOR'> selected</cfif> value="GESTORINSPETOR">GESTORES/INSPETORES</option>
			   <option <cfif #ucase(trim(rsalter.AVGR_GRUPOACESSO))# eq 'GESTORINSPETORANALISTA'> selected</cfif> value="GESTORINSPETORANALISTA">GESTORES/INSPETORES/ANALISTAS</option>
			   <option value="">--------------------------</option>
			   <cfloop query="qArea"> 
			    <option <cfif #ucase(trim(rsalter.AVGR_GRUPOACESSO))# eq #ucase(trim(qArea.Usu_GrupoAcesso))#> selected</cfif> value="#ucase(trim(qArea.Usu_GrupoAcesso))#">#ucase(trim(qArea.Usu_GrupoAcesso))#</option>
	          </cfloop>
	        </select>	      </td>
	</tr>
	<tr>
	  <td><div align="left"><span class="style3">
	    </span><span class="style3">
	      </span><span class="style3"><strong>Mensagem:</strong></span><span class="style3">
	        </label>
	          </span></div></td>	
	  <td colspan="8"><label>
            <textarea name="frmmensagem" cols="150" rows="15" class="titulos" id="frmmensagem">#AVGR_AVISO#</textarea>
          </label></td>
	</tr>
	<tr>
	   <td colspan="9"></td>
	</tr>
	<tr>
	   <td colspan="9"></td>
	</tr>
	<tr>
	  <td>&nbsp;</td>
	  <td colspan="9">&nbsp;</td>
	  </tr>
	<tr>
	<cfif len(AVGR_ANEXO) lte 0>
		  <cfset habtn = 'disabled'>
	<cfelse>
		  <cfset habtn = ''>					  
	</cfif>	
	<!--- <cfset auxcaminho = mid(AVGR_ANEXO, 36, len(AVGR_ANEXO))> --->
	  <td>
	    
	      <div align="center">
	        <input name="cancelar" class="botao" type="button" value="Voltar" onClick="voltar()">
	        </div></td>    
	  <td colspan="9"> 
	  <input type="button" class="botao" name="Abrir" value="Abrir Anexo" onClick="window.open('abrir_pdf_act.cfm?arquivo=#AVGR_ANEXO#','_blank')" #habtn#>     	  
	     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	     <input name="alterar" type="submit" class="botao" id="alterar" value="Confirmar(Alterar)" align="center" onClick="document.frmObjeto.acao.value='alterar'">	  </td>        
    </tr>
<input type="hidden" name="acao" id="acao" value="">
<input name="frmx_ano" type="hidden" id="frmx_ano" value="#form.frmx_ano#"> 
<input name="frmx_id" type="hidden" id="frmx_id" value="#form.frmx_id#">	
<input name="frm1dthoje" type="hidden" id="frm1dthoje" value="<cfoutput>#dateformat(now(),"YYYYMMDD")#</cfoutput>">
</form>
</cfoutput>
	<tr>
	   <td colspan="10">&nbsp;</td>
	</tr>
</table>
  <p>&nbsp;  </p></td>
  </tr>
  <tr valign="top">
    <td align="left" class="link1">&nbsp;</td>
  </tr>
</TABLE>
<form name="formvolta" method="post" action="index.cfm?opcao=permissao15">
  <input name="sacao" type="hidden" id="sacao" value="voltar">
</form> 
</body>
</html>