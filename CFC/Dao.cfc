<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">
<cfset dsn = 'DBSNCI'>
<cfquery name="qUsuarioLogado"  datasource="#dsn#">
	 SELECT Usu_Login as Login
            ,Usu_GrupoAcesso as GrupoAcesso
            ,Usu_Apelido as NomeUsuario
            ,Usu_LotacaoNome as NomeLotacao
            ,Usu_Matricula as Matricula
            ,Usu_Username as UserName
            ,Usu_DtUltAtu as DataUltimaAtualizacao
            ,Usu_DR as SE
            ,Usu_Lotacao as CodigoLotacao
            ,Usu_Email as Email
    FROM Usuarios 
    WHERE Usu_Login = '#CGI.REMOTE_USER#'
  </cfquery>

<!--Gera nova data prevista para solu��o pelo �rg�o	(Dez dias corridos p�s Insert do parecer)-->
<cffunction	 name="dataNovoPrazo" returntype="date" hint="Gera nova data prevista para solução pelo órgão (Dez dias corridos)">
  
   <cfset dtatual = CreateDate(year(now()),month(now()),day(now()))>
                <cfset dtnovoprazo = DateAdd("d", 10, #dtatual#)>
   <cfset nCont = 1>
   <cfloop condition="nCont lt 2">
          <cfif nCont eq 1>
            <cfquery name="rsFeriado" datasource="#dsn#">
               SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtnovoprazo#
            </cfquery>
                <cfif rsFeriado.recordcount gt 0>
                         <cfset dtnovoprazo = DateAdd( "d", 1, dtnovoprazo)>
                         <cfset nCont = 1>
                <cfelse>
                         <cfset nCont = 2>
                </cfif>
             </cfif>

             <cfset vDiaSem = DayOfWeek(dtnovoprazo)>
             <cfswitch expression="#vDiaSem#">
             <cfcase value="1">
                  <!--- domingo --->
                  <cfset dtnovoprazo = DateAdd("d", 1, dtnovoprazo)>
                          <cfset nCont = 1>
               </cfcase>
               <cfcase value="7">
                   <!--- s�bado --->
                   <cfset dtnovoprazo = DateAdd("d", 2, dtnovoprazo)>
                   <cfset nCont = 1>
               </cfcase>
               <cfdefaultcase>
                   <cfset nCont = 2>
               </cfdefaultcase>
             </cfswitch>
     </cfloop>
  <!--- fim loop --->
	<cfset result = '#dtnovoprazo#' />
  <cfreturn result />
</cffunction>
	
<!---Retorna rsUsuarioLogado--->
<cffunction name="rsUsuarioLogado" returntype="query">
  <cfset result = "#qUsuarioLogado#" />
  <cfreturn result />
</cffunction>
	
<!---Retorna rsUnidade, se nenhum par�metro for informado, retorna todos os dados--->
<cffunction name="rsUnidadesSEusuario" returntype="query">
  <cfargument name="CodigoDaUnidade" type="string" required="false"  default="all">	  
  <cfquery name="qUnidades" datasource="#dsn#">
	 SELECT Und_Codigo as CodigoUnidade
            ,Und_Descricao as Descricao
            ,Und_CodReop as OrgaoSubordinador
            ,Und_CodDiretoria as SE
            ,Und_Classificacao as Classificacao
            ,Und_CatOperacional as CategoriaOperacional
            ,Und_TipoUnidade as TipoUnidade
            ,Und_Cgc as CNPJ
            ,Und_NomeGerente as NomeGestor
            ,Und_Sigla as Sigla
            ,Und_Status as Status
            ,Und_Endereco as Endereco
            ,Und_Cidade as Cidade
            ,Und_UF as UF
            ,Und_DtUltAtu as DataUltimaAtualizacao
            ,Und_Email as Email
            ,Und_Centraliza as OrgaoCentralizador
            ,Und_Username as UserName
	  FROM Unidades WHERE Und_CodDiretoria = '#qUsuarioLogado.SE#' AND Und_Codigo LIKE 
	        <cfif #CodigoDaUnidade# neq "all">
		        <cfqueryparam  value='#CodigoDaUnidade#' CFSQLType="CF_SQL_VARCHAR" MAXLENGTH="8">
	       <cfelse>
		        <cfqueryparam  value='%' CFSQLType="CF_SQL_VARCHAR">
	        </cfif> 
   </cfquery>
  <cfset result = qUnidades />
  <cfreturn result />
</cffunction>
  
<!---Gera um Insert na rsAndamento--->
<cffunction name="insertAndamento" hint="Rorina de Insert na tabela Andamento" >
	 
    <cfargument name="NumeroDaInspecao" type="string" required="true"   />
    <cfargument name="CodigoDaUnidade" type="string" required="true"  />
    <cfargument name="Grupo" type="string" required="true"  />
    <cfargument name="Item" type="string" required="true"  />
    <cfargument name="CodigoDaSituacaoDoPonto" type="string" required="true"  />  
    <cfargument name="CodigoUnidadeDaPosicao" type="string" required="true"  />
    <cfargument name="Parecer" type="string" required="true"   />     
   <cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
   <cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
   <cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>
    <cfquery datasource="#dsn#">

        INSERT INTO Andamento (
		         And_NumInspecao
                ,And_Unidade
                ,And_NumGrupo
                ,And_NumItem
                ,And_DtPosic
                ,And_username
                ,And_Situacao_Resp
                ,And_HrPosic
                ,And_Area
		        ,And_Parecer
        )
        VALUES
        (     <cfqueryparam cfsqltype="CF_SQL_CHAR" maxlength="10" value="#trim(arguments.NumeroDaInspecao)#">,
              <cfqueryparam cfsqltype="CF_SQL_CHAR" maxlength="8"  value="#trim(arguments.CodigoDaUnidade)#">,	
              <cfqueryparam cfsqltype="CF_SQL_INTEGER" maxlength="10" value="#trim(arguments.Grupo)#">,
              <cfqueryparam cfsqltype="CF_SQL_INTEGER" maxlength="10" value="#trim(arguments.Item)#">,	
              convert(char, getdate(), 102),
              '#qUsuarioLogado.Login#',
              <cfqueryparam cfsqltype="CF_SQL_INTEGER" maxlength="10" value="#trim(arguments.CodigoDaSituacaoDoPonto)#">,
              '#hhmmssdc#',
              <cfqueryparam cfsqltype="CF_SQL_CHAR" maxlength="8" value="#trim(arguments.CodigoUnidadeDaPosicao)#" >,
			  <cfqueryparam cfsqltype="CF_SQL_LONGVARCHAR"  value="#trim(arguments.Parecer)#" >
        ) 
    </cfquery>
</cffunction>


<!---Retorna yes se o prazo estipulado for extrapolado n�o considerando os dias �teis e feriados--->
<cffunction name="VencidoPrazo_Andamento" hint="Retorna a quantidade de dias dos status listados no argumento ListaDeStatusContabilizados ou retorna yes ou no se o prazo venceu" >
   <cfargument name="NumeroDaInspecao" type="string" required="true"   />
   <cfargument name="CodigoDaUnidade" type="string" required="true"  />
   <cfargument name="Grupo" type="string" required="true"  />
   <cfargument name="Item" type="string" required="true"  />
  <cfargument name="MostraDump" type="string"  default="no" /><!---yes ou no ou n�o informar--->
  <cfargument name="Prazo" type="numeric" default="30"/><!---em dias. Se n�o informado, considera 30 dias--->
  <cfargument name="RetornaQuantDias" type="string"  default="no" />
  <cfargument name="ListaDeStatusContabilizados" type="any" required="true"/><!---deve ser uma lista delimitada por v�rgulas. Ex.: 17,18--->
  <cfargument name="ApenasDiasUteis" type="string"  default="no" />

  
   <cfif isSimpleValue(arguments.ListaDeStatusContabilizados)>
       <cfset arguments.ListaDeStatusContabilizados = listToArray(arguments.ListaDeStatusContabilizados)>
   <cfelseif NOT isArray(arguments.ListaDeStatusContabilizados)>
       <cfthrow type="java.lang.IllegalArgumentException"
           message="O argumento 'ListaDeStatusContabilizados' deve ser uma lista delimitada por vírgulas. Ex.: 17,18">
   </cfif>
 
   <cfset listContabilizados = ArrayToList('#arguments.ListaDeStatusContabilizados#') />	  
  <cfquery name = rsDias_Andamento datasource="#dsn#">
     SELECT T1.And_Situacao_Resp, T1.And_DtPosic,  T1.And_HrPosic,  COALESCE(DateDiff(d, T1.And_DtPosic, T2.And_DtPosic),DateDiff(d, T1.And_DtPosic,GETDATE())) as qtddias, CASE WHEN T1.And_Situacao_Resp IN (#listContabilizados#) THEN 'SIM' ELSE 'n' END AS Contabilizar, T2.And_DtPosic AS And_DtPosic2
     
     FROM (Select *, ROW_NUMBER() OVER(ORDER BY And_DtPosic, And_HrPosic ASC) AS Linha
                  From Andamento  WHERE 
            And_Unidade =     <cfqueryparam cfsqltype="CF_SQL_CHAR" maxlength="8"  value="#trim(arguments.CodigoDaUnidade)#"> AND 
            And_NumInspecao = <cfqueryparam cfsqltype="CF_SQL_CHAR" maxlength="10" value="#trim(arguments.NumeroDaInspecao)#"> AND 
            And_NumGrupo =    <cfqueryparam cfsqltype="CF_SQL_INTEGER" maxlength="10" value="#trim(arguments.Grupo)#"> AND 
            And_NumItem =     <cfqueryparam cfsqltype="CF_SQL_INTEGER" maxlength="10" value="#trim(arguments.Item)#">) T1 LEFT JOIN
                (Select *, ROW_NUMBER() OVER(ORDER BY And_DtPosic, And_HrPosic ASC) AS Linha
                  From Andamento  WHERE 
            And_Unidade =     <cfqueryparam cfsqltype="CF_SQL_CHAR" maxlength="8"  value="#trim(arguments.CodigoDaUnidade)#"> AND 
            And_NumInspecao = <cfqueryparam cfsqltype="CF_SQL_CHAR" maxlength="10" value="#trim(arguments.NumeroDaInspecao)#"> AND 
            And_NumGrupo =    <cfqueryparam cfsqltype="CF_SQL_INTEGER" maxlength="10" value="#trim(arguments.Grupo)#"> AND 
            And_NumItem =     <cfqueryparam cfsqltype="CF_SQL_INTEGER" maxlength="10" value="#trim(arguments.Item)#">) T2
      ON (T1.Linha = T2.Linha - 1)
 </cfquery>

<!---Totatiliza os dias dos status informados no argumento ListaDeStatusContabilizados--->	 
<cfquery dbtype="query" name="qDiasStatusContabilizado">
      SELECT SUM(qtddias) as total
      FROM rsDias_Andamento	
      WHERE And_Situacao_Resp in (#listContabilizados#) 	
</cfquery> 

<cfquery dbtype="query" name="qDiasUteis">
   SELECT And_DtPosic, And_DtPosic2, qtddias
   FROM rsDias_Andamento	
   WHERE And_Situacao_Resp in (#listContabilizados#) 	
</cfquery>
<cfset qDiasNaoUteis = 0>
<cfset qDiasDoPrazo = 0> 
<cfif "#trim(arguments.ApenasDiasUteis)#" eq 'yes' >
   
   <cfif '#qDiasStatusContabilizado.recordcount#' neq 0>

      <cfloop query="qDiasUteis">

         <cfset auxposic = CreateDate(year('#And_DtPosic#'),month('#And_DtPosic#'),day('#And_DtPosic#'))>
		 <cfset auxdtnova = auxposic>
         <cfset DIAS ='#qtddias#' + 1> 
		 <cfset auxDTFim = DateAdd("d", #DIAS#, #auxposic#)>
         <!--- <cfset dtatual = auxposic>  --->
         <cfset nCont = 1>
         <cfset dsusp = 0>
		 <cfset DD_SD_Existe = 0>
         
		<!--- Obter sabados e domingos entre auxdtnova e  DIAS  --->
		<cfloop condition="nCont lte DIAS">
               <cfset vDiaSem = DayOfWeek(auxdtnova)>
               <cfswitch expression="#vDiaSem#">
                  <cfcase value="1">
                     <cfset dsusp = dsusp + 1>
                  </cfcase>
                  <cfcase value="7">
                     <cfset dsusp = dsusp + 1>
                  </cfcase>
               </cfswitch>
			<cfset auxdtnova = DateAdd("d", 1, #auxdtnova#)>
            <cfset nCont = nCont + 1>
         </cfloop>
		<!---  --->
		<!--- obter qtd de sabados/domingos nos feriados nacionais entre auxposic e auxDTFim --->
		 <cfquery name="rsFeriado" datasource="#dsn#">
               SELECT Fer_Data FROM FeriadoNacional where Fer_Data between #auxposic# and #auxDTFim#
         </cfquery>
		 
		 <cfif rsFeriado.recordcount gt 0>
		       <cfset DD_SD_Existe = rsFeriado.recordcount>
			   <cfloop query="rsFeriado">
				   <cfset vDiaSem = DayOfWeek(rsFeriado.Fer_Data)>
				   <cfswitch expression="#vDiaSem#">
					  <cfcase value="1">
						 <cfset DD_SD_Existe = DD_SD_Existe - 1>
					  </cfcase>
					  <cfcase value="7">
						 <cfset DD_SD_Existe = DD_SD_Existe - 1>
					  </cfcase>
				   </cfswitch>
			   </cfloop>
		 </cfif>
		<!---  --->
         <cfset qDiasNaoUteis = qDiasNaoUteis + dsusp + DD_SD_Existe>
       
      </cfloop>
   
      <cfset qDiasDoPrazo = qDiasStatusContabilizado.total - qDiasNaoUteis > 
   <cfelse>
      <cfset qDiasDoPrazo = 0>
   </cfif>
<cfelse>
   <cfset qDiasDoPrazo = qDiasStatusContabilizado.total> 

</cfif>



<cfset result = 'no' />



<cfif "#trim(arguments.RetornaQuantDias)#" eq 'yes'>
     <cfset result = '#qDiasDoPrazo#' />
<cfelse>	
   <!---verifica se a quantidade de dias contabilizados � maior que o prazo estipulado --->
     <cfif  qDiasDoPrazo gt Prazo >
          <cfset result = 'yes' /><!---prazo vencido--->	
     </cfif>
</cfif>
    
<cfif "#trim(arguments.MostraDump)#" eq 'yes'>
   <!---Teste--->  
    
     <cfdump var= '#rsDias_Andamento#'/>
     <cfdump var= '#qDiasUteis#'/><!---para teste--->
     <cfdump var= 'Quant. dias não úteis para reduzir: #qDiasNaoUteis# dias'   />  <!---para teste--->

    <br>
   <cfdump var= 'Prazo: #arguments.Prazo# dias'/>
     <br>
     <cfdump var= 'Total de dias contabilizado: #qDiasDoPrazo#'/>
   <br>
   <cfif "#trim(arguments.RetornaQuantDias)#" eq 'yes'>
         <cfdump var= 'retorno: #result# (dias)' />
   <cfelse>
      <cfif #result# eq 'no' >
            <cfdump var= 'retorno: #result# (prazo não vencido)' />
      <cfelse>
          <cfdump var= 'retorno: #result# (prazo vencido)' />
      </cfif>
   </cfif>	
     <!---Fim teste--->	
   
</cfif>	 
 
<cfreturn result />  

</cffunction>


<!---Gera nova data prevista para solu��o pelo �rg�o--->
<cffunction	 name="DataPrevistaSolucao" returntype="struct" hint="Gera nova data prevista para solução pelo órgão.">
   <cfargument name="Prazo" type="numeric" required="yes"/>
   <cfargument name="MostraDump" type="string"  default="no" /><!---yes ou no ou nao informar--->
	
   <cfset dtatual = CreateDate(year(now()),month(now()),day(now()))>
   <cfset dtnovoprazo = DateAdd("d", '#Prazo#', #dtatual#)>
   <cfset nCont = 1>
   <cfset nDiasSomar = 0>
   <cfloop condition="nCont lt Prazo">
      <cfquery name="rsFeriado" datasource="#dsn#">
         SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtnovoprazo#
      </cfquery>
      <cfif rsFeriado.recordcount gt 0>
              <cfset nDiasSomar = nDiasSomar + 1>
      <cfelse>
              <cfset vDiaSem = DayOfWeek(dtnovoprazo)>
              <cfswitch expression="#vDiaSem#">
                       <cfcase value="1">
                            <!--- domingo --->
                            <cfset nDiasSomar = nDiasSomar + 1>
                       </cfcase>
                        <cfcase value="7">
                            <!--- s�bado --->
                            <cfset nDiasSomar = nDiasSomar + 1>
                        </cfcase>
               </cfswitch>
      </cfif>
       <!--- <cfset dtnovoprazo = DateAdd("d", #nCont#, #dtatual#)> --->
	   <cfset dtnovoprazo = DateAdd("d", 1, #dtatual#)>
       <cfset nCont = nCont + 1>
       
       <cfif '#nCont#' eq '#Prazo#'>
            <cfset Prazo2 = Prazo + nDiasSomar>
            <cfset dtnovoprazo2 = DateAdd("d", #Prazo2#, #dtatual#)>
            <cfquery name="rsFeriado" datasource="#dsn#">
              SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtnovoprazo2#
            </cfquery>
            <cfset vDiaSem = DayOfWeek(dtnovoprazo2)>
           
            <cfif vDiaSem eq 1 || vDiaSem eq 7 || rsFeriado.recordcount neq 0>
               <cfset Prazo =Prazo + 1>
               <cfset nDiasSomar = nDiasSomar + 1>
            </cfif>
       </cfif>

   </cfloop>
<!--- fim loop --->
      <cfset Prazo = Prazo + nDiasSomar>
      <cfset dtnovoprazo = DateAdd("d", #Prazo#, #dtatual#)>

	<cfset novaData = StructNew()/>
	<cfset novaData.Data_Prevista =  CreateDate(Year(#dtnovoprazo#),Month(#dtnovoprazo#),Day(#dtnovoprazo#))/>		   
	<cfset novaData.Data_Prevista_Formatada = DateFormat(#dtnovoprazo#,"DD/MM/YYYY")/>   
				   
	<cfset result = '#novaData#' />
	<cfif "#trim(arguments.MostraDump)#" eq 'yes'>
	  <cfdump var= '#result#' />
    </cfif> 			   
				   
				   
  <cfreturn result />
</cffunction>
		
<!---Retorna um Struct com os dados do �rg�o subordinador, da �rea e do centralizador da unidade--->	
<cffunction name="DadosUnidade" hint="Retorna dados do órgão subordinador, da área e do centralizador da unidade."  returntype="struct">
  <cfargument name="CodigoDaUnidade" type="string" required="true"  />
  <cfargument name="MostraDump" type="string"  default="no" /><!---yes ou no ou nao informar--->
	
  <cfquery datasource="#dsn#" name="rsDadosUnidade">
     SELECT  Unidades.Und_Codigo AS Und_Unidade_Codigo,  Unidades.Und_CodDiretoria AS Und_Codigo_SE, Unidades.Und_Descricao AS Und_Unidade_Descricao, Unidades.Und_TipoUnidade AS Und_TipoUnidade, Unidades.Und_CatOperacional AS Und_CatOperacional, Unidades.Und_Email,   Reops.Rep_Codigo AS Und_OrgSub_Codigo,Reops.Rep_Nome AS Und_OrgSub_Descricao,  Reops.Rep_Sigla AS Und_OrgSub_Sigla, Reops.Rep_Email, Areas.Ars_Codigo AS Und_Area_Codigo,  Areas.Ars_Descricao AS Und_Area_Descricao, Areas.Ars_Sigla AS Und_Area_Sigla, Unidades.Und_Centraliza AS Und_Centra_Codigo, Areas.Ars_Email
     FROM  Unidades INNER JOIN  Reops ON  Unidades.Und_CodReop =  Reops.Rep_Codigo 
	                INNER JOIN  Areas ON  Reops.Rep_CodArea =  Areas.Ars_Codigo
	 WHERE  Unidades.Und_Codigo = <cfqueryparam cfsqltype="CF_SQL_CHAR" maxlength="8"  value="#trim(arguments.CodigoDaUnidade)#">
  </cfquery>

  <cfset dados=StructNew()>	  
  <cfset dados.Und_Unidade_Codigo='#rsDadosUnidade.Und_Unidade_Codigo#'>	  
  <cfset dados.Und_Unidade_Descricao='#rsDadosUnidade.Und_Unidade_Descricao#'>
  <cfset dados.Und_TipoUnidade='#rsDadosUnidade.Und_TipoUnidade#'>
  <cfset dados.Und_CatOperacional='#rsDadosUnidade.Und_CatOperacional#'>  
  <cfset dados.Und_Codigo_SE='#rsDadosUnidade.Und_Codigo_SE#'>
  <cfset dados.Und_Email='#rsDadosUnidade.Und_Email#'> 
  <cfset dados.Und_OrgSub_Codigo='#rsDadosUnidade.Und_OrgSub_Codigo#'>  
  <cfset dados.Und_OrgSub_Descricao='#rsDadosUnidade.Und_OrgSub_Descricao#'> 
  <cfset dados.Und_OrgSub_Sigla='#rsDadosUnidade.Und_OrgSub_Sigla#'> 
  <cfset dados.Und_OrgSub_Email='#rsDadosUnidade.Rep_Email#'>  
  <cfset dados.Und_Area_Codigo='#rsDadosUnidade.Und_Area_Codigo#'> 
  <cfset dados.Und_Area_Descricao='#rsDadosUnidade.Und_Area_Descricao#'> 
  <cfset dados.Und_Area_Sigla='#rsDadosUnidade.Und_Area_Sigla#'> 
  <cfset dados.Und_Area_Email='#rsDadosUnidade.Ars_Email#'>   
	  
  <cfif rsDadosUnidade.Und_Centra_Codigo neq ''>
        <cfquery datasource="#dsn#" name="rsDadosCentralizador">
            SELECT    Unidades.Und_Codigo AS Centra_Unidade_Codigo,  Unidades.Und_CodDiretoria AS Centra_Codigo_SE, Unidades.Und_Descricao AS Centra_Unidade_Descricao, Unidades.Und_Email, Reops.Rep_Codigo AS Centra_OrgSub_Codigo, Reops.Rep_Nome AS Centra_OrgSub_Descricao,  Reops.Rep_Sigla AS Centra_OrgSub_Sigla,  Areas.Ars_Codigo AS Centra_Area_Codigo,  Areas.Ars_Descricao AS Centra_Area_Descricao, Areas.Ars_Sigla AS Centra_Area_Sigla, Reops.Rep_Email, Areas.Ars_Email 
			FROM  Unidades INNER JOIN  Reops ON  Unidades.Und_CodReop =  Reops.Rep_Codigo INNER JOIN  Areas ON  Reops.Rep_CodArea =               Areas.Ars_Codigo 
            WHERE  Unidades.Und_Codigo = '#rsDadosUnidade.Und_Centra_Codigo#'
        </cfquery>
  <cfset dados.Centra_Unidade_Codigo='#rsDadosCentralizador.Centra_Unidade_Codigo#'>	  
  <cfset dados.Centra_Unidade_Descricao='#rsDadosCentralizador.Centra_Unidade_Descricao#'>
  <cfset dados.Centra_Email='#rsDadosCentralizador.Und_Email#'>   
  <cfset dados.Centra_OrgSub_Codigo='#rsDadosCentralizador.Centra_OrgSub_Codigo#'>  
  <cfset dados.Centra_OrgSub_Descricao='#rsDadosCentralizador.Centra_OrgSub_Descricao#'> 
  <cfset dados.Centra_OrgSub_Sigla='#rsDadosCentralizador.Centra_OrgSub_Sigla#'>
  <cfset dados.Centra_OrgSub_Email='#rsDadosCentralizador.Rep_Email#'>  
  <cfset dados.Centra_Area_Codigo='#rsDadosCentralizador.Centra_Area_Codigo#'> 
  <cfset dados.Centra_Area_Descricao='#rsDadosCentralizador.Centra_Area_Descricao#'> 
  <cfset dados.Centra_Area_Sigla='#rsDadosCentralizador.Centra_Area_Sigla#'>
  <cfset dados.Centra_Area_Email='#rsDadosCentralizador.Ars_Email#'>      
<cfelse>  
  <cfset dados.Centra_Unidade_Codigo='Não Centralizada'>	  
  <cfset dados.Centra_Unidade_Descricao='Não Centralizada'>
  <cfset dados.Centra_Email='Não Centralizada'> 
  <cfset dados.Centra_OrgSub_Codigo='Não Centralizada'>  
  <cfset dados.Centra_OrgSub_Descricao='Não Centralizada'> 
  <cfset dados.Centra_OrgSub_Sigla='Não Centralizada'>
  <cfset dados.Centra_OrgSub_Email='Não Centralizada'>
  <cfset dados.Centra_Area_Codigo='Não Centralizada'> 
  <cfset dados.Centra_Area_Descricao='Não Centralizada'> 
  <cfset dados.Centra_Area_Sigla='Não Centralizada'>	  
   <cfset dados.Centra_Area_Email='Não Centralizada'>   
 </cfif>
	  
	  
 <cfset result = '#dados#' />  	  
	  
 <cfif "#trim(arguments.MostraDump)#" eq 'yes'>
	  <cfdump var= '#result#' />
  </cfif> 
 
  <cfreturn result/>    
</cffunction>



<!---Gera resultformatado para CPF, CNPJ, Matr�cula, Telefone e N�SEI--->	  
<cffunction	 name="FormataNumero" returntype="string" hint="Gera resultado formatado para CPF, Matrícula e Nº SEI.">

   <cfargument name="Variavel" type="string" required="yes"/><!---Valor a ser formatado--->
   <cfargument name="TipoDeSaida" type="string" default="CPF"/><!---CPF ou CNPJ ou MATRICULA, TEL ou SEI--->
   <cfargument name="MostraDump" type="string"  default="no" /><!---yes ou no ou nao informar--->

   <cfset retorno= ""/>	
	
   <cfif TipoDeSaida eq 'CPF'>
	<cfset retorno = NumberFormat('#trim(arguments.Variavel)#', '00000000000') />
	<cfset retorno = left('#retorno#',3) & '.' & mid('#retorno#',4,3)  & '.' & mid('#retorno#',7,3) & "-" & right('#retorno#',2) /> 
   </cfif>
	
   <cfif TipoDeSaida eq 'CNPJ'>
	<cfset retorno = NumberFormat('#trim(arguments.Variavel)#', '00000000000000') />
	<cfset retorno = left('#retorno#',2) & '.' & mid('#retorno#',3,3)  & '.' & mid('#retorno#',6,3) & "/" & mid('#retorno#',9,4) & "-" & right('#retorno#',2)/> 
   </cfif>
   
   <cfif TipoDeSaida eq 'MATRICULA'>
	<cfset retorno = NumberFormat('#trim(arguments.Variavel)#', '00000000') />
	<cfset retorno = left('#retorno#',1) & '.' & mid('#retorno#',2,3)  & '.' & mid('#retorno#',5,3) & "-" & right('#retorno#',1) /> 
   </cfif>
   
   <cfif TipoDeSaida eq 'TEL'>
	<cfset retorno = NumberFormat('#trim(arguments.Variavel)#', '0000000000') />
	<cfset retorno = "(" & left('#retorno#',2) & ")"  & mid('#retorno#',3,4) & "-" &  right('#retorno#',4) /> 
   </cfif>
	
   <cfif TipoDeSaida eq 'SEI'>
	<cfset retorno = NumberFormat('#trim(arguments.Variavel)#', '00000000000000000') />
	<cfset retorno = left('#retorno#',5) & '.' & mid('#retorno#',6,6) & "/" & mid('#retorno#',12,4) & "-" & right('#retorno#',2)/>  
   </cfif>

   <cfif TipoDeSaida eq 'DATA'>
	<cfset retorno = DateFormat('#trim(arguments.Variavel)#',"DD/MM/YYYY") />
   </cfif>
	
   <cfif TipoDeSaida eq 'INSPECAO'>
	<cfset retorno = NumberFormat('#trim(arguments.Variavel)#', '0000000000') />
	<cfset retorno = left('#retorno#',2) & "." & mid('#retorno#',3,4) & "/" &  right('#retorno#',4) /> 
   </cfif>
	
   <cfif TipoDeSaida eq 'MOEDA'>
	<cfset retorno = LSCurrencyFormat('#trim(arguments.Variavel)#', "local")/> 
   </cfif>
	
	<cfset result = '#retorno#' />
	
	<cfif "#trim(arguments.MostraDump)#" eq 'yes'>
		 <cfset Tipo=StructNew()>
		 <cfset Tipo.MATRICULA="9.999.999-9">	 
		 <cfset Tipo.CPF="999.999.999-99">
		 <cfset Tipo.CNPJ="99.999.999/9999-99"> 
	     <cfset Tipo.SEI="99999.999999/9999-99">
		 <cfset Tipo.TEL="(99)9999-9999">	
	     <cfset Tipo.Data = "DD/MM/YYYY"/> 
		 <cfset Tipo.INSPECAO="99.9999/9999">	 
		 <cfset Tipo.MOEDA="R$ 9.999,99">
			 
	     <cfdump var='Opções para o argumento TipoDeSaida' />
         <cfdump var='#Tipo#' />	
         <cfdump var= 'Tipo de Saída escolhido: #TipoDeSaida#' />
          <br>
         <cfdump var= 'Resultado: #result#' />
     </cfif> 
	
	
	 <cfreturn result />
	
</cffunction>
	  
<!---Retorna os contatos na SCOI da SE da Unidade/�rg�o, para as mensagens autom�ticas--->	  
<cffunction	 name="Contato" returntype="string" hint="Retorna os contatos na SCOI da SE da Unidade/órgão, para as mensagens automáticas.">
  <cfargument name="CodigoDaUnidade" type="string" required="true"  />
  <cfargument name="MostraDump" type="string"  default="no" /><!---yes ou no ou n�o informar--->
	
  <cfquery datasource="#dsn#" name="rsDadosUnidade">
     SELECT  Unidades.Und_CodDiretoria AS Und_Codigo_SE
     FROM    Unidades 
	 WHERE   Unidades.Und_Codigo = <cfqueryparam cfsqltype="CF_SQL_CHAR" maxlength="8"  value="#trim(arguments.CodigoDaUnidade)#">
  </cfquery>
	  
  <cfquery datasource="#dsn#" name="rsFuncionario">
	 SELECT  Fun_Nome as nome, Fun_Email as email, Fun_Tel as tel
     FROM    Funcionarios 
	 WHERE   Fun_ContatoSistema = '1' and Fun_DR = #rsDadosUnidade.Und_Codigo_SE#
	  
	  
  </cfquery> 
  <cfset dadosFunc = ""/>
	  
<cfif rsFuncionario.recordcount gt 0>
	  <cfif rsFuncionario.recordcount gt 1>
        <cfoutput query="rsFuncionario">
           <cfset telefone = "(" & left('#rsFuncionario.tel#',2) & ") "  & mid('#rsFuncionario.tel#',3,4) & "-" &  right('#rsFuncionario.tel#',4) /> 
           <cfset dadosFunc = "#rsFuncionario.nome# - #rsFuncionario.email# - #telefone#; #dadosFunc#"/>
        </cfoutput>
		   <cfset dadosFunc = "Contatos: #dadosFunc#"/>
	  <cfelse>
		   <cfset telefone = "(" & left('#rsFuncionario.tel#',2) & ") "  & mid('#rsFuncionario.tel#',3,4) & "-" &  right('#rsFuncionario.tel#',4) />
		   <cfset dadosFunc = "Contato: #rsFuncionario.nome# - #rsFuncionario.email# - #telefone#"/>
      </cfif>
 <cfelse> 
	  <cfset dadosFunc = ""/>	  
</cfif>
		  
  <cfset result = '#dadosFunc#' />	
  <cfif "#trim(arguments.MostraDump)#" eq 'yes'>
	   <cfdump var= 'Resultado:' />
	   <br>
       <cfdump var= '#result#' />
  </cfif> 
	  
  <cfreturn result />  

</cffunction>
	
<!--Retorna a descri��o do �rg�o no pos_area-->
<cffunction	 name="DescricaoPosArea" returntype="string" hint="Retorna a descrição do órgão no pos_area">
  <cfargument name="CodigoDaUnidade" type="string" required="true"  />
	
  <cfquery datasource="#dsn#" name="rsDescricaoUnidade">
     SELECT  Und_Descricao
     FROM    Unidades 
	 WHERE   Und_Codigo = <cfqueryparam cfsqltype="CF_SQL_CHAR" maxlength="8"  value="#trim(arguments.CodigoDaUnidade)#">
  </cfquery>
  <cfquery datasource="#dsn#" name="rsDescricaoOrgaoSugordinador">
         SELECT  Rep_Nome
         FROM    Reops 
         WHERE   Rep_Codigo = <cfqueryparam cfsqltype="CF_SQL_CHAR" maxlength="8"  value="#trim(arguments.CodigoDaUnidade)#">
  </cfquery>    
  <cfquery datasource="#dsn#" name="rsDescricaoArea">
         SELECT  Ars_Descricao
         FROM    Areas
         WHERE   Ars_Codigo = <cfqueryparam cfsqltype="CF_SQL_CHAR" maxlength="8"  value="#trim(arguments.CodigoDaUnidade)#">
  </cfquery>  
      
      
   <cfset result =""/>
      
  <cfif #rsDescricaoUnidade.Und_Descricao# neq "" >
	 <cfset result = '#rsDescricaoUnidade.Und_Descricao#' />
  </cfif>   
  <cfif #rsDescricaoOrgaoSugordinador.Rep_Nome# neq "">
	 <cfset result = '#rsDescricaoOrgaoSugordinador.Rep_Nome#' />
  </cfif>
  <cfif #rsDescricaoArea.Ars_Descricao# neq "" >
	 <cfset result = '#rsDescricaoArea.Ars_Descricao#' /> 	 	 
  </cfif>

 <cfreturn result />  

</cffunction>
	  
</cfcomponent>
