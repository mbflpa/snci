<!--- <!--- <cfquery name="rsSE" datasource="#dsn_inspecao#">
	  SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where dir_codigo > '10'
</cfquery>
<cfloop query="rsSE"> --->
	<cfoutput>
		<!--- PARECERUNID: SE: #rsSE.Dir_Codigo# - #rsSE.Dir_Sigla#<BR> --->
		<cfquery name="rsPar" datasource="#dsn_inspecao#">
			   SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_Situacao_Resp, Pos_Parecer, Pos_Area
			   FROM ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			   WHERE Und_CodDiretoria = '#URL.CODSE#' AND Pos_Inspecao LIKE '%#URL.ANO#'
			   ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
		</cfquery>
		<!--- WHERE Pos_Situacao_Resp in (2,4,5,8,20,14,15,16,18,19,23) --->
	</cfoutput>
<cfoutput query="rsPar">
    <cfset prazopos = CreateDate(year(rsPar.Pos_DtPosic),month(rsPar.Pos_DtPosic),day(rsPar.Pos_DtPosic))>
    <cfquery name="rsAnd_existe" datasource="#dsn_inspecao#">
		SELECT And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_HrPosic, And_Situacao_Resp
		FROM Andamento
		WHERE And_NumInspecao='#rsPar.Pos_Inspecao#' AND 
		And_Unidade='#rsPar.Pos_Unidade#' AND 
		And_NumGrupo = #rsPar.Pos_NumGrupo# AND 
		And_NumItem = #rsPar.Pos_NumItem# and 
		And_DtPosic= #prazopos# and 
		And_Situacao_Resp = #rsPar.Pos_Situacao_Resp#
	</cfquery>
	<cfif rsAnd_existe.recordcount lte 0>
	<!--- <cfset gil = gil> --->
	  <cfquery datasource="#dsn_inspecao#">
		insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer) 
		values ('#rsPar.Pos_Inspecao#', '#rsPar.Pos_Unidade#', #rsPar.Pos_NumGrupo#, #rsPar.Pos_NumItem#, #prazopos#, 'Rotina de ajuste na andamento', #rsPar.Pos_Situacao_Resp#, '70:70:70', '#rsPar.Pos_Parecer#')
	  </cfquery>
	</cfif>

    <cfquery name="rsAnd" datasource="#dsn_inspecao#">
		SELECT And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_HrPosic, And_Situacao_Resp
		FROM Andamento
		WHERE And_NumInspecao ='#rsPar.Pos_Inspecao#' AND 
		And_Unidade = '#rsPar.Pos_Unidade#' AND 
		And_NumGrupo = #rsPar.Pos_NumGrupo# AND 
		And_NumItem = #rsPar.Pos_NumItem# 
		ORDER BY And_DtPosic DESC , And_HrPosic DESC
	</cfquery>
	<!--- PARECERUNID: #rsPar.Pos_Inspecao#, #rsPar.Pos_Unidade#, #rsPar.Pos_NumGrupo#, #rsPar.Pos_NumItem#, #rsPar.Pos_DtPosic#, #rsPar.Pos_Situacao_Resp#<BR><BR> --->
	<cfif (rsPar.Pos_DtPosic eq rsAnd.And_DtPosic) and (rsPar.Pos_Situacao_Resp eq rsAnd.And_Situacao_Resp)>
		<!---  já está ordenado  --->
		 <!---  <cfset gil = gil>  --->
	<cfelse>
		  <cfset sairloopSN = "N">
		  <cfif DateFormat(rsPar.Pos_DtPosic,"DD/MM/YYYY") eq DateFormat(Now(),"DD/MM/YYYY")>
				<cfset aux_hora = TimeFormat(Now(),'HH:MM:SS')>
				<cfset aux_hora =  left(aux_hora,2) & mid(aux_hora,4,2) & right(aux_hora,2)>
				<cfset aux_hora_fim =  left(aux_hora,2) & ":" & mid(aux_hora,4,2)  & ":" &  right(aux_hora,2)>
		  <cfelse>
				<cfset aux_hora="235959">
				<cfset aux_hora_fim = "23:59:59">
		  </cfif>
		  <cfset aux_hora = aux_hora - 1>
		  <cfloop query="rsAnd">
				<cfset prazoand = CreateDate(year(rsAnd.And_DtPosic),month(rsAnd.And_DtPosic),day(rsAnd.And_DtPosic))> 
		
                <cfif sairloopSN eq "N">
						<!--- #prazoand#<br>
						#prazopos#<br> --->
						<cfif (rsPar.Pos_DtPosic eq rsAnd.And_DtPosic) AND (rsPar.Pos_Situacao_Resp eq rsAnd.And_Situacao_Resp)>
						<!--- ANDAMENTO(igual)   : #rsAnd.And_NumInspecao#, #rsAnd.And_Unidade#, #rsAnd.And_NumGrupo#, #rsAnd.And_NumItem#, #rsAnd.And_DtPosic#, #rsAnd.And_HrPosic#, #rsAnd.And_Situacao_Resp#<BR> --->
						        <cfif aux_hora_fim lte aux_hh>
								  <cfset aux_hora_fim = TimeFormat(Now(),'HH:MM:SS')>
								  <cfset aux_hora_fim =  left(aux_hora,2) & ":" & mid(aux_hora,4,2)  & ":" &  right(aux_hora,2)>
								</cfif>
								<!--- <br>#aux_hora_fim# --->
							   <cfquery datasource="#dsn_inspecao#">
									 UPDATE Andamento 
									 SET And_DtPosic = #prazopos#, And_HrPosic = '#aux_hora_fim#' 
									 WHERE And_NumInspecao ='#rsAnd.And_NumInspecao#' AND 
									 And_Unidade = '#rsAnd.And_Unidade#' AND 
									 And_NumGrupo = #rsAnd.And_NumGrupo#  AND 
									 And_NumItem = #rsAnd.And_NumItem# AND 
									 And_DtPosic = #prazoand# and 
									 And_HrPosic = '#rsAnd.And_HrPosic#' and
									 And_Situacao_Resp = #rsAnd.And_Situacao_Resp#
							   </cfquery> 
							   <cfset sairloopSN = "S">		 
						<cfelse>
							
							     <cfset aux_hh =  left(aux_hora,2) & ":" & mid(aux_hora,3,2) & ":" & right(aux_hora,2)>
							<!---      #aux_hora#<br>
							     #aux_hh#<br> --->
								 <cfif (rsPar.Pos_DtPosic lte rsAnd.And_DtPosic)>
									<!---  dados a serem alterados: And_DtPosic: #prazopos#, And_HrPosic: #aux_hh#<br>
									 ANDAMENTO(menor ou igual)   : #rsAnd.And_NumInspecao#, #rsAnd.And_Unidade#, #rsAnd.And_NumGrupo#, #rsAnd.And_NumItem#, #rsAnd.And_DtPosic#, #rsAnd.And_HrPosic#, #rsAnd.And_Situacao_Resp#<BR>
 --->
										<cfquery datasource="#dsn_inspecao#">
										 UPDATE Andamento 
										 SET And_DtPosic = #prazopos#, And_HrPosic = '#aux_hh#' 
										 WHERE And_NumInspecao ='#rsAnd.And_NumInspecao#' AND 
										 And_Unidade = '#rsAnd.And_Unidade#' AND 
										 And_NumGrupo = #rsAnd.And_NumGrupo# AND 
										 And_NumItem = #rsAnd.And_NumItem# AND 
										 And_DtPosic = #prazoand# and 
										 And_HrPosic = '#rsAnd.And_HrPosic#' and
										 And_Situacao_Resp = #rsAnd.And_Situacao_Resp#
									   </cfquery> 
								   </cfif> 
						</cfif>
				</cfif>
				<cfset aux_hora = aux_hora - 1>		
		  </cfloop>
	</cfif>
</cfoutput>
<!--- </cfloop> --->
<cfoutput>
<br>Fim atualizacao na ANDAMENTO - OK!
<BR> SE: #URL.CODSE#       ANO : #URL.ANO#      HORA: #TimeFormat(Now(),'HH:MM:SS')#

</cfoutput>

	 --->
<cfoutput>

	<cfset dtlimit = CreateDate(2021,03,04)>
	<cfset dtfim = CreateDate(2021,12,31)>
	<cfquery name="rsStatus28" datasource="#dsn_inspecao#">
		SELECT And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_Situacao_Resp, And_username, And_HrPosic, And_Area, And_Parecer
		FROM Andamento
		WHERE And_DtPosic = #dtlimit#  AND And_Situacao_Resp = 28 AND And_username ='Rotina_em_Lote'
	</cfquery>
	<cfloop query="rsStatus28">
		<cfset rsRespDT = CreateDate(year(rsStatus28.And_DtPosic),month(rsStatus28.And_DtPosic),day(rsStatus28.And_DtPosic))> 
		<cfquery name="rsAntes" datasource="#dsn_inspecao#">
			SELECT TOP 1 And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_Situacao_Resp, And_username, And_HrPosic, And_Area, And_Parecer
			FROM Andamento 
			WHERE And_Unidade = '#rsStatus28.And_Unidade#' AND 
			And_NumInspecao = '#rsStatus28.And_NumInspecao#' AND 
			And_NumGrupo = #rsStatus28.And_NumGrupo# AND
			And_NumItem = #rsStatus28.And_NumItem# AND
			And_DtPosic <= #rsRespDT# and 
			And_Situacao_Resp <> 28 
			ORDER BY And_DtPosic DESC , And_HrPosic DESC
		</cfquery>	
		<cfset rsAntesDT = CreateDate(year(rsAntes.And_DtPosic),month(rsAntes.And_DtPosic),day(rsAntes.And_DtPosic))>
		<cfquery datasource="#dsn_inspecao#">
			insert into Andamento_Gil (Gil_NumInspecao, Gil_Unidade, Gil_NumGrupo, Gil_NumItem, Gil_DtPosic, Gil_HrPosic, Gil_Situacao_Resp, Gil_Area, Gil_username, Gil_Parecer) 
			values ('#rsAntes.And_NumInspecao#', '#rsAntes.And_Unidade#', #rsAntes.And_NumGrupo#, #rsAntes.And_NumItem#, #rsAntesDT#, '#rsAntes.And_HrPosic#', #rsAntes.And_Situacao_Resp#, '#rsAntes.And_Area#', '#rsAntes.And_username#', '#rsAntes.And_Parecer#' )
		</cfquery> 	
		<cfset rsStatus28DT = CreateDate(year(rsStatus28.And_DtPosic),month(rsStatus28.And_DtPosic),day(rsStatus28.And_DtPosic))>
		<cfquery datasource="#dsn_inspecao#">
			insert into Andamento_Gil (Gil_NumInspecao, Gil_Unidade, Gil_NumGrupo, Gil_NumItem, Gil_DtPosic, Gil_HrPosic, Gil_Situacao_Resp, Gil_Area, Gil_username, Gil_Parecer) 
			values ('#rsStatus28.And_NumInspecao#', '#rsStatus28.And_Unidade#', #rsStatus28.And_NumGrupo#, #rsStatus28.And_NumItem#, #rsStatus28DT#, '#rsStatus28.And_HrPosic#', #rsStatus28.And_Situacao_Resp#, '#rsStatus28.And_Area#', '#rsStatus28.And_username#', '#rsStatus28.And_Parecer#' )
		</cfquery> 	
	</cfloop>
</cfoutput>	 		 