
<cfquery name="rsAntes" datasource="#dsn_inspecao#">
	SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_Situacao_Resp,  Pos_Area, Pos_NomeArea, Pos_Sit_Resp_Antes
	FROM ParecerUnidade  
	where right(Pos_Inspecao,4) = '#ano#' 
</cfquery>	
<!--- and Pos_Inspecao='0300032024' and Pos_NumGrupo=702 and Pos_NumItem=2 --->
<cfset startTime = CreateTime(0,0,0)> 
<cfset endTime = CreateTime(0,0,45)> 
<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
</cfloop>

<cfoutput query="rsAntes">
	<cfset AndDtPosic = CreateDate(year(rsAntes.Pos_DtPosic),month(rsAntes.Pos_DtPosic),day(rsAntes.Pos_DtPosic))>
	<cfset salvarSN = 'N'>
	<cfquery name="rsAnd" datasource="#dsn_inspecao#">
		SELECT top 2 And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area
		FROM Andamento 
		WHERE And_Unidade = '#rsAntes.Pos_Unidade#' AND 
		And_NumInspecao = '#rsAntes.Pos_Inspecao#' AND 
		And_NumGrupo = #rsAntes.Pos_NumGrupo# AND 
		And_NumItem = #rsAntes.Pos_NumItem# AND 
		And_DtPosic <= #AndDtPosic# 
		order by And_DtPosic desc, And_HrPosic desc
	</cfquery>
	<cfset startTime = CreateTime(0,0,0)> 
	<cfset endTime = CreateTime(0,0,25)> 
	<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
	</cfloop>
	<cfloop query="rsAnd">
		<cfif rsAntes.Pos_Situacao_Resp neq rsAnd.And_Situacao_Resp>
			<cfset salvarSN = 'S'>
		</cfif>
		<cfif salvarSN eq 'S'>
			Pos_Inspecao='#rsAntes.Pos_Inspecao#' AND Pos_NumGrupo=#rsAntes.Pos_NumGrupo# AND Pos_NumItem=#rsAntes.Pos_NumItem# Pos_Situacao_Resp: #rsAntes.Pos_Situacao_Resp#  And_Situacao_Resp: #rsAnd.And_Situacao_Resp#<br> 
			<cfquery datasource="#dsn_inspecao#">
				UPDATE ParecerUnidade SET Pos_Sit_Resp_Antes = #rsAnd.And_Situacao_Resp# 
				WHERE Pos_Unidade='#rsAntes.Pos_Unidade#' AND Pos_Inspecao='#rsAntes.Pos_Inspecao#' AND Pos_NumGrupo=#rsAntes.Pos_NumGrupo# AND Pos_NumItem=#rsAntes.Pos_NumItem#
			</cfquery>
			<cfset salvarSN = 'N'>
		</cfif>
	</cfloop>

</cfoutput>
fim Processamento!