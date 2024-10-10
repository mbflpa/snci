<cfsetting requesttimeout="15000">
<cfset dtlimit = CreateDate(2024,#mes#,#dia#)> 
<cfset aux_mes = month(dtlimit)>
<cfset dtini = CreateDate(year(dtlimit),month(dtlimit),1)>		
<cfset aux_mes = month(dtlimit)>	
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

		<!--- atualizar a tabela SLNCPRCIDCGIANOMES com os dados da PARACERUNIDADE --->
		<!--- limpar tabela temp --->
		<cfquery datasource="#dsn_inspecao#">
			delete from SLNCPRCIDCGIANOMES where Pos_Ano=#anoexerc# and Pos_Mes=#aux_mes#
		</cfquery>	
		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,30)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>
		<!--- obter os solucionados do mês --->
		<cfquery name="rs3SO" datasource="#dsn_inspecao#">
			SELECT INP_DTConcluirRevisao, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, pos_dtultatu, pos_username, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
			FROM Inspecao INNER JOIN (ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)
			WHERE Pos_Situacao_Resp = 3 and Pos_DtPosic between #dtini# and #dtfim# 
		</cfquery>	

		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,45)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>

		<cfloop query="rs3SO">
			<cfset PosDtPosic = CreateDate(year(rs3SO.Pos_DtPosic),month(rs3SO.Pos_DtPosic),day(rs3SO.Pos_DtPosic))>
			<cfset INPDTConcluirRevisao  = CreateDate(year(rs3SO.INP_DTConcluirRevisao),month(rs3SO.INP_DTConcluirRevisao),day(rs3SO.INP_DTConcluirRevisao))>
			
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
			<cfset auxantes = trim(rs3SO.Pos_Sit_Resp_Antes)>
			<cfif auxantes is '' or auxantes is 0 or auxantes is 11 or auxantes is 14 or auxantes is 21 or auxantes is 28 or auxantes is 29>
				<cfset auxantes = 1> 
			</cfif>					
			<cfquery datasource="#dsn_inspecao#">
				insert into SLNCPRCIDCGIANOMES (Pos_Ano,Pos_Mes,Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao, pos_username, Pos_Area, Pos_NomeArea, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes,INPDTConcluirRevisao) 
				values (#anoexerc#,#aux_mes#,'#rs3SO.Pos_Unidade#', '#rs3SO.Pos_Inspecao#', #rs3SO.Pos_NumGrupo#, #rs3SO.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rs3SO.Pos_Situacao#', '#rs3SO.pos_username#', '#rs3SO.Pos_Area#', '#rs3SO.Pos_NomeArea#', #PosDtPrevSolucao#, #PosPontuacaoPonto#, '#PosClassificacaoPonto#', #auxantes#,#INPDTConcluirRevisao #)
			</cfquery>		
		</cfloop>	

		<!--- NAO RESPONDIDO PENDENTES E TRATAMENTOS --->
		<cfquery name="rsNRPENDTRAT" datasource="#dsn_inspecao#">
			SELECT INP_DTConcluirRevisao, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, pos_dtultatu, pos_username, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
			FROM Inspecao INNER JOIN (ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)
			WHERE Pos_Situacao_Resp In (14,2,4,5,8,15,16,18,19,20,23) 
		</cfquery>

		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,45)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>

		<cfloop query="rsNRPENDTRAT">
			<cfset PosDtPosic = CreateDate(year(rsNRPENDTRAT.Pos_DtPosic),month(rsNRPENDTRAT.Pos_DtPosic),day(rsNRPENDTRAT.Pos_DtPosic))>
			<cfset INPDTConcluirRevisao  = CreateDate(year(rsNRPENDTRAT.INP_DTConcluirRevisao),month(rsNRPENDTRAT.INP_DTConcluirRevisao),day(rsNRPENDTRAT.INP_DTConcluirRevisao))>
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
			<cfset auxantes = trim(rsNRPENDTRAT.Pos_Sit_Resp_Antes)>
			<cfif auxantes is '' or auxantes is 0 or auxantes is 11 or auxantes is 14 or auxantes is 21 or auxantes is 28 or auxantes is 29>
				<cfset auxantes = 1> 
			</cfif>							
			<cfquery datasource="#dsn_inspecao#">
				insert into SLNCPRCIDCGIANOMES (Pos_Ano,Pos_Mes,Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao,pos_username, Pos_Area, Pos_NomeArea, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes,INPDTConcluirRevisao) values (#anoexerc#,#aux_mes#,'#rsNRPENDTRAT.Pos_Unidade#', '#rsNRPENDTRAT.Pos_Inspecao#', #rsNRPENDTRAT.Pos_NumGrupo#, #rsNRPENDTRAT.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rsNRPENDTRAT.Pos_Situacao#', '#rsNRPENDTRAT.pos_username#', '#rsNRPENDTRAT.Pos_Area#', '#rsNRPENDTRAT.Pos_NomeArea#', #PosDtPrevSolucao#, #PosPontuacaoPonto#, '#PosClassificacaoPonto#', #auxantes#,#INPDTConcluirRevisao#)
			</cfquery>	
		</cfloop>			
		<!--- RESPOSTAS, CS, RV, AP, RC, NC, BX, EA, EC e TP (DENTRO DO MES)--->	
		<cfquery name="rsOutros" datasource="#dsn_inspecao#">
			SELECT INP_DTConcluirRevisao, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, pos_dtultatu, pos_username, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
			FROM Inspecao INNER JOIN (ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)
			WHERE Pos_Situacao_Resp In (1,6,7,17,22,9,10,21,24,25,26,27,28,29,30) and Pos_DtPosic between #dtini# and #dtfim# 
		</cfquery>

		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,45)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>

		<cfloop query="rsOutros">
			<cfset PosDtPosic = CreateDate(year(rsOutros.Pos_DtPosic),month(rsOutros.Pos_DtPosic),day(rsOutros.Pos_DtPosic))>
			<cfset INPDTConcluirRevisao  = CreateDate(year(rsOutros.INP_DTConcluirRevisao),month(rsOutros.INP_DTConcluirRevisao),day(rsOutros.INP_DTConcluirRevisao))>
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
			<cfset auxantes = trim(rsOutros.Pos_Sit_Resp_Antes)>
			<cfif auxantes is '' or auxantes is 0 or auxantes is 11 or auxantes is 14 or auxantes is 21 or auxantes is 28 or auxantes is 29>
				<cfset auxantes = 1> 
			</cfif>		
			<cfquery datasource="#dsn_inspecao#">
				insert into SLNCPRCIDCGIANOMES (Pos_Ano,Pos_Mes,Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao,pos_username, Pos_Area, Pos_NomeArea, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes,INPDTConcluirRevisao) 
				values 
				(#anoexerc#,#aux_mes#,'#rsOutros.Pos_Unidade#', '#rsOutros.Pos_Inspecao#', #rsOutros.Pos_NumGrupo#, #rsOutros.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rsOutros.Pos_Situacao#', '#rsOutros.pos_username#', '#rsOutros.Pos_Area#', '#rsOutros.Pos_NomeArea#', #PosDtPrevSolucao#, #PosPontuacaoPonto#, '#PosClassificacaoPonto#', #auxantes#,#INPDTConcluirRevisao#)
			</cfquery>		
		</cfloop>	

		<cfif month(dtini) eq '01'>
			<cfset dtinimesant = (year(dtini) - 1) & '-12-01'>
		<cfelse>
			<cfset dtinimesant = year(dtini) & '-' & (month(dtini) - 1) & '-01'>	
		</cfif>
		<cfquery name="rsFer" datasource="#dsn_inspecao#">
			SELECT Fer_Data FROM FeriadoNacional 
			where Fer_Data between '#dtinimesant#' and '#dateformat(dtfim,"YYYY-MM-DD")#'
			order by Fer_Data
		</cfquery>

		<!---  --->
		<cfset dt14limitprci_slnc  = #dtfim#>
		<cfset nCont = 1>
		<cfset dsusp = 0>
		<cfloop condition="nCont lte 30"> 
			<cfset dt14limitprci_slnc  = DateAdd("d", -1, #dt14limitprci_slnc#)>	
			<cfset vDiaSem = DayOfWeek(dt14limitprci_slnc )>
			<cfif (vDiaSem neq 1) and (vDiaSem neq 7)>
				<cfif rsFer.recordcount gt 0> 
					<cfloop query="rsFer">
						<cfif dateformat(rsFer.Fer_Data,"YYYYMMDD") eq dateformat(dt14limitprci_slnc ,"YYYYMMDD")>
							<cfset nCont = nCont - 1>
						</cfif>
					</cfloop> 
				</cfif>
			<cfelse>
				<cfif (vDiaSem eq 1) or (vDiaSem eq 7)> 
				<cfset nCont = nCont - 1>
				</cfif> 
			</cfif>
			<cfset nCont = nCont + 1> 
		</cfloop> 

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
			SELECT INPDTConcluirRevisao,Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Und_CodDiretoria, pos_dtultatu, 
			andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Situacao_Resp, Pos_Sit_Resp_Antes
			FROM SLNCPRCIDCGIANOMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			WHERE Pos_Situacao_Resp In (14,2,4,5,8,20,15,16,18,19,23) and Pos_DtPosic < #dtini# and Pos_Ano=#anoexerc# and Pos_Mes=#aux_mes#
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
		</cfquery>

		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,45)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>

		<cfoutput query="rsRot1">
			<cfset AndtDPosic = CreateDate(year(rsRot1.Pos_DtPosic),month(rsRot1.Pos_DtPosic),day(rsRot1.Pos_DtPosic))>
			<cfset AndtDTEnvio = CreateDate(year(rsRot1.INPDTConcluirRevisao),month(rsRot1.INPDTConcluirRevisao),day(rsRot1.INPDTConcluirRevisao))>
			<cfset AndtHPosic = rsRot1.andHrPosic>
			<cfset AndtCodSE = rsRot1.Und_CodDiretoria>
			<cfset auxsta = rsRot1.Pos_Situacao_Resp>			
			<cfif auxsta eq 14 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
				<cfset AndtPrazo = 'DP'>
			<cfelse>
				<cfset AndtPrazo = 'FP'>
			</cfif>	

			<cfset auxsta_antes = rsRot1.Pos_Sit_Resp_Antes> 
			<cfif auxsta_antes is 0 or auxsta_antes is 11 or auxsta_antes is 14 or auxsta_antes is 21 or auxsta_antes is 28 or auxsta_antes is 29>
				<cfset auxsta_antes = 1> 
			</cfif>		
			<cfset AndtNomeOrgCondutor = trim(rsRot1.Pos_NomeArea)>
			<cfif len(trim(rsRot1.Pos_NomeArea)) lt 0>
				<cfquery datasource="#dsn_inspecao#" name="rsdep">
					SELECT Dep_Descricao FROM Departamento where Dep_Codigo = '#rsRot1.Pos_Area#'
				</cfquery>
				<cfif rsdep.recordcount gt 0>
					<cfset AndtNomeOrgCondutor = trim(rsdep.Dep_Descricao)>
				</cfif>
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsunid">
						SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsRot1.Pos_Area#'
					</cfquery>
					<cfif rsunid.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsunid.Und_Descricao)>
					</cfif>
				</cfif>				
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsreop">
						SELECT Rep_Nome FROM Reops WHERE Rep_Codigo = '#rsRot1.Pos_Area#'
					</cfquery>							
					<cfif rsreop.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsreop.Rep_Nome)>
					</cfif>
				</cfif>
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsarea">
						SELECT Ars_Sigla FROM Areas WHERE Ars_Codigo = '#rsRot1.Pos_Area#'
					</cfquery>							
					<cfif rsarea.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsarea.Ars_Sigla)>
					</cfif>
				</cfif>
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsse">
						SELECT Dir_Descricao FROM Diretoria WHERE Dir_Sto = '#rsRot1.Pos_Area#'
					</cfquery>								
					<cfif rsse.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsse.Dir_Descricao)>
					</cfif>
				</cfif>	
			</cfif>					
			<!--- garantir a inclusão para PRCI --->
			<cfquery datasource="#dsn_inspecao#">
				insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto,Andt_DTEnvio) values ('#year(dtlimit)#', #month(dtlimit)#, '#rsRot1.Pos_Inspecao#', '#rsRot1.Pos_Unidade#', #rsRot1.Pos_NumGrupo#, #rsRot1.Pos_NumItem#, #AndtDPosic#, '#AndtHPosic#', #auxsta#, #rsRot1.Und_TipoUnidade#, 0, 0, '#rsRot1.pos_username#', CONVERT(char, GETDATE(), 120), '#rsRot1.Pos_Area#', '#AndtNomeOrgCondutor#', '#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1,'#auxsta_antes#', #rsRot1.Pos_PontuacaoPonto#, '#rsRot1.Pos_ClassificacaoPonto#',#AndtDTEnvio#)
			</cfquery>
		</cfoutput> 
		
		<!--- fim rotina 1  --->
		<!--- rotina 2 --->
		<!--- COMPOR O PRCI COM OS 14-NR, PENDENTES E TRATAMENTOS DENTRO DO MES E COMO MIGRARAM AO MÊS CORRENTE --->
		<!--- TODAS UNIDADES --->
		<cfquery name="rsRot2" datasource="#dsn_inspecao#">
			SELECT INPDTConcluirRevisao,Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Und_CodDiretoria, pos_dtultatu,andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Situacao_Resp, Pos_Sit_Resp_Antes
			FROM SLNCPRCIDCGIANOMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			WHERE Pos_Situacao_Resp In (14,2,4,5,8,20,15,16,18,19,23) and 
			Pos_DtPosic >= #dtini# and 
			Pos_Ano=#anoexerc# and 
			Pos_Mes=#aux_mes#
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
		</cfquery>

		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,45)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>

		<cfoutput query="rsRot2">
			<cfset AndtDPosica = CreateDate(year(rsRot2.Pos_DtPosic),month(rsRot2.Pos_DtPosic),day(rsRot2.Pos_DtPosic))>
			<cfset AndtDTEnvio = CreateDate(year(rsRot2.INPDTConcluirRevisao),month(rsRot2.INPDTConcluirRevisao),day(rsRot2.INPDTConcluirRevisao))>
			<cfset AndtHPosica = rsRot2.andHrPosic>
			<cfset AndtCodSE = rsRot2.Und_CodDiretoria>
			<cfset auxsta = rsRot2.Pos_Situacao_Resp>			
			<cfif auxsta eq 14 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
				<cfset AndtPrazo = 'DP'>
			<cfelse>
				<cfset AndtPrazo = 'FP'>
			</cfif>		
			<cfset auxsta_antes = rsRot2.Pos_Sit_Resp_Antes> 
			<cfif auxsta_antes is 0 or auxsta_antes is 11 or auxsta_antes is 14 or auxsta_antes is 21 or auxsta_antes is 28 or auxsta_antes is 29>
				<cfset auxsta_antes = 1> 
			</cfif>		
			<cfset AndtNomeOrgCondutor = trim(rsRot2.Pos_NomeArea)>
			<cfif len(trim(rsRot2.Pos_NomeArea)) lt 0>
				<cfquery datasource="#dsn_inspecao#" name="rsdep">
					SELECT Dep_Descricao FROM Departamento where Dep_Codigo = '#rsRot2.Pos_Area#'
				</cfquery>
				<cfif rsdep.recordcount gt 0>
					<cfset AndtNomeOrgCondutor = trim(rsdep.Dep_Descricao)>
				</cfif>
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsunid">
						SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsRot2.Pos_Area#'
					</cfquery>
					<cfif rsunid.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsunid.Und_Descricao)>
					</cfif>
				</cfif>				
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsreop">
						SELECT Rep_Nome FROM Reops WHERE Rep_Codigo = '#rsRot2.Pos_Area#'
					</cfquery>							
					<cfif rsreop.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsreop.Rep_Nome)>
					</cfif>
				</cfif>
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsarea">
						SELECT Ars_Sigla FROM Areas WHERE Ars_Codigo = '#rsRot2.Pos_Area#'
					</cfquery>							
					<cfif rsarea.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsarea.Ars_Sigla)>
					</cfif>
				</cfif>
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsse">
						SELECT Dir_Descricao FROM Diretoria WHERE Dir_Sto = '#rsRot2.Pos_Area#'
					</cfquery>								
					<cfif rsse.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsse.Dir_Descricao)>
					</cfif>
				</cfif>	
			</cfif>		
			<!--- garantir a inclusão para PRCI --->
			<cfquery datasource="#dsn_inspecao#">
				insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto,Andt_DTEnvio)  values ('#year(dtlimit)#', #month(dtlimit)#, '#rsRot2.Pos_Inspecao#', '#rsRot2.Pos_Unidade#', #rsRot2.Pos_NumGrupo#, #rsRot2.Pos_NumItem#, #AndtDPosica#, '#AndtHPosica#', #auxsta#, #rsRot2.Und_TipoUnidade#, 0, 0, '#rsRot2.pos_username#', CONVERT(char, GETDATE(), 120), '#rsRot2.Pos_Area#', '#AndtNomeOrgCondutor#', '#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1, '#auxsta_antes#', #rsRot2.Pos_PontuacaoPonto#, '#rsRot2.Pos_ClassificacaoPonto#',#AndtDTEnvio#)
			</cfquery>
		
			<cfif auxsta neq 14 and day(#AndtDPosica#) gt 1>
				<!--- FAZER BUSCAS POR outras possíveis ocorrências(PEND/TRAT) na andamento dentro do MêS/migração do mês anterior para PRCI --->
				<!--- Apenas nos maiores que o dia primeiro do mês trabalhado --->
				<cfset salvarSN = 'S'>
				<cfquery name="rsPENDTRAT" datasource="#dsn_inspecao#">
					SELECT INP_DTConcluirRevisao,And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area
					FROM Inspecao INNER JOIN Andamento ON (INP_NumInspecao = And_NumInspecao) AND (INP_Unidade = And_Unidade)
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
					<cfset AndtDTEnvio = CreateDate(year(rsPENDTRAT.INP_DTConcluirRevisao),month(rsPENDTRAT.INP_DTConcluirRevisao),day(rsPENDTRAT.INP_DTConcluirRevisao))>
					<cfset AndtHPosicb = rsPENDTRAT.And_HrPosic>
					<cfif auxsta eq 14 or auxsta eq 2 or auxsta eq 4 or auxsta eq 5 or auxsta eq 8 or auxsta eq 20 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>		
						<cfif auxsta eq 14 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
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
							<cfset auxsta_antes = rsPENDTRAT.And_Situacao_Resp> 
							<cfif auxsta_antes is 0 or auxsta_antes is 11 or auxsta_antes is 14 or auxsta_antes is 21 or auxsta_antes is 28 or auxsta_antes is 29>
								<cfset auxsta_antes = 1> 
							</cfif>		
							<cfset AndtNomeOrgCondutor = ''>
							<cfquery datasource="#dsn_inspecao#" name="rsdep">
								SELECT Dep_Descricao FROM Departamento where Dep_Codigo = '#rsPENDTRAT.And_Area#'
							</cfquery>
							<cfif rsdep.recordcount gt 0>
								<cfset AndtNomeOrgCondutor = trim(rsdep.Dep_Descricao)>
							</cfif>
							<cfif AndtNomeOrgCondutor is ''>
								<cfquery datasource="#dsn_inspecao#" name="rsunid">
									SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsPENDTRAT.And_Area#'
								</cfquery>
								<cfif rsunid.recordcount gt 0>
									<cfset AndtNomeOrgCondutor = trim(rsunid.Und_Descricao)>
								</cfif>
							</cfif>				
							<cfif AndtNomeOrgCondutor is ''>
								<cfquery datasource="#dsn_inspecao#" name="rsreop">
									SELECT Rep_Nome FROM Reops WHERE Rep_Codigo = '#rsPENDTRAT.And_Area#'
								</cfquery>							
								<cfif rsreop.recordcount gt 0>
									<cfset AndtNomeOrgCondutor = trim(rsreop.Rep_Nome)>
								</cfif>
							</cfif>
							<cfif AndtNomeOrgCondutor is ''>
								<cfquery datasource="#dsn_inspecao#" name="rsarea">
									SELECT Ars_Sigla FROM Areas WHERE Ars_Codigo = '#rsPENDTRAT.And_Area#'
								</cfquery>							
								<cfif rsarea.recordcount gt 0>
									<cfset AndtNomeOrgCondutor = trim(rsarea.Ars_Sigla)>
								</cfif>
							</cfif>
							<cfif AndtNomeOrgCondutor is ''>
								<cfquery datasource="#dsn_inspecao#" name="rsse">
									SELECT Dir_Descricao FROM Diretoria WHERE Dir_Sto = '#rsPENDTRAT.And_Area#'
								</cfquery>								
								<cfif rsse.recordcount gt 0>
									<cfset AndtNomeOrgCondutor = trim(rsse.Dir_Descricao)>
								</cfif>
							</cfif>							
							<cfquery datasource="#dsn_inspecao#">
								insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto,Andt_DTEnvio) values ('#year(dtlimit)#', #month(dtlimit)#, '#rsRot2.Pos_Inspecao#', '#rsRot2.Pos_Unidade#', #rsRot2.Pos_NumGrupo#, #rsRot2.Pos_NumItem#, #AndtDPosicb#, '#AndtHPosicb#', #auxsta#, #rsRot2.Und_TipoUnidade#, 0, 0, '#rsPENDTRAT.And_username#', CONVERT(char, GETDATE(), 120), '#rsPENDTRAT.And_Area#', '#AndtNomeOrgCondutor#','#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1, '#auxsta_antes#', #rsRot2.Pos_PontuacaoPonto#, '#rsRot2.Pos_ClassificacaoPonto#',#AndtDTEnvio#)
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
		<!--- OBTER NA ANDAMENTO POSSÍVEIS STATUS (14-NR, PEND OU TRAT) PARA COMPOR PRCI  DOS PONTOS TRAZIDOS DA PARECERUNIDADE (RESPOSTAS, SO, CS, RV AP, RC, NC, BX, EA, EC e TP --->
		<cfquery name="rsRot3" datasource="#dsn_inspecao#">
			SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Und_CodDiretoria, pos_dtultatu, andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Situacao_Resp, Pos_Sit_Resp_Antes
			FROM SLNCPRCIDCGIANOMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			WHERE Pos_Situacao_Resp In (3,1,6,7,17,22,9,21,24,25,26,27,28,29,30) AND 
			Pos_DtPosic between #dtini# and #dtfim# and 
			Pos_Ano=#anoexerc# and 
			Pos_Mes=#aux_mes#
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
					SELECT INP_DTConcluirRevisao,And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area
					FROM Inspecao INNER JOIN Andamento ON (INP_NumInspecao = And_NumInspecao) AND (INP_Unidade = And_Unidade)
					WHERE And_Unidade = '#rsRot3.Pos_Unidade#' AND 
					And_NumInspecao = '#rsRot3.Pos_Inspecao#' AND 
					And_NumGrupo = #rsRot3.Pos_NumGrupo# AND 
					And_NumItem = #rsRot3.Pos_NumItem# AND 
					And_DtPosic <= #AndtDPosic# AND 
					And_HrPosic <> '#AndtHPosic#'
					order by And_DtPosic desc, And_HrPosic desc
				</cfquery>					
				<cfset salvarSN = 'S'>
		
				<cfloop query="rsNRPENDTRAT">  
					<cfset auxsta = rsNRPENDTRAT.And_Situacao_Resp>	
					<cfset AndtDPosicc = CreateDate(year(rsNRPENDTRAT.And_DtPosic),month(rsNRPENDTRAT.And_DtPosic),day(rsNRPENDTRAT.And_DtPosic))>
					<cfset AndtDTEnvio = CreateDate(year(rsNRPENDTRAT.INP_DTConcluirRevisao),month(rsNRPENDTRAT.INP_DTConcluirRevisao),day(rsNRPENDTRAT.INP_DTConcluirRevisao))>
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
							<cfset auxsta_antes = rsNRPENDTRAT.And_Situacao_Resp> 
							<cfif auxsta_antes is 0 or auxsta_antes is 11 or auxsta_antes is 14 or auxsta_antes is 21 or auxsta_antes is 28 or auxsta_antes is 29>
								<cfset auxsta_antes = 1> 
							</cfif>		
							<cfset AndtNomeOrgCondutor = ''>
							<cfquery datasource="#dsn_inspecao#" name="rsdep">
								SELECT Dep_Descricao FROM Departamento where Dep_Codigo = '#rsNRPENDTRAT.And_Area#'
							</cfquery>
							<cfif rsdep.recordcount gt 0>
								<cfset AndtNomeOrgCondutor = trim(rsdep.Dep_Descricao)>
							</cfif>
							<cfif AndtNomeOrgCondutor is ''>
								<cfquery datasource="#dsn_inspecao#" name="rsunid">
									SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsNRPENDTRAT.And_Area#'
								</cfquery>
								<cfif rsunid.recordcount gt 0>
									<cfset AndtNomeOrgCondutor = trim(rsunid.Und_Descricao)>
								</cfif>
							</cfif>				
							<cfif AndtNomeOrgCondutor is ''>
								<cfquery datasource="#dsn_inspecao#" name="rsreop">
									SELECT Rep_Nome FROM Reops WHERE Rep_Codigo = '#rsNRPENDTRAT.And_Area#'
								</cfquery>							
								<cfif rsreop.recordcount gt 0>
									<cfset AndtNomeOrgCondutor = trim(rsreop.Rep_Nome)>
								</cfif>
							</cfif>
							<cfif AndtNomeOrgCondutor is ''>
								<cfquery datasource="#dsn_inspecao#" name="rsarea">
									SELECT Ars_Sigla FROM Areas WHERE Ars_Codigo = '#rsNRPENDTRAT.And_Area#'
								</cfquery>							
								<cfif rsarea.recordcount gt 0>
									<cfset AndtNomeOrgCondutor = trim(rsarea.Ars_Sigla)>
								</cfif>
							</cfif>
							<cfif AndtNomeOrgCondutor is ''>
								<cfquery datasource="#dsn_inspecao#" name="rsse">
									SELECT Dir_Descricao FROM Diretoria WHERE Dir_Sto = '#rsNRPENDTRAT.And_Area#'
								</cfquery>								
								<cfif rsse.recordcount gt 0>
									<cfset AndtNomeOrgCondutor = trim(rsse.Dir_Descricao)>
								</cfif>
							</cfif>	
							
							<cfquery datasource="#dsn_inspecao#">
								insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto,Andt_DTEnvio) values ('#year(dtlimit)#', #month(dtlimit)#, '#rsRot3.Pos_Inspecao#', '#rsRot3.Pos_Unidade#', #rsRot3.Pos_NumGrupo#, #rsRot3.Pos_NumItem#, #AndtDPosicc#, '#AndtHPosicc#', #auxsta#, #rsRot3.Und_TipoUnidade#, 0, 0, '#rsNRPENDTRAT.And_username#', CONVERT(char, GETDATE(), 120), '#rsNRPENDTRAT.And_Area#', '#AndtNomeOrgCondutor#','#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1, '#auxsta_antes#', #rsRot3.Pos_PontuacaoPonto#, '#rsRot3.Pos_ClassificacaoPonto#',#AndtDTEnvio#)
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
		<!--- ================  FINAL PRCI ======================= --->
		<!--- ================  INICIO SLNC ====================== --->
		<cfquery name="rsSLNC" datasource="#dsn_inspecao#">
			SELECT INPDTConcluirRevisao, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, pos_dtultatu, andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
			FROM SLNCPRCIDCGIANOMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			WHERE (((Pos_Situacao_Resp) In (2,4,5,8,15,16,19,23)) AND ((Und_TipoUnidade)<>12 And (Und_TipoUnidade)<>16))  
			and Pos_Ano=#anoexerc# 
			and Pos_Mes=#aux_mes#
			AND INPDTConcluirRevisao < #dt14limitprci_slnc#
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
		</cfquery>
		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,50)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>

		<cfoutput query="rsSLNC">
			<cfset AndtDPosic = CreateDate(year(rsSLNC.Pos_DtPosic),month(rsSLNC.Pos_DtPosic),day(rsSLNC.Pos_DtPosic))>
			<cfset AndtDTEnvio = CreateDate(year(rsSLNC.INPDTConcluirRevisao),month(rsSLNC.INPDTConcluirRevisao),day(rsSLNC.INPDTConcluirRevisao))>
			<cfset AndtHPosic = rsSLNC.andHrPosic>
			<cfset auxsta = rsSLNC.Pos_Situacao_Resp>
		
			<!--- ponto pode ser salvo para compor SLNC --->
			<cfset PosDtPosic = CreateDate(year(rsSLNC.Pos_DtPosic),month(rsSLNC.Pos_DtPosic),day(rsSLNC.Pos_DtPosic))>
			<cfset AndtHPosic = TimeFormat(now(),"hh:mm:ssss")> 
			<cfset AndtCodSE = left(rsSLNC.Pos_Unidade,2)>
			<cfset auxsta = rsSLNC.Pos_Situacao_Resp>
			<cfset auxsta_antes = rsSLNC.Pos_Sit_Resp_Antes> 
			<cfif auxsta_antes is 0 or auxsta_antes is 11 or auxsta_antes is 14 or auxsta_antes is 21 or auxsta_antes is 28 or auxsta_antes is 29>
				<cfset auxsta_antes = 1> 
			</cfif>		
			<cfset AndtNomeOrgCondutor = trim(rsSLNC.Pos_NomeArea)>
			<cfif len(trim(rsSLNC.Pos_NomeArea)) lt 0>
				<cfquery datasource="#dsn_inspecao#" name="rsdep">
					SELECT Dep_Descricao FROM Departamento where Dep_Codigo = '#rsSLNC.Pos_Area#'
				</cfquery>
				<cfif rsdep.recordcount gt 0>
					<cfset AndtNomeOrgCondutor = trim(rsdep.Dep_Descricao)>
				</cfif>
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsunid">
						SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsSLNC.Pos_Area#'
					</cfquery>
					<cfif rsunid.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsunid.Und_Descricao)>
					</cfif>
				</cfif>				
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsreop">
						SELECT Rep_Nome FROM Reops WHERE Rep_Codigo = '#rsSLNC.Pos_Area#'
					</cfquery>							
					<cfif rsreop.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsreop.Rep_Nome)>
					</cfif>
				</cfif>
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsarea">
						SELECT Ars_Sigla FROM Areas WHERE Ars_Codigo = '#rsSLNC.Pos_Area#'
					</cfquery>							
					<cfif rsarea.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsarea.Ars_Sigla)>
					</cfif>
				</cfif>
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsse">
						SELECT Dir_Descricao FROM Diretoria WHERE Dir_Sto = '#rsSLNC.Pos_Area#'
					</cfquery>								
					<cfif rsse.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsse.Dir_Descricao)>
					</cfif>
				</cfif>	
			</cfif>						
			<cfquery datasource="#dsn_inspecao#">
				insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto,Andt_DTEnvio) values ('#year(dtlimit)#', #month(dtlimit)#, '#rsSLNC.Pos_Inspecao#', '#rsSLNC.Pos_Unidade#', #rsSLNC.Pos_NumGrupo#, #rsSLNC.Pos_NumItem#, #PosDtPosic#, '#AndtHPosic#', #auxsta#, #rsSLNC.Und_TipoUnidade#, 0, 0, '#rsSLNC.pos_username#', CONVERT(char, GETDATE(), 120), '#rsSLNC.Pos_Area#', '#AndtNomeOrgCondutor#', '#AndtCodSE#', #dtfim#, 'NN', 2, '#auxsta_antes#', #rsSLNC.Pos_PontuacaoPonto#, '#rsSLNC.Pos_ClassificacaoPonto#',#AndtDTEnvio#)
			</cfquery>	
		</cfoutput>

		<!--- COMPOR O SLNC COM OS solucionados do Mês --->
		<cfquery name="rs3SO" datasource="#dsn_inspecao#">
			SELECT INPDTConcluirRevisao,Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, pos_dtultatu, andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes,Und_CodDiretoria
			FROM SLNCPRCIDCGIANOMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			WHERE Pos_Situacao_Resp = 3 and Pos_Ano=#anoexerc# and Pos_Mes=#aux_mes#
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
		</cfquery>

		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,50)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>

		<cfoutput query="rs3SO">
			<cfset PosDtPosic = CreateDate(year(rs3SO.Pos_DtPosic),month(rs3SO.Pos_DtPosic),day(rs3SO.Pos_DtPosic))>
			<cfset AndtDTEnvio = CreateDate(year(rs3SO.INPDTConcluirRevisao),month(rs3SO.INPDTConcluirRevisao),day(rs3SO.INPDTConcluirRevisao))>
			<cfset AndtHPosic = rs3SO.andHrPosic>
			<cfset AndtCodSE = left(rs3SO.Pos_Unidade,2)>
			
			<cfset auxsta = rs3SO.Pos_Situacao_Resp>
			<cfset auxsta_antes = rs3SO.Pos_Sit_Resp_Antes> 
			<cfif auxsta_antes is 0 or auxsta_antes is 11 or auxsta_antes is 14 or auxsta_antes is 21 or auxsta_antes is 28 or auxsta_antes is 29>
				<cfset auxsta_antes = 1> 
			</cfif>		
			<cfset AndtNomeOrgCondutor = trim(rs3SO.Pos_NomeArea)>
			<cfif len(trim(rs3SO.Pos_NomeArea)) lt 0>
				<cfquery datasource="#dsn_inspecao#" name="rsdep">
					SELECT Dep_Descricao FROM Departamento where Dep_Codigo = '#rs3SO.Pos_Area#'
				</cfquery>
				<cfif rsdep.recordcount gt 0>
					<cfset AndtNomeOrgCondutor = trim(rsdep.Dep_Descricao)>
				</cfif>
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsunid">
						SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rs3SO.Pos_Area#'
					</cfquery>
					<cfif rsunid.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsunid.Und_Descricao)>
					</cfif>
				</cfif>				
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsreop">
						SELECT Rep_Nome FROM Reops WHERE Rep_Codigo = '#rs3SO.Pos_Area#'
					</cfquery>							
					<cfif rsreop.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsreop.Rep_Nome)>
					</cfif>
				</cfif>
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsarea">
						SELECT Ars_Sigla FROM Areas WHERE Ars_Codigo = '#rs3SO.Pos_Area#'
					</cfquery>							
					<cfif rsarea.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsarea.Ars_Sigla)>
					</cfif>
				</cfif>
				<cfif AndtNomeOrgCondutor is ''>
					<cfquery datasource="#dsn_inspecao#" name="rsse">
						SELECT Dir_Descricao FROM Diretoria WHERE Dir_Sto = '#rs3SO.Pos_Area#'
					</cfquery>								
					<cfif rsse.recordcount gt 0>
						<cfset AndtNomeOrgCondutor = trim(rsse.Dir_Descricao)>
					</cfif>
				</cfif>	
			</cfif>	
			<cfquery datasource="#dsn_inspecao#">
				insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor,Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt,Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto,Andt_DTEnvio) values ('#year(dtlimit)#', #month(dtlimit)#, '#rs3SO.Pos_Inspecao#', '#rs3SO.Pos_Unidade#',#rs3SO.Pos_NumGrupo#, #rs3SO.Pos_NumItem#, #PosDtPosic#, '#AndtHPosic#', #auxsta#, #rs3SO.Und_TipoUnidade#, 0, 0, '#rs3SO.pos_username#', CONVERT(char, GETDATE(), 120), '#rs3SO.Pos_Area#', '#AndtNomeOrgCondutor#', '#AndtCodSE#', #dtfim#, 'NN', 2, '#auxsta_antes#', #rs3SO.Pos_PontuacaoPonto#, '#rs3SO.Pos_ClassificacaoPonto#',#AndtDTEnvio#)
			</cfquery>	
		</cfoutput>
		<!--- VALIDAR PONTOS NA TABELA: Andamento_Temp  --->
		<!--- GRUPOS E ITENS NAO PERMITIDOS  --->
		<cfquery name="rsGRIT" datasource="#dsn_inspecao#">
			SELECT Andt_AnoExerc, Andt_TipoRel, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_Resp, Andt_Area
			FROM Andamento_Temp 
			WHERE Andt_AnoExerc ='#year(dtlimit)#' AND Andt_Mes = #month(dtlimit)#
		</cfquery>

		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,50)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>

		<cfloop query="rsGRIT">
			<cfset excSN='N'>
			<cfset auxgrp = rsGRIT.Andt_Grp>
			<cfset auxitm = rsGRIT.Andt_Item>
			<cfif auxgrp is 9 and auxitm is 9>
				<cfset excSN='S'>
			<cfelseif auxgrp is 29 and auxitm is 4>
				<cfset excSN='S'>
			<cfelseif auxgrp is 68 and auxitm is 3>
				<cfset excSN='S'>
			<cfelseif auxgrp is 96 and auxitm is 3>
				<cfset excSN='S'>
			<cfelseif auxgrp is 122 and auxitm is 3>
				<cfset excSN='S'>			
			<cfelseif auxgrp is 209 and auxitm is 3>
				<cfset excSN='S'>
			<cfelseif auxgrp is 278 and auxitm is 2>
				<cfset excSN='S'>
			<cfelseif auxgrp is 241 and auxitm is 3>
				<cfset excSN='S'>
			<cfelseif auxgrp is 308 and auxitm is 3>
				<cfset excSN='S'>
			<cfelseif auxgrp is 337 and auxitm is 2>
				<cfset excSN='S'>
			</cfif>
			<cfif excSN eq 'S'>
				<cfquery datasource="#dsn_inspecao#">
					UPDATE Andamento_Temp SET Andt_Prazo = 'X1'
					WHERE Andt_AnoExerc='#rsGRIT.Andt_AnoExerc#' AND
					Andt_Mes=#rsGRIT.Andt_Mes# AND
					Andt_TipoRel=#rsGRIT.Andt_TipoRel# AND
					Andt_Unid='#rsGRIT.Andt_Unid#' AND 
					Andt_Insp='#rsGRIT.Andt_Insp#' AND 
					Andt_Grp=#rsGRIT.Andt_Grp# AND 
					Andt_Item=#rsGRIT.Andt_Item# AND
					Andt_Resp=#rsGRIT.Andt_Resp# AND
					Andt_Area='#rsGRIT.Andt_Area#'
				</cfquery>
			</cfif>		
		</cfloop>		
		<!--- FIM ROTINA  ---> 
				
		<!--- ROTINA  --->
		<!--- POS_NOMEAREA NAO PERMITIDOS  --->
		<cfquery name="AndtArea" datasource="#dsn_inspecao#">
			SELECT Ars_Descricao, Andt_AnoExerc, Andt_TipoRel, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_Resp, Andt_Area, Andt_PosClassificacaoPonto, Andt_Unid
			FROM Andamento_Temp INNER JOIN Areas ON Andt_Area = Ars_Codigo  
			WHERE Andt_AnoExerc ='#year(dtlimit)#' AND Andt_Mes = #month(dtlimit)# 
		</cfquery>

		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,50)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>

		<cfloop query="AndtArea">
			<cfset ArsDescricao = ucase(trim(AndtArea.Ars_Descricao))>
			<cfset excSN='N'>
			<cfif ArsDescricao eq 'SEC ACOMP CONTR INTERNO/SCIA'>
				<cfset excSN='S'>
			<cfelseif ArsDescricao eq 'SEC ACOMP CONTR INTERNO/SGCIN'>
				<cfset excSN='S'>
			<cfelseif ArsDescricao eq 'SUP CONTR INTERNO/CCOP'>
				<cfset excSN='S'>
			<cfelseif ArsDescricao eq 'SEC AVAL CONT INTERNO/SCOI'>
				<cfset excSN='S'>
			<cfelseif ArsDescricao eq 'SEC AVAL CONT INTERNO/SGCIN'>
				<cfset excSN='S'>			
			<cfelseif ArsDescricao eq 'COORD SEG CORPOR/GSOP'>
				<cfset excSN='S'>
			<cfelseif ArsDescricao eq 'COORD SEG CORPORATIVA/GSEP'>
				<cfset excSN='S'>
			<cfelseif ArsDescricao eq 'COORD SEG CORPOR 01/GSOP'>
				<cfset excSN='S'>
			<cfelseif ArsDescricao eq 'SUBG SEG CORPOR/GAAV'>
				<cfset excSN='S'>
			<cfelseif ArsDescricao eq 'CORREGEDORIA/PRESI'>
				<cfset excSN='S'>
			<cfelseif ArsDescricao eq 'CORREGEDORIA SEDE/SCORG'>
				<cfset excSN='S'>
			<cfelseif ArsDescricao eq 'COORD REG CORREICAO/CORR'>
				<cfset excSN='S'>
			<cfelseif ArsDescricao eq 'SUP CSC LOCAL TEC INF/CESTI'>
				<cfset excSN='S'>				
			<cfelseif left(ArsDescricao,22) eq 'GER DE SERVICOS DE TIC'>*Saiuqalam10

				<cfset excSN='S'>				
			</cfif>
			<cfif excSN eq 'S'>
				<cfquery datasource="#dsn_inspecao#">
					UPDATE Andamento_Temp SET Andt_Prazo = 'X2'
					WHERE Andt_AnoExerc='#AndtArea.Andt_AnoExerc#' AND
					Andt_Mes=#AndtArea.Andt_Mes# AND
					Andt_TipoRel=#AndtArea.Andt_TipoRel# AND
					Andt_Unid='#AndtArea.Andt_Unid#' AND 
					Andt_Insp='#AndtArea.Andt_Insp#' AND 
					Andt_Grp=#AndtArea.Andt_Grp# AND 
					Andt_Item=#AndtArea.Andt_Item# AND
					Andt_Resp=#AndtArea.Andt_Resp# AND
					Andt_Area='#AndtArea.Andt_Area#'
				</cfquery>
			</cfif>	 				 	
		</cfloop>

		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,45)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>

	<!--- FIM ROTINA   
		<cfquery datasource="#dsn_inspecao#">
			delete from Andamento_Temp where Andt_Prazo = 'EX'
		</cfquery>  
	
		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,45)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>	--->

<cfoutput>
dtlimit: #dtlimit#<br>
</cfoutput>
Fim processamento!


