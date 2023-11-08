<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_DR from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery> 
  
<cfset varAtua="">
 <!--- <cfset qAcesso.Usu_DR = '28'>  --->
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">
	<script language="JavaScript" src="../../mm_menu.js"></script>
</head>

<body>
	<!--//Validação de campos vazios em formulário -->
<script type="text/javascript">

function troca(a){

   var cmbseunid = document.getElementById("dr");
   for (i = 1; i < cmbseunid.length; i++) {

		// comparando o valor do value
		if (cmbseunid.options[i].value == a){
	//	       alert(i);
		  var  b = cmbseunid.options[i].text;
	//	  alert(cmbseunid.options[i].value + ' valor de b' + b + ' valor de a' + a);
		  i = cmbseunid.length;
		   }
		}	
		//alert(a + '  ' + b);	

	if (a == "---") {
	   alert("Informar um valor da seleção!");
	   return false;
		}
	 
//	if (confirm ("Deseja continuar?"))
//	   {
		document.formx.ssuper.value=a;
		document.formx.slabel.value=b;
		document.formx.submit(); 
//		}
//	else
//	   {
//	   return false;
//	   }
}

</script>
 
<!--- Áreas para seleção de permissão --->

	<!--- ÁREA DE CONTEÚDO --->

	<table width="100%" border="0" cellspacing="0" >
	<form method="post" name="form" action="">
	  <table width="100%" border="0" align="center">
	      <tr valign="baseline">
	        <td colspan="6" class="exibir"><div align="center"><span class="titulo1"><strong>Permiss&Otilde;es</strong></span></div></td>
	      </tr>
		<tr valign="baseline">
	      <td colspan="6">&nbsp;</td>
	    </tr>
		 <tr valign="baseline">
	      <td colspan="6">&nbsp;</td>
	    </tr>

		<cfif qAcesso.Usu_DR eq '04'>
			<tr valign="baseline">
		      <td colspan="6"><span class="titulos">Superintendência:</span></td>
			</tr>
			 <tr valign="baseline">
		     <td colspan="6">
			    <select name="dr" id="dr" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="04">AL</option>
				  <option value="70">SE</option>
		        </select></td>

			 </tr>
			 <tr valign="baseline">
		         <td colspan="6">&nbsp;</td>
		     </tr>
			 <cfset seprinc= '04'>
	         <cfset sesubor= '70'>
		 <cfelseif qAcesso.Usu_DR eq '10'>
			 <tr valign="baseline">
		        <td colspan="6"><span class="titulos">Superintendência:</span></td>
			 </tr>
			 <tr valign="baseline">
		     <td colspan="6"><select name="dr"  id="dr" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="10">BSB</option>
				  <option value="16">GO</option>
		        </select></td>
			 </tr>
			 <tr valign="baseline">
		         <td colspan="6">&nbsp;</td>
		     </tr>
			 <cfset seprinc= '10'>
	         <cfset sesubor= '16'>
		<cfelseif qAcesso.Usu_DR eq '06'>
			 <tr valign="baseline">
		        <td colspan="6"><span class="titulos">Superintendência:</span></td>
			 </tr>
			 <tr valign="baseline">
		     <td colspan="6"><select name="dr" id="dr" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="06">AM</option>
				  <option value="65">RR</option>
		        </select></td>
			 </tr>
			 <tr valign="baseline">
		         <td colspan="6">&nbsp;</td>
		     </tr>
			 <cfset seprinc= '06'>
	         <cfset sesubor= '65'>
		<cfelseif qAcesso.Usu_DR eq '26'>
			 <tr valign="baseline">
		        <td colspan="6"><span class="titulos">Superintendência:</span></td>
			 </tr>
			 <tr valign="baseline">
		     <td colspan="6"><select name="dr" id="dr" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="26">RO</option>
				  <option value="03">ACRE</option>
		        </select></td>
			 </tr>
			 <tr valign="baseline">
		         <td colspan="6">&nbsp;</td>
		     </tr>
			 <cfset seprinc= '26'>
	         <cfset sesubor= '03'>				 
		 <cfelseif qAcesso.Usu_DR eq '28'>
			 <tr valign="baseline">
		        <td colspan="6"><span class="titulos">Superintendência:</span></td>
			 </tr>
			 <tr valign="baseline">
		     <td colspan="6"><select name="dr" id="dr" class="form">
		          <option selected="selected" value="---">---</option>
		          <option value="28">PA</option>
				  <option value="05">AP</option>
		        </select></td>
			 </tr>
			 <tr valign="baseline">
		         <td colspan="6">&nbsp;</td>
		     </tr>
			 <cfset seprinc= '28'>
	         <cfset sesubor= '05'>
		 </cfif>
	   <tr valign="baseline">
	       <td colspan="6"><button name="enviar" type="button" class="botao" onClick="troca(dr.value);">Confirmar</button>
	       </td>
	  </tr>
	  </table>

	<!--- FIM DA ÁREA DE CONTEÚDO --->
    </form>
	</table>
	
<form name="formx" method="post" action="adicionar_permissao_rotinas_inspecao_novo2.cfm">
  <input name="ssuper" type="hidden" id="ssuper">  
  <input name="slabel" type="hidden" id="slabel">
</form>
	</body>
	</html>

