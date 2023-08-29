<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">

<style type="text/css">
<!--
.style4 {color: #11438B}
-->
</style>
</head>
<body>
  <script type="text/javascript">
    document.write("<table width='" + largura() + "' height='" + altura() + "' border='0'>");
  </script>
  <form action="Grafico_PACIN_Realizado2.cfm" method="get" target="_blank" name="form1">
    <tr height="5%">
<!--- 	  <td align="center"><div id="menu" align="center"><cfinclude template="cabecalho.cfm"> --->
    </tr>
	<tr height="3%">
	  <!--- <td align="center" valign="top" class="titulo">Identifica&ccedil;&atilde;o no sistema</td> --->
	</tr>
<tr height="90%"><td valign="middle" align="center">&nbsp;</td>
</tr>
 <cfif ano neq "" and se neq "">
   <table width="95%" border="1" align="left">
  <tr>
    <cfoutput>
    <td colspan="15" class="titulo2"><div align="center"><span class="titulo"> anal&iacute;tico  PLANEJAMENTO PACIN <cfoutput>#ano#</cfoutput> (Planejado / Executado na se/<cfoutput>#se#</cfoutput>) </span></div></td>
    </cfoutput>
    </tr>
 
  <tr>
  <cfset TotGerPlan = 0>
  <cfset TotGerExec = 0>
<cfquery name="rsPlan" datasource="#dsn_inspecao#">
SELECT Month(Plan_DTFinal) AS MesFinal, Count(Month(Plan_DTFinal)) AS Total_Plan FROM Planejamento 
   GROUP BY Month(Plan_DTFinal), Year([Plan_DTFinal]), Left([Plan_CodUnid],2) 
<cfif #mes# is 'Todos'>
	HAVING (((Year([Plan_DTFinal]))=#ano#) AND ((Left([Plan_CodUnid],2))=#se#)) 
<cfelse>
	HAVING (((Year([Plan_DTFinal]))=#ano#) AND ((Left([Plan_CodUnid],2))=#se#)) and (Month(Plan_DTFinal) = #mes#)
</cfif>
	ORDER BY Month(Plan_DTFinal) asc
</cfquery>
    <td colspan="2">
	<cfchart format="png" chartwidth="900" show3d="no" showlegend="no" yaxistitle="Qtd" xaxistitle="Mes" chartheight="400">
		<cfchartseries type="cylinder">
         <cfoutput query="rsPlan">
		  <cfset mesd = "">
		  <cfswitch expression="#int(MesFinal)#">
			<cfcase value="1">
			   <cfset mesd = "Jan">
			</cfcase>
			<cfcase value="2">
				<cfset mesd = "Fev">
			</cfcase>
			<cfcase value="3">
				<cfset mesd = "Mar">
			</cfcase>
			<cfcase value="4">
				<cfset mesd = "Abr">
			</cfcase>
			<cfcase value="5">
				<cfset mesd = "Mai">
			</cfcase>
			<cfcase value="6">
				<cfset mesd = "Jun">
			</cfcase>
			<cfcase value="7">
				<cfset mesd = "Jul">
			</cfcase>
			<cfcase value="8">
				<cfset mesd = "Ago">
			</cfcase>
			<cfcase value="9">
				<cfset mesd = "Set">
			</cfcase>
			<cfcase value="10">
				<cfset mesd = "Out">
			</cfcase>
			<cfcase value="11">
				<cfset mesd = "Nov">
			</cfcase>
			<cfcase value="12">
				<cfset mesd = "Dez">
			</cfcase>																					
		 </cfswitch>

		 <cfquery name="rsRealiz" datasource="#dsn_inspecao#">
		SELECT Month([INP_DtFimInspecao]) AS MesRealiz, Count(Month([INP_DtFimInspecao])) AS QuantRealiz 
		FROM Inspecao  GROUP BY Month([INP_DtFimInspecao]), Year([INP_DtFimInspecao]), Left([INP_Unidade],2) 
		HAVING (Year([INP_DtFimInspecao])=#ano#) AND (Left([INP_Unidade],2)=#se#) and (Month(INP_DtFimInspecao) = #int(MesFinal)#)
		ORDER BY Month(INP_DtFimInspecao)
		</cfquery>
		<cfset qtdreal = 0>
		<cfif rsRealiz.recordcount gt 0>
		   <cfset qtdreal = rsRealiz.QuantRealiz>
		</cfif>
		<cfset TotGerPlan = TotGerPlan + rsPlan.Total_Plan>
		<cfset TotGerExec = TotGerExec + qtdreal>
		<!--- <cfset itemplan = 'P: ' & #mesd# & '(' & #Total_Plan# & ')'> --->
		<cfset itemplan = 'Plan - ' & #mesd#>
		<cfset itemexec = 'Exec - ' & #mesd#>
		  <cfchartdata item="#itemplan#" value="#rsPlan.Total_Plan#">
          <cfchartdata item="#itemexec#" value="#qtdreal#">
        </cfoutput> 
        </cfchartseries>
        </cfchart> 
	</td>
  </tr>
   <tr>
     <td colspan="2" class="titulos"><hr></td>
     </tr>
   <tr>
    <td width="321" class="titulos">Total Geral =&gt; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Planejado:&nbsp;&nbsp; <cfoutput>#TotGerPlan#</cfoutput></td>
    <td width="927" class="titulos"> Executado:&nbsp;&nbsp; <cfoutput>#TotGerExec#</cfoutput></td>
   </tr>
   <tr>
     <td colspan="2" class="titulos"><hr></td>
     </tr>
  <tr>
    <td colspan="2">
	<table width="281" border="1" align="left">
  <tr>
    <td class="titulos">Clique no m&ecirc;s para Gerar Relat&oacute;rio Anal&iacute;tico</td>
    </tr>
	<cfoutput>
   <td>
   <a href="Grafico_PACIN_Realizado2.cfm?ano=#ano#&se=#se#&mes=Todos" target="_blank"><span class="link1">Geral</span></a>
   </td>
   </cfoutput>
   <cfquery name="rsRealiz" datasource="#dsn_inspecao#">
		SELECT Month([INP_DtFimInspecao]) AS MesRealiz, Count(Month([INP_DtFimInspecao])) AS QuantRealiz 
		FROM Inspecao  GROUP BY Month([INP_DtFimInspecao]), Year([INP_DtFimInspecao]), Left([INP_Unidade],2) 
		<cfif #mes# is 'Todos'>
		  HAVING (Year([INP_DtFimInspecao])=#ano#) AND (Left([INP_Unidade],2)=#se#)
        <cfelse>
          HAVING (Year([INP_DtFimInspecao])=#ano#) AND (Left([INP_Unidade],2)=#se#) and (Month(INP_DtFimInspecao) = #mes#)
        </cfif>
	    ORDER BY Month(INP_DtFimInspecao)
	  </cfquery>
  <cfoutput query="rsRealiz">
          <cfset mesdesc = "">
		  <cfswitch expression="#MesRealiz#">
			<cfcase value="1">
				<cfset mesdesc = 'Janeiro'>
			</cfcase>
			<cfcase value="2">
				<cfset mesdesc = 'Fevereiro'>
			</cfcase>
			<cfcase value="3">
				<cfset mesdesc = 'Março'>
			</cfcase>
			<cfcase value="4">
				<cfset mesdesc = 'Abril'>
			</cfcase>
			<cfcase value="5">
				<cfset mesdesc = 'Maio'>
			</cfcase>
			<cfcase value="6">
				<cfset mesdesc = 'Junho'>
			</cfcase>
			<cfcase value="7">
				<cfset mesdesc = 'Julho'>
			</cfcase>
			<cfcase value="8">
				<cfset mesdesc = 'Agosto'>
			</cfcase>
			<cfcase value="9">
				<cfset mesdesc = 'Setembro'>
			</cfcase>
			<cfcase value="10">
				<cfset mesdesc = 'Outubro'>
			</cfcase>
			<cfcase value="11">
				<cfset mesdesc = 'Novembro'>
			</cfcase>
			<cfcase value="12">
				<cfset mesdesc = 'Dezembro'>
			</cfcase>																					
		 </cfswitch>
		 <tr>
		 <td>
		 <a href="Grafico_PACIN_Realizado2.cfm?ano=#ano#&se=#se#&mes=#MesRealiz#" target="_blank"><span class="link1">#mesdesc#</span></a>
		 </td>
		 </tr>
</cfoutput>
    
</table>
	</td>
  </tr>
</table>  

<cfelse>
 <p class="red_titulo">Informar os valores: Ano e Superintendência.</p>
</cfif> 
</form>
</body>
</html>