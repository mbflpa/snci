<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>    
<!---  --->
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Usu_Coordena, Usu_Matricula FROM Usuarios WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfquery name="rsSE" datasource="#dsn_inspecao#">
	SELECT Dir_Codigo, Dir_Sigla
	FROM Diretoria
	WHERE Dir_Codigo <> '01'
</cfquery>
<cfquery name="rstpunid" datasource="#dsn_inspecao#">
	SELECT TUN_Codigo, TUN_Descricao
	FROM Tipo_Unidades
	ORDER BY TUN_Descricao
</cfquery>

<cfset auxanoatu = year(now())>
<cfquery name="rsAno" datasource="#dsn_inspecao#">
SELECT Andt_AnoExerc
FROM Andamento_Temp
GROUP BY Andt_AnoExerc
HAVING Andt_AnoExerc  < '#auxanoatu#'
ORDER BY Andt_AnoExerc DESC
</cfquery>
<!--- =========================== --->

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">

function validarform() {
//alert('aqui....');
    var frm = document.forms[0];
	var messelec = frm.frmmes.value;
	var mesatual = frm.frmmesatual.value;
//alert(frm.frmUsuGrupoAcesso.value);
//alert(frm.frmdia.value);

	//alert('frmanoselecionado ' + frm.frmano.value + ' Ano atual ' + frm.frmanoatual.value + ' Mes selecionado ' + frm.frmmes.value + ' mes atual: ' + mesatual);	
	if (eval(frm.frmano.value) == eval(frm.frmanoatual.value))
	{
	if (eval(messelec) >= eval(mesatual)){
	alert('Gestor(a), o mês selecionado para o ano selecionado ainda não gerado!');
	return false;
	}

    if (eval(messelec) == eval(mesatual - 1) && frm.frmUsuGrupoAcesso.value != 'GESTORMASTER' && frm.frmdia.value <= 10){
	alert('Gestor(a), o mês selecionado para o ano selecionado ainda não gerado!');
	return false;
	}	
	} 


//return false;
}
</script>
 <link href="css.css" rel="stylesheet" type="text/css">
</head>
<br>
<body>

<!--- <cfinclude template="cabecalho.cfm"> --->
<tr>
   <td colspan="6" align="center">&nbsp;</td>
</tr>

<!--- Área de conteúdo   --->
	<form action="Pacin_Unidades_Avaliadas.cfm" method="post" target="_blank" name="frmObjeto" onSubmit="return validarform()">
	  <table width="38%" align="center">
       
        <tr>
          <td colspan="5" align="center" class="titulo2">UNIDADES AVALIADAS/A AVALIAR POR EXERCÍCIO</td>
        </tr>
		<tr>
          <td colspan="5" align="center" class="titulo1">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="5" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="5" align="center"><div align="left"><strong class="titulos">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Filtro de sele&ccedil;&atilde;o:
            
          </strong></div></td>
        </tr>
<!--- 
		 <tr>
		   <td colspan="5" align="center">&nbsp;</td>
	    </tr> --->

        <tr>
          <td width="2%"></td>
          <td colspan="4"><strong>
          </strong><strong><span class="exibir">
          </span></strong></td>
        </tr>

 <cfif UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORMASTER' AND qAcesso.Usu_DR eq '01'>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria WHERE Dir_Codigo <> '01'
			</cfquery>
			 <tr valign="baseline">
		     <td width="2%">&nbsp;</td>
             <td width="39%" class="exibir"><strong>Superintend&ecirc;ncia : </strong></td>
			 <td colspan="3">
			   
		       <div align="left">
			       <select name="se" id="se" class="form">
			         <option selected="selected" value="Todos">Todos</option>
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
		     <td width="2%">&nbsp;</td>
             <td width="39%" class="exibir"><strong>Superintend&ecirc;ncia : </strong></td>
			 <td colspan="3"><div align="left">
			   <select name="se" id="se" class="form">
                 <option selected="selected" value="Todos">Todos</option>
                 <cfoutput query="qSE">
                   <option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
                 </cfoutput>
               </select>
			   </div></td>
			 </tr>
        <cfelseif qAcesso.Usu_DR eq '04'>
			 <tr valign="baseline">
		     <td width="2%">&nbsp;</td>
             <td width="39%" class="exibir"><strong>Superintend&ecirc;ncia : </strong></td>
		     <td colspan="3">
			    <div align="left">
			      <select name="se" id="se" class="form">
	                <option selected="selected" value="Todos">Todos</option>
	                <option value="04">AL</option>
			        <option value="70">SE</option>
	              </select>
		       </div></td>
			 </tr>

			 <cfset seprinc= '04'>
	         <cfset sesubor= '70'>
		 <cfelseif qAcesso.Usu_DR eq '10'>
			 <tr valign="baseline">
		     <td width="2%">&nbsp;</td>
             <td width="39%" class="exibir"><strong>Superintend&ecirc;ncia : </strong></td>
		     <td colspan="3">
			   <div align="left">
			     <select name="se"  id="se" class="form">
		              <option selected="selected" value="Todos">Todos</option>
		              <option value="10">BSB</option>
				      <option value="16">GO</option>
	             </select>
			   </div></td>
			 </tr>
			 <cfset seprinc= '10'>
	         <cfset sesubor= '16'>
		<cfelseif qAcesso.Usu_DR eq '06'>
			 <tr valign="baseline">
		     <td width="2%">&nbsp;</td>
             <td width="39%" class="exibir"><strong>Superintend&ecirc;ncia : </strong></td>
		     <td colspan="3">
			   <div align="left">
			     <select name="se" id="se" class="form">
		              <option selected="selected" value="Todos">Todos</option>
		              <option value="06">AM</option>
				      <option value="65">RR</option>
	             </select>
		       </div></td>
			 </tr>
			 <cfset seprinc= '06'>
	         <cfset sesubor= '65'>
		<cfelseif qAcesso.Usu_DR eq '26'>
			 <tr valign="baseline">
		     <td width="2%">&nbsp;</td>
             <td width="39%" class="exibir"><strong>Superintend&ecirc;ncia : </strong></td>
		     <td colspan="3">
			   <div align="left">
			     <select name="se" id="se" class="form">
		              <option selected="selected" value="Todos">Todos</option>
		              <option value="26">RO</option>
				      <option value="03">ACR</option>
	             </select>
		       </div></td>
			 </tr>
			 <cfset seprinc= '26'>
	         <cfset sesubor= '03'>				 
		 <cfelseif qAcesso.Usu_DR eq '28'>
			 <tr valign="baseline">
		     <td width="2%">&nbsp;</td>
             <td width="39%" class="exibir"><strong>Superintend&ecirc;ncia : </strong></td>
		     <td colspan="3">
			   <div align="left">
			     <select name="se" id="se" class="form">
		              <option selected="selected" value="Todos">Todos</option>
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
            <td width="39%" class="exibir"><strong>Tipo de Unidade &nbsp;&nbsp; : </strong></td>
            <td colspan="2">
			<select name="frmtipounid" class="exibir" id="frmtipounid">
			          <option value="Todas">Todas</option>
    			  <cfoutput query="rstpunid">
                      <option value="#TUN_Codigo#">#trim(TUN_Descricao)#</option>  
                  </cfoutput>
            </select>			</td>
          </tr>
		  <cfset cont = year(now())>		  
          <tr>
            <td>&nbsp;</td>
            <td class="exibir"><strong>Exerc&iacute;cio &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: </strong></td>
            <td colspan="2">
			<select name="frmano" class="exibir" id="frmano">
			<option value="Todos" selected="selected">Todos</option>
              <cfloop condition="cont gte 2018">
                <option value="<cfoutput>#cont#</cfoutput>"><cfoutput>#cont#</cfoutput></option>
				<cfset cont = cont - 1>
              </cfloop>
            </select></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td colspan="3">&nbsp;</td>
          </tr>
          <td>&nbsp;</td>
            <td colspan="3">
              <div align="center">
                <input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar">
              </div></td></tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="3">&nbsp;</td>
        </tr>
      </table>
	  <input name="grupoacesso" type="hidden" value="<cfoutput>#ucase(trim(qAcesso.Usu_GrupoAcesso))#</cfoutput>">
  	  <input name="usucoordena" type="hidden" value="<cfoutput>#ucase(trim(qAcesso.Usu_Coordena))#</cfoutput>">
  	  <input name="usumatricula" type="hidden" value="<cfoutput>#ucase(trim(qAcesso.Usu_Matricula))#</cfoutput>">	  
	  
	</form>
</body>
</html>
