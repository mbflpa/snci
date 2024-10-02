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

		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,45)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop>	

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


<cfoutput>
dtlimit: #dtlimit#<br>
</cfoutput>
Fim processamento!
