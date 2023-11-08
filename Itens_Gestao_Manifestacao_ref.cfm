<!--- <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>   ---> 
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena 
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<!--- =========================== --->
<!--- <cfinclude template="cabecalho.cfm"> --->
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">

function valida_form() {
  var frm = document.forms[0];

  if (frm.ckTipo.value=='periodo'){
  // alert(frm.ckTipo.value);
		if (frm.dtinic.value==''){
		  alert('Informe a Data Inicial!');
		  frm.dtinic.focus();
		  return false;
		}
		if (frm.dtfim.value==''){
		  alert('Informe a Data Final!');
		  frm.dtinic.focus();
		  return false;
		}
		if (frm.dtinic.value.length != 10){
		alert("Preencher campo: Data Inicial ex. DD/MM/AAAA");
		frm.dtinic.focus();
		return false;
	    }
		if (frm.dtfim.value.length!= 10){
		alert("Preencher campo: Data Final ex. DD/MM/AAAA");
		frm.dtfim.focus();
		return false;
	    }
				
		
		 var dtinic_yyyymmdd = frm.dtinic.value.substr(6,10) + frm.dtinic.value.substr(3,2) + frm.dtinic.value.substr(0,2);
		 var dtfim_yyyymmdd = frm.dtfim.value.substr(6,10) + frm.dtfim.value.substr(3,2) + frm.dtfim.value.substr(0,2);
       //  alert('dt inicio: ' + dtinic_yyyymmdd + '     dt fim: ' + dtfim_yyyymmdd);
		 if (dtinic_yyyymmdd > dtfim_yyyymmdd)
		 {
		  alert('Data Inicial é maior que a Data Final!')
		  frm.dtinic.focus();
		  return false;
		 }
		 if ((dtfim_yyyymmdd - dtinic_yyyymmdd) > 31)
		 {
		 alert((dtfim_yyyymmdd - dtinic_yyyymmdd));
		  alert('Esta consulta está limitada a 30(dias) entre as duas datas!')
		  frm.dtfim.focus();
		  return false;
		 }
		if (frm.SE.value==''){
		  alert('Informar a Superintendência!');
		  frm.SE.focus();
		  return false;
		}
  }
  //=========================
  if (frm.ckTipo.value=='super'){
		if (frm.superAno.value==''){
		  alert('Informar o Ano');
		  frm.superAno.focus();
		  return false;
		}
		if (frm.superAno.value.length != 4){
		  alert('Informar o campo ano com 4 dígitos ex. 2018');
		  frm.superAno.focus();
		  return false;
		}
		if (frm.superAno.value < 2018 ){
		  alert('Não há Inspeção para ano inferior a 2018');
		  frm.superAno.focus();
		  return false;
		}
	}
	//==========================
   if (frm.ckTipo.value=='inspecao'){
		if (frm.txtNum_Inspecao.value==''){
		  alert('Informar o Nº do Relatório');
		  frm.txtNum_Inspecao.focus();
		  return false;
		}
		if (frm.txtNum_Inspecao.value.length != 10){
		alert("Nº de Inspeção deve conter 10 dígitos!");
		frm.txtNum_Inspecao.focus();
		return false;
	    }
	}
 //=========
 /*
 if (frm.ckTipo.value=='inspetor'){
  // alert(frm.ckTipo.value);
		if (frm.dtinicinsp.value==''){
		  alert('Informe a Data Inicial!');
		  frm.dtinicinsp.focus();
		  return false;
		}
		if (frm.dtfiminsp.value==''){
		  alert('Informe a Data Final!');
		  frm.dtinicinsp.focus();
		  return false;
		}
		if (frm.dtinicinsp.value.length != 10){
		alert("Preencher campo: Data Inicial ex. DD/MM/AAAA");
		frm.dtinicinsp.focus();
		return false;
	    }
		if (frm.dtfiminsp.value.length!= 10){
		alert("Preencher campo: Data Final ex. DD/MM/AAAA");
		frm.dtfiminsp.focus();
		return false;
	    }
		 var dtinic_yyyymmdd = frm.dtinicinsp.value.substr(6,10) + frm.dtinicinsp.value.substr(3,2) + frm.dtinicinsp.value.substr(0,2);
		 var dtfim_yyyymmdd = frm.dtfiminsp.value.substr(6,10) + frm.dtfiminsp.value.substr(3,2) + frm.dtfiminsp.value.substr(0,2);
       //  alert('dt inicio: ' + dtinic_yyyymmdd + '     dt fim: ' + dtfim_yyyymmdd);
		 if (dtinic_yyyymmdd > dtfim_yyyymmdd)
		 {
		  alert('Data Inicial é maior que a Data Final!')
		  frm.dtinicinsp.focus();
		  return false;
		 }
		 if ((dtfim_yyyymmdd - dtinic_yyyymmdd) > 1130)
		 {
		//  alert('Esta consulta está limitada a 365 dias entre as duas datas!')
		//  frm.dtfim.focus();
		 // return false;
		 }
  }
  */
 //=========
//return false;
}

function desabilita_campos(x){
    var frm = document.forms[0];
//	alert(x);
	frm.Submit1.disabled=true;
	frm.Submit2.disabled=true;
	frm.Submit3.disabled=true;
	//frm.Submit4.disabled=true;
	frm.dtinic.disabled=true;
	frm.dtinic.value='';
	frm.dtfim.disabled=true;
	frm.dtfim.value='';
	//frm.dtinicinsp.disabled=true;
	//frm.dtinicinsp.value='';
	//frm.dtfiminsp.disabled=true;
//	frm.dtfiminsp.value='';
	frm.SE.disabled=true;
	frm.SE.selectedIndex = 0;
	frm.superSE.disabled=true;
	frm.superMes.disabled=true;
	frm.superAno.value = '';
	frm.superAno.disabled=true;
	frm.superSE.selectedIndex = 0;
	frm.txtNum_Inspecao.value='';
	frm.txtNum_Inspecao.disabled=true;
	//frm.InspSE.disabled=true;
	//frm.InspSE.selectedIndex = 0;
		
	if (x == 1) {
	    frm.ckTipo.value='periodo';
		frm.dtinic.disabled=false;
		frm.dtfim.disabled=false;
		frm.SE.disabled=false;
		frm.Submit1.disabled=false;
		frm.dtinic.focus();
	}
	if (x == 2) {
   	   frm.ckTipo.value='inspecao';
	   frm.txtNum_Inspecao.disabled=false;
	   frm.Submit2.disabled=false;
	   frm.txtNum_Inspecao.focus();
	}
	if (x == 3) {
	    frm.superSE.disabled=false;
		frm.Submit3.disabled=false;
		frm.superMes.disabled=false;
	    frm.superAno.disabled=false;
		frm.superSE.focus();
 	}
/*	if (x == 4) {
		frm.dtinicinsp.disabled=false;
	    frm.dtfiminsp.disabled=false;
		frm.InspSE.disabled=false;
		frm.Submit4.disabled=false;
		frm.InspSE.focus();
 	}
	*/
	//alert(frm.ckTipo.value);
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
</script>
 <link href="css.css" rel="stylesheet" type="text/css">
</head>
<br>
<body>


<tr>
   <td colspan="6" align="center">&nbsp;</td>
</tr>

<!--- Área de conteúdo   --->
	<form action="Itens_Gestao_Manifestacao.cfm" method="get" target="_blank" name="frmObjeto" onSubmit="return valida_form()">
      <table width="53%" align="center">
        <tr>
          <td colspan="5" align="center" class="titulo1">AN&Aacute;LISES  DAS MANIFESTA&Ccedil;&Otilde;ES</td>
        </tr>
        <tr>
          <td colspan="5" align="center"><div align="left"></div>            <div align="left">&nbsp;</div></td>
        </tr>
        
        
        <tr>
          <td width="1%" class="exibir">&nbsp;</td>
          <td colspan="4"><input name="ckTipo" type="radio" onClick="document.frmObjeto.ckTipo.value='periodo';desabilita_campos(1)" value="periodo" checked>
              <span class="exibir"><strong>Per&iacute;odo/Superintendência</strong></span></td>
        </tr>
        <tr>
          <td colspan="5">&nbsp;</td>
        </tr>
        <tr>
          <td><strong>
            <div id="dDtInicio" class="exibir"></div>
          </strong></td>
          <td width="20%"><strong><span class="exibir">Data Inicial :</span></strong><strong></strong></td>
          <td width="79%" colspan="2"><strong class="titulo1">
            <input name="dtinic" type="text" class="form" tabindex="1" id="dtinic" size="14" maxlength="10"  onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" >
          </strong></td>
        </tr>
        <tr>
          <td></td>
          <td><strong>
            <div id="dDtFinal" class="exibir">Data Final :</div>
          </strong></td>
          <td colspan="3"><strong><span class="exibir">
            <input name="dtfim" type="text" class="form" id="dtfim" tabindex="2" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10">
          </span></strong></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td><strong><span class="exibir">Superintend&ecirc;ncia :</span></strong> </td>
		  
		  <!---  --->
		     <cfif UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORMASTER' AND qAcesso.Usu_DR eq '01'>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria
			</cfquery>

		     <td colspan="3">
			    <select name="SE" id="SE" class="form">
		          <option selected="selected" value="0">Todas</option>
				  <cfoutput query="qSE">
		          	<option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
				  </cfoutput>
		        </select></td>

<!--- 			 <cfset seprinc= '04'>
	         <cfset sesubor= '70'> --->
		<cfelseif UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORES' AND len(TRIM(qAcesso.Usu_Coordena)) gt 0> 
            <cfset auxtam_lista = len(TRIM(qAcesso.Usu_Coordena))>
			<cfset aux_lista = TRIM(qAcesso.Usu_Coordena)>
			<cfset aux_codse = "">			
			

		     <td colspan="3">
			    <select name="SE" id="SE" class="form">
		          <option selected="selected" value="0">Todas</option>
<cfoutput>
				  <cfloop from="1" to="#val(auxtam_lista) + 1# " index="i">
				     <cfif len(aux_codse) eq 2>
					   <cfquery name="qCDR" datasource="#dsn_inspecao#">
						SELECT Dir_Sigla FROM Diretoria  WHERE Dir_Codigo = '#aux_codse#'
					   </cfquery> 
		               <option value="#aux_codse#">#Ucase(trim(qCDR.Dir_Sigla))#</option>
					   <cfset aux_codse = "">
					</cfif>
					<cfif mid(aux_lista,i,1) neq ",">
					  <cfset aux_codse = #aux_codse# & #mid(aux_lista,i,1)#>
					</cfif>
				  </cfloop>
</cfoutput>				  				  
		        </select>				</td>
        </cfif>
		  <!---  --->
        </tr>
        <tr>
          <td colspan="5">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="3">
            <div align="center">
              <input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar" onClick="document.frmObjeto.ckTipo.value='periodo';">
              </div></td></tr>
      </table>
	</form>
</body>
</html>
