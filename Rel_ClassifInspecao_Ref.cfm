<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
 <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>    
<!---  --->

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena, Dir_Descricao 
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<!--- <cfif (cgi.REMOTE_USER neq "CORREIOSNET\80144276") and (cgi.REMOTE_USER neq "CORREIOSNET\85051071") AND (cgi.REMOTE_USER neq "CORREIOSNET\85051160") and (cgi.REMOTE_USER neq "CORREIOSNET\89094158") and (cgi.REMOTE_USER neq "CORREIOSNET\81062117")>
<p>=================== Aguarde! =======================</p>
<p>============== Pagina em  Manutencao! =================</p>
<p>============== Previsao de retorno as ??h =================</p>
<cfabort>
</cfif>   --->
<!--- =========================== --->
<cfquery name="rsStatus" datasource="#dsn_inspecao#">
  SELECT STO_Codigo, STO_Sigla, STO_Descricao
  FROM Situacao_Ponto where (STO_Status = 'A') and (STO_Codigo in (1,2,4,5,6,7,8,9,14,21,22))
  order by Sto_Sigla
</cfquery>
<!--- =========================== --->
<cfset aux_mes = int(month(now()))>
<cfif UCASE(TRIM(qAcesso.Usu_GrupoAcesso)) EQ 'GESTORMASTER'>
	 <!--- <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=PAGINA DE INDICADORES SLNC EM MANUTENCAO!"> --->
<cfelse> 
  <cfif day(now()) lte 10>
	 <!--- <cfset auxajusdt = year(now()) & '/' & (month(now()) - 1)>
	 <cfset dtlimit = year(now()) & auxajusdt & '28'> --->
	 <cfset aux_mes = int(month(now()) - 1)>
  </cfif>
</cfif> 

<!--- <cfset aux_mes = url.mes> --->
<cfif aux_mes is 1>
  <cfset dtlimit = (year(now()) - 1) & "/12/31">
<cfelseif aux_mes is 2>
  <cfset dtlimit = (year(now())) & "/01/31">
<cfelseif aux_mes is 3>
	<cfif int(year(now())) mod 4 is 0>
	   <cfset dtlimit = (year(now())) & "/02/29">
	<cfelse>
	   <cfset dtlimit = (year(now())) & "/02/28">
	</cfif>
<cfelseif aux_mes is 4>
  <cfset dtlimit = (year(now())) & "/03/31">
<cfelseif aux_mes is 5>
	   <cfset dtlimit = (year(now())) & "/04/30">		
<cfelseif aux_mes is 6>
	   <cfset dtlimit = (year(now())) & "/05/31">		
<cfelseif aux_mes is 7>
	   <cfset dtlimit = (year(now())) & "/06/30">					   
<cfelseif aux_mes is 8>
	   <cfset dtlimit = (year(now())) & "/07/31">					   
<cfelseif aux_mes is 9>
	   <cfset dtlimit = (year(now())) & "/08/31">					   
<cfelseif aux_mes is 10>
	   <cfset dtlimit = (year(now())) & "/09/30">					   
<cfelseif aux_mes is 11>
	   <cfset dtlimit = (year(now())) & "/10/31">					   
<cfelse>
	   <cfset dtlimit = (year(now())) & "/11/30">					   
</cfif>


<!--- <cfset dtlimit = ("2021/10/31")> --->
<cfif UCASE(trim(qAcesso.Usu_GrupoAcesso)) eq "SUPERINTENDENTE">
    <cflocation url="Rel_ClassifInspecao.cfm?se=#qAcesso.Usu_DR#&dtlimit=#dtlimit#">
	<!--- <cfinclude template="cabecalho.cfm"> --->
</cfif>
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">

function valida_form() {
    var frm = document.forms[0];
    if (frm.se.value=='---'){
	  alert('Informar a Superintendência!');
	  frm.se.focus();
	  return false;
	}	
//=========================================	
	if (frm.mes.value=='---'){
	  alert('Informar o Mês!');
	  frm.mes.focus();
	  return false;
	}
//=========================================	
	if (frm.ano.value=='---'){
	  alert('Informar o Ano!');
	  frm.ano.focus();
	  return false;
	} 	 
//return false;
//=========================================	
	if (frm.trimetre.value=='---'){
	  alert('Informar o trimetre!');
	  frm.trimetre.focus();
	  return false;
	} 	 
//return false;
}
function mudar(a){
//alert(a);
//var frm = document.forms[0];
//if (a == 'mes') {frm.trimestre.selectedIndex = 0;}
//if (a == 'tri') {frm.mes.selectedIndex = 0;}
}
//================
</script>
 <link href="css.css" rel="stylesheet" type="text/css">
 <style type="text/css">
<!--
.style1 {font-size: 12px}
-->
 </style>
</head>
<br>
<body>


<tr>
   <td colspan="6" align="center">&nbsp;</td>
</tr>

<!--- Área de conteúdo   --->
	<form action="Rel_ClassifInspecao.cfm" method="post" target="_blank" name="frmObjeto" onSubmit="return valida_form()">
	  <table width="59%" align="center">
	  <cfif UCASE(trim(qAcesso.Usu_GrupoAcesso)) eq "SUPERINTENDENTE">
		<tr>
		<td colspan="5" align="center"><cfoutput><span class="titulo2">#qAcesso.Dir_Descricao#</span></cfoutput></td>
		</tr>
		<tr>
		<td colspan="5" align="center">&nbsp;</td>
		</tr>
	  </cfif>  
        <tr>
          <td colspan="5" align="center" class="titulo2"><strong> Efic&Aacute;cia de Controle Interno das Unidades Operacionais (EFCI)</strong> </td>
        </tr>
		<tr>
          <td colspan="5" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="5" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="5" align="center"><div align="left"><strong class="titulo1">Pesquisa por:
            
          </strong></div></td>
        </tr>

		 <tr>
		   <td colspan="5" align="center">&nbsp;</td>
	    </tr>

        <tr>
          <td width="1%"></td>
          <td colspan="4"><strong>
          </strong><strong><span class="exibir">
          </span></strong></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td width="23%"><strong><span class="exibir">Superintend&ecirc;ncia :</span></strong> </td>
          <td width="76%" colspan="3">
		  <!---  --->
		   <cfif UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORMASTER' AND qAcesso.Usu_DR eq '01'>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria
			</cfquery>
			 	<select name="se" id="se" class="form">
		          <option selected="selected" value="---">---</option>
				  <cfoutput query="qSE">
		          	<option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
				  </cfoutput>
		        </select>
		<cfelseif UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORES' AND len(TRIM(qAcesso.Usu_Coordena)) gt 0> 
		
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
		  <!---  --->
		  </td>
	    </tr>
        <!--- <tr>
          <td>&nbsp;</td>
          <td class="exibir"><strong>Ano(se=20 e 50 falha) </strong></td>
          <td colspan="3"><select name="ano" class="form" id="ano" tabindex="3">
           <!---  <option selected="selected" value="---">---</option> --->
                  <option value="2018">2018</option>
				  <option value="2019">2019</option>
				  <option value="2020">2020</option>
				  <option selected="selected" value="2021">2021</option>
          </select></td>
        </tr> --->
        <!--- <tr>
          <td>&nbsp;</td>
          <td class="exibir"><strong>Trimestre</strong></td>
          <td colspan="3"><select name="trimestre" class="form" id="trimestre" tabindex="3" onChange="mudar('mes')">
            <option selected="selected" value="---">---</option>
                <option selected="selected" value="---">---</option>
                  <option value="1">Primeiro</option>
				  <option value="2">Segundo</option>
				  <option value="3">Terceiro</option>
				  <option value="4">Quarto</option>
          </select>
          </select></td>
        </tr> --->
         <!--- <tr>
          <td>&nbsp;</td>
          <td class="exibir"><strong>M&ecirc;s(se=74 falha)</strong></td>
          <td colspan="3"><select name="mes" class="form" id="mes" tabindex="3" onChange="mudar('tri')">
		  <option selected="selected" value="---">---</option>
<cfset aux_mes = 1>
<cfloop condition="#aux_mes# lte 12">
   <cfif aux_mes lt int(month(now()))>
        <cfif aux_mes is 1>
		  	<option value="01">Janeiro</option>
		<cfelseif aux_mes is 2>
			<option value="02">Fevereiro</option>			
		<cfelseif aux_mes is 3>
              <option value="03">Março</option>
		<cfelseif aux_mes is 4>
              <option value="04">Abril</option>		
		<cfelseif aux_mes is 5>
              <option value="05">Maio</option>	
		<cfelseif aux_mes is 6>
              <option value="06">Junho</option>		
		<cfelseif aux_mes is 7>
              <option value="07">Julho</option>	
		<cfelseif aux_mes is 8>
              <option value="08">Agosto</option>
		<cfelseif aux_mes is 9>
              <option value="09">Setembro</option>
		<cfelseif aux_mes is 10>
              <option value="10">Outubro</option>	
		<cfelseif aux_mes is 11>
              <option value="11">Novembro</option>	
		<cfelse>
              <option value="12">Dezembro</option>
		</cfif>
		
	</cfif>
	<cfset aux_mes = aux_mes + 1>
</cfloop>
		  </select>
		  </td>
        </tr> --->
         <tr>
           <td>&nbsp;</td>
           <td colspan="2">&nbsp;</td>
         </tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="2"><div align="right">
            <input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar" onClick="document.frmObjeto.ckTipo.value='ano';">
          </div></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="2">&nbsp;</td>
        </tr>

      </table>

	  <input name="dtlimit" type="hidden" value="<cfoutput>#dtlimit#</cfoutput>">
	</form>
</body>
</html>

