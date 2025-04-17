
<cfprocessingdirective pageEncoding ="utf-8">
<!--- <cfif int(day(now())) is 1>
<p>=================== Aguarde! =======================</p>
<p>============== SNCI em  Manutencao! =================</p>
<p>============== Previsão de retorno às 08h =================</p>
<cfabort>
</cfif>
<cfset gil = gil> --->

<cfsetting requesttimeout="20000">

<cfset auxdt = dateformat(now(),"YYYYMMDD")>
<cfquery name="rsDia" datasource="#dsn_inspecao#">
	SELECT MSG_Realizado, MSG_Status FROM Mensagem WHERE MSG_Codigo = 1
</cfquery>
<cfset auxdiacol = rsDia.MSG_Realizado>
<cfset auxdiacol = left(auxdiacol,4) & '-' & mid(auxdiacol,5,2) & '-' & right(auxdiacol,2)>
<cfset dtlimit = CreateDate(year(auxdiacol),month(auxdiacol),day(auxdiacol))> 

<cfif rsDia.MSG_Status is 'A'>
	<cflocation url="SNCI_MENSAGEM.cfm?form.motivo=Sr(a) USUARIO(a), AGUARDE! EM POUCOS MINUTOS SERÁ LIBERADO O ACESSO, SNCI EM MANUTENÇÃO">
</cfif>  
	
<cfset auxsite = trim(ucase(cgi.server_name))>
<!--- Rotina já rodou neste dia? --->
<cfif (rsDia.MSG_Realizado eq auxdt)>
	<!--- Sim! Rotina já rodou. --->
	<cfif FIND("INTRANETSISTEMASPE", "#auxsite#")>
		<cflocation url="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">
	<cfelseif FIND("DESENVOLVIMENTOPE", "#auxsite#")>
	<cfquery datasource="#dsn_inspecao#">
		UPDATE Mensagem SET MSG_Realizado = '#auxdt#', MSG_Status = 'D' WHERE MSG_Codigo = 1
	</cfquery>	  
		<cflocation url="http://desenvolvimentope/snci/rotinas_inspecao.cfm">
	<cfelseif FIND("HOMOLOGACAOPE", "#auxsite#")>
	<cfquery datasource="#dsn_inspecao#">
		UPDATE Mensagem SET MSG_Realizado = '#auxdt#', MSG_Status = 'D' WHERE MSG_Codigo = 1
	</cfquery>	  
		<cflocation url="http://homologacaope/snci/rotinas_inspecao.cfm">  
	<cfelse>
		<!--- Provocar erro --->
		<cfset AAA = AAA>
	</cfif> 
</cfif>   
<!--- Atualiza o campo com a data corrente da realizacao --->
<cfquery datasource="#dsn_inspecao#">
	UPDATE Mensagem SET MSG_Realizado = '#auxdt#', MSG_Status = 'A' WHERE MSG_Codigo = 1
</cfquery>

<!--- Não rodar em desenvolvimento ou Homologação --->
<cfif FIND("DESENVOLVIMENTOPE", "#auxsite#")>
	<cfquery datasource="#dsn_inspecao#">
		UPDATE Mensagem SET MSG_Realizado = '#auxdt#', MSG_Status = 'D' WHERE MSG_Codigo = 1
	</cfquery>
	<cflocation url="http://desenvolvimentope/snci/rotinas_inspecao.cfm"> 
<cfelseif FIND("HOMOLOGACAOPE", "#auxsite#")>
	<cfquery datasource="#dsn_inspecao#">
		UPDATE Mensagem SET MSG_Realizado = '#auxdt#', MSG_Status = 'D' WHERE MSG_Codigo = 1
	</cfquery>
	<cflocation url="http://homologacaope/snci/rotinas_inspecao.cfm">  
</cfif>     

<!---Cria uma instância do componente Dao--->
<cfobject component = "CFC/Dao" name = "dao">
<!---  --->
<cfset rotinaSN = 'S'>
<cfset dtatual = CreateDate(year(now()),month(now()),day(now()))>
<cfset vDiaSem = DayOfWeek(dtatual)>
<cfif vDiaSem eq 1 or vDiaSem eq 7>
	<cfset rotinaSN = 'N'>
<cfelse>
	<!--- verificar se Feriado Nacional --->
	<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
			 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtatual#
	</cfquery>
	<cfif rsFeriado.recordcount gt 0>
	   <cfset rotinaSN = 'N'>
	</cfif>
</cfif>
<!---  --->
<cfif not isDefined("url.rotina")>
 	<cfset rotina = 1>
</cfif> 
<cfif rotinaSN is 'S'>
	<!--- Obter o a data util para 10(dez) dias --->
	<cfset dt10dduteis = CreateDate(year(now()),month(now()),day(now()))>
	<cfset nCont = 1>
	<cfloop condition="nCont lt 10">
		<cfset dt10dduteis = DateAdd( "d", 1, dt10dduteis)>
		<cfset vDiaSem = DayOfWeek(dt10dduteis)>
		<cfif vDiaSem neq 1 and vDiaSem neq 7>
			<!--- verificar se Feriado Nacional --->
			<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
				 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dt10dduteis#
			</cfquery>
			<cfif rsFeriado.recordcount gt 0>
			   <cfset nCont = nCont - 1>
			</cfif>
		</cfif>
		<!--- Verifica se final de semana  --->
		<cfif vDiaSem eq 1 or vDiaSem eq 7>
			<cfset nCont = nCont - 1>
		</cfif>	
		<cfset nCont = nCont + 1>
	</cfloop>

	<!--- Obter o a data util para 30(trinta) dias --->
	<cfset dt30dduteis = CreateDate(year(now()),month(now()),day(now()))>
	<cfset nCont = 1>
	<cfloop condition="nCont lt 30">
		<cfset dt30dduteis = DateAdd( "d", 1, dt30dduteis)>
		<cfset vDiaSem = DayOfWeek(dt30dduteis)>
		<cfif vDiaSem neq 1 and vDiaSem neq 7>
			<!--- verificar se Feriado Nacional --->
			<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
				 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dt30dduteis#
			</cfquery>
			<cfif rsFeriado.recordcount gt 0>
			   <cfset nCont = nCont - 1>
			</cfif>
		</cfif>
		<!--- Verifica se final de semana  --->
		<cfif vDiaSem eq 1 or vDiaSem eq 7>
			<cfset nCont = nCont - 1>
		</cfif>	
		<cfset nCont = nCont + 1>
	</cfloop>	
</cfif>

<cfloop condition="rotina lte 33">   
	<cfif rotina eq 1>
	    <cfset auxano = year(now())>
	    <!--- Prover ajustes na tabela Andamento para todos os status --->
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<cfquery name="rsEncerrar" datasource="#dsn_inspecao#">
			SELECT Und_Descricao,Pos_Parecer, Pos_ClassificacaoPonto, RIP_Falta, Pos_Situacao_Resp, INP_DTConcluirRevisao, INP_DTConcluirRevisao, DATEDIFF(d,INP_DTConcluirRevisao,GETDATE()), Pos_Unidade,Pos_Inspecao,Pos_NumGrupo,Pos_NumItem
			FROM ((Inspecao INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)) INNER JOIN ParecerUnidade ON (RIP_Unidade = Pos_Unidade) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumItem = Pos_NumItem)) INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			WHERE (Und_TipoUnidade<>12) AND (Pos_Situacao_Resp In (2,4,5,8,15,16,19,23)) AND ((Pos_ClassificacaoPonto='MEDIANO' AND RIP_Falta > 1000 AND RIP_Falta < 120000) OR (Pos_ClassificacaoPonto='GRAVE' AND RIP_Falta < 120000)) 
			and (DATEDIFF(d,INP_DTConcluirRevisao,GETDATE()) >= 360)
			ORDER BY Pos_ClassificacaoPonto, RIP_Falta DESC
		</cfquery>
		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,45)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>		
		<cfset msg = 'Conforme novos critérios definidos por meio da Nota Técnica N.º 51741855/2024, SEI 53180.028789/2022-72, encerra-se o acompanhamento da regularização da não conformidade registrada nesse item de avaliação após decorrido o prazo de 360 dias.' & CHR(13) & CHR(13) & 'Tal decisão não exime os órgãos responsáveis da adoção de ações para regularização da situação registrada pelo Controle Interno, inclusive quanto ao recolhimento aos cofres da Empresa dos valores devidos, se for o caso.'>
		<cfset pos_aux = trim(rsEncerrar.Pos_Parecer) & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM')  & '> ' & 'Opinião do Controle Interno' & CHR(13) & CHR(13) & 'À(O) ' & #rsEncerrar.Und_Descricao# & CHR(13) & CHR(13) & msg & CHR(13) & CHR(13) & 'Situação: ENCERRADO' & CHR(13) & CHR(13) &  'Responsável: DCINT/SUGOV/DIGOE ' & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
		<cfoutput query="rsEncerrar">
			<cfquery datasource="#dsn_inspecao#">
				UPDATE ParecerUnidade SET Pos_Situacao_Resp = 29
				, Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
				, Pos_DtPrev_Solucao = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))# 
				, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
				, Pos_Situacao = 'EC'
				, Pos_Parecer = '#pos_aux#'
				, Pos_Sit_Resp_Antes = #rsEncerrar.Pos_Situacao_Resp#
				WHERE Pos_Unidade='#rsEncerrar.Pos_Unidade#' AND Pos_Inspecao='#rsEncerrar.Pos_Inspecao#' AND Pos_NumGrupo=#rsEncerrar.Pos_NumGrupo# AND Pos_NumItem=#rsEncerrar.Pos_NumItem#
			</cfquery> 
			<cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM')  & '> ' & 'Opinião do Controle Interno' & CHR(13) & CHR(13) & 'À(O) ' & #rsEncerrar.Und_Descricao# & CHR(13) & CHR(13) & msg & CHR(13) & CHR(13) & 'Situação: ENCERRADO' & CHR(13) & CHR(13) &  'Responsável: DCINT/SUGOV/DIGOE ' & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
			<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
			<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
			<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")> 
			<cfif len(hhmmssdc) lt 9>
				<cfset hhmmssdc = hhmmssdc & '0'>
			</cfif>
			<cfquery datasource="#dsn_inspecao#">
				insert into Andamento (And_NumInspecao,And_Unidade,And_NumGrupo,And_NumItem,And_DtPosic,And_username,And_Situacao_Resp,And_Area,And_NomeArea,And_HrPosic,And_Parecer) 
				values ('#rsEncerrar.Pos_Inspecao#','#rsEncerrar.Pos_Unidade#','#rsEncerrar.Pos_NumGrupo#','#rsEncerrar.Pos_NumItem#',#createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#,'Rotina_Automatica',29,'#rsEncerrar.Pos_Unidade#','#rsEncerrar.Und_Descricao#','#hhmmssdc#','#and_obs#')
			</cfquery> 
		</cfoutput>
	</cfif>
	<cfif rotina eq 1>
	    <cfset auxano = year(now())>
	    <!--- Prover ajustes na tabela Andamento para todos os status --->
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<cfquery name="rsAtuAND" datasource="#dsn_inspecao#">
			SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_Situacao_Resp, pos_username, Pos_Area, Pos_NomeArea, pos_dtultatu
			FROM ParecerUnidade LEFT JOIN Andamento ON (Pos_Situacao_Resp = And_Situacao_Resp) AND (Pos_DtPosic = And_DtPosic) AND (Pos_NumItem = And_NumItem) AND 
			(Pos_NumGrupo = And_NumGrupo) AND (Pos_Unidade = And_Unidade) AND ([Pos_Inspecao] = [And_NumInspecao])
			WHERE And_NumInspecao Is Null
			order by Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>
		<cfoutput query="rsAtuAND">
		    <cfset incluirsn = 'S'>
		    <cfif right(rsAtuAND.Pos_Inspecao,4) eq auxano>
				<cfquery name="rs011Pos" datasource="#dsn_inspecao#">
					SELECT Pos_Unidade FROM ParecerUnidade
					WHERE Pos_Inspecao='#rsAtuAND.Pos_Inspecao#' AND Pos_Situacao_Resp in(0,11)
				</cfquery>
				<cfif rs011Pos.recordcount gt 0>
					<cfset incluirsn = 'N'>
				</cfif>
			</cfif>
			<cfif incluirsn eq 'S'>
				<cfset hhmmssdc = trim(mid(rsAtuAND.pos_dtultatu,11,len(rsAtuAND.pos_dtultatu)))>
				<cfset hhmmssdc = Replace(hhmmssdc,':','','All')>
				<cfset hhmmssdc = Replace(hhmmssdc,'.','','All')>	
				<cfset andparecer = #rsAtuAND.Pos_Area#  & " --- " & #rsAtuAND.Pos_NomeArea#>

				<cfif rsAtuAND.Pos_Situacao_Resp eq 14>
					<cfset hhmmssdc = '000014'>
				</cfif>
				
				<cfquery datasource="#dsn_inspecao#">
					insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, and_Parecer, And_Area) 
					values ('#rsAtuAND.Pos_Inspecao#', '#rsAtuAND.Pos_Unidade#', #rsAtuAND.Pos_NumGrupo#, #rsAtuAND.Pos_NumItem#, '#dateformat(rsAtuAND.Pos_DtPosic,"YYYY-MM-DD")#', '#rsAtuAND.pos_username#', #rsAtuAND.Pos_Situacao_Resp#, '#hhmmssdc#', '#andparecer#', '#rsAtuAND.Pos_Area#')
				</cfquery>
			</cfif>
		</cfoutput>
	</cfif> 
	<cfif rotina eq 2>
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
			<cfquery name="rsAnd" datasource="#dsn_inspecao#">
				SELECT And_HrPosic
				FROM Andamento
				WHERE And_NumInspecao='#rs3SO.Pos_Inspecao#' AND 
				And_Unidade='#rs3SO.Pos_Unidade#' AND 
				And_NumGrupo=#rs3SO.Pos_NumGrupo# AND 
				And_NumItem=#rs3SO.Pos_NumItem# AND 
				And_Situacao_Resp=3 and
				And_DtPosic=#PosDtPosic#
				order by And_DtPosic desc, And_HrPosic desc
			</cfquery>	
			<cfset AndHrPosic = #trim(rsAnd.And_HrPosic)#>
			<cfquery datasource="#dsn_inspecao#">
				insert into SLNCPRCIDCGIANOMES (Pos_Ano,Pos_Mes,Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao, pos_username, Pos_Area, Pos_NomeArea, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes,INPDTConcluirRevisao,andHrPosic) 
				values (#anoexerc#,#aux_mes#,'#rs3SO.Pos_Unidade#', '#rs3SO.Pos_Inspecao#', #rs3SO.Pos_NumGrupo#, #rs3SO.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rs3SO.Pos_Situacao#', '#rs3SO.pos_username#', '#rs3SO.Pos_Area#', '#rs3SO.Pos_NomeArea#', #PosDtPrevSolucao#, #PosPontuacaoPonto#, '#PosClassificacaoPonto#', #auxantes#,#INPDTConcluirRevisao#,'#AndHrPosic#')
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
			<cfset AndHrPosic = '000014'>
			<cfif auxsta neq 14>
				<cfquery name="rsAnd" datasource="#dsn_inspecao#">
					SELECT And_HrPosic
					FROM Andamento
					WHERE And_NumInspecao='#rsNRPENDTRAT.Pos_Inspecao#' AND 
					And_Unidade='#rsNRPENDTRAT.Pos_Unidade#' AND 
					And_NumGrupo=#rsNRPENDTRAT.Pos_NumGrupo# AND 
					And_NumItem=#rsNRPENDTRAT.Pos_NumItem# AND 
					And_Situacao_Resp=#auxsta# and
					And_DtPosic=#PosDtPosic#
					order by And_DtPosic desc, And_HrPosic desc
				</cfquery>	
				<cfset AndHrPosic = #trim(rsAnd.And_HrPosic)#>
			</cfif>									
			<cfquery datasource="#dsn_inspecao#">
				insert into SLNCPRCIDCGIANOMES (Pos_Ano,Pos_Mes,Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao,pos_username, Pos_Area, Pos_NomeArea, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes,INPDTConcluirRevisao,andHrPosic) values (#anoexerc#,#aux_mes#,'#rsNRPENDTRAT.Pos_Unidade#', '#rsNRPENDTRAT.Pos_Inspecao#', #rsNRPENDTRAT.Pos_NumGrupo#, #rsNRPENDTRAT.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rsNRPENDTRAT.Pos_Situacao#', '#rsNRPENDTRAT.pos_username#', '#rsNRPENDTRAT.Pos_Area#', '#rsNRPENDTRAT.Pos_NomeArea#', #PosDtPrevSolucao#, #PosPontuacaoPonto#, '#PosClassificacaoPonto#', #auxantes#,#INPDTConcluirRevisao#,'#AndHrPosic#')
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

			<cfquery name="rsAnd" datasource="#dsn_inspecao#">
				SELECT And_HrPosic
				FROM Andamento
				WHERE And_NumInspecao='#rsOutros.Pos_Inspecao#' AND 
				And_Unidade='#rsOutros.Pos_Unidade#' AND 
				And_NumGrupo=#rsOutros.Pos_NumGrupo# AND 
				And_NumItem=#rsOutros.Pos_NumItem# AND 
				And_Situacao_Resp=#auxsta# and
				And_DtPosic=#PosDtPosic#
				order by And_DtPosic desc, And_HrPosic desc
			</cfquery>	
			<cfset AndHrPosic = trim(#rsAnd.And_HrPosic#)>
							
			<cfquery datasource="#dsn_inspecao#">
				insert into SLNCPRCIDCGIANOMES (Pos_Ano,Pos_Mes,Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao,pos_username, Pos_Area, Pos_NomeArea, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes,INPDTConcluirRevisao,andHrPosic) 
				values 
				(#anoexerc#,#aux_mes#,'#rsOutros.Pos_Unidade#', '#rsOutros.Pos_Inspecao#', #rsOutros.Pos_NumGrupo#, #rsOutros.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rsOutros.Pos_Situacao#', '#rsOutros.pos_username#', '#rsOutros.Pos_Area#', '#rsOutros.Pos_NomeArea#', #PosDtPrevSolucao#, #PosPontuacaoPonto#, '#PosClassificacaoPonto#', #auxantes#,#INPDTConcluirRevisao#,'#AndHrPosic#')
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
		<cfset dt14nrlimiteslnc  = #dtfim#>
		<cfset nCont = 1>
		<cfset dsusp = 0>
		<cfloop condition="nCont lte 30"> 
			<cfset dt14nrlimiteslnc  = DateAdd("d", -1, #dt14nrlimiteslnc#)>	
			<cfset vDiaSem = DayOfWeek(dt14nrlimiteslnc )>
			<cfif (vDiaSem neq 1) and (vDiaSem neq 7)>
				<cfif rsFer.recordcount gt 0> 
					<cfloop query="rsFer">
						<cfif dateformat(rsFer.Fer_Data,"YYYYMMDD") eq dateformat(dt14nrlimiteslnc ,"YYYYMMDD")>
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
			SELECT andHrPosic,INPDTConcluirRevisao,Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Und_CodDiretoria, pos_dtultatu, 
			Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Situacao_Resp, Pos_Sit_Resp_Antes
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
			SELECT andHrPosic,INPDTConcluirRevisao,Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Und_CodDiretoria, pos_dtultatu,Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Situacao_Resp, Pos_Sit_Resp_Antes
			FROM SLNCPRCIDCGIANOMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			WHERE Pos_Situacao_Resp In (14,2,4,5,8,20,15,16,18,19,23) and 
			Pos_DtPosic >= #dtini# and 
			Pos_Ano=#anoexerc# and Pos_Mes=#aux_mes#
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
		</cfquery>

		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,45)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>

		<cfoutput query="rsRot2">
			<cfset auxsit = rsRot2.Pos_Situacao_Resp>
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
				<cfset startTime = CreateTime(0,0,0)> 
				<cfset endTime = CreateTime(0,0,45)> 
				<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
				</cfloop>
				<cfset salvarSN = 'S'>
				<cfloop query="rsPENDTRAT"> 
					<cfset auxsta = rsPENDTRAT.And_Situacao_Resp>
					<cfset AndtDPosicb = CreateDate(year(rsPENDTRAT.And_DtPosic),month(rsPENDTRAT.And_DtPosic),day(rsPENDTRAT.And_DtPosic))>
					<cfset AndtDTEnvio = CreateDate(year(rsPENDTRAT.INP_DTConcluirRevisao),month(rsPENDTRAT.INP_DTConcluirRevisao),day(rsPENDTRAT.INP_DTConcluirRevisao))>
					<cfset AndtHPosicb = rsPENDTRAT.And_HrPosic>
					<cfif auxsta neq 14 and auxsta neq 2 and auxsta neq 4 and auxsta neq 5 and auxsta neq 8 and auxsta neq 20 and auxsta neq 15 and auxsta neq 16 and auxsta neq 18 and auxsta neq 19 and auxsta neq 23>						
						   <cfif (dateformat(#AndtDPosicb#,"YYYYMMDD") lte dateformat(#dtini#,"YYYYMMDD"))>
								<cfset salvarSN = 'N'>
						   </cfif> 
					</cfif>
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
							<!---	--->			
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
			SELECT andHrPosic,Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Und_CodDiretoria, pos_dtultatu,Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Situacao_Resp, Pos_Sit_Resp_Antes
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
			<cfset auxsit = rsRot3.Pos_Situacao_Resp>
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
				<cfset startTime = CreateTime(0,0,0)> 
				<cfset endTime = CreateTime(0,0,45)> 
				<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
				</cfloop>								
				<cfset salvarSN = 'S'>
		
				<cfloop query="rsNRPENDTRAT">  			
					<cfset auxsta = rsNRPENDTRAT.And_Situacao_Resp>	
					<cfset AndtDPosicc = CreateDate(year(rsNRPENDTRAT.And_DtPosic),month(rsNRPENDTRAT.And_DtPosic),day(rsNRPENDTRAT.And_DtPosic))>
					<cfset AndtDTEnvio = CreateDate(year(rsNRPENDTRAT.INP_DTConcluirRevisao),month(rsNRPENDTRAT.INP_DTConcluirRevisao),day(rsNRPENDTRAT.INP_DTConcluirRevisao))>
					<cfset AndtHPosicc = rsNRPENDTRAT.And_HrPosic>
					<cfif auxsta neq 14 and auxsta neq 2 and auxsta neq 4 and auxsta neq 5 and auxsta neq 8 and auxsta neq 20 and auxsta neq 15 and auxsta neq 16 and auxsta neq 18 and auxsta neq 19 and auxsta neq 23>						
						   <cfif (dateformat(#AndtDPosicc#,"YYYYMMDD") lte dateformat(#dtini#,"YYYYMMDD"))>
							<cfset salvarSN = 'N'>
						   </cfif> 
					</cfif>
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
						<cfif auxsta eq 14 and dateformat(AndtDPosicc,"YYYYMMDD") lt dateformat(dt14nrlimiteslnc,"YYYYMMDD")>
							<!--- <cfset salvarSN = 'N'> --->
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
			<!--- fim rot03  --->
		</cfoutput> 
		<!--- ================  FINAL PRCI ======================= --->

		<!--- ================  INICIO SLNC ====================== --->
		<cfquery name="rsSLNC" datasource="#dsn_inspecao#">
			SELECT andHrPosic,INPDTConcluirRevisao, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, pos_dtultatu, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
			FROM SLNCPRCIDCGIANOMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			WHERE (((Pos_Situacao_Resp) In (2,4,5,8,15,16,19,23)) AND ((Und_TipoUnidade)<>12 And (Und_TipoUnidade)<>16))  
			and Pos_Ano=#anoexerc# 
			and Pos_Mes=#aux_mes#
			AND INPDTConcluirRevisao < #dt14nrlimiteslnc#
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
			SELECT andHrPosic,INPDTConcluirRevisao,Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, pos_dtultatu, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes,Und_CodDiretoria
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
			    <cfif rsGRIT.Andt_TipoRel eq 1>
					<cfset AndtTipoRel= 11>
				<cfelse>
					<cfset AndtTipoRel= 22>
				</cfif>
				<cfquery datasource="#dsn_inspecao#">
					UPDATE Andamento_Temp SET Andt_TipoRel = #AndtTipoRel#
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
			<cfelseif ArsDescricao eq 'COORD CONTR INT OPER/CCOP'>
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
			<cfelseif left(ArsDescricao,22) eq 'GER DE SERVICOS DE TIC'>
				<cfset excSN='S'>				
			</cfif>
			<cfif excSN eq 'S'>
				<cfif AndtArea.Andt_TipoRel eq 1>
					<cfset AndtTipoRel= 11>
				<cfelse>
					<cfset AndtTipoRel= 22>
				</cfif>
				<cfquery datasource="#dsn_inspecao#">
					UPDATE Andamento_Temp SET Andt_TipoRel = #AndtTipoRel#
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
	</cfif>
	<!--- ************** MUDAR STATUS ****************** --->
	<!--- ###### UNIDADES ###### --->
	<!--- para PENDENTE --->
	<cfif rotina eq 3 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- Todas mudanças de Status deverão ter registros nos campos (Pos_Paracer(Cumulativo) e And_Parecer(individual)) --->
		<!--- Mudar o Status de 14-NR para 2-PU (Próprias) --->
		<!--- CONDIÇÃO: Quando o campo: Pos_DtPrev_Solucao estiver vencido dos 10 dias úteis concedidos --->
		<cfquery name="rs14NR_2PU" datasource="#dsn_inspecao#">
			SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Parecer, Und_Email, 
			Und_TipoUnidade, Und_Descricao, Und_Centraliza, Rep_Email
			FROM Unidades 
			INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
			INNER JOIN Reops ON Und_CodReop = Rep_Codigo
			WHERE Pos_Situacao_Resp in (14) and
		 	Und_TipoUnidade not in (12,16) and 
			(Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) 
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>
	  	<cfoutput query="rs14NR_2PU">
			<!--- Proprias --->
			<cfset rot3_IDStatus = 2>
			<cfset rot3_SglStatus = 'PU'>
			<cfset rot3_DescStatus = 'PENDENTE DA UNIDADE'>
			<cfset sinformes = 'Em virtude da ausência de manifestação desse gestor, estamos transferindo a Situação encontrada para o Status ' & #rot3_DescStatus# & CHR(13) & ' Com cobranças diárias, por e-mail, até o registro de sua resposta no sistema.'   & CHR(13) & ' Após 30 dias úteis a contar na data do recebimento do Relatório de Controle Interno o ponto será repassado, automaticamente, para o Órgão Subordinador.'>

			<cfset aux_posarea = rs14NR_2PU.Pos_Area>
			<cfset aux_posnomearea = rs14NR_2PU.Pos_NomeArea>
	
			<!--- Opiniao da CCOP --->
			<cfset Encaminhamento = "Opinião do Controle Interno">
			<cfset aux_obs = #rs14NR_2PU.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: ' & #rot3_DescStatus# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			<cfquery datasource="#dsn_inspecao#">
			UPDATE ParecerUnidade SET Pos_Area = '#aux_posarea#', Pos_NomeArea = '#aux_posnomearea#', Pos_Situacao_Resp = #rot3_IDStatus#, Pos_Situacao = '#rot3_SglStatus#', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dtatual#, Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 14 WHERE Pos_Unidade='#rs14NR_2PU.Pos_Unidade#' AND Pos_Inspecao='#rs14NR_2PU.Pos_Inspecao#' AND Pos_NumGrupo=#rs14NR_2PU.Pos_NumGrupo# AND Pos_NumItem=#rs14NR_2PU.Pos_NumItem#
			</cfquery>
			<cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: ' & #rot3_DescStatus# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
                <cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
                <cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
                <cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>	 
			<cfquery datasource="#dsn_inspecao#">
			insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs14NR_2PU.Pos_Inspecao#', '#rs14NR_2PU.Pos_Unidade#', #rs14NR_2PU.Pos_NumGrupo#, #rs14NR_2PU.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', #rot3_IDStatus#, '#hhmmssdc#', '#and_obs#', '#aux_posarea#')
			</cfquery>
		</cfoutput> 
    </cfif> 

	<!--- DE 15-TU - TRATAMENTO PARA 2-PU-PENDENTE OU 16-TS-Órgão SUBORDINADOR--->
	<!--- PROPRIAS --->
	<cfif rotina eq 4 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- Mudar de Status 15-TU para o Status 2-PU OU 16-TS --->
		<cfquery name="rs15TU_2PU16TS" datasource="#dsn_inspecao#">
		SELECT Und_Centraliza, Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Parecer, Und_Email, Und_TipoUnidade, Und_Descricao, Rep_Codigo, Rep_Nome
		FROM Unidades 
		INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
		INNER JOIN Reops ON Und_CodReop = Rep_Codigo
		WHERE (Pos_Situacao_Resp=15) and (Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00'))
		ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>
		<!--- Opiniao da CCOP --->
		<cfset Encaminhamento = "Opinião do Controle Interno">
		<cfset dtatual = CreateDate(year(now()),month(now()),day(now()))> 
		<cfoutput query="rs15TU_2PU16TS">
		    	
		    <!--- Pesquisa pelos 30 dias --->
			<!--- 	<cfobject component = "CFC/Dao" name = "dao"> --->
			<cfinvoke component="#dao#" method="VencidoPrazo_Andamento" returnVariable="PrazoVencidoDias"
			NumeroDaInspecao="#rs15TU_2PU16TS.Pos_Inspecao#" 
			CodigoDaUnidade="#rs15TU_2PU16TS.Pos_Unidade#" 
			Grupo="#rs15TU_2PU16TS.Pos_NumGrupo#" 
			Item="#rs15TU_2PU16TS.Pos_NumItem#" 
			ListaDeStatusContabilizados="14,2,15"
			Prazo = 30
			RetornaQuantDias="yes" 
			MostraDump="no"
			ApenasDiasUteis="yes"
			/>
		
		    <cfset auxQtdDias = 30 - '#PrazoVencidoDias#'>
	<!--- 		<cfset auxQtdDias = 0> --->
			<cfif auxQtdDias lte 0>
				<!--- MUDAR PARA Órgão SUBORDINADOR --->
				<cfquery name="rsOrg" datasource="#dsn_inspecao#">
				  SELECT Rep_Codigo, Rep_Nome, Und_Descricao 
				  FROM Reops INNER JOIN Unidades ON Rep_Codigo = Und_CodReop 
				  WHERE Und_Codigo = '#rs15TU_2PU16TS.Pos_Area#'
				</cfquery>
				
				<cfset sinformes = 'Em virtude da ausência de conclusão do Item da Avaliação no Status TRATAMENTO UNIDADE pelo(a) Gestor(a) da unidade: ' & #trim(rs15TU_2PU16TS.Und_Descricao)# & CHR(13) & ', no prazo solicitado até ' & #DateFormat(rs15TU_2PU16TS.Pos_DtPrev_Solucao,"DD/MM/YYYY")# & ', estamos modificando-o para o Status de TRATAMENTO ORGAO SUBORDINADOR e no aguardo do Aprimoramento para às devidas providências até ' & #DateFormat(dt10dduteis,"DD/MM/YYYY")# & '.'>
							 				
				<cfset aux_obs = #rs15TU_2PU16TS.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rsOrg.Rep_Nome# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: TRATAMENTO ORGAO SUBORDINADOR' & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dt10dduteis,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			  <cfquery datasource="#dsn_inspecao#">
			   UPDATE ParecerUnidade SET Pos_Situacao_Resp = 16, Pos_Situacao = 'TS', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dt10dduteis#, Pos_Area = '#rsOrg.Rep_Codigo#', Pos_NomeArea = '#rsOrg.Rep_Nome#', Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 15 WHERE Pos_Unidade='#rs15TU_2PU16TS.Pos_Unidade#' AND Pos_Inspecao='#rs15TU_2PU16TS.Pos_Inspecao#' AND Pos_NumGrupo=#rs15TU_2PU16TS.Pos_NumGrupo# AND Pos_NumItem=#rs15TU_2PU16TS.Pos_NumItem#
			 </cfquery>
			 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rsOrg.Rep_Nome# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: TRATAMENTO ORGAO SUBORDINADOR' & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dt10dduteis,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
                <cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
                <cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
                <cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>			 
			 <cfquery datasource="#dsn_inspecao#">
			   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs15TU_2PU16TS.Pos_Inspecao#', '#rs15TU_2PU16TS.Pos_Unidade#', #rs15TU_2PU16TS.Pos_NumGrupo#, #rs15TU_2PU16TS.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 16, '#hhmmssdc#', '#and_obs#', '#rsOrg.Rep_Codigo#')
			 </cfquery>				  		   
				  
		   <cfelse>
				   <!--- MUDAR PARA PENDENTE DE UNIDADE --->
				   <cfset sinformes = 'Em virtude da ausência de conclusão do Item da Avaliação no Status TRATAMENTO UNIDADE pelo(a) Gestor(a) desta unidade, no prazo solicitado até ' & #DateFormat(rs15TU_2PU16TS.Pos_DtPrev_Solucao,"DD/MM/YYYY")# & ', estamos modificando-o para o Status de PENDENTE DA UNIDADE e no aguardo do Aprimoramento para às devidas providências.'>
				  <cfset aux_obs = #rs15TU_2PU16TS.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rs15TU_2PU16TS.Pos_NomeArea# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: PENDENTE DA UNIDADE' & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			     <cfquery datasource="#dsn_inspecao#">
				   UPDATE ParecerUnidade SET Pos_Situacao_Resp = 2, Pos_Situacao = 'PU', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_Area = '#rs15TU_2PU16TS.Pos_Area#', Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dtatual#, Pos_NomeArea = '#trim(rs15TU_2PU16TS.Pos_NomeArea)#', Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 15
				   WHERE Pos_Unidade='#rs15TU_2PU16TS.Pos_Unidade#' AND Pos_Inspecao='#rs15TU_2PU16TS.Pos_Inspecao#' AND Pos_NumGrupo=#rs15TU_2PU16TS.Pos_NumGrupo# AND Pos_NumItem=#rs15TU_2PU16TS.Pos_NumItem#
				 </cfquery>	 
				<cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rs15TU_2PU16TS.Pos_NomeArea# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: PENDENTE DA UNIDADE' & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP'  & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>				 
                <cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
                <cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
                <cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>					
				<cfquery datasource="#dsn_inspecao#">
					insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs15TU_2PU16TS.Pos_Inspecao#', '#rs15TU_2PU16TS.Pos_Unidade#', #rs15TU_2PU16TS.Pos_NumGrupo#, #rs15TU_2PU16TS.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 2, '#hhmmssdc#', '#and_obs#', '#rs15TU_2PU16TS.Pos_Area#')
				</cfquery>				 	
		   </cfif>  
		</cfoutput> 
	</cfif>	
	<cfif rotina eq 5 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- Mudar o Status de 2-PU para 16-TS Tratamento Órgão subord --->
		   <cfquery name="rs2PU_16TS" datasource="#dsn_inspecao#">
			 SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Parecer, Und_TipoUnidade, Und_Descricao, Und_Centraliza, Pos_Area, Pos_NomeArea
			 FROM Unidades 
			 INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
			 WHERE (Pos_Situacao_Resp = 2) and (Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00'))
			 ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		   </cfquery>
		<!--- Opiniao da CCOP --->
		<cfset Encaminhamento = "Opinião do Controle Interno">
		<cfoutput query="rs2PU_16TS">
		    	
		    <!--- Pesquisa pelos 30 dias --->
			<!--- 	<cfobject component = "CFC/Dao" name = "dao"> --->
			<cfinvoke component="#dao#" method="VencidoPrazo_Andamento" returnVariable="PrazoVencidoDias"
			NumeroDaInspecao="#rs2PU_16TS.Pos_Inspecao#" 
			CodigoDaUnidade="#rs2PU_16TS.Pos_Unidade#" 
			Grupo="#rs2PU_16TS.Pos_NumGrupo#" 
			Item="#rs2PU_16TS.Pos_NumItem#" 
			ListaDeStatusContabilizados="14,2"
			Prazo = 30
			RetornaQuantDias="yes" 
			MostraDump="no"
			ApenasDiasUteis="yes"
			/>
		    <cfset auxQtdDias = 30 - '#PrazoVencidoDias#'>
			<cfif auxQtdDias lte 0>
				<!--- MUDAR PARA Órgão SUBORDINADOR --->
				<cfquery name="rsOrg" datasource="#dsn_inspecao#">
				  SELECT Rep_Codigo, Rep_Nome, Und_Descricao 
				  FROM Reops INNER JOIN Unidades ON Rep_Codigo = Und_CodReop 
				  WHERE Und_Codigo = '#rs2PU_16TS.Pos_Area#'
				</cfquery>
				  
				<cfset sinformes = 'Em virtude da ausência de conclusão do Item da Avaliação no Status PENDENTE DA UNIDADE pelo(a) Gestor(a) da unidade: ' & #trim(rs2PU_16TS.Und_Descricao)# & CHR(13) & ', no prazo solicitado, estamos modificando-o para o Status de TRATAMENTO ORGAO SUBORDINADOR e no aguardo do Aprimoramento para às devidas providências até ' & #DateFormat(dt10dduteis,"DD/MM/YYYY")# & '.'>
							 				
				<cfset aux_obs = #rs2PU_16TS.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rsOrg.Rep_Nome# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: TRATAMENTO ORGAO SUBORDINADOR' & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dt10dduteis,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			  <cfquery datasource="#dsn_inspecao#">
			   UPDATE ParecerUnidade SET Pos_Situacao_Resp = 16, Pos_Situacao = 'TS', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dt10dduteis#, Pos_Area = '#rsOrg.Rep_Codigo#', Pos_NomeArea = '#rsOrg.Rep_Nome#', Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 2 WHERE Pos_Unidade='#rs2PU_16TS.Pos_Unidade#' AND Pos_Inspecao='#rs2PU_16TS.Pos_Inspecao#' AND Pos_NumGrupo=#rs2PU_16TS.Pos_NumGrupo# AND Pos_NumItem=#rs2PU_16TS.Pos_NumItem#
			 </cfquery>
			 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rsOrg.Rep_Nome# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: TRATAMENTO ORGAO SUBORDINADOR' & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dt10dduteis,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
                <cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
                <cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
                <cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>		 
			 <cfquery datasource="#dsn_inspecao#">
			   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs2PU_16TS.Pos_Inspecao#', '#rs2PU_16TS.Pos_Unidade#', #rs2PU_16TS.Pos_NumGrupo#, #rs2PU_16TS.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 16, '#hhmmssdc#', '#and_obs#', '#rsOrg.Rep_Codigo#')
			 </cfquery>				  		   				 	
		   </cfif>  
		</cfoutput> 
	</cfif>	
	<!--- DE 14-NR para 20-PF-PENDENTE --->
	<!--- TERCEIRAS --->	
	<cfif rotina eq 6 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
	   <cfquery name="rs14NR_20PF" datasource="#dsn_inspecao#">
		SELECT INP_DTConcluirRevisao,Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Parecer, Und_Email, 
		Und_TipoUnidade, Und_Descricao, Und_Centraliza, Rep_Email
		FROM Unidades 
		INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
		INNER JOIN inspecao on INP_Unidade = Pos_Unidade and INP_NumInspecao = Pos_Inspecao
		INNER JOIN Reops ON Und_CodReop = Rep_Codigo
		WHERE Pos_Situacao_Resp in (14) and 
		Und_TipoUnidade in (12,16) and 
		(Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00'))
		ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
	   </cfquery>
	    <!--- Opiniao da CCOP --->
		<cfset Encaminhamento = "Opinião do Controle Interno">
		<cfoutput query="rs14NR_20PF">
			<cfset dt30terc = CreateDate(year(rs14NR_20PF.INP_DTConcluirRevisao),month(rs14NR_20PF.INP_DTConcluirRevisao),day(rs14NR_20PF.INP_DTConcluirRevisao))>
			<!--- complementar os 20 dias úteis da data de liberação para compor os 30  dias úteis--->
			<cfset dt30terc = CreateDate(year(dt30terc),month(dt30terc),day(dt30terc))>
			<cfset nCont = 1>
			<cfloop condition="nCont lte 30">
				<cfset dt30terc = DateAdd( "d", 1, dt30terc)>
				<cfset vDiaSem = DayOfWeek(dt30terc)>
				<cfif vDiaSem neq 1 and vDiaSem neq 7>
				<!--- verificar se Feriado Nacional --->
				<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
					SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dt30terc#
				</cfquery>
				<cfif rsFeriado.recordcount gt 0>
					<cfset nCont = nCont - 1>
				</cfif>
				</cfif>
				<!--- Verifica se final de semana  --->
				<cfif vDiaSem eq 1 or vDiaSem eq 7>
				<cfset nCont = nCont - 1>
				</cfif>
				<cfset nCont = nCont + 1>
			</cfloop> 	

			<cfset rot6_IDStatus = 20>
			<cfset rot6_SglStatus = 'PF'>
			<cfset rot6_DescStatus = 'PENDENTE DE TERCEIRIZADA'>
			<cfset sinformes = 'Em virtude da ausência de manifestação desse gestor, estamos transferindo a Situação encontrada para o Status ' & #rot6_DescStatus# & CHR(13) & ' Com cobranças diárias, por e-mail, até o registro de sua resposta no sistema.'   & CHR(13) & ' Após 30 dias úteis a contar na data do recebimento do Relatório de Controle Interno o ponto será repassado, automaticamente, para o Órgão Subordinador.'>

			<cfset aux_posarea = rs14NR_20PF.Pos_Area>
			<cfset aux_posnomearea = rs14NR_20PF.Pos_NomeArea>

			<!--- Opiniao da CCOP --->
			<cfset Encaminhamento = "Opinião do Controle Interno">
			<cfset aux_obs = #rs14NR_20PF.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Data Final da Solução: ' & #DateFormat(dt30terc,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & #rot6_DescStatus# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			<cfquery datasource="#dsn_inspecao#">
				UPDATE ParecerUnidade SET Pos_Area = '#aux_posarea#', Pos_NomeArea = '#aux_posnomearea#', Pos_Situacao_Resp = #rot6_IDStatus#, Pos_Situacao = '#rot6_SglStatus#', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dt30terc#, Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 14 WHERE Pos_Unidade='#rs14NR_20PF.Pos_Unidade#' AND Pos_Inspecao='#rs14NR_20PF.Pos_Inspecao#' AND Pos_NumGrupo=#rs14NR_20PF.Pos_NumGrupo# AND Pos_NumItem=#rs14NR_20PF.Pos_NumItem#
			</cfquery>
	
			<cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Data Final da Solução: ' & #DateFormat(dt30terc,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & #rot6_DescStatus# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
			<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
			<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>	 
	
			<cfquery datasource="#dsn_inspecao#">
				insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs14NR_20PF.Pos_Inspecao#', '#rs14NR_20PF.Pos_Unidade#', #rs14NR_20PF.Pos_NumGrupo#, #rs14NR_20PF.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', #rot6_IDStatus#, '#hhmmssdc#', '#and_obs#', '#aux_posarea#')
			</cfquery>		   
		</cfoutput> 
	</cfif>

	<!--- DE 18-TF ou 20-PF-PENDENTE para (26-NC GERAT OU GEOPE) --->
	<!--- TERCEIRAS --->	
	<cfif rotina eq 7 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
	   <cfquery name="rs18TF20PF_26NC" datasource="#dsn_inspecao#">
		 SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Parecer, Und_TipoUnidade, Und_Descricao, Und_Centraliza, Und_Email, Rep_Codigo, Rep_Nome, Rep_Email
		 FROM Unidades 
		 INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
		 INNER JOIN Reops ON Und_CodReop = Rep_Codigo
		 WHERE Pos_Situacao_Resp in (18,20) and 
		 Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00') AND Und_TipoUnidade in (12,16) 
		 ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
	   </cfquery>
	    <!--- Opiniao da CCOP --->
		<cfset Encaminhamento = "Opinião do Controle Interno">
		<cfoutput query="rs18TF20PF_26NC">
				<!--- MUDAR PARA ORGAO SUBORDINADOR (GEOPE OU GERAT) --->
				<!--- SE possuir GERAT ou apenas GEOPE --->
			   <cfquery name="rsGERAT" datasource="#dsn_inspecao#">
				SELECT Ars_Codigo, Ars_Descricao, Ars_Email
				FROM Areas 
				WHERE (left(Ars_Codigo,2) = '#left(rs18TF20PF_26NC.Pos_Area,2)#') AND (Ars_Descricao Like 'GER REG ATENDIMENTO%') and (Ars_Status = 'A') 
				ORDER BY Ars_Codigo
			  </cfquery>
			  <cfif rsGERAT.recordcount gt 0>
					<cfset rot7_posarea = rsGERAT.Ars_Codigo>
					<cfset rot7_posnomearea = rsGERAT.Ars_Descricao>
					<cfset rot7_sdestina = rsGERAT.Ars_Email>
			  <cfelse>
				  <cfquery name="rsGEOPE" datasource="#dsn_inspecao#">
					SELECT Ars_Codigo, Ars_Descricao, Ars_Email
				    FROM Areas 
					WHERE (left(Ars_Codigo,2) = '#left(rs18TF20PF_26NC.Pos_Area,2)#') AND (Ars_Descricao Like 'GER REG OPERACAO/GEOPE%') and (Ars_Status = 'A') 
					ORDER BY Ars_Codigo
				  </cfquery>
				  <cfif rsGEOPE.recordcount gt 0>
						<cfset rot7_posarea = rsGEOPE.Ars_Codigo>
						<cfset rot7_posnomearea = rsGEOPE.Ars_Descricao>
						<cfset rot7_sdestina = rsGEOPE.Ars_Email>
				  </cfif>
			  </cfif>
				<cfset sinformes = 'Em virtude da ausência de conclusão do Item da Avaliação pelo(a) Gestor(a) da unidade: ' & #trim(rs18TF20PF_26NC.Und_Descricao)# & CHR(13) & ', no prazo solicitado até ' & #DateFormat(rs18TF20PF_26NC.Pos_DtPrev_Solucao,"DD/MM/YYYY")# & ', estamos modificando para o Status de NÃO REGULARIZADO - APLICAR O CONTRATO e no aguardo do Aprimoramento para às devidas providências.'>
						 				
				<cfset aux_obs = #rs18TF20PF_26NC.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rot7_posnomearea# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: NÃO REGULARIZADO - APLICAR O CONTRATO' & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			  <cfquery datasource="#dsn_inspecao#">
			   UPDATE ParecerUnidade SET Pos_Situacao_Resp = 26, Pos_Situacao = 'NC', Pos_DtUltAtu = CONVERT(varchar, GETDATE(), 120), Pos_DtPosic = #dtatual#, Pos_Area = '#rot7_posarea#', Pos_NomeArea = '#rot7_posnomearea#', Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 18 WHERE Pos_Unidade='#rs18TF20PF_26NC.Pos_Unidade#' AND Pos_Inspecao='#rs18TF20PF_26NC.Pos_Inspecao#' AND Pos_NumGrupo=#rs18TF20PF_26NC.Pos_NumGrupo# AND Pos_NumItem=#rs18TF20PF_26NC.Pos_NumItem#
			 </cfquery>
			 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rot7_posnomearea# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: NÃO REGULARIZADO - APLICAR O CONTRATO' & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
			<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
			<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>				 
			 <cfquery datasource="#dsn_inspecao#">
			   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs18TF20PF_26NC.Pos_Inspecao#', '#rs18TF20PF_26NC.Pos_Unidade#', #rs18TF20PF_26NC.Pos_NumGrupo#, #rs18TF20PF_26NC.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 26, '#hhmmssdc#', '#and_obs#', '#rot7_posarea#')
			 </cfquery>			
		 	  		   
		</cfoutput> 
	</cfif>
	<cfif rotina eq 8 and rotinaSN is 'S'>
	</cfif>
	<!--- ###### FIM UNIDADES ###### --->
	<!--- ###### SUBORDINADORES ###### --->
	<cfif rotina eq 9 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- ==================================== --->
		<!--- mudar status 16-TS para 4-PO quando estiverem com a Pos_DtPrev_Solucao vencida nos 10 dias corridos oferecidos anteriormente --->
		<cfquery name="rs16TS4PO" datasource="#dsn_inspecao#">
		  SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, Rep_Codigo, Rep_Nome
		  FROM Unidades 
		  INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
		  INNER JOIN Reops ON Pos_Area = Rep_Codigo
		  WHERE (Pos_Situacao_Resp=16) and 
		  (Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) 
		  ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>
		<cfoutput query="rs16TS4PO">
			<!--- Opiniao da CCOP --->
		 <cfset Encaminhamento = "Opinião do Controle Interno">
		 <cfset sinformes = "Em virtude da ausência de manifestação e/ou solução deste Órgão, automaticamente o sistema modifica seu Status para Pendente Órgão Subordinador e no aguardo do Aprimoramento para às devidas providências.">
			 <cfset aux_obs = #rs16TS4PO.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(rs16TS4PO.Pos_NomeArea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: PENDENTE DO ORGAO SUBORDINADOR' & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			 <cfquery datasource="#dsn_inspecao#">
			   UPDATE ParecerUnidade SET Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dtatual#, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_Situacao_Resp = 4, Pos_Situacao = 'PO', Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 16 WHERE Pos_Unidade='#rs16TS4PO.Pos_Unidade#' AND Pos_Inspecao='#rs16TS4PO.Pos_Inspecao#' AND Pos_NumGrupo=#rs16TS4PO.Pos_NumGrupo# AND Pos_NumItem=#rs16TS4PO.Pos_NumItem#
			 </cfquery>
			 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(rs16TS4PO.Pos_NomeArea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: PENDENTE DO ORGAO SUBORDINADOR' & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
			<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
			<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>		 
			 <cfquery datasource="#dsn_inspecao#">
			   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs16TS4PO.Pos_Inspecao#', '#rs16TS4PO.Pos_Unidade#', '#rs16TS4PO.Pos_NumGrupo#', '#rs16TS4PO.Pos_NumItem#', convert(char, getdate(), 102), 'Rotina_Automatica', 4, '#hhmmssdc#', '#and_obs#', '#rs16TS4PO.Pos_Area#')
			 </cfquery>
		</cfoutput> 
	</cfif>
	<!--- ###### FIM SUBORDINADORES ###### --->	
	<!--- ###### AREAS ###### --->
	<cfif rotina eq 10 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!---aptos a mudar de status de 19, quando data Pos_DtPrev_Solucao estiver vencida para status = 5 - PA - PENDENTE DE ÁREA --->
		<cfquery name="rs19TA5PA" datasource="#dsn_inspecao#">
		  SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Area, Pos_NomeArea, Pos_Parecer 
		  FROM ParecerUnidade 
		  WHERE (Pos_Situacao_Resp=19) and (Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) 
		  ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>
	<cfoutput query="rs19TA5PA">
		<!--- Opiniao da CCOP --->
		<cfset sinformes = "Em virtude da ausência de conclusão do Item da Avaliação no status em Tratamento de Área por este Órgão: " & #trim(rs19TA5PA.Pos_NomeArea)# & CHR(13) & " no prazo solicitado, estamos modificando-o para o Status de PENDENTE DE AREA e no aguardo do Aprimoramento para às devidas providências.">
		<cfset Encaminhamento = "Opinião do Controle Interno">
		<cfset aux_obs = #rs19TA5PA.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(rs19TA5PA.Pos_NomeArea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: PENDENTE DE AREA' & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
		 <cfquery datasource="#dsn_inspecao#">
		   UPDATE ParecerUnidade SET Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dtatual#, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_Situacao_Resp = 5, Pos_Situacao = 'PA', Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 19 WHERE Pos_Unidade='#rs19TA5PA.Pos_Unidade#' AND Pos_Inspecao='#rs19TA5PA.Pos_Inspecao#' AND Pos_NumGrupo=#rs19TA5PA.Pos_NumGrupo# AND Pos_NumItem=#rs19TA5PA.Pos_NumItem#
		 </cfquery>
		 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(rs19TA5PA.Pos_NomeArea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: PENDENTE DE AREA' & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
		<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
		<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
		<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>			 
		 <cfquery datasource="#dsn_inspecao#">
		  insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs19TA5PA.Pos_Inspecao#', '#rs19TA5PA.Pos_Unidade#', #rs19TA5PA.Pos_NumGrupo#, #rs19TA5PA.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 5, '#hhmmssdc#', '#and_obs#', '#rs19TA5PA.Pos_Area#')
		 </cfquery>	 
	</cfoutput> 
	</cfif>
	<!--- ###### FIM - AREAS ###### --->
	<!--- ###### SUPERINTENDENTE ###### --->
<cfif rotina eq 11 and rotinaSN is 'S'>
	<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
	<!--- Mudar o Status de 23-TO Tratamento Superintendencia para 8-SE Pendente Superintendencia  --->
	 <cfquery name="rs23TO8SE" datasource="#dsn_inspecao#">
		SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Parecer, Pos_Area, Pos_NomeArea 
		FROM ParecerUnidade 
		WHERE (Pos_Situacao_Resp=23) and (Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) 
		ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
	 </cfquery>
	 <cfoutput query="rs23TO8SE">
		<!--- Opiniao da CCOP --->
		<cfset sinformes = "Em virtude da ausência de conclusão do Item da Avaliação no Status Em Tratamento Superintendência desta : " & #trim(rs23TO8SE.Pos_NomeArea)# & CHR(13) & " no prazo solicitado, estamos modificando-o para o status de PENDENTE SUPERINTENDÊNCIA e no aguardo do Aprimoramento para às devidas providências.">
		<cfset Encaminhamento = "Opinião do Controle Interno">
		<cfset aux_obs = #rs23TO8SE.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À ' & #trim(rs23TO8SE.Pos_NomeArea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: PENDENTE SUPERINTENDENCIA' & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
		<cfquery datasource="#dsn_inspecao#">
		  UPDATE ParecerUnidade SET Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dtatual#, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_Situacao_Resp = 8, Pos_Situacao = 'SE', Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 23 WHERE Pos_Unidade='#rs23TO8SE.Pos_Unidade#' AND Pos_Inspecao='#rs23TO8SE.Pos_Inspecao#' AND Pos_NumGrupo=#rs23TO8SE.Pos_NumGrupo# AND Pos_NumItem=#rs23TO8SE.Pos_NumItem#
		</cfquery>
		<cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À ' & #trim(rs23TO8SE.Pos_NomeArea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: PENDENTE SUPERINTENDENCIA' & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
			<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
			<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>		
		<cfquery datasource="#dsn_inspecao#">
		   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs23TO8SE.Pos_Inspecao#', '#rs23TO8SE.Pos_Unidade#', #rs23TO8SE.Pos_NumGrupo#, #rs23TO8SE.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 8, '#hhmmssdc#', '#and_obs#', '#rs23TO8SE.Pos_Area#')
		</cfquery>
	</cfoutput> 
	</cfif>	
	<!--- ###### FIM - SUPERINTENDENTE ###### --->
	<!--- ************** FIM - MUDAR STATUS ****************** --->
	<!--- ************** PRÉ- ALERTA (DIÁRIOS)****************** --->
	<!--- ###### UNIDADES ###### --->
	<cfif rotina eq 12 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- E-mail agrupado para os Status 14-NR QUANDO FALTAR DE 5 A 0 DIAS DO VENCTO da Pos_DtPrev_Solucao para PROPRIAS  --->
		<cfquery name="rs14NRpro" datasource="#dsn_inspecao#">
			SELECT Pos_Inspecao
		    FROM Unidades INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade  
		    WHERE (Pos_DtPrev_Solucao >= convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
		   (Pos_Situacao_Resp=14) and (DATEDIFF(d,GETDATE(),Pos_DtPrev_Solucao) <= 4) and (Und_TipoUnidade not in(12,16))
		   GROUP BY Pos_Inspecao
		   order by Pos_Inspecao
		</cfquery>
  
		<cfoutput query="rs14NRpro">
			<cfquery name="rs14NR" datasource="#dsn_inspecao#">
		       SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Und_Email, Und_Descricao, Und_Centraliza
			   FROM Unidades 
			   INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
			   WHERE (Pos_DtPrev_Solucao >= convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
			   (Pos_Situacao_Resp=14) and (DATEDIFF(d,GETDATE(),Pos_DtPrev_Solucao) <= 4) AND Pos_Inspecao = '#rs14NRpro.Pos_Inspecao#'
			   ORDER BY Und_CodDiretoria, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
			</cfquery>		

			<cfset rot12_sdestina = rs14NR.Und_Email>
			<cfif findoneof("@", #trim(rot12_sdestina)#) eq 0>
			 <cfset rot12_sdestina = "gilvanm@correios.com.br">
			</cfif>

			<cfif rs14NR.recordcount gt 0>
		  	<cfmail from="SNCI@correios.com.br" to="#rot12_sdestina#" subject="Avaliação - NÃO RESPONDIDO" type="HTML">
			 Mensagem automática. Não precisa responder!<br><br>
			<strong>
			   Ao Gestor(a) do(a) #Ucase(rs14NR.Und_Descricao)#. <br><br><br>
	
	&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  "NÃO RESPONDIDO"  para  manifestação desse Órgão.<br><br>
	
	&nbsp;&nbsp;&nbsp;Assim, solicitamos registrar, por  meio do preenchimento do campo "Manifestar-se" no Sistema SNCI, as suas manifestações acerca das inconsistências registradas no prazo solicitado.<br><br>
	
	&nbsp;&nbsp;&nbsp;Para registro de suas manifestações acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Sistema Nacional de Controle Interno - SNCI</a><br><br>
				<table>
				<tr>
				<td><strong>Unidade</strong></td>
				<td><strong>Avaliação</strong></td>
				<td><strong>Grupo</strong></td>
				<td><strong>Item</strong></td>
				<td><strong>Dt.Posição</strong></td>
				<td><strong>Dt.Previsão Solução</strong></td>
				</tr>
				<tr>
				<td>-----------------------------------------</td>
				<td>----------------</td>
				<td>--------</td>
				<td>------</td>
				<td>----------------</td>
				<td>----------------</td>
				</tr>
				<cfloop query="rs14NR">
					<tr>
					<td><strong>#trim(rs14NR.Und_Descricao)#</strong></td>
					<td align="center"><strong>#rs14NR.Pos_Inspecao#</strong></td>
					<td align="center"><strong>#rs14NR.Pos_NumGrupo#</strong></td>
					<td align="center"><strong>#rs14NR.Pos_NumItem#</strong></td>
					<td align="center"><strong>#dateformat(rs14NR.Pos_DtPosic,"DD/MM/YYYY")#</strong></td>
					<td align="center"><strong>#dateformat(rs14NR.Pos_DtPrev_Solucao,"DD/MM/YYYY")#</strong></td>
					
					</tr>
 		        </cfloop>
				</table>
				<br>
	&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
	
			</strong>
		 </cfmail>
		</cfif>		 
	  </cfoutput> 
	<!--- fim e-mail status 14-NR --->
	</cfif> 

	<cfif rotina eq 13 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- E-mail agrupado para os Status 14-NR QUANDO FALTAR DE 5 A 0 DIAS DO VENCTO da Pos_DtPrev_Solucao para franquias  --->
		<cfquery name="rs14NRfra" datasource="#dsn_inspecao#">
			SELECT Pos_Inspecao
		    FROM Unidades INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade  
		    WHERE (Pos_Situacao_Resp=14) and (Und_TipoUnidade in(12,16))
		   GROUP BY Pos_Inspecao
		   order by Pos_Inspecao
		</cfquery>
  
		<cfoutput query="rs14NRfra">
			<cfquery name="rs14NR" datasource="#dsn_inspecao#">
		       SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Und_Email, Und_Descricao, Und_Centraliza
			   FROM Unidades 
			   INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
			   WHERE Pos_Inspecao = '#rs14NRfra.Pos_Inspecao#'
			   ORDER BY Und_CodDiretoria, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
			</cfquery>		

			<cfset rot13_sdestina = rs14NR.Und_Email>
			<cfif findoneof("@", #trim(rot13_sdestina)#) eq 0>
			 <cfset rot13_sdestina = "gilvanm@correios.com.br">
			</cfif>

			<cfif rs14NR.recordcount gt 0>
		  	<cfmail from="SNCI@correios.com.br" to="#rot13_sdestina#" subject="Avaliação - NÃO RESPONDIDO" type="HTML">
			 Mensagem automática. Não precisa responder!<br><br>
			<strong>
			   Ao Gestor(a) do(a) #Ucase(rs14NR.Und_Descricao)#. <br><br><br>
	
	&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  "NÃO RESPONDIDO"  para  manifestação desse Órgão.<br><br>
	
	&nbsp;&nbsp;&nbsp;Assim, solicitamos registrar, por  meio do preenchimento do campo "Manifestar-se" no Sistema SNCI, as suas manifestações acerca das inconsistências registradas no prazo solicitado.<br><br>
	
	&nbsp;&nbsp;&nbsp;Para registro de suas manifestações acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Sistema Nacional de Controle Interno - SNCI</a><br><br>
				<table>
				<tr>
					<td><strong>Unidade</strong></td>
					<td><strong>Avaliação</strong></td>
					<td><strong>Grupo</strong></td>
					<td><strong>Item</strong></td>
					<td><strong>Dt.Posição</strong></td>
					<td><strong>Dt.Previsão Solução</strong></td>
				</tr>
				<tr>
				<td>-----------------------------------------</td>
				<td>----------------</td>
				<td>--------</td>
				<td>------</td>
				<td>----------------</td>
				<td>----------------</td>
				</tr>
				<cfloop query="rs14NR">
					<tr>
						<td><strong>#trim(rs14NR.Und_Descricao)#</strong></td>
						<td align="center"><strong>#rs14NR.Pos_Inspecao#</strong></td>
						<td align="center"><strong>#rs14NR.Pos_NumGrupo#</strong></td>
						<td align="center"><strong>#rs14NR.Pos_NumItem#</strong></td>
						<td align="center"><strong>#dateformat(rs14NR.Pos_DtPosic,"DD/MM/YYYY")#</strong></td>
						<td align="center"><strong>#dateformat(rs14NR.Pos_DtPrev_Solucao,"DD/MM/YYYY")#</strong></td>
					</tr>
 		        </cfloop>
				</table>
				<br>
	&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
	
			</strong>
		 </cfmail>
		</cfif>		 
	  </cfoutput> 
	<!--- fim e-mail status 14-NR --->
	</cfif> 

	<cfif rotina eq 14 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- Pré-alerta por e-mail para Unidade para os status = (15-TU) e que a data Pos_DtPrev_Solucao esteja apenas a 5(cinco) dias do vencimento --->
		<cfquery name="rs15TUGRP" datasource="#dsn_inspecao#">
			SELECT Pos_Inspecao
		    FROM ParecerUnidade 
		    WHERE (Pos_DtPrev_Solucao >= convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
			(Pos_Situacao_Resp=15) and (DATEDIFF(d,GETDATE(),Pos_DtPrev_Solucao) <= 4) 
		   GROUP BY Pos_Inspecao
		   order by Pos_Inspecao
		</cfquery>
	
	 	<cfoutput query="rs15TUGRP">
			<cfquery name="rs15TU" datasource="#dsn_inspecao#">
				SELECT Und_Centraliza, Pos_Area, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Und_Email, Und_TipoUnidade, Und_Descricao
				FROM Unidades 
				INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
				where (Pos_Situacao_Resp=15) and (Pos_DtPrev_Solucao > convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
				(DATEDIFF(d,GETDATE(), Pos_DtPrev_Solucao) <= 4) AND 
				Pos_Inspecao = '#rs15TUGRP.Pos_Inspecao#'
				ORDER BY Und_CodDiretoria, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
			</cfquery>
		    <cfset rot14_sdestina = rs15TU.Und_Email>
			<cfif findoneof("@", #trim(rot14_sdestina)#) eq 0>
				 <cfset rot14_sdestina = "gilvanm@correios.com.br">
			</cfif>
	   <cfif rs15TU.recordcount gt 0>
	   <cfmail from="SNCI@correios.com.br" to="#rot14_sdestina#" subject="Avaliação TRATAMENTO UNIDADE" type="HTML">
			 Mensagem automática. Não precisa responder!<br><br>
			<strong>
			   Ao Gestor(a) do(a) #Ucase(rs15TU.Und_Descricao)#. <br><br><br>
	
	&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno em TRATAMENTO UNIDADE para  manifestação desse Órgão.<br><br>
	
	&nbsp;&nbsp;&nbsp;Assim, solicitamos registrar, por  meio do preenchimento do campo "Manifestar-se" no Sistema SNCI, as suas manifestações acerca das inconsistências registradas.<br><br>
	
	&nbsp;&nbsp;&nbsp;Para registro de suas manifestações acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Sistema Nacional de Controle Interno - SNCI</a><br><br>
	<table>
				<tr>
				<td><strong>Unidade</strong></td>
				<td><strong>Avaliação</strong></td>
				<td><strong>Grupo</strong></td>
				<td><strong>Item</strong></td>
				<td><strong>Dt.Posição</strong></td>
				<td><strong>Dt.Previsão Solução</strong></td>
				</tr>
				<tr>
				<td>-----------------------------------------</td>
				<td>----------------</td>
				<td>--------</td>
				<td>------</td>
				<td>----------------</td>
				<td>----------------</td>
				</tr>
				<cfloop query="rs15TU">
					<tr>
					<td><strong>#TRIM(rs15TU.Und_Descricao)#</strong></td>
					<td align="center"><strong>#rs15TU.Pos_Inspecao#</strong></td>
					<td align="center"><strong>#rs15TU.Pos_NumGrupo#</strong></td>
					<td align="center"><strong>#rs15TU.Pos_NumItem#</strong></td>
					<td align="center"><strong>#dateformat(rs15TU.Pos_DtPosic,"DD/MM/YYYY")#</strong></td>
					<td align="center"><strong>#dateformat(rs15TU.Pos_DtPrev_Solucao,"DD/MM/YYYY")#</strong></td>
					</tr>
 		        </cfloop>
				</table>
				<br>
	&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.	
	
			</strong>
	   </cfmail>  
	   	   </cfif>

	</cfoutput> 
	</cfif>
	<cfif rotina eq 15 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput>
		<!--- Pré-alerta por e-mail para Unidade para os status = (18-TF) e que a data Pos_DtPrev_Solucao esteja apenas a 5(cinco) dias do vencimento --->
		<cfquery name="rs18TFGRP" datasource="#dsn_inspecao#">
			SELECT Pos_Inspecao
		    FROM ParecerUnidade 
		    WHERE (Pos_DtPrev_Solucao >= convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
			(Pos_Situacao_Resp=18) and (DATEDIFF(d,GETDATE(),Pos_DtPrev_Solucao) <= 4) 
		   GROUP BY Pos_Inspecao
		   order by Pos_Inspecao
		</cfquery>
	
	 	<cfoutput query="rs18TFGRP">
			<cfquery name="rs18TF" datasource="#dsn_inspecao#">
				SELECT Und_Centraliza, Pos_Area, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Und_Email, Und_TipoUnidade, Und_Descricao
				FROM Unidades 
				INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
				where (Pos_Situacao_Resp=18) and (Pos_DtPrev_Solucao > convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
				(DATEDIFF(d,GETDATE(), Pos_DtPrev_Solucao) <= 4) AND 
				Pos_Inspecao = '#rs18TFGRP.Pos_Inspecao#'
				ORDER BY Und_CodDiretoria, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
			</cfquery>
		    <cfset rot15_sdestina = rs18TF.Und_Email>
			<cfif findoneof("@", #trim(rot15_sdestina)#) eq 0>
				 <cfset rot15_sdestina = "gilvanm@correios.com.br">
			</cfif>

	   <cfif rs18TF.recordcount gt 0>
	   
	   <cfmail from="SNCI@correios.com.br" to="#rot15_sdestina#" subject="Avaliação TRATAMENTO TERCEIRIZADA" type="HTML">
			 Mensagem automática. Não precisa responder!<br><br>
			<strong>
			   Ao Gestor(a) do(a) #Ucase(rs18TF.Und_Descricao)#. <br><br><br>
	
	&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno em TRATAMENTO TERCEIRIZADA para  manifestação desse Órgão.<br><br>
	
	&nbsp;&nbsp;&nbsp;Assim, solicitamos registrar, por  meio do preenchimento do campo "Manifestar-se" no Sistema SNCI, as suas manifestações acerca das inconsistências registradas.<br><br>
	
	&nbsp;&nbsp;&nbsp;Para registro de suas manifestações acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Sistema Nacional de Controle Interno - SNCI</a><br><br>
	<table>
				<tr>
				<td><strong>Unidade</strong></td>
				<td><strong>Avaliação</strong></td>
				<td><strong>Grupo</strong></td>
				<td><strong>Item</strong></td>
				<td><strong>Dt.Posição</strong></td>
				<td><strong>Dt.Previsão Solução</strong></td>
				</tr>
				<tr>
				<td>-----------------------------------------</td>
				<td>----------------</td>
				<td>--------</td>
				<td>------</td>
				<td>----------------</td>
				<td>----------------</td>
				</tr>
				<cfloop query="rs18TF">
					<tr>
					<td><strong>#TRIM(rs18TF.Und_Descricao)#</strong></td>
					<td align="center"><strong>#rs18TF.Pos_Inspecao#</strong></td>
					<td align="center"><strong>#rs18TF.Pos_NumGrupo#</strong></td>
					<td align="center"><strong>#rs18TF.Pos_NumItem#</strong></td>
					<td align="center"><strong>#dateformat(rs18TF.Pos_DtPosic,"DD/MM/YYYY")#</strong></td>
					<td align="center"><strong>#dateformat(rs18TF.Pos_DtPrev_Solucao,"DD/MM/YYYY")#</strong></td>
					</tr>
 		        </cfloop>
				</table>
				<br>
	&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
	
			</strong>
	   </cfmail>
	   </cfif>  
	</cfoutput> 
	</cfif>	
	<!--- ###### FIM - UNIDADES ###### --->
	<!--- ###### SUBORDINADORES ###### --->
<cfif rotina eq 16 and rotinaSN is 'S'>
			<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
	  <!--- pré-alerta Orgao subordinador com e-mail agrupado e classif. (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem) --->
	 <!--- status 16 e data Pos_DtPrev_Solucao ESTÁ DE 0 A 5 DIAS DO VENCTO --->
	  <cfquery name="rs16TSGRP" datasource="#dsn_inspecao#">
			SELECT distinct Rep_Codigo, Rep_Nome, Rep_Email 
			FROM Reops INNER JOIN ParecerUnidade ON Rep_Codigo = Pos_Area 
			WHERE Pos_Situacao_Resp = 16  and (Pos_DtPrev_Solucao > convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
			(DATEDIFF(d,GETDATE(),Pos_DtPrev_Solucao) <= 4)
			ORDER BY Rep_Codigo
	  </cfquery>
	
	  <cfoutput query="rs16TSGRP">
 			<cfquery name="rs16TS" datasource="#dsn_inspecao#">
				SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, Und_Descricao
				FROM Unidades 
				INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
				WHERE (Pos_Area = '#rs16TSGRP.Rep_Codigo#') and Pos_Situacao_Resp=16 and 
				(Pos_DtPrev_Solucao > convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) And 
				(DATEDIFF(d,GETDATE(), Pos_DtPrev_Solucao) <= 4) 
				ORDER BY Und_CodDiretoria, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
			</cfquery>	 
			<cfif rs16TS.recordcount gt 0>
             	<cfset rot16_sdestina = rs16TSGRP.Rep_Email>
				<cfif findoneof("@", #trim(rot16_sdestina)#) eq 0>
					 <cfset rot16_sdestina = "gilvanm@correios.com.br">
				</cfif>

				 <cfmail from="SNCI@correios.com.br" to="#rot16_sdestina#" subject="Avaliação TRATAMENTO ÓRGÃO SUBORDINADOR" type="HTML">
					 Mensagem automática. Não precisa responder!<br><br>
					<strong>
					   Ao Gestor(a) do(a) #Ucase(rs16TSGRP.Rep_Nome)#. <br><br><br>
			
			&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  em TRATAMENTO ÓRGÃO SUBORDINADOR para  manifestação  desse Órgão.<br><br>
			
			&nbsp;&nbsp;&nbsp;Assim, solicitamos registrar, por  meio do preenchimento do campo "Manifestar-se" no Sistema SNCI, as suas manifestações acerca das inconsistências registradas.<br><br>
			
			&nbsp;&nbsp;&nbsp;Para registro de suas manifestações acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Sistema Nacional de Controle Interno - SNCI</a><br><br>
			<table>
				<tr>
				<td><strong>Unidade</strong></td>
				<td><strong>Avaliação</strong></td>
				<td><strong>Grupo</strong></td>
				<td><strong>Item</strong></td>
				<td><strong>Dt.Posição</strong></td>
				<td><strong>Dt.Previsão Solução</strong></td>
				</tr>
				<tr>
				<td>-----------------------------------------</td>
				<td>----------------</td>
				<td>--------</td>
				<td>------</td>
				<td>----------------</td>
				<td>----------------</td>
				</tr>

				<cfloop query="rs16TS">
				<tr>
				<td><strong>#rs16TS.Und_Descricao#</strong></td>
				<td align="center"><strong>#rs16TS.Pos_Inspecao#</strong></td>
				<td align="center"><strong>#rs16TS.Pos_NumGrupo#</strong></td>
				<td align="center"><strong>#rs16TS.Pos_NumItem#</strong></td>
				<td align="center"><strong>#dateformat(rs16TS.Pos_DtPosic,"DD/MM/YYYY")#</strong></td>
				<td align="center"><strong>#dateformat(rs16TS.Pos_DtPrev_Solucao,"DD/MM/YYYY")#</strong></td>
				</tr>
				</cfloop>
				</table>
			<br>
			&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
			</strong>
			</cfmail>
		</cfif>  			
	</cfoutput> 
	 <!--- Fim da rotina de Pré-Alerta --->
	</cfif>	
	<!--- ###### FIM - SUBORDINADORES ###### --->
	<!--- ###### AREAS ###### --->
<cfif rotina eq 17 and rotinaSN is 'S'>
	    <cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
        <!--- pré-alerta Área com e-mail agrupado e classif. (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem) --->
	    <!--- status 19 e data Pos_DtPrev_Solucao ESTÁ DE 0 A 5 DIAS DO VENCTO --->
	   <cfquery name="rs19TAGRP" datasource="#dsn_inspecao#">
		     SELECT distinct Ars_Codigo, Ars_Descricao, Ars_Email 
			 FROM Areas INNER JOIN ParecerUnidade ON Ars_Codigo = Pos_Area 
			 WHERE Pos_Situacao_Resp = 19  and (Pos_DtPrev_Solucao > convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
			(DATEDIFF(d,GETDATE(),Pos_DtPrev_Solucao) <= 4)
			ORDER BY Ars_Codigo
	  </cfquery>
	
	  <cfoutput query="rs19TAGRP">
		   <cfquery name="rs19TA" datasource="#dsn_inspecao#">
			SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, Und_Email, Und_Descricao 
			FROM Unidades 
			INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
			WHERE (Pos_Area = '#rs19TAGRP.Ars_Codigo#') and 
			Pos_Situacao_Resp = 19 and 
			(Pos_DtPrev_Solucao > convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
			(DATEDIFF(d,GETDATE(),Pos_DtPrev_Solucao) <= 4) 
			ORDER BY Und_CodDiretoria, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		   </cfquery>

		  <cfset sdestina = "">
		  <cfif rs19TA.recordcount gt 0>
			 <cfset rot17_sdestina = rs19TAGRP.Ars_Email>
				<cfif findoneof("@", #trim(rot17_sdestina)#) eq 0>
					 <cfset rot17_sdestina = "gilvanm@correios.com.br">
				</cfif>

			  <cfmail from="SNCI@correios.com.br" to="#rot17_sdestina#" subject="Avaliação TRATAMENTO DA ÁREA" type="HTML">
				 Mensagem automática. Não precisa responder!<br><br>
				<strong>
				   Ao Gestor(a) do(a) #Ucase(rs19TAGRP.Ars_Descricao)#. <br><br><br>
		
		&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  em TRATAMENTO DA ÁREA para  manifestação  desse Órgão.<br><br>
		
		&nbsp;&nbsp;&nbsp;Assim, solicitamos registrar, por  meio do preenchimento do campo "Manifestar-se" no Sistema SNCI, as suas manifestações acerca das inconsistências registradas.<br><br>
		
		&nbsp;&nbsp;&nbsp;Para registro de suas manifestações acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Sistema Nacional de Controle Interno - SNCI</a><br><br>
				<table>
				<tr>
				<td><strong>Unidade</strong></td>
				<td><strong>Avaliação</strong></td>
				<td><strong>Grupo</strong></td>
				<td><strong>Item</strong></td>
				<td><strong>Dt.Posição</strong></td>
				<td><strong>Dt.Previsão Solução</strong></td>
				</tr>
				<tr>
				<td>-----------------------------------------</td>
				<td>----------------</td>
				<td>--------</td>
				<td>------</td>
				<td>----------------</td>
				<td>----------------</td>
				</tr>
				<cfloop query="rs19TA">
				<tr>
				<td align="left"><strong>#rs19TA.Und_Descricao#</strong></td>
				<td align="center"><strong>#rs19TA.Pos_Inspecao#</strong></td>
				<td align="center"><strong>#rs19TA.Pos_NumGrupo#</strong></td>
				<td align="center"><strong>#rs19TA.Pos_NumItem#</strong></td>
				<td align="center"><strong>#dateformat(rs19TA.Pos_DtPosic,"DD/MM/YYYY")#</strong></td>
				<td align="center"><strong>#dateformat(rs19TA.Pos_DtPrev_Solucao,"DD/MM/YYYY")#</strong></td>
				</tr>
				</cfloop>
				</table>
				<br>
				&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
				</strong>
			</cfmail>
		  </cfif>
	<!--- fim e-mail para status = 19 --->
	</cfoutput> 
	</cfif>	
	<!--- ###### FIM - AREAS ###### --->
	<!--- ###### SUPERINTENDENTE ###### --->
<cfif rotina eq 18 and rotinaSN is 'S'>
	    <cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
        <!--- pré-alerta Área com e-mail agrupado e classif. (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem) --->
	    <!--- status 23 e data Pos_DtPrev_Solucao ESTÁ DE 0 A 5 DIAS DO VENCTO --->
	   <cfquery name="rs23TOGRP" datasource="#dsn_inspecao#">
		     SELECT distinct Dir_Sto, Dir_Codigo, Dir_Sigla, Dir_Descricao, Dir_Email  
			 FROM Diretoria INNER JOIN ParecerUnidade ON Dir_Sto = Pos_Area 
			 WHERE Pos_Situacao_Resp = 23  and (Pos_DtPrev_Solucao > convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
			(DATEDIFF(d,GETDATE(),Pos_DtPrev_Solucao) <= 4)
			ORDER BY Dir_Codigo
	  </cfquery>
	
	  <cfoutput query="rs23TOGRP">
		   <cfquery name="rs23TO" datasource="#dsn_inspecao#">
			SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, Und_Email, Und_Descricao 
			FROM Unidades 
			INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
			WHERE (Pos_Area = '#rs23TOGRP.Dir_Sto#') and 
			Pos_Situacao_Resp = 23 and 
			(Pos_DtPrev_Solucao > convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
			(DATEDIFF(d,GETDATE(),Pos_DtPrev_Solucao) <= 4) 
			ORDER BY Und_CodDiretoria, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		   </cfquery>

		  <cfset sdestina = "">
		  <cfif rs23TO.recordcount gt 0>
			 	<cfset rot18_sdestina = rs23TOGRP.Dir_Email>
				
				<cfif findoneof("@", #trim(rot18_sdestina)#) eq 0>
					 <cfset rot18_sdestina = "gilvanm@correios.com.br">
				</cfif>

			  <cfmail from="SNCI@correios.com.br" to="#rot18_sdestina#" subject="Avaliação TRATAMENTO SE" type="HTML">
				 Mensagem automática. Não precisa responder!<br><br>
				<strong>
				   Ao Gestor(a) do(a) #Ucase(rs23TOGRP.Dir_Descricao)#. <br><br><br>
		
		&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  em TRATAMENTO SUPERINTENDÊNCIA ESTADUAL para  manifestação  desse Órgão.<br><br>
		
		&nbsp;&nbsp;&nbsp;Assim, solicitamos registrar, por  meio do preenchimento do campo "Manifestar-se" no Sistema SNCI, as suas manifestações acerca das inconsistências registradas.<br><br>
		
		&nbsp;&nbsp;&nbsp;Para registro de suas manifestações acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Sistema Nacional de Controle Interno - SNCI</a><br><br>
				<table>
				<tr>
				<td><strong>Unidade</strong></td>
				<td><strong>Avaliação</strong></td>
				<td><strong>Grupo</strong></td>
				<td><strong>Item</strong></td>
				<td><strong>Dt.Posição</strong></td>
				<td><strong>Dt.Previsão Solução</strong></td>
				</tr>
				<tr>
				<td>-----------------------------------------</td>
				<td>----------------</td>
				<td>--------</td>
				<td>------</td>
				<td>----------------</td>
				<td>----------------</td>
				</tr>
				<cfloop query="rs23TO">
				<tr>
				<td align="left"><strong>#rs23TO.Und_Descricao#</strong></td>
				<td align="center"><strong>#rs23TO.Pos_Inspecao#</strong></td>
				<td align="center"><strong>#rs23TO.Pos_NumGrupo#</strong></td>
				<td align="center"><strong>#rs23TO.Pos_NumItem#</strong></td>
				<td align="center"><strong>#dateformat(rs23TO.Pos_DtPosic,"DD/MM/YYYY")#</strong></td>
				<td align="center"><strong>#dateformat(rs23TO.Pos_DtPrev_Solucao,"DD/MM/YYYY")#</strong></td>
				</tr>
				</cfloop>
				</table>
				<br>
				&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
				</strong>
			</cfmail>
		  </cfif>
	<!--- fim e-mail para status = 19 --->
	</cfoutput> 
	</cfif>		
	<!--- ###### FIM - SUPERINTENDENTE ###### --->	
	<!--- ************** FIM - PRÉ- ALERTA ****************** --->
	<!--- ************** COBRANÇAS POR E-MAIL AOS PENDENTES (SEMANAL ÁS QUARTAS-FEIRAS)****************** --->
	<!--- ###### SUBORDINADORES ###### --->
	<cfif rotina eq 19 and rotinaSN is 'S'>
		 <cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		 <!--- Rotinas de cobranças semanal por email --->
		 <!---  email semanal ao Orgao Subordinador de forma agrupado para o Status = 4-PO --->
		 <!--- status 4 apenas --->
		<!---  <cfset dtatual = CreateDate(year(now()),month(now()),day(now()))> --->
		 <cfset vDiaSem = DayOfWeek(dtatual)>
		 <cfif int(vDiaSem) is 4>
	       <!--- Quarta-feira --->
		   <cfquery name="rs4POGRP" datasource="#dsn_inspecao#">
				SELECT distinct Rep_Codigo, Rep_Nome, Rep_Email 
				FROM Reops INNER JOIN ParecerUnidade ON Rep_Codigo = Pos_Area 
				WHERE Pos_Situacao_Resp = 4 and (Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00'))
				ORDER BY Rep_Codigo
	  		</cfquery>

		  <cfoutput query="rs4POGRP">
			<!--- fazer busca com filtro da REATE e classif. (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem) --->
			<cfquery name="rs4PO" datasource="#dsn_inspecao#">
				SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, Und_Email, Und_Descricao 
				FROM Unidades 
				INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
				WHERE (Pos_Area = '#rs4POGRP.Rep_Codigo#') and (Pos_Situacao_Resp = 4) and (Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00'))
				ORDER BY Und_CodDiretoria, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		   </cfquery>
		   <cfif rs4PO.recordcount gt 0>
				<cfif findoneof("@", #trim(rs4POGRP.Rep_Email)#) eq 0>
					 <cfset rot19_sdestina = "gilvanm@correios.com.br">
				 <cfelse>
					<cfset rot19_sdestina = #trim(rs4POGRP.Rep_Email)#>
			 	</cfif>
				
				<!---    ---> 
			    <cfmail from="SNCI@correios.com.br" to="#rot19_sdestina#" subject="Avaliação PENDENTE DO ÓRGÃO SUBORDINADOR" type="HTML">
				 Mensagem automática. Não precisa responder!<br><br>
				<strong>
				   Ao Gestor(a) do(a) #Ucase(rs4POGRP.Rep_Nome)#. <br><br><br>
		
		&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  em PENDENTE DO ÓRGÃO SUBORDINADOR  para  manifestação  desse Órgão.<br><br>
		
		&nbsp;&nbsp;&nbsp;Assim, solicitamos registrar, por  meio do preenchimento do campo "Manifestar-se" no Sistema SNCI, as suas manifestações acerca das inconsistências registradas.<br><br>
		
		&nbsp;&nbsp;&nbsp;Para registro de suas manifestações acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Sistema Nacional de Controle Interno - SNCI</a><br><br>
		<table>
		<tr>
		<td><strong>Unidade</strong></td>
		<td><strong>Avaliação</strong></td>
		<td><strong>Grupo</strong></td>
		<td><strong>Item</strong></td>
		<td><strong>Dt.Posição</strong></td>
		</tr>
		<tr>
		<td>-----------------------------------------</td>
		<td>----------------</td>
		<td>--------</td>
		<td>------</td>
		<td>----------------</td>
		</tr>
		<cfloop query="rs4PO">
		<tr>
		<td align="left"><strong>#rs4PO.Und_Descricao#</strong></td>
		<td align="center"><strong>#rs4PO.Pos_Inspecao#</strong></td>
		<td align="center"><strong>#rs4PO.Pos_NumGrupo#</strong></td>
		<td align="center"><strong>#rs4PO.Pos_NumItem#</strong></td>
		<td align="center"><strong>#dateformat(rs4PO.Pos_DtPosic,"DD/MM/YYYY")#</strong></td>
		</tr>
		</cfloop>
		</table>
		<br>
		&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
		</strong>
		</cfmail>
		</cfif>
		</cfoutput>
	</cfif> 
	<!--- fim email diarios --->
	</cfif>
	<!--- ###### FIM - SUBORDINADORES ###### --->
	<!--- ###### UNIDADES ###### --->
	<cfif rotina eq 20 and rotinaSN is 'S'>
		 <cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		 <!--- Rotinas de cobranças diárias por email --->
		 <!---  email diários as UNIDADES agrupado para o Status = 2-PU e 20-PF --->

		   <cfquery name="rs2PU20PFGRP" datasource="#dsn_inspecao#">
				SELECT Pos_Inspecao
				FROM ParecerUnidade 
				WHERE (Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
				Pos_Situacao_Resp in (2,20)  
			   GROUP BY Pos_Inspecao
			   order by Pos_Inspecao
			</cfquery>

		  <cfoutput query="rs2PU20PFGRP">
				<cfquery name="rs2PU20PF" datasource="#dsn_inspecao#">
					SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, Und_Email, Und_Descricao, Und_TipoUnidade
					FROM Unidades 
					INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
					WHERE Pos_Situacao_Resp in (2,20) and Pos_Inspecao = '#rs2PU20PFGRP.Pos_Inspecao#' and 
					(Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00'))
					ORDER BY Und_CodDiretoria, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
				</cfquery>
		   		<cfif rs2PU20PF.recordcount gt 0>
					<cfif findoneof("@", #trim(rs2PU20PF.Und_Email)#) eq 0>
						<cfset rot20_sdestina = "gilvanm@correios.com.br">
					 <cfelse>
						<cfset rot20_sdestina = #trim(rs2PU20PF.Und_Email)#>
					</cfif>
					
					<cfset rot20_assunto = 'AVALIAÇÃO PENDENTE DA UNIDADE'>
					<cfif rs2PU20PF.Und_TipoUnidade is 12 or rs2PU20PF.Und_TipoUnidade is 16>
						<cfset rot20_assunto = 'AVALIAÇÃO PENDENTE DE TERCEIRIZADA'>
					</cfif>
					<!---    ---> 
			   		<cfmail from="SNCI@correios.com.br" to="#rot20_sdestina#" subject="#rot20_assunto#" type="HTML">
				 Mensagem automática. Não precisa responder!<br><br>
				<strong>
				   Ao Gestor(a) do(a) #Ucase(rs2PU20PF.Und_Descricao)#. <br><br><br>
		
		&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  em #rot20_assunto#  para  manifestação  desse Órgão.<br><br>
		
		&nbsp;&nbsp;&nbsp;Assim, solicitamos registrar, por  meio do preenchimento do campo "Manifestar-se" no Sistema SNCI, as suas manifestações acerca das inconsistências registradas.<br><br>
		
		&nbsp;&nbsp;&nbsp;Para registro de suas manifestações acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Sistema Nacional de Controle Interno - SNCI</a><br><br>
		<table>
		<tr>
		<td><strong>Unidade</strong></td>
		<td><strong>Avaliação</strong></td>
		<td><strong>Grupo</strong></td>
		<td><strong>Item</strong></td>
		<td><strong>Dt.Posição</strong></td>
		</tr>
		<tr>
		<td>-----------------------------------------</td>
		<td>----------------</td>
		<td>--------</td>
		<td>------</td>
		<td>----------------</td>
		</tr>
		<cfloop query="rs2PU20PF">
		<tr>
		<td align="left"><strong>#rs2PU20PF.Und_Descricao#</strong></td>
		<td align="center"><strong>#rs2PU20PF.Pos_Inspecao#</strong></td>
		<td align="center"><strong>#rs2PU20PF.Pos_NumGrupo#</strong></td>
		<td align="center"><strong>#rs2PU20PF.Pos_NumItem#</strong></td>
		<td align="center"><strong>#dateformat(rs2PU20PF.Pos_DtPosic,"DD/MM/YYYY")#</strong></td>
		</tr>
		</cfloop>
		</table>
		<br>
		&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
		</strong>
		</cfmail>
		</cfif>
		</cfoutput>
	</cfif>
	<!--- ###### FIM - UNIDADES ###### --->
	<!--- ###### AREAS ###### --->
	<cfif rotina eq 21 and rotinaSN is 'S'>
		 <cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		 <!--- Rotinas de cobranças semanal por email --->
		 <!---  email semanal a AREAS de forma agrupado para o Status = 5-PA --->
		<!---  <cfset dtatual = CreateDate(year(now()),month(now()),day(now()))> --->
		 <cfset vDiaSem = DayOfWeek(dtatual)>
		 <cfif int(vDiaSem) is 4>
	       <!--- Quarta-feira --->
		   <cfquery name="rs5PAGRP" datasource="#dsn_inspecao#">
				SELECT distinct Ars_Codigo, Ars_Descricao, Ars_Email 
				FROM Areas INNER JOIN ParecerUnidade ON Ars_Codigo = Pos_Area 
				WHERE Pos_Situacao_Resp = 5 and (Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00'))
				ORDER BY Ars_Codigo
	  		</cfquery>

		  <cfoutput query="rs5PAGRP">
			<!--- fazer busca com filtro da REATE e classif. (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem) --->
			<cfquery name="rs5PA" datasource="#dsn_inspecao#">
				SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, Und_Email, Und_Descricao 
				FROM Unidades 
				INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
				WHERE (Pos_Area = '#rs5PAGRP.Ars_Codigo#') and (Pos_Situacao_Resp = 5) and (Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00'))
				ORDER BY Und_CodDiretoria, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		   </cfquery>
		   <cfif rs5PA.recordcount gt 0>
				<cfif findoneof("@", #trim(rs5PAGRP.Ars_Email)#) eq 0>
					 <cfset rot21_sdestina = "gilvanm@correios.com.br">
				 <cfelse>
					<cfset rot21_sdestina = #trim(rs5PAGRP.Ars_Email)#>
			 	</cfif>
				
			    <cfmail from="SNCI@correios.com.br" to="#rot21_sdestina#" subject="Avaliação PENDENTE DA ÁREA" type="HTML">
				 Mensagem automática. Não precisa responder!<br><br>
				<strong>
				   Ao Gestor(a) do(a) #Ucase(rs5PAGRP.Ars_Descricao)#. <br><br><br>
		
		&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  em PENDENTE DA ÁREA  para  manifestação  desse Órgão.<br><br>
		
		&nbsp;&nbsp;&nbsp;Assim, solicitamos registrar, por  meio do preenchimento do campo "Manifestar-se" no Sistema SNCI, as suas manifestações acerca das inconsistências registradas.<br><br>
		
		&nbsp;&nbsp;&nbsp;Para registro de suas manifestações acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Sistema Nacional de Controle Interno - SNCI</a><br><br>
		<table>
		<tr>
		<td><strong>Unidade</strong></td>
		<td><strong>Avaliação</strong></td>
		<td><strong>Grupo</strong></td>
		<td><strong>Item</strong></td>
		<td><strong>Dt.Posição</strong></td>
		</tr>
		<tr>
		<td>-----------------------------------------</td>
		<td>----------------</td>
		<td>--------</td>
		<td>------</td>
		<td>----------------</td>
		</tr>
		<cfloop query="rs5PA">
		<tr>
		<td align="left"><strong>#rs5PA.Und_Descricao#</strong></td>
		<td align="center"><strong>#rs5PA.Pos_Inspecao#</strong></td>
		<td align="center"><strong>#rs5PA.Pos_NumGrupo#</strong></td>
		<td align="center"><strong>#rs5PA.Pos_NumItem#</strong></td>
		<td align="center"><strong>#dateformat(rs5PA.Pos_DtPosic,"DD/MM/YYYY")#</strong></td>
		</tr>
		</cfloop>
		</table>
		<br>
		&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
		</strong>
		</cfmail>
		</cfif>
		</cfoutput>
	</cfif> 
	<!--- fim email diarios --->
	</cfif>	
	<!--- ###### FIM - AREAS ###### --->
	<!--- ###### SUPERINTENDENTES ###### --->
	<cfif rotina eq 22 and rotinaSN is 'S'>
		 <cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		 <!--- Rotinas de cobranças semanal por email --->
		 <!---  email semanal a SUPERINTENDENTES de forma agrupado para o Status = 8-SE --->
		<!---  <cfset dtatual = CreateDate(year(now()),month(now()),day(now()))> --->
		 <cfset vDiaSem = DayOfWeek(dtatual)>
		 <cfif int(vDiaSem) is 4>
	       <!--- Quarta-feira --->
			<cfquery name="rsSEGRP" datasource="#dsn_inspecao#">
				SELECT Dir_Sto, Dir_Codigo, Dir_Sigla, Dir_Descricao, Dir_Email  
				FROM Diretoria 
				where Dir_Codigo <> '01'
				ORDER BY Dir_Codigo
			</cfquery>

			<cfoutput query="rsSEGRP">
				<!--- fazer busca com filtro da REATE e classif. (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem) --->
				<cfquery name="rsSE" datasource="#dsn_inspecao#">
					SELECT trim(STO_Descricao) as situa, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Und_Email, Und_Descricao 
					FROM Unidades 
					INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
					inner join Situacao_Ponto on STO_Codigo = Pos_Situacao_Resp
					WHERE left(Pos_Area,2) = '#rsSEGRP.Dir_Codigo#' and Pos_Situacao_Resp in (2,4,5,8,11,14,15,16,18,19,20,23) 
					ORDER BY Und_Descricao, Pos_Situacao_Resp, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
				</cfquery>
				<cfif rsSE.recordcount gt 0>
					<cfif findoneof("@", #trim(rsSEGRP.Dir_Email)#) eq 0>
						<cfset rot22_sdestina = "gilvanm@correios.com.br">
					<cfelse>
						<cfset rot22_sdestina = #trim(rsSEGRP.Dir_Email)#>
					</cfif>
	     
					<cfmail from="SNCI@correios.com.br" to="#rot22_sdestina#" subject="Avaliação (SE)" type="HTML">
						Mensagem automática. Não precisa responder!<br><br>
						<strong>
								Ao Gestor(a) do(a) #Ucase(rsSEGRP.Dir_Descricao)#. <br><br><br>

						&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  nas situações abaixo para  manifestação de seus gestores.<br><br>

						&nbsp;&nbsp;&nbsp;Assim, solicitamos registrar, por  meio do preenchimento do campo "Manifestar-se" no Sistema SNCI, as suas manifestações acerca das inconsistências registradas.<br><br>

						&nbsp;&nbsp;&nbsp;Para registro de suas manifestações acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Sistema Nacional de Controle Interno - SNCI</a><br><br>
						<table>
							<tr>
								<td><strong>Unidade</strong></td>
								<td><strong>Avaliação</strong></td>
								<td><strong>Grupo</strong></td>
								<td><strong>Item</strong></td>
								<td><strong>Dt.Posição</strong></td>
								<td><strong>Dt.Previsão</strong></td>
								<td><strong>Dias(Vencto)</strong></td>
								<td><strong>Situação</strong></td>
							</tr>
							<tr>
								<td>-----------------------------------------</td>
								<td>----------------</td>
								<td>--------</td>
								<td>------</td>
								<td>----------------</td>
								<td>----------------</td>
								<td>-----------------</td>
								<td>-----------------------------------------------------------</td>
							</tr>
							<cfloop query="rsSE">
								<cfset dtprevi = ''>
								<cfset DIAS = ''>
								<cfif rsSE.Pos_Situacao_Resp neq 11>
									<cfset dtprevi = dateformat(rsSE.Pos_DtPrev_Solucao,"DD/MM/YYYY")>
									<cfset DIAS = dateDiff("d", DateFormat(now(),"YYYY/MM/DD"),DateFormat(rsSE.Pos_DtPrev_Solucao,"YYYY/MM/DD"))>
								</cfif>
								<tr>
									<td align="left"><strong>#rsSE.Und_Descricao#</strong></td>
									<td align="center"><strong>#rsSE.Pos_Inspecao#</strong></td>
									<td align="center"><strong>#rsSE.Pos_NumGrupo#</strong></td>
									<td align="center"><strong>#rsSE.Pos_NumItem#</strong></td>
									<td align="center"><strong>#dateformat(rsSE.Pos_DtPosic,"DD/MM/YYYY")#</strong></td>
									<td align="center"><strong>#dtprevi#</strong></td>
									<td align="center"><strong>#DIAS#</strong></td>
									<td align="center"><strong>#rsSE.situa#</strong></td>
								</tr>
							</cfloop>
						</table>
						<br>
						&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
						</strong>    
					</cfmail>
				</cfif>
			</cfoutput>
	</cfif> 
	<!--- fim email diarios --->
	</cfif>		
	<!--- ###### FIM - SUPERINTENDENTES ###### --->
	<!--- ************** FIM - COBRANÇAS POR E-MAIL AOS PENDENTES ****************** --->
	<!--- ************** AVISOS POR E-MAIL AOS SCOI (DIÁRIO)****************** --->
	<!--- ###### INICIO - 0-RE e 11-EL ###### --->
	<cfif rotina eq 23 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- Cobrança por e-mail aos SCOI Status 0-RE ou 11-EL com 1(um) ou mais dias no SNCI --->
		<cfquery name="rsRot23" datasource="#dsn_inspecao#">
			SELECT Und_CodDiretoria
			FROM ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			WHERE (((Pos_Situacao_Resp)=0 Or (Pos_Situacao_Resp)=11) AND ((Pos_DtPosic)<GETDATE()))
			GROUP BY Und_CodDiretoria
		</cfquery>
		<cfoutput query="rsRot23">
			<cfquery name="rs011" datasource="#dsn_inspecao#">
				SELECT Und_CodDiretoria, Und_Descricao, Pos_Inspecao 
				FROM Unidades 
				INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
				WHERE (Pos_Situacao_Resp in (0,11)) and 
				(Pos_DtPosic < GETDATE()) and (Und_CodDiretoria = '#rsRot23.Und_CodDiretoria#') 
				GROUP BY Und_CodDiretoria, Und_Descricao, Pos_Inspecao 
			</cfquery>	
			<cfset scoi_coordena = ''>			
			<cfif rs011.recordcount gt 0>
				<cfset scoi_coordena = rs011.Und_CodDiretoria>
				<cfif scoi_coordena eq '03' or scoi_coordena eq '05' or scoi_coordena eq '65'>
					<cfset scoi_coordena = '10'>
				<cfelseif scoi_coordena eq '70'>
					<cfset scoi_coordena = '04'>						 					 				 
				</cfif>
				<cfquery name="rsGes" datasource="#dsn_inspecao#">
					SELECT Ars_Sigla, Ars_Email 
					FROM Areas 
					WHERE (left(Ars_Codigo,2)= '#scoi_coordena#') AND (Ars_Descricao Like '%SEC AVAL CONT INTERNO/SCOI%' OR Ars_Descricao Like '%SUP CONTR INTERNO/SCOI%')
				</cfquery>
				<cfset auxnomearea = rsGes.Ars_Sigla>
				<cfset rot23_sdestina = rsGes.Ars_Email>
				
				<cfif findoneof("@", #trim(rot23_sdestina)#) eq 0>
					 <cfset rot23_sdestina = "gilvanm@correios.com.br">
				</cfif>
				<cfmail from="SNCI@correios.com.br" to="#rot23_sdestina#" subject="Revisões dos SCOIs" type="HTML"> 
				 Mensagem automática. Não precisa responder!<br><br>
				<strong>
				   Ao Gestor(a) da #Ucase(auxnomearea)#. <br><br><br>
		
		&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  para  REVISÃO, LIBERAÇÃO desse Órgão.<br><br>
		&nbsp;&nbsp;&nbsp;Para registro de suas Análises ou encaminhamentos acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">SNCI</a><br><br>
				
					<table>
					<tr>
					<td><strong>Unidade</strong></td>
					<td><strong>Avaliação</strong></td>
					</tr>
					<tr>
					<td>-----------------------------------------------</td>
					<td>----------------</td>
					</tr>
					<cfloop query="rs011">
						<tr>
						<td align="left"><strong>#rs011.Und_Descricao#</strong></td>
						<td align="center"><strong>#rs011.Pos_Inspecao#</strong></td>
						</tr>
					</cfloop>
					</table>
					<br>
					&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
					</strong>
			    </cfmail>
			 </cfif>     
		  </cfoutput> 
	</cfif>
	<!--- ###### FIM 0-RE e 11-EL ###### --->
	<!--- ###### INICIO REPOSTAS ###### --->
	<cfif rotina eq 24 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- Inicio em 13/11/2020 Gilvan - ROTINAS PARA MUDANÇA DE STATUS  dos Itens --->
		<!--- Cobrança por e-mail aos SCOI Status 1-RU, 6-RA, 7-RS, 17-RF, 21-RV, 22-RO que Pos_DtPosic possui mais de 14 dias corridos --->
		<cfquery name="rsRot24" datasource="#dsn_inspecao#">
			SELECT Und_CodDiretoria 
			FROM Unidades 
			INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
			WHERE Pos_Situacao_Resp IN (1,6,7,17,21,22) AND (Pos_NumGrupo not in (9,29,68,96,122,209,241,278,308,337) AND Pos_NumItem not in (2,3,4,9)) and (Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) 
			and (DATEDIFF(d,Pos_DtPosic, GETDATE()) >= 15) 
			GROUP BY Und_CodDiretoria
		</cfquery>
	
		<cfoutput query="rsRot24">
	
			<cfquery name="rs16722" datasource="#dsn_inspecao#">
			   SELECT Und_CodDiretoria, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_Situacao_Resp, STO_Sigla, STO_Descricao  
			   FROM Unidades 
			   INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
			   INNER JOIN Situacao_Ponto ON (Pos_Situacao_Resp = STO_Codigo)
			   WHERE (Pos_Situacao_Resp in (1,6,7,17,21,22)) AND 
			   (Pos_NumGrupo not in (9,29,68,96,122,209,241,278,308) AND Pos_NumItem not in (2,3,4,9)) and 
			   (Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
			   (DATEDIFF(d,Pos_DtPosic, GETDATE()) >= 15) and 
			   (Und_CodDiretoria = '#rsRot24.Und_CodDiretoria#') 
			   ORDER BY Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
			</cfquery>	
			<cfset scoi_coordena = ''>
			<cfif rs16722.recordcount gt 0>
				<!--- Calculo dos 15 dias uteis --->
				<cfset dtposic = CreateDate(year(rs16722.Pos_DtPosic),month(rs16722.Pos_DtPosic),day(rs16722.Pos_DtPosic))>
				<cfset nCont = 1>
				<cfset nFinal = 15>
				<cfloop condition="nCont lte nFinal">
					<cfset dtposic = DateAdd("d", 1, #dtposic#)>
					<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
						SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtposic#
					</cfquery>
					<cfif rsFeriado.recordcount gt 0>
						<cfset nFinal = nFinal + 1>
					<cfelse>
						<cfset vDiaSem = DayOfWeek(dtposic)>
						<cfswitch expression="#vDiaSem#">
							<cfcase value="1">
								<!--- domingo --->
								<cfset nFinal = nFinal + 1>
							</cfcase>
							<cfcase value="7">
								<cfset nFinal = nFinal + 1>
							</cfcase>
						</cfswitch>
					</cfif>
					<cfset nCont = nCont + 1>
				</cfloop>
				<!--- <cfset dtFUP = dtposic> --->
				<!---  --->
				<cfif (nFinal - 15) lte 0>
					<cfset scoi_coordena = rs16722.Und_CodDiretoria>
					<cfset scoi_coordena = rs011.Und_CodDiretoria>
					<cfif scoi_coordena eq '03' or scoi_coordena eq '05' or scoi_coordena eq '65'>
						<cfset scoi_coordena = '10'>
					<cfelseif scoi_coordena eq '70'>
						<cfset scoi_coordena = '04'>						 					 				 
					</cfif>	

					<cfquery name="rsGes" datasource="#dsn_inspecao#">
						SELECT Ars_Sigla, Ars_Email 
						FROM Areas 
						WHERE AND left(Ars_Codigo,2)= '#scoi_coordena#' and (Ars_Descricao Like '%SEC AVAL CONT INTERNO/SCOI%' OR Ars_Descricao Like '%SUP CONTR INTERNO/SCOI%') 
					</cfquery>
		
					<cfset auxnomearea = rsGes.Ars_Sigla>
					<cfset rot24_sdestina = rsGes.Ars_Email>
					
					<cfif findoneof("@", #trim(rot24_sdestina)#) eq 0>
						 <cfset rot24_sdestina = "gilvanm@correios.com.br">
					</cfif>
			
					<cfmail from="SNCI@correios.com.br" to="#rot24_sdestina#" subject="GESTORES - Respostas" type="HTML">  
			
						 Mensagem automática. Não precisa responder!<br><br>
						<strong>
						   Ao Gestor(a) do(a) #Ucase(auxnomearea)#. <br><br><br>
				
				&nbsp;&nbsp;&nbsp;Comunicamos que há itens com manifestação dos órgãos e que encontram-se pendentes de tratamento dessa SGCIN/SCOI.<br><br>
				&nbsp;&nbsp;&nbsp;Para registro de suas Análises acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">SNCI</a><br><br>
						
						<table>
						<tr>
						
						<td><strong>Unidade</strong></td>
						<td><strong>Descrição</strong></td>
						<td><strong>Avaliação</strong></td>
						<td><strong>Grupo</strong></td>
						<td><strong>Item</strong></td>
						<td><strong>Posição</strong></td>
						<td><strong>Sigla</strong></td>
						<td><strong>Descrição</strong></td>
						<td><strong>Dias</strong></td>
						</tr>
						<tr>
						<td>----------</td>
						<td>-----------------------------------------------</td>
						<td>-------------</td>
						<td>-------</td>
						<td>-------</td>
						<td>-------------</td>	
						<td>-----</td>
						<td>-------------------------------</td>	
						<td>-------</td>						
						</tr>
						<cfloop query="rs16722">
								<tr>
								<td align="left"><strong>#rs16722.Pos_Unidade#</strong></td>
								<td align="left"><strong>#rs16722.Und_Descricao#</strong></td>
								<td align="center"><strong>#rs16722.Pos_Inspecao#</strong></td>
								<td align="center"><strong>#rs16722.Pos_NumGrupo#</strong></td>
								<td align="center"><strong>#rs16722.Pos_NumItem#</strong></td>
								<td align="center"><strong>#dateformat(rs16722.Pos_DtPosic,"dd/mm/yyyy")#</strong></td>
								<td align="center"><strong>#rs16722.STO_Sigla#</strong></td>
								<td align="left"><strong>#trim(rs16722.STO_Descricao)#</strong></td>
								<cfset auxposic = DateFormat(now(),"YYYY/MM/DD")>
								<cfset DIAS = dateDiff("d", DateFormat(rs16722.Pos_DtPosic,"YYYY/MM/DD"), DateFormat(now(),"YYYY/MM/DD"))>
								<td align="right"><strong>#DIAS#</strong></td>
								</tr>
						</cfloop>
							</table>
							<br>
							&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
							</strong>
					 </cfmail>
				 </cfif>
				</cfif>      
			  </cfoutput>  
		</cfif> 
	<!--- ###### FIM REPOSTAS ###### --->
	<!--- ###### INICIO Em Análise ###### --->
	<cfif rotina eq 25 and rotinaSN is 'S'>
			<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
			<!--- Inicio em 02/06/2021 Gilvan --->
			<!--- Cobrança por e-mail aos SCIA Status 28-EA = EM ANALISE aos seus respectivos CCOP/SCIA QUE DATA POSIC possua 20 de vencido--->
			<cfquery name="rsRotina25" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla 
				FROM Diretoria 
				where Dir_Codigo <> '01'
				ORDER BY Dir_Sigla
			</cfquery>
			<cfoutput query="rsRotina25">
				
				<cfquery name="rs25" datasource="#dsn_inspecao#">
				SELECT Und_CodDiretoria, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_Situacao_Resp, STO_Sigla, STO_Descricao, DATEDIFF(d,Pos_DtPosic, GETDATE()) as diasocorr  
				FROM Unidades 
				INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
				INNER JOIN Situacao_Ponto ON (Pos_Situacao_Resp = STO_Codigo)
				WHERE (Pos_Situacao_Resp in (28)) and 
				(DATEDIFF(d,Pos_DtPosic, GETDATE()) >= 20) and 
				(Und_CodDiretoria = '#rsRotina25.Dir_Codigo#') 
				ORDER BY Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
				</cfquery>	

				<cfif rs25.recordcount gt 0>

				<cfset auxSE = rsRotina25.Dir_Codigo>
				<cfset scia_se = auxSE>
				<cfif auxSE eq '03' or auxSE eq '16' or auxSE eq '26' or auxSE eq '06' or auxSE eq '75' or auxSE eq '28' or auxSE eq '65' or auxSE eq '05'> <!--- ACR;GO;RO;AM;TO;PA;RR;AP --->
					<cfset scia_se = '10'>	<!--- BSB --->
				<cfelseif auxSE eq '08' or auxSE eq '14'>   <!--- BA; ES --->
					<cfset scia_se = '20'> <!--- MG --->
				<cfelseif auxSE eq '04' or auxSE eq '12' or auxSE eq '18' or auxSE eq '30' or auxSE eq '34' or auxSE eq '60' or auxSE eq '70'> <!--- AL; CE; MA; PB; PI; RN; SE --->
					<cfset scia_se = '32'> <!--- PE --->
				<cfelseif auxSE eq '68' or auxSE eq '64'> <!--- SC;RS --->
					<cfset scia_se = '36'>	<!--- PR --->
				<cfelseif auxSE eq '50'>   <!--- RJ --->
					<cfset scia_se = '72'> <!--- SPM --->
				<cfelseif auxSE eq '22' OR auxSE eq '24'>   <!--- MS; MT --->
					<cfset scia_se = '74'> <!--- SPI --->				 					 				 
				</cfif>	
					
					<cfquery name="rsSCIA" datasource="#dsn_inspecao#">
					 SELECT DISTINCT Ars_Codigo, Ars_Sigla, Ars_Descricao, Ars_Email, Ars_EmailCoordenador
					 FROM Areas 
					 WHERE Left(Ars_Codigo,2) = '#scia_se#' and (Ars_Descricao Like '%SEC ACOMP CONTR INTERNO/SCIA%' OR Ars_Descricao Like '%SEC ACOMP CONTR INTERNO/SCIA%')
					 ORDER BY Ars_Sigla
					</cfquery>					
					<!---  --->				
			
					<cfset auxnomearea = rsSCIA.Ars_Sigla>
					<cfset rot25_sdestina = rsSCIA.Ars_Email>
					<cfset rot25_sdestina = rot25_sdestina & ';' & rsSCIA.Ars_EmailCoordenador>
					
					<cfif findoneof("@", #trim(rot25_sdestina)#) eq 0>
						 <cfset rot25_sdestina = "gilvanm@correios.com.br">
					</cfif>
				
					<cfmail from="SNCI@correios.com.br" to="#rot25_sdestina#" subject="GESTORES - Em Análise" type="HTML">  
		
						 Mensagem automática. Não precisa responder!<br><br>
						<strong>
						   Ao Gestor(a) do(a) #Ucase(auxnomearea)#. <br><br><br>
				
				&nbsp;&nbsp;&nbsp;Comunicamos que há itens respondidos aguardando ratificação pelas equipes das SGCIN/SCIA quanto as ações informadas pelo gestor em sua última manifestação.<br><br>
				&nbsp;&nbsp;&nbsp;Para registro de suas Análises acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">SNCI</a><br><br>
						
						<table>
						<tr>
					
						<td><strong>Unidade</strong></td>
						<td><strong>Descrição</strong></td>
						<td><strong>Avaliação</strong></td>
						<td><strong>Grupo</strong></td>
						<td><strong>Item</strong></td>
						<td><strong>Posição</strong></td>
						<td><strong>Sigla</strong></td>
						<td><strong>Descrição</strong></td>
						<td><strong>Dias Úteis</strong></td>
						</tr>
						<tr>
						<td>----------</td>
						<td>-----------------------------------------------</td>
						<td>-------------</td>
						<td>-------</td>
						<td>-------</td>
						<td>-------------</td>	
						<td>-----</td>
						<td>-------------------------------</td>	
						<td>------------</td>						
						</tr>
						<cfloop query="rs25">
							<!--- Contar dias úteis  --->
							<cfset nCont = 1>
							<cfset dsusp = 0>
							<cfset dduteis = 0>
							<cfset DD_SD_Existe = 0>
							<cfset auxdtnova = CreateDate(year(rs25.Pos_DtPosic),month(rs25.Pos_DtPosic),day(rs25.Pos_DtPosic))>
							<cfset auxDTFim = DateAdd("d", #rs25.diasocorr#, #auxdtnova#)>
							
							<!--- Obter sabados e domingos entre as datas  --->
							<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
								SELECT Fer_Data FROM FeriadoNacional where Fer_Data between #auxdtnova# and #auxDTFim#
							</cfquery>
							<cfif rsFeriado.recordcount gt 0>
								   <cfset DD_SD_Existe = rsFeriado.recordcount>
								   <cfloop query="rsFeriado">
									   <cfset vDiaSem = DayOfWeek(rsFeriado.Fer_Data)>
									   <cfswitch expression="#vDiaSem#">
										  <cfcase value="1">
											 <cfset DD_SD_Existe = DD_SD_Existe - 1>
										  </cfcase>
										  <cfcase value="7">
											 <cfset DD_SD_Existe = DD_SD_Existe - 1>
										  </cfcase>
									   </cfswitch>
								   </cfloop>
							 </cfif>
							<!--- obter os sabados/domingos nos feriados nacionais --->
							<cfloop condition="nCont lte #rs25.diasocorr#">
									<cfset vDiaSem = DayOfWeek(auxdtnova)>
									<cfswitch expression="#vDiaSem#">
										<cfcase value="1">
											<cfset dsusp = dsusp + 1>
										</cfcase>
										<cfcase value="7">
											<cfset dsusp = dsusp + 1>
										</cfcase>
										<cfdefaultcase>
											<!--- <cfset nCont = 2> --->
										</cfdefaultcase>
									</cfswitch>
									<cfset nCont = nCont + 1>
									<cfset auxdtnova = DateAdd("d", 1, #auxdtnova#)>
								</cfloop>
								<cfset dsusp = #dsusp# + #DD_SD_Existe#>
								<cfset dduteis = #rs25.diasocorr# - #dsusp#> 
							<!---  --->
							<cfif (dduteis gte 20)> 					
								<tr>
									<td align="left"><strong>#rs25.Pos_Unidade#</strong></td>
									<td align="left"><strong>#rs25.Und_Descricao#</strong></td>
									<td align="center"><strong>#rs25.Pos_Inspecao#</strong></td>
									<td align="center"><strong>#rs25.Pos_NumGrupo#</strong></td>
									<td align="center"><strong>#rs25.Pos_NumItem#</strong></td>
									<td align="center"><strong>#dateformat(rs25.Pos_DtPosic,"dd/mm/yyyy")#</strong></td>
									<td align="center"><strong>#rs25.STO_Sigla#</strong></td>
									<td align="left"><strong>#trim(rs25.STO_Descricao)#</strong></td>
									<cfset auxposic = DateFormat(now(),"YYYY/MM/DD")>
									<cfset DIAS = dduteis>
									<td align="right"><strong>#DIAS#</strong></td>
								</tr>
								</cfif>
							</cfloop>
							</table>
							<br>
							&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
							</strong>
						</cfmail> 
					</cfif> 
				<!--- </cfloop>	 --->						    
		  </cfoutput> 
	</cfif>
	<!--- ###### FIM Em Análise ###### --->
<!--- ************** MUDAR STATUS conforme Demanda nº 58 ****************** --->
	<!--- para Tratamento --->
	<cfif rotina eq 26 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- Todas mudanças de Status deverão ter registros nos campos (Pos_Paracer(Cumulativo) e And_Parecer(individual)) --->
		<!--- Mudar o Status de 10 para Tratamento conforme valor registrado no campo Pos_Area --->
		<!--- CONDIÇÃO: Quando o campo: Pos_DtPrev_Solucao estiver vencido.
		obs. deverá ser concedido 10 (dez) dias úteis ao campo  Pos_DtPrev_Solucao--->
		<cfset PosDtPrevSolucao = CreateDate(year(now()),month(now()),day(now()))>
		<cfset nCont = 1>
		<cfset nFinal = 10>
		<cfloop condition="nCont lte nFinal">
			<cfset PosDtPrevSolucao = DateAdd("d", 1, #PosDtPrevSolucao#)>
			<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
				SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #PosDtPrevSolucao#
			</cfquery>
			<cfif rsFeriado.recordcount gt 0>
				<cfset nFinal = nFinal + 1>
			<cfelse>
				<cfset vDiaSem = DayOfWeek(PosDtPrevSolucao)>
				<cfswitch expression="#vDiaSem#">
					<cfcase value="1">
						<!--- domingo --->
						<cfset nFinal = nFinal + 1>
					</cfcase>
					<cfcase value="7">
						<cfset nFinal = nFinal + 1>
					</cfcase>
				</cfswitch>
			</cfif>
			<cfset nCont = nCont + 1>
		</cfloop>	
		<cfset PosDtPrevSolucao = CreateDate(year(PosDtPrevSolucao),month(PosDtPrevSolucao),day(PosDtPrevSolucao))>
	
		<cfquery name="rs10PS_TRAT" datasource="#dsn_inspecao#">
			SELECT Und_Centraliza, Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Parecer, Und_Email, Und_TipoUnidade, Und_Descricao, Rep_Codigo, Rep_Nome
			FROM Unidades 
			INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
			INNER JOIN Reops ON Und_CodReop = Rep_Codigo
			WHERE (Pos_Situacao_Resp=10) and 
			(Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00'))
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>

	  <cfoutput query="rs10PS_TRAT">
			<cfset PosDtPosic =  dateformat(rs10PS_TRAT.Pos_DtPosic,"YYYYMMDD")>
			<cfquery name="rsAntes" datasource="#dsn_inspecao#">
				SELECT TOP 1 And_DtPosic, And_HrPosic, And_Situacao_Resp, And_Area
				FROM Andamento
				WHERE And_Unidade = '#rs10PS_TRAT.Pos_Unidade#' AND 
				And_NumInspecao = '#rs10PS_TRAT.Pos_Inspecao#' AND 
				And_NumGrupo = #rs10PS_TRAT.Pos_NumGrupo# AND 
				And_NumItem = #rs10PS_TRAT.Pos_NumItem# AND 
				And_Situacao_Resp in (1,2,3,4,5,6,7,8,14,15,16,17,18,19,20,22,23) and And_DtPosic <= '#PosDtPosic#'
				ORDER BY And_DtPosic DESC, And_HrPosic DESC
			</cfquery>	 
			 <cfif rsAntes.recordcount gt 0>
			 	<cfset AndArea = rsAntes.And_Area>
			 <cfelse>
			    <cfset AndArea = rs10PS_TRAT.Pos_Unidade>
			 </cfif>
			<!---  --->
			<cfquery name="rsExiste" datasource="#dsn_inspecao#">
				SELECT Und_Codigo, Und_Descricao FROM Unidades WHERE Und_Codigo = '#AndArea#'
			</cfquery>
			<cfif rsExiste.recordcount gt 0>
				<cfif rs10PS_TRAT.Und_TipoUnidade is 12 || rs10PS_TRAT.Und_TipoUnidade is 16>
				   <!--- TERCEIRIZADA --->
				   <cfset rot26_StatusID = 18>
				   <cfset rot26_StatusSGL = 'TF'>
				   <cfset rot26_StatusDESC = 'TRATAMENTO TERCEIRIZADA'>
				 <cfelse>
				   <!--- Proprias --->
				   <cfset rot26_StatusID = 15>
				   <cfset rot26_StatusSGL = 'TU'>
				   <cfset rot26_StatusDESC = 'TRATAMENTO UNIDADE'>
				 </cfif>
				 <cfset aux_posarea = rsExiste.Und_Codigo>
		         <cfset aux_posnomearea = rsExiste.Und_Descricao>
			<cfelse>
				<cfquery name="rsExiste" datasource="#dsn_inspecao#">
					SELECT Ars_Codigo, Ars_Descricao FROM Areas WHERE Ars_Codigo = '#AndArea#' 
				</cfquery>
				<cfif rsExiste.recordcount gt 0>
					<cfset rot26_StatusID = 19>
					<cfset rot26_StatusSGL = 'TA'>
					<cfset rot26_StatusDESC = 'TRATAMENTO AREA'>
					<cfset aux_posarea = rsExiste.Ars_Codigo>
		         	<cfset aux_posnomearea = rsExiste.Ars_Descricao>
				<cfelse>
					<cfquery name="rsExiste" datasource="#dsn_inspecao#">
						SELECT Rep_Codigo, Rep_Nome FROM Reops WHERE Rep_Codigo = '#AndArea#'
					</cfquery>
					<cfif rsExiste.recordcount gt 0>
						<cfset rot26_StatusID = 16>
						<cfset rot26_StatusSGL = 'TS'>
						<cfset rot26_StatusDESC = 'TRATAMENTO ORGAO SUBORDINADOR'>
						<cfset aux_posarea = rsExiste.Rep_Codigo>
						<cfset aux_posnomearea = rsExiste.Rep_Nome>						
					<cfelse>
						<cfquery name="rsExiste" datasource="#dsn_inspecao#">
							SELECT Dir_Codigo, Dir_Descricao
							FROM Diretoria
							WHERE Dir_Sto = '#AndArea#'
						</cfquery>
						<cfif rsExiste.recordcount gt 0>
							<cfset rot26_StatusID = 23>
							<cfset rot26_StatusSGL = 'TO'>
							<cfset rot26_StatusDESC = 'TRATAMENTO SUPERINTENDENCIA ESTADUAL'>
							<cfset aux_posarea = rsExiste.Dir_Codigo>
							<cfset aux_posnomearea = rsExiste.Dir_Descricao>								
						</cfif>	
					</cfif>	
				</cfif>				
			</cfif>
	
	 <!--- Opiniao da CCOP --->
	 <cfset Encaminhamento = "Opinião do Controle Interno">
	 <cfset sinformes = 'Prezado gestor, solicita-se atualizar as informações do andamento das ações para regularização do item apontado considerando sua manifestação de ' & DateFormat(rsAntes.And_DtPosic,"DD/MM/YYYY") & ' quanto as tratativas com órgão externo, Incluir no SNCI as evidências das tratativas/ações adotadas.'>
	 <cfset aux_obs = #rs10PS_TRAT.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: ' & #rot26_StatusDESC# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(PosDtPrevSolucao,"DD/MM/YYYY")# & CHR(13) & CHR(13)& CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
		 <cfquery datasource="#dsn_inspecao#">
		   UPDATE ParecerUnidade SET Pos_Area = '#aux_posarea#', Pos_NomeArea = '#aux_posnomearea#', Pos_Situacao_Resp = #rot26_StatusID#, Pos_Situacao = '#rot26_StatusSGL#', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_DtPosic = convert(char, getdate(), 102), Pos_DtPrev_Solucao = #PosDtPrevSolucao#, Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 10 WHERE Pos_Unidade='#rs10PS_TRAT.Pos_Unidade#' AND Pos_Inspecao='#rs10PS_TRAT.Pos_Inspecao#' AND Pos_NumGrupo=#rs10PS_TRAT.Pos_NumGrupo# AND Pos_NumItem=#rs10PS_TRAT.Pos_NumItem#
		 </cfquery>
		 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: ' & #rot26_StatusDESC# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
			<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
			<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>		 
		 <cfquery datasource="#dsn_inspecao#">
		   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs10PS_TRAT.Pos_Inspecao#', '#rs10PS_TRAT.Pos_Unidade#', #rs10PS_TRAT.Pos_NumGrupo#, #rs10PS_TRAT.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', #rot26_StatusID#, '#hhmmssdc#', '#and_obs#', '#aux_posarea#')
		 </cfquery>
	</cfoutput> 
  </cfif> 	
  <cfif rotina eq 27 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
			<!--- ###### INICIO Resposta AGF ###### em 24/01/2024 Gilvan --->
			<!--- Aviso aos SCIAS por e-mail aos SCIA Status 17-RF aos seus respectivos SCIA QUE DATA POSIC possua 20 de vencido--->
			<cfquery name="rsRotina27" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla 
				FROM Diretoria 
				where Dir_Codigo <> '01'
				ORDER BY Dir_Sigla
			</cfquery>
			<cfoutput query="rsRotina27">
				
				<cfquery name="rs27" datasource="#dsn_inspecao#">
					SELECT Und_CodDiretoria, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_Situacao_Resp, STO_Sigla, STO_Descricao, DATEDIFF(d,Pos_DtPosic, GETDATE()) as diasocorr  
					FROM Unidades 
					INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
					INNER JOIN Situacao_Ponto ON (Pos_Situacao_Resp = STO_Codigo)
					WHERE (Pos_Situacao_Resp in (17)) and 
					(Und_CodDiretoria = '#rsRotina27.Dir_Codigo#') 
					ORDER BY Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
				</cfquery>	

				<cfif rs27.recordcount gt 0>

					<cfset auxSE = rsRotina27.Dir_Codigo>
					<cfset scia_se = auxSE>
					<cfif auxSE eq '03' or auxSE eq '16' or auxSE eq '26' or auxSE eq '06' or auxSE eq '75' or auxSE eq '28' or auxSE eq '65' or auxSE eq '05'> <!--- ACR;GO;RO;AM;TO;PA;RR;AP --->
						<cfset scia_se = '10'>	<!--- BSB --->
					<cfelseif auxSE eq '08' or auxSE eq '14'>   <!--- BA; ES --->
						<cfset scia_se = '20'> <!--- MG --->
					<cfelseif auxSE eq '04' or auxSE eq '12' or auxSE eq '18' or auxSE eq '30' or auxSE eq '34' or auxSE eq '60' or auxSE eq '70'> <!--- AL; CE; MA; PB; PI; RN; SE --->
						<cfset scia_se = '32'> <!--- PE --->
					<cfelseif auxSE eq '68' or auxSE eq '64'> <!--- SC;RS --->
						<cfset scia_se = '36'>	<!--- PR --->
					<cfelseif auxSE eq '50'>   <!--- RJ --->
						<cfset scia_se = '72'> <!--- SPM --->
					<cfelseif auxSE eq '22' OR auxSE eq '24'>   <!--- MS; MT --->
						<cfset scia_se = '74'> <!--- SPI --->				 					 				 
					</cfif>	
					
					<cfquery name="rsSCIA" datasource="#dsn_inspecao#">
					 SELECT DISTINCT Ars_Codigo, Ars_Sigla, Ars_Descricao, Ars_Email, Ars_EmailCoordenador
					 FROM Areas 
					 WHERE Left(Ars_Codigo,2) = '#scia_se#' and (Ars_Descricao Like '%SEC ACOMP CONTR INTERNO/SCIA%' OR Ars_Descricao Like '%SEC ACOMP CONTR INTERNO/SCIA%')
					 ORDER BY Ars_Sigla
					</cfquery>					
					<!---  --->				
			
					<cfset auxnomearea = rsSCIA.Ars_Sigla>
					<cfset rot27_sdestina = rsSCIA.Ars_Email>
					<cfset rot27_sdestina = rot27_sdestina & ';' & rsSCIA.Ars_EmailCoordenador>
					
					<cfif findoneof("@", #trim(rot27_sdestina)#) eq 0>
						 <cfset rot27_sdestina = "gilvanm@correios.com.br">
					</cfif>
				
					<cfmail from="SNCI@correios.com.br" to="#rot27_sdestina#" subject="GESTORES - Em Análise" type="HTML">  
		
						 Mensagem automática. Não precisa responder!<br><br>
						<strong>
						   Ao Gestor(a) do(a) #Ucase(auxnomearea)#. <br><br><br>
				
				&nbsp;&nbsp;&nbsp;Comunicamos que há itens respondidos pela AGF aguardando ratificação pelas equipes das SGCIN/SCIA quanto as ações informadas pelo gestor em sua última manifestação.<br><br>
				&nbsp;&nbsp;&nbsp;Para registro de suas Análises acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">SNCI</a><br><br>
						
						<table>
							<tr>
								<td><strong>Unidade</strong></td>
								<td><strong>Descrição</strong></td>
								<td><strong>Avaliação</strong></td>
								<td><strong>Grupo</strong></td>
								<td><strong>Item</strong></td>
								<td><strong>Posição</strong></td>
								<td><strong>Sigla</strong></td>
								<td><strong>Descrição</strong></td>
							</tr>
							<tr>
								<td>----------</td>
								<td>-----------------------------------------------</td>
								<td>-------------</td>
								<td>-------</td>
								<td>-------</td>
								<td>-------------</td>	
								<td>-----</td>
								<td>-------------------------------</td>	
								<td>------------</td>						
							</tr>
							<cfloop query="rs27">
								<tr>
									<td align="left"><strong>#rs27.Pos_Unidade#</strong></td>
									<td align="left"><strong>#rs27.Und_Descricao#</strong></td>
									<td align="center"><strong>#rs27.Pos_Inspecao#</strong></td>
									<td align="center"><strong>#rs27.Pos_NumGrupo#</strong></td>
									<td align="center"><strong>#rs27.Pos_NumItem#</strong></td>
									<td align="center"><strong>#dateformat(rs27.Pos_DtPosic,"dd/mm/yyyy")#</strong></td>
									<td align="center"><strong>#rs27.STO_Sigla#</strong></td>
									<td align="left"><strong>#trim(rs27.STO_Descricao)#</strong></td>
								</tr>
							</cfloop>
							</table>
							<br>
							&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
							</strong>
					</cfmail> 
				</cfif> 
				<!--- </cfloop>	 --->						    
		  </cfoutput> 
 	<!--- ###### FIM Resposta AGF ###### --->
  </cfif> 
  <!---  --->
  <cfif rotina eq 28>
  </cfif>

<!--- alerta quanto a necessidade de realizar Pesquisa_Pos_Avaliacao das Avaliações--->

	<cfif rotina eq 29 and rotinaSN is 'S'>
		<cfoutput>
		<cfquery name="rsAviso1" datasource="#dsn_inspecao#">
			SELECT Pes_Inspecao, Und_Descricao, INP_Responsavel, Und_Email
			FROM (Pesquisa_Pos_Avaliacao INNER JOIN Inspecao ON Pes_Inspecao = INP_NumInspecao) INNER JOIN Unidades ON INP_Unidade = Und_Codigo
			WHERE (Pes_GestorNome is Null) and (DATEDIFF(d,GETDATE(),Pes_dtinicio) <= 10) and Pes_Ctrl_AvisoA = 0
			order by Pes_Inspecao
		</cfquery>
		
		<cfloop query="rsAviso1">
			<cfset rot29a_sdestina = rsAviso1.Und_Email>
			
			<cfif findoneof("@", #trim(rot29a_sdestina)#) eq 0>
				<cfset rot29a_sdestina = "gilvanm@correios.com.br">
			</cfif>

			<cfmail from="SNCI@correios.com.br" to="#rot29a_sdestina#" subject="Pesquisa de Opinião" type="HTML">
					 Mensagem automática. Não precisa responder!<br><br>
					<strong>
					   Ao Gestor(a) do(a) #Ucase(rsAviso1.Und_Descricao)#. <br><br><br>
			
			&nbsp;&nbsp;&nbsp;Comunicamos ao Gestor(a) #rsAviso1.INP_Responsavel# que está disponível a Pesquisa de Opinião ref. a verificação do controle interno realizada nessa unidade sob o nº de avaliação #rsAviso1.Pes_Inspecao#.<br><br>
			
			&nbsp;&nbsp;&nbsp;Para registro de sua Opinião acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/Pesquisa.cfm?ninsp=#rsAviso1.Pes_Inspecao#&consulta=N">Sistema Nacional de Controle Interno - SNCI</a><br><br>

			&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
			
					</strong>
			</cfmail>	
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Pesquisa_Pos_Avaliacao SET Pes_Ctrl_AvisoA = 1, Pes_dtultatu = CONVERT(char, GETDATE(), 120)
				WHERE Pes_Inspecao ='#rsAviso1.Pes_Inspecao#'	
			</cfquery>					
		</cfloop>
		<!--- aviso 2 --->
		<cfquery name="rsAviso2" datasource="#dsn_inspecao#">
			SELECT Pes_Inspecao, Und_Descricao, INP_Responsavel, Und_Email
			FROM (Pesquisa_Pos_Avaliacao INNER JOIN Inspecao ON Pes_Inspecao = INP_NumInspecao) INNER JOIN Unidades ON INP_Unidade = Und_Codigo 
			WHERE (Pes_GestorNome is Null) and (DATEDIFF(d,GETDATE(),Pes_dtinicio) > 10) and (DATEDIFF(d,GETDATE(),Pes_dtinicio) <= 20) and Pes_Ctrl_AvisoA = 1
			order by Pes_Inspecao
		</cfquery>
		<cfloop query="rsAviso2">
			<cfset rot29b_sdestina = rsAviso2.Und_Email>
			
			<cfif findoneof("@", #trim(rot29b_sdestina)#) eq 0>
				<cfset rot29b_sdestina = "gilvanm@correios.com.br">
			</cfif>

			<cfmail from="SNCI@correios.com.br" to="#rot29b_sdestina#" subject="Pesquisa de Opinião" type="HTML">
					 Mensagem automática. Não precisa responder!<br><br>
					<strong>
					   Ao Gestor(a) do(a) #Ucase(rsAviso2.Und_Descricao)#. <br><br><br>
			
			&nbsp;&nbsp;&nbsp;Comunicamos ao Gestor(a) #rsAviso2.INP_Responsavel# que está disponível a Pesquisa de Opinião ref. a verificação do controle interno realizada nessa unidade sob o nº de avaliação #rsAviso2.Pes_Inspecao#.<br><br>
			
			&nbsp;&nbsp;&nbsp;Para registro de sua Opinião acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/Pesquisa.cfm?ninsp=#rsAviso2.Pes_Inspecao#&consulta=N">Sistema Nacional de Controle Interno - SNCI</a><br><br>

			&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
			
					</strong>
			</cfmail>	
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Pesquisa_Pos_Avaliacao SET Pes_Ctrl_AvisoA = 2, Pes_dtultatu = CONVERT(char, GETDATE(), 120)
				WHERE Pes_Inspecao ='#rsAviso2.Pes_Inspecao#'	
			</cfquery>					
		</cfloop>		
		<cfquery name="rsAviso3" datasource="#dsn_inspecao#">
			SELECT Pes_Inspecao, Und_Descricao, INP_Responsavel, Und_Email
			FROM (Pesquisa_Pos_Avaliacao INNER JOIN Inspecao ON Pes_Inspecao = INP_NumInspecao) INNER JOIN Unidades ON INP_Unidade = Und_Codigo 
			WHERE (Pes_GestorNome is Null) and (DATEDIFF(d,GETDATE(),Pes_dtinicio) > 20) and (DATEDIFF(d,GETDATE(),Pes_dtinicio) <= 31) and Pes_Ctrl_AvisoA = 2
			order by Pes_Inspecao
		</cfquery>	
		<!--- aviso 3 e ultimo --->
		<cfloop query="rsAviso3">
			<cfset rot29c_sdestina = rsAviso3.Und_Email>
			
			<cfif findoneof("@", #trim(rot29c_sdestina)#) eq 0>
				<cfset rot29c_sdestina = "gilvanm@correios.com.br">
			</cfif>

			<cfmail from="SNCI@correios.com.br" to="#rot29c_sdestina#" subject="Pesquisa de Opinião" type="HTML">
					 Mensagem automática. Não precisa responder!<br><br>
					<strong>
					   Ao Gestor(a) do(a) #Ucase(rsAviso3.Und_Descricao)#. <br><br><br>
			
			&nbsp;&nbsp;&nbsp;Comunicamos ao Gestor(a) #rsAviso3.INP_Responsavel# que está disponível a Pesquisa de Opinião ref. a verificação do controle interno realizada nessa unidade sob o nº de avaliação #rsAviso3.Pes_Inspecao#.<br><br>
			
			&nbsp;&nbsp;&nbsp;Para registro de sua Opinião acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/Pesquisa.cfm?ninsp=#rsAviso3.Pes_Inspecao#&consulta=N">Sistema Nacional de Controle Interno - SNCI</a><br><br>

			&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
			
					</strong>
			</cfmail>	
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Pesquisa_Pos_Avaliacao SET Pes_Ctrl_AvisoA = 3, Pes_dtultatu = CONVERT(char, GETDATE(), 120)
				WHERE Pes_Inspecao ='#rsAviso3.Pes_Inspecao#'	
			</cfquery>					
		</cfloop>	
		</cfoutput>		
	</cfif>
	<!-- a partir do dia 15/01/2025 -->
	<cfif rotina eq 30>
		<!--- ajustes de campos para exibição --->
		<cfset aux_mes = month(dtlimit)>
		<cfset anoexerc = year(dtlimit)>
		<!--- Criar linha de metas para o exercício do PACIN --->
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
			  WHERE Met_Codigo ='#rsMetas.Met_Codigo#' AND Met_Ano = #anoexerc# AND Met_Mes = #aux_mes#
		   </cfquery>
		</cfoutput>	

		<!--- PRCI --->
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
			  where (Andt_CodSE = '#rsRegMeta.Met_Codigo#' and Andt_TipoRel = 1 and Andt_AnoExerc = '#anoexerc#' and Andt_Mes <= #aux_mes#)
			  order by Andt_Mes
		   </cfquery>
		   <cfset startTime = CreateTime(0,0,0)> 
		   <cfset endTime = CreateTime(0,0,30)> 
		   <cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		   </cfloop>
		   <cfif rsPRCIBase.recordcount gt 0>
			  <cfset totmesDP = 0>
			  <cfset TOTMESDPFP = 0>
			  <!--- contar unidade DP e FP --->
			  <cfquery dbtype="query" name="rstotmesDP">
				 SELECT Andt_Prazo 
				 FROM  rsPRCIBase
				 where Andt_Prazo = 'DP' and Andt_Mes = #aux_mes#
			  </cfquery>
			  <cfset totmesDP = rstotmesDP.recordcount>

			  <cfquery dbtype="query" name="rsTOTMESDPFP">
				 SELECT Andt_Prazo 
				 FROM rsPRCIBase  
				 where Andt_Mes = #aux_mes#
			  </cfquery>		
			  <cfset TOTMESDPFP = rsTOTMESDPFP.recordcount>

			  <!--- Quant. FP --->
			  <cfset totmesFP = (TOTMESDPFP - totmesDP)>

			  <cfset PercDPmes = '100.0'>
			  <cfif TOTMESDPFP gt 0 and TOTMESDPFP neq totmesDP>
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
			  <!---
					rsRegMeta.Met_Codigo: #rsRegMeta.Met_Codigo#  PercDPmes: #PercDPmes#	metprciacumperiodo: #metprciacumperiodo#<br>			
			  --->
			  <cfquery datasource="#dsn_inspecao#">
				 UPDATE Metas SET Met_PRCI_Acum='#PercDPmes#',Met_PRCI_AcumPeriodo='#metprciacumperiodo#'
				 WHERE Met_Codigo='#rsRegMeta.Met_Codigo#' and Met_Ano = #anoexerc# and Met_Mes = #aux_mes#
			  </cfquery> 
		   <cfelse>
			  <cfquery datasource="#dsn_inspecao#">
				 UPDATE Metas SET Met_PRCI_Acum='100.0',Met_PRCI_AcumPeriodo='100.0'
				 WHERE Met_Codigo='#rsRegMeta.Met_Codigo#' and Met_Ano = #anoexerc# and Met_Mes = #aux_mes#
			  </cfquery> 
		   </cfif> 
		</cfoutput>	

		<!--- fim PRCI --->
		<!---  SLNC, DGCI e MET_RESULTADO  --->
		<cfquery name="rsAno" datasource="#dsn_inspecao#">
		   SELECT Andt_CodSE,Andt_Mes,Andt_Resp
		   FROM Andamento_Temp
		   WHERE Andt_AnoExerc = '#anoexerc#' AND Andt_Mes <= #aux_mes# AND Andt_TipoRel = 2
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
				 SELECT Met_PRCI_Acum, Met_PRCI_AcumPeriodo,Met_DGCI_Mes
				 FROM Metas
				 WHERE Met_Codigo='#rsRegMeta.Met_Codigo#' AND Met_Ano = #anoexerc# AND Met_Mes = #aux_mes#
			  </cfquery>	
			  <!---  gerar o met_slnc_acum e Met_slnc_AcumPeriodo --->
			  <cfset startTime = CreateTime(0,0,0)> 
			  <cfset endTime = CreateTime(0,0,25)> 
			  <cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
			  </cfloop>	
			  
				 <!--- quant. (3-SOL) no mês por SE --->
				 <cfquery dbtype="query" name="rstotmessesol">
					SELECT Andt_Resp 
					FROM  rsAno
					where Andt_Resp = 3 and Andt_CodSE = '#rsRegMeta.Met_Codigo#' and Andt_Mes = #aux_mes#
				 </cfquery>
				  <cfset totmessesol = 0>
				 <cfif rstotmessesol.recordcount gt 0>
					<cfset totmessesol = rstotmessesol.recordcount>
				 </cfif> 
				 <!--- quant. (Pendentes + Tratamentos) no mês por SE --->
				 <cfquery dbtype="query" name="rstotmessependtrat">
					SELECT Andt_Resp 
					FROM  rsAno
					where Andt_Resp <> 3 and Andt_CodSE = '#rsRegMeta.Met_Codigo#' and Andt_Mes = #aux_mes#
				 </cfquery>

				 <cfset totmessependtrat = 0>
				 <cfset totmessegeral = totmessesol + totmessependtrat> 
				 <cfif rstotmessependtrat.recordcount gt 0>
					<cfset totmessependtrat = rstotmessependtrat.recordcount>
					<cfset totmessegeral = totmessesol + totmessependtrat>
				 </cfif>


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
				 <cfset totanosesol = 0>
				 <cfif rstotmessependtrat.recordcount gt 0>
					<cfset totanosesol = rstotanosesol.recordcount>
				 </cfif>
				 

				 <!--- quant. (Pendentes + Tratamentos) no ano por SE --->
				 <cfquery dbtype="query" name="rstotanosependtrat">
					SELECT Andt_Resp 
					FROM  rsAno
					where Andt_Resp <> 3 and Andt_CodSE = '#rsRegMeta.Met_Codigo#'
				 </cfquery>
				 <cfset totanosependtrat = 0>
				 <cfif rstotanosependtrat.recordcount gt 0>
					<cfset totanosependtrat = rstotanosependtrat.recordcount>
				 </cfif>

				 <cfset totanosegeral = totanosesol + totanosependtrat>

				 <cfset slnc_acperiodo = '100.0'>
				 <cfif totanosegeral gt 0>
					<cfset slnc_acperiodo = trim(NumberFormat(((totanosesol/totanosegeral) * 100),999.0))>
				 </cfif>

				 <cfset auxmetprciacumper = rsprciacum.Met_PRCI_AcumPeriodo>
				 <cfset dgci_acperiodo = trim(numberFormat((slnc_acperiodo * 0.45) + (auxmetprciacumper * 0.55),999.0))>  
				 <cfset MetasResult = trim(NumberFormat(((dgci_acperiodo/rsprciacum.Met_DGCI_Mes) * 100),000.0))>
								  
			  <!---
			  ANO:#anoexerc#' Met_Mes = #aux_mes# Met_Codigo='#rsRegMeta.Met_Codigo#' Met_SLNC_Acum= '#slnc_acummes#' Met_SLNC_AcumPeriodo='#slnc_acperiodo#' Met_DGCI_Acum='#dgci_acummes#',Met_DGCI_AcumPeriodo='#dgci_acperiodo#',Met_Resultado='#MetasResult#'<BR>    
			  --->
			  <cfquery datasource="#dsn_inspecao#">
				 UPDATE Metas SET Met_SLNC_Acum= '#slnc_acummes#',Met_SLNC_AcumPeriodo='#slnc_acperiodo#',Met_DGCI_Acum='#dgci_acummes#',Met_DGCI_AcumPeriodo='#dgci_acperiodo#',Met_Resultado='#MetasResult#'
				 WHERE Met_Codigo='#rsRegMeta.Met_Codigo#' and Met_Ano = '#anoexerc#' and Met_Mes = #aux_mes#
			  </cfquery> 
		
		   </cfoutput>	
		   <!--- FIM  SLNC, DGCI e MET_RESULTADO --->
		   <!--- fim ajustes de campos para exibição --->
   </cfif>	
	<!---  até 14/01/2025
	<cfif rotina eq 30>
		<!--- ajustes de campos para exibição --->
		<cfset aux_mes = month(dtlimit)>
		<cfset anoexerc = year(dtlimit)>
		<!--- Criar linha de metas para o exercício do PACIN --->
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
				WHERE Met_Codigo ='#rsMetas.Met_Codigo#' AND Met_Ano = #anoexerc# AND Met_Mes = #aux_mes#
			</cfquery>
		</cfoutput>	

		<!--- PRCI --->
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
				where (Andt_CodSE = '#rsRegMeta.Met_Codigo#' and Andt_TipoRel = 1 and Andt_AnoExerc = '#anoexerc#' and Andt_Mes <= #aux_mes#)
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
					where Andt_Prazo = 'DP' and Andt_Mes = #aux_mes#
				</cfquery>
				<cfset totmesDP = rstotmesDP.recordcount>

				<cfquery dbtype="query" name="rsTOTMESDPFP">
					SELECT Andt_Prazo 
					FROM rsPRCIBase  
					where Andt_Mes = #aux_mes#
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
				<!---
						rsRegMeta.Met_Codigo: #rsRegMeta.Met_Codigo#  PercDPmes: #PercDPmes#	metprciacumperiodo: #metprciacumperiodo#<br>			
				--->
				<cfquery datasource="#dsn_inspecao#">
					UPDATE Metas SET Met_PRCI_Acum='#PercDPmes#',Met_PRCI_AcumPeriodo='#metprciacumperiodo#'
					WHERE Met_Codigo='#rsRegMeta.Met_Codigo#' and Met_Ano = #anoexerc# and Met_Mes = #aux_mes#
				</cfquery>  
		</cfoutput>	
			<!--- fim PRCI --->
			<!---  SLNC, DGCI e MET_RESULTADO  --->
		<cfquery name="rsAno" datasource="#dsn_inspecao#">
			SELECT Andt_CodSE,Andt_Mes,Andt_Resp
			FROM Andamento_Temp
			WHERE Andt_AnoExerc = '#anoexerc#' AND Andt_Mes <= #aux_mes# AND Andt_TipoRel = 2
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
				SELECT Met_PRCI_Acum, Met_PRCI_AcumPeriodo,Met_DGCI_Mes
				FROM Metas
				WHERE Met_Codigo='#rsRegMeta.Met_Codigo#' AND Met_Ano = #anoexerc# AND Met_Mes = #aux_mes#
			</cfquery>		
			<!--- quant. (3-SOL) no mês por SE --->
			<cfquery dbtype="query" name="rstotmessesol">
				SELECT Andt_Resp 
				FROM  rsAno
				where Andt_Resp = 3 and Andt_CodSE = '#rsRegMeta.Met_Codigo#' and Andt_Mes = #aux_mes#
			</cfquery>
			<cfset totmessesol = rstotmessesol.recordcount>
			<!--- quant. (Pendentes + Tratamentos) no mês por SE --->
			<cfquery dbtype="query" name="rstotmessependtrat">
				SELECT Andt_Resp 
				FROM  rsAno
				where Andt_Resp <> 3 and Andt_CodSE = '#rsRegMeta.Met_Codigo#' and Andt_Mes = #aux_mes#
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

			<cfset MetasResult = numberFormat((dgci_acummes / rsprciacum.Met_DGCI_Mes)*100,999.0)>
			<!---
			ANO:#anoexerc#' Met_Mes = #aux_mes# Met_Codigo='#rsRegMeta.Met_Codigo#' Met_SLNC_Acum= '#slnc_acummes#' Met_SLNC_AcumPeriodo='#slnc_acperiodo#' Met_DGCI_Acum='#dgci_acummes#',Met_DGCI_AcumPeriodo='#dgci_acperiodo#',Met_Resultado='#MetasResult#'<BR>    
			--->
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Metas SET Met_SLNC_Acum= '#slnc_acummes#',Met_SLNC_AcumPeriodo='#slnc_acperiodo#',Met_DGCI_Acum='#dgci_acummes#',Met_DGCI_AcumPeriodo='#dgci_acperiodo#',Met_Resultado='#MetasResult#'
				WHERE Met_Codigo='#rsRegMeta.Met_Codigo#' and Met_Ano = '#anoexerc#' and Met_Mes = #aux_mes#
			</cfquery> 
		</cfoutput>	
		<!--- FIM  SLNC, DGCI e MET_RESULTADO --->
		<!--- fim ajustes de campos para exibição --->
	</cfif>		
	--->
	<cfif rotina eq 31>	
	<cfoutput>
		<!--- envio por e-mail das conclusões de revisão no dia anterior --->
		<cfquery name="rsfimRevisao" datasource="#dsn_inspecao#">
			SELECT INP_NumInspecao
			FROM Inspecao
			WHERE INP_DTConcluirRevisao='#dateformat(dtlimit,"YYYY-MM-DD")#'
		</cfquery>
		<cfloop query="rsfimRevisao">
			<!--- Início - e-mail automático por unidade com NC --->
			<cfquery name="rsEnvio" datasource="#dsn_inspecao#">
				SELECT Usu_Email, Und_Email, Fun_Email, Rep_Email, INP_NumInspecao, INP_Unidade, INP_DTConcluirRevisao, Und_TipoUnidade, Und_Descricao, Und_CodReop, INP_DtInicInspecao, INP_Coordenador
				FROM (Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
				INNER JOIN Reops ON Und_CodReop = Rep_Codigo 
				INNER JOIN Usuarios ON INP_UserName = Usu_Login
				INNER JOIN Funcionarios ON INP_Coordenador = Fun_Matric 
				WHERE INP_NumInspecao = '#rsfimRevisao.INP_NumInspecao#'
			</cfquery>
			<cfset startTime = CreateTime(0,0,0)> 
			<cfset endTime = CreateTime(0,0,45)> 
			<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
			</cfloop> 
			<cfset sdestina =''>
				
			<cfset emailrevisor = #rsEnvio.Usu_Email#>
			<cfset emailunid = #rsEnvio.Und_Email#>
			<cfset emailreopunid = #rsEnvio.Rep_Email#>
			<cfset emailcoord = #rsEnvio.Fun_Email#>
			<cfset emailscoi="">

			<!--- adquirir o email do SCOI da SE --->
			<cfset scoi_se = left(rsEnvio.INP_Unidade,2)>
			<cfif scoi_se eq '03' or scoi_se eq '05' or scoi_se eq '65'>
				<cfset scoi_se = '10'>
			<cfelseif scoi_se eq '70'>
				<cfset scoi_se = '04'>						 					 				 
			</cfif>

			<cfquery name="rsSCOIEmail" datasource="#dsn_inspecao#">
				SELECT Ars_Email
				FROM Areas
				WHERE left(Ars_Codigo,2) = '#scoi_se#'  and (Ars_Descricao Like '%SEC AVAL CONT INTERNO/SGCIN%')
			</cfquery>
			<cfset startTime = CreateTime(0,0,0)> 
			<cfset endTime = CreateTime(0,0,15)> 
			<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
			</cfloop>
			<cfset emailscoi = #rsSCOIEmail.Ars_Email#>
				
			<cfif emailunid neq "">
				<cfset sdestina = #sdestina# & ';' & #emailunid#>
			</cfif>

			<cfif emailreopunid neq "">
				<cfset sdestina = #sdestina# & ';' & #emailreopunid#>
			</cfif>

			<cfif emailcoord neq "">
				<cfset sdestina = #sdestina# & ';' & #emailcoord#>
			</cfif>

			<cfif emailrevisor neq "">
				<cfset sdestina = #sdestina# & ';' & #emailrevisor#>
			</cfif>
			
			<cfset sdestina = #sdestina# & ';' & #emailscoi#>

			<cfif findoneof("@", trim(sdestina)) eq 0>
				<cfset sdestina = "gilvanm@correios.com.br">
			</cfif>

			
			<cfset assunto = 'Relatório de Controle Interno - ' & #trim(rsEnvio.Und_Descricao)# & ' - Avaliação de Controle Interno ' & #rsEnvio.INP_NumInspecao#>
			<cfquery name="rsNC" datasource="#dsn_inspecao#">
				SELECT Pos_Inspecao
				FROM ParecerUnidade
				WHERE Pos_Inspecao='#rsEnvio.INP_NumInspecao#'
			</cfquery>
			<cfif rsNC.recordcount gt 0>			
				<cfif rsEnvio.Und_TipoUnidade neq 12 and rsEnvio.Und_TipoUnidade neq 16>  	
					<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
						Mensagem automática. Não precisa responder!<br><br>
						<strong>
						Prezado(a) Gerente do(a) #trim(Ucase(rsEnvio.Und_Descricao))#, informamos que está disponível na intranet o Relatório de Controle Interno: Nº #rsEnvio.INP_NumInspecao#, realizada nessa Unidade na Data: #dateformat(rsEnvio.INP_DtInicInspecao,"dd/mm/yyyy")#. <br><br>

						&nbsp;&nbsp;&nbsp;Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:<br><br>

						&nbsp;&nbsp;&nbsp;a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA); <br>

						&nbsp;&nbsp;&nbsp;b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;<br>

						&nbsp;&nbsp;&nbsp;c) Anexar no sistema os Comprovantes de regularização da situação encontrada e/ou das Ações implementadas (em PDF).<br><br>

						&nbsp;&nbsp;&nbsp;Registrar a resposta no Sistema Nacional de Controle Interno - SNCI  num prazo de dez (10) dias úteis, contados a partir da data de entrega do Relatório. <br>
						&nbsp;&nbsp;&nbsp;O não cumprimento ensejará em perda de prazo.<br><br>

						&nbsp;&nbsp;&nbsp;Acesse o SNCI endereço: (http://intranetsistemaspe/snci/rotinas_inspecao.cfm) ou clique no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório de Controle Interno.</a><br><br>

						&nbsp;&nbsp;&nbsp;Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação. <br><br>

						&nbsp;&nbsp;&nbsp;Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:  #emailscoi#.<br><br>
						<table>
							<tr>
								<td><strong>Unidade : #rsEnvio.INP_Unidade# - #rsEnvio.Und_Descricao#</strong></td>
							</tr>
							<tr>
								<td><strong>Relatório: #rsEnvio.INP_NumInspecao#</strong></td>
							</tr>
							<tr>
								<td><strong>------------------------------------------</strong></td>
							</tr>
						</table>
						<br>
						&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
						</strong>
					</cfmail>
					<cfset posparecer = DateFormat(rsEnvio.INP_DTConcluirRevisao,"DD/MM/YYYY") & '>Conclusão da Revisão e Liberação da Avaliação' & CHR(13) & CHR(13)
					& 'Prezado(a) Gerente do(a)' & #trim(Ucase(rsEnvio.Und_Descricao))# & ', informamos que está disponível na intranet o Relatório de Controle Interno: Nº' & #rsEnvio.INP_NumInspecao# & ', realizada nessa Unidade na Data: ' & #dateformat(rsEnvio.INP_DtInicInspecao,"dd/mm/yyyy")# & CHR(13) & CHR(13) 
					& 'Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:' & CHR(13) & CHR(13) 
					& 'a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA);' & CHR(13) 
					& 'b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;' & CHR(13) 
					& 'c) Anexar no sistema os Comprovantes de regularização da situação encontrada e/ou das Ações implementadas (em PDF).' & CHR(13) & CHR(13) 
					& 'Registrar a resposta no Sistema Nacional de Controle Interno - SNCI num prazo de dez (10) dias úteis, contados a partir da data de entrega do Relatório.' & CHR(13) 
					& 'O não cumprimento ensejará em perda de prazo.' & CHR(13) & CHR(13) 
					& 'Acesse o SNCI endereço: (http://intranetsistemaspe/snci/rotinas_inspecao.cfm) ou clique no link: Relatório de Controle Interno.' & CHR(13) & CHR(13) 
					& 'Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação.' & CHR(13) & CHR(13) 
					& 'Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:' & CHR(13) & CHR(13) 
					& 'Unidade : ' & #rsEnvio.INP_Unidade# & '-' & #rsEnvio.Und_Descricao# & CHR(13) 
					& 'Relatório:' &  #rsEnvio.INP_NumInspecao# 
					& CHR(13) & CHR(13) & 'Desde já agradecemos a sua atenção.' 
					& CHR(13)
					& '-----------------------------------------------------------------------------------------------------------------------'>
				<cfelse>
					<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
						Mensagem automática. Não precisa responder!<br><br>
						<strong>
						Prezado(a) Gerente do(a) #trim(Ucase(rsEnvio.Und_Descricao))#, informamos que está disponível na intranet o Relatório de Controle Interno: Nº #rsEnvio.INP_NumInspecao#, realizada nessa Unidade na Data: #dateformat(rsEnvio.INP_DtInicInspecao,"dd/mm/yyyy")#. <br><br>

						&nbsp;&nbsp;&nbsp;Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:<br><br>

						&nbsp;&nbsp;&nbsp;a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA); <br>

						&nbsp;&nbsp;&nbsp;b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;<br>

						&nbsp;&nbsp;&nbsp;c) Anexar no sistema os Comprovantes de regularização da situação encontrada e/ou das Ações implementadas (em PDF).<br><br>

						&nbsp;&nbsp;&nbsp;Registrar a resposta no Sistema Nacional de Controle Interno - SNCI  num prazo de dez (10) dias úteis, contados a partir da data de entrega do Relatório. <br>
						&nbsp;&nbsp;&nbsp;O não cumprimento ensejará em perda de prazo.<br><br>

						&nbsp;&nbsp;&nbsp;Acesse o SNCI endereço: (http://intranetsistemaspe/snci/rotinas_inspecao.cfm) ou clique no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório de Controle Interno.</a><br><br>

						&nbsp;&nbsp;&nbsp;Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação, <br>
						&nbsp;&nbsp;&nbsp;desde que esteja dentro do prazo de 30 dias úteis a contar da entrega do Relatório. <br><br>   

						&nbsp;&nbsp;&nbsp;Após esse prazo, a situação será direcionada diretamente para área gestora do Contrato de Terceirizadas para adoção das ações previstas em contrato. <br><br>                      

						&nbsp;&nbsp;&nbsp;Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:  #emailscoi#.<br><br>

						<table>
						<tr>
						<td><strong>Unidade : #rsEnvio.INP_Unidade# - #rsEnvio.Und_Descricao#</strong></td>
						</tr>
						<tr>
						<td><strong>Relatório: #rsEnvio.INP_NumInspecao#</strong></td>
						</tr>
						<tr>
						<td><strong>------------------------------------------</strong></td>
						</tr>
						</table>
						<br>
						&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
						</strong>
					</cfmail>
		
					<cfset posparecer = DateFormat(rsEnvio.INP_DTConcluirRevisao,"DD/MM/YYYY") & '>Conclusão da Revisão e Liberação da Avaliação' & CHR(13) & CHR(13)
					& 'Prezado(a) Gerente do(a)' & #trim(Ucase(rsEnvio.Und_Descricao))# & ', informamos que está disponível na intranet o Relatório de Controle Interno: Nº' & #rsEnvio.INP_NumInspecao# & ', realizada nessa Unidade na Data: ' & #dateformat(rsEnvio.INP_DtInicInspecao,"dd/mm/yyyy")# & CHR(13) & CHR(13) 
					& 'Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:' & CHR(13) & CHR(13) 
					& 'a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA);' & CHR(13) 
					& 'b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;' & CHR(13) 
					& 'c) Anexar no sistema os Comprovantes de regularização da situação encontrada e/ou das Ações implementadas (em PDF).' & CHR(13) & CHR(13) 
					& 'Registrar a resposta no Sistema Nacional de Controle Interno - SNCI num prazo de dez (10) dias úteis, contados a partir da data de entrega do Relatório.' & CHR(13) 
					& 'O não cumprimento ensejará em perda de prazo.' & CHR(13) & CHR(13) 
					& 'Acesse o SNCI endereço: (http://intranetsistemaspe/snci/rotinas_inspecao.cfm) ou clique no link: Relatório de Controle Interno.' & CHR(13) & CHR(13) 
					& 'Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação.' & CHR(13) 
					& 'Desde que esteja dentro do prazo de 30 dias úteis a contar da entrega do Relatório.' & CHR(13) & CHR(13) 
					& 'Após esse prazo, a situação será direcionada diretamente para área gestora do Contrato de Terceirizadas para adoção das ações previstas em contrato.' & CHR(13) & CHR(13) 
					& 'Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:' & CHR(13) & CHR(13) 
					& 'Unidade : ' & #rsEnvio.INP_Unidade# & '-' & #rsEnvio.Und_Descricao# & CHR(13) 
					& 'Relatório:' &  #rsEnvio.INP_NumInspecao# 
					& CHR(13) & CHR(13) & 'Desde já agradecemos a sua atenção.' 
					& CHR(13)
					& '-----------------------------------------------------------------------------------------------------------------------'>      
				</cfif>          
				<!--- Update na tabela parecer unidade --->
				<cfquery datasource="#dsn_inspecao#">
					UPDATE ParecerUnidade SET Pos_Parecer = '#posparecer#'
					WHERE Pos_Inspecao='#rsEnvio.INP_NumInspecao#' and Pos_Situacao_Resp = 14
				</cfquery>    		    
			<cfelse>	
					<!--- SEM NC --->
				<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
					Mensagem automática. Não precisa responder!<br><br>
					<strong>
					Prezado(a) Gerente do(a) #trim(Ucase(rsEnvio.Und_Descricao))#<br><br>
					&nbsp;&nbsp;&nbsp;informamos que não houve Não Conformidades no Relatório de Controle Interno: Nº #rsEnvio.INP_NumInspecao#, realizada nessa Unidade na Data: #dateformat(rsEnvio.INP_DtInicInspecao,"dd/mm/yyyy")#. <br><br>
					&nbsp;&nbsp;&nbsp;Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico: #emailscoi#.<br><br>
					<br>
					&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
					</strong>
				</cfmail>   			
			</cfif>
		</cfloop>		
	</cfoutput>		
	</cfif>
	<cfif rotina eq 32>
		 <cfquery datasource="#dsn_inspecao#">
		  UPDATE AvisosGrupos SET AVGR_status = 'D', AVGR_DT_DES = convert(char, getdate(), 102) WHERE AVGR_status = 'A' and AVGR_DT_FINAL < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')
		 </cfquery> 
	</cfif>	
	<cfif rotina eq 33>
		<cfset auxdt = dateformat(now(),"YYYYMMDD")>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Mensagem SET MSG_Realizado = '#auxdt#', MSG_Status = 'D' WHERE MSG_Codigo = 1
		</cfquery>	
		<cflocation url="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">	
	</cfif>		
	<!---  --->
    <cfset rotina = rotina + 1> 
</cfloop>   
<!--- Fim loop Geral--->
