 
<CFSET TOTITENS = 0>
<!--- ================================================ --->
<!--- Mudar o Status para 13-OC  --->
<!--- DE TODAS do grupo=3 e item = 5 --->
 <cfquery name="rsSta3_5" datasource="#dsn_inspecao#">
SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Parecer FROM ParecerUnidade 
WHERE (Pos_NumGrupo=3 and Pos_NumItem=5 and Pos_Situacao = 'SS') ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
</cfquery>  
   <cfoutput query="rsSta3_5">
   		<!--- Opiniao da CCOP --->
	<cfset CodSE = left(Pos_Unidade,2)>
		<cfswitch expression="#CodSE#">
		  <cfcase value="03">
			  <cfset nomeccop = "BSB/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="04">
			  <cfset nomeccop = "PE/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="05">
			  <cfset nomeccop = "BSB/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="06">
			  <cfset nomeccop = "BSB/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="08">
			  <cfset nomeccop = "MG/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="10">
			  <cfset nomeccop = "BSB/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="12">
			  <cfset nomeccop = "PE/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="14">
			  <cfset nomeccop = "MG/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="16">
			  <cfset nomeccop = "BSB/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="18">
			  <cfset nomeccop = "PE/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="20">
			  <cfset nomeccop = "MG/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="22">
			  <cfset nomeccop = "SPI/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="24">
			  <cfset nomeccop = "SPI/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="26">
			  <cfset nomeccop = "BSB/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="28">
			  <cfset nomeccop = "BSB/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="30">
			  <cfset nomeccop = "PE/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="32">
			  <cfset nomeccop = "PE/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="34">
			  <cfset nomeccop = "PE/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="36">
			  <cfset nomeccop = "PR/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="50">
			  <cfset nomeccop = "SPM/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="60">
			  <cfset nomeccop = "PE/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="64">
			  <cfset nomeccop = "PR/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="65">
			  <cfset nomeccop = "BSB/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="68">
			  <cfset nomeccop = "PR/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="70">
			  <cfset nomeccop = "PE/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="72">
			  <cfset nomeccop = "SPM/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="74">
			  <cfset nomeccop = "SPI/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfcase value="75">
			  <cfset nomeccop = "BSB/DCINT/GCOP/CCOP">
		  </cfcase>
		  <cfdefaultcase>
			  <cfset nomeccop = "PE/DCINT/GCOP/CCOP">
		  </cfdefaultcase>
		</cfswitch>   
       <cfset IDStatus = 13>
	   <cfset SglStatus = 'OC'>
	   <cfset DescStatus = 'ORIENTACAO CANCELADA'>
	   <cfset Encaminhamento = 'Opinião do Controle Interno'>
	   <cfset sinformes = 'Considerando a decisão Corporativa de retirada das caixas de coleta em más condições instaladas na frente das unidades de atendimento, Processo 53180.008902/2018-17, Ofício Nº 12050059/2020 - GEDC-DESEC e Ofício Circular Nº 11414705/2019 - GGAT-DERAT (anexos), encerra-se este item com status de ORIENTAÇÃO CANCELADA (perda de objeto).'>

			 <cfset aux_obs = #rsSta3_5.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & Trim(Encaminhamento) & CHR(13) & CHR(13) & 'À(O) ' & #nomeccop# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: ' & #DescStatus# & CHR(13) & CHR(13) & 'Responsável: COORD CONTR INT OPER/CCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			 <cfquery datasource="#dsn_inspecao#">
			   UPDATE ParecerUnidade SET Pos_Situacao_Resp = #IDStatus#, Pos_Situacao = '#SglStatus#', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), pos_DtPosic = convert(char, getdate(), 102), pos_DtPrev_Solucao = convert(char, getdate(), 102), Pos_Parecer = '#aux_obs#' WHERE Pos_Unidade='#rsSta3_5.Pos_Unidade#' AND Pos_Inspecao='#rsSta3_5.Pos_Inspecao#' AND Pos_NumGrupo = 3 AND Pos_NumItem = 5 
			 </cfquery>  

			 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & Trim(Encaminhamento) & CHR(13) & CHR(13) & 'À(O) ' & #nomeccop# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: ' & #DescStatus# & CHR(13) & CHR(13) & 'Responsável: COORD CONTR INT OPER/CCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>

			 <cfquery datasource="#dsn_inspecao#">
				   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer) values ('#rsSta3_5.Pos_Inspecao#', '#rsSta3_5.Pos_Unidade#', 3, 5, convert(char, getdate(), 102), '#CGI.REMOTE_USER#', #IDStatus#, convert(char, getdate(), 108), '#and_obs#')
			</cfquery> 
			<CFSET TOTITENS = TOTITENS +1>
</cfoutput>	 
<cfoutput>FIM ROTINA #TOTITENS#</cfoutput>

<!--- ========== re-direcionamento à página principal ========== --->
<cfoutput>FIM ROTINA #TOTITENS#</cfoutput>

<!--- Fim da rotina --->
