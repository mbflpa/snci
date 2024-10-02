<cfprocessingdirective pageEncoding ="utf-8"/>
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Usu_Coordena FROM Usuarios WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
// função que transmite as rotinas de alt, exc, etc...
function trocar(a,b){
    a = a.toUpperCase();
					
	if (a == "---") {
	   alert("Selecionar uma Superintendencia!");
	   return false;
	}
    document.form1.se.value = a; 
	document.form1.evento.value = b; 

	if (b == 'alt') {document.form1.action='alterar_unidade.cfm';}
	if (b == 'inc') {document.form1.action='incluir_unidade.cfm';}	
	if (b == 'exc') {document.form1.action='Excluir_Unidades.cfm';}		
	
    document.form1.submit(); 
}
</script>
</head>

<body>


<cfset seprinc= 'N'>

<form name="form1" method="post" action="alterar_unidade.cfm">  

	    <table width="21%" border="0" align="center">
	      <tr valign="baseline">
	        <td colspan="4" class="exibir"><div align="center"><span class="titulo1"><strong>Cadastro de  unidades </strong></span></div></td>
	      </tr>
 
	      <tr valign="baseline">
	        <td colspan="4">&nbsp;</td>
          </tr>
	      <tr valign="baseline">
		      <td colspan="4"><div align="center"><span class="titulos">Superintendência:</span></div></td>
	  </tr>

	   <cfif UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORMASTER'>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where Dir_Codigo <> '01'
			</cfquery>
			 <tr valign="baseline">
		     <td width="2%">&nbsp;</td>
			 <td colspan="3">
			   <div align="center">
			     <select name="dr" id="dr" class="form">
			       <option selected="selected" value="---">---</option>
			       <cfoutput query="qSE">
			         <option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
		           </cfoutput>
		         </select>
		       </div></td>
			 </tr>
		<cfelseif (UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORES') AND (TRIM(qAcesso.Usu_Coordena) neq '')>
			<cfoutput>
			<cfset se= #trim(qAcesso.Usu_Coordena)#>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where Dir_Codigo in(#se#)
			</cfquery>
			<!--- SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where Dir_Codigo in(#se#) --->
			</cfoutput>
			 <tr valign="baseline">
		     <td>&nbsp;</td>
			 <td colspan="3"><div align="left">
			   <select name="dr" id="dr" class="form">
                 <option selected="selected" value="---">---</option>
                 <cfoutput query="qSE">
                   <option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
                 </cfoutput>
               </select>
			   </div></td>
			 </tr>
        <cfelseif qAcesso.Usu_DR eq '04'>
			 <tr valign="baseline">
			 <td>&nbsp;</td>
		     <td colspan="3">
			    <div align="left">
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
			 <td>&nbsp;</td>
		     <td colspan="3">
			   <div align="left">
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
			 <td>&nbsp;</td>
		     <td colspan="3">
			   <div align="left">
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
			 <td>&nbsp;</td>
		     <td colspan="3">
			   <div align="left">
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
			 <td>&nbsp;</td>
		     <td colspan="3">
			   <div align="left">
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
        <tr valign="baseline">
          <td colspan="4">&nbsp;</td>
        </tr>
        <tr valign="baseline">
		  <td colspan="2"><div align="center">
	        <button type="button" class="botao" onClick="trocar(document.form1.dr.value,'inc')">Incluir</button>
	        </div></td>
	      <td width="35%">
            
            <div align="center">
                <button type="button" class="botao" onClick="trocar(document.form1.dr.value,'alt')">Alterar</button>
          </div></td>
          <td width="30%"><div align="center">
            <button type="button" class="botao" onClick="trocar(document.form1.dr.value,'exc')">Excluir</button>
          </div></td>
        </tr>
	</table>
	<input name="se" type="hidden" value="<cfoutput>#qAcesso.Usu_DR#</cfoutput>">
	<input name="evento" type="hidden" value="">

  <cfif (trim(qAcesso.Usu_GrupoAcesso) neq "GESTORMASTER") AND (TRIM(qAcesso.Usu_Coordena) eq '')>
	<script>
	document.form1.submit();
	</script>
  </cfif> 
</form>
  <!--- Termino da area de conteudo --->
</body>
</html>

