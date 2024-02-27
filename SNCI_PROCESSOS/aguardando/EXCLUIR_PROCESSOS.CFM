
<cfprocessingdirective pageencoding = "utf-8"> 

<cfquery name="dadosAno_CI" datasource="#application.dsn_processos#" timeout="120" >
			SELECT	pc_indDados_numPosic 
					,pc_orgaoIndicador.pc_org_sigla as orgaoIndicador
					,pc_orgaoAvaliado.pc_org_sigla as orgaoAvaliado
					,pc_orgaoResp.pc_org_sigla as orgaoResp
					,pc_indDados_numProcesso as numProcessoSNCI
					,pc_indDados_numItem as item
					,pc_indDados_numOrientacao as orientacao
					,pc_indDados_dataPrevista as dataPrevista
					,pc_indDados_dataStatus as dataPosicao
					,pc_indDados_orientacaoStatus as OrientacaoStatus
					,pc_indDados_dataRef as dataRef
					,pc_indDados_prazo as prazo
					,MONTH(pc_indDados_dataRef) AS monthRef
					,YEAR(pc_indDados_dataRef) AS yearRef
					,pc_indDados_numIndicador
					,CASE WHEN pc_indDados_prazo = 'DP' THEN 1 ELSE 0 END AS DP
					,pc_indMeta_meta
			FROM pc_indicadores_dados		
			INNER JOIN pc_orgaos as pc_orgaoAvaliado ON pc_orgaoAvaliado.pc_org_mcu = pc_indicadores_dados.pc_indDados_numOrgaoAvaliado
			INNER JOIN pc_orgaos as pc_orgaoResp ON pc_orgaoResp.pc_org_mcu = pc_indicadores_dados.pc_indDados_numOrgaoResp
			INNER JOIN pc_orgaos as pc_orgaoIndicador ON pc_orgaoIndicador.pc_org_mcu = pc_indicadores_dados.pc_indDados_numOrgaoIndicador
			LEFT JOIN pc_indicadores_meta ON pc_indicadores_meta.pc_indMeta_ano = YEAR(pc_indicadores_dados.pc_indDados_dataRef) 
                                      AND pc_indicadores_meta.pc_indMeta_mes = MONTH(pc_indicadores_dados.pc_indDados_dataRef)
                                      AND pc_orgaoIndicador.pc_org_mcu = pc_indicadores_meta.pc_indMeta_numOrgao
									  AND pc_indicadores_dados.pc_indDados_numIndicador = pc_indicadores_meta.pc_indMeta_numIndicador
			WHERE YEAR(pc_indDados_dataRef) = 2023
		</cfquery>

		<cfquery name="resultadoPRCI_porOrgao" dbtype="query">
			SELECT
				yearRef,
				monthRef,
				orgaoIndicador,
				SUM(DP)/COUNT(*) AS prci,
				pc_indMeta_meta
			FROM dadosAno_CI
			WHERE monthRef = 1
				AND pc_indDados_numIndicador = 1
			GROUP BY yearRef, monthRef, pc_indMeta_meta,orgaoIndicador	
				
		</cfquery>




		<cfdump var="#resultadoPRCI_porOrgao#">


