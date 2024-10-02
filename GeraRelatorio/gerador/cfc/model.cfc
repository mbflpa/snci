<!------------------------------------------------------------------>
<!---@Nome: Componente de acesso ao banco para relet�rios ---------->
<!---@Descri��o: --->
<!---@Data: 07/07/2010 --------------------------------------------->
<!---@Autor: Sandro Mendes - GESIT/SSAD----------------------------->
<!------------------------------------------------------------------>

<cfcomponent>

	<!---@Nome:--->
	<!---@Descri��o:--->
	<!---@Par�metros:--->
	<!---@Data Modifica��o:--->
	<!---@Vers�o:--->
	<cffunction name="listaDadosRelatorio" access="public" returntype="query">

		<cfargument name="id" required="no" type="string" default="0">
		<cfargument name="dtini" required="no" type="string" default="">
		<cfargument name="dtfim" required="no" type="string" default="">
		<cfargument name="area" required="no" type="string" default="">
		<cfargument name="tipo" required="no" type="string" default="">
		<cfargument name="situacao" required="no" type="string" default="">
		<cfargument name="objetivo" required="no" type="string" default="0">

		<cfset var qryRelatorio = "">
		<cfset var numero = "3200972006">

	   <!---  <cfdump var="#arguments#">
		 <cfabort> --->

		<cftry> 
							
			      <cfquery name="qryRelatorio" timeout="120" datasource="#Application.DSN#">
					 SELECT Grupos_Verificacao.Grp_Descricao, Grupos_Verificacao.Grp_Codigo, Itens_Verificacao.Itn_Descricao,Itens_Verificacao.Itn_NumItem, Itens_Verificacao.Itn_Amostra,  Itens_Verificacao.Itn_Norma, Itens_Verificacao.Itn_ValidacaoObrigatoria,
					Itens_Verificacao.Itn_TipoUnidade,Itens_Verificacao.Itn_PTC_Seq,Itens_Verificacao.Itn_ImpactarTipos,Inspecao.INP_Coordenador, Inspecao.INP_DtEncerramento,Resultado_Inspecao.RIP_Comentario, Resultado_Inspecao.RIP_Recomendacoes, Resultado_Inspecao.RIP_Recomendacao, Resultado_Inspecao.RIP_Unidade,  Resultado_Inspecao.RIP_MatricAvaliador, Areas.Ars_Sigla,
					Tipo_Unidades.TUN_Codigo, Tipo_Unidades.TUN_Descricao, ParecerUnidade.Pos_Parecer, ParecerUnidade.Pos_PontuacaoPonto, ParecerUnidade.Pos_ClassificacaoPonto,Inspecao.INP_NumInspecao,
					Inspecao.INP_DtInicInspecao, Inspecao.INP_UserName, ParecerUnidade.Pos_Situacao_Resp, Inspecao.INP_DtFimInspecao, Unidades.Und_Descricao,
					Diretoria.Dir_Sigla, Funcionarios.Fun_Matric, Funcionarios.Fun_Nome, Resultado_Inspecao.RIP_Valor, Diretoria.Dir_Descricao, ITN_PONTUACAO, Itn_Classificacao 
					FROM ParecerUnidade INNER JOIN Resultado_Inspecao ON Pos_Unidade = RIP_Unidade AND Pos_Inspecao = RIP_NumInspecao AND Pos_NumGrupo = RIP_NumGrupo AND Pos_NumItem = RIP_NumItem 
					LEFT OUTER JOIN Analise ON Pos_Unidade = Ana_Unidade AND Pos_Inspecao = Ana_NumInspecao AND Pos_NumGrupo = Ana_NumGrupo AND Pos_NumItem = Ana_NumItem 
					INNER JOIN Itens_Verificacao 
					INNER JOIN Grupos_Verificacao ON Itn_NumGrupo = Grp_Codigo and Itn_Ano = Grp_Ano 
					ON RIP_NumGrupo = Itn_NumGrupo AND RIP_NumItem = Itn_NumItem and convert(char(4), Rip_Ano) = Itn_Ano
					INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao AND INP_Modalidade = Itn_Modalidade
					INNER JOIN Unidades ON INP_Unidade = Und_Codigo 
					INNER JOIN Diretoria ON RIP_CodDiretoria = Dir_Codigo 
					INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo and TUN_Codigo = Itn_TipoUnidade
					INNER JOIN Funcionarios ON INP_Coordenador = Fun_Matric AND INP_Coordenador = Fun_Matric 
					LEFT OUTER JOIN Areas ON Pos_Area = Areas.Ars_Codigo
					
					WHERE (0 = 0) 				
			  	      <cfif Arguments.ID Neq 0>
				         And Inspecao.INP_NumInspecao = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.ID#">
		              </cfif> 
                      <cfif Len(trim(Arguments.dtini)) Neq 0 and Len(trim(Arguments.dtfim)) Neq 0>
                         And Inspecao.INP_DtFimInspecao BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#ARGUMENTS.dtini#"> AND <cfqueryparam cfsqltype="cf_sql_date" value="#ARGUMENTS.dtfim#">
					  </cfif>
					  <cfif Len(trim(Arguments.tipo)) Neq 0>
				         AND Tipo_Unidades.TUN_Codigo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ARGUMENTS.tipo#">
			          </cfif>
				      <cfif Len(trim(Arguments.area)) Neq 0>
				         And ParecerUnidade.Pos_area = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.area#">
					  </cfif>
					  <cfif Len(trim(Arguments.situacao)) Neq 0>
				         And ParecerUnidade.Pos_Situacao_Resp = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.situacao#">
					  </cfif>
					  <cfif Arguments.objetivo Neq 0>
				         And Grupos_Verificacao.Grp_Codigo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.objetivo#">
					  </cfif>
				       ORDER BY Grupos_Verificacao.Grp_Codigo, Itens_Verificacao.Itn_NumItem, Unidades.Und_Descricao, Inspecao.INP_NumInspecao
			       </cfquery>
			<cfcatch>
				<cfset mensagem = 'Nao foi possivel efetuar a operacao. Erro: ' & cfcatch.Message>
			<!---<script>
					alert('<cfoutput>#mensagem#</cfoutput>');
					location.href = '../dsp/pagina.cfm';
				 </script>--->
				 <cfdump var="#cfcatch#">
			</cfcatch>
		</cftry>
	<cfreturn qryRelatorio>
	</cffunction>


	<cffunction name="listaDadospapeltrabalho" access="public" returntype="query">

		<cfargument name="id" required="no" type="string" default="0">
		<cfargument name="dtini" required="no" type="string" default="">
		<cfargument name="dtfim" required="no" type="string" default="">
		<cfargument name="area" required="no" type="string" default="">
		<cfargument name="tipo" required="no" type="string" default="">
		<cfargument name="situacao" required="no" type="string" default="">
		<cfargument name="objetivo" required="no" type="string" default="0">

		<cfset var qryPapelTrabalho = "">
		<!--- <cfset var numero = "3200972006"> --->

	   <!---  <cfdump var="#arguments#">
		 <cfabort> --->

		<cftry>

			      <cfquery name="qryPapelTrabalho" timeout="120" datasource="#Application.DSN#">					
						select Grupos_Verificacao.Grp_Descricao, Grupos_Verificacao.Grp_Codigo, Itens_Verificacao.Itn_Descricao, Itens_Verificacao.Itn_NumItem,Itens_Verificacao.Itn_ValorDeclarado,  Itens_Verificacao.Itn_Amostra,  Itens_Verificacao.Itn_Norma, Itens_Verificacao.Itn_ValidacaoObrigatoria, Itens_Verificacao.Itn_Pontuacao, Itens_Verificacao.Itn_Classificacao, Itens_Verificacao.Itn_PTC_Seq,Itens_Verificacao.Itn_ImpactarTipos,Itens_Verificacao.Itn_TipoUnidade, Inspecao.INP_Coordenador, Inspecao.INP_UserName,  Inspecao.INP_DtUltAtu, Resultado_Inspecao.RIP_Comentario, Resultado_Inspecao.RIP_Recomendacoes, Resultado_Inspecao.RIP_Recomendacao, Resultado_Inspecao.RIP_Resposta, Resultado_Inspecao.RIP_Unidade, Resultado_Inspecao.RIP_MatricAvaliador,
						Tipo_Unidades.TUN_Codigo, Tipo_Unidades.TUN_Descricao, Inspecao.INP_NumInspecao, Inspecao.INP_DtInicInspecao, Inspecao.INP_DtFimInspecao, Inspecao.INP_Modalidade, Inspecao.INP_DTConcluirAvaliacao,Inspecao.INP_DTConcluirRevisao,Inspecao.INP_DtEncerramento, Unidades.Und_Descricao, Diretoria.Dir_Sigla, Funcionarios.Fun_Matric, Funcionarios.Fun_Nome, Resultado_Inspecao.RIP_Valor,  Resultado_Inspecao.RIP_Falta, Resultado_Inspecao.RIP_Sobra, Resultado_Inspecao.RIP_EmRisco, Resultado_Inspecao.RIP_ReincInspecao, Resultado_Inspecao.RIP_ReincGrupo, Resultado_Inspecao.RIP_ReincItem, Diretoria.Dir_Descricao, ParecerUnidade.Pos_PontuacaoPonto, ParecerUnidade.Pos_ClassificacaoPonto, TNC_ClassifInicio, TNC_ClassifAtual
						FROM (Diretoria INNER JOIN (Tipo_Unidades INNER JOIN ((((((Inspecao INNER JOIN Resultado_Inspecao ON (Inspecao.INP_NumInspecao = Resultado_Inspecao.RIP_NumInspecao) AND (Inspecao.INP_Unidade = Resultado_Inspecao.RIP_Unidade)) LEFT JOIN Analise ON (Resultado_Inspecao.RIP_NumItem = Analise.Ana_NumItem) AND (Resultado_Inspecao.RIP_NumGrupo = Analise.Ana_NumGrupo) AND (Resultado_Inspecao.RIP_NumInspecao = Analise.Ana_NumInspecao) AND (Resultado_Inspecao.RIP_Unidade = Analise.Ana_Unidade)) LEFT JOIN ParecerUnidade ON (Resultado_Inspecao.RIP_NumItem = ParecerUnidade.Pos_NumItem) AND (Resultado_Inspecao.RIP_NumGrupo = ParecerUnidade.Pos_NumGrupo) AND (Resultado_Inspecao.RIP_NumInspecao = ParecerUnidade.Pos_Inspecao) AND (Resultado_Inspecao.RIP_Unidade = ParecerUnidade.Pos_Unidade)) 
						INNER JOIN Unidades ON Resultado_Inspecao.RIP_Unidade = Unidades.Und_Codigo) INNER JOIN Itens_Verificacao ON (Inspecao.INP_Modalidade = Itens_Verificacao.Itn_Modalidade) AND (Resultado_Inspecao.RIP_NumItem = Itens_Verificacao.Itn_NumItem) and convert(char(4),RIP_Ano) = Itn_Ano AND (Resultado_Inspecao.RIP_NumGrupo = Itens_Verificacao.Itn_NumGrupo) AND (Unidades.Und_TipoUnidade = Itens_Verificacao.Itn_TipoUnidade)) INNER JOIN Grupos_Verificacao ON (Itens_Verificacao.Itn_Ano = Grupos_Verificacao.Grp_Ano) AND (Itens_Verificacao.Itn_NumGrupo = Grupos_Verificacao.Grp_Codigo)) ON Tipo_Unidades.TUN_Codigo = Itens_Verificacao.Itn_TipoUnidade) ON Diretoria.Dir_Codigo = Resultado_Inspecao.RIP_CodDiretoria) INNER JOIN Funcionarios ON Inspecao.INP_Coordenador = Funcionarios.Fun_Matric
						left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade)

					where Itens_Verificacao.Itn_Situacao <> 'X' and RIP_Resposta <> 'A'
		              <cfif Arguments.id Neq 0>
				       and Inspecao.INP_NumInspecao = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.id#">
		              </cfif>
                       <cfif Len(trim(Arguments.dtini)) Neq 0 and Len(trim(Arguments.dtfim)) Neq 0>
                         And Inspecao.INP_DtFimInspecao BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#ARGUMENTS.dtini#"> AND <cfqueryparam cfsqltype="cf_sql_date" value="#ARGUMENTS.dtfim#">
					  </cfif>
					  <cfif Len(trim(Arguments.tipo)) Neq 0>
				         AND Tipo_Unidades.TUN_Codigo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ARGUMENTS.tipo#">
			          </cfif>
					  <cfif Arguments.objetivo Neq 0>
				         And Grupos_Verificacao.Grp_Codigo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.objetivo#">
					  </cfif>
				       ORDER BY Grupos_Verificacao.Grp_Codigo, Itens_Verificacao.Itn_NumItem, Unidades.Und_Descricao, Inspecao.INP_NumInspecao
			       </cfquery>
			<cfcatch>
				<cfset mensagem = 'Nao foi possivel efetuar a operacao. Erro: ' & cfcatch.Message>
			<!---<script>
					alert('<cfoutput>#mensagem#</cfoutput>');
					location.href = '../dsp/pagina.cfm';
				 </script>--->
				 <cfdump var="#cfcatch#">
			</cfcatch>
		</cftry>
	<cfreturn qryPapelTrabalho>
	</cffunction>



   <cffunction name="listaDadosInspetor" access="public" returntype="query">

	 <cfargument name="id" required="no" type="string" default="0">
	 <cfargument name="dtini" required="no" type="string" default="">
	 <cfargument name="dtfim" required="no" type="string" default="">
	 <cfargument name="area" required="no" type="string" default="">
	 <cfargument name="tipo" required="no" type="string" default="">

	  <cfset var qryInspetor = ''>

	    <!--- <cfdump var="#arguments#">
		<cfabort> --->

	<cftry>

	  <cfquery name="qryInspetor" timeout="120" datasource="#Application.DSN#">
	    SELECT distinct Inspetor_Inspecao.IPT_MatricInspetor, Funcionarios.Fun_Nome, Inspecao.INP_NumInspecao
        FROM Areas RIGHT OUTER JOIN Inspetor_Inspecao INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric AND Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
		INNER JOIN Inspecao ON Inspetor_Inspecao.IPT_NumInspecao = Inspecao.INP_NumInspecao AND Inspetor_Inspecao.IPT_CodUnidade = Inspecao.INP_Unidade
		INNER JOIN ParecerUnidade ON Inspecao.INP_NumInspecao = ParecerUnidade.Pos_Inspecao AND Inspecao.INP_Unidade = ParecerUnidade.Pos_Unidade ON Areas.Ars_Codigo = ParecerUnidade.Pos_Area
		INNER JOIN Unidades ON ParecerUnidade.Pos_Unidade = Unidades.Und_Codigo INNER JOIN Tipo_Unidades ON Unidades.Und_TipoUnidade = Tipo_Unidades.TUN_Codigo
        WHERE  0 = 0
		<cfif Arguments.ID Neq 0>
          And Inspecao.INP_NumInspecao = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.ID#">
		</cfif>
        <cfif Len(trim(Arguments.dtini)) Neq 0 and Len(trim(Arguments.dtfim)) Neq 0>
          And Inspecao.INP_DtFimInspecao BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#ARGUMENTS.dtini#"> AND <cfqueryparam cfsqltype="cf_sql_date" value="#ARGUMENTS.dtfim#">
	    </cfif>
	    <cfif Len(trim(Arguments.tipo)) Neq 0>
	      And Tipo_Unidades.TUN_Codigo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ARGUMENTS.tipo#">
		</cfif>
		 <cfif Len(trim(Arguments.area)) Neq 0>
		  And ParecerUnidade.Pos_area = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.area#">
		</cfif>
	   </cfquery>
	    <cfcatch>
	      <cfdump var="#cfcatch#">
	    </cfcatch>
	</cftry>
	<cfreturn qryInspetor>
  </cffunction>

  <cffunction name="listaAnexos" access="public" returntype="query">

	 <cfargument name="id" required="no" type="string" default="0">
	 <cfargument name="grupo" required="no" type="string" default="0">
	 <cfargument name="item" required="no" type="string" default="0">

	  <cfset var qryAnexos = ''>

	<cftry>
	  <cfquery name="qryAnexos" timeout="120" datasource="#Application.DSN#">
	     SELECT DISTINCT Ane_Caminho, Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo
         FROM Anexos
         WHERE (0 = 0) And Ane_NumInspecao = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
		 AND (Ane_NumGrupo = <cfqueryparam cfsqltype="cf_sql_numeric" value="#grupo#">)
		 AND (Ane_NumItem = <cfqueryparam cfsqltype="cf_sql_numeric" value="#item#">)
		 order by Ane_Codigo
	  </cfquery>
	    <cfcatch>
	      <cfdump var="#cfcatch#">
	    </cfcatch>
	</cftry>
	<cfreturn qryAnexos>
  </cffunction>
  <cffunction name="listainspetor" access="public" returntype="query">
	<cfargument name="dtini" required="no" type="string">
	<cfargument name="dtfim" required="no" type="string">

	   <cfset var qryInspetores = ''>

	   <!--- <cfdump var="#dtini#">
       <cfabort> --->

	<cftry>
	  <cfquery name="qryInspetores" timeout="120" datasource="#Application.DSN#">
	     SELECT DISTINCT Inspetor_Inspecao.IPT_MatricInspetor, Funcionarios.Fun_Nome
         FROM Inspetor_Inspecao INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
         AND  Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric INNER JOIN Inspecao ON Inspetor_Inspecao.IPT_CodUnidade = Inspecao.INP_Unidade AND
         Inspetor_Inspecao.IPT_NumInspecao = Inspecao.INP_NumInspecao
         WHERE (0 = 0) AND Inspecao.INP_DtFimInspecao BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#dtini#">
		 AND <cfqueryparam cfsqltype="cf_sql_date" value="#dtfim#">
	  </cfquery>
	    <cfcatch>
	      <cfdump var="#cfcatch#">
	    </cfcatch>
	</cftry>
	<cfreturn qryInspetores>
  </cffunction>
  <cffunction name="listacoordenador" access="public" returntype="query">
	<cfargument name="dtini" required="no" type="string">
	<cfargument name="dtfim" required="no" type="string">

	   <cfset var qryCoordenadores = ''>
	   <!--- <cfdump var="#dtini#">
       <cfabort>  --->

	<cftry>
	  <cfquery name="qryCoordenadores" timeout="120" datasource="#Application.DSN#">
	     SELECT DISTINCT Funcionarios.Fun_Nome, Inspecao.INP_Coordenador
         FROM Funcionarios INNER JOIN Inspecao ON Funcionarios.Fun_Matric = Inspecao.INP_Coordenador
         WHERE (0 = 0) AND Inspecao.INP_DtFimInspecao BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#dtini#">
		 AND <cfqueryparam cfsqltype="cf_sql_date" value="#dtfim#">
	  </cfquery>
	    <cfcatch>
	      <cfdump var="#cfcatch#">
	    </cfcatch>
	</cftry>
	<cfreturn qryCoordenadores>
  </cffunction>
</cfcomponent>
