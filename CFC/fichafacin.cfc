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
			WHERE FAC_Unidade = '#form.idunidade#' and FAC_Avaliacao = convert(varchar,'#form.idavaliacao#') and FAC_MatriculaGestor = '#form.idmatrgestor#'
		</cfquery>
		<cfif rsexistegestor.recordcount gt 0>
			<cfset form.acaofac = 'ALT'>
		</cfif>
		<cfquery datasource="#dsnSNCI#" name="rsexisteFACA">
		   select FACA_MatriculaInspetor 
		   from UN_Ficha_Facin_Avaliador
		   where FACA_Unidade = '#form.idunidade#' and
		   FACA_Avaliacao = '#form.idavaliacao#' and 
		   FACA_MatriculaGestor = '#form.idmatrgestor#' and
		   FACA_MatriculaInspetor = '#form.idmatrinspetor#' and 
		   FACA_Grupo = #form.idgrupo# and 
		   FACA_Item = #form.iditem#
		</cfquery>
		<cfif rsexisteFACA.recordcount gt 0>
			<cfset form.acaofaca = 'ALT'>
		</cfif>
		<cfquery datasource="#dsnSNCI#" name="rsexisteFFI">
			select FFI_Avaliacao from UN_Ficha_Facin_Individual
			where FFI_Avaliacao = '#form.idavaliacao#' and 
			FFI_MatriculaGestor = '#form.idmatrgestor#' and
			FFI_MatriculaInspetor = '#form.idmatrinspetor#' 
		 </cfquery>		
		<cfif rsexisteFFI.recordcount gt 0>
			<cfset form.acaoffi = 'ALT'>
		</cfif>
		<cfif form.grpacesso neq 'INSPETORES'>
			<cfif form.acaofac eq 'INC'>
				<!--- inserir UN_Ficha_Facin --->
				<cfquery datasource="#dsnSNCI#">
					insert into UN_Ficha_Facin (FAC_Unidade,FAC_Avaliacao,FAC_MatriculaGestor,FAC_Data_SEI,FAC_Qtd_Avaliacao,FAC_Qtd_Correcaotexto,FAC_Qtd_Reanalise,FAC_Perc_Reanalise,FAC_Pontos_Revisao_Meta1,FAC_Resultado_Meta1,FAC_Peso_Meta1,FAC_Pontos_Revisao_Meta2,FAC_Resultado_Meta2,FAC_Peso_Meta2,FAC_Data_Plan_Meta3,FAC_DifDia_Meta3,FAC_Resultado_Meta3,FAC_DtCriar,FAC_DtAlter)
					values
					('#form.idunidade#','#form.idavaliacao#','#form.idmatrgestor#','#form.facdatasei#',#form.facqtdavaliacao#,#form.facqtdcorrecaotexto#,#form.facqtdreanalise#,#form.facpercreanalise#,#form.facpontosrevisaometa1#,#form.facresultadometa1#,#form.facpesometa1#,#form.facpontosrevisaometa2#,#form.facresultadometa2#,#form.facpesometa2#,'#form.FACDATAPLANMETA3#',#form.FACDIFDIAMETA3#,#form.facresultadometa3#,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120))
				</cfquery>	
			<cfelse>
				<!--- alterar UN_Ficha_Facin --->
				<cfquery datasource="#dsnSNCI#">
					UPDATE UN_Ficha_Facin SET 
					  FAC_Data_SEI = '#form.facdatasei#'
					, FAC_Qtd_Avaliacao = #form.facqtdavaliacao#
					, FAC_Qtd_Correcaotexto = #form.facqtdcorrecaotexto#
					, FAC_Qtd_Reanalise = #form.facqtdreanalise#
					, FAC_Perc_Reanalise = #form.facpercreanalise#
					, FAC_Pontos_Revisao_Meta1 = #form.facpontosrevisaometa1# 
					, FAC_Resultado_Meta1 = #form.facresultadometa1#
					, FAC_Peso_Meta1 = #form.facpesometa1#
					, FAC_Pontos_Revisao_Meta2 = #form.facpontosrevisaometa2#
					, FAC_Resultado_Meta2 = #form.facresultadometa2#
					, FAC_Peso_Meta2 = #form.facpesometa2#
					, FAC_Data_Plan_Meta3 = '#form.FACDATAPLANMETA3#'
					, FAC_DifDia_Meta3 = #form.FACDIFDIAMETA3#
					, FAC_Resultado_Meta3 = #form.facresultadometa3#
					, FAC_DtAlter = CONVERT(char, GETDATE(), 120)
					where FAC_Unidade = '#form.idunidade#' and FAC_Avaliacao = '#form.idavaliacao#' and FAC_MatriculaGestor='#form.idmatrgestor#'	
				</cfquery>		
			</cfif>
		</cfif>
		<cfoutput>
		<!--- inserção na tabela Un_Ficha_FAcin_avaliador --->
		<cfif form.grpacesso neq 'INSPETORES'>
			<cfif form.acaofaca eq 'INC'>
				<cfquery datasource="#dsnSNCI#">
					insert into UN_Ficha_Facin_Avaliador (FACA_Unidade,FACA_Avaliacao,FACA_MatriculaGestor,FACA_MatriculaInspetor,FACA_Grupo,FACA_Item,FACA_Meta1_AT_OrtoGram,FACA_Meta1_AT_CCCP,FACA_Meta1_AE_Tecn,FACA_Meta1_AE_Prob,FACA_Meta1_AE_Valor,FACA_Meta1_AE_Cosq,FACA_Meta1_AE_Norma,FACA_Meta1_AE_Docu,FACA_Meta1_AE_Class,FACA_Meta1_AE_Orient,FACA_Meta1_Pontos,FACA_Meta2_AR_Falta,FACA_Meta2_AR_Troca,FACA_Meta2_AR_Nomen,FACA_Meta2_AR_Ordem,FACA_Meta2_AR_Prazo,FACA_Meta2_Pontos,FACA_ConsideracaoGestor,FACA_Tipo,FACA_DtCriar,FACA_DtAlter)
					values
					('#form.idunidade#','#form.idavaliacao#','#form.idmatrgestor#','#form.idmatrinspetor#',#form.idgrupo#,#form.iditem#,'#form.meta1atorgr#','#form.meta1atcccp#','#form.meta1aetecn#','#form.meta1aeprob#','#form.meta1aevalo#','#form.meta1aecsqc#','#form.meta1aenorm #','#form.meta1aedocm#','#form.meta1aeclas#','#form.meta1orient#',#facameta1pontos#,'#form.meta2arfalt#','#form.meta2artroc#','#form.meta2arnomc#','#form.meta2arorde#','#form.meta2arpraz#',#facameta2pontos#,'#form.considerargestor#','#form.facatipo#',CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120))
				</cfquery>	
			<cfelse>	
				<cfquery datasource="#dsnSNCI#">
					UPDATE UN_Ficha_Facin_Avaliador set 
					 FACA_Meta1_AT_OrtoGram = '#form.meta1atorgr#'
					,FACA_Meta1_AT_CCCP = '#form.meta1atcccp#'
					,FACA_Meta1_AE_Tecn = '#form.meta1aetecn#'
					,FACA_Meta1_AE_Prob = '#form.meta1aeprob#'
					,FACA_Meta1_AE_Valor = '#form.meta1aevalo#'
					,FACA_Meta1_AE_Cosq = '#form.meta1aecsqc#'
					,FACA_Meta1_AE_Norma = '#form.meta1aenorm#'
					,FACA_Meta1_AE_Docu = '#form.meta1aedocm#'
					,FACA_Meta1_AE_Class = '#form.meta1aeclas#'
					,FACA_Meta1_AE_Orient = '#form.meta1orient#'
					,FACA_Meta1_Pontos = #facameta1pontos#
					,FACA_Meta2_AR_Falta = '#form.meta2arfalt#'
					,FACA_Meta2_AR_Troca = '#form.meta2artroc#'
					,FACA_Meta2_AR_Nomen = '#form.meta2arnomc#'
					,FACA_Meta2_AR_Ordem = '#form.meta2arorde#'
					,FACA_Meta2_AR_Prazo = '#form.meta2arpraz#'
					,FACA_Meta2_Pontos = #facameta2pontos#
					,FACA_Tipo = '#form.facatipo#'
					,Faca_ConsideracaoGestor = '#form.considerargestor#'
					,FACA_DtAlter = CONVERT(char, GETDATE(), 120)
					WHERE 
					FACA_Unidade = '#form.idunidade#' AND 
					FACA_Avaliacao = '#form.idavaliacao#' AND 
					FACA_MatriculaGestor='#form.idmatrgestor#' AND 
					FACA_MatriculaInspetor='#form.idmatrinspetor#' and 
					FACA_Grupo=#form.idgrupo# and 
					FACA_Item=#form.iditem#	
				</cfquery>				
			</cfif>
		
			<cfif form.acaoffi eq 'INC'>
				<cfquery datasource="#dsnSNCI#">
					insert into UN_Ficha_Facin_Individual (FFI_Avaliacao,FFI_MatriculaGestor,FFI_MatriculaInspetor,FFI_Qtd_Item,FFI_Meta1_Peso,FFI_Meta1_Pontuacao_Obtida,FFI_Meta1_Resultado,FFI_Meta2_Peso,FFI_Meta2_Pontuacao_Obtida,FFI_Meta2_Resultado,FFI_DtCriar,FFI_DtAlter)
					values
					('#form.idavaliacao#','#form.idmatrgestor#','#form.idmatrinspetor#',#form.ffiqtditem#,#form.ffimeta1peso#,#form.ffimeta1pontuacaobtida#,#form.ffimeta1resultado#,#form.ffimeta2peso#,#form.ffimeta2pontuacaobtida#,#form.ffimeta2resultado#,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120))
				</cfquery>
			<cfelse>				
				<cfquery datasource="#dsnSNCI#">
					UPDATE UN_Ficha_Facin_Individual set 
					 FFI_Qtd_Item = #ffiqtditem#
					,FFI_Meta1_Peso = #form.ffimeta1peso#
					,FFI_Meta1_Pontuacao_Obtida = #form.ffimeta1pontuacaobtida#
					,FFI_Meta1_Resultado = #form.ffimeta1resultado#
					,FFI_Meta2_Peso = #form.ffimeta2peso#
					,FFI_Meta2_Pontuacao_Obtida = #form.ffimeta2pontuacaobtida#
					,FFI_Meta2_Resultado = #form.ffimeta2resultado#
					,FFI_DtAlter = CONVERT(char, GETDATE(), 120)
					where 
					FFI_Avaliacao = '#form.idavaliacao#' and 
					FFI_MatriculaGestor = '#form.idmatrgestor#' and
					FFI_MatriculaInspetor = '#form.idmatrinspetor#'
				</cfquery>	
			</cfif>	
			<cfif form.facatipo eq 'Com Reanálise'>
				<cfquery datasource="#dsnSNCI#">
					UPDATE UN_Ficha_Facin_Avaliador set 
					FACA_Meta2_AR_Prazo = '#form.meta2arpraz#'
					WHERE 
					FACA_Unidade = '#form.idunidade#' AND 
					FACA_Avaliacao = '#form.idavaliacao#'  
				</cfquery>				
			</cfif> 
			<!--- inicio atualização --->
			<cfquery datasource="#dsnSNCI#" name="rsfacinaval">
				SELECT FAC_Qtd_Avaliacao,FAC_Peso_Meta1, FAC_Peso_Meta2,FACA_Unidade, FACA_Avaliacao, FACA_MatriculaGestor, FACA_MatriculaInspetor, FACA_Grupo, FACA_Item, FACA_Meta1_AT_OrtoGram, FACA_Meta1_AT_CCCP, FACA_Meta1_AE_Tecn, FACA_Meta1_AE_Prob, FACA_Meta1_AE_Valor, FACA_Meta1_AE_Cosq, FACA_Meta1_AE_Norma, FACA_Meta1_AE_Docu, FACA_Meta1_AE_Class, FACA_Meta1_AE_Orient, FACA_Meta1_Pontos, FACA_Meta2_AR_Falta, FACA_Meta2_AR_Troca, FACA_Meta2_AR_Nomen, FACA_Meta2_AR_Ordem, FACA_Meta2_AR_Prazo, FACA_Meta2_Pontos
				,FFI_MatriculaInspetor,FFI_Qtd_Item
				FROM (UN_Ficha_Facin 
				INNER JOIN UN_Ficha_Facin_Avaliador ON (FAC_MatriculaGestor = FACA_MatriculaGestor) AND (FAC_Avaliacao = FACA_Avaliacao) AND (FAC_Unidade = FACA_Unidade)) 
				INNER JOIN UN_Ficha_Facin_Individual ON (FACA_MatriculaInspetor = FFI_MatriculaInspetor) AND (FACA_MatriculaGestor = FFI_MatriculaGestor) AND (FACA_Avaliacao = FFI_Avaliacao)	
				WHERE FACA_Avaliacao='#form.idavaliacao#' 
				order by FACA_MatriculaInspetor, FACA_Grupo, FACA_Item
			</cfquery>
			<cfquery name="rsInsp" dbtype = "query">
				SELECT distinct FACA_MatriculaInspetor 
				FROM rsfacinaval
				order by FACA_MatriculaInspetor
			</cfquery>
			<cfset facpesometa1aval = numberFormat((100/rsfacinaval.FAC_Qtd_Avaliacao)/10,'___.000')>
			<cfset facpesometa2aval = numberFormat((100/rsfacinaval.FAC_Qtd_Avaliacao)/5,'___.000')>
			<cfset somageralmeta1 = 0>
			<cfset somageralmeta2 = 0>
			<cfloop query="rsInsp">
				<cfset ffimatriculainspetor = rsInsp.FACA_MatriculaInspetor> 
				<cfquery name="rsDados" dbtype = "query">
					SELECT FACA_MatriculaGestor,FFI_Qtd_Item, FACA_Grupo, FACA_Item, FACA_Meta1_AT_OrtoGram, FACA_Meta1_AT_CCCP, FACA_Meta1_AE_Tecn, FACA_Meta1_AE_Prob, FACA_Meta1_AE_Valor, FACA_Meta1_AE_Cosq, FACA_Meta1_AE_Norma, 
					FACA_Meta1_AE_Docu, FACA_Meta1_AE_Class, FACA_Meta1_AE_Orient, FACA_Meta1_Pontos, FACA_Meta2_AR_Falta, FACA_Meta2_AR_Troca, FACA_Meta2_AR_Nomen, FACA_Meta2_AR_Ordem, 
					FACA_Meta2_AR_Prazo, FACA_Meta2_Pontos 
					FROM rsfacinaval
					where FACA_MatriculaInspetor = '#ffimatriculainspetor#'
					order by FACA_Grupo, FACA_Item 
				</cfquery>
				<cfset descontometa1inspetor = 0>
				<cfset descontometa2inspetor = 0>      
				<cfloop query="rsDados">
					<cfset ffimatriculagestor = rsDados.FACA_MatriculaGestor>   
					<cfset ffiqtditeminspetor = rsDados.FFI_Qtd_Item> 
					<cfset facameta1pesoind = numberFormat((100/rsDados.FFI_Qtd_Item)/10,'___.000')>
					<cfset facameta2pesoind = numberFormat((100/rsDados.FFI_Qtd_Item)/5,'___.000')>
					<cfset facameta1pontos = 0>
					<cfset facameta2pontos = 0>
					<cfset somameta1 = 0>
					<cfset somameta2 = 0>
					<cfset somameta1 = rsDados.FACA_Meta1_AT_OrtoGram + rsDados.FACA_Meta1_AT_CCCP + rsDados.FACA_Meta1_AE_Tecn + rsDados.FACA_Meta1_AE_Prob + rsDados.FACA_Meta1_AE_Valor + rsDados.FACA_Meta1_AE_Cosq + rsDados.FACA_Meta1_AE_Norma + rsDados.FACA_Meta1_AE_Docu + rsDados.FACA_Meta1_AE_Class + rsDados.FACA_Meta1_AE_Orient>
					<cfif somameta1 lte 0>
						<cfset facameta1pontos = numberFormat(facameta1pesoind*10,'___.000')>
					<cfelse>
						<cfset facameta1pontos = numberFormat((facameta1pesoind*10) - (somameta1*facameta1pesoind),'___.000')>
					</cfif>
					<cfset somageralmeta1 = somageralmeta1 + somameta1>
					<cfset descontometa1inspetor = descontometa1inspetor + somameta1>
					<cfset somameta2 = rsDados.FACA_Meta2_AR_Falta + rsDados.FACA_Meta2_AR_Troca + rsDados.FACA_Meta2_AR_Nomen + rsDados.FACA_Meta2_AR_Ordem + rsDados.FACA_Meta2_AR_Prazo>
					<cfif somameta2 lte 0>
						<cfset facameta2pontos = numberFormat(facameta2pesoind*5,'___.000')>
					<cfelse>
						<cfset facameta2pontos = numberFormat((facameta2pesoind*5) - (somameta2*facameta2pesoind),'___.000')>
					</cfif>
					<cfset somageralmeta2 = somageralmeta2 + somameta2>
					<cfset descontometa2inspetor = descontometa2inspetor + somameta2>
					<cfquery datasource="#dsnSNCI#">
						update UN_Ficha_Facin_Avaliador set FACA_Meta1_Pontos=#facameta1pontos#,FACA_Meta2_Pontos=#facameta2pontos#
						WHERE FACA_Avaliacao='#form.idavaliacao#' and FACA_Grupo=#rsDados.FACA_Grupo# and FACA_Item=#rsDados.FACA_Item# and FACA_MatriculaInspetor = '#ffimatriculainspetor#'
					</cfquery> 
				</cfloop>
			
				<cfset ffimeta1pontuacaoobtida = numberFormat((ffiqtditeminspetor - (descontometa1inspetor * facameta1pesoind)),'___.00')>
				<cfset ffimeta2pontuacaoobtida = numberFormat((ffiqtditeminspetor - (descontometa2inspetor * facameta2pesoind)),'___.00')>
				<cfset ffimeta1resultado = numberFormat((ffimeta1pontuacaoobtida / ffiqtditeminspetor)*100,'___.00')>
				<cfset ffimeta2resultado = numberFormat((ffimeta2pontuacaoobtida / ffiqtditeminspetor)*100,'___.00')>    
				<cfquery datasource="#dsnSNCI#">
					UPDATE UN_Ficha_Facin_Individual set 
						FFI_Meta1_Peso = #facameta1pesoind#
					,FFI_Meta1_Pontuacao_Obtida = #ffimeta1pontuacaoobtida#
					,FFI_Meta1_Resultado = #ffimeta1resultado#
					,FFI_Meta2_Peso = #facameta2pesoind#
					,FFI_Meta2_Pontuacao_Obtida = #ffimeta2pontuacaoobtida#
					,FFI_Meta2_Resultado = #ffimeta2resultado#
					where 
					FFI_Avaliacao = '#form.idavaliacao#' and 
					FFI_MatriculaGestor = '#ffimatriculagestor#' and
					FFI_MatriculaInspetor = '#ffimatriculainspetor#'
				</cfquery>     
			</cfloop>
			<cfloop>
				<cfset facpontosrevisaometa1 = numberFormat(rsfacinaval.FAC_Qtd_Avaliacao - (somageralmeta1*facpesometa1aval),'___.00')>
				<cfset facresultadometa1 = numberFormat((facpontosrevisaometa1/rsfacinaval.FAC_Qtd_Avaliacao)*100,'___.00')>
				<cfset facpontosrevisaometa2 = numberFormat(rsfacinaval.FAC_Qtd_Avaliacao - (somageralmeta2*facpesometa2aval),'___.00')>
				<cfset facresultadometa2 = numberFormat((facpontosrevisaometa2/rsfacinaval.FAC_Qtd_Avaliacao)*100,'___.00')>
				<cfquery datasource="#dsnSNCI#">
					UPDATE UN_Ficha_Facin SET FAC_Peso_Meta1=#facpesometa1aval#, 
					FAC_Pontos_Revisao_Meta1=#facpontosrevisaometa1#, 
					FAC_Resultado_Meta1 = #facresultadometa1#, 
					FAC_Peso_Meta2 = #facpesometa2aval#,
					FAC_Pontos_Revisao_Meta2=#facpontosrevisaometa2#,
					FAC_Resultado_Meta2 = #facresultadometa2#
					WHERE FAC_Avaliacao= '#form.idavaliacao#'
				</cfquery>
			</cfloop>
			<!--- Final atualização --->						
		<cfelse>
			<!--- GRUPO DE ACESSO INSPETORES SOMENTE UPDATE--->
			<!--- alterar UN_Ficha_Facin_Avaliador --->
			<cfquery datasource="#dsnSNCI#">
				UPDATE UN_Ficha_Facin_Avaliador SET
					 FACA_ConsideracaoInspetor = '#form.considerinspetor#'
					,FACA_DtAlter = CONVERT(char, GETDATE(), 120)
				WHERE 
					FACA_Avaliacao = '#form.idavaliacao#' and 
					FACA_MatriculaInspetor = '#form.idmatrinspetor#' and
					FACA_Grupo=#form.idgrupo# and 
					FACA_Item=#form.iditem#	
			</cfquery>	
		</cfif>
		</cfoutput>

		<cfoutput>
			<!--- <cflocation url = "../ficha_facin.cfm?form.numinsp=#form.idavaliacao#&form.grpitem=#form.idgrupo#,#form.iditem#"> --->
			<cflocation url = "../ficha_facin_Ref.cfm?numinsp=#form.idavaliacao#&acao=buscar"> 
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
				SELECT distinct FFI_MatriculaInspetor, Fun_Nome
				FROM UN_Ficha_Facin INNER JOIN UN_Ficha_Facin_Individual ON (FAC_MatriculaGestor = FFI_MatriculaGestor) AND (FAC_Avaliacao = FFI_Avaliacao)
				INNER JOIN Funcionarios ON FFI_MatriculaInspetor = Fun_Matric
				GROUP BY FFI_Avaliacao, FFI_MatriculaInspetor, Fun_Nome, FAC_DtConcluirFacin_Gestor,FFI_DtConcluirFacin_Inspetor
				HAVING FFI_Avaliacao Like '%#ano#' AND FFI_Avaliacao Like '#codse#%' and FFI_DtConcluirFacin_Inspetor is not null and 
				FAC_DtConcluirFacin_Gestor between '#dtinic#' and '#dtfinal#'
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
				SELECT FFI_Avaliacao, Und_Descricao, FAC_DtConcluirFacin_Gestor, FFI_MatriculaInspetor
				FROM UN_Ficha_Facin 
				INNER JOIN Unidades ON FAC_Unidade = Und_Codigo
				INNER JOIN UN_Ficha_Facin_Individual ON (FAC_MatriculaGestor = FFI_MatriculaGestor) AND (FAC_Avaliacao = FFI_Avaliacao)
				WHERE FFI_MatriculaInspetor='#matr#' AND FFI_Avaliacao Like '#codse#%' AND FFI_Avaliacao Like '%#ano#' and FAC_DtConcluirFacin_Gestor between '#dtinic#' and '#dtfinal#'
				and FFI_DtConcluirFacin_Inspetor is not null
				ORDER BY Und_Descricao
            </cfquery>
            <cfreturn rsavalia>
        </cftransaction>
    </cffunction> 
	<cffunction name="finalizarfacin" access="remote" returntype="any" hint="Registrar a finalização da facin para o gestor/inspetor logado">
			<cfargument name="unid" required="true">
			<cfargument name="aval" required="true">
			<cfargument name="matrgestor" required="true">
			<cfargument name="matrinspetor" required="true">
			<cfargument name="grpacesso" required="true">		
			
			<cftry>
				<cfif grpacesso eq 'GESTORES'>
					<cfquery datasource="DBSNCI">
							update UN_Ficha_Facin set
								  FAC_DtConcluirFacin_Gestor = CONVERT(char, GETDATE(), 120)
								, FAC_DtAlter = CONVERT(char, GETDATE(), 120)
							WHERE FAC_Unidade='#unid#' AND 
							FAC_Avaliacao ='#aval#' AND 
							FAC_MatriculaGestor = '#matrgestor#'
					</cfquery> 
					<!--- Avisar aos inspetores da conclusão da FACIN --->
					<cfquery name="rsEnvio" datasource="DBSNCI">
						SELECT Fun_Nome,Fun_Email,Und_Descricao
						FROM Funcionarios INNER JOIN Inspetor_Inspecao ON Fun_Matric = IPT_MatricInspetor 
						INNER JOIN Unidades ON IPT_CodUnidade = Und_Codigo
						WHERE IPT_NumInspecao='#aval#'
					</cfquery>
					<cfset sdestina = ''>
					<cfloop query="rsEnvio">
						<cfset sdestina = #sdestina# & ';' & #rsEnvio.Fun_Email#>
					</cfloop>
					<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="FACIN - Concluída" type="HTML">
							Mensagem automática. Não precisa responder!<br><br>
							<strong>
							&nbsp;&nbsp;&nbsp;Comunicamos que o revisor concluiu a FACIN da avaliação: #aval# - #rsEnvio.Und_Descricao#<br><br>

							&nbsp;&nbsp;&nbsp;Assim, solicitamos registrar, as suas considerações no Sistema SNCI.<br><br>

							&nbsp;&nbsp;&nbsp;Para registro de suas considerações acesse o SNCI (endereço: http://intranetsistemaspe/snci/rotinas_inspecao.cfm) clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Sistema Nacional de Controle Interno - SNCI</a><br><br>
								<br>
							&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
							</strong>
					</cfmail>
					<!--- Fim -   Avisar aos inspetores da conclusão da FACIN --->					
					<cfset ret = 'Confirmar conclusão da FACIN - realizada com sucesso!'> 
				<cfelse>
					<cfquery datasource="DBSNCI">
						update UN_Ficha_Facin_Individual set
							FFI_DtConcluirFacin_Inspetor = CONVERT(char, GETDATE(), 120)
						   ,FFI_DtAlter = CONVERT(char, GETDATE(), 120)
						WHERE FFI_Avaliacao ='#aval#' AND 
						FFI_MatriculaGestor = '#matrgestor#' AND
						FFI_MatriculaInspetor = '#matrinspetor#'
					</cfquery> 
					<cfset ret = 'Conclusão das considerações (FACIN) - realizada com sucesso!'> 
				</cfif>					
				<cfcatch type="any">
					<cfset ret = 'Conclusão da FACIN - Falhou!'>  
				</cfcatch>
			</cftry>
			<cfreturn #ret#>
	</cffunction>	
	<!--- Este método inspetores por ano e cod_se --->
	<cffunction  name="gestao" access="remote" ReturnFormat="json" returntype="any">
		<cfargument name="ano" required="true">
		<cfargument name="dtinic" required="true">
		<cfargument name="dtfinal" required="true">
		<cfargument name="codse" required="true">
		<cfargument name="matrinsp" required="true">
		<cfargument name="aval" required="true">
		<cftransaction>
			<cfquery name="rsgestao" datasource="DBSNCI">
				SELECT FFI_Avaliacao,TUN_Descricao,FAC_Qtd_Avaliacao,FFI_Qtd_Item,FFI_Meta1_Pontuacao_Obtida,FFI_Meta1_Resultado,FFI_Meta2_Pontuacao_Obtida,FFI_Meta2_Resultado,FAC_Resultado_Meta3
				FROM (Unidades 
				INNER JOIN (UN_Ficha_Facin 
				INNER JOIN UN_Ficha_Facin_Individual ON (FAC_MatriculaGestor = FFI_MatriculaGestor) AND (FAC_Avaliacao = FFI_Avaliacao)) ON Und_Codigo = FAC_Unidade) 
				INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
				WHERE FFI_Avaliacao Like '%#ano#' and 
				FFI_Avaliacao Like '#codse#%' AND 
				FFI_MatriculaInspetor='#matrinsp#' and 
				FFI_DtConcluirFacin_Inspetor is not null and 
				FAC_DtConcluirFacin_Gestor between '#dtinic#' and '#dtfinal#'
				<cfif aval neq 't'>
					and FFI_Avaliacao='#aval#'
				</cfif>
				ORDER BY FFI_Avaliacao
			</cfquery>
			<cfreturn rsgestao>
		</cftransaction>
	</cffunction>  	  	
</cfcomponent>