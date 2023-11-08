<cfprocessingdirective pageEncoding ="utf-8"/>  
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena 
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
// fun��o que transmite as rotinas de alt, exc, etc...
function trocar(a,b){
    a = a.toUpperCase();
    b = b.toUpperCase();
					
	if (a == "---") {
	   alert("Selecionar uma Superintendência!");
	   return false;
	}
	if (b == "---") {
	   alert("Selecionar uma Grupo de Acesso!");
	   return false;
	}
    document.form1.submit(); 
}
</script>
</head>

	
	<!--- <body onLoad="grupoacesso('---')"; onsubmit="mensagem()"> --->
<body>
<cfif isDefined("Form.sacao") And (#Form.sacao# neq "")>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
 <cfinclude template="cabecalho.cfm">
</table>
</cfif> 

<form name="form1" method="post" action="adicionar_permissao_rotinas_inspecao1.cfm">  

	    <table width="80%" border="0" align="center">
	      <tr valign="baseline">
	        <td colspan="3" class="exibir"><div align="center"><span class="titulo1"><strong>Permissões</strong></span></div></td>
	      </tr>
 
	     <tr valign="baseline">
		      <td colspan="3"><span class="titulos">Superintendência:</span></td>
	  </tr>

	   <cfif (UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORMASTER' or UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GOVERNANCA') AND qAcesso.Usu_DR eq '01'>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria
			</cfquery>
			 <tr valign="baseline">
		     <td colspan="3">
			    <select name="dr" id="dr" class="form">
		          <option selected="selected" value="---">---</option>
				  <cfoutput query="qSE">
		          	<option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
				  </cfoutput>
		        </select></td>

			 </tr>
			 <tr valign="baseline">
		         <td colspan="3">&nbsp;</td>
		     </tr>
<!--- 			 <cfset seprinc= '04'>
	         <cfset sesubor= '70'> --->
		<cfelseif (UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORES' OR UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'ANALISTAS') AND len(TRIM(qAcesso.Usu_Coordena)) gt 0> 
			<cfset aux_lista = TRIM(qAcesso.Usu_Coordena)>
	
			 <tr valign="baseline">
		     <td colspan="3">
			    <select name="dr" id="dr" class="form">
		          <option selected="selected" value="---">---</option>
<cfoutput>
				<cfloop list="#aux_lista#" index="i">
					<cfquery name="qCDR" datasource="#dsn_inspecao#">
						SELECT Dir_Sigla FROM Diretoria  WHERE Dir_Codigo = '#i#'
					</cfquery>
					<option value="#i#">#Ucase(trim(qCDR.Dir_Sigla))#</option>
				</cfloop>

</cfoutput>				  				  
		        </select></td>

			 </tr>
			 <tr valign="baseline">
		         <td colspan="3">&nbsp;</td>
		     </tr>
        <cfelseif qAcesso.Usu_DR eq '04'>
			 <tr valign="baseline">
		     <td colspan="3">
			    <select name="dr" id="dr" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="04">AL</option>
				  <option value="70">SE</option>
		        </select></td>

			 </tr>
			 <tr valign="baseline">
		         <td colspan="3">&nbsp;</td>
		     </tr>
			 <cfset seprinc= '04'>
	         <cfset sesubor= '70'>
		 <cfelseif qAcesso.Usu_DR eq '10'>
			 <tr valign="baseline">
		     <td colspan="3">
			 <select name="dr"  id="dr" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="10">BSB</option>
				  <option value="16">GO</option>
		        </select>
				</td>
			 </tr>
			 <tr valign="baseline">
		         <td colspan="3">&nbsp;</td>
		     </tr>
			 <cfset seprinc= '10'>
	         <cfset sesubor= '16'>
		<cfelseif qAcesso.Usu_DR eq '06'>
			 <tr valign="baseline">
		     <td colspan="3">
			 <select name="dr" id="dr" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="06">AM</option>
				  <option value="65">RR</option>
		        </select></td>
			 </tr>
			 <tr valign="baseline">
		         <td colspan="3">&nbsp;</td>
		     </tr>
			 <cfset seprinc= '06'>
	         <cfset sesubor= '65'>
		<cfelseif qAcesso.Usu_DR eq '26'>
			 <tr valign="baseline">
		     <td colspan="3">
			 <select name="dr" id="dr" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="26">RO</option>
				  <option value="03">ACR</option>
		        </select></td>
			 </tr>
			 <tr valign="baseline">
		         <td colspan="3">&nbsp;</td>
		     </tr>
			 <cfset seprinc= '26'>
	         <cfset sesubor= '03'>				 
		 <cfelseif qAcesso.Usu_DR eq '28'>
			 <tr valign="baseline">
		     <td colspan="3">
			 <select name="dr" id="dr" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="28">PA</option>
				  <option value="05">AP</option>
		     </select></td>
			 </tr>
			 <tr valign="baseline">
		         <td colspan="3">&nbsp;</td>
		     </tr>
			 <cfset seprinc= '28'>
	         <cfset sesubor= '05'>
		 <cfelse>
		     <tr valign="baseline">
		     <td colspan="3"> 
			   <cfoutput>
			    <select name="dr" id="dr" class="form">
		          <option selected="selected" value="#qAcesso.Usu_DR#">#qAcesso.Dir_Sigla#</option>
		        </select>
	           </cfoutput>
			 </td>
			 </tr>
		 </cfif>	  
        <tr valign="baseline">
	      <td colspan="3">&nbsp;</td>
		</tr>

<!--- �reas para sele��o de permiss�o --->
	
	<!--- �REA DE CONTE�DO --->
	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqArea" returnvariable="request.qArea">
	</cfinvoke>

        <tr valign="baseline">
	      <td colspan="3"><span class="titulos">Grupo de Acesso:</span></td>
		</tr>
		<tr valign="baseline"> 
	      <td colspan="3">
		   <select name="area_usu" id="area_usu" class="form">
	          <cfoutput query="request.qArea"> 
			  <cfif left(qAcesso.Usu_DR,2) eq '01' and (UCase(trim(Usu_GrupoAcesso)) eq "DEPARTAMENTO" or UCase(trim(Usu_GrupoAcesso)) eq "GESTORMASTER" or UCase(trim(Usu_GrupoAcesso)) eq "DESENVOLVEDORES" or UCase(trim(Usu_GrupoAcesso)) eq "ANALISTAS" OR UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GOVERNANCA')>
			    <option value="#UCase(Usu_GrupoAcesso)#">#UCase(Usu_GrupoAcesso)#</option>
              <cfelse>
			  <cfif (UCase(trim(Usu_GrupoAcesso)) neq "DEPARTAMENTO" and UCase(trim(Usu_GrupoAcesso)) neq "GESTORMASTER" and UCase(trim(Usu_GrupoAcesso)) neq "DESENVOLVEDORES")>
			    <option value="#UCase(Usu_GrupoAcesso)#">#UCase(Usu_GrupoAcesso)#</option>
			  </cfif>
			  </cfif>
                
	          </cfoutput>
	        </select>
	      </td>
	      </tr>
			 <tr valign="baseline" align="center">
			   <td><button type="button" class="botao" onClick="trocar(dr.value,area_usu.value);">Confirmar Permissão</button></td>
	      </tr>
	</table>
	<input name="frmgrpacessologin" type="hidden" value="<cfoutput>#trim(qAcesso.Usu_GrupoAcesso)#</cfoutput>">
	<input name="frmcoordena" type="hidden" value="<cfoutput>#TRIM(qAcesso.Usu_Coordena)#</cfoutput>">
	<input name="frmse" type="hidden" value="<cfoutput>#TRIM(qAcesso.Usu_DR)#</cfoutput>">
</form>
  <!--- T�rmino da �rea de conte�do --->
</body>
</html>

