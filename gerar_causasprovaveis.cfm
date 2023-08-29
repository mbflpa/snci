<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="permissao_negada.htm">
	<cfabort> 
</cfif> 
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena, Dir_Descricao, Usu_Matricula
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
order by Dir_Sigla
</cfquery>

<!--- ========================== --->
<cfquery name="qAno" datasource="#dsn_inspecao#">
 SELECT Right([INP_NumInspecao],4) AS AnoInsp FROM Inspecao GROUP BY Right([INP_NumInspecao],4) order by Right([INP_NumInspecao],4) desc
</cfquery>
<!--- =========================== --->

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">
function valida_form() {
  var frm = document.forms[0];
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
		return false;
	    }
		if (frm.dtfim.value.length!= 10){
		alert("Preencher campo: Data Final ex. DD/MM/AAAA");
		return false;
	    }

		if (frm.SE.value==''){
		  alert('Informar a Superintendência!');
		  frm.SE.focus();
		  return false;
		}

//return false;
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
	<form action="gerar_causasprovaveis1.cfm" method="get" target="_blank" name="frmObjeto" onSubmit="return valida_form()">
	  <table width="53%" align="center">
        <tr>
          <td colspan="9" align="center" class="titulo1"><strong>gerar causas provaveis</strong></td>
        </tr>
		<tr>
          <td colspan="9" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="9" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="9" align="center"><div align="left"><strong class="titulo1">Pesquisa por:

          </strong></div></td>
        </tr>

		 <tr>
          <td colspan="9" align="center"><div align="left">&nbsp;</div></td>
        </tr>

        <tr>
          <td width="7%">&nbsp;</td>
          <td colspan="8">&nbsp;</td>
        </tr>
     	<tr>
          <td>&nbsp;</td>
          <td colspan="7"><div align="right"><strong><span class="exibir">Ano: &nbsp;&nbsp;&nbsp;</strong></div></td>
          <td width="70%"><strong>
            <select name="Ano" class="form" tabindex="3">
         <!---      <option selected="selected" value="">---</option> --->
              <cfoutput query="qAno">
                <option value="#AnoInsp#">#AnoInsp#</option>
              </cfoutput>
            </select>
          </strong><strong>
          </strong><strong>
          </strong></td>
        </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td colspan="7">&nbsp;</td>
		  <td>&nbsp;</td>
	    </tr>
		<tr>
          <td>&nbsp;</td>
          <td colspan="7"><strong><span class="exibir">Superintend&ecirc;ncia:
          &nbsp;&nbsp;&nbsp;</strong></td>
          <td><strong>
<cfif UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORMASTER' AND qAcesso.Usu_DR eq '01'>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where dir_codigo <> '01'
			</cfquery>
			 	<select name="se" id="se" class="form">
		          <option selected="selected" value="---">---</option>
				  <cfoutput query="qSE">
		          	<option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
				  </cfoutput>
		        </select>
		<cfelseif (UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORES' OR UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'ANALISTAS') AND len(TRIM(qAcesso.Usu_Coordena)) gt 0> 
		
            <cfset auxtam_lista = len(TRIM(qAcesso.Usu_Coordena))>
			<cfset aux_lista = TRIM(qAcesso.Usu_Coordena)>
			<cfset aux_codse = "">			
			    <select name="se" id="se" class="form">
		          <option selected="selected" value="---">---</option>
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
		        </select>

        <cfelseif qAcesso.Usu_DR eq '04'>
			    <select name="se" id="se" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="04">AL</option>
				  <option value="70">SE</option>
		        </select>
			 <cfset seprinc= '04'>
	         <cfset sesubor= '70'>
		 <cfelseif qAcesso.Usu_DR eq '10'>
			 <select name="se"  id="se" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="10">BSB</option>
				  <option value="16">GO</option>
	         </select>
			 <cfset seprinc= '10'>
	         <cfset sesubor= '16'>
		<cfelseif qAcesso.Usu_DR eq '06'>
			 <select name="se" id="se" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="06">AM</option>
				  <option value="65">RR</option>
	         </select>
			 <cfset seprinc= '06'>
	         <cfset sesubor= '65'>
		<cfelseif qAcesso.Usu_DR eq '26'>
			 <select name="se" id="se" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="26">RO</option>
				  <option value="03">ACR</option>
	         </select>
			 <cfset seprinc= '26'>
	         <cfset sesubor= '03'>				 
		 <cfelseif qAcesso.Usu_DR eq '28'>
			 <select name="se" id="se" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="28">PA</option>
				  <option value="05">AP</option>
		     </select>
			 <cfset seprinc= '28'>
	         <cfset sesubor= '05'>
		 <cfelse>
			   <cfoutput>
			    <select name="se" id="se" class="form">
		          <option selected="selected" value="#qAcesso.Usu_DR#">#qAcesso.Dir_Sigla#</option>
		        </select>
	           </cfoutput>
		 </cfif>
          </strong></td>
        </tr>
		<tr>
          <td>&nbsp;</td>
          <td colspan="8">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="7">&nbsp;</td>
          <td colspan="2"><input name="Submit1" type="submit" class="botao" id="Submit13" value="Confirmar"></td>
        </tr>
      </table>
</form>
</body>
</html>
