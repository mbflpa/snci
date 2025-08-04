<!--- #se#  === #frmano#<br> --->
<cfprocessingdirective pageEncoding ="utf-8"> 
<cfsetting requesttimeout="15000"> 
<cfif IsDefined("url.ninsp")>
<cfset txtNum_Inspecao = url.ninsp>
</cfif>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso,Usu_Matricula,Usu_Coordena,Usu_DR from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset grpacesso = ucase(Trim(qUsuario.Usu_GrupoAcesso))>

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
<cfset dtlimit = CreateDate(#frmano#,#frmmes#,1)>

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

<cfoutput>
<cfset dtini = dateformat(now(),"DD/MM/YYYY")>
<cfset dtini = '01' & right(dtini,8)>
<cfset dtfim = now()>
<cfset dtfim = DateAdd( "d", -1, dtfim)>
<cfif aux_mes eq month(now())>
  <cfset cabec = ' - Período de ' & dtini & ' até ' & dateformat(dtfim,"DD/MM/YYYY")>	 
</cfif>
<!---
  
frmmes: #frmmes#<br>
dtlimit: #dtlimit#<br>
#int(month(now()) - 1)#

<cfset gil = gil>  --->
</cfoutput>
<!--- exibicao em tela --->
<cfif grpacesso eq 'GESTORMASTER' or grpacesso eq 'GOVERNANCA'>
	<cfquery name="rsMetas" datasource="#dsn_inspecao#">
		SELECT Met_Codigo,Met_Ano,Dir_Sigla,Met_SE_STO,Met_SLNC,Met_SLNC_Mes,Met_PRCI,Met_PRCI_Mes,Met_PRCI_Acum,Met_DGCI,Met_SLNC_Acum,Met_SLNC_AcumPeriodo,Met_PRCI_AcumPeriodo,Met_DGCI_Mes,Met_DGCI_Acum,Met_DGCI_AcumPeriodo,Met_Resultado
		FROM Metas INNER JOIN Diretoria ON Met_Codigo = Dir_Codigo
		WHERE (Met_Ano = #frmano#) and Met_Mes = #frmmes#
		ORDER BY Met_Resultado desc, Met_DGCI_Acum desc
	</cfquery>
<cfelseif grpacesso eq 'GESTORES' or grpacesso eq 'ANALISTAS'>  
	<cfquery name="rsMetas" datasource="#dsn_inspecao#">
		SELECT Met_Codigo,Met_Ano,Dir_Sigla,Met_SE_STO,Met_SLNC,Met_SLNC_Mes,Met_PRCI,Met_PRCI_Mes,Met_PRCI_Acum,Met_DGCI,Met_SLNC_Acum,Met_SLNC_AcumPeriodo,Met_PRCI_AcumPeriodo,Met_DGCI_Mes,Met_DGCI_Acum,Met_DGCI_AcumPeriodo,Met_Resultado 
		FROM Metas INNER JOIN Diretoria ON Met_Codigo = Dir_Codigo
		WHERE (Met_Ano = #frmano#) and Met_Mes = #frmmes# and Met_Codigo in(#qUsuario.Usu_Coordena#)
		ORDER BY Met_Resultado desc, Met_DGCI_Acum desc
	</cfquery>
<cfelse>
	<cfquery name="rsMetas" datasource="#dsn_inspecao#">
		SELECT Met_Codigo,Met_Ano,Dir_Sigla,Met_SE_STO,Met_SLNC,Met_SLNC_Mes,Met_PRCI,Met_PRCI_Mes,Met_PRCI_Acum,Met_DGCI,Met_SLNC_Acum,Met_SLNC_AcumPeriodo,Met_PRCI_AcumPeriodo,Met_DGCI_Mes,Met_DGCI_Acum,Met_DGCI_AcumPeriodo,Met_Resultado 
		FROM Metas INNER JOIN Diretoria ON Met_Codigo = Dir_Codigo
		WHERE (Met_Ano = #frmano#) and Met_Mes = #frmmes# and Met_Codigo = '#qUsuario.Usu_DR#'
		ORDER BY Met_Resultado desc
	</cfquery>
</cfif>
	<cfquery name="rsNacional" datasource="#dsn_inspecao#">
		SELECT Met_PRCI,Met_SLNC,Met_DGCI
		FROM Metas 
		WHERE Met_Ano = #frmano# and Met_Mes = 1
	</cfquery>

<!--- Criacao do arquivo CSV --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>

<!--- Excluir arquivos anteriores ao dia atual --->

<cfset auxcab = 'RESULTADO EM RELAÇÃO À META ' & #ucase(cabec)#>

<table width="98%" border="1" align="center" cellpadding="0" cellspacing="0">
  
  <tr>
    <td colspan="28" class="exibir"><div align="center"><strong>RESULTADO EM RELA&Ccedil;&Atilde;O &Agrave; META <cfoutput>#ucase(cabec)#</cfoutput></strong></div>      <div align="center"></div>      <div align="center"></div></td>
    </tr>
  <tr>
    <td colspan="2" class="exibir">&nbsp;</td>
    <td colspan="7" class="exibir"><div align="center"><strong>PRCI</strong></div></td>
    <td colspan="7" class="exibir"><div align="center"><strong>SLNC</strong></div></td>
    <td colspan="4" class="exibir"><div align="center"><strong>DGCI</strong></div></td>
    <td colspan="2" class="exibir"><div align="center"><strong>Resultado do DGCI em Relação<br>à Meta Mensal</strong></div></td>
  </tr>
  <tr>
    <td class="exibir"><div align="center"><strong>Classif.</strong></div></td>
    <td class="exibir"><div align="center"><strong>SE</strong></div></td>
    <td class="exibir"><div align="center"><strong>DP</strong></div></td>
    <td class="exibir"><div align="center"><strong>FP</strong></div></td>
    <td class="exibir"><div align="center"><strong>(DP+FP)</strong></div></td>
    <td class="exibir"><div align="center"><strong>PRCI_MES</strong></div></td>
    <td class="exibir"><div align="center"><strong>PRCI_DB</strong></div></td>
    <td class="exibir"><div align="center"><strong>Meta Mês</strong></div></td>    
    <td class="exibir"><div align="center"><strong>Resultado Mensal</strong></div></td>
    <td class="exibir"><div align="center"><strong>SOlUC</strong></div></td>
    <td class="exibir"><div align="center"><strong>(TRAT+PEND)</strong></div></td>
    <td class="exibir"><div align="center"><strong>(SOlUC+TRAT+PEND)</strong></div></td>
    <td class="exibir"><div align="center"><strong>SLNC_MES</strong></div></td>      
    <td class="exibir"><div align="center"><strong>SLNC_DB</strong></div></td>
    <td class="exibir"><div align="center"><strong>Meta Mês</strong></div></td>
    <td class="exibir"><div align="center"><strong>Resultado Mensal</strong></div></td>
    <td class="exibir"><div align="center"><strong>DGCI_MES</strong></div></td> 
    <td class="exibir"><div align="center"><strong>DGCI_DB</strong></div></td>
    <td class="exibir"><div align="center"><strong>Meta Mês</strong></div></td>
    <td class="exibir"><div align="center"><strong>Resultado Mensal</strong></div></td>
    <td class="exibir"><div align="center"><strong>Acumulado<br>Realizado</strong></div></td>
    <td class="exibir"><div align="center"><strong>(AcumuladoRealizado/Meta Mês)*100</strong></div></td>
    <td class="exibir"><div align="center"><strong>Resultado Mensal</strong></div></td>
    
    
    </tr>
  <cfset PRCInac = 0>
  <cfset PRCIAPnac = 0>
  <cfset prciacurealnac = 0>
  <cfset PRCIAPnacPer = 0>
  <cfset SLNCnac = 0>
  <cfset SLNCAPnac = 0>
  <cfset slncacurealnac=0>
  <cfset DGCInac = 0>
  <cfset DGCIAPnac = 0>
  <cfset dgciacurealnac=0>
  <cfset RESMETnac = 0>
  <cfset mesrel = frmmes>
  <cfset cla = 0>
  <cfoutput query="rsMetas">
    <cfset cla = cla + 1>
    <cfset se = rsMetas.Dir_Sigla>
    <!--- PRCI --->
    <cfset MetPRCI = numberFormat(rsMetas.Met_PRCI,999.0)>
    <cfset MetPRCIAcum = numberFormat(rsMetas.Met_PRCI_Acum,999.0)>
	
    <cfif MetPRCIAcum gt MetPRCI>
		  <cfset PRCIRes = "ACIMA DO ESPERADO">
		  <cfset scord1 = "##33CCFF">
     <cfelseif MetPRCIAcum eq MetPRCI>
		  <cfset PRCIRes = "DENTRO DO ESPERADO">
		  <cfset scord1 = "##339900">
     <cfelse>
		  <cfset PRCIRes = "ABAIXO DO ESPERADO">
		  <cfset scord1 = "##FF3300">
    </cfif>
	
    <cfset MetPRCIAcumPeriodo = numberFormat(Met_PRCI_AcumPeriodo,999.0)>
    <cfif MetPRCIAcumPeriodo gt MetPRCI>
      <cfset PRCIAcuPerRealRes = "ACIMA DO ESPERADO">
      <cfset scorf1 = "##33CCFF">
    <cfelseif MetPRCIAcumPeriodo eq MetPRCI>
      <cfset PRCIAcuPerRealRes = "DENTRO DO ESPERADO">
      <cfset scorf1 = "##339900">
    <cfelse>
      <cfset PRCIAcuPerRealRes = "ABAIXO DO ESPERADO">
      <cfset scorf1 = "##FF3300">
    </cfif>

    <!--- SLNC --->
    <cfset MetSLNC = numberFormat(rsMetas.Met_SLNC,999.0)>
    <cfset MetSLNCAcum = numberFormat(rsMetas.Met_SLNC_Acum,999.0)>
	
    <cfif MetSLNCAcum gt MetSLNC>
      <cfset SLNCRes = "ACIMA DO ESPERADO">
      <cfset scroi1 = "##33CCFF">
    <cfelseif MetSLNCAcum eq MetSLNC>
      <cfset SLNCRes = "DENTRO DO ESPERADO">
      <cfset scroi1 = "##339900">
    <cfelse>
      <cfset SLNCRes = "ABAIXO DO ESPERADO">
      <cfset scroi1 = "##FF3300">
    </cfif>
	
    <cfset MetSLNCAcumPeriodo = trim(numberFormat(Met_SLNC_AcumPeriodo,999.0))>
  
    <cfif MetSLNCAcumPeriodo gt MetSLNC>
		  <cfset SLNCAcuPerRealRes = "ACIMA DO ESPERADO">
		  <cfset scrok1 = "##33CCFF">
      <cfelseif MetSLNCAcumPeriodo eq MetSLNC>
		  <cfset SLNCAcuPerRealRes = "DENTRO DO ESPERADO">
		  <cfset scrok1 = "##339900">
      <cfelse>
		  <cfset SLNCAcuPerRealRes = "ABAIXO DO ESPERADO">
		  <cfset scrok1 = "##FF3300">
    </cfif>
	
    <cfset MetDGCI = numberFormat((rsMetas.Met_DGCI),999.0)>
    <cfset MetDGCIAcum = numberFormat(rsMetas.Met_DGCI_Acum,999.0)>
	
    <cfif MetDGCIAcum gt MetDGCI>
      <cfset DGCIRes = "ACIMA DO ESPERADO">
      <cfset scorn1 = "##33CCFF">
    <cfelseif MetDGCIAcum eq MetDGCI>
      <cfset DGCIRes = "DENTRO DO ESPERADO">
      <cfset scorn1 = "##339900">
    <cfelse>
      <cfset DGCIRes = "ABAIXO DO ESPERADO">
      <cfset scorn1 = "##FF3300">
    </cfif>
	
    <cfset MetDGCIAcumPeriodo = trim(numberFormat(Met_DGCI_AcumPeriodo,999.0))>
    
    <cfif MetDGCIAcumPeriodo gt MetDGCI>
      <cfset DGCIAcuPerRealRes = "ACIMA DO ESPERADO">
      <cfset scorp1 = "##33CCFF">
      <cfelseif MetDGCIAcumPeriodo eq MetDGCI>
      <cfset DGCIAcuPerRealRes = "DENTRO DO ESPERADO">
      <cfset scorp1 = "##339900">
      <cfelse>
      <cfset DGCIAcuPerRealRes = "ABAIXO DO ESPERADO">
      <cfset scorp1 = "##FF3300">
    </cfif>
	
    <cfset permeta = rsMetas.Met_Resultado>
    
    <cfif cla lt 10>
	  <cfset cl = '0' & cla & 'º'>
	<cfelse>
	  <cfset cl = cla & 'º'>
	</cfif>
    <cfquery name="rsPRCIBase" datasource="#dsn_inspecao#">
        SELECT Andt_TipoRel,Andt_Unid as UNID, Andt_Insp as INSP, Andt_Grp as Grupo, Andt_Item as Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_Mes, Andt_Prazo
        FROM Andamento_Temp 
        where (Andt_CodSE = '#rsMetas.Met_Codigo#' and Andt_AnoExerc = '#frmano#' and Andt_Mes = #aux_mes#)
        order by Andt_Mes
    </cfquery>
    <cfset startTime = CreateTime(0,0,0)> 
    <cfset endTime = CreateTime(0,0,30)> 
    <cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
    </cfloop>
    <cfset totmesDP = 0>
    <cfset totmesFP = 0>
    <cfset TOTMESDPFP = 0>
    <!--- contar unidade DP e FP --->
    <cfquery dbtype="query" name="rstotmesDP">
        SELECT Andt_Prazo 
        FROM  rsPRCIBase
        where Andt_TipoRel = 1 AND Andt_Prazo = 'DP' and Andt_Mes = #aux_mes#
    </cfquery>
    <cfset totmesDP = rstotmesDP.recordcount>

    <cfquery dbtype="query" name="rsTOTMESFP">
        SELECT Andt_Prazo 
        FROM  rsPRCIBase
        where Andt_TipoRel = 1 AND Andt_Prazo = 'FP' and Andt_Mes = #aux_mes#
    </cfquery>		
    <cfset totmesFP = rsTOTMESFP.recordcount>
    <!--- Quant. FP --->
    <cfset TOTMESDPFP = (totmesDP + totmesFP)>

    <cfset PercDPmes = '100.0'>
    <cfif TOTMESDPFP gt 0>
        <cfset PercDPmes = trim(NumberFormat((totmesDP/TOTMESDPFP) * 100,999.0))>
    </cfif>
    <!---  SLNC --->
    <!--- quant. (3-SOL) no mês por SE --->
			<cfquery dbtype="query" name="rstotmessesol">
				SELECT Andt_Resp 
				FROM  rsPRCIBase
				where Andt_TipoRel = 2 AND Andt_Resp = 3 and Andt_Mes = #aux_mes#
			</cfquery>
			<cfset totmessesol = rstotmessesol.recordcount>
			<!--- quant. (Pendentes + Tratamentos) no mês por SE --->
			<cfquery dbtype="query" name="rstotmessependtrat">
				SELECT Andt_Resp 
				FROM  rsPRCIBase
				where Andt_TipoRel = 2 AND Andt_Resp <> 3 and Andt_Mes = #aux_mes#
			</cfquery>
			<cfset totmessependtrat = rstotmessependtrat.recordcount>
			<cfset totmessegeral = totmessesol + totmessependtrat>

			<!--- slncacum ---> 
			<cfset slnc_acummes = '100.0'>
			<cfif totmessegeral gt 0>
				<cfset slnc_acummes = trim(NumberFormat(((totmessesol/totmessegeral) * 100),999.0))>
			</cfif>
            <cfset dgci_acummes = trim(numberFormat((slnc_acummes * 0.45) + (PercDPmes * 0.55),999.0))> 
    <tr>
      <td class="exibir"><div align="center">#cl#</div></td>
      <td class="exibir"><div align="center"><strong>#se#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#totmesDP#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#totmesFP#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#TOTMESDPFP#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#PercDPmes#</strong></div></td>      
      <td class="exibir"><div align="center"><strong>#MetPRCIAcum#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#MetPRCI#</strong></div></td>
      <td bgcolor="#scord1#" class="exibir"><div align="center">#PRCIRes#</div></td>
      <td class="exibir"><div align="center"><strong>#totmessesol#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#totmessependtrat#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#totmessegeral#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#slnc_acummes#</strong></div></td>       
      <td class="exibir"><div align="center"><strong>#MetSLNCAcum#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#MetSLNC#</strong></div></td>      
      <td bgcolor="#scroi1#" class="exibir"><div align="center">#SLNCRes#</div></td>
      <td class="exibir"><div align="center"><strong>#dgci_acummes#</strong></div></td> 
      <td class="exibir"><div align="center"><strong>#rsMetas.Met_DGCI_Acum#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#Met_DGCI#</strong></div></td>    
      <td  bgcolor="#scorn1#"class="exibir"><div align="center"><strong>#DGCIRes#</strong></div></td>  
      <td class="exibir"><div align="center"><strong>#Met_DGCI_AcumPeriodo#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#permeta#</strong></div></td>
      <td  bgcolor="#scorp1#"class="exibir"><div align="center"><strong>#DGCIAcuPerRealRes#</strong></div></td>   
      <td  bgcolor="#scorp1#"class="exibir"><div align="center"></div></td>    
    </tr>

    <cfset prciacurealnac = prciacurealnac + MetPRCIAcumPeriodo>
    <cfset PRCIAPnac = PRCIAPnac + MetPRCIAcum>
    <cfset slncacurealnac = slncacurealnac + MetSLNCAcumPeriodo>
    <cfset SLNCAPnac = SLNCAPnac + MetSLNCAcum>
    <cfset DGCIAPnac = DGCIAPnac + MetDGCIAcum>
    <cfset dgciacurealnac = dgciacurealnac + MetDGCIAcumPeriodo>
    <cfset RESMETnac = RESMETnac + permeta>     
  </cfoutput>
 </table>
<!--- fim exibicao --->
</form>
  <cfinclude template="rodape.cfm">
</body>
</html>

