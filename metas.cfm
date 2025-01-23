<!--- #se#  === #frmano#<br> --->
<cfprocessingdirective pageEncoding ="utf-8"> 
<cfoutput>
	<cfif frmano lte 2022>
		<cflocation url="Rel_indicadoresglobal_2022.cfm?frmano=#frmano#&frmmes=#frmmes#&Submit1=Confirmar&frmanoatual=#frmanoatual#&frmmesatual=#frmmesatual#">
	</cfif>   
</cfoutput>
<cfsetting requesttimeout="15000"> 
<cfif IsDefined("url.ninsp")>
<cfset txtNum_Inspecao = url.ninsp>
</cfif>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso,Usu_Matricula,Usu_Coordena,Usu_DR from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset grpacesso = ucase(Trim(qUsuario.Usu_GrupoAcesso))>
<!---
<cfif frmano eq year(now()) and frmmes lt 5 and grpacesso neq 'GESTORMASTER'>
	 <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=Favor aguardar, tela em manutencao para o ano/mes selecionado!">
</cfif> 
--->
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfset total=0>

<cfinclude template="cabecalho.cfm"><br>
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
  <!---
  <cfoutput>
    #frmano#,#frmmes#    
  </cfoutput>
--->
<form action="" method="post" target="_blank" name="form1">
  <cfset dtlimit = CreateDate(#frmano#,#frmmes#,1)>
  <cfset aux_mes = int(month(dtlimit))>
  <cfset dia = day(now())>
  <cfset mes = month(now())>
  <cfset ano = year(now())>
  <cfif (grpacesso neq 'GESTORMASTER') and (frmano neq ano) and (mes eq 1) and (dia lte 10)>
    <cfset ano = frmano>
  </cfif>
<cfif grpacesso neq 'GESTORMASTER' and dia lte 10 and frmano eq ano>
  <cfif frmmes is 1>
		<cfset dtlimit = (frmano - 1) & "/12/31">
    <cfset cabec = 'Dez/' & year(dtlimit)>
	<cfelseif frmmes is 2>
		<cfset dtlimit = frmano  & "/01/31">	
    <cfset cabec = 'Jan/' & year(dtlimit)>	
	<cfelseif frmmes is 3>  
		<cfif int(frmano) mod 4 is 0>
			<cfset dtlimit = frmano & "/02/29">
		<cfelse>
			<cfset dtlimit = frmano & "/02/28">
		</cfif>
    <cfset cabec = 'Fev/' & year(dtlimit)>	
	<cfelseif frmmes is 4>
		<cfset dtlimit = frmano & "/03/31">
    <cfset cabec = 'Mar/' & year(dtlimit)>	
	<cfelseif frmmes is 5>
		<cfset dtlimit = frmano & "/04/30">	
    <cfset cabec = 'Abr/' & year(dtlimit)>		
	<cfelseif frmmes is 6>
		<cfset dtlimit = frmano & "/05/31">		
    <cfset cabec = 'Mai/' & year(dtlimit)>	
	<cfelseif frmmes is 7>
		<cfset dtlimit = frmano & "/06/30">		
    <cfset cabec = 'Jun/' & year(dtlimit)>				   
	<cfelseif frmmes is 8>
		<cfset dtlimit = frmano & "/07/31">
    <cfset cabec = 'Jul/' & year(dtlimit)>						   
	<cfelseif frmmes is 9>
		<cfset dtlimit = frmano & "/08/31">		
    <cfset cabec = 'Ago/' & year(dtlimit)>				   
	<cfelseif frmmes is 10>
		<cfset dtlimit = frmano & "/09/30">		
    <cfset cabec = 'Set/' & year(dtlimit)>				   
	<cfelseif frmmes is 11>
		<cfset dtlimit = frmano & "/10/31">	
    <cfset cabec = 'Out/' & year(dtlimit)>	
	<cfelseif frmmes is 12>	
		<cfset dtlimit = frmano & "/11/30">	  
    <cfset cabec = 'Nov/' & year(dtlimit)>	 				   			   
	</cfif>
<cfelse>  
	<cfif frmmes is 1>
    <cfset cabec = 'Jan/' & year(dtlimit)>	
    <cfset dtlimit = frmano  & "/01/31">
	<cfelseif frmmes is 2>  
		<cfif int(frmano) mod 4 is 0>
			<cfset dtlimit = frmano & "/02/29">
		<cfelse>
			<cfset dtlimit = frmano & "/02/28">
		</cfif>
    <cfset cabec = 'Fev/' & year(dtlimit)>	
	<cfelseif frmmes is 3>
		<cfset dtlimit = frmano & "/03/31">
    <cfset cabec = 'Mar/' & year(dtlimit)>	
	<cfelseif frmmes is 4>
		<cfset dtlimit = frmano & "/04/30">	
    <cfset cabec = 'Abr/' & year(dtlimit)>		
	<cfelseif frmmes is 5>
		<cfset dtlimit = frmano & "/05/31">		
    <cfset cabec = 'Mai/' & year(dtlimit)>	
	<cfelseif frmmes is 6>
		<cfset dtlimit = frmano & "/06/30">		
    <cfset cabec = 'Jun/' & year(dtlimit)>				   
	<cfelseif frmmes is 7>
		<cfset dtlimit = frmano & "/07/31">
    <cfset cabec = 'Jul/' & year(dtlimit)>						   
	<cfelseif frmmes is 8>
		<cfset dtlimit = frmano & "/08/31">		
    <cfset cabec = 'Ago/' & year(dtlimit)>				   
	<cfelseif frmmes is 9>
		<cfset dtlimit = frmano & "/09/30">		
    <cfset cabec = 'Set/' & year(dtlimit)>				   
	<cfelseif frmmes is 10>
		<cfset dtlimit = frmano & "/10/31">	
    <cfset cabec = 'Out/' & year(dtlimit)>	
	<cfelseif frmmes is 11>	
		<cfset dtlimit = frmano & "/11/30">	  
    <cfset cabec = 'Nov/' & year(dtlimit)>	 
	<cfelseif frmmes is 12>	
		<cfset dtlimit = frmano & "/12/31">	  
    <cfset cabec = 'Dez/' & year(dtlimit)>    				   			   
	</cfif>
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
<cfset fazgestaoRS='N'>
<cfif grpacesso eq 'GESTORMASTER' or grpacesso eq 'GOVERNANCA'>
	<cfquery name="rsMetas" datasource="#dsn_inspecao#">
		SELECT Met_Codigo,Met_Ano,Dir_Sigla,Met_SE_STO,Met_SLNC,Met_SLNC_Mes,Met_PRCI,Met_PRCI_Mes,Met_PRCI_Acum,Met_DGCI,Met_SLNC_Acum,Met_SLNC_AcumPeriodo,Met_PRCI_AcumPeriodo,Met_DGCI_Mes,Met_DGCI_Acum,Met_DGCI_AcumPeriodo,Met_Resultado
		FROM Metas INNER JOIN Diretoria ON Met_Codigo = Dir_Codigo
		WHERE (Met_Ano = #frmano#) and Met_Mes = #frmmes#
    <cfif frmano eq 2024 and frmmes gt 4>
      and Met_Codigo <> '64'
    </cfif>
		ORDER BY Met_Resultado desc, Met_DGCI_Acum desc
	</cfquery>
<cfelseif grpacesso eq 'GESTORES' or grpacesso eq 'ANALISTAS'>  
  <cfset UsuCoordena = ''>
  <cfif frmano eq 2024 and frmmes gt 4>
      <cfloop index="ind" list="#qUsuario.Usu_Coordena#">
          <cfif ind neq '64'>
            <cfif UsuCoordena eq ''>
              <cfset UsuCoordena = ind>
            <cfelse>
              <cfset UsuCoordena = UsuCoordena & ',' & ind>
            </cfif>
          <cfelse>
            <cfset fazgestaoRS='S'>
          </cfif>
      </cfloop> 
  <cfelse>
    <cfset UsuCoordena = qUsuario.Usu_Coordena>
  </cfif>
  <cfif UsuCoordena eq ''>
    <cfset UsuCoordena = qUsuario.Usu_Coordena>
    <cfset grpacesso = 'GERENTES'>
  </cfif>
	<cfquery name="rsMetas" datasource="#dsn_inspecao#">
		SELECT Met_Codigo,Met_Ano,Dir_Sigla,Met_SE_STO,Met_SLNC,Met_SLNC_Mes,Met_PRCI,Met_PRCI_Mes,Met_PRCI_Acum,Met_DGCI,Met_SLNC_Acum,Met_SLNC_AcumPeriodo,Met_PRCI_AcumPeriodo,Met_DGCI_Mes,Met_DGCI_Acum,Met_DGCI_AcumPeriodo,Met_Resultado 
		FROM Metas INNER JOIN Diretoria ON Met_Codigo = Dir_Codigo
		WHERE (Met_Ano = #frmano#) and Met_Mes = #frmmes# and Met_Codigo in(#UsuCoordena#)
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
  SELECT Met_PRCI,Met_SLNC,Met_DGCI,Met_Codigo
  FROM Metas 
  WHERE Met_Ano = #frmano# and Met_Mes = 1 
  <cfif frmano eq 2024 and frmmes gt 4>
    and Met_Codigo <> '64' and Met_Codigo <> '01'
  <cfelse>
    <cfif qUsuario.Usu_DR neq '01'>
      and Met_Codigo = '#qUsuario.Usu_DR#'
    </cfif>
  </cfif>
</cfquery>

<!--- Criacao do arquivo CSV --->
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
<cffile action="Append" file="#slocal##sarquivo#" output=';;#auxcab#'>
<cffile action="Append" file="#slocal##sarquivo#" output=';PRCI;;;;;SLNC;;;;;DGCI;;;;;'>
<cffile action="Append" file="#slocal##sarquivo#" output='SE;Meta Mensal;Realizado;Resultado Mensal;Acumulado Realizado;Resultado Acumulado Realizado;Meta Mensal;Realizado;Resultado Mensal;Acumulado Realizado;Resultado Acumulado Realizado;Meta Mensal;Realizado;Resultado Mensal;Acumulado Realizado;Resultado Acumulado Realizado;Resultado em Relação à Meta Mensal'>

<table width="98%" border="1" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td colspan="18" class="exibir"><div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/csv.png" width="37" height="38" border="0"></a></div></td>
    </tr>
  <tr>
    <td colspan="18" class="exibir"><div align="center"><strong>RESULTADO EM RELA&Ccedil;&Atilde;O &Agrave; META <cfoutput>#ucase(cabec)#</cfoutput></strong></div>      <div align="center"></div>      <div align="center"></div></td>
    </tr>
  <tr>
    <td colspan="2" class="exibir">&nbsp;</td>
    <td colspan="5" class="exibir"><div align="center"><strong>PRCI</strong></div></td>
    <td colspan="5" class="exibir"><div align="center"><strong>SLNC</strong></div></td>
    <td colspan="5" class="exibir"><div align="center"><strong>DGCI</strong></div></td>
    <td rowspan="2" class="exibir"><div align="center"><strong><span class="titulos">(***)Resultado em Relação<br>à Meta Mensal</span></strong></div></td>
  </tr>
  <tr>
    <td class="exibir"><div align="center"><strong>Ordem</strong></div></td>
    <td class="exibir"><div align="center"><strong>SE</strong></div></td>
    <td class="exibir"><div align="center"><strong>Meta <br>
      Mensal</strong></div></td>
    <td class="exibir"><div align="center"><strong>Realizado</strong></div></td>
    <td class="exibir"><div align="center"><strong>Resultado Mensal</strong></div></td>
    <td class="exibir"><div align="center"><strong>Acumulado<br>
      Realizado</strong></div></td>
    <td class="exibir"><div align="center"><strong>Resultado<br>
      Acumulado<br>
      Realizado</strong></div></td>
    <td class="exibir"><div align="center"><strong>Meta Mensal</strong></div></td>
    <td class="exibir"><div align="center"><strong>Realizado</strong></div></td>
    <td class="exibir"><div align="center"><strong>Resultado Mensal</strong></div></td>
    <td class="exibir"><div align="center"><strong>Acumulado <br>
      Realizado</strong></div></td>
    <td class="exibir"><div align="center"><strong>Resultado<br>
      Acumulado<br>
      Realizado</strong></div></td>
    <td class="exibir"><div align="center"><strong>Meta Mensal </strong></div></td>
    <td class="exibir"><div align="center"><strong>(*)Realizado</strong></div></td>
    <td class="exibir"><div align="center"><strong>Resultado Mensal</strong></div></td>
    <td class="exibir"><div align="center"><strong>(**)Acumulado<br>Realizado</strong></div></td>
    <td class="exibir"><div align="center"><strong>Resultado<br>Acumulado<br>Realizado</strong></div></td>
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
    <cfif frmano eq 2024 and rsMetas.Met_Codigo eq '64' and frmmes gt 4> 
      <cfset PRCIRes = "SUSPENSO">
		  <cfset scord1 = "">
      <cfset PRCIAcuPerRealRes = "SUSPENSO">
      <cfset scorf1 = "">
      <cfset SLNCRes = "SUSPENSO">
      <cfset scroi1 = "">
      <cfset SLNCAcuPerRealRes = "SUSPENSO">
		  <cfset scrok1 = "">
      <cfset DGCIRes = "SUSPENSO">
      <cfset scorn1 = "">
      <cfset DGCIAcuPerRealRes = "SUSPENSO">
      <cfset scorp1 = "">
      <cfset MetPRCI = '---'>
      <cfset MetPRCIAcum = '---'>
      <cfset MetPRCIAcumPeriodo = '---'>
      <cfset MetSLNC = '---'>
      <cfset MetSLNCAcum = '---'>
      <cfset MetSLNCAcumPeriodo = '---'>
      <cfset MetDGCI = '---'>
      <cfset MetDGCIAcum = '---'>
      <cfset MetDGCIAcumPeriodo = '---'>
      <cfset permeta = '---'>    
      <cfset cl = '---'> 
    </cfif>
    <tr>
      <td class="exibir"><div align="center">#cl#</div></td>
      <td class="exibir"><div align="center"><strong>#se#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#MetPRCI#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#MetPRCIAcum#</strong></div></td>
      <td bgcolor="#scord1#" class="exibir"><div align="center">#PRCIRes#</div></td>
      <td class="exibir"><div align="center"><strong>#MetPRCIAcumPeriodo#</strong></div></td>
      <td bgcolor="#scorf1#" class="exibir"><div align="center">#PRCIAcuPerRealRes#</div></td>
      <td class="exibir"><div align="center"><strong>#MetSLNC#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#MetSLNCAcum#</strong></div></td>
      <td bgcolor="#scroi1#" class="exibir"><div align="center">#SLNCRes#</div></td>
      <td class="exibir"><div align="center"><strong>#MetSLNCAcumPeriodo#</strong></div></td>
      <td bgcolor="#scrok1#" class="exibir"><div align="center">#SLNCAcuPerRealRes#</div></td>
      <td class="exibir"><div align="center"><strong>#MetDGCI#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#MetDGCIAcum#</strong></div></td>
      <td bgcolor="#scorn1#" class="exibir"><div align="center">#DGCIRes#</div></td>
      <td class="exibir"><div align="center"><strong>#MetDGCIAcumPeriodo#</strong></div></td>
      <td bgcolor="#scorp1#" class="exibir"><div align="center">#DGCIAcuPerRealRes#</div></td>
	    <td class="exibir"><div align="center"><strong>#permeta#</strong></div></td>
    </tr>
    <cfif frmano eq 2024 and rsMetas.Met_Codigo eq '64' and frmmes gt 4>
      <cfset MetPRCIAcumPeriodo=0>
      <cfset MetPRCIAcum=0>
      <cfset MetSLNCAcumPeriodo=0>
      <cfset MetSLNCAcum=0>
      <cfset MetDGCIAcum=0>
      <cfset MetDGCIAcumPeriodo=0>
      <cfset permeta=0>   
    </cfif>

    <cfset prciacurealnac = prciacurealnac + MetPRCIAcumPeriodo>
    <cfset PRCIAPnac = PRCIAPnac + MetPRCIAcum>
    <cfset slncacurealnac = slncacurealnac + MetSLNCAcumPeriodo>
    <cfset SLNCAPnac = SLNCAPnac + MetSLNCAcum>
    <cfset DGCIAPnac = DGCIAPnac + MetDGCIAcum>
    <cfset dgciacurealnac = dgciacurealnac + MetDGCIAcumPeriodo>
    <cfset RESMETnac = RESMETnac + permeta>     
    
    <cffile action="Append" file="#slocal##sarquivo#" output='#se#;#MetPRCI#;#MetPRCIAcum#;#PRCIRes#;#MetPRCIAcumPeriodo#;#PRCIAcuPerRealRes#;#MetSLNC#;#MetSLNCAcum#;#SLNCRes#;#MetSLNCAcumPeriodo#;#SLNCAcuPerRealRes#;#MetDGCI#;#MetDGCIAcum#;#DGCIRes#;#Met_DGCI_AcumPeriodo#;#DGCIAcuPerRealRes#;#permeta#'>
  </cfoutput>
  <cfif grpacesso eq 'GESTORMASTER' or grpacesso eq 'GOVERNANCA' or grpacesso eq 'GESTORES' or grpacesso eq 'ANALISTAS'>
    <cfif grpacesso eq 'GESTORES' or grpacesso eq 'ANALISTAS'>
    <cfelse>
      <cfset fazgestaoRS='S'>
    </cfif>
  
    <cfif frmano eq 2024 and frmmes gt 4 and fazgestaoRS eq 'S'>
      <cfoutput>
      <tr>
          <td class="exibir"><div align="center">---</div></td>
          <td class="exibir"><div align="center"><strong>RS</strong></div></td>
          <td class="exibir"><div align="center"><strong>---</strong></div></td>
          <td class="exibir"><div align="center"><strong>---</strong></div></td>
          <td class="exibir"><div align="center">SUSPENSO</div></td>
          <td class="exibir"><div align="center"><strong>---</strong></div></td>
          <td class="exibir"><div align="center">SUSPENSO</div></td>
          <td class="exibir"><div align="center"><strong>---</strong></div></td>
          <td class="exibir"><div align="center"><strong>---</strong></div></td>
          <td class="exibir"><div align="center">SUSPENSO</div></td>
          <td class="exibir"><div align="center"><strong>---</strong></div></td>
          <td class="exibir"><div align="center">SUSPENSO</div></td>
          <td class="exibir"><div align="center"><strong>---</strong></div></td>
          <td class="exibir"><div align="center"><strong>---</strong></div></td>
          <td class="exibir"><div align="center">SUSPENSO</div></td>
          <td class="exibir"><div align="center"><strong>---</strong></div></td>
          <td class="exibir"><div align="center">SUSPENSO</div></td>
          <td class="exibir"><div align="center"><strong>---</strong></div></td>
        </tr>
        <cffile action="Append" file="#slocal##sarquivo#" output='RS;---;---;SUSPENSO;---;SUSPENSO;---;---;SUSPENSO;---;SUSPENSO;---;---;SUSPENSO;---;SUSPENSO;---'>
      </cfoutput>
  </cfif>
</cfif>
  <cfloop query="rsNacional">
      <cfset PRCInac = PRCInac + rsNacional.Met_PRCI>
      <cfset SLNCnac = SLNCnac + rsNacional.Met_SLNC>
      <cfset DGCInac = DGCInac + rsNacional.Met_DGCI>  
  </cfloop>
 
  <cfset PRCInac = numberFormat((PRCInac/rsNacional.recordcount),999.0)>
  <cfset prciacurealnac = numberFormat((prciacurealnac/rsMetas.recordcount),999.0)>
  <cfset PRCIAPnac = numberFormat((PRCIAPnac/rsMetas.recordcount),999.0)>
  <cfset SLNCnac = numberFormat((SLNCnac/rsNacional.recordcount),999.0)>
  <cfset slncacurealnac = numberFormat((slncacurealnac/rsMetas.recordcount),999.0)>
  <cfset SLNCAPnac = numberFormat((SLNCAPnac/rsMetas.recordcount),999.0)>
  <cfset DGCInac = numberFormat((DGCInac/rsNacional.recordcount),999.0)>
  <cfset dgciacurealnac = numberFormat((dgciacurealnac/rsMetas.recordcount),999.0)>
  <cfset DGCIAPnac = numberFormat((DGCIAPnac/rsMetas.recordcount),999.0)>
  <cfset RESMETnac = numberFormat((DGCIAPnac/DGCInac)*100,999.0)>

	<cfif PRCIAPnac gt PRCInac>
		<cfset PRCIResNac = "ACIMA DO ESPERADO">
		<cfset scord2 = "##33CCFF">
	<cfelseif PRCIAPnac eq PRCInac>
		<cfset PRCIResNac = "DENTRO DO ESPERADO">
		<cfset scord2 = "##339900">
	<cfelse>
		<cfset PRCIResNac = "ABAIXO DO ESPERADO">
		<cfset scord2 = "##FF3300">
	</cfif>
	<cfif prciacurealnac gt PRCInac>
		<cfset prciacurealnacres = "ACIMA DO ESPERADO">
		<cfset scorf2 = "##33CCFF">
	<cfelseif prciacurealnac eq PRCInac>
		<cfset prciacurealnacres = "DENTRO DO ESPERADO">
		<cfset scorf2 = "##339900">
	<cfelse>
		<cfset prciacurealnacres = "ABAIXO DO ESPERADO">
		<cfset scorf2 = "##FF3300">
	</cfif>

	<cfif SLNCAPnac gt SLNCnac>
		<cfset SLNCResNac = "ACIMA DO ESPERADO">
		<cfset scroi2 = "##33CCFF">
	<cfelseif SLNCAPnac eq SLNCnac>
		<cfset SLNCResNac = "DENTRO DO ESPERADO">
		<cfset scroi2 = "##339900">
	<cfelse>
		<cfset SLNCResNac = "ABAIXO DO ESPERADO">
		<cfset scroi2 = "##FF3300">
	</cfif>
	<cfif slncacurealnac gt SLNCnac>
		<cfset slncacurealnacres = "ACIMA DO ESPERADO">
		<cfset scrok2 = "##33CCFF">
	<cfelseif slncacurealnac eq SLNCnac>
		<cfset slncacurealnacres = "DENTRO DO ESPERADO">
		<cfset scrok2 = "##339900">
	<cfelse>
		<cfset slncacurealnacres = "ABAIXO DO ESPERADO">
		<cfset scrok2 = "##FF3300">
	</cfif>  
    
	<cfif DGCIAPnac gt DGCInac>
		<cfset DGCIResNac = "ACIMA DO ESPERADO">
		<cfset scorn2 = "##33CCFF">
	<cfelseif DGCIAPnac eq DGCInac>
		<cfset DGCIResNac = "DENTRO DO ESPERADO">
		<cfset scorn2 = "##339900">
	<cfelse>
		<cfset DGCIResNac = "ABAIXO DO ESPERADO">
		<cfset scorn2 = "##FF3300">
	</cfif>
	
	<cfif dgciacurealnac gt DGCInac>
		<cfset dgciacurealnacres = "ACIMA DO ESPERADO">
		<cfset scorp2 = "##33CCFF">
	<cfelseif dgciacurealnac eq DGCInac>
		<cfset dgciacurealnacres = "DENTRO DO ESPERADO">
		<cfset scorp2 = "##339900">
	<cfelse>
		<cfset dgciacurealnacres = "ABAIXO DO ESPERADO">
		<cfset scorp2 = "##FF3300">
	</cfif>  
  <cfif grpacesso neq 'GESTORMASTER' and grpacesso neq 'GOVERNANCA' and grpacesso neq 'GESTORES' and grpacesso neq 'ANALISTAS'>
    <cfif frmano eq 2024 and rsMetas.Met_Codigo eq '64' and frmmes gt 4>
      <cfset PRCInac = '---'>
      <cfset prciacurealnac = '---'>
      <cfset PRCIAPnac = '---'>
      <cfset SLNCnac = '---'>
      <cfset slncacurealnac = '---'>
      <cfset SLNCAPnac = '---'>
      <cfset DGCInac = '---'>
      <cfset dgciacurealnac = '---'>
      <cfset DGCIAPnac = '---'>
      <cfset RESMETnac = '---'> 
      <cfset PRCIResNac = 'SUSPENSO'> 
      <cfset scord2 = "">
      <cfset prciacurealnacres = 'SUSPENSO'> 
      <cfset scorf2 = "">
      <cfset SLNCResNac = 'SUSPENSO'> 
      <cfset scroi2 = "">
      <cfset slncacurealnacres = 'SUSPENSO'> 
      <cfset scrok2 = "">
      <cfset DGCIResNac = 'SUSPENSO'> 
      <cfset scorn2 = "">
      <cfset dgciacurealnacres = 'SUSPENSO'> 
      <cfset scorp2 = "">
    </cfif>
  </cfif>
  <cfoutput>
  <tr bgcolor="CCCCCC" class="exibir">
      <td colspan="2" class="exibir">&nbsp;</td>
      <td class="exibir"><div align="center"><strong>Meta<br>
        Nacional</strong></div></td>
      <td colspan="2" class="exibir"><div align="center"><strong>Resultado 
        Nacional</strong></div></td>
      <td colspan="2" class="exibir"><div align="center"><strong>Acumulado
        Realizado
        Nacional</strong></div></td>
      <td class="exibir"><div align="center"><strong>Meta<br> 
        Nacional </strong></div></td>
      <td colspan="2" class="exibir"><div align="center"><strong>Resultado 
        Nacional</strong></div></td>
      <td colspan="2" class="exibir"><div align="center"><strong>Acumulado
        Realizado
        Nacional</strong></div></td>
      <td class="exibir"><div align="center"><strong>Meta<br> 
        Nacional</strong></div></td>
      <td colspan="2" class="exibir"><div align="center"><strong>Resultado 
        Nacional</strong></div></td>
      <td colspan="2" class="exibir"><div align="center"><strong>Acumulado
        Realizado
        Nacional</strong></div></td>
      <td class="exibir">&nbsp;</td>
    </tr>
    <tr class="exibir">
      <td colspan="2" class="exibir">&nbsp;</td>
      <td class="exibir"><div align="center"><strong>#PRCInac#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#PRCIAPnac#</strong></div></td>
      <td bgcolor="#scord2#" class="exibir"><div align="center"><strong>#PRCIResNac#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#prciacurealnac#</strong></div></td>
      <td bgcolor="#scorf2#" class="exibir"><div align="center">#prciacurealnacres#</div></td>
      <td class="exibir"><div align="center"><strong>#SLNCnac#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#SLNCAPnac#</strong></div></td>
      <td bgcolor="#scroi2#" class="exibir"><div align="center"><strong>#SLNCResNac#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#slncacurealnac#</strong></div></td>
      <td bgcolor="#scrok2#" class="exibir"><div align="center">#slncacurealnacres#</div></td>
      <td class="exibir"><div align="center"><strong>#DGCInac#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#DGCIAPnac#</strong></div></td>
      <td bgcolor="#scorn2#" class="exibir"><div align="center"><strong>#DGCIResNac#</strong></div></td>
      <td class="exibir"><div align="center"><strong>#dgciacurealnac#</strong></div></td>
      <td bgcolor="#scorp2#" class="exibir"><div align="center">#dgciacurealnacres#</div></td>
      <td class="exibir"><div align="center"><strong>#RESMETnac#</strong></div></td>
    </tr>	
    <tr class="exibir">
      <td colspan="18" class="exibir"><strong>(*)DGCI Realizado = (PRCI Realizado * 0,55) + (SLNC Realizado * 0,45)</strong></td>
    </tr>    
    <tr class="exibir">
      <td colspan="18" class="exibir"><strong>(**)DGCI Acumulado Realizado = (PRCI Acumulado Realizado * 0,55) + (SLNC Acumulado Realizado * 0,45)</strong></td>
    </tr>   
        <tr class="exibir">
      <td colspan="18" class="exibir"><strong>(***)Resultado em Relação à Meta Mensal = (DGCI Realizado / DGCI Meta Mensal) * 100</strong></td>
    </tr>     
    <cffile action="Append" file="#slocal##sarquivo#" output=';Meta Nacional;Resultado Nacional;;Acumulado Realizado Nacional;;Meta Nacional;Resultado Nacional;;Acumulado Realizado Nacional;;Meta Nacional;Resultado Nacional;;Acumulado Realizado Nacional;;;'>
    <!---    <CFSET RESMETnac = numberFormat((DGCIAPnac/DGCInac)*100,999.0)> --->
    
<cffile action="Append" file="#slocal##sarquivo#" output=';#PRCInac#;#PRCIAPnac#;#PRCIResNac#;#prciacurealnac#;#prciacurealnacres#;#SLNCnac#;#SLNCAPnac#;#SLNCResNac#;#slncacurealnac#;#slncacurealnacres#;#DGCInac#;#DGCIAPnac#;#DGCIResNac#;#dgciacurealnac#;#dgciacurealnacres#;#RESMETnac#%'>
<cffile action="Append" file="#slocal##sarquivo#" output='(*) DGCI Realizado = (PRCI Realizado * 0,55) + (SLNC Realizado * 0,45)'>
<cffile action="Append" file="#slocal##sarquivo#" output='(**)DGCI Acumulado Realizado = (PRCI Acumulado Realizado * 0,55) + (SLNC Acumulado Realizado * 0,45)'>
<cffile action="Append" file="#slocal##sarquivo#" output='(***)Resultado em Relação à Meta Mensal = (DGCI Realizado / DGCI Meta Mensal) * 100'>

  </cfoutput>
</table>
<!--- fim exibicao --->
</form>
  <cfinclude template="rodape.cfm">
</body>
</html>