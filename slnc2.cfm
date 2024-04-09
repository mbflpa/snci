<cfprocessingdirective pageEncoding ="utf-8"> 
<cfsetting requesttimeout="10000">
<cfif len(form.lis_se) is 1>
	<cfset form.lis_se = 0 & form.lis_se>
</cfif>
<!--- <cfoutput>#form.lis_anoexerc#<br></cfoutput> --->

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfset total=0>

<!---  <cfif rsResumo.recordcount lte 0>
  Nao Ha dados a serem relatados para o periodo informado!<br>
  <input type="button" class="botao" onClick="window.close()" value="Fechar">
  <cfabort> 
</cfif>  --->
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	SELECT Dir_codigo, Dir_Sigla, Dir_Descricao FROM Diretoria WHERE Dir_codigo = '#lis_se#'
</cfquery>
<cfset auxfilta = #qAcesso.Dir_Descricao#>
<cfset auxfiltb = 'SE/' & #qAcesso.Dir_Sigla#>
<!---  --->
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
<cffile action="Append" file="#slocal##sarquivo#" output='#auxfilta#'>
<cffile action="Append" file="#slocal##sarquivo#" output='SOLUÇÃO DE NÃO CONFORMIDADES(SLNC)'>
<!--- <cffile action="Append" file="#slocal##sarquivo#" output=';;A;B;C;D;E=((C*100)/D);'>
<cffile action="Append" file="#slocal##sarquivo#" output='SE;Mês;Quantidade (Solucionados);Total;% de SL do mês;Meta Mensal;% Em Relação à meta Mensal;Resultado'> --->
<!---  --->


<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">
<script language="javascript">

function valida_form(a,b) {
   //	alert(a + '  ' + b);
   document.frmResumo.frmse.value = a;
   document.frmResumo.frmano.value = b;   
   document.frmResumo.submit();
}

</script>
<style type="text/css">
<!--
.style1 {font-size: 9px}
-->
</style>
</head>
<body>

<!--- Obter Solucionados por mes --->
<cfoutput>
<cfif form.lis_mes eq 0>
  <cfset aux_mes = 1> 
  <cfif int(form.lis_anoexerc) eq int(year(now()))>
	  <cfset auxmesfim = (int(month(now())) - 1)>
  <cfelse>
      <cfset auxmesfim = 12>      
  </cfif>
<cfelse>  
    <cfset aux_mes = #lis_mes#>
<!--- 	<cfif int(form.lis_anoexerc) eq int(year(now()))> --->
	  <cfset auxmesfim = #form.lis_mes#>  
	<!--- </cfif>   --->
</cfif>
<!--- #aux_mes#   #auxmesfim#<br><br> --->
</cfoutput>
<cfloop condition="#aux_mes# lte #auxmesfim#"> 
<cfoutput>	
<!--- #aux_mes#   #auxmesfim#<br> --->
	<cfif aux_mes is 1>
	  <cfset dtini = CreateDate(form.lis_anoexerc,1,1)>
	  <cfset dtfim = CreateDate(form.lis_anoexerc,1,31)>
	  <cfset mes = "Jan">
	<cfelseif aux_mes is 2>
			<cfif int(form.lis_anoexerc) mod 4 is 0>
			   <cfset dtfim = CreateDate(form.lis_anoexerc,2,29)>
			<cfelse>
			   <cfset dtfim = CreateDate(form.lis_anoexerc,2,28)>
			</cfif>
			<cfset dtini = CreateDate(form.lis_anoexerc,2,1)>				
	        <cfset mes = "Fev">			
	<cfelseif aux_mes is 3>
		   <cfset dtini = CreateDate(form.lis_anoexerc,3,1)>		
		   <cfset dtfim = CreateDate(form.lis_anoexerc,3,31)>
	       <cfset mes = "Mar">		   
	<cfelseif aux_mes is 4>
		   <cfset dtini = CreateDate(form.lis_anoexerc,4,1)>		
		   <cfset dtfim = CreateDate(form.lis_anoexerc,4,30)>		
		   <cfset mes = "Abr">
	<cfelseif aux_mes is 5>
		   <cfset dtini = CreateDate(form.lis_anoexerc,5,1)>		
		   <cfset dtfim = CreateDate(form.lis_anoexerc,5,31)>	
	   	   <cfset mes = "Mai">	
	<cfelseif aux_mes is 6>
		   <cfset dtini = CreateDate(form.lis_anoexerc,6,1)>		
		   <cfset dtfim = CreateDate(form.lis_anoexerc,6,30)>	
		   <cfset mes = "Jun">	
	<cfelseif aux_mes is 7>
		   <cfset dtini = CreateDate(form.lis_anoexerc,7,1)>		
		   <cfset dtfim = CreateDate(form.lis_anoexerc,7,31)>	
		   <cfset mes = "Jul">	
	<cfelseif aux_mes is 8>
		   <cfset dtini = CreateDate(form.lis_anoexerc,8,1)>		
		   <cfset dtfim = CreateDate(form.lis_anoexerc,8,31)>		
		   <cfset mes = "Ago">
	<cfelseif aux_mes is 9>
		   <cfset dtini = CreateDate(form.lis_anoexerc,9,1)>		
		   <cfset dtfim = CreateDate(form.lis_anoexerc,9,30)>
		   <cfset mes = "Set">		
	<cfelseif aux_mes is 10>
		   <cfset dtini = CreateDate(form.lis_anoexerc,10,1)>		
		   <cfset dtfim = CreateDate(form.lis_anoexerc,10,31)>		
		   <cfset mes = "Out">
	<cfelseif aux_mes is 11>
		   <cfset dtini = CreateDate(form.lis_anoexerc,11,1)>		
		   <cfset dtfim = CreateDate(form.lis_anoexerc,11,30)>		
		   <cfset mes = "Nov">
	<cfelse>
		   <cfset dtini = CreateDate(form.lis_anoexerc,12,1)>		
		   <cfset dtfim = CreateDate(form.lis_anoexerc,12,31)>
		   <cfset mes = "Dez">		
	</cfif>
<cfquery name="rsFer" datasource="#dsn_inspecao#">
   SELECT Fer_Data FROM FeriadoNacional 
   where Fer_Data between #dtini# and #dtfim#
   order by Fer_Data
</cfquery>
<cfif lis_grpace is 'un'>
	<!--- UNIDADE --->
	<cfquery name="rs3SO" datasource="#dsn_inspecao#">
		SELECT Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_tpunid, Andt_Area, Andt_RespAnt 
		FROM Andamento_Temp INNER JOIN Unidades ON Andt_Area = Und_Codigo
		WHERE (Andt_Resp = 3) and 
		(Andt_TipoRel = 2) and 
		Andt_RespAnt in (1,17,2,15,18,20) AND 
		(Und_CodDiretoria = '#lis_se#') and
		Andt_AnoExerc = '#form.lis_anoexerc#'
		<cfif lis_mes neq 0>
		  and Andt_Mes = #lis_mes#
		</cfif>
		order by Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item
	</cfquery>
</cfif>
<cfif lis_grpace is 'ge'>
	<!--- AREA --->
	<cfquery name="rs3SO" datasource="#dsn_inspecao#">
		SELECT Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_tpunid, Andt_Area, Andt_RespAnt 
		FROM Andamento_Temp INNER JOIN Areas ON Andt_Area = Ars_Codigo
		INNER JOIN Unidades ON Andt_Unid = Und_Codigo
		WHERE (Andt_Resp = 3) and 
		(Andt_TipoRel = 2) and 
		Andt_RespAnt in (6,5,19) AND 
		(Und_CodDiretoria = '#lis_se#') and 
		Andt_AnoExerc = '#form.lis_anoexerc#'
		<cfif lis_mes neq 0>
		  and Andt_Mes = #lis_mes#
		</cfif>
		order by Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item
	</cfquery>
</cfif>		
<cfif lis_grpace is 'sb'>
	<!--- SUBORDINADORES --->
	<cfquery name="rs3SO" datasource="#dsn_inspecao#">
		SELECT Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_tpunid, Andt_Area, Andt_RespAnt 
		FROM Andamento_Temp INNER JOIN Reops ON Andt_Area = Rep_Codigo
		INNER JOIN Unidades ON Andt_Unid = Und_Codigo
		WHERE (Andt_Resp = 3) and 
		(Andt_TipoRel = 2) and 
		Andt_RespAnt in (7,4,16) AND 
		(Und_CodDiretoria = '#lis_se#') and
		Andt_AnoExerc = '#form.lis_anoexerc#'
		<cfif lis_mes neq 0>
		  and Andt_Mes = #lis_mes#
		</cfif>
		order by Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item
	</cfquery>		
</cfif>	
<cfif lis_grpace is 'su'>							
	<!--- SUPERINTENDENTE --->
	<cfquery name="rs3SO" datasource="#dsn_inspecao#">
		SELECT Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_tpunid, Andt_Area, Andt_RespAnt 
		FROM Andamento_Temp INNER JOIN Reops ON Andt_Area = Rep_Codigo
		INNER JOIN Unidades ON Andt_Unid = Und_Codigo
		WHERE (Andt_Resp = 3) and 
		(Andt_TipoRel = 2) and 
		Andt_RespAnt in (22,8,23) AND 
		(Und_CodDiretoria = '#lis_se#') and
		Andt_AnoExerc = '#form.lis_anoexerc#'
		<cfif lis_mes neq 0>
		  and Andt_Mes = #lis_mes#
		</cfif>
		order by Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item
	</cfquery>
</cfif>		
<cfif lis_grpace is 'geral'>							
	<!--- Todos --->
	<cfquery name="rs3SO" datasource="#dsn_inspecao#">
		SELECT Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_tpunid, Andt_Area, Andt_RespAnt
		FROM Andamento_Temp 
		INNER JOIN Unidades ON Andt_Unid = Und_Codigo
		WHERE (Andt_Resp = 3) and 
		(Andt_TipoRel = 2) and  
		(Und_CodDiretoria = '#lis_se#') and
		Andt_AnoExerc = '#form.lis_anoexerc#'
		order by Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item
	</cfquery>
</cfif>	
</cfoutput>	
<!--- Fim obter solucionados por mes --->
<!--- Atualizar  Andamento_Temp--->
<cfoutput query="rs3SO">
    	<cfif rs3SO.Andt_Uteis lte 0 and lis_grpace neq 'geral'> 
			<cfset rs3SODT = CreateDate(year(rs3SO.Andt_DPosic),month(rs3SO.Andt_DPosic),day(rs3SO.Andt_DPosic))>
			<!---   <cfif rsExiste.Recordcount lte 0> --->
			
			<!--- Obter status14 --->
			<cfquery name="rs14ST" datasource="#dsn_inspecao#">
				Select And_DtPosic 
				from Andamento
				where And_Unidade = '#rs3SO.Andt_Unid#' and 
				And_NumInspecao = '#rs3SO.Andt_Insp#' and 
				And_NumGrupo = #rs3SO.Andt_Grp# and 
				And_NumItem = #rs3SO.Andt_Item# and 
				And_Situacao_Resp in(0,11,14)
				order by And_DtPosic desc
			</cfquery>
			<cfset auxDifdias = 0>
			<cfset dduteis = 0> 
			<cfif rs14ST.recordcount gt 0>
				<cfset rs14STDT = CreateDate(year(rs14ST.And_DtPosic),month(rs14ST.And_DtPosic),day(rs14ST.And_DtPosic))>
				<cfset auxdtnova = CreateDate(year(now()),month(now()),day(now()))>
				<cfset auxDifdias = dateDiff("d", rs14STDT, dtfim)>	
				<!--- obter dias uteis  --->
				<cfset dduteis = 0> 
				<cfset dias = auxDifdias>  
				<cfset nCont = 1>
				<cfset dsusp = 0>
				<cfset auxdtnova = rs14STDT>
				<cfset auxdtfim = CreateDate(year(now()),month(now()),day(now()))>
				<cfset auxdtfim = DateAdd("d", #auxDifdias#, #auxdtnova#)>
				<!--- obter os sabados/domingos nos feriados nacionais --->
				<cfset vDiaSem = DayOfWeek(auxdtnova)>
				<cfif rsFer.recordcount gt 0> 
						<cfloop query="rsFer">
							<cfif dateformat(rsFer.Fer_Data,"YYYYMMDD") eq dateformat(auxdtnova,"YYYYMMDD")>
								<cfset dsusp = dsusp + 1>
							</cfif>
						</cfloop> 
				</cfif>
			<cfloop condition="nCont lte #auxDifdias#">  
				<cfif (vDiaSem eq 1) or (vDiaSem eq 7)> 
				  <cfset dsusp = dsusp + 1>
				 </cfif> 
				<cfset auxdtnova = DateAdd("d", 1, #auxdtnova#)>
				<cfset nCont = nCont + 1> 
			</cfloop> 
			<cfset dduteis = auxDifdias - dsusp>
			<cfif dduteis lte 0>
				<cfset dduteis = 1>
			</cfif>	
	</cfif>

	<!--- Obter prazo --->
	<cfif (dduteis gt 10)> 
		<cfset prz = "FP">
	<cfelse> 
		<cfset prz = "DP">
	</cfif>
	<!--- Fim obter prazo --->
	<!--- Obter orgao condutor --->
	<cfset rsAntesResp = rs3SO.Andt_RespAnt>
	<cfif trim(rs3SO.Andt_Area) neq "">
		<cfif (rsAntesResp is 1 or rsAntesResp is 17 or rsAntesResp is 2 or rsAntesResp is 15 or rsAntesResp is 18 or rsAntesResp is 20)>
			<cfquery name="rsSoluc" datasource="#dsn_inspecao#">
				SELECT Und_Codigo, Und_Descricao FROM Unidades WHERE Und_Codigo = '#rs3SO.Andt_Area#'
			</cfquery>
			<cfset auxarea = #rsSoluc.Und_Descricao#>
		</cfif>
		<cfif rsAntesResp is 6 or rsAntesResp is 5 or rsAntesResp is 19>
			<cfquery name="rsSoluc" datasource="#dsn_inspecao#">
				SELECT Ars_Codigo, Ars_Descricao FROM Areas WHERE Ars_Codigo = '#rs3SO.Andt_Area#'
			</cfquery>
			<cfset auxarea = #rsSoluc.Ars_Descricao#>
		</cfif>
		<cfif rsAntesResp is 7 or rsAntesResp is 4 or rsAntesResp is 16>
			<cfquery name="rsSoluc" datasource="#dsn_inspecao#">
				SELECT Rep_Codigo, Rep_Nome FROM Reops WHERE Rep_Codigo = '#rs3SO.Andt_Area#'
			</cfquery>
			<cfset auxarea = #rsSoluc.Rep_Nome#>			
		</cfif>
		<cfif rsAntesResp is 22 or rsAntesResp is 8 or rsAntesResp is 23>
			<cfquery name="rsSoluc" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Descricao FROM Diretoria	WHERE Dir_Sto = '#rs3SO.Andt_Area#'
			</cfquery>
			<cfset auxarea = #rsSoluc.Dir_Descricao#>			
		</cfif>			
	</cfif>
	<cfif auxarea eq "">
	  <cfset auxarea = "---">
	</cfif>
	<!--- Fim obter orgao condutor --->
	<!--- #rs3SO.Andt_Mes# #rs14STDT#<br> --->	
	<cfquery datasource="#dsn_inspecao#">
	UPDATE Andamento_Temp SET Andt_DTEnvio = #rs14STDT# 
	, Andt_NomeOrgCondutor = '#auxarea#'
	, Andt_Prazo = '#prz#'
	, Andt_DiasCor = #auxDifdias#
	, Andt_Uteis = #dduteis#
	WHERE  Andt_TipoRel = 2 and 
	Andt_AnoExerc = '#form.lis_anoexerc#' and
	Andt_Mes = #rs3SO.Andt_Mes# and 
	Andt_Insp = '#rs3SO.Andt_Insp#' and 
	Andt_Unid = '#rs3SO.Andt_Unid#' and 
	Andt_Grp = #rs3SO.Andt_Grp# and 
	Andt_Item = #rs3SO.Andt_Item# 
	</cfquery> 	 
 </cfif> 
 </cfoutput>

  <cfset aux_mes = aux_mes + 1>
 </cfloop>
<!--- <cfoutput><br><br><br>#aux_mes#   #auxmesfim#</cfoutput> --->
<!--- <cfset gil = gil> --->
<!--- Fim - Atualizar  Andamento_Temp--->
<!--- Exibir em tela --->
<cfoutput>
<cfif lis_grpace is 'un'>
	<cfquery name="rsResumo" datasource="#dsn_inspecao#">
		SELECT Dir_Codigo, Dir_Sigla, Dir_Descricao, Andt_Unid, Und_Descricao, Andt_Mes, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, STO_Descricao, Andt_Uteis, Andt_Area, Andt_DTEnvio, Andt_NomeOrgCondutor, Andt_Prazo, Andt_DTRefer, Andt_NomeOrgCondutor 
		FROM Andamento_Temp 
		INNER JOIN Unidades ON Andt_Area = Und_Codigo
		INNER JOIN Situacao_Ponto ON Andt_Resp = STO_Codigo 
		INNER JOIN Diretoria ON Dir_Codigo = Und_CodDiretoria 
		WHERE (Andt_AnoExerc='#form.lis_anoexerc#' AND Andt_TipoRel=2 AND Andt_CodSE='#form.lis_se#' AND Andt_Resp=3 AND Andt_RespAnt In (1,2,15,17,18,20) 
		<cfif form.lis_mes neq 0>
		  and Andt_Mes = #form.lis_mes# 
		</cfif>
		)
		OR 
		(Andt_AnoExerc='#form.lis_anoexerc#' AND Andt_TipoRel=2 AND Andt_CodSE='#form.lis_se#' AND Andt_Resp In (1,2,15,17,18,20)
		<cfif form.lis_mes neq 0>
		  and Andt_Mes = #form.lis_mes# 
		</cfif>
		)
		order by Dir_Codigo, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic
	</cfquery>
</cfif>
<cfif lis_grpace is 'ge'>
	<!--- AREA --->
	<cfquery name="rsResumo" datasource="#dsn_inspecao#">
		SELECT Dir_Codigo, Dir_Sigla, Dir_Descricao, Andt_Unid, Und_Descricao, Andt_Mes, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, STO_Descricao, Andt_Uteis, Andt_Area, Andt_DTEnvio, Andt_NomeOrgCondutor, Andt_Prazo, Andt_DTRefer, Andt_NomeOrgCondutor 
		FROM Andamento_Temp
		INNER JOIN Areas ON Andt_Area = Ars_Codigo
		INNER JOIN Unidades ON Andt_Unid = Und_Codigo
		INNER JOIN Situacao_Ponto ON Andt_Resp = STO_Codigo 
		INNER JOIN Diretoria ON Dir_Codigo = Und_CodDiretoria 
		WHERE (Andt_AnoExerc='#form.lis_anoexerc#' AND Andt_TipoRel=2 AND Andt_CodSE='#form.lis_se#' AND Andt_Resp=3 AND Andt_RespAnt In (5,6,19) 
		<cfif form.lis_mes neq 0>
		  and Andt_Mes = #form.lis_mes# 
		</cfif>
		)
		OR 
		(Andt_AnoExerc='#form.lis_anoexerc#' AND Andt_TipoRel=2 AND Andt_CodSE='#form.lis_se#' AND Andt_Resp In (5,6,19)
		<cfif form.lis_mes neq 0>
		  and Andt_Mes = #form.lis_mes# 
		</cfif>
		)
		order by Dir_Codigo, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic
	</cfquery>	

</cfif>		
<cfif lis_grpace is 'sb'>
	<!--- SUBORDINADORES --->
	<cfquery name="rsResumo" datasource="#dsn_inspecao#">
		SELECT Dir_Codigo, Dir_Sigla, Dir_Descricao, Andt_Unid, Und_Descricao, Andt_Mes, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, STO_Descricao, Andt_Uteis, Andt_Area, Andt_DTEnvio, Andt_NomeOrgCondutor, Andt_Prazo, Andt_DTRefer, Andt_NomeOrgCondutor 
		FROM Andamento_Temp 
		INNER JOIN Reops ON Andt_Area = Rep_Codigo
		INNER JOIN Unidades ON Andt_Unid = Und_Codigo
		INNER JOIN Situacao_Ponto ON Andt_Resp = STO_Codigo 
		INNER JOIN Diretoria ON Dir_Codigo = Und_CodDiretoria 
		WHERE (Andt_AnoExerc='#form.lis_anoexerc#' AND Andt_TipoRel=2 AND Andt_CodSE='#form.lis_se#' AND Andt_Resp=3 AND Andt_RespAnt In (4,7,16) 
		<cfif form.lis_mes neq 0>
		  and Andt_Mes = #form.lis_mes# 
		</cfif>
		)
		OR 
		(Andt_AnoExerc='#form.lis_anoexerc#' AND Andt_TipoRel=2 AND Andt_CodSE='#form.lis_se#' AND Andt_Resp In (4,7,16)
		<cfif form.lis_mes neq 0>
		  and Andt_Mes = #form.lis_mes# 
		</cfif>
		)		
		order by Dir_Codigo, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic
	</cfquery>		
</cfif>	
<cfif lis_grpace is 'su'>			
	<!--- SUPERINTENDENTE --->
	<cfquery name="rsResumo" datasource="#dsn_inspecao#">
		SELECT Dir_Codigo, Dir_Sigla, Dir_Descricao, Andt_Unid, Und_Descricao, Andt_Mes, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, STO_Descricao, Andt_Uteis, Andt_Area, Andt_DTEnvio, Andt_NomeOrgCondutor, Andt_Prazo, Andt_DTRefer, Andt_NomeOrgCondutor 
		FROM ((Situacao_Ponto INNER JOIN (Andamento_Temp INNER JOIN Unidades ON Andt_Unid = Und_Codigo) ON STO_Codigo = Andt_Resp) INNER JOIN Reops ON Und_CodReop = Rep_Codigo) INNER JOIN Diretoria ON Andt_CodSE = Dir_Codigo
		WHERE (Andt_AnoExerc='#form.lis_anoexerc#' AND Andt_TipoRel=2 AND Andt_CodSE='#form.lis_se#' AND Andt_Resp=3 AND Andt_RespAnt In (8,22,23) 
		<cfif form.lis_mes neq 0>
		  and Andt_Mes = #form.lis_mes# 
		</cfif>
		)
		OR 
		(Andt_AnoExerc='#form.lis_anoexerc#' AND Andt_TipoRel=2 AND Andt_CodSE='#form.lis_se#' AND Andt_Resp In (8,22,23)
		<cfif form.lis_mes neq 0>
		  and Andt_Mes = #form.lis_mes# 
		</cfif>
		)
		order by Dir_Codigo, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic
	</cfquery>	
</cfif>	
<cfif lis_grpace is 'geral'>	
	<!--- geral --->
	<cfquery name="rsResumo" datasource="#dsn_inspecao#">
		SELECT Dir_Codigo, Dir_Sigla, Dir_Descricao, Andt_Unid, Und_Descricao, Andt_Mes, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, STO_Descricao, Andt_Uteis, Andt_Area, Andt_DTEnvio, Andt_NomeOrgCondutor, Andt_Prazo, Andt_DTRefer, Andt_NomeOrgCondutor 
		FROM Andamento_Temp
		INNER JOIN Diretoria ON Andt_CodSE = Dir_Codigo
		INNER JOIN Unidades ON Andt_Unid = Und_Codigo
		INNER JOIN Situacao_Ponto ON Andt_Resp = STO_Codigo 
		WHERE Dir_Codigo ='#form.lis_se#' AND 
		Andt_AnoExerc = '#form.lis_anoexerc#' and
		(Andt_Resp = 3) and Andt_TipoRel = 2 
		order by Dir_Codigo, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic
	</cfquery>	
</cfif>
</cfoutput>

<form action="itens_Gestao_2.cfm" method="get" target="_blank" name="frmResumo">
 	<cfif form.lis_grpace is "un">
		<cfset grpace = "Unidades">
 		<cfset relgpac = "UNSO">
	<cfelseif form.lis_grpace is "ge">
		<cfset grpace = "Gerências Regionais e Áreas de Suporte">
		<cfset relgpac = "GRSO">
	<cfelseif form.lis_grpace is "sb">
		<cfset grpace = "Órgãos Subordinadores">
		<cfset relgpac = "OSSO">
	<cfelseif form.lis_grpace is "su">
		<cfset grpace = "Superintendência">
		<cfset relgpac = "SUSO">
    <cfelseif form.lis_grpace is "geral">
		<cfset grpace = "Geral">
		<cfset relgpac = "Gerais">
	</cfif>  
  <table width="90%" border="1" align="center" cellpadding="0" cellspacing="0">
  <cfoutput>
  <!--- Excluir arquivos anteriores ao dia atual --->
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Matricula FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
<!--- <cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'> --->
<cfset relmes = trim(form.lis_mes)>
<cfif len(relmes) is 1>
	<cfset relmes = 0 & relmes>
</cfif> 
<!--- <cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(form.lis_se)# & #relgpac# & #relmes# & '.xls'> --->
      <tr>
        <td colspan="12"><div align="center" class="titulo1">#auxfilta#</div></td>
      </tr>
      <tr>
        <td colspan="13"><div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/csv.png" width="39" height="38" border="0"></a></div></td>
      </tr>
      <tr>
        <td colspan="12"><div align="center" class="exibir"><span class="titulo1"><strong>Solução de Não Conformidades (SLNC)</strong></span></div></td>
      </tr>
<cfif grpace neq 'geral'>
	<tr>
		<td colspan="10" class="titulos"><p>#grpace# &nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;&nbsp;SOLUCIONADOS: #form.lis_soluc#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Outros Status: #form.lis_outros#</p>
	</td>
		<cfset auxqtd = form.lis_soluc + form.lis_outros> 
		<td colspan="2" class="titulos"><div align="right">Qtd.:&nbsp; #auxqtd#</div></td>
	</tr>
	<cffile action="Append" file="#slocal##sarquivo#" output='#grpace#  -  SOLUCIONADOS: #form.lis_soluc#     Outros Status: #form.lis_outros#;;;;;;;;;;Qtd.: #auxqtd#'> 
<cfelse>
	<tr>
		<td colspan="10" class="titulos"><p>#grpace# &nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;&nbsp;SOLUCIONADOS: #rs3SO.recordcount#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Outros Status: 0</p>
	</td>
		<cfset auxqtd = rsResumo.recordcount> 
		<td colspan="2" class="titulos"><div align="right">Qtd.:&nbsp; #auxqtd#</div></td>
	</tr>
	<cffile action="Append" file="#slocal##sarquivo#" output='#grpace#  -  SOLUCIONADOS: #rs3SO.recordcount#     Outros Status: 0;;;;;;;;;;Qtd.: #auxqtd#'> 
</cfif>		 
	   
</cfoutput>	  

	  <tr class="exibir">
	    <td width="4%" height="27" class="titulos"><div align="center">Mês</div>
	      <div align="center"></div></td>
        <td width="16%" class="titulos"><div align="left">Unidade</div>
        <div align="center"></div></td>
        <td width="20%" class="titulos">Órgão Solucionador (*)</td>
        <td width="6%" class="titulos">Relatório</td>
        <td width="5%" class="titulos"><div align="center">Grupo</div></td>
        <td width="4%" class="titulos"><div align="center">Item</div></td>
		<td width="9%" class="titulos">Dt. Liberação (**)</td>
        <td width="9%" class="titulos">Dt. Solução </td>
        <td width="11%" class="titulos"><div align="center"></div>          
          <div align="center">Ação</div></td>
        <td width="6%" class="titulos">Dt. Refer.:</td>
        <td width="10%" class="titulos"><div align="center">Tempo de Solução(dias úteis) (***)</div></td>
<!---         <td width="7%" class="titulos"><div align="center">Prazo</div></td> --->
      </tr>
	<cffile action="Append" file="#slocal##sarquivo#" output='Mês;Unidade;Órgão Solucionador(*);Relatório;Grupo;Item;Dt. Liberação(**);Dt. Solução;Dt. refer.:;Tempo de Solução(dias úteis)(***)'>
<cfoutput query="rsResumo">
<!--- Dir_Codigo, Dir_Sigla, Dir_Descricao, Andt_Unid, Und_Descricao, Andt_Mes, , , , , Andt_HPosic, Andt_Resp, STO_Descricao, Andt_Uteis, Andt_Area, Andt_DTEnvio, Andt_NomeOrgCondutor, , Andt_DTRefer  --->
<!---  --->
	<cfif Andt_Mes is 1>
		<cfset mes = "Jan">
	<cfelseif Andt_Mes is 2>
		<cfset mes = "Fev">			
	<cfelseif Andt_Mes is 3>
		<cfset mes = "Mar">		   
	<cfelseif Andt_Mes is 4>
		<cfset mes = "Abr">
	<cfelseif Andt_Mes is 5>
		<cfset mes = "Mai">	
	<cfelseif Andt_Mes is 6>
		<cfset mes = "Jun">	
	<cfelseif Andt_Mes is 7>
		<cfset mes = "Jul">	
	<cfelseif Andt_Mes is 8>
		<cfset mes = "Ago">
	<cfelseif Andt_Mes is 9>
		<cfset mes = "Set">		
	<cfelseif Andt_Mes is 10>
		<cfset mes = "Out">
	<cfelseif Andt_Mes is 11>
		<cfset mes = "Nov">
	<cfelse>
		<cfset mes = "Dez">		
	</cfif>
<!---  --->
		 
	<tr class="exibir">
	    <td><div align="center">#mes#</div></td>
	    <td><span class="style1">#Und_Descricao#</span></td>
	    <td><span class="style1">#Andt_NomeOrgCondutor#</span></td>
	    <td>#Andt_Insp#</td>
		<cfset auxgrp = Andt_Grp>
	    <td><div align="center">#auxgrp#</div></td>
		<cfset auxit = Andt_Item>
	    <td><div align="center">#auxit#</div></td>
	 	<cfif len(Andt_DTEnvio) gte 8>
			<cfset dtenvio = dateformat(Andt_DTEnvio,"dd/mm/yyyy")>
		<cfelse>
			<cfset dtenvio = "---">		
		</cfif> 
		
	    <td><div align="center">#dtenvio#</div></td>
		<cfset dtposic = dateformat(Andt_DPosic,"dd/mm/yyyy")>
	    <td><div align="center">#dtposic#</div></td>
	    <td><div align="center">#rsResumo.STO_Descricao#</div></td>
	    <cfset dtfim = dateformat(dtfim,"dd/mm/yyyy")>
	    <td><div align="center">#dtfim#</div></td>	
<CFSET DDUT = 0>	
<cfif Andt_Resp is 3 and grpace neq 'geral'>		
		<!--- inicio dias uteis --->
			<cfset auxdtprev = CreateDate(year(Andt_DTEnvio),month(Andt_DTEnvio),day(Andt_DTEnvio))>
			<cfset nCont = 'S'>
			<cfset ddsupr = 0>
			<cfloop condition="nCont eq 'S'">
			   <cfset auxdtprev = DateAdd( "d", 1, auxdtprev)>
			   <cfset vDiaSem = DayOfWeek(auxdtprev)>
				<!--- Verifica se final de semana  --->
				<cfif vDiaSem eq 1 or vDiaSem eq 7>
					<cfset ddsupr = ddsupr + 1>
				</cfif>
				<cfif dateformat(auxdtprev,"YYYYMMDD") GTE dateformat(Andt_DPosic,"YYYYMMDD")>
				  <cfset nCont = 'N'>
				</cfif>
			</cfloop>					
		<!--- fim dias uteis --->
		
		 <cfset  diascor = DateDiff( "d", Andt_DTEnvio, Andt_DPosic)> 
		<CFSET DDUT = diascor - ddsupr> 
</cfif>		
	    <td><div align="center">#DDUT#</div></td>
      <!---   <td><div align="center">A Definir</div></td> --->
</tr>	  
<cffile action="Append" file="#slocal##sarquivo#" output='#mes#;#Und_Descricao#;#Andt_NomeOrgCondutor#;#Andt_Insp#;#auxgrp#;#auxit#;#dtenvio#;#dtposic#;#rsResumo.STO_Descricao#;#dtfim#;#DDUT#'>	
</cfoutput> 

      <tr class="exibir">
        <td colspan="12" class="titulos">&nbsp;</td>
      </tr>
      <tr class="exibir">
        <td colspan="12" class="titulos">(*) Órgão Solucionador:  &nbsp;&nbsp;É o responsável pela solução do ponto.</td>
      </tr>
	  <cffile action="Append" file="#slocal##sarquivo#" output='(*) Órgão Solucionador:   Órgão responsável pela solução do ponto.'>
	   <tr class="exibir">
        <td colspan="12" class="titulos">(**) <strong>Dt. Liberação</strong>:&nbsp;É a data de envio do relatório de avaliação de controle interno para unidade.</td>
      </tr>
	  <cffile action="Append" file="#slocal##sarquivo#" output='(**) Dt. Liberação:  É a data de envio do relatório de avaliação de controle interno para unidade.'>
	   <tr class="exibir">
        <td colspan="12" class="titulos">(***) Tempo de Solução(dias úteis): &nbsp;&nbsp;É o intervalo entre a data de liberação e a data de solução.</td>
      </tr>	
	  <cffile action="Append" file="#slocal##sarquivo#" output='(***) Tempo de Solução(dias úteis):   É o intervalo entre a data de liberação e a data de solução.'>  
      <tr class="exibir">
        <td colspan="12">
		<table width="1179" border="0">
          <tr>
            <td colspan="12"><p align="center" class="titulos"><strong> CRITÉRIOS DE MENSURAÇÃO </strong></p></td>
          </tr>
<cffile action="Append" file="#slocal##sarquivo#" output='CRITÉRIOS DE MENSURAÇÃO'>  		  
         <tr class="exibir">
            <td width="121" class="exibir"><strong>SOLUCIONADO</strong></td>
            <td width="1048"><p> A situação apontada foi regularizada pelo gestor. </p></td>
          </tr>
<cffile action="Append" file="#slocal##sarquivo#" output='SOLUCIONADO A situaçao apontada foi regularizada pelo gestor. 
 '> 		  
        </table></td>
      </tr>  
  </table>
  
    <input name="frmse" type="hidden" id="frmse">
    <input name="frmano" type="hidden" id="frmano">
</form>
  <cfinclude template="rodape.cfm">
</body>
</html>
