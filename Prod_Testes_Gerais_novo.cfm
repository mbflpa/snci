<cfsetting requesttimeout="15000">
<!--- ================  inicio Salvas ======================= --->
<cfquery name="rsDia" datasource="#dsn_inspecao#">
  SELECT MSG_Realizado, MSG_Status FROM Mensagem WHERE MSG_Codigo = 1
</cfquery>
<cfset auxdiacol = rsDia.MSG_Realizado>
<cfset auxdiacol = left(auxdiacol,4) & '-' & mid(auxdiacol,5,2) & '-' & right(auxdiacol,2)>
<cfset dtlimit = CreateDate(year(auxdiacol),month(auxdiacol),day(auxdiacol))> 
<!---<cfset dtlimit = CreateDate(year(now()),month(now()),day(now()))> 
 <cfset dtlimit = CreateDate(2024,1,31)>  --->
<cfset aux_mes = month(dtlimit)>
<cfset dtini = CreateDate(year(dtlimit),month(dtlimit),1)>		
<cfset dtfim = dtlimit>	

<!--- Criar linha de metas para o exercício do PACIN --->
<cfset anoexerc = year(dtlimit)>
<cfquery name="rsMetas" datasource="#dsn_inspecao#">
	SELECT Met_Codigo, Met_SE_STO, Met_PRCI, Met_SLNC, Met_DGCI, Met_Mes
	FROM Metas
	WHERE Met_Ano = '#anoexerc#' and Met_Mes = 1 
	order by Met_Codigo
</cfquery>

<cfset nMes = aux_mes>
<cfoutput query="rsMetas">
	<cfset metprci = trim(rsMetas.Met_PRCI)>
	<cfset metslnc = trim(rsMetas.Met_SLNC)>
	<cfset metdgci = trim(rsMetas.Met_DGCI)>

	<cfquery name="rsMes" datasource="#dsn_inspecao#">
		SELECT Met_Ano
		FROM Metas
		WHERE Met_Codigo ='#rsMetas.Met_Codigo#' AND Met_Ano = #anoexerc# AND Met_Mes = #nMes#
	</cfquery>
	<cfif rsMes.recordcount lte 0>		
			<cfquery datasource="#dsn_inspecao#">
				insert into Metas (Met_Codigo,Met_Ano,Met_Mes,Met_SE_STO,Met_PRCI,Met_PRCI_Mes,Met_PRCI_Acum,Met_PRCI_AcumPeriodo,Met_SLNC,Met_SLNC_Mes,Met_SLNC_Acum,Met_SLNC_AcumPeriodo,Met_DGCI,Met_DGCI_Mes,Met_DGCI_Acum,Met_DGCI_AcumPeriodo,Met_Resultado) 
				values ('#rsMetas.Met_Codigo#',#anoexerc#,#aux_mes#,'#rsMetas.Met_SE_STO#','#metprci#','#metprci#','0.0','0.0','#metslnc#','#metslnc#','0.0','0.0','#metdgci#','#metdgci#','0.0','0.0','0.0')
			</cfquery>   
	</cfif>	
</cfoutput>	
		
<!--- Fim Criar linha de metas para o exercício do PACIN --->

<!--- atualizar a tabela SLNCPRCIDCGIMES com os dados da PARACERUNIDADE --->
<!--- limpar tabela temp --->
<cfquery datasource="#dsn_inspecao#">
	delete from SLNCPRCIDCGIMES 
</cfquery>	

<!--- obter os solucionados do mês --->
<cfquery name="rs3SO" datasource="#dsn_inspecao#">
	SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, pos_dtultatu, pos_username, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
	FROM ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
	WHERE Pos_Situacao_Resp = 3 and Pos_DtPosic between #dtini# and #dtfim# 
</cfquery>	

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,45)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfloop query="rs3SO">
	<cfset PosDtPosic = CreateDate(year(rs3SO.Pos_DtPosic),month(rs3SO.Pos_DtPosic),day(rs3SO.Pos_DtPosic))>
	<cfif len(trim(rs3SO.Pos_DtPrev_Solucao)) neq 0>
		<cfset PosDtPrevSolucao = CreateDate(year(rs3SO.Pos_DtPrev_Solucao),month(rs3SO.Pos_DtPrev_Solucao),day(rs3SO.Pos_DtPrev_Solucao))>
	<cfelse>
		<cfset PosDtPrevSolucao = CreateDate(year(rs3SO.Pos_DtPosic),month(rs3SO.Pos_DtPosic),day(rs3SO.Pos_DtPosic))>
	</cfif>
	<cfif len(trim(rs3SO.Pos_PontuacaoPonto)) neq 0 AND len(trim(rs3SO.Pos_ClassificacaoPonto)) NEQ 0>
		<cfset PosPontuacaoPonto = trim(rs3SO.Pos_PontuacaoPonto)>
		<cfset PosClassificacaoPonto = trim(rs3SO.Pos_ClassificacaoPonto)>
	<cfelse>
		<cfset PosPontuacaoPonto = 0>
		<cfset PosClassificacaoPonto = 'FALTA'>
	</cfif>					
	<cfset posdtultatu = CreateDate(year(rs3SO.pos_dtultatu),month(rs3SO.pos_dtultatu),day(rs3SO.pos_dtultatu))>
	<cfset auxsta = rs3SO.Pos_Situacao_Resp> 
	<cfset auxantes = 0>
	<cfif rs3SO.Pos_Sit_Resp_Antes gt 0>
		<cfset auxantes = rs3SO.Pos_Situacao_Resp>
	</cfif>					
	<cfquery datasource="#dsn_inspecao#">
		insert into SLNCPRCIDCGIMES (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao, 
		pos_username, Pos_Area, Pos_NomeArea, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes) values ('#rs3SO.Pos_Unidade#', '#rs3SO.Pos_Inspecao#', #rs3SO.Pos_NumGrupo#, #rs3SO.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rs3SO.Pos_Situacao#', '#rs3SO.pos_username#', '#rs3SO.Pos_Area#', '#rs3SO.Pos_NomeArea#', #PosDtPrevSolucao#, #PosPontuacaoPonto#, '#PosClassificacaoPonto#', #auxantes#)
	</cfquery>		
</cfloop>	
<!--- NAO RESPONDIDO PENDENTES E TRATAMENTOS --->
<cfquery name="rsNRPENDTRAT" datasource="#dsn_inspecao#">
	SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, pos_dtultatu, pos_username, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
	FROM ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
	WHERE Pos_Situacao_Resp In (14,2,4,5,8,15,16,18,19,20,23) 
</cfquery>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,45)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfloop query="rsNRPENDTRAT">
		<cfset PosDtPosic = CreateDate(year(rsNRPENDTRAT.Pos_DtPosic),month(rsNRPENDTRAT.Pos_DtPosic),day(rsNRPENDTRAT.Pos_DtPosic))>
		<cfif len(trim(rsNRPENDTRAT.Pos_DtPrev_Solucao)) neq 0>
		<cfset PosDtPrevSolucao = CreateDate(year(rsNRPENDTRAT.Pos_DtPrev_Solucao),month(rsNRPENDTRAT.Pos_DtPrev_Solucao),day(rsNRPENDTRAT.Pos_DtPrev_Solucao))>
		<cfelse>
		<cfset PosDtPrevSolucao = CreateDate(year(rsNRPENDTRAT.Pos_DtPosic),month(rsNRPENDTRAT.Pos_DtPosic),day(rsNRPENDTRAT.Pos_DtPosic))>
		</cfif>
		<cfif len(trim(rsNRPENDTRAT.Pos_PontuacaoPonto)) neq 0 AND len(trim(rsNRPENDTRAT.Pos_ClassificacaoPonto)) NEQ 0>
			<cfset PosPontuacaoPonto = trim(rsNRPENDTRAT.Pos_PontuacaoPonto)>
			<cfset PosClassificacaoPonto = trim(rsNRPENDTRAT.Pos_ClassificacaoPonto)>
		<cfelse>
			<cfset PosPontuacaoPonto = 0>
			<cfset PosClassificacaoPonto = 'FALTA'>
		</cfif>						
		<cfset posdtultatu = CreateDate(year(rsNRPENDTRAT.pos_dtultatu),month(rsNRPENDTRAT.pos_dtultatu),day(rsNRPENDTRAT.pos_dtultatu))>
		<cfset auxsta = rsNRPENDTRAT.Pos_Situacao_Resp>
		<cfset auxantes = 0>
		<cfif rsNRPENDTRAT.Pos_Sit_Resp_Antes gt 0>
			<cfset auxantes = rsNRPENDTRAT.Pos_Situacao_Resp>
		</cfif>							
		<cfquery datasource="#dsn_inspecao#">
			insert into SLNCPRCIDCGIMES (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao, 
			pos_username, Pos_Area, Pos_NomeArea, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes) values ('#rsNRPENDTRAT.Pos_Unidade#', '#rsNRPENDTRAT.Pos_Inspecao#', #rsNRPENDTRAT.Pos_NumGrupo#, #rsNRPENDTRAT.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rsNRPENDTRAT.Pos_Situacao#', '#rsNRPENDTRAT.pos_username#', '#rsNRPENDTRAT.Pos_Area#', '#rsNRPENDTRAT.Pos_NomeArea#', #PosDtPrevSolucao#, #PosPontuacaoPonto#, '#PosClassificacaoPonto#', #auxantes#)
		</cfquery>	
</cfloop>			
<!--- RESPOSTAS, CS, PI, OC, RV, AP, RC, NC, BX, EA, EC e TP (DENTRO DO MES)--->	
<cfquery name="rsOutros" datasource="#dsn_inspecao#">
	SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, pos_dtultatu, pos_username, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
	FROM ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
	WHERE Pos_Situacao_Resp In (1,6,7,17,22,9,10,12,13,21,24,25,26,27,28,29,30) and Pos_DtPosic between #dtini# and #dtfim# 
</cfquery>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,45)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfloop query="rsOutros">
	<cfset PosDtPosic = CreateDate(year(rsOutros.Pos_DtPosic),month(rsOutros.Pos_DtPosic),day(rsOutros.Pos_DtPosic))>
	<cfif len(trim(rsOutros.Pos_DtPrev_Solucao)) neq 0>
		<cfset PosDtPrevSolucao = CreateDate(year(rsOutros.Pos_DtPrev_Solucao),month(rsOutros.Pos_DtPrev_Solucao),day(rsOutros.Pos_DtPrev_Solucao))>
	<cfelse>
		<cfset PosDtPrevSolucao = CreateDate(year(rsOutros.Pos_DtPosic),month(rsOutros.Pos_DtPosic),day(rsOutros.Pos_DtPosic))>
	</cfif>
	<cfif len(trim(rsOutros.Pos_PontuacaoPonto)) neq 0 AND len(trim(rsOutros.Pos_ClassificacaoPonto)) NEQ 0>
		<cfset PosPontuacaoPonto = trim(rsOutros.Pos_PontuacaoPonto)>
		<cfset PosClassificacaoPonto = trim(rsOutros.Pos_ClassificacaoPonto)>
	<cfelse>
		<cfset PosPontuacaoPonto = 0>
		<cfset PosClassificacaoPonto = 'FALTA'>
	</cfif>						
	<cfset posdtultatu = CreateDate(year(rsOutros.pos_dtultatu),month(rsOutros.pos_dtultatu),day(rsOutros.pos_dtultatu))>
	<cfset auxsta = rsOutros.Pos_Situacao_Resp> 
	<cfset auxantes = 0>
	<cfif rsOutros.Pos_Sit_Resp_Antes gt 0>
		<cfset auxantes = rsOutros.Pos_Situacao_Resp>
	</cfif>	
	<cfquery datasource="#dsn_inspecao#">
		insert into SLNCPRCIDCGIMES (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao, 
		pos_username, Pos_Area, Pos_NomeArea, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes) values ('#rsOutros.Pos_Unidade#', '#rsOutros.Pos_Inspecao#', #rsOutros.Pos_NumGrupo#, #rsOutros.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rsOutros.Pos_Situacao#', '#rsOutros.pos_username#', '#rsOutros.Pos_Area#', '#rsOutros.Pos_NomeArea#', #PosDtPrevSolucao#, #PosPontuacaoPonto#, '#PosClassificacaoPonto#', #auxantes#)
	</cfquery>		
</cfloop>	
<!--- FIM atualizar a tabela SLNCPRCIDCGIMES com os dados da PARACERUNIDADE ---> 
<cfinclude template="INDICADORES_MES.CFM">

<!--- ================ GERAR INDICADOR PRCI ====================== --->
<!--- Garantir integridade dos dados com a exclusão de dados do mês a ser gerado (PRCI=1 e SLNC=2) --->
<cfquery datasource="#dsn_inspecao#">
	delete from Andamento_Temp
	where  Andt_AnoExerc='#year(dtlimit)#' and Andt_Mes = #month(dtlimit)#
</cfquery>	

<!--- rotina 1--->
<!--- COMPOR O PRCI COM OS 14-NR, PENDENTES E TRATAMENTOS DO MES ANTERIOR--->
<!--- TODAS UNIDADES --->
<cfquery name="rsRot1" datasource="#dsn_inspecao#">
	SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Und_CodDiretoria, pos_dtultatu, 
	andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Situacao_Resp, Pos_Sit_Resp_Antes
	FROM SLNCPRCIDCGIMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
	WHERE Pos_Situacao_Resp In (14,2,4,5,8,20,15,16,18,19,23) and Pos_DtPosic < #dtini# 
	ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
</cfquery>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,45)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfoutput query="rsRot1">
		<cfset AndtDPosic = CreateDate(year(rsRot1.Pos_DtPosic),month(rsRot1.Pos_DtPosic),day(rsRot1.Pos_DtPosic))>
		<cfset AndtHPosic = rsRot1.andHrPosic>
		<cfset AndtCodSE = rsRot1.Und_CodDiretoria>
		<cfset auxsta = rsRot1.Pos_Situacao_Resp>			
		<cfif auxsta eq 14 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
			<cfset AndtPrazo = 'DP'>
		<cfelse>
			<cfset AndtPrazo = 'FP'>
		</cfif>		
		<!--- garantir a inclusão para PRCI --->
		<cfquery datasource="#dsn_inspecao#">
			insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto)  
			values ('#year(dtlimit)#', #month(dtlimit)#, '#rsRot1.Pos_Inspecao#', '#rsRot1.Pos_Unidade#', #rsRot1.Pos_NumGrupo#, #rsRot1.Pos_NumItem#, #AndtDPosic#, '#AndtHPosic#', #auxsta#, #rsRot1.Und_TipoUnidade#, 0, 0, '#rsRot1.pos_username#', CONVERT(char, GETDATE(), 120), '#rsRot1.Pos_Area#', '#rsRot1.Pos_NomeArea#', '#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1, 0, #rsRot1.Pos_PontuacaoPonto#, '#rsRot1.Pos_ClassificacaoPonto#')
		</cfquery>
</cfoutput> 
<!--- fim rotina 1  --->
<!--- rotina 2 --->
<!--- COMPOR O PRCI COM OS 14-NR, PENDENTES E TRATAMENTOS DENTRO DO MES E COMO MIGRARAM AO MÊS CORRENTE --->
<!--- TODAS UNIDADES --->
<cfquery name="rsRot2" datasource="#dsn_inspecao#">
	SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Und_CodDiretoria, pos_dtultatu, 
	andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Situacao_Resp, Pos_Sit_Resp_Antes
	FROM SLNCPRCIDCGIMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
	WHERE Pos_Situacao_Resp In (14,2,4,5,8,20,15,16,18,19,23) and Pos_DtPosic >= #dtini#
	ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
</cfquery>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,45)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfoutput query="rsRot2">
	<cfset AndtDPosica = CreateDate(year(rsRot2.Pos_DtPosic),month(rsRot2.Pos_DtPosic),day(rsRot2.Pos_DtPosic))>
	<cfset AndtHPosica = rsRot2.andHrPosic>
	<cfset AndtCodSE = rsRot2.Und_CodDiretoria>
	<cfset auxsta = rsRot2.Pos_Situacao_Resp>			
	<cfif auxsta eq 14 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
		<cfset AndtPrazo = 'DP'>
	<cfelse>
		<cfset AndtPrazo = 'FP'>
	</cfif>		
		
	<!--- garantir a inclusão para PRCI --->
	<cfquery datasource="#dsn_inspecao#">
		insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto)  values ('#year(dtlimit)#', #month(dtlimit)#, '#rsRot2.Pos_Inspecao#', '#rsRot2.Pos_Unidade#', #rsRot2.Pos_NumGrupo#, #rsRot2.Pos_NumItem#, #AndtDPosica#, '#AndtHPosica#', #auxsta#, #rsRot2.Und_TipoUnidade#, 0, 0, '#rsRot2.pos_username#', CONVERT(char, GETDATE(), 120), '#rsRot2.Pos_Area#', '#rsRot2.Pos_NomeArea#', '#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1, 0, #rsRot2.Pos_PontuacaoPonto#, '#rsRot2.Pos_ClassificacaoPonto#')
	</cfquery>
	<cfif auxsta neq 14 and day(#AndtDPosica#) gt 1>
		<!--- FAZER BUSCAS POR outras possíveis ocorrências(PEND/TRAT) na andamento dentro do MêS/migração do mês anterior para PRCI --->
		<!--- Apenas nos maiores que o dia primeiro do mês trabalhado --->
		<cfset salvarSN = 'S'>

		<cfquery name="rsPENDTRAT" datasource="#dsn_inspecao#">
			SELECT And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area
			FROM Andamento 
			WHERE And_Unidade = '#rsRot2.Pos_Unidade#' AND 
			And_NumInspecao = '#rsRot2.Pos_Inspecao#' AND 
			And_NumGrupo = #rsRot2.Pos_NumGrupo# AND 
			And_NumItem = #rsRot2.Pos_NumItem# AND 
			And_DtPosic <= #AndtDPosica# and And_HrPosic <> '#AndtHPosica#'
			order by And_DtPosic desc, And_HrPosic desc
		</cfquery>
		
		<cfloop query="rsPENDTRAT"> 
			<cfset auxsta = rsPENDTRAT.And_Situacao_Resp>
			<cfset AndtDPosicb = CreateDate(year(rsPENDTRAT.And_DtPosic),month(rsPENDTRAT.And_DtPosic),day(rsPENDTRAT.And_DtPosic))>
			<cfset AndtHPosicb = rsPENDTRAT.And_HrPosic>
			<cfif auxsta eq 2 or auxsta eq 4 or auxsta eq 5 or auxsta eq 8 or auxsta eq 20 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
				<cfset auxsta = rsPENDTRAT.And_Situacao_Resp>			
				<cfif auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
					<cfset AndtPrazo = 'DP'>
				<cfelse>
					<cfset AndtPrazo = 'FP'>
				</cfif>

				<cfquery name="rsExiste" datasource="#dsn_inspecao#">
					select Andt_Insp 
					from Andamento_Temp 
					where Andt_AnoExerc = '#year(dtlimit)#' and
					Andt_Mes = #month(dtlimit)# and
					Andt_Insp = '#rsRot2.Pos_Inspecao#' and
					Andt_Unid = '#rsRot2.Pos_Unidade#' and
					Andt_Grp = #rsRot2.Pos_NumGrupo# and 
					Andt_Item = #rsRot2.Pos_NumItem# and 
					Andt_DPosic = #AndtDPosicb# and
					Andt_HPosic = '#AndtHPosicb#' and
					Andt_Resp = #auxsta# and
					Andt_TipoRel = 1
				</cfquery>	
						
				<cfif (rsExiste.recordcount lte 0) and (salvarSN eq 'S')>
					<cfquery datasource="#dsn_inspecao#">
						insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto) 
						values ('#year(dtlimit)#', #month(dtlimit)#, '#rsRot2.Pos_Inspecao#', '#rsRot2.Pos_Unidade#', #rsRot2.Pos_NumGrupo#, #rsRot2.Pos_NumItem#, #AndtDPosicb#, '#AndtHPosicb#', #auxsta#, #rsRot2.Und_TipoUnidade#, 0, 0, '#rsPENDTRAT.And_username#', CONVERT(char, GETDATE(), 120), '#rsPENDTRAT.And_Area#', '#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1, 0, #rsRot2.Pos_PontuacaoPonto#, '#rsRot2.Pos_ClassificacaoPonto#')
					</cfquery> 
				</cfif>
			</cfif>						
			<cfif dateformat(#AndtDPosicb#,"YYYYMMDD") lte dateformat(#dtini#,"YYYYMMDD")> 
				<cfset salvarSN = 'N'>
			</cfif>
		</cfloop> 
	</cfif>
</cfoutput> 
<!--- fim rotina 2  --->
<!--- ROTINA 3 --->
<!--- OBTER NA ANDAMENTO POSSÍVEIS STATUS (14-NR, PEND OU TRAT) PARA COMPOR PRCI  DOS PONTOS TRAZIDOS DA PARECERUNIDADE (RESPOSTAS, SO, CS, PI, OC, RV AP, RC, NC, BX, EA, EC e TP --->
<cfquery name="rsRot3" datasource="#dsn_inspecao#">
	SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Und_CodDiretoria, pos_dtultatu, andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Situacao_Resp, Pos_Sit_Resp_Antes
	FROM SLNCPRCIDCGIMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
	WHERE Pos_Situacao_Resp In (3,1,6,7,17,22) AND Pos_DtPosic between #dtini# and #dtfim#
	ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
</cfquery>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,45)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfoutput query="rsRot3">
	<cfset AndtDPosic = CreateDate(year(rsRot3.Pos_DtPosic),month(rsRot3.Pos_DtPosic),day(rsRot3.Pos_DtPosic))>
	<cfset AndtHPosic = rsRot3.andHrPosic>
	<cfif day(AndtDPosic) gt 1>
		<cfquery name="rsNRPENDTRAT" datasource="#dsn_inspecao#">
			SELECT And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area
			FROM Andamento
			WHERE And_Unidade = '#rsRot3.Pos_Unidade#' AND 
			And_NumInspecao = '#rsRot3.Pos_Inspecao#' AND 
			And_NumGrupo = #rsRot3.Pos_NumGrupo# AND 
			And_NumItem = #rsRot3.Pos_NumItem# AND 
			And_DtPosic <= #AndtDPosic# AND 
			And_HrPosic <> '#AndtHPosic#'
			order by And_DtPosic desc, And_HrPosic desc
		</cfquery>					
		<cfset auxantes = 0>
		<cfif rsRot3.Pos_Sit_Resp_Antes gt 0>
			<cfset auxantes = rsRot3.Pos_Situacao_Resp>
		</cfif>
		<cfset salvarSN = 'S'>
		
		<cfloop query="rsNRPENDTRAT">  
			<cfset auxsta = rsNRPENDTRAT.And_Situacao_Resp>	
			<cfset AndtDPosicc = CreateDate(year(rsNRPENDTRAT.And_DtPosic),month(rsNRPENDTRAT.And_DtPosic),day(rsNRPENDTRAT.And_DtPosic))>
			<cfset AndtHPosicc = rsNRPENDTRAT.And_HrPosic>
			<cfif auxsta eq 14 or auxsta eq 2 or auxsta eq 4 or auxsta eq 5 or auxsta eq 8 or auxsta eq 20 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>					
				<cfset AndtCodSE = rsRot3.Und_CodDiretoria>

				<cfif auxsta eq 14 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
					<cfset AndtPrazo = 'DP'>
				<cfelse>
					<cfset AndtPrazo = 'FP'>
				</cfif>

				<cfquery name="rsExisteb" datasource="#dsn_inspecao#">
					select Andt_Insp 
					from Andamento_Temp 
					where Andt_AnoExerc = '#year(dtlimit)#' and
					Andt_Mes = #month(dtlimit)# and
					Andt_Insp = '#rsRot3.Pos_Inspecao#' and
					Andt_Unid = '#rsRot3.Pos_Unidade#' and
					Andt_Grp = #rsRot3.Pos_NumGrupo# and 
					Andt_Item = #rsRot3.Pos_NumItem# and 
					Andt_DPosic = #AndtDPosicc# and
					Andt_HPosic = '#AndtHPosicc#' and
					Andt_Resp = #auxsta# and
					Andt_TipoRel = 1
				</cfquery>	
				<cfif auxsta eq 14 and dateformat(AndtDPosicc,"YYYYMMDD") lt dateformat(dt14limitprci_slnc,"YYYYMMDD")>
					<cfset salvarSN = 'N'>
				</cfif>
				<cfif (rsExisteb.recordcount lte 0) and (salvarSN eq 'S')>
					<cfquery datasource="#dsn_inspecao#">
						insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto) values ('#year(dtlimit)#', #month(dtlimit)#, '#rsRot3.Pos_Inspecao#', '#rsRot3.Pos_Unidade#', #rsRot3.Pos_NumGrupo#, #rsRot3.Pos_NumItem#, #AndtDPosicc#, '#AndtHPosicc#', #auxsta#, #rsRot3.Und_TipoUnidade#, 0, 0, '#rsNRPENDTRAT.And_username#', CONVERT(char, GETDATE(), 120), '#rsNRPENDTRAT.And_Area#', '#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1, 0, #rsRot3.Pos_PontuacaoPonto#, '#rsRot3.Pos_ClassificacaoPonto#')
					</cfquery> 
				</cfif>
				<cfif dateformat(#AndtDPosicc#,"YYYYMMDD") lte dateformat(#dtini#,"YYYYMMDD")>
					<cfset salvarSN = 'N'>				
				</cfif>	
			</cfif>	
		</cfloop>
	</cfif>
</cfoutput>  
<!--- FIM ROTINA 3 ---> 
<!--- ROTINA 4 --->
<!--- VALIDAR PONTOS NA TABELA: Andamento_Temp  --->
<!--- GRUPOS E ITENS NÃO PERMITIDOS  --->
<cfquery name="rsGRIT" datasource="#dsn_inspecao#">
	SELECT Andt_AnoExerc, Andt_TipoRel, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_Resp, Andt_Area
	FROM Andamento_Temp 
	WHERE Andt_AnoExerc ='#year(dtlimit)#' AND Andt_TipoRel=1 AND Andt_Mes = #month(dtlimit)#
</cfquery>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,25)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfoutput query="rsGRIT">
	<cfset auxgrp = rsGRIT.Andt_Grp>
	<cfset auxitm = rsGRIT.Andt_Item>
	<cfif (auxgrp is 9 and auxitm is 9) or (auxgrp is 29 and auxitm is 4) or (auxgrp is 68 and auxitm is 3) or (auxgrp is 96 and auxitm is 3) or (auxgrp is 122 and auxitm is 3) or (auxgrp is 209 and auxitm is 3) or (auxgrp is 241 and auxitm is 3) or (auxgrp is 308 and auxitm is 3) or (auxgrp is 278 and auxitm is 2) or (auxgrp is 337 and auxitm is 2)>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Andamento_Temp SET Andt_Prazo = 'EX'
			WHERE Andt_Unid='#rsGRIT.Andt_Unid#' AND 
			Andt_Insp='#rsGRIT.Andt_Insp#' AND 
			Andt_Grp=#rsGRIT.Andt_Grp# AND 
			Andt_Item=#rsGRIT.Andt_Item#
		</cfquery>	
	</cfif>
</cfoutput>			

<!--- POS_NOMEAREA NAO PERMITIDOS  --->
 <cfquery name="AndtArea" datasource="#dsn_inspecao#">
	SELECT Andt_AnoExerc, Andt_TipoRel, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_Resp, Andt_Area, Andt_PosClassificacaoPonto, Andt_Unid
	FROM Andamento_Temp 
	WHERE Andt_AnoExerc ='#year(dtlimit)#' AND Andt_TipoRel=2 AND Andt_Mes = #month(dtlimit)# 
</cfquery>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,25)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfloop query="AndtArea">
	<cfquery name="rsNegar" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla 
		FROM Areas 
		WHERE Ars_Codigo = '#AndtArea.Andt_Area#' and 
		(Ars_Sigla Like '%CCOP/SCIA%' Or 
		Ars_Sigla Like '%CCOP/SCOI%' Or 
		Ars_Sigla Like '%GCOP/CCOP%' Or
		Ars_Sigla Like '%GSOP/CSEC%' Or 
		Ars_Sigla Like '%CORR%' Or 
		Ars_Sigla Like '%GCOP/SGCIN%' Or 
		Ars_Sigla Like '%GAAV/SGSEC%' OR 
		Ars_Sigla Like '%/SCORG%')
	</cfquery>
	<cfset AndtPosClassificacaoPonto = trim(ucase(AndtArea.Andt_PosClassificacaoPonto))>
	<cfif rsNegar.recordcount gt 0 or (AndtPosClassificacaoPonto eq 'LEVE' and Andt_Unid neq 12)> 
		<cfquery datasource="#dsn_inspecao#">
		   UPDATE Andamento_Temp SET Andt_Prazo = 'EX'
		   WHERE Andt_Unid='#AndtArea.Andt_Unid#' AND 
		   Andt_Insp='#AndtArea.Andt_Insp#' AND 
		   Andt_Grp=#AndtArea.Andt_Grp# AND 
		   Andt_Item=#AndtArea.Andt_Item#
		</cfquery>	
	</cfif>			 	
</cfloop>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,45)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfquery datasource="#dsn_inspecao#">
   delete from Andamento_Temp where Andt_Prazo = 'EX'
</cfquery>  
<!--- FIM ROTINA 4 ---> 

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,45)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<!--- ROTINA 5 --->
<cfquery dbtype="query" name="rsRegMeta">
	SELECT Met_Codigo, Met_SE_STO 
	FROM rsMetas
	order by Met_Codigo
</cfquery>
<cfoutput query="rsRegMeta">
	<cfset se = rsRegMeta.Met_Codigo>
	<!--- <cfset gil = gil> --->
	<cfquery name="rsPRCIBase" datasource="#dsn_inspecao#">
		SELECT Andt_Unid as UNID, Andt_Insp as INSP, Andt_Grp as Grupo, Andt_Item as Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_Mes, Andt_Prazo
		FROM Andamento_Temp 
		where (Andt_CodSE = '#se#' and Andt_TipoRel = 1 and Andt_AnoExerc = '#anoexerc#' and Andt_Mes <= #month(dtlimit)#)
		order by Andt_Mes
	</cfquery>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,30)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfset totmesDP = 0>
<cfset TOTMESDPFP = 0>
	<!--- contar unidade DP e FP --->
	<cfquery dbtype="query" name="rstotmesDP">
		SELECT Andt_Prazo 
		FROM  rsPRCIBase
		where Andt_Prazo = 'DP' and Andt_Mes = #month(dtlimit)#
	</cfquery>
	<cfset totmesDP = rstotmesDP.recordcount>

	<cfquery dbtype="query" name="rsTOTMESDPFP">
		SELECT Andt_Prazo 
		FROM rsPRCIBase  
		where Andt_Mes = #month(dtlimit)#
	</cfquery>		
	<cfset TOTMESDPFP = rsTOTMESDPFP.recordcount>

		<!--- Quant. FP --->
    <cfset totmesFP = (TOTMESDPFP - totmesDP)>

	<cfset PercDPmes = '100.0'>
	<cfif TOTMESDPFP gt 0>
		<cfset PercDPmes = trim(NumberFormat((totmesDP/TOTMESDPFP) * 100,999.0))>
	</cfif>

<!---    ==============================  --->
	<!--- Quant. DP --->
	<cfquery dbtype="query" name="rstotgerDP">
		SELECT Andt_Prazo 
		FROM  rsPRCIBase
		where Andt_Prazo = 'DP'
	</cfquery>		
	<cfset totgerDP = rstotgerDP.recordcount>

	<cfquery dbtype="query" name="rsTOTGER">
		SELECT Andt_Prazo 
		FROM rsPRCIBase 
	</cfquery>		
	<cfset TOTGER = rsTOTGER.recordcount>

	<cfset metprciacumperiodo = trim(NumberFormat((totgerDP/TOTGER)* 100,999.0))> 

	<cfquery datasource="#dsn_inspecao#">
		UPDATE Metas SET Met_PRCI_Acum = '#PercDPmes#',Met_PRCI_AcumPeriodo = '#metprciacumperiodo#'
		WHERE Met_Codigo='#se#' and Met_Ano = #anoexerc# and Met_Mes = #month(dtlimit)#
	</cfquery>  
<!---
se: #se#  DP:#totgerDP#  DP+FP:#TOTGER#   metprciacumperiodo:#metprciacumperiodo#    (PercDPmes = Met_PRCI_Acum): #PercDPmes# totmesDP: #totmesDP# totmesFP: #totmesFP# <br>
--->
</cfoutput>	
<!--- FIM ROTINA 5 ---> 
<!--- ================  FINAL PRCI ======================= --->
<!--- ================  INICIO SLNC ====================== --->
<cfquery name="rsSLNC" datasource="#dsn_inspecao#">
	SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, pos_dtultatu, andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
	FROM SLNCPRCIDCGIMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
	WHERE (((Pos_Situacao_Resp) In (2,4,5,8,15,16,19,23)) AND ((Und_TipoUnidade)<>12 And (Und_TipoUnidade)<>16)) 
	ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
</cfquery>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,50)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfoutput query="rsSLNC">
	<cfset SalvarSN = 'S'>
	<cfquery name="rs14" datasource="#dsn_inspecao#">
		SELECT And_DtPosic, And_HrPosic
		FROM Andamento
		WHERE And_Unidade = '#rsSLNC.Pos_Unidade#' AND 
		And_NumInspecao = '#rsSLNC.Pos_Inspecao#' AND 
		And_NumGrupo = #rsSLNC.Pos_NumGrupo# AND 
		And_NumItem = #rsSLNC.Pos_NumItem# AND 
		And_Situacao_Resp = 14 and And_DtPosic >= #dt14limitprci_slnc#
	</cfquery>
		<cfif rs14.recordcount gt 0> 
		<cfset SalvarSN = 'N'>
	</cfif> 
	<cfif SalvarSN is 'S'>
		<cfset AndtDPosic = CreateDate(year(rsSLNC.Pos_DtPosic),month(rsSLNC.Pos_DtPosic),day(rsSLNC.Pos_DtPosic))>
		<cfset AndtHPosic = rsSLNC.andHrPosic>
		<cfset auxsta = rsSLNC.Pos_Situacao_Resp>
		<cfquery name="rsExiste" datasource="#dsn_inspecao#">
				select Andt_Insp 
				from Andamento_Temp 
				where Andt_AnoExerc = '#year(dtlimit)#' and
				Andt_Mes = #month(dtlimit)# and
				Andt_Insp = '#rsSLNC.Pos_Inspecao#' and
				Andt_Unid = '#rsSLNC.Pos_Unidade#' and
				Andt_Grp = #rsSLNC.Pos_NumGrupo# and 
				Andt_Item = #rsSLNC.Pos_NumItem# and 
				Andt_DPosic = #AndtDPosic# and
				Andt_HPosic = '#AndtHPosic#' and
				Andt_Resp = #auxsta# and
				Andt_TipoRel = 2
		</cfquery>			
		<cfif rsExiste.recordcount lte 0>
			<!--- ponto pode ser salvo para compor SLNC --->
			<cfset PosDtPosic = CreateDate(year(rsSLNC.Pos_DtPosic),month(rsSLNC.Pos_DtPosic),day(rsSLNC.Pos_DtPosic))>
			<cfset AndtHPosic = TimeFormat(now(),"hh:mm:ssss")> 
			<cfset AndtCodSE = left(rsSLNC.Pos_Unidade,2)>
			<cfset auxsta = rsSLNC.Pos_Situacao_Resp>
			<cfset auxantes = 0>
			<cfif rsSLNC.Pos_Sit_Resp_Antes gt 0>
				<cfset auxantes = rsSLNC.Pos_Situacao_Resp>
			</cfif>							
			<cfquery datasource="#dsn_inspecao#">
			insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto) 
			values ('#year(dtlimit)#', #month(dtlimit)#, '#rsSLNC.Pos_Inspecao#', '#rsSLNC.Pos_Unidade#', #rsSLNC.Pos_NumGrupo#, #rsSLNC.Pos_NumItem#, #PosDtPosic#, '#AndtHPosic#', #auxsta#, #rsSLNC.Und_TipoUnidade#, 0, 0, '#rsSLNC.pos_username#', CONVERT(char, GETDATE(), 120), '#rsSLNC.Pos_Area#', '#trim(rsSLNC.Pos_NomeArea)#', '#AndtCodSE#', #dtfim#, 'NN', 2, '#auxantes#', #rsSLNC.Pos_PontuacaoPonto#, '#rsSLNC.Pos_ClassificacaoPonto#')
			</cfquery>	
		</cfif>					
	</cfif>
</cfoutput>
<!--- COMPOR O SLNC COM OS solucionados do Mês --->
<cfquery name="rs3SO" datasource="#dsn_inspecao#">
	SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, pos_dtultatu, andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes,Und_CodDiretoria
	FROM SLNCPRCIDCGIMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
	WHERE Pos_Situacao_Resp = 3
	ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
</cfquery>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,25)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfoutput query="rs3SO">
	<!--- <cfset auxsta_antes = rs3SO.Pos_Sit_Resp_Antes> --->
	<!---  <cfif auxsta_antes is 0 or auxsta_antes is ''> --->
	<cfset PosDtPosic = CreateDate(year(rs3SO.Pos_DtPosic),month(rs3SO.Pos_DtPosic),day(rs3SO.Pos_DtPosic))>
	<cfset AndtHPosic = rs3SO.andHrPosic>
	<cfset AndtCodSE = left(rs3SO.Pos_Unidade,2)>
	<cfset auxsta = rs3SO.Pos_Situacao_Resp>
		
	<cfset auxsta_antes = 'F'>
	<cfquery datasource="#dsn_inspecao#" name="rsunid">
		SELECT Und_Codigo FROM Unidades WHERE Und_Codigo = '#rs3SO.Pos_Area#'
	</cfquery>
	<cfif rsunid.recordcount gt 0>
		<cfset auxsta_antes = 1>
	</cfif>
	<cfif auxsta_antes is 'F'>
		<cfquery datasource="#dsn_inspecao#" name="rsreop">
			SELECT Rep_Codigo FROM Reops WHERE Rep_Codigo = '#rs3SO.Pos_Area#'
		</cfquery>							
	
		<cfif rsreop.recordcount gt 0>
			<cfset auxsta_antes = 7>
		</cfif>
	</cfif>
	<cfif auxsta_antes is 'F'>
		<cfquery datasource="#dsn_inspecao#" name="rsarea">
			SELECT Ars_Codigo FROM Areas WHERE Ars_Codigo = '#rs3SO.Pos_Area#'
		</cfquery>							
	
		<cfif rsarea.recordcount gt 0>
			<cfset auxsta_antes = 6>
		</cfif>
	</cfif>
	<cfif auxsta_antes is 'F'>
		<cfquery datasource="#dsn_inspecao#" name="rsse">
			SELECT Dir_Sto FROM Diretoria WHERE Dir_Sto = '#rs3SO.Pos_Area#'
		</cfquery>								
	
		<cfif rsse.recordcount gt 0>
			<cfset auxsta_antes = 22>
		</cfif>
	</cfif>		
	<cfquery datasource="#dsn_inspecao#">
		insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor,Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt,Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto) values ('#year(dtlimit)#', #month(dtlimit)#, '#rs3SO.Pos_Inspecao#', '#rs3SO.Pos_Unidade#',#rs3SO.Pos_NumGrupo#, #rs3SO.Pos_NumItem#, #PosDtPosic#, '#AndtHPosic#', #auxsta#, #rs3SO.Und_TipoUnidade#, 0, 0, '#rs3SO.pos_username#', CONVERT(char, GETDATE(), 120), '#rs3SO.Pos_Area#', '#trim(rs3SO.Pos_NomeArea)#', '#AndtCodSE#', #dtfim#, 'NN', 2, '#auxsta_antes#', #rs3SO.Pos_PontuacaoPonto#, '#rs3SO.Pos_ClassificacaoPonto#')
	</cfquery>	
	<!---  ======================================  --->
	<cfset AndtDPosic = CreateDate(year(PosDtPosic),month(PosDtPosic),day(PosDtPosic))>
	<cfset AndtHPosic = AndtHPosic>
	<cfif day(AndtDPosic) gt 1>
		<cfquery name="rsNRPENDTRAT" datasource="#dsn_inspecao#">
			SELECT And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area
			FROM Andamento
			WHERE And_Unidade = '#rs3SO.Pos_Unidade#' AND 
			And_NumInspecao = '#rs3SO.Pos_Inspecao#' AND 
			And_NumGrupo = #rs3SO.Pos_NumGrupo# AND 
			And_NumItem = #rs3SO.Pos_NumItem# AND 
			And_DtPosic <= #AndtDPosic# AND 
			And_HrPosic <> '#AndtHPosic#'
			order by And_DtPosic desc, And_HrPosic desc
		</cfquery>					
		<cfset auxantes = 0>
		<cfif rs3SO.Pos_Sit_Resp_Antes gt 0>
			<cfset auxantes = rs3SO.Pos_Situacao_Resp>
		</cfif>
		<cfset salvarSN = 'S'>
		
		<cfloop query="rsNRPENDTRAT">  
			<cfset auxstab = rsNRPENDTRAT.And_Situacao_Resp>	
			<cfset AndtDPosicc = CreateDate(year(rsNRPENDTRAT.And_DtPosic),month(rsNRPENDTRAT.And_DtPosic),day(rsNRPENDTRAT.And_DtPosic))>
			<cfset AndtHPosicc = rsNRPENDTRAT.And_HrPosic>
			<cfif auxstab eq 14 or auxstab eq 2 or auxstab eq 4 or auxstab eq 5 or auxstab eq 8 or auxstab eq 20 or auxstab eq 15 or auxstab eq 16 or auxstab eq 18 or auxstab eq 19 or auxstab eq 23>					
				<cfset AndtCodSE = rs3SO.Und_CodDiretoria>

				<cfquery name="rsExisteb" datasource="#dsn_inspecao#">
					select Andt_Insp 
					from Andamento_Temp 
					where Andt_AnoExerc = '#year(dtlimit)#' and
					Andt_Mes = #month(dtlimit)# and
					Andt_Insp = '#rs3SO.Pos_Inspecao#' and
					Andt_Unid = '#rs3SO.Pos_Unidade#' and
					Andt_Grp = #rs3SO.Pos_NumGrupo# and 
					Andt_Item = #rs3SO.Pos_NumItem# and 
					Andt_DPosic = #AndtDPosicc# and
					Andt_HPosic = '#AndtHPosicc#' and
					Andt_Resp <> 3 and
					Andt_TipoRel = 1
				</cfquery>	
				<cfif auxstab eq 14 and dateformat(AndtDPosicc,"YYYYMMDD") lt dateformat(dt14limitprci_slnc,"YYYYMMDD")>
					<cfset salvarSN = 'N'>
				</cfif>
				<cfif (rsExisteb.recordcount lte 0) and (salvarSN eq 'S')>
					<cfquery datasource="#dsn_inspecao#">
						insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor,Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt,Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto) 
						values ('#year(dtlimit)#', #month(dtlimit)#, '#rs3SO.Pos_Inspecao#', '#rs3SO.Pos_Unidade#',#rs3SO.Pos_NumGrupo#, #rs3SO.Pos_NumItem#, #AndtDPosicc#, '#AndtHPosicc#', #auxstab#, #rs3SO.Und_TipoUnidade#, 0, 0, '#rsNRPENDTRAT.And_username#', CONVERT(char, GETDATE(), 120), '#rsNRPENDTRAT.And_Area#', '#AndtCodSE#', '#AndtCodSE#', #dtfim#, 'NN', 2, '3', #rs3SO.Pos_PontuacaoPonto#, '#rs3SO.Pos_ClassificacaoPonto#')									
					</cfquery> 
					<cfset salvarSN = 'N'>
				</cfif>
			</cfif>	
		</cfloop>
	</cfif>
</cfoutput>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,45)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<!--- VALIDAR PONTOS NA TABELA: Andamento_Temp  --->
<!--- GRUPOS E ITENS NAO PERMITIDOS  --->
<cfquery name="rsGRIT" datasource="#dsn_inspecao#">
SELECT Andt_AnoExerc, Andt_TipoRel, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_Resp, Andt_Area
FROM Andamento_Temp 
WHERE Andt_AnoExerc ='#year(dtlimit)#' AND Andt_TipoRel=2 AND Andt_Mes = #month(dtlimit)#
</cfquery>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,10)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfloop query="rsGRIT">
	<cfset auxgrp = rsGRIT.Andt_Grp>
	<cfset auxitm = rsGRIT.Andt_Item>
	<cfif (auxgrp is 9 and auxitm is 9) or (auxgrp is 29 and auxitm is 4) or (auxgrp is 68 and auxitm is 3) or (auxgrp is 96 and auxitm is 3) or (auxgrp is 122 and auxitm is 3) or (auxgrp is 209 and auxitm is 3) or (auxgrp is 241 and auxitm is 3) or (auxgrp is 308 and auxitm is 3) or (auxgrp is 278 and auxitm is 2) or (auxgrp is 337 and auxitm is 2)>
		<cfquery datasource="#dsn_inspecao#">
		   UPDATE Andamento_Temp SET Andt_Prazo = 'EX'
		   WHERE Andt_Unid='#rsGRIT.Andt_Unid#' AND 
		   Andt_Insp='#rsGRIT.Andt_Insp#' AND 
		   Andt_Grp=#rsGRIT.Andt_Grp# AND 
		   Andt_Item=#rsGRIT.Andt_Item#
		</cfquery>		
	</cfif>
</cfloop>			
<!--- FIM ROTINA  ---> 
		
<!--- ROTINA  --->
<!--- POS_NOMEAREA NAO PERMITIDOS  --->
 <cfquery name="AndtArea" datasource="#dsn_inspecao#">
	SELECT Andt_AnoExerc, Andt_TipoRel, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_Resp, Andt_Area, Andt_PosClassificacaoPonto, Andt_Unid
	FROM Andamento_Temp 
	WHERE Andt_AnoExerc ='#year(dtlimit)#' AND Andt_TipoRel=2 AND Andt_Mes = #month(dtlimit)# 
</cfquery>

<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,10)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfloop query="AndtArea">
	<cfquery name="rsNegar" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla 
		FROM Areas 
		WHERE Ars_Codigo = '#AndtArea.Andt_Area#' and 
		(Ars_Sigla Like '%CCOP/SCIA%' Or 
		Ars_Sigla Like '%CCOP/SCOI%' Or 
		Ars_Sigla Like '%GCOP/CCOP%' Or
		Ars_Sigla Like '%GSOP/CSEC%' Or 
		Ars_Sigla Like '%CORR%' Or 
		Ars_Sigla Like '%GCOP/SGCIN%' Or 
		Ars_Sigla Like '%GAAV/SGSEC%' OR 
		Ars_Sigla Like '%/SCORG%')
	</cfquery>
	<cfset AndtPosClassificacaoPonto = trim(ucase(AndtArea.Andt_PosClassificacaoPonto))>
	<cfif rsNegar.recordcount gt 0 or (AndtPosClassificacaoPonto eq 'LEVE' and Andt_Unid neq 12)> 
		<cfquery datasource="#dsn_inspecao#">
		   UPDATE Andamento_Temp SET Andt_Prazo = 'EX'
		   WHERE Andt_Unid='#AndtArea.Andt_Unid#' AND 
		   Andt_Insp='#AndtArea.Andt_Insp#' AND 
		   Andt_Grp=#AndtArea.Andt_Grp# AND 
		   Andt_Item=#AndtArea.Andt_Item#
		</cfquery>	
	</cfif>			 	
</cfloop>
<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,45)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<!--- FIM ROTINA  ---> 
<cfquery datasource="#dsn_inspecao#">
   delete from Andamento_Temp where Andt_Prazo = 'EX'
</cfquery>  

<!---  gerar o met_slnc_acum e Met_slnc_AcumPeriodo --->
<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,45)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfquery name="rsAno" datasource="#dsn_inspecao#">
	SELECT Andt_CodSE,Andt_Mes,Andt_Resp
	FROM Andamento_Temp
	WHERE Andt_AnoExerc = '#anoexerc#' AND Andt_Mes <= #month(dtlimit)# AND Andt_TipoRel = 2
	order by Andt_CodSE 
</cfquery> 

<!---  gerar o met_slnc_acum e Met_slnc_AcumPeriodo --->
<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,45)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>	
<cfquery dbtype="query" name="rsRegMeta">
	SELECT Met_Codigo, Met_SE_STO 
	FROM rsMetas
	order by Met_Codigo 
</cfquery>	
<cfoutput query="rsRegMeta">
	<cfset totmessegeral = 0>	
	<cfset totmessesol = 0>	
	<cfset totmessependtrat = 0>	
	<cfset slnc_acummes = 0>	
	<cfset dgci_acummes = 0>	
	<cfset totanosegeral = 0>	
	<cfset totanosesol = 0>	
	<cfset totanosependtrat = 0>			
	<cfset slnc_acperiodo = 0>	
	<cfset dgci_acperiodo = 0>
	<cfset MetasResult = 0>
	<!--- Obter PRCI mes corrente --->
	<cfquery name="rsprciacum" datasource="#dsn_inspecao#">
		SELECT Met_PRCI_Acum, Met_PRCI_AcumPeriodo
		FROM Metas
		WHERE Met_Codigo='#rsRegMeta.Met_Codigo#' AND Met_Ano = #anoexerc# AND Met_Mes = #month(dtlimit)#
	</cfquery>		
	<!--- quant. (3-SOL) no mês por SE --->
	<cfquery dbtype="query" name="rstotmessesol">
		SELECT Andt_Resp 
		FROM  rsAno
		where Andt_Resp = 3 and Andt_CodSE = '#rsRegMeta.Met_Codigo#' and Andt_Mes = #month(dtlimit)#
	</cfquery>
	<cfset totmessesol = rstotmessesol.recordcount>
	<!--- quant. (Pendentes + Tratamentos) no mês por SE --->
	<cfquery dbtype="query" name="rstotmessependtrat">
		SELECT Andt_Resp 
		FROM  rsAno
		where Andt_Resp <> 3 and Andt_CodSE = '#rsRegMeta.Met_Codigo#' and Andt_Mes = #month(dtlimit)#
	</cfquery>
	<cfset totmessependtrat = rstotmessependtrat.recordcount>
	<cfset totmessegeral = totmessesol + totmessependtrat>

	<!--- slncacum ---> 
	<cfset slnc_acummes = '100.0'>
	<cfif totmessegeral gt 0>
		<cfset slnc_acummes = trim(NumberFormat(((totmessesol/totmessegeral) * 100),999.0))>
	</cfif>

	<cfset dgci_acummes = trim(numberFormat((slnc_acummes * 0.45) + (rsprciacum.Met_PRCI_Acum * 0.55),999.0))>  

	<!--- slncacumperiodo --->
	<!--- quant. (3-SOL) no ano por SE --->
	<cfquery dbtype="query" name="rstotanosesol">
		SELECT Andt_Resp 
		FROM  rsAno
		where Andt_Resp = 3 and Andt_CodSE = '#rsRegMeta.Met_Codigo#'
	</cfquery>
	<cfset totanosesol = rstotanosesol.recordcount>

	<!--- quant. (Pendentes + Tratamentos) no ano por SE --->
	<cfquery dbtype="query" name="rstotanosependtrat">
		SELECT Andt_Resp 
		FROM  rsAno
		where Andt_Resp <> 3 and Andt_CodSE = '#rsRegMeta.Met_Codigo#'
	</cfquery>
	<cfset totanosependtrat = rstotanosependtrat.recordcount>

	<cfset totanosegeral = totanosesol + totanosependtrat>

	<cfset slnc_acperiodo = trim(NumberFormat(((totanosesol/totanosegeral) * 100),999.0))>

	<cfset auxmetprciacumper = rsprciacum.Met_PRCI_AcumPeriodo>
	<cfset dgci_acperiodo = trim(numberFormat((slnc_acperiodo * 0.45) + (auxmetprciacumper * 0.55),999.0))>  

	<cfset MetasResult = numberFormat((dgci_acperiodo / rsMetas.Met_DGCI)*100,999.0)>

	<cfquery datasource="#dsn_inspecao#">
		UPDATE Metas SET Met_SLNC_Acum= '#slnc_acummes#',Met_SLNC_AcumPeriodo='#slnc_acperiodo#',Met_DGCI_Acum='#dgci_acummes#',Met_DGCI_AcumPeriodo='#dgci_acperiodo#',Met_Resultado='#MetasResult#'
		WHERE Met_Codigo='#rsRegMeta.Met_Codigo#' and Met_Ano = '#anoexerc#' and Met_Mes = #month(dtlimit)#
	</cfquery> 
</cfoutput>
<!--- ================  FINAL SLNC ======================= --->
fim processamento!
