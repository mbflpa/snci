<cfcomponent>
<cfprocessingdirective pageencoding = "utf-8">	

<cfparam name = "dsnSNCI" default = "DBSNCI"> 


<cffunction name="salvarPosic"   access="remote" hint="salva a manifestação de qualquer usuário">
	<cfset form.acaofac = 'INC'>
	<cfset form.acaofaca = 'INC'>
	<cfquery datasource="#dsnSNCI#" name="rsexistegestor">
		select FAC_Avaliacao from UN_Ficha_Facin 
		WHERE FAC_Avaliacao = convert(varchar,'#FACAVALIACAO#') and FAC_Matricula = '#facmatricula#'
	</cfquery>
	<cfif rsexistegestor.recordcount gt 0>
		<cfset form.acaofac = 'ALT'>
	</cfif>
	<cfquery datasource="#dsnSNCI#" name="rsexisteaval">
	   select FACA_Avaliador from UN_Ficha_Facin_Avaliador
	   where FACA_Avaliacao = '#FACAVALIACAO#' and FACA_Avaliador = '#form.matravaliador#'
	</cfquery>
	<cfif rsexisteaval.recordcount gt 0>
		<cfset form.acaofaca = 'ALT'>
	</cfif>
	<cfif grpacesso neq 'INSPETORES'>
		<cfif form.acaofac eq 'INC'>
			<!--- inserir UN_Ficha_Facin --->
			<cfquery datasource="#dsnSNCI#">
				insert into UN_Ficha_Facin (FAC_Avaliacao,FAC_Unidade,FAC_Matricula,FAC_Ano,FAC_Data_SEI,FAC_Revisor,FAC_Qtd_Geral,FAC_Qtd_NC,FAC_Qtd_Devolvido,FAC_Pontos_Revisao_Meta1,FAC_Perc_Revisao_Meta1,FAC_Meta1_Peso_Item,FAC_Pontos_Revisao_Meta2,FAC_Perc_Revisao_Meta2,FAC_Meta2_Peso_Item,FAC_Data_Plan_Meta3,FAC_DifDia_Meta3,FAC_Perc_Meta3,FAC_DtCriar,FAC_DtAlter)
				values
				('#FACAVALIACAO#','#FACUNIDADE#','#FACMATRICULA#','#FACANO#','#FACDATASEI#','#FACREVISOR#',#FACQTDGERAL#,#FACQTDNC#,#FACQTDEVOLVIDO#,#FACPONTOSREVISAOMETA1#,#FACPERCREVISAOMETA1#,#FACMETA1PESOITEM#,#FACPONTOSREVISAOMETA2#,#FACPERCREVISAOMETA2#,#FACMETA2PESOITEM#,'#FACDATAPLANMETA3#',#FACDIFDIAMETA3#,#FACPERCMETA3#,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120))
			</cfquery>	
		<cfelse>
			<!--- alterar UN_Ficha_Facin --->
			<cfquery datasource="#dsnSNCI#">
				UPDATE UN_Ficha_Facin SET 
				FAC_Pontos_Revisao_Meta1 = #FACPONTOSREVISAOMETA1# 
				, FAC_Perc_Revisao_Meta1 = #FACPERCREVISAOMETA1#
				, FAC_Meta1_Peso_Item = #FACMETA1PESOITEM#
				, FAC_Pontos_Revisao_Meta2 = #FACPONTOSREVISAOMETA2#
				, FAC_Perc_Revisao_Meta2 = #FACPERCREVISAOMETA2#
				, FAC_Meta2_Peso_Item = #FACMETA2PESOITEM#
				, FAC_Data_Plan_Meta3 = '#FACDATAPLANMETA3#'
				, FAC_DifDia_Meta3 = #FACDIFDIAMETA3#
				, FAC_Perc_Meta3 = #FACPERCMETA3#
				, FAC_DtAlter = CONVERT(char, GETDATE(), 120)
				where FAC_Avaliacao = '#FACAVALIACAO#' and FAC_Matricula='#FACMATRICULA#' and FAC_Unidade = '#FACUNIDADE#'		
			</cfquery>
		</cfif>
	</cfif>

	<!--- pesquisar dados da avaliação --->
	<cfquery datasource="#dsnSNCI#" name="rsSalva">
		SELECT RIP_MatricAvaliador, RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem
		FROM Resultado_Inspecao
		WHERE RIP_NumInspecao= <CFQUERYPARAM VALUE="#FACAVALIACAO#" CFSQLType="CF_SQL_CHAR"> AND RIP_Resposta='N' and 
		RIP_NumGrupo = #form.grp# and RIP_NumItem = #form.itm#
		<cfif grpacesso eq 'INSPETORES'>
            AND RIP_MatricAvaliador = '#FACMATRICULA#'
        </cfif>
		ORDER BY RIP_MatricAvaliador, RIP_NumGrupo, RIP_NumItem
    </cfquery>
	<table>	
	<!--- <cfdump var="#form#">  --->
	<br>
	<cfoutput query="rsSalva">

		<!--- <cfdump var="#rsSalva#">  --->
		<cfset grpitem = rsSalva.RIP_NumGrupo & '_' & rsSalva.RIP_NumItem>
		<cfset matraval = rsSalva.RIP_NumGrupo & '_' & rsSalva.RIP_NumItem>
<!---
		#grpitem#<br>
		#RIP_MatricAvaliador#<br>
--->
		<cfloop collection="#form#" item="nomecampo">
			<cfif right(nomecampo,8) eq '#RIP_MatricAvaliador#'>
<!---
				<tr>
					<td>#nomecampo#</td> <td>#find("_",nomecampo)#</td> <td>#evaluate("form.#nomecampo#")#</td>
				</tr>
--->	
				<!--- meta1 --->
				<cfif nomecampo eq "FFIMETA1QTDITEM_#RIP_MatricAvaliador#">
					<cfset FFIMETA1QTDITEM = #evaluate("form.#nomecampo#")#>
				</cfif>
				<cfif nomecampo eq "FFIMETA1PONTUACAOINICIAL_#RIP_MatricAvaliador#">
					<cfset FFIMETA1PONTUACAOINICIAL = #evaluate("form.#nomecampo#")#>
				</cfif>
				<cfif nomecampo eq "FFIMETA1PONTUACAOOBTIDA_#RIP_MatricAvaliador#">
					<cfset FFIMETA1PONTUACAOOBTIDA = #evaluate("form.#nomecampo#")#>
				</cfif>
				<cfif nomecampo eq "FFIMETA1RESULTADO_#RIP_MatricAvaliador#">
					<cfset FFIMETA1RESULTADO = #evaluate("form.#nomecampo#")#>
				</cfif>
				<!--- meta 2 --->
				<cfif nomecampo eq "FFIMETA2QTDITEM_#RIP_MatricAvaliador#">
					<cfset FFIMETA2QTDITEM = #evaluate("form.#nomecampo#")#>
				</cfif>
				<cfif nomecampo eq "FFIMETA2PONTUACAOINICIAL_#RIP_MatricAvaliador#">
					<cfset FFIMETA2PONTUACAOINICIAL = #evaluate("form.#nomecampo#")#>
				</cfif>
				<cfif nomecampo eq "FFIMETA2PONTUACAOOBTIDA_#RIP_MatricAvaliador#">
					<cfset FFIMETA2PONTUACAOOBTIDA = #evaluate("form.#nomecampo#")#>
				</cfif>
				<cfif nomecampo eq "FFIMETA2RESULTADO_#RIP_MatricAvaliador#">
					<cfset FFIMETA2RESULTADO = #evaluate("form.#nomecampo#")#>
				</cfif>			
			</cfif>
		</cfloop>


		<cfloop collection="#form#" item="nomecampo">
			<cfset gpitpos = find("_",nomecampo)>
			<cfif gpitpos gt 0>
				<cfset gpitpos = gpitpos + 1>
				<cfif mid(nomecampo,gpitpos,len(nomecampo)) eq grpitem>
<!---				
					<tr>
						<td>#nomecampo#</td> <td>#evaluate("form.#nomecampo#")#</td>
					</tr>
--->				
					<!--- meta1 --->
					<cfif nomecampo eq "FACAMETA1ATORTOGRAM_#grpitem#">
						<cfset FACAMETA1ATORTOGRAM = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA1ATCCCP_#grpitem#">
						<cfset FACAMETA1ATCCCP = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA1AETECH_#grpitem#">
						<cfset FACAMETA1AETECH = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA1AEPROB_#grpitem#">
						<cfset FACAMETA1AEPROB = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA1AEVALO_#grpitem#">
						<cfset FACAMETA1AEVALO = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA1AECOSQ_#grpitem#">
						<cfset FACAMETA1AECOSQ = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA1AENORMA_#grpitem#">
						<cfset FACAMETA1AENORMA = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA1AEDOCU_#grpitem#">
						<cfset FACAMETA1AEDOCU = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA1AECLASS_#grpitem#">
						<cfset FACAMETA1AECLASS = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA1AEORIENT_#grpitem#">
						<cfset FACAMETA1AEORIENT = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "#grpitem#">
						<cfset FACAMETA1AEORIENT = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA1PONTOS_#grpitem#">
						<cfset FACAMETA1PONTOS = #evaluate("form.#nomecampo#")#>
					</cfif>
					<!--- meta2 --->
					<cfif nomecampo eq "FACAMETA2ARFALTA_#grpitem#">
						<cfset FACAMETA2ARFALTA  = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA2ARTROCA_#grpitem#">
						<cfset FACAMETA2ARTROCA  = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA2ARNOMEN_#grpitem#">
						<cfset FACAMETA2ARNOMEN = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA2ARORDEM_#grpitem#">
						<cfset FACAMETA2ARORDEM = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA2ARPRAZO_#grpitem#">
						<cfset FACAMETA2ARPRAZO = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACAMETA2PONTOS_#grpitem#">
						<cfset FACAMETA2PONTOS  = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACACONSIDERACAOREVISOR_#grpitem#">
						<cfset FACACONSIDERACAOREVISOR = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACACONSIDERACAOAVALIADOR_#grpitem#">
						<cfset FACACONSIDERACAOAVALIADOR = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACACONSIDERACAOSCOI_#grpitem#">
						<cfset FACACONSIDERACAOSCOI = #evaluate("form.#nomecampo#")#>
					</cfif>
					<cfif nomecampo eq "FACACONSIDERACAOSGCIN_#grpitem#">
						<cfset FACACONSIDERACAOSGCIN = #evaluate("form.#nomecampo#")#>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
	<!--- inserção na tabela Un_Ficha_FAcin_avaliador --->
	<cfif grpacesso neq 'INSPETORES'>
		<cfif form.acaofaca eq 'INC'>
			<cfquery datasource="#dsnSNCI#">
				insert into UN_Ficha_Facin_Avaliador (FACA_Avaliacao,FACA_Unidade,FACA_Matricula,FACA_Avaliador,FACA_Grupo,FACA_Item,FACA_Meta1_AT_OrtoGram,FACA_Meta1_AT_CCCP,FACA_Meta1_AE_Tecn,FACA_Meta1_AE_Prob,FACA_Meta1_AE_Valor,FACA_Meta1_AE_Cosq,FACA_Meta1_AE_Norma,FACA_Meta1_AE_Docu,FACA_Meta1_AE_Class,FACA_Meta1_AE_Orient,FACA_Meta1_Pontos,FACA_Meta2_AR_Falta,FACA_Meta2_AR_Troca,FACA_Meta2_AR_Nomen,FACA_Meta2_AR_Ordem,FACA_Meta2_AR_Prazo,FACA_Meta2_Pontos,FACA_Consideracao_Revisor,FACA_Consideracao_Avaliador,FACA_Consideracao_SCOI,FACA_Consideracao_SGCIN,FACA_DtCriar,FACA_DtAlter)
				values
				('#FACAVALIACAO#','#FACUNIDADE#','#FACMATRICULA#','#RIP_MatricAvaliador#',#rsSalva.RIP_NumGrupo#,#rsSalva.RIP_NumItem#,'#FACAMETA1ATORTOGRAM#','#FACAMETA1ATCCCP#','#FACAMETA1AETECH#','#FACAMETA1AEPROB#','#FACAMETA1AEVALO#','#FACAMETA1AECOSQ#','#FACAMETA1AENORMA#','#FACAMETA1AEDOCU#','#FACAMETA1AECLASS#','#FACAMETA1AEORIENT#',#FACAMETA1PONTOS#,'#FACAMETA2ARFALTA#','#FACAMETA2ARTROCA#','#FACAMETA2ARNOMEN#','#FACAMETA2ARORDEM#','#FACAMETA2ARPRAZO#',#FACAMETA2PONTOS#,'#FACACONSIDERACAOREVISOR#','#FACACONSIDERACAOAVALIADOR#','#FACACONSIDERACAOSCOI#','#FACACONSIDERACAOSGCIN#',CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120))
			</cfquery>	

			<cfquery datasource="#dsnSNCI#">
				insert into UN_Ficha_Facin_Individual (FFI_Avaliacao,FFI_Avaliador,FFI_Meta1_Qtd_Item,FFI_Meta1_Pontuacao_Inicial,FFI_Meta1_Pontuacao_Obtida,FFI_Meta1_Resultado,FFI_Meta2_Qtd_Item,FFI_Meta2_Pontuacao_Inicial,FFI_Meta2_Pontuacao_Obtida,FFI_Meta2_Resultado,FFI_DtCriar,FFI_DtAlter)
				values
				('#FACAVALIACAO#','#RIP_MatricAvaliador#',#FFIMETA1QTDITEM#,#FFIMETA1PONTUACAOINICIAL#,#FFIMETA1PONTUACAOOBTIDA#,#FFIMETA1RESULTADO#,#FFIMETA2QTDITEM#,#FFIMETA2PONTUACAOINICIAL#,#FFIMETA2PONTUACAOOBTIDA#,#FFIMETA2RESULTADO#,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120))
			</cfquery>
		<cfelse>	
			<cfquery datasource="#dsnSNCI#">
				UPDATE UN_Ficha_Facin_Avaliador set 
				 FACA_Meta1_AT_OrtoGram = '#FACAMETA1ATORTOGRAM#'
				,FACA_Meta1_AT_CCCP = '#FACAMETA1ATCCCP#'
				,FACA_Meta1_AE_Tecn = '#FACAMETA1AETECH#'
				,FACA_Meta1_AE_Prob = '#FACAMETA1AEPROB#'
				,FACA_Meta1_AE_Valor = '#FACAMETA1AEVALO#'
				,FACA_Meta1_AE_Cosq = '#FACAMETA1AECOSQ#'
				,FACA_Meta1_AE_Norma = '#FACAMETA1AENORMA#'
				,FACA_Meta1_AE_Docu = '#FACAMETA1AEDOCU#'
				,FACA_Meta1_AE_Class = '#FACAMETA1AECLASS#'
				,FACA_Meta1_AE_Orient = '#FACAMETA1AEORIENT#'
				,FACA_Meta1_Pontos = #FACAMETA1PONTOS#
				,FACA_Meta2_AR_Falta = '#FACAMETA2ARFALTA#'
				,FACA_Meta2_AR_Troca = '#FACAMETA2ARTROCA#'
				,FACA_Meta2_AR_Nomen = '#FACAMETA2ARNOMEN#'
				,FACA_Meta2_AR_Ordem = '#FACAMETA2ARORDEM#'
				,FACA_Meta2_AR_Prazo = '#FACAMETA2ARPRAZO#'
				,FACA_Meta2_Pontos = #FACAMETA2PONTOS#
				,FACA_Consideracao_Revisor = '#FACACONSIDERACAOREVISOR#'
				,FACA_Consideracao_Avaliador = '#FACACONSIDERACAOAVALIADOR#'
				,FACA_Consideracao_SCOI = '#FACACONSIDERACAOSCOI#'
				,FACA_Consideracao_SGCIN = '#FACACONSIDERACAOSGCIN#'
				,FACA_DtAlter = CONVERT(char, GETDATE(), 120)
				WHERE 
				FACA_Avaliacao = '#FACAVALIACAO#' AND 
				FACA_Unidade = '#FACUNIDADE#' AND 
				FACA_Matricula='#FACMATRICULA#' AND 
				FACA_Avaliador='#RIP_MatricAvaliador#' and 
				FACA_Grupo=#rsSalva.RIP_NumGrupo# and 
				FACA_Item=#rsSalva.RIP_NumItem#	
			</cfquery>	
			<cfquery datasource="#dsnSNCI#">
				UPDATE UN_Ficha_Facin_Individual set 
				 FFI_Meta1_Qtd_Item = #FFIMETA1QTDITEM#
				,FFI_Meta1_Pontuacao_Inicial = #FFIMETA1PONTUACAOINICIAL#
				,FFI_Meta1_Pontuacao_Obtida = #FFIMETA1PONTUACAOOBTIDA#
				,FFI_Meta1_Resultado = #FFIMETA1RESULTADO#
				,FFI_Meta2_Qtd_Item = #FFIMETA2QTDITEM#
				,FFI_Meta2_Pontuacao_Inicial = #FFIMETA2PONTUACAOINICIAL#
				,FFI_Meta2_Pontuacao_Obtida = #FFIMETA2PONTUACAOOBTIDA#
				,FFI_Meta2_Resultado = #FFIMETA2RESULTADO#
				,FFI_DtAlter = CONVERT(char, GETDATE(), 120)
				where 
				FFI_Avaliacao = '#FACAVALIACAO#' and 
				FFI_Avaliador = '#RIP_MatricAvaliador#'
			</cfquery>				
		</cfif>
	<cfelse>
		<!--- GRUPO DE ACESSO INSPETORES SOMENTE UPDATE--->
		<!--- alterar UN_Ficha_Facin_Avaliador --->
		<cfquery datasource="#dsnSNCI#">
			UPDATE UN_Ficha_Facin_Avaliador SET 
				  FACA_Consideracao_Avaliador = '#FACACONSIDERACAOAVALIADOR#'
				, FACA_DtAlter = CONVERT(char, GETDATE(), 120)
			WHERE 
				FACA_Avaliacao = '#FACAVALIACAO#' AND 
				FACA_Unidade = '#FACUNIDADE#' AND 
				FACA_Matricula='#FACMATRICULA#' AND 
				FACA_Avaliador='#RIP_MatricAvaliador#' and 
				FACA_Grupo=#rsSalva.RIP_NumGrupo# and 
				FACA_Item=#rsSalva.RIP_NumItem#	
		</cfquery>		
	</cfif>
	</cfoutput>
	</table>
<cfoutput>
	<!--- <cflocation url = "../ficha_facin.cfm?form.numinsp=#FACAVALIACAO#&form.grpitem=#form.grp#,#form.itm#"> --->
	<cflocation url = "../ficha_facin_Ref.cfm?numinsp=#FACAVALIACAO#&acao=buscar"> 
</cfoutput>	   

</cffunction>
</cfcomponent>