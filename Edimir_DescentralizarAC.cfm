<cfquery name="rsDescAC" datasource="#dsn_inspecao#">
	SELECT DAC_Unidade, DAC_Inspecao, DAC_NumGrupo, DAC_NumItem, DAC_Situacao, DAC_Area, DAC_Situacao_Resp, DAC_NomeArea, Und_Descricao
    FROM DescentralizaAC INNER JOIN Unidades ON DAC_Unidade = Und_Codigo
	order by DAC_Unidade, DAC_Inspecao, DAC_NumGrupo, DAC_NumItem 
</cfquery>

  
    <cfset dtatual = CreateDate(year(now()),month(now()),day(now()))>
	<cfset dtnovoprazo = DateAdd("d", 10, #dtatual#)>
    <cfset nCont = 1>
	<cfloop condition="nCont lt 2">
        <cfif nCont eq 1>
			    <cfquery name="rsFeriado" datasource="#dsn_inspecao#">
					 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtnovoprazo#
				</cfquery>
		   <cfif rsFeriado.recordcount gt 0>
			    <cfset dtnovoprazo = DateAdd( "d", 1, dtnovoprazo)>
			    <cfset nCont = 1>
		   <cfelse>
			    <cfset nCont = 2>
		   </cfif>
		</cfif>

		<cfset vDiaSem = DayOfWeek(dtnovoprazo)>
		<cfswitch expression="#vDiaSem#">
		<cfcase value="1">
		     <!--- domingo --->
		     <cfset dtnovoprazo = DateAdd("d", 1, dtnovoprazo)>
			 <cfset nCont = 1>
		  </cfcase>
		  <cfcase value="7">
		      <!--- sábado --->
		      <cfset dtnovoprazo = DateAdd("d", 2, dtnovoprazo)>
			  <cfset nCont = 1>
		  </cfcase>
		  <cfdefaultcase>
			  <cfset nCont = 2>
		  </cfdefaultcase>
		</cfswitch>
	   </cfloop>
		<!--- fim loop --->
	   <cfset IDStatus = 15>
	   <cfset SglStatus = 'TU'>
	   <cfset DescStatus = 'TRATAMENTO UNIDADE'>
	<cfoutput query="rsDescAC">

	   <cfset aux_posarea = rsDescAC.DAC_Unidade>
       <cfset aux_posnomearea = rsDescAC.Und_Descricao>

	  <cfquery name="rsCT" datasource="#dsn_inspecao#">
		 SELECT Cen_CDD FROM Centraliza WHERE Cen_AC = '#aux_posarea#'
	  </cfquery>
	  
<cfif rsCT.recordcount gt 0>
       <cfquery name="rsPar" datasource="#dsn_inspecao#">
          Select Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_Parecer from ParecerUnidade
		  WHERE Pos_Unidade = '#rsDescAC.DAC_Unidade#' AND Pos_Inspecao='#rsDescAC.DAC_Inspecao#' AND Pos_NumGrupo=#rsDescAC.DAC_NumGrupo# AND Pos_NumItem=#rsDescAC.DAC_NumItem#
       </cfquery> 
	 
<!--- Opiniao da CVCO --->
		<cfif rsPar.recordcount gt 0>
		 <cfset Encaminhamento = 'Opinião do Controle Interno'>
		 <cfset sinformes = 'Apontamento transferido para manifestação desse órgão em decorrência da descentralização da atividade de Distribuição Domiciliária. ' & CHR(13) & 'Favor adotar/apresentar as ações necessárias para o saneamento da Não Conformidade (NC) registrada.'>
		 <cfset aux_obs = #rsPar.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & Trim(Encaminhamento) & CHR(13) & CHR(13) & 'À(O) ' & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: ' & #DescStatus# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Responsável: COORD VERIF CONTR UNID OP/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			 <cfquery datasource="#dsn_inspecao#">
			   UPDATE ParecerUnidade SET Pos_Area = '#aux_posarea#', Pos_NomeArea = '#aux_posnomearea#', Pos_Situacao_Resp = #IDStatus#, Pos_Situacao = '#SglStatus#', Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, Pos_DtPrev_Solucao = #dtnovoprazo#, Pos_Parecer = '#aux_obs#' WHERE Pos_Unidade='#rsPar.Pos_Unidade#' AND Pos_Inspecao='#rsPar.Pos_Inspecao#' AND Pos_NumGrupo=#rsPar.Pos_NumGrupo# AND Pos_NumItem=#rsPar.Pos_NumItem#
			 </cfquery>
			 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & Trim(Encaminhamento) & CHR(13) & CHR(13) & 'À(O) ' & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & 'Situação: ' & #DescStatus# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Responsável: COORD VERIF CONTR UNID OP/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			 <cfquery datasource="#dsn_inspecao#">
			   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer) values ('#rsPar.Pos_Inspecao#', '#rsPar.Pos_Unidade#', #rsPar.Pos_NumGrupo#, #rsPar.Pos_NumItem#, convert(char, getdate(), 102), 'Rotina_Automatica', #IDStatus#, convert(char, getdate(), 108), '#and_obs#')
			 </cfquery>
		
			<cfquery datasource="#dsn_inspecao#">
			  delete FROM Centraliza WHERE Cen_AC = '#aux_posarea#'
			</cfquery>
		</cfif>	
</cfif> 
</cfoutput> 
Fim-Processamento!.
<!--- Exemplo
15/07/2020-14:30>Opinião do Controle Interno
À(O) AC XXXXXXXX
Apontamento transferido para manifestação desse órgão em decorrência da descentralização da atividade de Distribuição Domiciliária. 
Favor adotar/apresentar as ações necessárias para o saneamento da Não-Conformidade (NC) registrada.
                                                                                         
Situação: TRATAMENTO UNIDADE
Data de Previsão da Solução: 27/07/2020
Responsável: COORD VERIF CONTR UNID OP/GCOP
--------------------------------------------------------------------------------------------------------------                                                                                              Situação: PENDENTE DA UNIDADE  Data de Previsão da Solução: 15/07/2020  Responsável: COORD VERIF CONTR UNID OP/GCOP --------------------------------------------------------------------------------------------------------------
 --->
