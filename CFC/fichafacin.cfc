<cfcomponent>
	<cfprocessingdirective pageencoding = "utf-8">	
	<cfparam name = "dsnSNCI" default = "DBSNCI"> 
    <cffunction name="init">
        <cfreturn this>
    </cffunction>
	<cffunction name="salvarPosic"   access="remote" hint="salva a manifestação de qualquer usuário">
		<!---
		<cfdump var=#form#>
		<cfset gil = gil>		
		--->	

		<cfset form.acaofac = 'INC'>
		<cfset form.acaofaca = 'INC'>
		<cfset form.acaoffi = 'INC'>
		<cfquery datasource="#dsnSNCI#" name="rsexistegestor">
			select FAC_Avaliacao 
			from UN_Ficha_Facin 
			WHERE FAC_Unidade = '#form.FACUNIDADE#' and FAC_Avaliacao = convert(varchar,'#form.FACAVALIACAO#') and FAC_Matricula = '#form.facmatricula#'
		</cfquery>
		<cfif rsexistegestor.recordcount gt 0>
			<cfset form.acaofac = 'ALT'>
		</cfif>
		<cfquery datasource="#dsnSNCI#" name="rsexisteFACA">
		   select FACA_Avaliador 
		   from UN_Ficha_Facin_Avaliador
		   where FACA_Unidade = '#form.FACUNIDADE#' and
		   FACA_Avaliacao = '#form.FACAVALIACAO#' and 
		   FACA_Matricula = '#form.facmatricula#' and
		   FACA_Avaliador = '#form.matravaliador#' and 
		   FACA_Grupo = #form.facagrupo# and 
		   FACA_Item = #form.facaitem#
		</cfquery>
		<cfif rsexisteFACA.recordcount gt 0>
			<cfset form.acaofaca = 'ALT'>
		</cfif>
		<cfquery datasource="#dsnSNCI#" name="rsexisteFFI">
			select FFI_Avaliacao from UN_Ficha_Facin_Individual
			where FFI_Avaliacao = '#form.FACAVALIACAO#' and 
			FFI_matricula = '#form.facmatricula#' and
			FFI_Avaliador = '#form.matravaliador#' 
		 </cfquery>		
		<cfif rsexisteFFI.recordcount gt 0>
			<cfset form.acaoffi = 'ALT'>
		</cfif>
		<cfif grpacesso neq 'INSPETORES'>
			<cfif form.acaofac eq 'INC'>
				<!--- inserir UN_Ficha_Facin --->
				<cfquery datasource="#dsnSNCI#">
					insert into UN_Ficha_Facin (FAC_Avaliacao,FAC_Unidade,FAC_Matricula,FAC_Ano,FAC_Data_SEI,FAC_Revisor,FAC_Qtd_Geral,FAC_Qtd_NC,FAC_Qtd_Devolvido,FAC_Pontos_Revisao_Meta1,FAC_Perc_Revisao_Meta1,FAC_Meta1_Peso_Item,FAC_Pontos_Revisao_Meta2,FAC_Perc_Revisao_Meta2,FAC_Meta2_Peso_Item,FAC_Data_Plan_Meta3,FAC_DifDia_Meta3,FAC_Perc_Meta3,FAC_Consideracao,FAC_DtCriar,FAC_DtAlter)
					values
					('#form.FACAVALIACAO#','#form.FACUNIDADE#','#form.FACMATRICULA#','#form.FACANO#','#form.FACDATASEI#','#form.FACREVISOR#',#form.FACQTDGERAL#,#form.FACQTDNC#,#form.FACQTDEVOLVIDO#,#form.FACPONTOSREVISAOMETA1#,#form.FACPERCREVISAOMETA1#,#form.FACMETA1PESOITEM#,#form.FACPONTOSREVISAOMETA2#,#form.FACPERCREVISAOMETA2#,#form.FACMETA2PESOITEM#,'#form.FACDATAPLANMETA3#',#form.FACDIFDIAMETA3#,#form.FACPERCMETA3#,'#form.considerar#',CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120))
				</cfquery>	
			<cfelse>
				<!--- alterar UN_Ficha_Facin --->
				<cfquery datasource="#dsnSNCI#">
					UPDATE UN_Ficha_Facin SET 
					FAC_Pontos_Revisao_Meta1 = #form.FACPONTOSREVISAOMETA1# 
					, FAC_Perc_Revisao_Meta1 = #form.FACPERCREVISAOMETA1#
					, FAC_Meta1_Peso_Item = #form.FACMETA1PESOITEM#
					, FAC_Pontos_Revisao_Meta2 = #form.FACPONTOSREVISAOMETA2#
					, FAC_Perc_Revisao_Meta2 = #form.FACPERCREVISAOMETA2#
					, FAC_Meta2_Peso_Item = #form.FACMETA2PESOITEM#
					, FAC_Data_Plan_Meta3 = '#form.FACDATAPLANMETA3#'
					, FAC_DifDia_Meta3 = #form.FACDIFDIAMETA3#
					, FAC_Perc_Meta3 = #form.FACPERCMETA3#
					, FAC_Consideracao = '#form.considerar#'
					, FAC_DtAlter = CONVERT(char, GETDATE(), 120)
					where FAC_Unidade = '#form.FACUNIDADE#' and FAC_Avaliacao = '#form.FACAVALIACAO#' and FAC_Matricula='#form.FACMATRICULA#'	
				</cfquery>		
			</cfif>
		</cfif>
		<!--- pesquisar dados da avaliação --->
		<cfquery datasource="#dsnSNCI#" name="rsSalva">
			SELECT RIP_MatricAvaliador, RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem
			FROM Resultado_Inspecao
			WHERE RIP_NumInspecao= '#form.FACAVALIACAO#' and 
			RIP_NumGrupo = #form.grp# and RIP_NumItem = #form.itm#
			<cfif grpacesso eq 'INSPETORES'>
				AND RIP_MatricAvaliador = '#form.FACMATRICULA#'
			</cfif>
			ORDER BY RIP_MatricAvaliador, RIP_NumGrupo, RIP_NumItem
		</cfquery>
				
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
		

		<!--- inserção na tabela Un_Ficha_FAcin_avaliador --->
		<cfif grpacesso neq 'INSPETORES'>
			<cfif form.acaofaca eq 'INC'>
				<cfquery datasource="#dsnSNCI#">
					insert into UN_Ficha_Facin_Avaliador (FACA_Unidade,FACA_Avaliacao,FACA_Matricula,FACA_Avaliador,FACA_Grupo,FACA_Item,FACA_Meta1_AT_OrtoGram,FACA_Meta1_AT_CCCP,FACA_Meta1_AE_Tecn,FACA_Meta1_AE_Prob,FACA_Meta1_AE_Valor,FACA_Meta1_AE_Cosq,FACA_Meta1_AE_Norma,FACA_Meta1_AE_Docu,FACA_Meta1_AE_Class,FACA_Meta1_AE_Orient,FACA_Meta1_Pontos,FACA_Meta2_AR_Falta,FACA_Meta2_AR_Troca,FACA_Meta2_AR_Nomen,FACA_Meta2_AR_Ordem,FACA_Meta2_AR_Prazo,FACA_Meta2_Pontos,FACA_DtCriar,FACA_DtAlter)
					values
					('#FACUNIDADE#','#FACAVALIACAO#','#FACMATRICULA#','#RIP_MatricAvaliador#',#form.facagrupo#,#form.facaitem#,'#form.meta1_atorgr#','#form.meta1_atcccp#','#form.meta1_aetecn#','#form.meta1_aeprob#','#form.meta1_aevalo#','#form.meta1_aecsqc#','#form.meta1_aenorm #','#form.meta1_aedocm#','#form.meta1_aeclas#','#form.meta1_orient#',#FACAMETA1PONTOS#,'#form.meta2_arfalt#','#form.meta2_artroc#','#form.meta2_arnomc#','#form.meta2_arorde#','#form.meta2_arpraz#',#FACAMETA2PONTOS#,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120))
				</cfquery>	
			<cfelse>	
				<cfquery datasource="#dsnSNCI#">
					UPDATE UN_Ficha_Facin_Avaliador set 
					 FACA_Meta1_AT_OrtoGram = '#form.meta1_atorgr#'
					,FACA_Meta1_AT_CCCP = '#form.meta1_atcccp#'
					,FACA_Meta1_AE_Tecn = '#form.meta1_aetecn#'
					,FACA_Meta1_AE_Prob = '#form.meta1_aeprob#'
					,FACA_Meta1_AE_Valor = '#form.meta1_aevalo#'
					,FACA_Meta1_AE_Cosq = '#form.meta1_aecsqc#'
					,FACA_Meta1_AE_Norma = '#form.meta1_aenorm #'
					,FACA_Meta1_AE_Docu = '#form.meta1_aedocm#'
					,FACA_Meta1_AE_Class = '#form.meta1_aeclas#'
					,FACA_Meta1_AE_Orient = '#form.meta1_orient#'
					,FACA_Meta1_Pontos = #FACAMETA1PONTOS#
					,FACA_Meta2_AR_Falta = '#form.meta2_arfalt#'
					,FACA_Meta2_AR_Troca = '#form.meta2_artroc#'
					,FACA_Meta2_AR_Nomen = '#form.meta2_arnomc#'
					,FACA_Meta2_AR_Ordem = '#form.meta2_arorde#'
					,FACA_Meta2_AR_Prazo = '#form.meta2_arpraz#'
					,FACA_Meta2_Pontos = #FACAMETA2PONTOS#
					,FACA_DtAlter = CONVERT(char, GETDATE(), 120)
					WHERE 
					FACA_Unidade = '#FACUNIDADE#' AND 
					FACA_Avaliacao = '#FACAVALIACAO#' AND 
					FACA_Matricula='#FACMATRICULA#' AND 
					FACA_Avaliador='#RIP_MatricAvaliador#' and 
					FACA_Grupo=#rsSalva.RIP_NumGrupo# and 
					FACA_Item=#rsSalva.RIP_NumItem#	
				</cfquery>				
			</cfif>
			<cfif form.acaoffi eq 'INC'>
				<cfquery datasource="#dsnSNCI#">
					insert into UN_Ficha_Facin_Individual (FFI_Avaliacao,FFI_Matricula,FFI_Avaliador,FFI_Meta1_Qtd_Item,FFI_Meta1_Pontuacao_Inicial,FFI_Meta1_Pontuacao_Obtida,FFI_Meta1_Resultado,FFI_Meta2_Qtd_Item,FFI_Meta2_Pontuacao_Inicial,FFI_Meta2_Pontuacao_Obtida,FFI_Meta2_Resultado,FFI_DtCriar,FFI_DtAlter)
					values
					('#FACAVALIACAO#','#FACMATRICULA#','#RIP_MatricAvaliador#',#FFIMETA1QTDITEM#,#FFIMETA1PONTUACAOINICIAL#,#FFIMETA1PONTUACAOOBTIDA#,#FFIMETA1RESULTADO#,#FFIMETA2QTDITEM#,#FFIMETA2PONTUACAOINICIAL#,#FFIMETA2PONTUACAOOBTIDA#,#FFIMETA2RESULTADO#,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120))
				</cfquery>
			<cfelse>
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
					FFI_Matricula = '#FACMATRICULA#' and
					FFI_Avaliador = '#RIP_MatricAvaliador#'
				</cfquery>	
			</cfif>			
		<cfelse>
			<!--- GRUPO DE ACESSO INSPETORES SOMENTE UPDATE--->
			<!--- alterar UN_Ficha_Facin_Avaliador --->
			<cfquery datasource="#dsnSNCI#">
				UPDATE UN_Ficha_Facin_Individual SET
					FFI_Consideracao_Inspetor = '#form.considerar#'
					,FFI_DtAlter = CONVERT(char, GETDATE(), 120)
				WHERE 
					FFI_Avaliacao = '#FACAVALIACAO#' and 
					FFI_Matricula = '#FACMATRICULA#' and
					FFI_Avaliador = '#RIP_MatricAvaliador#'
			</cfquery>		
		</cfif>
		</cfoutput>

		<cfoutput>
			<!--- <cflocation url = "../ficha_facin.cfm?form.numinsp=#FACAVALIACAO#&form.grpitem=#form.grp#,#form.itm#"> --->
			<cflocation url = "../ficha_facin_Ref.cfm?numinsp=#FACAVALIACAO#&acao=buscar"> 
		</cfoutput>	   
	
	</cffunction>
	<!--- Este método inspetores por ano e cod_se --->
	<cffunction  name="inspetores" access="remote" ReturnFormat="json" returntype="any">
		<cfargument name="ano" required="true">
		<cfargument name="codse" required="true">
		<cftransaction>
			<cfquery name="rsInsp" datasource="DBSNCI">
				SELECT FFI_Avaliador, Fun_Nome
				FROM UN_Ficha_Facin_Individual 
				INNER JOIN Funcionarios ON FFI_Avaliador = Fun_Matric
				GROUP BY FFI_Avaliacao, FFI_Avaliador, Fun_Nome
				HAVING (((FFI_Avaliacao) Like '%#ano#') AND ((FFI_Avaliacao) Like '#codse#%'))
				ORDER BY Fun_Nome
			</cfquery>
			<cfreturn rsInsp>
		</cftransaction>
	</cffunction>  	
    <!--- Este método Nº das avaliações por ano/cod_se e Matricula inspetor --->
    <cffunction  name="avaliacao" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="ano" required="true">
        <cfargument name="codse" required="true">
        <cfargument name="matr" required="true">
        <cftransaction>
            <cfquery name="rsavalia" datasource="DBSNCI">
                SELECT FFI_Avaliacao, Und_Descricao
                FROM Unidades 
                INNER JOIN (Inspecao 
                INNER JOIN UN_Ficha_Facin_Individual ON INP_NumInspecao = FFI_Avaliacao) ON Und_Codigo = INP_Unidade
                GROUP BY FFI_Avaliador, FFI_Avaliacao, Und_Descricao
                HAVING (((FFI_Avaliador)='#matr#') AND ((FFI_Avaliacao) Like '%#ano#'))
                ORDER BY Und_Descricao
            </cfquery>
            <cfreturn rsavalia>
        </cftransaction>
    </cffunction>  	
</cfcomponent>