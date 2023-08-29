<cfcomponent >
<cfset dsn_inspecao = 'DBSNCI'>
<cffunction name="rsA" returntype="query">
<!---    <cfargument name="dtfim" required="yes">	
   <cfargument name="se" required="yes"> 
  <cfquery name="rsBaseA" datasource="#dsn_inspecao#">
  SELECT And_Unidade as UNID, And_NumInspecao as INSP, And_NumGrupo as Grupo, And_NumItem as Item, Min(DateDiff("d",[And_DtPosic],#Arguments.dtfim#)) AS Dias
FROM Andamento
WHERE (((And_Situacao_Resp) In (1,2,4,5,6,7,8,14,15,16,17,18,19,20,22,23)) AND ((And_DtPosic)<=#Arguments.dtfim#))
GROUP BY And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem
HAVING (((And_NumInspecao) Like '#Arguments.se#%'))
ORDER BY And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem
</cfquery>
 <cfquery datasource="#dsn_inspecao#">
   delete from Andamento_Temp where Andt_user = '85051071'
 </cfquery>
<cfloop query="rsBaseA">
 <cfquery datasource="#dsn_inspecao#">
   insert into Andamento_Temp (Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_user, Andt_tpunid, Andt_DiasCor) 
   values ('#rsBaseA.INSP#', '#rsBaseA.UNID#', #rsBaseA.Grupo#, #rsBaseA.Item#, convert(char, getdate(), 102), '00:00:00', '88','85051071', 99, #rsBaseA.Dias#)
 </cfquery>
</cfloop> 
  <cfset result = "" />
  <cfreturn result /> --->
</cffunction>
<cffunction name="rsB" returntype="query">
   <cfargument name="UNID" required="yes">	
   <cfargument name="INSP" required="yes">
   <cfargument name="Grupo" required="yes">	
   <cfargument name="Item" required="yes">
   <cfargument name="dtfim" required="yes">
<!---    <cfargument name="mes" required="yes">	 --->
<!---     <cfquery name="rsBase" datasource="#dsn_inspecao#">
	  SELECT TOP 1 And_DtPosic, And_HrPosic, And_Situacao_Resp, Und_TipoUnidade, DATEDIFF(dd,And_DtPosic,#dtfim#) as DiasOcor 
	  FROM Andamento INNER JOIN Unidades ON And_Unidade = Und_Codigo 
	  WHERE And_Unidade = '#Arguments.UNID#' AND 
	  And_NumInspecao = '#Arguments.INSP#' AND 
	  And_NumGrupo = #Arguments.Grupo# AND
	  And_NumItem = #Arguments.Item# AND 
	  And_DtPosic <= #Arguments.dtfim# AND And_Situacao_Resp in (1,2,4,5,6,7,8,14,15,16,17,18,19,20,22,23)
	  ORDER BY And_DtPosic DESC , And_HrPosic DESC 
	  </cfquery>   --->
	   <!---  --->
  <cfset result = rsBase />
  <cfreturn result />
</cffunction>
<cffunction name="rsAndResp" returntype="query">
   <cfargument name="UNID" required="yes">	
   <cfargument name="INSP" required="yes">
   <cfargument name="Grupo" required="yes">	
   <cfargument name="Item" required="yes">
   <cfargument name="DTRESP" required="yes">
   <cfargument name="RESP" required="yes">	
   <cfargument name="tpunid" required="yes">	
   
<!---    <cfquery name="rsAnd" datasource="#dsn_inspecao#">
			SELECT And_DtPosic, And_HrPosic, And_Situacao_Resp
			FROM Andamento 
			WHERE And_Unidade = '#Arguments.UNID#' AND 
	  		And_NumInspecao = '#Arguments.INSP#' AND 
	  		And_NumGrupo = #Arguments.Grupo# AND
	 		And_NumItem = #Arguments.Item# AND 
	  		And_DtPosic <= #Arguments.DTRESP# and
			And_Situacao_Resp <> #Arguments.RESP#
			<cfif Arguments.RESP is 1 and Arguments.tpunid neq 12>
			and (And_Situacao_Resp in (2,14,15,4,16))
			<cfelseif Arguments.RESP is 6>
			and (And_Situacao_Resp in (1,2,5,19))
			<cfelseif Arguments.RESP is 7>
			and (And_Situacao_Resp in (1,2,4,14,16,17,18))
			<cfelseif Arguments.RESP is 17 and Arguments.tpunid eq 12>
			and (And_Situacao_Resp in (4,14,16,18,20))			
			<cfelseif Arguments.RESP is 22>
			and (And_Situacao_Resp in (1,2,8,23))
			</cfif>
			ORDER BY And_DtPosic DESC , And_HrPosic DESC
   </cfquery> --->
  <cfset result = rsAnd />
  <cfreturn result />
</cffunction>
</cfcomponent>