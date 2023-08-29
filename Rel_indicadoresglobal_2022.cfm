<!--- #se#  === #frmano#<br> --->
<cfprocessingdirective pageEncoding ="utf-8"/>
  <!--- <cfif day(now()) lte 10>
	 <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=Favor aguardar ate o dia 11 do mes para gerar o relatorio de METAS com os dados atualizados ao mes anterior!">
  </cfif> --->
   
<cfsetting requesttimeout="15000"> 
<cfif IsDefined("url.ninsp")>
<cfset txtNum_Inspecao = url.ninsp>
</cfif>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula, Usu_Coordena from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
 
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfset total=0>

<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">
<script language="javascript">

//=============================

function listar(a,b,c){
	document.formx.lis_se.value=a;
	document.formx.lis_grpace.value=b;
    document.formx.lis_mes.value=c;
	document.formx.submit(); 
}

</script>

</head>
<body>
<form action="" method="post" target="_blank" name="form1">

<!---  --->

<cfset dtlimit = CreateDate(#frmano#,#frmmes#,day(now()))>
<!--- Criar linha de metas --->
<cfquery name="rsMetas" datasource="#dsn_inspecao#">
	SELECT Met_Codigo, Met_Ano, Met_Mes, Met_SE_STO, Met_SLNC, Met_PRCI, Met_EFCI, Met_DGCI, Met_SLNC_Acum, Met_PRCI_Acum, Met_EFCI_Acum
	FROM Metas
	WHERE Met_Ano = #frmano# and Met_Mes = 1
</cfquery>

<cfset nCont = 1>
<cfloop condition="nCont lte int(month(dtlimit))">
	<cfset metprci = trim(numberFormat(rsMetas.Met_PRCI,999.0))>
	<cfset metslnc = rsMetas.Met_SLNC>
	<!--- <cfset metdgci = numberFormat(((metslnc * 0.6) + (metprci * 0.4)),999.0)> --->
	<cfset metdgci = rsMetas.Met_DGCI>
	<cfset metslncmes = numberFormat(((metslnc / 12) * nCont),999.0)>
	<cfset metdgcimes = numberFormat(((metslncmes * 0.6) + (metprci * 0.4)),999.0)>
  <cfquery datasource="#dsn_inspecao#" name="rsCrMes">
	  SELECT Met_Codigo, Met_Ano, Met_Mes, Met_SE_STO, Met_SLNC, Met_PRCI, Met_EFCI, Met_DGCI, Met_SLNC_Acum, Met_PRCI_Acum, Met_EFCI_Acum
	  FROM Metas
	  WHERE Met_Codigo ='#rsMetas.Met_Codigo#' AND Met_Ano = #frmano# AND Met_Mes = #nCont#
  </cfquery>	
  <cfif rsCrMes.recordcount lte 0>		
		<cfquery datasource="#dsn_inspecao#">
		 insert into Metas (Met_Codigo, Met_Ano, Met_Mes, Met_SE_STO, Met_PRCI, Met_SLNC, Met_DGCI, Met_PRCI_Mes, Met_SLNC_Mes, Met_DGCI_Mes, Met_PRCI_Acum, Met_SLNC_Acum, Met_DGCI_Acum, Met_PRCI_AcumPeriodo, Met_SLNC_AcumPeriodo, Met_DGCI_AcumPeriodo) 
		  values ('#rsMetas.Met_Codigo#', #frmano#, #nCont#, '#rsMetas.Met_SE_STO#', '#metprci#', '#metslnc#', '#metdgci#', '#metprci#', '#metslncmes#', '#metdgcimes#', '0.0', '0.0', '0.0', '0.0', '0.0', '0.0')
		</cfquery>    
  </cfif>
	<cfif nCont eq 1>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Metas SET Met_DGCI='#metdgci#', Met_PRCI_Mes='#metprci#', Met_SLNC_Mes='#metslncmes#', Met_DGCI_Mes = '#metdgcimes#'
			WHERE Met_Codigo = '#rsMetas.Met_Codigo#' and Met_Ano = #frmano# and Met_Mes = 1
		</cfquery> 		
	</cfif>  
  <cfset nCont = nCont + 1>
</cfloop>
<!--- fim criar linhas de metas --->
<!---  --->
<cfquery name="rsMetas" datasource="#dsn_inspecao#">
	SELECT Met_Codigo, Met_Ano, Met_Mes, Met_SLNC, Met_PRCI, Met_DGCI, Met_SLNC_Mes, Met_PRCI_Mes, Met_DGCI_Mes, Met_SLNC_Acum, Met_PRCI_Acum, Met_DGCI_Acum, Met_SLNC_AcumPeriodo, Met_PRCI_AcumPeriodo, Met_DGCI_AcumPeriodo
	FROM Metas
	WHERE Met_Ano = #frmano# and Met_Mes = #frmmes#
</cfquery>
<cfoutput query="rsMetas">
  <cfset dgcimes = '0.0'>
  <cfset dgciacum = '0.0'>
  <cfset dgciacumperiodo = '0.0'>
  <cfset dgcimes = trim(numberFormat(((rsMetas.Met_SLNC_Mes * 0.6) + (rsMetas.Met_PRCI_Mes * 0.4)),999.0))>
  <cfset dgciacum = trim(numberFormat(((rsMetas.Met_SLNC_Acum * 0.6) + (rsMetas.Met_PRCI_Acum * 0.4)),999.0))>
  <cfset dgciacumperiodo = round(numberFormat(((rsMetas.Met_SLNC_AcumPeriodo * 0.6) + (rsMetas.Met_PRCI_AcumPeriodo * 0.4)),999.0))> 
  <cfquery datasource="#dsn_inspecao#">
		UPDATE Metas SET Met_DGCI_Mes='#dgcimes#', Met_DGCI_Acum =#dgciacum#, Met_DGCI_AcumPeriodo='#dgciacumperiodo#'
		WHERE Met_Codigo = '#rsMetas.Met_Codigo#' and Met_Ano = #frmano# and Met_Mes = #frmmes#
  </cfquery> 
</cfoutput>
<!---  --->
<!--- Obter solucionados --->
<cfset aux_mes = int(month(dtlimit))>
<cfif aux_mes is 1>
	<cfset dtlimit = (year(dtlimit)) & "/01/31">
	<cfset cabec = 'Jan/' & year(dtlimit)>
<cfelseif aux_mes is 2>
    <cfset cabec = 'Fev/' & year(dtlimit)>
	<cfif int(year(dtlimit)) mod 4 is 0>
	<cfset dtlimit = (year(dtlimit)) & "/02/29">
<cfelse>
    <cfset cabec = 'Fev/' & year(dtlimit)>
	<cfset dtlimit = (year(dtlimit)) & "/02/28">
</cfif>
<cfelseif aux_mes is 3>
	<cfset dtlimit = (year(dtlimit)) & "/03/31">
	<cfset cabec = 'Mar/' & year(dtlimit)>  
<cfelseif aux_mes is 4>
	<cfset dtlimit = (year(dtlimit)) & "/04/30">		
	<cfset cabec = 'Abr/' & year(dtlimit)>
<cfelseif aux_mes is 5>
	<cfset dtlimit = (year(dtlimit)) & "/05/31">	
	<cfset cabec = 'Mai/' & year(dtlimit)>	
<cfelseif aux_mes is 6>
	<cfset dtlimit = (year(dtlimit)) & "/06/30">	
	<cfset cabec = 'Jun/' & year(dtlimit)>				   
<cfelseif aux_mes is 7>
	<cfset dtlimit = (year(dtlimit)) & "/07/31">	
	<cfset cabec = 'Jul/' & year(dtlimit)>				   
<cfelseif aux_mes is 8>
	<cfset dtlimit = (year(dtlimit)) & "/08/31">	
	<cfset cabec = 'Ago/' & year(dtlimit)>				   
<cfelseif aux_mes is 9>
	<cfset dtlimit = (year(dtlimit)) & "/09/30">		
	<cfset cabec = 'Set/' & year(dtlimit)>			   
<cfelseif aux_mes is 10>
	<cfset dtlimit = (year(dtlimit)) & "/10/31">		
	<cfset cabec = 'Out/' & year(dtlimit)>			   
<cfelseif aux_mes is 11>
	<cfset dtlimit = (year(dtlimit)) & "/11/30">		
	<cfset cabec = 'Nov/' & year(dtlimit)>			   
<cfelse>
	<cfset dtlimit = (year(dtlimit)) & "/12/31">				
	<cfset cabec = 'Dez/' & year(dtlimit)>	   
</cfif>
<!--- <cfoutput>
#dtlimit#
</cfoutput>
<cfset gil = gil> --->
<!--- <cfquery name="rsMetas" datasource="#dsn_inspecao#">
	SELECT Met_Codigo, Met_Ano, Met_Mes, Met_SE_STO, Met_SLNC, Met_PRCI, Met_EFCI, Met_DGCI, Met_SLNC_Acum, Met_PRCI_Acum, Met_EFCI_Acum, 
	FROM Metas
	WHERE Met_Ano = '#frmano#' and Met_Mes = #frmmes#
</cfquery>


<cfquery name="rsAjuste" datasource="#dsn_inspecao#">
	SELECT Met_Codigo, Met_Ano, Met_Mes, Dir_Sigla, Met_SE_STO, Met_SLNC, Met_SLNC_Mes, Met_PRCI, Met_DGCI, Met_SLNC_Acum, Met_PRCI_Acum 
	FROM Metas INNER JOIN Diretoria ON Met_Codigo = Dir_Codigo
	WHERE (Met_Ano = #frmano#) and (Met_Mes = #frmmes#)
</cfquery>

<cfset DGCIM = 0>
<cfset DGCIA = 0>
<cfoutput query="rsAjuste">
	<cfset DGCIA = numberFormat((rsAjuste.Met_SLNC_Acum * 0.6) + (rsAjuste.Met_PRCI_Acum * 0.4),999.0)>
 	<cfset DGCIM = numberFormat((rsAjuste.Met_SLNC_Mes * 0.6) + (rsAjuste.Met_PRCI * 0.4),999.0)>

    <cfset auxdif = numberFormat(((DGCIA * 100)/DGCIM),999.0)>
<!--- 	DGCIA: #DGCIA# Met_Codigo = '#rsAjuste.Met_Codigo#' and Met_Ano = #rsAjuste.Met_Ano# and Met_Mes = #rsAjuste.Met_Mes#  dgcia:#DGCIA#  DGCIM: #DGCIM# e valor:#auxdif#<br> --->
	<cfquery datasource="#dsn_inspecao#">
		UPDATE Metas SET Met_DGCI='#DGCIA#', Met_Resultado = #auxdif#
		WHERE Met_Codigo = '#rsAjuste.Met_Codigo#' and Met_Ano = #frmano# and Met_Mes = #frmmes#
	</cfquery> 

</cfoutput> --->

<!--- exibicao em tela --->
<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER'>
	<cfquery name="rsMetas" datasource="#dsn_inspecao#">
		SELECT Met_Codigo, Met_Ano, Dir_Sigla, Met_SE_STO, Met_SLNC, Met_SLNC_Mes, Met_PRCI, Met_PRCI_Mes, Met_PRCI_Acum, Met_DGCI, Met_SLNC_Acum, Met_SLNC_AcumPeriodo, Met_PRCI_AcumPeriodo, Met_DGCI_Mes, Met_DGCI_Acum, Met_DGCI_AcumPeriodo 
		FROM Metas INNER JOIN Diretoria ON Met_Codigo = Dir_Codigo
		WHERE (Met_Ano = #frmano#) and Met_Mes = #frmmes#
		ORDER BY Met_DGCI_AcumPeriodo DESC
	</cfquery>
<cfelse>
	<cfquery name="rsMetas" datasource="#dsn_inspecao#">
		SELECT Met_Codigo, Met_Ano, Dir_Sigla, Met_SE_STO, Met_SLNC, Met_SLNC_Mes, Met_PRCI, Met_PRCI_Mes, Met_PRCI_Acum, Met_DGCI, Met_SLNC_Acum, Met_SLNC_AcumPeriodo, Met_PRCI_AcumPeriodo, Met_DGCI_Mes, Met_DGCI_Acum, Met_DGCI_AcumPeriodo 
		FROM Metas INNER JOIN Diretoria ON Met_Codigo = Dir_Codigo
		WHERE (Met_Ano = #frmano#) and Met_Mes = #frmmes# and Met_Codigo in(#qUsuario.Usu_Coordena#)
		ORDER BY Met_DGCI_AcumPeriodo DESC
	</cfquery>
</cfif>
<!--- Criação do arquivo CSV --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>
<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.csv'>

<!--- Excluir arquivos anteriores ao dia atual --->
<cfdirectory name="qList" filter="*.csv" sort="name desc" directory="#slocal#">
<cfloop query="qList">
	<cfif (left(name,8) lt left(sdata,8)) or (mid(name,12,8) eq trim(qUsuario.Usu_Matricula))>
	  <cffile action="delete" file="#slocal##name#">
	</cfif>
</cfloop>
<cffile action="write" addnewline="no" file="#slocal##sarquivo#" output=''>
<cfset auxcab = 'RESULTADO EM RELAÇÃO À META ' & #ucase(cabec)#>
<cffile action="Append" file="#slocal##sarquivo#" output='#auxcab#'>
<cffile action="Append" file="#slocal##sarquivo#" output=';PRCI;;;SLNC;;;DGCI;;;Diferença em'>
<cffile action="Append" file="#slocal##sarquivo#" output='SE;Meta;Resultado;Parcial;Meta;Resultado;Parcial;Meta;Resultado;Parcial;Relação à Meta'>
<!--- <cfset auxRazao = (rsMetas.Met_SLNC/12)> --->
<cfset auxRazao = numberFormat((rsMetas.Met_SLNC/12),999.0)> 
<!--- <cfset auxRazao = rsMetas.Met_SLNC_Mes> --->


<table width="97%" border="1" align="center" cellpadding="0" cellspacing="0">

  <tr>
	<td colspan="22"><div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/csv.png" width="45" height="45" border="0"></a></div></td>
</tr>
  <tr>
    <td colspan="22" class="titulos"><div align="center"><strong> RESULTADO EM RELA&Ccedil;&Atilde;O &Agrave; META  <cfoutput>#ucase(cabec)#</cfoutput></strong></div></td>
  </tr>
  <tr>
    <td width="2%" class="titulos"><div align="center">&nbsp;</div></td>
    <td colspan="3" class="titulos"><div align="center"></div>      <div align="center">PRCI</div></td>
    <td colspan="3" class="titulos"><div align="center">SLNC</div></td>
    <td colspan="14" class="titulos"><div align="center">DGCI</div></td>
    <td width="12%" rowspan="2" class="titulos"><div align="center">Resultado em Rela&ccedil;&atilde;o &agrave; Meta </div>      
      <div align="center"></div></td>
  </tr>
    <tr>
    <td class="titulos"><div align="center">SE</div></td>
    <td width="6%" class="titulos"><div align="center"></div>      <div align="center"></div>      <div align="center"></div>      <div align="center">Meta</div></td>
    <td width="7%" class="titulos"><div align="center">Resultado</div></td>
    <td width="15%" class="titulos"><div align="center">Parcial</div></td>
    <td width="6%" class="titulos"><div align="center">Meta</div></td>
    <td width="7%" class="titulos"><div align="center">Resultado</div></td>
    <td width="14%" class="titulos"><div align="center">Parcial</div></td>
    <td colspan="12" class="titulos"><div align="center">Meta</div></td>
    <td width="7%" class="titulos"><div align="center">Resultado</div></td>
    <td width="12%" class="titulos"><div align="center">Parcial</div></td>
    </tr>
  <tr>
    <td colspan="22" class="exibir"><div align="center"></div></td>
  </tr>
  <tr class="exibir">
    <td colspan="11"><div align="center"></div>      <div align="center"></div>        <div align="center"></div></td>
	<!--- <cfset totgeral = rsitem.recordcount> --->
    </tr>

<cfset PRCInac = 0>
<cfset PRCIAPnac = 0>
<cfset SLNCnac = 0>
<cfset SLNCAPnac = 0>
<cfset DGCInac = 0>
<cfset DGCIAPnac = 0>
<cfset RESMETnac = 0>
<cfset mesrel = frmmes>	
<cfoutput query="rsMetas">
	<cfset se = rsMetas.Dir_Sigla>
	<cfset DGCIM = 0>	
	<!--- PRCI --->
	<cfset PRCIm = rsMetas.Met_PRCI_Mes>
	<cfset PRCIAP = numberFormat(rsMetas.Met_PRCI_AcumPeriodo,999.0)>
    <cfif PRCIAP gt PRCIm>
		<cfset PRCIRes = "ACIMA DO ESPERADO">
		<cfset scorb = "##33CCFF">
    <cfelseif PRCIAP eq PRCIm>		
		<cfset PRCIRes = "DENTRO DO ESPERADO">
		<cfset scorb = "##339900">
    <cfelse>
		<cfset PRCIRes = "ABAIXO DO ESPERADO">
		<cfset scorb = "##FF3300">
	</cfif>	
	
	<!--- SLNC --->
	<!--- <cfset SLNCA = rsMetas.Met_SLNC_Acum> --->
	<cfset SLNCAP = numberFormat(rsMetas.Met_SLNC_AcumPeriodo,999.0)>
	<cfset auxRazao = numberFormat(rsMetas.Met_SLNC_Mes,999.0)>
	<!--- <cfset auxRazao = rsMetas.Met_SLNC_Mes> --->
	<cfset SLNCm = numberFormat(rsMetas.Met_SLNC_Mes,999.0)>
	<cfset SLNCAP = rsMetas.Met_SLNC_AcumPeriodo>
	<!--- MES:#mesrel# SLNC:#SLNC#  SLNCAP:#SLNCAP#
	<CFSET GIL = GIL> --->
	<cfif SLNCAP gt SLNCm>
		<cfset SLNCRes = "ACIMA DO ESPERADO">
		<cfset scorc = "##33CCFF">
    <cfelseif SLNCAP eq SLNCm>		
		<cfset SLNCRes = "DENTRO DO ESPERADO">
		<cfset scorc = "##339900">
    <cfelse>
		<cfset SLNCRes = "ABAIXO DO ESPERADO">
		<cfset scorc = "##FF3300">
	</cfif>	

	<cfset DGCIM = numberFormat((SLNCm * 0.6) + (rsMetas.Met_PRCI * 0.4),999.0)>
<!--- 	<cfset DGCIM = numberFormat(DGCIM + (SLNCm * 0.4),'__.00')> --->
	
 	<cfset DGCIm = numberFormat((rsMetas.Met_DGCI_Mes),999.0)>
<!--- 	<cfset DGCIM = numberFormat(rsMetas.Met_DGCI,999.0)>
 	<cfset DGCIA = numberFormat(rsMetas.Met_Resultado,999.0)> --->
	<!--- <CFSET auxdif = numberFormat(((DGCIA * 100)/DGCIM),999.0)> --->

	
	<!--- <cfset RESMETnac = (RESMETnac) + (DGCIA - DGCIM)>  --->
<!--- 	<cfset DGCIA = numberFormat(rsMetas.Met_DGCI_Acum,999.0)>  --->
	<!--- <cfset DGCIAP = numberFormat(rsMetas.Met_DGCI_AcumPeriodo,999.0)> --->
	<cfset DGCIAP = numberFormat((rsMetas.Met_SLNC_AcumPeriodo * 0.6) + (rsMetas.Met_PRCI_AcumPeriodo * 0.4),999.0)>
	<cfif DGCIAP gt DGCIm>
		<cfset DGCIRes = "ACIMA DO ESPERADO">
		<cfset scord = "##33CCFF">
	<cfelseif DGCIAP eq DGCIm>		
		<cfset DGCIRes = "DENTRO DO ESPERADO">
		<cfset scord = "##339900">
	<cfelse>
		<cfset DGCIRes = "ABAIXO DO ESPERADO">
		<cfset scord = "##FF3300">
	</cfif>	
	<CFSET permeta = numberFormat((DGCIAP/DGCIm)*100,999.0)>
	<tr>
    <td class="exibir"><div align="center"><strong>#se#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#PRCIm#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#PRCIAP#</strong></div></td>
    <td bgcolor="#scorb#" class="exibir"><div align="center">#PRCIRes#</div></td>
	<td class="exibir"><div align="center"><strong>#SLNCm#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#SLNCAP#</strong></div></td>
    <td bgcolor="#scorc#" class="exibir"><div align="center">#SLNCRes#</div></td>
    <td colspan="12" class="exibir"><div align="center"><strong>#DGCIm#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#DGCIAP#</strong></div></td>
    <td bgcolor="#scord#" class="exibir"><div align="center">#DGCIRes#</div></td>
	
	<td class="exibir"><div align="center"><strong>#permeta#</strong></div></td>
    <!--- <td class="exibir"><div align="center"><strong>#auxdif#</strong></div></td> --->
  	</tr>

	<cfset PRCInac = PRCInac + PRCIm>
	<cfset PRCIAPnac = PRCIAPnac + PRCIAP>
	<cfset SLNCnac = SLNCnac + SLNCm>
	<cfset SLNCAPnac = SLNCAPnac + SLNCAP>
	<cfset DGCInac = DGCInac + DGCIm>
	<cfset DGCIAPnac = DGCIAPnac + DGCIAP>
	<cfset RESMETnac = RESMETnac + permeta>
	<!--- #auxdif#  #RESMETnac#<br> --->
	 
	
	<!--- <cfset gil = gil> --->
<!---   <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_DGCI = '#DGCIA#' WHERE Met_Codigo='#rsMetas.Met_Codigo#' and Met_Ano = #frmano# and Met_Mes = #frmmes#
  </cfquery> --->
<!---    <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_DGCI = '#DGCIA#' WHERE Met_Codigo='#rsMetas.Met_Codigo#' and Met_Ano = #year(dtlimit)# and Met_Mes = 13
  </cfquery>  --->
<cffile action="Append" file="#slocal##sarquivo#" output='#se#;#PRCIm#;#PRCIAP#;#PRCIRes#;#SLNCm#;#SLNCAP#;#SLNCRes#;#DGCIm#;#DGCIAP#;#DGCIRes#;#permeta#'>
</cfoutput>	
    <cfset PRCInac = numberFormat((PRCInac / rsMetas.recordcount) ,999.0)>
	<cfset PRCIAPnac = numberFormat((PRCIAPnac / rsMetas.recordcount) ,999.0)>	
    <cfset SLNCnac = numberFormat((SLNCnac / rsMetas.recordcount) ,999.0)>
	<cfset SLNCAPnac = numberFormat((SLNCAPnac / rsMetas.recordcount) ,999.0)>	
    <cfset DGCInac = numberFormat((DGCInac / rsMetas.recordcount) ,999.0)>
	<cfset DGCIAPnac = numberFormat((DGCIAPnac / rsMetas.recordcount) ,999.0)>	
<!--- 	<cfset RESMETnac = numberFormat((RESMETnac / rsMetas.recordcount) ,999.0)>	 ---> 
	
	
	<!---  --->
    <cfif PRCIAPnac gt PRCInac>
		<cfset PRCIRes = "ACIMA DO ESPERADO">
		<cfset scorb = "##33CCFF">
    <cfelseif PRCInac eq PRCIAPnac>		
		<cfset PRCIRes = "DENTRO DO ESPERADO">
		<cfset scorb = "##339900">
    <cfelse>
		<cfset PRCIRes = "ABAIXO DO ESPERADO">
		<cfset scorb = "##FF3300">
	</cfif>	
	<cfif SLNCAPnac gt SLNCnac>
		<cfset SLNCRes = "ACIMA DO ESPERADO">
		<cfset scorc = "##33CCFF">
    <cfelseif SLNCnac eq SLNCAPnac>		
		<cfset SLNCRes = "DENTRO DO ESPERADO">
		<cfset scorc = "##339900">
    <cfelse>
		<cfset SLNCRes = "ABAIXO DO ESPERADO">
		<cfset scorc = "##FF3300">
	</cfif>	
	<cfif DGCIAPnac gt DGCInac>
		<cfset DGCIRes = "ACIMA DO ESPERADO">
		<cfset scord = "##33CCFF">
	<cfelseif DGCInac eq DGCIAPnac>		
		<cfset DGCIRes = "DENTRO DO ESPERADO">
		<cfset scord = "##339900">
	<cfelse>
		<cfset DGCIRes = "ABAIXO DO ESPERADO">
		<cfset scord = "##FF3300">
	</cfif>			
	<!---  --->
<cfoutput>
<tr>
    <td bgcolor="CCCCCC" class="titulos"><div align="center">&nbsp;</div></td>
    <td bgcolor="##CCCCCC" class="titulos"><div align="center"></div>      <div align="center"></div>      <div align="center"></div>      <div align="center">Meta Nacional </div></td>
    <td bgcolor="CCCCCC" class="titulos"><div align="center">Resultado Nacional </div></td>
    <td bgcolor="CCCCCC" class="titulos"><div align="center"></div></td>
    <td bgcolor="CCCCCC" class="titulos"><div align="center">Meta Nacional </div></td>
    <td bgcolor="CCCCCC" class="titulos"><div align="center">Resultado Nacional </div></td>
    <td bgcolor="CCCCCC" class="titulos"><div align="center"></div></td>
    <td colspan="12" bgcolor="CCCCCC" class="titulos"><div align="center">Meta Nacional</div></td>
    <td width="7%" bgcolor="CCCCCC" class="titulos"><div align="center">Resultado Nacional</div></td>
    <td width="12%" bgcolor="CCCCCC" class="titulos"><div align="center">&nbsp;</div></td>
	<td width="12%" bgcolor="CCCCCC" class="titulos"><div align="center">&nbsp;</div></td>
    </tr>
   <cffile action="Append" file="#slocal##sarquivo#" output=';Meta Nacional;Resultado Nacional;;Meta Nacional;Resultado Nacional;;Meta Nacional;Resultado Nacional;;Meta'>
   <CFSET RESMETnac = numberFormat((DGCIAPnac/DGCInac)*100,999.0)>
	<tr>
    <td class="titulos"><div align="center">&nbsp;</div></td>
    <td class="titulos"><div align="center">#PRCInac#%</div></td>
    <td class="titulos"><div align="center">#PRCIAPnac#%</div></td>
    <td bgcolor="#scorb#" class="titulos"><div align="center">#PRCIRes#</div></td>
    <td class="titulos"><div align="center">#SLNCnac#%</div></td>
    <td class="titulos"><div align="center">#SLNCAPnac#%</div></td>
    <td bgcolor="#scorc#" class="titulos"><div align="center">#SLNCRes#</div></td>
    <td colspan="12" class="titulos"><div align="center">#DGCInac#%</div></td>
    <td width="7%" class="titulos"><div align="center">#DGCIAPnac#%</div></td>
    <td bgcolor="#scord#" width="12%" class="titulos"><div align="center">#DGCIRes#</div></td>
	<td width="12%" class="titulos"><div align="center">#RESMETnac#%</div></td>
    </tr>
   <cffile action="Append" file="#slocal##sarquivo#" output=';#PRCInac#%;#PRCIAPnac#%;#PRCIRes#;#SLNCnac#%;#SLNCAPnac#%;#SLNCRes#;#DGCInac#%;#DGCIAPnac#%;#DGCIRes#;#RESMETnac#%'>	
	</cfoutput>
</table>

<!--- fim exibicao --->
</form>
  <cfinclude template="rodape.cfm">
</body>
</html>

