<cfprocessingdirective pageEncoding ="utf-8"> 
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	SELECT Usu_GrupoAcesso, Usu_DR, Usu_Coordena FROM Usuarios WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset grpacesso = ucase(trim(qAcesso.Usu_GrupoAcesso))>
<cfif grpacesso NEQ 'ANALISTAS' and grpacesso NEQ 'GESTORMASTER' and grpacesso NEQ 'GOVERNANCA' AND grpacesso NEQ 'GESTORES' AND grpacesso NEQ 'DESENVOLVEDORES' AND grpacesso NEQ 'SUPERINTENDENTE' AND grpacesso NEQ 'GERENTES' AND grpacesso NEQ 'ORGAOSUBORDINADOR' AND grpacesso NEQ 'SUBORDINADORREGIONAL'>
<!---	 <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=PAGINA DE INDICADORES EM MANUTENCAO ATE 12h"> --->
</cfif>   
<cfset auxanoatu = year(now())>
<cfquery name="rsAno" datasource="#dsn_inspecao#">
	SELECT Andt_AnoExerc
	FROM Andamento_Temp
	GROUP BY Andt_AnoExerc
	HAVING Andt_AnoExerc > '2021' and Andt_AnoExerc < '#auxanoatu#'
	ORDER BY Andt_AnoExerc DESC
</cfquery>

<!--- =========================== --->
<cfset auxdia = int(day(now()))>
<cfset aux_mes = int(month(now()))>
<cfset aux_ano = int(year(now()))>


<cfif grpacesso eq 'GESTORMASTER' OR grpacesso eq 'GOVERNANCA'>
	<cfif (aux_mes eq 1) or (aux_mes eq 2 and auxdia lte 10)>
		 <!--- <cfset aux_mes = 12>
		 <cfset aux_ano = aux_ano - 1>
		 --->
	</cfif>
	<cfif auxdia gt 10>
	<!---		<cfset aux_mes = (aux_mes - 1)>  --->
	</cfif>
 <cfelse>
	<cfif (aux_mes eq 1) or (aux_mes eq 2 and auxdia lte 10)>
		 <cfset aux_mes = 12>
		 <cfset aux_ano = aux_ano - 1>
	<cfelse>
			<cfset aux_mes = (aux_mes - 1)>
	</cfif>
 </cfif>

<!---
 <cfoutput>aux_ano:#aux_ano#  === aux_mes:#aux_mes#</cfoutput><BR> 
<cfset gil = gil> 
--->

<cfif aux_mes is 1>
    <cfset dtlimit = aux_ano & "/01/31">
<cfelseif aux_mes is 2>  
	<cfif int(aux_ano) mod 4 is 0>
	   <cfset dtlimit = aux_ano & "/02/29">
	<cfelse>
	   <cfset dtlimit = aux_ano & "/02/28">
	</cfif>
<cfelseif aux_mes is 3>
  <cfset dtlimit = aux_ano & "/03/31">
<cfelseif aux_mes is 4>
	   <cfset dtlimit = aux_ano & "/04/30">		
<cfelseif aux_mes is 5>
	   <cfset dtlimit = aux_ano & "/05/31">		
<cfelseif aux_mes is 6>
	   <cfset dtlimit = aux_ano & "/06/30">					   
<cfelseif aux_mes is 7>
	   <cfset dtlimit = aux_ano & "/07/31">					   
<cfelseif aux_mes is 8>
	   <cfset dtlimit = aux_ano & "/08/31">					   
<cfelseif aux_mes is 9>
	   <cfset dtlimit = aux_ano & "/09/30">					   
<cfelseif aux_mes is 10>
	   <cfset dtlimit = aux_ano & "/10/31">	
<cfelseif aux_mes is 11>	
		<cfset dtlimit = aux_ano & "/11/30">	   				   
<cfelse>
	   <cfset dtlimit = aux_ano & "/12/31">				   
</cfif>
<!---
 <cfoutput>dtlimit:#dtlimit#</cfoutput>
 <CFSET GIL = GIL>  
--->
<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
// fun��o que transmite as rotinas de alt, exc, etc...
function trocar(a){
//alert('aaa');
    a = a.toUpperCase();
					
	if (a == "---") {
	   alert("Selecionar uma Superintendência!");
	   return false;
	}
    //document.form1.se.value = a; 
    document.form1.submit(); 
}

function valida_form() {
    var frm = document.forms[0];
    if (frm.dr.value=='---'){
	  alert('Informar a Superintendência!');
	  frm.dr.focus();
	  return false;
	}	
	//alert(frm.anoatual.value + '  ' + frm.frmano.value);
	frm.anoexerc.value = frm.frmano.value;
	 
	var auxdt = frm.dtlimit.value; 
	if (frm.frmano.value < 2023) {
		frm.dtlimit.value = frm.frmano.value + auxdt.substring(4,10);
	}	
	if (frm.frmano.value < frm.anoatual.value)
	{
	//alert(frm.anoatual.value + '  ' + frm.frmano.value);
	frm.dtlimit.value = frm.frmano.value + '/12/31';
	} 
}

</script>
</head>

<body>

<cfif grpacesso is 'SUPERINTENDENTE'> 
	<cfinclude template="cabecalho.cfm">
</cfif> 
<form action="dgci.cfm" method="get" target="_blank" name="frmObjeto" onSubmit="return valida_form()"> 
	    <table width="33%" border="0" align="center">
	      <tr valign="baseline">
	        <td colspan="2" class="exibir"><div align="center"><span class="titulo1">indicadores</span></div></td>
	      </tr>
 
	      <tr valign="baseline">
	        <td colspan="2">&nbsp;</td>
          </tr>
	      <tr valign="baseline">
	        <td colspan="2" class="titulo1"><div align="center"><strong>DGCI - Desempenho Geral de Controle Interno</strong></div></td>
          </tr>
	      <tr valign="baseline">
	        <td colspan="2">&nbsp;</td>
          </tr>
	      <tr valign="baseline">
	        <td colspan="2">&nbsp;</td>
          </tr>
	      <tr valign="baseline">
	        <td colspan="2">&nbsp;</td>
          </tr>
	      <tr valign="baseline">
	        <td colspan="2"><div align="center"><span class="titulos">&nbsp;&nbsp;&nbsp;&nbsp;Superintendência:</span></div></td>
          </tr>
	      <tr valign="baseline">
		      <td colspan="2"><div align="center"><span class="titulos">&nbsp;&nbsp;&nbsp;&nbsp;</span></div></td>
	  </tr>

	   <cfif grpacesso eq 'GESTORMASTER' OR grpacesso eq 'GOVERNANCA'>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where dir_codigo <> '01'
			</cfquery>
			 <tr valign="baseline">
		     <td><div align="center"></div></td>
			 <td width="97%">
		       <div align="center">
			       <select name="dr" id="dr" class="form">
                     <option selected="selected" value="---">---</option>
                     <cfoutput query="qSE">
                       <option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
                     </cfoutput>
                   </select>
	           </div></td></tr>
		 <cfelseif grpacesso eq 'DESENVOLVEDORES'>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria WHERE dir_codigo <> '01'
			</cfquery>
			 <tr valign="baseline">
		     <td><div align="center"></div></td>
			 <td width="97%">
		       <div align="center">
			       <select name="dr" id="dr" class="form">
                     <option selected="selected" value="---">---</option>
                     <cfoutput query="qSE">
                       <option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
                     </cfoutput>
                   </select>
	           </div></td></tr>
		<cfelseif grpacesso eq 'SUPERINTENDENTE' OR grpacesso eq 'GERENTES' OR grpacesso eq 'ORGAOSUBORDINADOR' OR grpacesso eq 'SUBORDINADORREGIONAL' or grpacesso eq 'INSPETORES'>
		   <cfoutput>
		   <cfset se= #trim(qAcesso.Usu_DR)#>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where Dir_Codigo in(#se#)
			</cfquery>
			 <tr valign="baseline">
		     <td><div align="center"></div></td>
			 <td width="97%">
			   
			   <div align="center">
			       <select name="dr" id="dr" class="form">
                       <option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
                   </select>
			       
			   </div></td></tr>
			 </cfoutput>
		<cfelseif (grpacesso eq 'GESTORES' OR grpacesso eq 'ANALISTAS') AND len(TRIM(qAcesso.Usu_Coordena)) gt 0> 
			<cfoutput>
			<cfset se= #trim(qAcesso.Usu_Coordena)#>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where Dir_Codigo in(#se#)
			</cfquery>
			<!--- SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where Dir_Codigo in(#se#) --->
			</cfoutput>
			 <tr valign="baseline">
		     <td><div align="center"></div></td>
			 <td width="97%">
		       <div align="center">
			       <select name="dr" id="dr" class="form">
                     <option selected="selected" value="---">---</option>
                     <cfoutput query="qSE">
                       <option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
                     </cfoutput>
                   </select>
	           </div></td></tr>
        <cfelseif qAcesso.Usu_DR eq '04'>
			 <tr valign="baseline">
			 <td><div align="center"></div></td>
		     <td width="97%">
		       <div align="center">
			        <select name="dr" id="dr" class="form">
                      <option selected="selected" value="---">---</option>
                      <option value="04">AL</option>
		              <option value="70">SE</option>
                 </select>
		            </div></td>
			 </tr>

			 <cfset seprinc= '04'>
	         <cfset sesubor= '70'>
		 <cfelseif qAcesso.Usu_DR eq '10'>
			 <tr valign="baseline">
			 <td><div align="center"></div></td>
		     <td width="97%">
		       <div align="center">
			       <select name="dr"  id="dr" class="form">
	                    <option selected="selected" value="---">---</option>
	                    <option value="10">BSB</option>
			            <option value="16">GO</option>
                 </select>
			       </div></td>
			 </tr>
			 <cfset seprinc= '10'>
	         <cfset sesubor= '16'>
		<cfelseif qAcesso.Usu_DR eq '06'>
			 <tr valign="baseline">
			 <td><div align="center"></div></td>
		     <td width="97%">
		       <div align="center">
			       <select name="dr" id="dr" class="form">
	                    <option selected="selected" value="---">---</option>
	                    <option value="06">AM</option>
			            <option value="65">RR</option>
                 </select>
		           </div></td>
			 </tr>
			 <cfset seprinc= '06'>
	         <cfset sesubor= '65'>
		<cfelseif qAcesso.Usu_DR eq '26'>
			 <tr valign="baseline">
			 <td><div align="center"></div></td>
		     <td width="97%">
		       <div align="center">
			       <select name="dr" id="dr" class="form">
	                    <option selected="selected" value="---">---</option>
	                    <option value="26">RO</option>
			            <option value="03">ACR</option>
                 </select>
		           </div></td>
			 </tr>
			 <cfset seprinc= '26'>
	         <cfset sesubor= '03'>				 
		 <cfelseif qAcesso.Usu_DR eq '28'>
			 <tr valign="baseline">
			 <td><div align="center"></div></td>
		     <td width="97%">
		       <div align="center">
			       <select name="dr" id="dr" class="form">
	                    <option selected="selected" value="---">---</option>
	                    <option value="28">PA</option>
			            <option value="05">AP</option>
                 </select>
		           </div></td>
			 </tr>
			 <cfset seprinc= '28'>
	         <cfset sesubor= '05'>
		 </cfif>	 
		           <tr>
		             <td>&nbsp;</td>
		             <td class="exibir"><div align="center"><strong>Ano : </strong></div></td>
		             <td colspan="2">&nbsp;</td>
          </tr>
		           <tr>
            <td>&nbsp;</td>
            <td class="exibir"><div align="center">
              <select name="frmano" class="exibir" id="frmano">
			    <cfoutput> <option value="#year(now())#">#year(now())#</option></cfoutput>
                <cfoutput query="rsAno">
                  <option value="#rsAno.Andt_AnoExerc#" <cfif rsAno.Andt_AnoExerc eq year(now())>selected</cfif>>#rsAno.Andt_AnoExerc#</option>
                </cfoutput>
              </select>	  
            </div></td>
            <td colspan="2">&nbsp;
			</td>
          </tr> 

        <tr valign="baseline">
          <td colspan="2"><div align="center"></div></td>
        </tr>
        
        <tr valign="baseline">
	      <td colspan="2">
              <div align="right">
<!--- 	              <button type="button" class="botao" onClick="trocar(document.form1.dr.value)">Confirmar</button> --->
				   <input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar" onClick="document.frmObjeto.ckTipo.value='ano';">
          </div></td>
		</tr>
  </table>
	
  <cfif grpacesso eq 'SUPERINTENDENTE'>
	<!--- <cfif seprinc eq 'N'> --->
	<script>
	document.form1.submit();
	</script>
	<!--- </cfif> --->
  </cfif>
      <input name="dtlimit" type="hidden" value="<cfoutput>#dtlimit#</cfoutput>">
	  <input name="dtlimitatual" type="hidden" value="<cfoutput>#dtlimit#</cfoutput>">
	  <input name="anoexerc" type="hidden" value="<cfoutput>#year(dtLimit)#</cfoutput>">
	  <input name="anoatual" type="hidden" value="<cfoutput>#year(now())#</cfoutput>">
	  <input name="frmmesatual" type="hidden" value="<cfoutput>#month(now())#</cfoutput>">
	  <input name="frmUsuGrupoAcesso" type="hidden" value="<cfoutput>#grpacesso#</cfoutput>">
	  <input name="frmdia" type="hidden" value="<cfoutput>#day(now())#</cfoutput>">
<!--- 	  
<cfoutput>dtlimit:#dtlimit#</cfoutput><br>
<cfoutput>#year(dtLimit)#</cfoutput><br>
<cfoutput>#year(now())#</cfoutput>	  
--->
</form>
  <!--- T�rmino da �rea de conte�do --->
</body>
</html>

