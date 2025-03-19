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
		<cfif form.grpacesso neq 'INSPETORES'>
			<cfif form.acaofac eq 'INC'>
				<!--- inserir UN_Ficha_Facin --->
				<cfquery datasource="#dsnSNCI#">
					insert into UN_Ficha_Facin (FAC_Avaliacao,FAC_Unidade,FAC_Matricula,FAC_Ano,FAC_Data_SEI,FAC_Revisor,FAC_Qtd_Geral,FAC_Qtd_NC,FAC_Qtd_Devolvido,FAC_Pontos_Revisao_Meta1,FAC_Perc_Revisao_Meta1,FAC_Meta1_Peso_Item,FAC_Pontos_Revisao_Meta2,FAC_Perc_Revisao_Meta2,FAC_Meta2_Peso_Item,FAC_Data_Plan_Meta3,FAC_DifDia_Meta3,FAC_Perc_Meta3,FAC_DtCriar,FAC_DtAlter)
					values
					('#form.FACAVALIACAO#','#form.FACUNIDADE#','#form.FACMATRICULA#','#form.FACANO#','#form.FACDATASEI#','#form.FACREVISOR#',#form.FACQTDGERAL#,#form.FACQTDNC#,#form.FACQTDEVOLVIDO#,#form.FACPONTOSREVISAOMETA1#,#form.FACPERCREVISAOMETA1#,#form.FACMETA1PESOITEM#,#form.FACPONTOSREVISAOMETA2#,#form.FACPERCREVISAOMETA2#,#form.FACMETA2PESOITEM#,'#form.FACDATAPLANMETA3#',#form.FACDIFDIAMETA3#,#form.FACPERCMETA3#,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120))
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
			<cfif form.grpacesso eq 'INSPETORES'>
				AND RIP_MatricAvaliador = '#form.FACMATRICULA#'
			</cfif>
		</cfquery>
				
		<!--- <cfdump var="#form#">  --->
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
		<cfif form.grpacesso neq 'INSPETORES'>
			<cfif form.acaofaca eq 'INC'>
				<cfquery datasource="#dsnSNCI#">
					insert into UN_Ficha_Facin_Avaliador (FACA_Unidade,FACA_Avaliacao,FACA_Matricula,FACA_Avaliador,FACA_Grupo,FACA_Item,FACA_Meta1_AT_OrtoGram,FACA_Meta1_AT_CCCP,FACA_Meta1_AE_Tecn,FACA_Meta1_AE_Prob,FACA_Meta1_AE_Valor,FACA_Meta1_AE_Cosq,FACA_Meta1_AE_Norma,FACA_Meta1_AE_Docu,FACA_Meta1_AE_Class,FACA_Meta1_AE_Orient,FACA_Meta1_Pontos,FACA_Meta2_AR_Falta,FACA_Meta2_AR_Troca,FACA_Meta2_AR_Nomen,FACA_Meta2_AR_Ordem,FACA_Meta2_AR_Prazo,FACA_Meta2_Pontos,FACA_Consideracao,FACA_DtCriar,FACA_DtAlter)
					values
					('#FACUNIDADE#','#FACAVALIACAO#','#FACMATRICULA#','#RIP_MatricAvaliador#',#form.facagrupo#,#form.facaitem#,'#form.meta1_atorgr#','#form.meta1_atcccp#','#form.meta1_aetecn#','#form.meta1_aeprob#','#form.meta1_aevalo#','#form.meta1_aecsqc#','#form.meta1_aenorm #','#form.meta1_aedocm#','#form.meta1_aeclas#','#form.meta1_orient#',#meta1_pto_obtida#,'#form.meta2_arfalt#','#form.meta2_artroc#','#form.meta2_arnomc#','#form.meta2_arorde#','#form.meta2_arpraz#',#meta2_pto_obtida#,'#form.considerargestor#',CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120))
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
					,FACA_Meta1_Pontos = #meta1_pto_obtida#
					,FACA_Meta2_AR_Falta = '#form.meta2_arfalt#'
					,FACA_Meta2_AR_Troca = '#form.meta2_artroc#'
					,FACA_Meta2_AR_Nomen = '#form.meta2_arnomc#'
					,FACA_Meta2_AR_Ordem = '#form.meta2_arorde#'
					,FACA_Meta2_AR_Prazo = '#form.meta2_arpraz#'
					,FACA_Consideracao = '#form.considerargestor#'
					,FACA_Meta2_Pontos = #meta2_pto_obtida#
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
			<!--- atualizar tabelas --->
<!--- inicio atualização --->

	<cfquery datasource="#dsnSNCI#" name="rsfacinaval">
		SELECT FAC_Qtd_Geral,FAC_Meta1_Peso_Item, FAC_Meta2_Peso_Item,FACA_Unidade, FACA_Avaliacao, FACA_Matricula, FACA_Avaliador, FACA_Grupo, FACA_Item, FACA_Meta1_AT_OrtoGram, FACA_Meta1_AT_CCCP, FACA_Meta1_AE_Tecn, FACA_Meta1_AE_Prob, FACA_Meta1_AE_Valor, FACA_Meta1_AE_Cosq, FACA_Meta1_AE_Norma, FACA_Meta1_AE_Docu, FACA_Meta1_AE_Class, FACA_Meta1_AE_Orient, FACA_Meta1_Pontos, FACA_Meta2_AR_Falta, FACA_Meta2_AR_Troca, FACA_Meta2_AR_Nomen, FACA_Meta2_AR_Ordem, FACA_Meta2_AR_Prazo, FACA_Meta2_Pontos
		FROM UN_Ficha_Facin 
		INNER JOIN UN_Ficha_Facin_Avaliador ON (FAC_Matricula = FACA_Matricula) AND (FAC_Avaliacao = FACA_Avaliacao) AND (FAC_Unidade = FACA_Unidade)
		WHERE FACA_Avaliacao='#FACAVALIACAO#'
	</cfquery>

	<cfset PesoAvaliacao = 0>
	<cfset descontometa1 = 0>
	<cfset descontometa2 = 0>
	<cfset PesoAvaliacao = numberFormat((100/rsfacinaval.FAC_Qtd_Geral),'___.00')>
	<cfset descontometa1 = numberFormat((100/rsfacinaval.FAC_Qtd_Geral)/10,'___.000')>
	<cfset descontometa2 = numberFormat((100/rsfacinaval.FAC_Qtd_Geral)/5,'___.000')>
	<cfset somageralmeta1 = 0>
	<cfset somageralmeta2 = 0>
	<cfset FACPontosRevisaoMeta1 = 0>
	<cfset FACPercRevisaoMeta1 = 0>
	<cfset FACPontosRevisaoMeta2 = 0>
	<cfset FACPercRevisaoMeta2 = 0>

	<cfloop query="rsfacinaval">
		<cfset FACMeta1PesoItem = 0>
		<cfset FACMeta2PesoItem = 0>
		<cfset somameta1 = 0>
		<cfset somameta2 = 0>

		<cfset somameta1 = FACA_Meta1_AT_OrtoGram + FACA_Meta1_AT_CCCP + FACA_Meta1_AE_Tecn + FACA_Meta1_AE_Prob + FACA_Meta1_AE_Valor + FACA_Meta1_AE_Cosq + FACA_Meta1_AE_Norma + FACA_Meta1_AE_Docu + FACA_Meta1_AE_Class + FACA_Meta1_AE_Orient>
		<cfif somameta1 lte 0>
			<cfset FACMeta1PesoItem = PesoAvaliacao>
		<cfelse>
			<cfset FACMeta1PesoItem = numberFormat((descontometa1*10) - (somameta1*descontometa1),'___.00')>
		</cfif>
		<cfset somageralmeta1 = somageralmeta1 + somameta1>

		<cfset somameta2 = FACA_Meta2_AR_Falta + FACA_Meta2_AR_Troca + FACA_Meta2_AR_Nomen + FACA_Meta2_AR_Ordem + FACA_Meta2_AR_Prazo>
		<cfif somameta2 lte 0>
			<cfset FACMeta2PesoItem = PesoAvaliacao>
		<cfelse>
			<cfset FACMeta2PesoItem = numberFormat((descontometa2*5) - (somameta2*descontometa2),'___.00')>
		</cfif>
		<cfset somageralmeta2 = somageralmeta2 + somameta2>
		<cfquery datasource="#dsnSNCI#">
			update UN_Ficha_Facin_Avaliador set FACA_Meta1_Pontos=#FACMeta1PesoItem#,FACA_Meta2_Pontos=#FACMeta2PesoItem#
			WHERE FACA_Avaliacao='#FACAVALIACAO#' and FACA_Grupo=#FACA_Grupo# and FACA_Item=#FACA_Item#
		</cfquery>
	</cfloop>

	<cfset FACPontosRevisaoMeta1 = numberFormat(rsfacinaval.FAC_Qtd_Geral - (somageralmeta1*descontometa1),'___.00')>
    <cfset FACPercRevisaoMeta1 = numberFormat((FACPontosRevisaoMeta1/rsfacinaval.FAC_Qtd_Geral)*100,'___.00')>

    <cfset FACPontosRevisaoMeta2 = numberFormat(rsfacinaval.FAC_Qtd_Geral - (somageralmeta2*descontometa2),'___.00')>
    <cfset FACPercRevisaoMeta2 = numberFormat((FACPontosRevisaoMeta2/rsfacinaval.FAC_Qtd_Geral)*100,'___.00')>

    <cfquery datasource="#dsnSNCI#">
        UPDATE UN_Ficha_Facin SET FAC_Pontos_Revisao_Meta1=#FACPontosRevisaoMeta1#, 
        FAC_Perc_Revisao_Meta1 = #FACPercRevisaoMeta1#, 
        FAC_Pontos_Revisao_Meta2=#FACPontosRevisaoMeta2#,
        FAC_Perc_Revisao_Meta2 = #FACPercRevisaoMeta2#
        WHERE FAC_Avaliacao= '#FACAVALIACAO#'
    </cfquery>
<!--- Fnal atualização --->					
			<!--- fim atualizar tabelas --->

		<cfelse>
			<!--- GRUPO DE ACESSO INSPETORES SOMENTE UPDATE--->
			<!--- alterar UN_Ficha_Facin_Avaliador --->
			<cfquery datasource="#dsnSNCI#">
				UPDATE UN_Ficha_Facin_Avaliador SET
					 FACA_Consideracao_Inspetor = '#form.considerinspetor#'
					,FACA_DtAlter = CONVERT(char, GETDATE(), 120)
				WHERE 
					FACA_Avaliacao = '#FACAVALIACAO#' and 
					FACA_Avaliador = '#RIP_MatricAvaliador#' and
					FACA_Grupo=#rsSalva.RIP_NumGrupo# and 
					FACA_Item=#rsSalva.RIP_NumItem#	
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
		<cfargument name="dtinic" required="true">
		<cfargument name="dtfinal" required="true">
		<cfargument name="codse" required="true">
		<cftransaction>
			<cfquery name="rsInsp" datasource="DBSNCI">
				SELECT distinct FFI_Avaliador, Fun_Nome
				FROM UN_Ficha_Facin INNER JOIN UN_Ficha_Facin_Individual ON (FAC_Matricula = FFI_Matricula) AND (FAC_Avaliacao = FFI_Avaliacao)
				INNER JOIN Funcionarios ON FFI_Avaliador = Fun_Matric
				GROUP BY FFI_Avaliacao, FFI_Avaliador, Fun_Nome, FAC_DtConcluirFacin
				HAVING FFI_Avaliacao Like '%#ano#' AND FFI_Avaliacao Like '#codse#%' and
				FAC_DtConcluirFacin between '#dtinic#' and '#dtfinal#'
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
		<cfargument name="dtinic" required="true">
		<cfargument name="dtfinal" required="true">
        <cftransaction>
            <cfquery name="rsavalia" datasource="DBSNCI">
				SELECT FFI_Avaliacao, Und_Descricao, FAC_DtConcluirFacin, FFI_Avaliador
				FROM UN_Ficha_Facin 
				INNER JOIN Unidades ON FAC_Unidade = Und_Codigo
				INNER JOIN UN_Ficha_Facin_Individual ON (FAC_Matricula = FFI_Matricula) AND (FAC_Avaliacao = FFI_Avaliacao)
				WHERE FFI_Avaliador='#matr#' AND FFI_Avaliacao Like '%#ano#' and FAC_DtConcluirFacin between '#dtinic#' and '#dtfinal#'
				ORDER BY Und_Descricao
            </cfquery>
            <cfreturn rsavalia>
        </cftransaction>
    </cffunction> 
	<cffunction name="finalizarfacin" access="remote" returntype="any" hint="Registrar a finalização da facin para o gestor logado">
			<cfargument name="unid" required="true">
			<cfargument name="aval" required="true">
			<cfargument name="matr" required="true">
			
			<cftry>
				<cfquery datasource="DBSNCI">
						update UN_Ficha_Facin set
							FAC_DtConcluirFacin = CONVERT(char, GETDATE(), 120)
						WHERE FAC_Unidade='#unid#' AND 
						FAC_Avaliacao ='#aval#' AND 
						FAC_Matricula = '#matr#'
				</cfquery> 
					<cfset ret = 'Conclusão da FACIN - realizada com sucesso!'> 
				<cfcatch type="any">
					<cfset ret = 'Conclusão da FACIN - Falhou!'>  
				</cfcatch>
			</cftry>
			<cfreturn #ret#>
	</cffunction>	
	<!--- Este método inspetores por ano e cod_se --->
	<cffunction  name="gestao" access="remote" ReturnFormat="json" returntype="any">
		<cfargument name="aval" required="true">
		<cfargument name="matr" required="true">
		<cftransaction>
			<cfquery name="rsgestao" datasource="DBSNCI">
				SELECT FFI_Meta1_Qtd_Item, FFI_Meta1_Pontuacao_Inicial, FFI_Meta1_Pontuacao_Obtida, FFI_Meta1_Resultado, FFI_Meta2_Qtd_Item, FFI_Meta2_Pontuacao_Inicial, FFI_Meta2_Pontuacao_Obtida, FFI_Meta2_Resultado, FFI_Avaliacao,FAC_Qtd_Geral, FAC_Perc_Meta3,TUN_Descricao
				FROM (Unidades 
				INNER JOIN (UN_Ficha_Facin 
				INNER JOIN UN_Ficha_Facin_Individual ON (FAC_Matricula = FFI_Matricula) AND (FAC_Avaliacao = FFI_Avaliacao)) ON Und_Codigo = FAC_Unidade) 
				INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
				WHERE FFI_Avaliador='#matr#' 
				<cfif aval neq 't'>
					and FFI_Avaliacao='#aval#'
				</cfif>
				ORDER BY FFI_Avaliacao
			</cfquery>
			<cfreturn rsgestao>
		</cftransaction>
	</cffunction>  	
</cfcomponent>