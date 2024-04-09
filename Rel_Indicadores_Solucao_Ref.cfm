<cfprocessingdirective pageEncoding ="utf-8"> 
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  
<!---  --->

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena, Dir_Descricao, Usu_Matricula
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
order by Dir_Sigla
</cfquery>
<cfset grpacesso = ucase(trim(qAcesso.Usu_GrupoAcesso))>
<!---  <cfif TRIM(qAcesso.Usu_GrupoAcesso) NEQ 'GESTORMASTER'>
	 <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=PAGINA DE INDICADORES SLNC EM MANUTENCAO ATE 12h!">
</cfif>   --->
<cfset auxanoatu = year(now())>
<cfquery name="rsAno" datasource="#dsn_inspecao#">
SELECT Andt_AnoExerc
FROM Andamento_Temp
GROUP BY Andt_AnoExerc
HAVING Andt_AnoExerc > '2021' and Andt_AnoExerc < '#auxanoatu#'
ORDER BY Andt_AnoExerc DESC
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
<cfset auxdia = int(day(now()))>
<cfset aux_mes = int(month(now()))>
<cfset aux_ano = int(year(now()))>
<cfif grpacesso eq 'GESTORMASTER'>
   <cfif (aux_mes eq 1) or (aux_mes eq 2 and auxdia lte 10)>
		<cfset aux_mes = 12>
		<cfset aux_ano = aux_ano - 1>
	<cfelseif (aux_mes gt 2 and auxdia lte 10)>
		<cfset aux_mes = (aux_mes - 1)>
	<cfelse>
		<cfset aux_mes = (aux_mes - 1)>		
   </cfif>

<cfelse>
	<cfif (aux_mes eq 1) or (aux_mes eq 2 and auxdia lte 10)>
		<cfset aux_mes = 12>
		<cfset aux_ano = aux_ano - 1>
	<cfelseif (aux_mes gt 2 and auxdia lte 10)>
		<cfset aux_mes = (aux_mes - 2)>
	<cfelse>
		<cfset aux_mes = (aux_mes - 1)>
	</cfif>
</cfif>
<!---
 <cfoutput>aux_ano:#aux_ano#  === aux_mes:#aux_mes#</cfoutput><BR> 
 <cfset gil = gil>  --->  
   
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
<cfoutput>
aux_ano:#aux_ano#  === aux_mes:#aux_mes#<br>
 dtlimit#dtlimit#<br> 
<CFSET GIL = GIL>   
</cfoutput>
--->

<cfoutput>
<cfif grpacesso eq 'SUPERINTENDENTE' OR grpacesso eq 'GERENTES' OR grpacesso eq 'ORGAOSUBORDINADOR' OR grpacesso eq 'SUBORDINADORREGIONAL'>
	
    <cflocation url="Rel_Indicadores_Solucao.cfm?se=#qAcesso.Usu_DR#&anoexerc=#year(dtlimit)#&dtlimit=#dtlimit#&frmano=#year(dtlimit)#">
	<!--- <cfinclude template="cabecalho.cfm"> --->
</cfif>
</cfoutput>
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
	//alert(frm.anoatual.value + '  ' + frm.frmano.value);
	frm.anoexerc.value = frm.frmano.value;
	var auxdt = frm.dtlimitatual.value; 
	//frm.dtlimit.value = frm.frmano.value + auxdt.substring(4,10);
	
	if (frm.frmano.value < frm.anoatual.value)
	{
	//alert(frm.anoatual.value + '  ' + frm.frmano.value);
	//frm.dtlimit.value = frm.frmano.value + '/12/31';
	} 
//alert(frm.anoatual.value + '  ' + frm.frmano.value + '  ' + frm.dtlimit.value);

	//alert(frm.dtlimit.value);
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
</head>
<br>
<body>


<tr>
   <td colspan="6" align="center">&nbsp;</td>
</tr>

<!--- �rea de conte�do   --->
	<form action="Rel_Indicadores_Solucao.cfm" method="get" target="_blank" name="frmObjeto" onSubmit="return valida_form()">
	  <table width="59%" align="center">
	  <cfif grpacesso eq "SUPERINTENDENTE">
		<tr>
		<td colspan="5" align="center"><cfoutput><span class="titulo2">#qAcesso.Dir_Descricao#</span></cfoutput></td>
		</tr>
		<tr>
		<td colspan="5" align="center">&nbsp;</td>
		</tr>
	  </cfif>
       
        <tr>
          <td colspan="5" align="center" class="titulo2"><strong> Solu&Ccedil;&Atilde;o de N&Atilde;o Conformidades (SLNC)</strong> </td>
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
		   <cfif grpacesso eq 'GESTORMASTER' or grpacesso eq 'GOVERNANCA'>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where dir_codigo <> '01'
			</cfquery>
			 	<select name="se" id="se" class="form">
		          <option selected="selected" value="---">---</option>
				  <cfoutput query="qSE">
		          	<option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
				  </cfoutput>
		        </select>
		<cfelseif (grpacesso eq 'GESTORES' OR grpacesso eq 'ANALISTAS') AND len(TRIM(qAcesso.Usu_Coordena)) gt 0> 
		
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

  
          <tr>
            <td>&nbsp;</td>
            <td class="exibir"><strong>Ano : </strong></td>
            <td colspan="2">
			<select name="frmano" class="exibir" id="frmano">
			 <cfoutput> <option value="#year(now())#">#year(now())#</option></cfoutput>
			<cfoutput query="rsAno">
			  <option value="#rsAno.Andt_AnoExerc#" <cfif rsAno.Andt_AnoExerc eq year(now())>selected</cfif>>#rsAno.Andt_AnoExerc#</option>
			  </cfoutput>
            </select>
			
			</td>
          </tr>
          <td>&nbsp;</td>
            <td colspan="3">
              <div align="center">
                <input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar" onClick="document.frmObjeto.ckTipo.value='ano';">
            </div></td></tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="3">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="2" bgcolor="#E5E5E5" class="red_titulo"><div align="center" class="red_titulo">Estimativa de Gera&ccedil;&atilde;o do relat&oacute;rio em tela. &nbsp;&nbsp;At&eacute;  10 min! </div></td>
        </tr>
      </table>

	  <input name="dtlimit" type="hidden" value="<cfoutput>#dtlimit#</cfoutput>">
	  <input name="dtlimitatual" type="hidden" value="<cfoutput>#dtlimit#</cfoutput>">
	  <input name="anoexerc" type="hidden" value="<cfoutput>#year(dtLimit)#</cfoutput>">
	  <input name="anoatual" type="hidden" value="<cfoutput>#year(now())#</cfoutput>">
	   
<!--- <cfoutput>#dtlimit#</cfoutput><br>
<cfoutput>#dtlimit#</cfoutput><br>
<cfoutput>#year(dtLimit)#</cfoutput><br>
<cfoutput>#year(now())#</cfoutput>	 --->  
	  
	</form>
</body>
</html>
