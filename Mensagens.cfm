<cfprocessingdirective pageEncoding ="utf-8"/>
<!--- <cfif int(day(now())) is 1>
<p>=================== Aguarde! =======================</p>
<p>============== SNCI em  Manutencao! =================</p>
<p>============== Previsão de retorno às 08h =================</p>
<cfabort>
</cfif>
<cfset gil = gil> --->

<!--- Criação do registro de log em formato CSV --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<!--- <cfset diretorio ="\\sac1887\sistemas$\GMAT01\Pernambuco\SNCI\">
<cfset slocal = #diretorio# & 'Dados\'>
<cfset sarquivo = 'REG_LOG_SNCI.csv'>
<cfif fileExists(#slocal# & sarquivo)>
<cfelse>
	<cffile action="Append" file="#slocal##sarquivo#" output='DTHORA_ATUALIZ;NOME DA TELA;AÇÃO;RESULTADO DA AÇÃO'>
</cfif>
 --->

<cfsetting requesttimeout="15000">

<cfset auxdt = dateformat(now(),"YYYYMMDD")>
<cfquery name="rsDia" datasource="#dsn_inspecao#">
  SELECT MSG_Realizado, MSG_Status FROM Mensagem WHERE MSG_Codigo = 1
</cfquery>
<cfif rsDia.MSG_Status is 'A'>
		 <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=Sr(a) USUARIO(a), AGUARDE! EM POUCOS MINUTOS SERA LIBERADO O ACESSO, SNCI EM MANUTENCAO">
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
	<cfset dtdezdiasuteis = CreateDate(year(now()),month(now()),day(now()))>
	<cfset nCont = 0>
	<cfloop condition="nCont lt 10">
		<cfset nCont = nCont + 1>
		<cfset dtdezdiasuteis = DateAdd( "d", 1, dtdezdiasuteis)>
		<cfset vDiaSem = DayOfWeek(dtdezdiasuteis)>
		<cfif vDiaSem neq 1 and vDiaSem neq 7>
			<!--- verificar se Feriado Nacional --->
			<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
				 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtdezdiasuteis#
			</cfquery>
			<cfif rsFeriado.recordcount gt 0>
			   <cfset nCont = nCont - 1>
			</cfif>
		</cfif>
		<!--- Verifica se final de semana  --->
		<cfif vDiaSem eq 1 or vDiaSem eq 7>
			<cfset nCont = nCont - 1>
		</cfif>	
	</cfloop>
</cfif>
 
<cfloop condition="rotina lte 28">   
	<!--- copiar Parecerunidade  --->
	<cfif rotina eq 1>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- 24/05/2022 --->
		<cfset dtlimit = CreateDate(year(now()),month(now()),day(now()))> 
		<!---  <cfset dtlimit = CreateDate(2022,6,3)> ---> 
		<cfset aux_mes = month(dtlimit)>
		<!---  --->
		<cfif aux_mes is 1>
		   <cfset anoantes =  (year(dtlimit) - 1)>
		   <cfset dtini = CreateDate(anoantes,12,1)>		
		   <cfset dtfim = CreateDate(anoantes,12,31)>
		<cfelseif aux_mes is 2>
			<cfset dtini = CreateDate(year(dtlimit),1,1)>
			<cfset dtfim = CreateDate(year(dtlimit),1,31)>	
		<cfelseif aux_mes is 3>
			<cfif int(year(dtlimit)) mod 4 is 0>
			   <cfset dtfim = CreateDate(year(dtlimit),2,29)>
			<cfelse>
			   <cfset dtfim = CreateDate(year(dtlimit),2,28)>
			</cfif>
			<cfset dtini = CreateDate(year(dtlimit),2,1)>				
		<cfelseif aux_mes is 4>
		   <cfset dtini = CreateDate(year(dtlimit),3,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),3,31)>	
		<cfelseif aux_mes is 5>
		   <cfset dtini = CreateDate(year(dtlimit),4,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),4,30)>		
		<cfelseif aux_mes is 6>
		   <cfset dtini = CreateDate(year(dtlimit),5,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),5,31)>				
		<cfelseif aux_mes is 7>
		   <cfset dtini = CreateDate(year(dtlimit),6,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),6,30)>	
		<cfelseif aux_mes is 8>
		   <cfset dtini = CreateDate(year(dtlimit),7,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),7,31)>		
		<cfelseif aux_mes is 9>
		   <cfset dtini = CreateDate(year(dtlimit),8,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),8,31)>				
		<cfelseif aux_mes is 10>
		   <cfset dtini = CreateDate(year(dtlimit),9,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),9,30)>	
		<cfelseif aux_mes is 11>
		   <cfset dtini = CreateDate(year(dtlimit),10,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),10,31)>		
		<cfelseif aux_mes is 12>
		   <cfset dtini = CreateDate(year(dtlimit),11,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),11,30)>		
		</cfif>	
		<!---  --->
		<!--- <cfoutput>#dtlimit#  dtini:#dtini#  dtfim #dtfim#</cfoutput> --->
		<cfif day(dtlimit) lte 5> 
			<cfquery datasource="#dsn_inspecao#" name="rsMesOK">
				Select Pos_Unidade 
				from SLNCPRCIDCGIMES 
				where Pos_DtPosic between #dtini# and #dtfim# 
			</cfquery>	
			<cfif rsMesOK.recordcount lte 0>
			<!--- 	<cfset gil = gil> --->
				<cfquery name="rs3SO" datasource="#dsn_inspecao#">
					SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, pos_dtultatu, pos_username, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
					FROM ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
					WHERE Pos_Situacao_Resp = 3 and Pos_DtPosic between #dtini# and #dtfim# 
				</cfquery>		
				
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
							insert into SLNCPRCIDCGIMES (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao, pos_username, Pos_Area, Pos_NomeArea, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes) values ('#rs3SO.Pos_Unidade#', '#rs3SO.Pos_Inspecao#', #rs3SO.Pos_NumGrupo#, #rs3SO.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rs3SO.Pos_Situacao#', '#rs3SO.pos_username#', '#rs3SO.Pos_Area#', '#rs3SO.Pos_NomeArea#', #PosDtPrevSolucao#, #PosPontuacaoPonto#, '#PosClassificacaoPonto#', #auxantes#)
						</cfquery>		
				</cfloop>	
				
				<!--- NAO RESPONDIDO   PENDENTES E TRATAMENTOS --->
				<cfquery name="rsNRPENDTRAT" datasource="#dsn_inspecao#">
					SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, pos_dtultatu, pos_username, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
					FROM ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
					WHERE Pos_Situacao_Resp In (14,2,4,5,8,15,16,18,19,20,23) 
				</cfquery>			
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
							insert into SLNCPRCIDCGIMES (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao, pos_username, Pos_Area, Pos_NomeArea, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes) values ('#rsNRPENDTRAT.Pos_Unidade#', '#rsNRPENDTRAT.Pos_Inspecao#', #rsNRPENDTRAT.Pos_NumGrupo#, #rsNRPENDTRAT.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rsNRPENDTRAT.Pos_Situacao#', '#rsNRPENDTRAT.pos_username#', '#rsNRPENDTRAT.Pos_Area#', '#rsNRPENDTRAT.Pos_NomeArea#', #PosDtPrevSolucao#, #PosPontuacaoPonto#, '#PosClassificacaoPonto#', #auxantes#)
						</cfquery>	
				</cfloop>	
			
				<!--- RESPOSTAS, CS, PI, OC, RV, AP, RC, NC, BX, EA, EC e TP (DENTRO DO MES)--->	
				<cfquery name="rsOutros" datasource="#dsn_inspecao#">
					SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, pos_dtultatu, pos_username, Pos_Area, Pos_NomeArea, Und_TipoUnidade, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
					FROM ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
					WHERE Pos_Situacao_Resp In (1,6,7,17,22,9,10,12,13,21,24,25,26,27,28,29,30) and Pos_DtPosic between #dtini# and #dtfim# 
				</cfquery>
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
							insert into SLNCPRCIDCGIMES (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao, pos_username, Pos_Area, Pos_NomeArea, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes) values ('#rsOutros.Pos_Unidade#', '#rsOutros.Pos_Inspecao#', #rsOutros.Pos_NumGrupo#, #rsOutros.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rsOutros.Pos_Situacao#', '#rsOutros.pos_username#', '#rsOutros.Pos_Area#', '#rsOutros.Pos_NomeArea#', #PosDtPrevSolucao#, #PosPontuacaoPonto#, '#PosClassificacaoPonto#', #auxantes#)
						</cfquery>		
				</cfloop>		 
		 </cfif>  
	<!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 1;GERAR INDICADORES SLNC e PRCI SALVAR PARACERUNIDADE para SLNCPRCIDCGIMES'> --->		 
 </cfif>
</cfif>
<!---  --->

	<!--- ************** MUDAR STATUS ****************** --->
	<!--- ###### UNIDADES ###### --->
	<!--- para PENDENTE --->
	<cfif rotina eq 2 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- Todas mudanças de Status deverão ter registros nos campos (Pos_Paracer(Cumulativo) e And_Parecer(individual)) --->
		<!--- Mudar o Status de 14 para 2-PU (Próprias) ou 20-PF(TERCEIRAS TIPOUNID= 12 OU 16) --->
		<!--- CONDIÇÃO: Quando o campo: Pos_DtPrev_Solucao estiver vencido dos 10 dias úteis concedidos --->
		<cfquery name="rs14NR2PU20PF" datasource="#dsn_inspecao#">
			SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Parecer, Und_Email, Und_TipoUnidade, Und_Descricao, Und_Centraliza, Rep_Email
			FROM Unidades 
			INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
			INNER JOIN Reops ON Und_CodReop = Rep_Codigo
			WHERE (Pos_Situacao_Resp = 14) and 
			(Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and (Pos_DtPosic <> Pos_DtPrev_Solucao)
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>

	  <cfoutput query="rs14NR2PU20PF">
		 <!--- Atribuir o novo status --->
		 <cfif rs14NR2PU20PF.Und_TipoUnidade is 12 || rs14NR2PU20PF.Und_TipoUnidade is 16>
		   <!--- TERCEIRIZADA --->
		   <cfset rot2_IDStatus = 20>
		   <cfset rot2_SglStatus = 'PF'>
		   <cfset rot2_DescStatus = 'PENDENTE DE TERCEIRIZADA'>
		 <cfelse>
		   <!--- Proprias --->
		   <cfset rot2_IDStatus = 2>
		   <cfset rot2_SglStatus = 'PU'>
		   <cfset rot2_DescStatus = 'PENDENTE DA UNIDADE'>
		 </cfif>
		   <cfset aux_posarea = rs14NR2PU20PF.Pos_Area>
		   <cfset aux_posnomearea = rs14NR2PU20PF.Pos_NomeArea>
	
	 <!--- Opiniao da CCOP --->
	 <cfset Encaminhamento = "Opinião do Controle Interno">
	 <cfset sinformes = 'Em virtude da ausência de manifestação desse gestor, estamos transferindo a Situação Encontrada para o Status ' & #rot2_DescStatus# & CHR(13) & ' Com cobranças diárias, por e-mail, até o registro de sua resposta no sistema.'   & CHR(13) & ' Após 30 dias úteis a contar na data do recebimento do Relatório de Controle Interno o ponto será repassado, automaticamente, para o Órgão Subordinador.'>
	 <cfset aux_obs = #rs14NR2PU20PF.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: ' & #rot2_DescStatus# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
		 <cfquery datasource="#dsn_inspecao#">
		   UPDATE ParecerUnidade SET Pos_Area = '#aux_posarea#', Pos_NomeArea = '#aux_posnomearea#', Pos_Situacao_Resp = #rot2_IDStatus#, Pos_Situacao = '#rot2_SglStatus#', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dtatual#, Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 14 WHERE Pos_Unidade='#rs14NR2PU20PF.Pos_Unidade#' AND Pos_Inspecao='#rs14NR2PU20PF.Pos_Inspecao#' AND Pos_NumGrupo=#rs14NR2PU20PF.Pos_NumGrupo# AND Pos_NumItem=#rs14NR2PU20PF.Pos_NumItem#
		 </cfquery>
		 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: ' & #rot2_DescStatus# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
		 <cfquery datasource="#dsn_inspecao#">
		   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs14NR2PU20PF.Pos_Inspecao#', '#rs14NR2PU20PF.Pos_Unidade#', #rs14NR2PU20PF.Pos_NumGrupo#, #rs14NR2PU20PF.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', #rot2_IDStatus#, convert(char, getdate(), 108), '#and_obs#', '#aux_posarea#')
		 </cfquery>
	</cfoutput> 
	  <!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 2;Mudar o Status de 14 para 2(Proprias) ou 20(AGF) cuja Pos_DtPrev_Solucao esta vencida'> --->		
  </cfif> 

	<!--- DE 15-TU - TRATAMENTO PARA 2-PU-PENDENTE OU 16-TS-Órgão SUBORDINADOR--->
	<!--- PROPRIAS --->
	<cfif rotina eq 3 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- Mudar de Status 15-TU para o Status 2-PU OU 16-TS --->
		<cfquery name="rs15TU_2PU16TS" datasource="#dsn_inspecao#">
		SELECT Und_Centraliza, Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Parecer, Und_Email, Und_TipoUnidade, Und_Descricao, Rep_Codigo, Rep_Nome
		FROM Unidades 
		INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
		INNER JOIN Reops ON Und_CodReop = Rep_Codigo
		WHERE (Pos_Situacao_Resp=15) and (Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and (Pos_DtPosic <> Pos_DtPrev_Solucao)
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
				
				<cfset sinformes = 'Em virtude da ausência de conclusão do Item da Avaliação no Status TRATAMENTO UNIDADE pelo(a) Gestor(a) da unidade: ' & #trim(rs15TU_2PU16TS.Und_Descricao)# & CHR(13) & ', no prazo solicitado até ' & #DateFormat(rs15TU_2PU16TS.Pos_DtPrev_Solucao,"DD/MM/YYYY")# & ', estamos modificando-o para o Status de TRATAMENTO ORGAO SUBORDINADOR e no aguardo do Aprimoramento para às devidas providências até ' & #DateFormat(dtdezdiasuteis,"DD/MM/YYYY")# & '.'>
							 				
				<cfset aux_obs = #rs15TU_2PU16TS.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rsOrg.Rep_Nome# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: TRATAMENTO ORGAO SUBORDINADOR' & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtdezdiasuteis,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			  <cfquery datasource="#dsn_inspecao#">
			   UPDATE ParecerUnidade SET Pos_Situacao_Resp = 16, Pos_Situacao = 'TS', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dtdezdiasuteis#, Pos_Area = '#rsOrg.Rep_Codigo#', Pos_NomeArea = '#rsOrg.Rep_Nome#', Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 15 WHERE Pos_Unidade='#rs15TU_2PU16TS.Pos_Unidade#' AND Pos_Inspecao='#rs15TU_2PU16TS.Pos_Inspecao#' AND Pos_NumGrupo=#rs15TU_2PU16TS.Pos_NumGrupo# AND Pos_NumItem=#rs15TU_2PU16TS.Pos_NumItem#
			 </cfquery>
			 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rsOrg.Rep_Nome# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: TRATAMENTO ORGAO SUBORDINADOR' & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtdezdiasuteis,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			 <cfquery datasource="#dsn_inspecao#">
			   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs15TU_2PU16TS.Pos_Inspecao#', '#rs15TU_2PU16TS.Pos_Unidade#', #rs15TU_2PU16TS.Pos_NumGrupo#, #rs15TU_2PU16TS.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 16, convert(char, getdate(), 108), '#and_obs#', '#rsOrg.Rep_Codigo#')
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
				<cfquery datasource="#dsn_inspecao#">
					insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs15TU_2PU16TS.Pos_Inspecao#', '#rs15TU_2PU16TS.Pos_Unidade#', #rs15TU_2PU16TS.Pos_NumGrupo#, #rs15TU_2PU16TS.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 2, convert(char, getdate(), 108), '#and_obs#', '#rs15TU_2PU16TS.Pos_Area#')
				</cfquery>				 	
		   </cfif>  
		</cfoutput> 
    	<!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 3;Mudar de Status 15-TU para o Status 2-PU OU 16-TS'>	 --->	
	</cfif>	
	<cfif rotina eq 4 and rotinaSN is 'S'>
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
				  
				<cfset sinformes = 'Em virtude da ausência de conclusão do Item da Avaliação no Status PENDENTE DA UNIDADE pelo(a) Gestor(a) da unidade: ' & #trim(rs2PU_16TS.Und_Descricao)# & CHR(13) & ', no prazo solicitado, estamos modificando-o para o Status de TRATAMENTO ORGAO SUBORDINADOR e no aguardo do Aprimoramento para às devidas providências até ' & #DateFormat(dtdezdiasuteis,"DD/MM/YYYY")# & '.'>
							 				
				<cfset aux_obs = #rs2PU_16TS.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rsOrg.Rep_Nome# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: TRATAMENTO ORGAO SUBORDINADOR' & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtdezdiasuteis,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			  <cfquery datasource="#dsn_inspecao#">
			   UPDATE ParecerUnidade SET Pos_Situacao_Resp = 16, Pos_Situacao = 'TS', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dtdezdiasuteis#, Pos_Area = '#rsOrg.Rep_Codigo#', Pos_NomeArea = '#rsOrg.Rep_Nome#', Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 2 WHERE Pos_Unidade='#rs2PU_16TS.Pos_Unidade#' AND Pos_Inspecao='#rs2PU_16TS.Pos_Inspecao#' AND Pos_NumGrupo=#rs2PU_16TS.Pos_NumGrupo# AND Pos_NumItem=#rs2PU_16TS.Pos_NumItem#
			 </cfquery>
			 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rsOrg.Rep_Nome# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: TRATAMENTO ORGAO SUBORDINADOR' & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtdezdiasuteis,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			 <cfquery datasource="#dsn_inspecao#">
			   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs2PU_16TS.Pos_Inspecao#', '#rs2PU_16TS.Pos_Unidade#', #rs2PU_16TS.Pos_NumGrupo#, #rs2PU_16TS.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 16, convert(char, getdate(), 108), '#and_obs#', '#rsOrg.Rep_Codigo#')
			 </cfquery>				  		   				 	
		   </cfif>  
		</cfoutput> 
    	<!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 4;Mudar de Status 2-PU para 16-TS'>	 --->	
	</cfif>	
	<!--- DE 18-TF - TRATAMENTO PARA 20-PF-PENDENTE OU 26-NC GERAT OU GEOPE --->
	<!--- TERCEIRAS --->	
	<cfif rotina eq 5 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
	   <cfquery name="rs18TF_20PF26NC" datasource="#dsn_inspecao#">
		 SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Parecer, Und_TipoUnidade, Und_Descricao, Und_Centraliza, Und_Email, Rep_Codigo, Rep_Nome, Rep_Email
		 FROM Unidades 
		 INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
		 INNER JOIN Reops ON Und_CodReop = Rep_Codigo
		 WHERE Pos_Situacao_Resp in (18) and 
		 Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00') and (Pos_DtPosic <> Pos_DtPrev_Solucao) AND 
		 Und_TipoUnidade in (12,16) 
		 ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
	   </cfquery>
	    <!--- Opiniao da CCOP --->
		<cfset Encaminhamento = "Opinião do Controle Interno">
		<cfoutput query="rs18TF_20PF26NC">
			<cfquery name="rs14NR" datasource="#dsn_inspecao#">
				SELECT And_DtPosic
				FROM Andamento
				WHERE And_Unidade = '#rs18TF_20PF26NC.Pos_Unidade#' AND 
				And_NumInspecao = '#rs18TF_20PF26NC.Pos_Inspecao#' AND 
				And_NumGrupo = #rs18TF_20PF26NC.Pos_NumGrupo# AND 
				And_NumItem = #rs18TF_20PF26NC.Pos_NumItem# AND 
				And_Situacao_Resp in (0,11,14)
				order by And_DtPosic DESC
			</cfquery>
			<cfset dtposicfut = CreateDate(year(rs14NR.And_DtPosic),month(rs14NR.And_DtPosic),day(rs14NR.And_DtPosic))>
			<cfset dtposic14nr = CreateDate(year(rs14NR.And_DtPosic),month(rs14NR.And_DtPosic),day(rs14NR.And_DtPosic))>
			<cfset nCont = 0>
			<cfloop condition="nCont lte 29">
				<cfset nCont = nCont + 1>
				<cfset dtposic14nr = DateAdd( "d", 1, dtposic14nr)>
				<cfset vDiaSem = DayOfWeek(dtposic14nr)>
				<cfif vDiaSem neq 1 and vDiaSem neq 7>
					<!--- verificar se Feriado Nacional --->
					<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
						 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtposic14nr#
					</cfquery>
					<cfif rsFeriado.recordcount gt 0>
					   <cfset nCont = nCont - 1>
					</cfif>
				</cfif>
				<!--- Verifica se final de semana  --->
				<cfif vDiaSem eq 1 or vDiaSem eq 7>
					<cfset nCont = nCont - 1>
				</cfif>	
			</cfloop>	
			<cfset dtposic30dias = dtposic14nr>
			<cfif dtposic14nr lt now()>
				<cfset auxQtdDias = 0>
			</cfif>
			<!--- fim --->				

			<cfif auxQtdDias lte 0>
				<!--- MUDAR PARA ORGAO SUBORDINADOR (GEOPE OU GERAT) --->
				<!--- SE possuir GERAT ou apenas GEOPE --->
			   <cfquery name="rsGERAT" datasource="#dsn_inspecao#">
				SELECT Ars_Codigo, Ars_Descricao, Ars_Email
				FROM Areas 
				WHERE (left(Ars_Codigo,2) = '#left(rs18TF_20PF26NC.Pos_Area,2)#') AND (Ars_Descricao Like 'GER REG ATENDIMENTO%') and (Ars_Status = 'A') 
				ORDER BY Ars_Codigo
			  </cfquery>
			  <cfif rsGERAT.recordcount gt 0>
					<cfset rot5_posarea = rsGERAT.Ars_Codigo>
					<cfset rot5_posnomearea = rsGERAT.Ars_Descricao>
					<cfset rot5_sdestina = rsGERAT.Ars_Email>
			  <cfelse>
				  <cfquery name="rsGEOPE" datasource="#dsn_inspecao#">
					SELECT Ars_Codigo, Ars_Descricao, Ars_Email
				    FROM Areas 
					WHERE (left(Ars_Codigo,2) = '#left(rs18TF_20PF26NC.Pos_Area,2)#') AND (Ars_Descricao Like 'GER REG OPERACAO/GEOPE%') and (Ars_Status = 'A') 
					ORDER BY Ars_Codigo
				  </cfquery>
				  <cfif rsGEOPE.recordcount gt 0>
						<cfset rot5_posarea = rsGEOPE.Ars_Codigo>
						<cfset rot5_posnomearea = rsGEOPE.Ars_Descricao>
						<cfset rot5_sdestina = rsGEOPE.Ars_Email>
				  </cfif>
			  </cfif>
				  
				<cfset sinformes = 'Em virtude da ausência de conclusão do Item da Avaliação no Status EM TRATAMENTO pelo(a) Gestor(a) da unidade: ' & #trim(rs18TF_20PF26NC.Und_Descricao)# & CHR(13) & ', no prazo solicitado até ' & #DateFormat(rs18TF_20PF26NC.Pos_DtPrev_Solucao,"DD/MM/YYYY")# & ', estamos modificando-o para o Status de NÃO REGULARIZADO - APLICAR O CONTRATO e no aguardo do Aprimoramento para às devidas providências.'>
							 				
				<cfset aux_obs = #rs18TF_20PF26NC.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rot5_posnomearea# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: NÃO REGULARIZADO - APLICAR O CONTRATO' & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			  <cfquery datasource="#dsn_inspecao#">
			   UPDATE ParecerUnidade SET Pos_Situacao_Resp = 26, Pos_Situacao = 'NC', Pos_DtUltAtu = CONVERT(varchar, GETDATE(), 120), Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dtatual#, Pos_Area = '#rot5_posarea#', Pos_NomeArea = '#rot5_posnomearea#', Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 18 WHERE Pos_Unidade='#rs18TF_20PF26NC.Pos_Unidade#' AND Pos_Inspecao='#rs18TF_20PF26NC.Pos_Inspecao#' AND Pos_NumGrupo=#rs18TF_20PF26NC.Pos_NumGrupo# AND Pos_NumItem=#rs18TF_20PF26NC.Pos_NumItem#
			 </cfquery>
			 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rot5_posnomearea# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: NÃO REGULARIZADO - APLICAR O CONTRATO' & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			 <cfquery datasource="#dsn_inspecao#">
			   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs18TF_20PF26NC.Pos_Inspecao#', '#rs18TF_20PF26NC.Pos_Unidade#', #rs18TF_20PF26NC.Pos_NumGrupo#, #rs18TF_20PF26NC.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 26, convert(char, getdate(), 108), '#and_obs#', '#rot5_posarea#')
			 </cfquery>				  		   
				  
		   <cfelse>
				   <!--- MUDAR PARA PENDENTE DE TERCEIRIZADA --->
				   <cfset sinformes = "Em virtude da ausência de conclusão do Item da Avaliação no Status EM TRATAMENTO pelo(a) Gestor(a) da unidade: " & #trim(rs18TF_20PF26NC.Und_Descricao)# & CHR(13) & ", no prazo solicitado até " & #DateFormat(rs18TF_20PF26NC.Pos_DtPrev_Solucao,"DD/MM/YYYY")# & ", estamos modificando-o para o Status de PENDENTE DE TERCEIRIZADA e no aguardo do Aprimoramento para às devidas providências.">
				   
				  <cfset aux_obs = #rs18TF_20PF26NC.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & "-" & TimeFormat(Now(),'HH:MM') & ">" & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & "À(O) " & #rs18TF_20PF26NC.Pos_NomeArea# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & "Situação: PENDENTE DE TERCEIRIZADA" & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & "--------------------------------------------------------------------------------------------------------------">
			     <cfquery datasource="#dsn_inspecao#">
				   UPDATE ParecerUnidade SET Pos_Situacao_Resp = 20, Pos_Situacao = 'PF', Pos_DtUltAtu = CONVERT(varchar, getdate(), 120), Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dtatual#, Pos_Area = '#rs18TF_20PF26NC.Pos_Area#', Pos_NomeArea = '#trim(rs18TF_20PF26NC.Pos_NomeArea)#', Pos_Parecer= '#aux_obs#', Pos_Sit_Resp_Antes = 18 WHERE Pos_Unidade='#rs18TF_20PF26NC.Pos_Unidade#' AND Pos_Inspecao='#rs18TF_20PF26NC.Pos_Inspecao#' AND Pos_NumGrupo=#rs18TF_20PF26NC.Pos_NumGrupo# AND Pos_NumItem=#rs18TF_20PF26NC.Pos_NumItem#
				 </cfquery>	 
				<cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & "-" & TimeFormat(Now(),'HH:MM') & ">" & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & "À(O) " & #rs18TF_20PF26NC.Pos_NomeArea# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & "Situação: PENDENTE DE TERCEIRIZADA" & CHR(13) & CHR(13) & "Responsável: SUBG CONTR INT OPER/GCOP"  & CHR(13) & "--------------------------------------------------------------------------------------------------------------">				 
				<cfquery datasource="#dsn_inspecao#">
					insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs18TF_20PF26NC.Pos_Inspecao#', '#rs18TF_20PF26NC.Pos_Unidade#', #rs18TF_20PF26NC.Pos_NumGrupo#, #rs18TF_20PF26NC.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 20, convert(char, getdate(), 108), '#and_obs#', '#rs18TF_20PF26NC.Pos_Area#')
				</cfquery>				 	
		   </cfif>  
		</cfoutput> 
    	<!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 5;DE 18-TF - TRATAMENTO PARA 20-PF-PENDENTE OU 26-NC GERAT OU GEOPE'>	 --->	
	</cfif>
	<cfif rotina eq 6 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
	   <!--- Mudar 20 - PENDENTE DE TERCEIRIZADA para 26-NC Não Regularizado(Aplicar CFP)--->
	   <cfquery name="rs20PF_26NC" datasource="#dsn_inspecao#">
		 SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Parecer, Und_TipoUnidade, Und_Descricao, Und_Centraliza, Und_Email, Rep_Codigo, Rep_Nome, Rep_Email
		 FROM Unidades 
		 INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
		 INNER JOIN Reops ON Und_CodReop = Rep_Codigo
		 WHERE Pos_Situacao_Resp in (20) and Und_TipoUnidade in (12,16) and (Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00'))
		 ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
	   </cfquery>
	    <!--- Opiniao da CCOP --->
		<cfset Encaminhamento = "Opinião do Controle Interno">
		<cfoutput query="rs20PF_26NC">
			<cfquery name="rs14NR" datasource="#dsn_inspecao#">
				SELECT And_DtPosic
				FROM Andamento
				WHERE And_Unidade = '#rs20PF_26NC.Pos_Unidade#' AND 
				And_NumInspecao = '#rs20PF_26NC.Pos_Inspecao#' AND 
				And_NumGrupo = #rs20PF_26NC.Pos_NumGrupo# AND 
				And_NumItem = #rs20PF_26NC.Pos_NumItem# AND 
				And_Situacao_Resp in (0,11,14)
				order by And_DtPosic DESC
			</cfquery>
			<cfset dtposicfut = CreateDate(year(rs14NR.And_DtPosic),month(rs14NR.And_DtPosic),day(rs14NR.And_DtPosic))>
			<cfset dtposic14nr = CreateDate(year(rs14NR.And_DtPosic),month(rs14NR.And_DtPosic),day(rs14NR.And_DtPosic))>
			<cfset nCont = 0>
			<cfloop condition="nCont lte 29">
				<cfset nCont = nCont + 1>
				<cfset dtposic14nr = DateAdd( "d", 1, dtposic14nr)>
				<cfset vDiaSem = DayOfWeek(dtposic14nr)>
				<cfif vDiaSem neq 1 and vDiaSem neq 7>
					<!--- verificar se Feriado Nacional --->
					<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
						 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtposic14nr#
					</cfquery>
					<cfif rsFeriado.recordcount gt 0>
					   <cfset nCont = nCont - 1>
					</cfif>
				</cfif>
				<!--- Verifica se final de semana  --->
				<cfif vDiaSem eq 1 or vDiaSem eq 7>
					<cfset nCont = nCont - 1>
				</cfif>	
			</cfloop>	
			<cfset dtposic30dias = dtposic14nr>
			<cfif dtposic14nr lt now()>
				<cfset auxQtdDias = 0>
			</cfif>
			<!--- fim --->	

			<cfif auxQtdDias lte 0>
				<!--- MUDAR PARA ORGAO SUBORDINADOR (GEOPE OU GERAT) --->
				<!--- SE possuir GERAT ou apenas GEOPE --->
			   <cfquery name="rsGERAT" datasource="#dsn_inspecao#">
				SELECT Ars_Codigo, Ars_Descricao, Ars_Email
				FROM Areas 
				WHERE (left(Ars_Codigo,2) = '#left(rs20PF_26NC.Pos_Area,2)#') AND (Ars_Descricao Like 'GER REG ATENDIMENTO%') and (Ars_Status = 'A') 
				ORDER BY Ars_Codigo
			  </cfquery>
			  <cfif rsGERAT.recordcount gt 0>
					<cfset rot6__posarea = rsGERAT.Ars_Codigo>
					<cfset rot6__posnomearea = rsGERAT.Ars_Descricao>
					<cfset rot6__sdestina = rsGERAT.Ars_Email>
			  <cfelse>
				  <cfquery name="rsGEOPE" datasource="#dsn_inspecao#">
					SELECT Ars_Codigo, Ars_Descricao, Ars_Email
				    FROM Areas 
					WHERE (left(Ars_Codigo,2) = '#left(rs20PF_26NC.Pos_Area,2)#') AND (Ars_Descricao Like 'GER REG OPERACAO/GEOPE%') and (Ars_Status = 'A') 
					ORDER BY Ars_Codigo
				  </cfquery>
				  <cfif rsGEOPE.recordcount gt 0>
						<cfset rot6__posarea = rsGEOPE.Ars_Codigo>
						<cfset rot6__posnomearea = rsGEOPE.Ars_Descricao>
						<cfset rot6__sdestina = rsGEOPE.Ars_Email>
				  </cfif>
			  </cfif>
				  
				<cfset sinformes = 'Em virtude da ausência de conclusão do Item da Avaliação no Status EM PENDENTE pelo(a) Gestor(a) da unidade: ' & #trim(rs20PF_26NC.Und_Descricao)# & CHR(13) & ', no prazo solicitado, estamos modificando-o para o Status de NÃO REGULARIZADO - APLICAR O CONTRATO e no aguardo do Aprimoramento para às devidas providências.'>
							 				
				<cfset aux_obs = #rs20PF_26NC.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rot6__posnomearea# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: NÃO REGULARIZADO - APLICAR O CONTRATO' & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			  <cfquery datasource="#dsn_inspecao#">
			   UPDATE ParecerUnidade SET Pos_Situacao_Resp = 26, Pos_Situacao = 'NC', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_DtPosic = #dtatual#, Pos_DtPrev_Solucao = #dtatual#, Pos_Area = '#rot6__posarea#', Pos_NomeArea = '#rot6__posnomearea#', Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 20 WHERE Pos_Unidade='#rs20PF_26NC.Pos_Unidade#' AND Pos_Inspecao='#rs20PF_26NC.Pos_Inspecao#' AND Pos_NumGrupo=#rs20PF_26NC.Pos_NumGrupo# AND Pos_NumItem=#rs20PF_26NC.Pos_NumItem#
			 </cfquery>
			 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #rot6__posnomearea# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: NÃO REGULARIZADO - APLICAR O CONTRATO' & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			 <cfquery datasource="#dsn_inspecao#">
			   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs20PF_26NC.Pos_Inspecao#', '#rs20PF_26NC.Pos_Unidade#', #rs20PF_26NC.Pos_NumGrupo#, #rs20PF_26NC.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 26, convert(char, getdate(), 108), '#and_obs#', '#rot6__posarea#')
			 </cfquery>				  		   			 	
		   </cfif>  
		</cfoutput> 
    	<!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 6;Mudar 20 - PENDENTE DE TERCEIRIZADA para 26-NC Não Regularizado(Aplicar CFP)'> --->		
	</cfif>
	<!--- ###### FIM UNIDADES ###### --->
	<!--- ###### SUBORDINADORES ###### --->
	<cfif rotina eq 7 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- ==================================== --->
		<!--- mudar status 16-TS para 4-PO quando estiverem com a Pos_DtPrev_Solucao vencida nos 10 dias corridos oferecidos anteriormente --->
		<cfquery name="rs16TS4PO" datasource="#dsn_inspecao#">
		  SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, Rep_Codigo, Rep_Nome
		  FROM Unidades 
		  INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
		  INNER JOIN Reops ON Pos_Area = Rep_Codigo
		  WHERE (Pos_Situacao_Resp=16) and 
		  (Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and (Pos_DtPosic <> Pos_DtPrev_Solucao) 
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
			 <cfquery datasource="#dsn_inspecao#">
			   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs16TS4PO.Pos_Inspecao#', '#rs16TS4PO.Pos_Unidade#', '#rs16TS4PO.Pos_NumGrupo#', '#rs16TS4PO.Pos_NumItem#', convert(char, getdate(), 102), 'Rotina_Automatica', 4, convert(char, getdate(), 108), '#and_obs#', '#rs16TS4PO.Pos_Area#')
			 </cfquery>
		</cfoutput> 
 <!---   <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 7;aptos a mudarem status 16 para 4 quando estiverem com a Pos_DtPrev_Solucao vencida nos 10 dias oferecidos'>		 --->	
	</cfif>
	<!--- ###### FIM SUBORDINADORES ###### --->	
	<!--- ###### AREAS ###### --->
	<cfif rotina eq 8 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!---aptos a mudar de status de 19, quando data Pos_DtPrev_Solucao estiver vencida para status = 5 - PA - PENDENTE DE ÁREA --->
		<cfquery name="rs19TA5PA" datasource="#dsn_inspecao#">
		  SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Area, Pos_NomeArea, Pos_Parecer 
		  FROM ParecerUnidade 
		  WHERE (Pos_Situacao_Resp=19) and (Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and (Pos_DtPosic <> Pos_DtPrev_Solucao)
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
		 <cfquery datasource="#dsn_inspecao#">
		  insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs19TA5PA.Pos_Inspecao#', '#rs19TA5PA.Pos_Unidade#', #rs19TA5PA.Pos_NumGrupo#, #rs19TA5PA.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 5, convert(char, getdate(), 108), '#and_obs#', '#rs19TA5PA.Pos_Area#')
		 </cfquery>	 
	</cfoutput> 
   <!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 8;aptos a mudarem de status de 19, quando data Pos_DtPrev_Solucao for maior em 45 dias, para status = 5-PA-PENDENTE DE AREA'> --->
	</cfif>
	<!--- ###### FIM - AREAS ###### --->
	<!--- ###### SUPERINTENDENTE ###### --->
<cfif rotina eq 9 and rotinaSN is 'S'>
	<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
	<!--- Mudar o Status de 23-TO Tratamento Superintendencia para 8-SE Pendente Superintendencia  --->
	 <cfquery name="rs23TO8SE" datasource="#dsn_inspecao#">
		SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Parecer, Pos_Area, Pos_NomeArea 
		FROM ParecerUnidade 
		WHERE (Pos_Situacao_Resp=23) and (Pos_DtPrev_Solucao < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and (Pos_DtPosic <> Pos_DtPrev_Solucao)
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
		<cfquery datasource="#dsn_inspecao#">
		   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs23TO8SE.Pos_Inspecao#', '#rs23TO8SE.Pos_Unidade#', #rs23TO8SE.Pos_NumGrupo#, #rs23TO8SE.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', 8, convert(char, getdate(), 108), '#and_obs#', '#rs23TO8SE.Pos_Area#')
		</cfquery>
	</cfoutput> 
    <!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 9;Mudar o Status de 23-TO Tratamento Superintendencia para 8-SE Pendente Superintendencia'>	 --->
	</cfif>	
	<!--- ###### FIM - SUPERINTENDENTE ###### --->
	<!--- ************** FIM - MUDAR STATUS ****************** --->
	<!--- ************** PRÉ- ALERTA (DIÁRIOS)****************** --->
	<!--- ###### UNIDADES ###### --->
	<cfif rotina eq 10 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- E-mail agrupado para os Status 14-NR QUANDO FALTAR DE 5 A 0 DIAS DO VENCTO DA  Pos_DtPrev_Solucao para PROPRIAS e TERCEIRIZADAs --->
		<cfquery name="rs14NRGRP" datasource="#dsn_inspecao#">
			SELECT Pos_Inspecao
		    FROM ParecerUnidade 
		    WHERE (Pos_DtPrev_Solucao >= convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
		   (Pos_Situacao_Resp=14) and (DATEDIFF(d,GETDATE(),Pos_DtPrev_Solucao) <= 4) 
		   GROUP BY Pos_Inspecao
		   order by Pos_Inspecao
		</cfquery>
  
		<cfoutput query="rs14NRGRP">
			<cfquery name="rs14NR" datasource="#dsn_inspecao#">
		       SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Und_Email, Und_Descricao, Und_Centraliza
			   FROM Unidades 
			   INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
			   WHERE (Pos_DtPrev_Solucao >= convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
			   (Pos_Situacao_Resp=14) and (DATEDIFF(d,GETDATE(),Pos_DtPrev_Solucao) <= 4) AND Pos_Inspecao = '#rs14NRGRP.Pos_Inspecao#'
			   ORDER BY Und_CodDiretoria, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
			</cfquery>		

			<cfset rot10_sdestina = rs14NR.Und_Email>
			<cfif findoneof("@", #trim(rot10_sdestina)#) eq 0>
			 <cfset rot10_sdestina = "gilvanm@correios.com.br">
			</cfif>

			<cfif rs14NR.recordcount gt 0>
		  	<cfmail from="SNCI@correios.com.br" to="#rot10_sdestina#" subject="Avaliação - NÃO RESPONDIDO" type="HTML">
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
	  <!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 10;Aviso por e-mail agrupado para os status 14-NR Quando da falta  DE 5 a 1 dias do vencto na  Pos_DtPrev_Solucao para PROPRIAS e TERCEIRIZADAS'> --->		 
	</cfif> 
	<cfif rotina eq 11 and rotinaSN is 'S'>
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
		    <cfset rot11_sdestina = rs15TU.Und_Email>
			<cfif findoneof("@", #trim(rot11_sdestina)#) eq 0>
				 <cfset rot11_sdestina = "gilvanm@correios.com.br">
			</cfif>

<!--- 	      <cfset rot11_sdestina = #rot11_sdestina# & ';gilvanm@correios.com.br'> --->
	   <!--- <cfset rot11_sdestina = "gilvanm@correios.com.br">  --->
	   <cfif rs15TU.recordcount gt 0>
	   <cfmail from="SNCI@correios.com.br" to="#rot11_sdestina#" subject="Avaliação TRATAMENTO UNIDADE" type="HTML">
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
	  <!---  <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 11;Pré-alerta por e-mail para Unidade para os status = (15-TU) e que a data Pos_DtPrev_Solucao esteja apenas a 5(cinco) dias do vencimento'> --->	
	</cfif>
<cfif rotina eq 12 and rotinaSN is 'S'>
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
		    <cfset rot12_sdestina = rs18TF.Und_Email>
			<cfif findoneof("@", #trim(rot12_sdestina)#) eq 0>
				 <cfset rot12_sdestina = "gilvanm@correios.com.br">
			</cfif>

<!--- 	          <cfset rot12_sdestina = #rot12_sdestina# & ';gilvanm@correios.com.br'>  --->
	   <!--- <cfset rot12_sdestina = "gilvanm@correios.com.br">  --->
	   <cfif rs18TF.recordcount gt 0>
	   
	   <cfmail from="SNCI@correios.com.br" to="#rot12_sdestina#" subject="Avaliação TRATAMENTO TERCEIRIZADA" type="HTML">
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
<!--- 	   <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 12;Pré-alerta por e-mail para Unidade para os status = (18-TF) e que a data Pos_DtPrev_Solucao esteja apenas a 5(cinco) dias do vencimento'>	 --->
	</cfif>	
	<!--- ###### FIM - UNIDADES ###### --->
	<!--- ###### SUBORDINADORES ###### --->
<cfif rotina eq 13 and rotinaSN is 'S'>
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
             	<cfset rot13_sdestina = rs16TSGRP.Rep_Email>
				<cfif findoneof("@", #trim(rot13_sdestina)#) eq 0>
					 <cfset rot13_sdestina = "gilvanm@correios.com.br">
				</cfif>

<!--- 				 <cfset rot13_sdestina = #rot13_sdestina# & ';gilvanm@correios.com.br'> --->
				 <!---   <cfset rot13_sdestina = "gilvanm@correios.com.br">  --->
				 <cfmail from="SNCI@correios.com.br" to="#rot13_sdestina#" subject="Avaliação TRATAMENTO ÓRGÃO SUBORDINADOR" type="HTML">
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
	  <!---  <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 13; pré-alerta Orgao subordinador com e-mail agrupado e classif. (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem) status 16 e data Pos_DtPrev_Solucao já ultrapassa o 5º neste status'> --->
	</cfif>	
	<!--- ###### FIM - SUBORDINADORES ###### --->
	<!--- ###### AREAS ###### --->
<cfif rotina eq 14 and rotinaSN is 'S'>
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
			 <cfset rot14_sdestina = rs19TAGRP.Ars_Email>
				<cfif findoneof("@", #trim(rot14_sdestina)#) eq 0>
					 <cfset rot14_sdestina = "gilvanm@correios.com.br">
				</cfif>

<!--- 			 <cfif left(rs19TA.Pos_Unidade,2) is '32'>
				   <cfset rot14_sdestina = #rot14_sdestina# & ';edimir@correios.com.br'>
			 </cfif> --->
			<!---  	   ---> 
<!--- 			<cfset rot14_sdestina = #rot14_sdestina# & ';gilvanm@correios.com.br'> --->
			<!--- <cfset rot14_sdestina = "gilvanm@correios.com.br"> --->
			  <cfmail from="SNCI@correios.com.br" to="#rot14_sdestina#" subject="Avaliação TRATAMENTO DA ÁREA" type="HTML">
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
    <!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 14;rotina PRÉ-ALERTA status 19 e data Pos_DtPrev_Solucao ESTÁ DE 0 A 5 DIAS DO VENCTO'>	 --->	
	</cfif>	
	<!--- ###### FIM - AREAS ###### --->
	<!--- ###### SUPERINTENDENTE ###### --->
<cfif rotina eq 15 and rotinaSN is 'S'>
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
			 <cfset rot15_sdestina = rs23TOGRP.Dir_Email>
				<cfif findoneof("@", #trim(rot15_sdestina)#) eq 0>
					 <cfset rot15_sdestina = "gilvanm@correios.com.br">
				</cfif>

<!--- 			 <cfif left(rs23TO.Pos_Unidade,2) is '32'>
				   <cfset rot15_sdestina = #rot15_sdestina# & ';edimir@correios.com.br'>
			 </cfif> --->
			<!---  	   ---> 
<!--- 			<cfset rot15_sdestina = #rot15_sdestina# & ';gilvanm@correios.com.br'> --->
			<!--- <cfset rot15_sdestina = "gilvanm@correios.com.br"> --->
			  <cfmail from="SNCI@correios.com.br" to="#rot15_sdestina#" subject="Avaliação TRATAMENTO SE" type="HTML">
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
    <!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 15;rotina PRÉ-ALERTA status 23 e data Pos_DtPrev_Solucao ESTÁ DE 0 A 5 DIAS DO VENCTO'>		 --->
	</cfif>		
	<!--- ###### FIM - SUPERINTENDENTE ###### --->	
	<!--- ************** FIM - PRÉ- ALERTA ****************** --->
	<!--- ************** COBRANÇAS POR E-MAIL AOS PENDENTES (SEMANAL ÁS QUARTAS-FEIRAS)****************** --->
	<!--- ###### SUBORDINADORES ###### --->
	<cfif rotina eq 16 and rotinaSN is 'S'>
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
					 <cfset rot16_sdestina = "gilvanm@correios.com.br">
				 <cfelse>
					<cfset rot16_sdestina = #trim(rs4POGRP.Rep_Email)#>
			 	</cfif>

				<!---    ---> 
<!--- 				<cfset rot16_sdestina = #rot16_sdestina# & ';gilvanm@correios.com.br'> --->
				<!--- <cfset rot16_sdestina = "gilvanm@correios.com.br"> --->
			    <cfmail from="SNCI@correios.com.br" to="#rot16_sdestina#" subject="Avaliação PENDENTE DO ÓRGÃO SUBORDINADOR" type="HTML">
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
    <!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 16; Rotinas de cobranças semanal por email semanal ao Orgao Subordinador de forma agrupado para o Status = 4-PO'>	 --->
	</cfif>
	<!--- ###### FIM - SUBORDINADORES ###### --->
	<!--- ###### UNIDADES ###### --->
	<cfif rotina eq 17 and rotinaSN is 'S'>
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
						<cfset rot17_sdestina = "gilvanm@correios.com.br">
					 <cfelse>
						<cfset rot17_sdestina = #trim(rs2PU20PF.Und_Email)#>
					</cfif>

					<cfset rot17_assunto = 'AVALIAÇÃO PENDENTE DA UNIDADE'>
					<cfif rs2PU20PF.Und_TipoUnidade is 12 or rs2PU20PF.Und_TipoUnidade is 16>
						<cfset rot17_assunto = 'AVALIAÇÃO PENDENTE DE TERCEIRIZADA'>
					</cfif>
					<!---    ---> 
<!--- 					<cfset rot17_sdestina = #rot17_sdestina# & ';gilvanm@correios.com.br'> --->
					<!--- <cfset rot17_sdestina = "gilvanm@correios.com.br"> --->
			   		<cfmail from="SNCI@correios.com.br" to="#rot17_sdestina#" subject="#rot17_assunto#" type="HTML">
				 Mensagem automática. Não precisa responder!<br><br>
				<strong>
				   Ao Gestor(a) do(a) #Ucase(rs2PU20PF.Und_Descricao)#. <br><br><br>
		
		&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  em #rot17_assunto#  para  manifestação  desse Órgão.<br><br>
		
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

	<!--- fim email diarios --->
<!---     <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 17; Rotinas de cobranças semanal por email as UNIDADES agrupado para o Status = 2-PU e 20-PF'>	 --->
	</cfif>
	<!--- ###### FIM - UNIDADES ###### --->
	<!--- ###### AREAS ###### --->
	<cfif rotina eq 18 and rotinaSN is 'S'>
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
					 <cfset rot18_sdestina = "gilvanm@correios.com.br">
				 <cfelse>
					<cfset rot18_sdestina = #trim(rs5PAGRP.Ars_Email)#>
			 	</cfif>

				<!---    ---> 
<!--- 				<cfset rot18_sdestina = #rot18_sdestina# & ';gilvanm@correios.com.br'> --->
				<!--- <cfset rot18_sdestina = "gilvanm@correios.com.br"> --->
			    <cfmail from="SNCI@correios.com.br" to="#rot18_sdestina#" subject="Avaliação PENDENTE DA ÁREA" type="HTML">
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
    <!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 18; Rotinas de cobranças semanal por email semanal às Àreas de forma agrupado para o Status = 5-PA'>	 --->
	</cfif>	
	<!--- ###### FIM - AREAS ###### --->
	<!--- ###### SUPERINTENDENTES ###### --->
	<cfif rotina eq 19 and rotinaSN is 'S'>
		 <cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		 <!--- Rotinas de cobranças semanal por email --->
		 <!---  email semanal a SUPERINTENDENTES de forma agrupado para o Status = 8-SE --->
		<!---  <cfset dtatual = CreateDate(year(now()),month(now()),day(now()))> --->
		 <cfset vDiaSem = DayOfWeek(dtatual)>
		 <cfif int(vDiaSem) is 4>
	       <!--- Quarta-feira --->
		  <cfquery name="rs08SEGRP" datasource="#dsn_inspecao#">
		     SELECT distinct Dir_Sto, Dir_Codigo, Dir_Sigla, Dir_Descricao, Dir_Email  
			 FROM Diretoria INNER JOIN ParecerUnidade ON Dir_Sto = Pos_Area 
			 WHERE Pos_Situacao_Resp = 8 and (Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00'))
			ORDER BY Dir_Codigo
	      </cfquery>

		  <cfoutput query="rs08SEGRP">
			<!--- fazer busca com filtro da REATE e classif. (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem) --->
			<cfquery name="rs08SE" datasource="#dsn_inspecao#">
				SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, Und_Email, Und_Descricao 
				FROM Unidades 
				INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
				WHERE (Pos_Area = '#rs08SEGRP.Dir_Sto#') and (Pos_Situacao_Resp = 5) and (Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00'))
				ORDER BY Und_CodDiretoria, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		   </cfquery>
		   <cfif rs08SE.recordcount gt 0>
				<cfif findoneof("@", #trim(rs08SEGRP.Dir_Email)#) eq 0>
					 <cfset rot19_sdestina = "gilvanm@correios.com.br">
				 <cfelse>
					<cfset rot19_sdestina = #trim(rs08SEGRP.Dir_Email)#>
			 	</cfif>

				<!---    ---> 
<!--- 				<cfset rot19_sdestina = #rot19_sdestina# & ';gilvanm@correios.com.br'> --->
				<!--- <cfset rot19_sdestina = "gilvanm@correios.com.br"> --->
			    <cfmail from="SNCI@correios.com.br" to="#rot19_sdestina#" subject="Avaliação PENDENTE SE" type="HTML">
				 Mensagem automática. Não precisa responder!<br><br>
				<strong>
				   Ao Gestor(a) do(a) #Ucase(rs08SEGRP.Dir_Descricao)#. <br><br><br>
		
		&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  em PENDENTE SUPERINTENDÊNCIA ESTADUAL  para  manifestação  desse Órgão.<br><br>
		
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
		<cfloop query="rs08SE">
		<tr>
		<td align="left"><strong>#rs08SE.Und_Descricao#</strong></td>
		<td align="center"><strong>#rs08SE.Pos_Inspecao#</strong></td>
		<td align="center"><strong>#rs08SE.Pos_NumGrupo#</strong></td>
		<td align="center"><strong>#rs08SE.Pos_NumItem#</strong></td>
		<td align="center"><strong>#dateformat(rs08SE.Pos_DtPosic,"DD/MM/YYYY")#</strong></td>
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
   <!---  <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 19; Rotinas de cobranças semanal por email semanal às Àreas de forma agrupado para o Status = 5-PA'> --->	
	</cfif>		
	<!--- ###### FIM - SUPERINTENDENTES ###### --->
	<!--- ************** FIM - COBRANÇAS POR E-MAIL AOS PENDENTES ****************** --->
	<!--- ************** AVISOS POR E-MAIL AOS SCOI (DIÁRIO)****************** --->
	<!--- ###### INICIO - 0-RE e 11-EL ###### --->
	<cfif rotina eq 20 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- Cobrança por e-mail aos SCOI Status 0-RE ou 11-EL ou 17-RF com 1(um) ou mais dias no SNCI --->
		<cfquery name="rsRot20" datasource="#dsn_inspecao#">
			SELECT Und_CodDiretoria
			FROM ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			WHERE (((Pos_Situacao_Resp)=0 Or (Pos_Situacao_Resp)=11) AND ((Pos_DtPosic)<GETDATE()))
			GROUP BY Und_CodDiretoria
		</cfquery>
	
		<cfoutput query="rsRot20">
	        
			<cfquery name="rs01117" datasource="#dsn_inspecao#">
				SELECT Und_CodDiretoria, Und_Descricao, Pos_Inspecao 
				FROM Unidades 
				INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
				WHERE (Pos_Situacao_Resp in (0,11,17)) and 
				(Pos_DtPosic < GETDATE()) and (Und_CodDiretoria = '#rsRot20.Und_CodDiretoria#') 
				GROUP BY Und_CodDiretoria, Und_Descricao, Pos_Inspecao 
			</cfquery>	
			<cfset scoi_coordena = ''>			
			<cfif rs01117.recordcount gt 0>
				<cfset scoi_coordena = rs01117.Und_CodDiretoria>
				<cfif rs01117.Und_CodDiretoria eq '03'>
					<cfset scoi_coordena = '10'>
				<cfelseif rs01117.Und_CodDiretoria eq '05'>
				     <cfset scoi_coordena = '36'>
				<cfelseif rs01117.Und_CodDiretoria eq '65'>
				     <cfset scoi_coordena = '36'>	
				<cfelseif rs01117.Und_CodDiretoria eq '70'>
				     <cfset scoi_coordena = '04'>						 					 				 
				</cfif>
				<cfquery name="rsGes" datasource="#dsn_inspecao#">
					SELECT Ars_Sigla, Ars_Email 
					FROM Areas 
					WHERE (trim(Ars_Sigla) Like '%GCOP/SGCIN/SCOI') AND (left(Ars_Codigo,2)= '#scoi_coordena#') and Ars_Status = 'A'
				</cfquery>

				<cfset auxnomearea = rsGes.Ars_Sigla>
				<cfset rot20_sdestina = rsGes.Ars_Email>
		
				<cfif findoneof("@", #trim(rot20_sdestina)#) eq 0>
					 <cfset rot20_sdestina = "gilvanm@correios.com.br">
				</cfif>
			
				<cfmail from="SNCI@correios.com.br" to="#rot20_sdestina#" subject="Revisões dos SCOIs" type="HTML"> 
		
				 Mensagem automática. Não precisa responder!<br><br>
				<strong>
				   Ao Gestor(a) da #Ucase(auxnomearea)#. <br><br><br>
		
		&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  para  REVISÃO, LIBERAÇÃO ou RESPOSTA DA TERCEIRIZADA desse Órgão.<br><br>
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
					<cfloop query="rs01117">
						<tr>
						<td align="left"><strong>#rs01117.Und_Descricao#</strong></td>
						<td align="center"><strong>#rs01117.Pos_Inspecao#</strong></td>
						</tr>
					</cfloop>
					</table>
					<br>
					&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
					</strong>
			    </cfmail>
			 </cfif>     
		  </cfoutput> 
<!---    <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 20;aviso por e-mail aos Status 0-RE ou 11-EL com 1(um) ou mais dias no SNCI'>	 --->   		   
	</cfif>
	<!--- ###### FIM 0-RE e 11-EL ###### --->
	<!--- ###### INICIO REPOSTAS ###### --->
	<cfif rotina eq 21 and rotinaSN is 'S'>
	 
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- Inicio em 13/11/2020 Gilvan - ROTINAS PARA MUDANÇA DE STATUS  dos Itens --->
		<!--- Cobrança por e-mail aos SCOI Status 1-RU, 6-RA, 7-RS, 17-RF, 21-RV, 22-RO que Pos_DtPosic possui mais de 14 dias corridos --->
		<cfquery name="rsRot21" datasource="#dsn_inspecao#">
			SELECT Und_CodDiretoria 
			FROM Unidades 
			INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade
			WHERE Pos_Situacao_Resp IN (1,6,7,17,21,22) AND (Pos_NumGrupo not in (9,29,68,96,122,209,241,278,308,337) AND Pos_NumItem not in (2,3,4,9)) and (Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) 
			and (DATEDIFF(d,Pos_DtPosic, GETDATE()) >= 15) 
			GROUP BY Und_CodDiretoria
		</cfquery>
	
		<cfoutput query="rsRot21">
	
			<cfquery name="rs16722" datasource="#dsn_inspecao#">
			   SELECT Und_CodDiretoria, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_Situacao_Resp, STO_Sigla, STO_Descricao  
			   FROM Unidades 
			   INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
			   INNER JOIN Situacao_Ponto ON (Pos_Situacao_Resp = STO_Codigo)
			   WHERE (Pos_Situacao_Resp in (1,6,7,17,21,22)) AND 
			   (Pos_NumGrupo not in (9,29,68,96,122,209,241,278,308) AND Pos_NumItem not in (2,3,4,9)) and 
			   (Pos_DtPosic < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) and 
			   (DATEDIFF(d,Pos_DtPosic, GETDATE()) >= 15) and 
			   (Und_CodDiretoria = '#rsRot21.Und_CodDiretoria#') 
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
					<cfif rs16722.Und_CodDiretoria eq '03'>
						<cfset scoi_coordena = '10'>
					<cfelseif rs16722.Und_CodDiretoria eq '05'>
						 <cfset scoi_coordena = '10'>
					<cfelseif rs16722.Und_CodDiretoria eq '65'>
						 <cfset scoi_coordena = '10'>	
					<cfelseif rs16722.Und_CodDiretoria eq '70'>
						 <cfset scoi_coordena = '04'>						 					 				 
					</cfif>				
					<cfquery name="rsGes" datasource="#dsn_inspecao#">
						SELECT Ars_Sigla, Ars_Email 
						FROM Areas 
						WHERE (trim(Ars_Sigla) Like '%GCOP/SGCIN/SCOI') AND (left(Ars_Codigo,2)= '#scoi_coordena#') and (Ars_Status = 'A') 
					</cfquery>
		
					<cfset auxnomearea = rsGes.Ars_Sigla>
					<cfset rot21_sdestina = rsGes.Ars_Email>
		
					<cfif findoneof("@", #trim(rot21_sdestina)#) eq 0>
						 <cfset rot21_sdestina = "gilvanm@correios.com.br">
					</cfif>
			
					<!--- <cfset gil= gil>	 --->
					<!---    --->
<!--- 					<cfset rot21_sdestina = #rot21_sdestina# & ';gilvanm@correios.com.br'> --->
				<!--- 	<cfset rot21_sdestina = "gilvanm@correios.com.br"> --->
					<cfmail from="SNCI@correios.com.br" to="#rot21_sdestina#" subject="GESTORES - Respostas" type="HTML">  
			
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
<!---    <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 21;aviso por e-mail aos Status 1-RU, 6-RA, 7-RS, 21-RV, 22-RO que Pos_DtPosic possui mais de 14 dias corridos'>	 --->   	  			  
		</cfif> 
	<!--- ###### FIM REPOSTAS ###### --->
	<!--- ###### INICIO Em Análise ###### --->
	<cfif rotina eq 22 and rotinaSN is 'S'>
			<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
			<!--- Inicio em 02/06/2021 Gilvan --->
			<!--- Cobrança por e-mail aos SCIA Status 28-EA = EM ANALISE aos seus respectivos CCOP/SCIA QUE DATA POSIC possua 20 de vencido--->
			<cfquery name="rsRotina22" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla 
				FROM Diretoria 
				where Dir_Codigo <> '01'
				ORDER BY Dir_Sigla
			</cfquery>
			<cfoutput query="rsRotina22">
				
				<cfquery name="rs22" datasource="#dsn_inspecao#">
				SELECT Und_CodDiretoria, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_Situacao_Resp, STO_Sigla, STO_Descricao, DATEDIFF(d,Pos_DtPosic, GETDATE()) as diasocorr  
				FROM Unidades 
				INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
				INNER JOIN Situacao_Ponto ON (Pos_Situacao_Resp = STO_Codigo)
				WHERE (Pos_Situacao_Resp in (28)) and 
				(DATEDIFF(d,Pos_DtPosic, GETDATE()) >= 20) and 
				(Und_CodDiretoria = '#rsRotina22.Dir_Codigo#') 
				ORDER BY Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
				</cfquery>	

				<cfif rs22.recordcount gt 0>

				<cfset auxSE = rsRotina22.Dir_Codigo>
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
					 SELECT DISTINCT Ars_Codigo, Ars_Sigla, Ars_Descricao, Ars_Email
					 FROM Areas WHERE Ars_Status = 'A' AND (Left(Ars_Codigo,2) = '#scia_se#') and (Ars_Sigla Like '%/SCIA%' OR Ars_Sigla Like '%DCINT/GCOP/SGCIN/SCIA')
					 ORDER BY Ars_Sigla
					</cfquery>					
					<!---  --->				
			
					<cfset auxnomearea = rsSCIA.Ars_Sigla>
					<cfset rot22_sdestina = rsSCIA.Ars_Email>
					
					<cfif findoneof("@", #trim(rot22_sdestina)#) eq 0>
						 <cfset rot22_sdestina = "gilvanm@correios.com.br">
					</cfif>
				
					<cfmail from="SNCI@correios.com.br" to="#rot22_sdestina#" subject="GESTORES - Em Análise" type="HTML">  
		
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
						<cfloop query="rs22">
							<!--- Contar dias úteis  --->
							<cfset nCont = 1>
							<cfset dsusp = 0>
							<cfset dduteis = 0>
							<cfset DD_SD_Existe = 0>
							<cfset auxdtnova = CreateDate(year(rs22.Pos_DtPosic),month(rs22.Pos_DtPosic),day(rs22.Pos_DtPosic))>
							<cfset auxDTFim = DateAdd("d", #rs22.diasocorr#, #auxdtnova#)>
							
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
							<cfloop condition="nCont lte #rs22.diasocorr#">
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
								<cfset dduteis = #rs22.diasocorr# - #dsusp#> 
							<!---  --->
							<cfif (dduteis gte 20)> 					
								<tr>
									<td align="left"><strong>#rs22.Pos_Unidade#</strong></td>
									<td align="left"><strong>#rs22.Und_Descricao#</strong></td>
									<td align="center"><strong>#rs22.Pos_Inspecao#</strong></td>
									<td align="center"><strong>#rs22.Pos_NumGrupo#</strong></td>
									<td align="center"><strong>#rs22.Pos_NumItem#</strong></td>
									<td align="center"><strong>#dateformat(rs22.Pos_DtPosic,"dd/mm/yyyy")#</strong></td>
									<td align="center"><strong>#rs22.STO_Sigla#</strong></td>
									<td align="left"><strong>#trim(rs22.STO_Descricao)#</strong></td>
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
 <!---   <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 22;Aviso por e-mail aos Status 28-EA = EM ANALISE aos seus respectivos SGCIN/SCIA'>	 --->   	  				   
	</cfif>
	<!--- ###### FIM Em Análise ###### --->
<!--- ************** MUDAR STATUS conforme Demanda nº 58 ****************** --->
	<!--- para Tratamento --->
	<cfif rotina eq 23 and rotinaSN is 'S'>
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
				   <cfset rot23_StatusID = 18>
				   <cfset rot23_StatusSGL = 'TF'>
				   <cfset rot23_StatusDESC = 'TRATAMENTO TERCEIRIZADA'>
				 <cfelse>
				   <!--- Proprias --->
				   <cfset rot23_StatusID = 15>
				   <cfset rot23_StatusSGL = 'TU'>
				   <cfset rot23_StatusDESC = 'TRATAMENTO UNIDADE'>
				 </cfif>
				 <cfset aux_posarea = rsExiste.Und_Codigo>
		         <cfset aux_posnomearea = rsExiste.Und_Descricao>
			<cfelse>
				<cfquery name="rsExiste" datasource="#dsn_inspecao#">
					SELECT Ars_Codigo, Ars_Descricao FROM Areas WHERE Ars_Codigo = '#AndArea#' 
				</cfquery>
				<cfif rsExiste.recordcount gt 0>
					<cfset rot23_StatusID = 19>
					<cfset rot23_StatusSGL = 'TA'>
					<cfset rot23_StatusDESC = 'TRATAMENTO AREA'>
					<cfset aux_posarea = rsExiste.Ars_Codigo>
		         	<cfset aux_posnomearea = rsExiste.Ars_Descricao>
				<cfelse>
					<cfquery name="rsExiste" datasource="#dsn_inspecao#">
						SELECT Rep_Codigo, Rep_Nome FROM Reops WHERE Rep_Codigo = '#AndArea#'
					</cfquery>
					<cfif rsExiste.recordcount gt 0>
						<cfset rot23_StatusID = 16>
						<cfset rot23_StatusSGL = 'TS'>
						<cfset rot23_StatusDESC = 'TRATAMENTO ORGAO SUBORDINADOR'>
						<cfset aux_posarea = rsExiste.Rep_Codigo>
						<cfset aux_posnomearea = rsExiste.Rep_Nome>						
					<cfelse>
						<cfquery name="rsExiste" datasource="#dsn_inspecao#">
							SELECT Dir_Codigo, Dir_Descricao
							FROM Diretoria
							WHERE Dir_Sto = '#AndArea#'
						</cfquery>
						<cfif rsExiste.recordcount gt 0>
							<cfset rot23_StatusID = 23>
							<cfset rot23_StatusSGL = 'TO'>
							<cfset rot23_StatusDESC = 'TRATAMENTO SUPERINTENDENCIA ESTADUAL'>
							<cfset aux_posarea = rsExiste.Dir_Codigo>
							<cfset aux_posnomearea = rsExiste.Dir_Descricao>								
						</cfif>	
					</cfif>	
				</cfif>				
			</cfif>
	
	 <!--- Opiniao da CCOP --->
	 <cfset Encaminhamento = "Opinião do Controle Interno">
	 <cfset sinformes = 'Prezado gestor, solicita-se atualizar as informações do andamento das ações para regularização do item apontado considerando sua manifestação de ' & DateFormat(rsAntes.And_DtPosic,"DD/MM/YYYY") & ' quanto as tratativas com órgão externo, Incluir no SNCI as evidências das tratativas/ações adotadas.'>
	 <cfset aux_obs = #rs10PS_TRAT.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: ' & #rot23_StatusDESC# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(PosDtPrevSolucao,"DD/MM/YYYY")# & CHR(13) & CHR(13)& CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
		 <cfquery datasource="#dsn_inspecao#">
		   UPDATE ParecerUnidade SET Pos_Area = '#aux_posarea#', Pos_NomeArea = '#aux_posnomearea#', Pos_Situacao_Resp = #rot23_StatusID#, Pos_Situacao = '#rot23_StatusSGL#', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_DtPosic = convert(char, getdate(), 102), Pos_DtPrev_Solucao = #PosDtPrevSolucao#, Pos_Parecer = '#aux_obs#', Pos_Sit_Resp_Antes = 10 WHERE Pos_Unidade='#rs10PS_TRAT.Pos_Unidade#' AND Pos_Inspecao='#rs10PS_TRAT.Pos_Inspecao#' AND Pos_NumGrupo=#rs10PS_TRAT.Pos_NumGrupo# AND Pos_NumItem=#rs10PS_TRAT.Pos_NumItem#
		 </cfquery>
		 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'À(O) ' & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: ' & #rot23_StatusDESC# & CHR(13) & CHR(13) & 'Responsável: SUBG CONTR INT OPER/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
		 <cfquery datasource="#dsn_inspecao#">
		   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#rs10PS_TRAT.Pos_Inspecao#', '#rs10PS_TRAT.Pos_Unidade#', #rs10PS_TRAT.Pos_NumGrupo#, #rs10PS_TRAT.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', #rot23_StatusID#, convert(char, getdate(), 108), '#and_obs#', '#aux_posarea#')
		 </cfquery>
	</cfoutput> 
	<!---   <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 23;Mudar o Status de 10 para TRATAMENTO'> --->
		
  </cfif> 	
  <cfif rotina eq 24 and rotinaSN is 'S'>
		<cfoutput>Modulo de nº : #rotina# em execucao</cfoutput><br>
		<!--- Todas mudanças de Status deverão ter registros nos campos (Pos_Parecer(Cumulativo) e And_Parecer(individual)) --->
		<!--- acrescentar o status 14-NR na PARECERUNIDADE e os  status 0-re, 11-el e 14-NR na ANDAMENTO --->
		<!--- Colocar na ParecerUnidade possíveis pontos não conforme que por algum motivo não tenha sido inserido  --->
		<!--- Trata-se de um acerto de dados que será trabalhado a partir do ano de exercício 2022  --->
 <!---		 <cfquery name="rsRESINSP_14NR" datasource="#dsn_inspecao#">
			SELECT RIP_Ano, Itn_Ano, RIP_Resposta, INP_Situacao, RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, Itn_Situacao, Und_Descricao, Und_Centraliza, Und_TipoUnidade, Und_CodReop, INP_DtInicInspecao
			FROM Resultado_Inspecao 
			LEFT JOIN ParecerUnidade ON RIP_Unidade = Pos_Unidade AND RIP_NumInspecao = Pos_Inspecao AND RIP_NumGrupo = Pos_NumGrupo AND RIP_NumItem = Pos_NumItem
			INNER JOIN Inspecao ON RIP_NumInspecao = INP_NumInspecao AND RIP_Unidade = INP_Unidade
			INNER JOIN Unidades 
			INNER JOIN Itens_Verificacao ON Und_TipoUnidade = Itn_TipoUnidade 
			ON convert(char(4), Rip_ano) = Itn_Ano AND RIP_NumItem = Itn_NumItem AND RIP_NumGrupo = Itn_NumGrupo AND INP_Modalidade = Itn_Modalidade AND RIP_Unidade = Und_Codigo
			WHERE Itn_Ano >= '2022' AND RIP_Resposta ='N' AND INP_Situacao = 'CO' AND Pos_Unidade Is Null AND Itn_Situacao = 'A'
		</cfquery>
		<cfset auxdtprev = CreateDate(year(now()),month(now()),day(now()))>
		<cfset nCont = 0>
		<cfloop condition="nCont lte 9">
		   <cfset nCont = nCont + 1>
		   <cfset auxdtprev = DateAdd( "d", 1, auxdtprev)>
		   <cfset vDiaSem = DayOfWeek(auxdtprev)>
		   <cfif vDiaSem neq 1 and vDiaSem neq 7>
				<!--- verificar se Feriado Nacional --->
				<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
					 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #auxdtprev#
				</cfquery>
				<cfif rsFeriado.recordcount gt 0>
				   <cfset nCont = nCont - 1>
				</cfif>
			</cfif>
			<!--- Verifica se final de semana  --->
			<cfif vDiaSem eq 1 or vDiaSem eq 7>
				<cfset nCont = nCont - 1>
			</cfif>
		</cfloop>			

	    <cfoutput query="rsRESINSP_14NR">
	  
			<cfquery name="rsREEL" datasource="#dsn_inspecao#">
				SELECT Pos_Unidade, Pos_NumGrupo, Pos_NumItem, Pos_Area, Pos_NomeArea 
				FROM ParecerUnidade 
				WHERE Pos_Unidade='#rsRESINSP_14NR.RIP_Unidade#' AND 
				Pos_Inspecao='#rsRESINSP_14NR.RIP_NumInspecao#' AND  
				Pos_NumGrupo = #rsRESINSP_14NR.RIP_NumGrupo# AND 
				Pos_NumItem = #rsRESINSP_14NR.RIP_NumItem# AND 
				Pos_Situacao_Resp IN (0,11)
			</cfquery> 	
			<cfif rsREEL.recordcount lte 0>
				<cfset auxposarea = rsRESINSP_14NR.RIP_Unidade>
				<cfset auxnomearea = rsRESINSP_14NR.Und_Descricao>
				<cfset auxUndCodReop = rsRESINSP_14NR.Und_CodReop>
				
				<cfif (rsRESINSP_14NR.Und_Centraliza neq "") and (rsRESINSP_14NR.Und_TipoUnidade eq 9)>
						<cfquery name="rsCDD" datasource="#dsn_inspecao#">
						SELECT Und_Descricao, Und_CodReop FROM Unidades WHERE Und_Codigo = '#rsRESINSP_14NR.Und_Centraliza#'
						</cfquery>
						<cfset auxposarea = rsRESINSP_14NR.Und_Centraliza>
						<cfset auxnomearea = rsCDD.Und_Descricao>
						<cfset auxUndCodReop = rsCDD.Und_CodReop>
				</cfif>		
				
				<!---Update na tabela parecer unidade--->
				<cfquery datasource="#dsn_inspecao#">
					UPDATE ParecerUnidade SET Pos_Area = '#auxposarea#'
					, Pos_NomeArea = '#auxnomearea#'
					, Pos_Situacao_Resp = 14
					, Pos_Situacao = 'NR'
					, Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
					, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(auxdtprev),month(auxdtprev),day(auxdtprev)))#
					, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120) 
					, pos_username = '#CGI.REMOTE_USER#'
					WHERE Pos_Unidade='#rsRESINSP_14NR.RIP_Unidade#' AND 
					Pos_Inspecao='#rsRESINSP_14NR.RIP_NumInspecao#' AND  
					Pos_NumGrupo = #rsRESINSP_14NR.RIP_NumGrupo# AND 
					Pos_NumItem = #rsRESINSP_14NR.RIP_NumItem# AND 
				</cfquery>
				<!--- envio de e-mail  --->
					<cfset emailunid = "">
					<cfset emailreopunid = "">

					<!--- Busca de email da Unidade --->
					<!--- adquirir o email dos registro do Pos_Area --->
					<cfquery name="rsUnidEmail" datasource="#dsn_inspecao#">
					SELECT Und_Descricao, Und_Email FROM Unidades WHERE Und_Codigo = '#auxposarea#'
					</cfquery>
					<cfset emailunid = #rsUnidEmail.Und_Email#>
					<!--- adquirir o email do OrgaoSubordiador --->
					<cfquery name="rsReopEmail" datasource="#dsn_inspecao#">
					SELECT Rep_Email FROM Reops WHERE Rep_Codigo = '#auxUndCodReop#'
					</cfquery>
					<cfset emailreopunid = #rsReopEmail.Rep_Email#>
				
					<cfset sdestina = "">
					<cfif emailunid neq "">
					<cfset sdestina = #sdestina# & ';' & #emailunid#>
					</cfif>
					
					<cfif emailreopunid neq "">
					  <cfset sdestina = #sdestina# & ';' & #emailreopunid#>
					</cfif>
				
					<!--- adquirir o email do SCOI da SE --->
					<cfquery name="rsSCOIEmail" datasource="#dsn_inspecao#">
						SELECT Ars_Email
						FROM Areas
						WHERE (Ars_Codigo Like 'left(#auxposarea#,2)%') AND 
						(Ars_Sigla Like '%CCOP/SCOI%' OR Ars_Sigla Like '%DCINT/GCOP/SGCIN/SCOI') AND (Ars_Status='A')
					</cfquery>
					<cfif rsSCOIEmail.Ars_Email neq "">
					  <cfset sdestina = #sdestina# & ';' & #rsSCOIEmail.Ars_Email#>
					</cfif> 
			
					<cfif findoneof("@", trim(sdestina)) eq 0>
						<cfset sdestina = "gilvanm@correios.com.br">
					</cfif>					
					<cfset assunto = 'Relatório de Controle Interno - ' & #trim(auxnomearea)# & ' - Avaliação de Controle Interno ' & #ninsp#>
					<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
							Mensagem automática. Não precisa responder!<br><br>
							<strong>
							Prezado(a) Gerente do(a) #trim(Ucase(rsEmail.Und_Descricao))#, informamos que estão disponível na intranet o Relatório de Controle Interno: 
							N° #rsRESINSP_14NR.RIP_NumInspecao#, realizada nessa Unidade na Data: #dateformat(rsRESINSP_14NR.INP_DtInicInspecao,"dd/mm/yyyy")#. <br><br><br>
				
						&nbsp;&nbsp;&nbsp;Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:<br><br>
				
						&nbsp;&nbsp;&nbsp;a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA); <br>
				
						&nbsp;&nbsp;&nbsp;b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;<br>
				
						&nbsp;&nbsp;&nbsp;c) Anexar no sistema os Comprovantes de regularização da situação encontrada e/ou das Ações implementadas (em PDF).<br><br>
				
						&nbsp;&nbsp;&nbsp;Registrar a resposta no Sistema Nacional de Controle Interno - SNCI  num prazo de dez (10) dias úteis, contados a partir da data de entrega do Relatório. <br>
						&nbsp;&nbsp;&nbsp;O Não cumprimento desse prazo ensejará comunicação ao órgão subordinador dessa unidade.<br><br>
				
						&nbsp;&nbsp;&nbsp;Acesse o SNCI clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório de Controle Interno.</a><br><br>
				
						&nbsp;&nbsp;&nbsp;Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação. <br><br>
				
						&nbsp;&nbsp;&nbsp;Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:  #rsSCOIEmail.Ars_Email#.<br><br>
				
						<table>
						<tr>
						<td><strong>Unidade : #auxposarea - #auxnomearea#</strong></td>
						</tr>
						<tr>
						<td><strong>Inspeção: #rsRESINSP_14NR.RIP_NumInspecao#</strong></td>
						</tr>
						<tr>
						<td><strong>------------------------------------------</strong></td>
						</tr>
						</table>
						<br>
						&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
						</strong>
						</cfmail>
					</cfif>
					<!--- Ajuste de linhas na tabela andamento --->
				
					<cfquery datasource="#dsn_inspecao#">
						INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area)
						VALUES ('#rsRESINSP_14NR.RIP_NumInspecao#', '#rsRESINSP_14NR.RIP_Unidade#', #rsRESINSP_14NR.RIP_NumGrupo#, #rsRESINSP_14NR.RIP_NumItem#, convert(char, getdate(), 102), 'Rotina_24-mensagem.cfm', 0, left(convert(char, getdate(), 114),10),'#auxposarea#')
					</cfquery>	
					<cfquery datasource="#dsn_inspecao#">
						INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area)
						VALUES ('#rsRESINSP_14NR.RIP_NumInspecao#', '#rsRESINSP_14NR.RIP_Unidade#', #rsRESINSP_14NR.RIP_NumGrupo#, #rsRESINSP_14NR.RIP_NumItem#, convert(char, getdate(), 102), 'Rotina_24-mensagem.cfm', 11, left(convert(char, getdate(), 114),10),'#auxposarea#')
					</cfquery>	
					<cfquery datasource="#dsn_inspecao#">
						INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area)
						VALUES ('#rsRESINSP_14NR.RIP_NumInspecao#', '#rsRESINSP_14NR.RIP_Unidade#', #rsRESINSP_14NR.RIP_NumGrupo#, #rsRESINSP_14NR.RIP_NumItem#, convert(char, getdate(), 102), 'Rotina_24-mensagem.cfm', 14, left(convert(char, getdate(), 114),10),'#auxposarea#')
					</cfquery>										
				</cfoutput>  --->
				<!--- Fim - e-mail automático por unidade --->				
				
					
		<!--- 	</cfif>     ---> 
	 <!---  <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 24;Resgate do limbo - desabilitada'>	 --->	
  </cfif> 
  <!---  --->
	<cfif rotina eq 25>
		<!--- LIberar o SNCI aos demais usuários --->
<!--- 		 <cfquery datasource="#dsn_inspecao#">
		  UPDATE Mensagem SET MSG_Status = 'D' WHERE MSG_Codigo = 1
		 </cfquery> ---> 
<!--- 		 <cflocation url="http://intranetsistemaspe/snci/rotinas_inspecao.cfm"> --->
	<!---   <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 25;Desabilitado'>	 --->
	</cfif>

<!--- alerta quanto a necessidade de realizar Pesquisa_Pos_Avaliacao das Avaliações--->

	<cfif rotina eq 26 and rotinaSN is 'S'>
		<cfoutput>
		<cfquery name="rsAviso1" datasource="#dsn_inspecao#">
			SELECT Pes_Inspecao, Und_Descricao, INP_Responsavel, Und_Email
			FROM (Pesquisa_Pos_Avaliacao INNER JOIN Inspecao ON Pes_Inspecao = INP_NumInspecao) INNER JOIN Unidades ON INP_Unidade = Und_Codigo
			WHERE (Pes_GestorNome is Null) and (DATEDIFF(d,GETDATE(),Pes_dtinicio) <= 10) and Pes_Ctrl_AvisoA = 0
			order by Pes_Inspecao
		</cfquery>
		
		<cfloop query="rsAviso1">
			<cfset rsAviso1_destina = rsAviso1.Und_Email>
			<cfif findoneof("@", #trim(rsAviso1_destina)#) eq 0>
				<cfset rsAviso1_destina = "gilvanm@correios.com.br">
			</cfif>

			<cfmail from="SNCI@correios.com.br" to="#rsAviso1_destina#" subject="Pesquisa de Opinião" type="HTML">
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
			<cfset rsAviso2_destina = rsAviso2.Und_Email>
			<cfif findoneof("@", #trim(rsAviso2_destina)#) eq 0>
				<cfset rsAviso2_destina = "gilvanm@correios.com.br">
			</cfif>

			<cfmail from="SNCI@correios.com.br" to="#rsAviso2_destina#" subject="Pesquisa de Opinião" type="HTML">
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
			<cfset rsAviso3_destina = rsAviso3.Und_Email>
			<cfif findoneof("@", #trim(rsAviso3_destina)#) eq 0>
				<cfset rsAviso3_destina = "gilvanm@correios.com.br">
			</cfif>

			<cfmail from="SNCI@correios.com.br" to="#rsAviso3_destina#" subject="Pesquisa de Opinião" type="HTML">
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
	 <!---  <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 26;alerta quanto a necessidade de realizar Pesquisa_Pos_Avaliacao das Avaliações'> --->	
	</cfif>
	<!---  --->
	<cfif rotina eq 27>
		 <cfquery datasource="#dsn_inspecao#">
		  UPDATE AvisosGrupos SET AVGR_status = 'D', AVGR_DT_DES = convert(char, getdate(), 102) WHERE AVGR_status = 'A' and AVGR_DT_FINAL < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')
		 </cfquery> 
	  <!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 27;ajuste na tela de avisos gerais'>	 --->
	</cfif>	
	<cfif rotina eq 28>
		<cfset auxdt = dateformat(now(),"YYYYMMDD")>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Mensagem SET MSG_Realizado = '#auxdt#', MSG_Status = 'D' WHERE MSG_Codigo = 1
		</cfquery>	
		<!--- <cffile action="Append" file="#slocal##sarquivo#" output='#dateformat(now(),"DD/MM/YYYY HH:MM")#;Mensagens.cfm;rotina 28;Fim processamento de mensagem.cfm'> --->
		<cflocation url="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">	
	</cfif>		
	<!---  --->
    <cfset rotina = rotina + 1> 
</cfloop>   
<!--- Fim loop Geral--->
