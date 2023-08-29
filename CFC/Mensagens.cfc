<cfcomponent displayname="Mensagens" hint="Disponibiliza diveros métodos com mensagens e e pareceres automáticos" >

<cffunction name="parecerCentraliza" >
	<cfargument name="TipoDeAcao" type="string" required="true" hint="Centralizacao/Mudanca/Descentralizacao"  default="">
	<cfargument name="NomeUnidadeInspecionada" type="string" required="true"  hint="Nome da unidade inspecionada" default="">	
	<cfargument name="NomeUnidadeCentralizaAntes" type="string" required="true"  hint="Nome da antiga unidade centralizadora" default="">
    <cfargument name="NomeUnidadeCentralizaDepois" type="string" required="true"  hint="Nome da nova unidade centralizadora" default="">
	<cfargument name="DataPrevisaoSolucao" type="string" required="true" hint="Data prevista para a solução da Situação Encontrada"  default="">
	<cfargument name="Responsavel" type="string" required="true" hint="Responsável pela alteração do Centralizador"  default="">
		
		
	<cfswitch expression="#arguments.TipoDeAcao#"> 
		<cfcase value="Descentralizacao">
            <cfset pos_aux = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & 
				   'Opinião do Controle Interno' & CHR(13) & CHR(13) &
                   'À(O) ' &  Trim('#arguments.NomeUnidadeInspecionada#') & CHR(13) & CHR(13) &
                   'Apontamento transferido para manifestação desse órgão em decorrência da descentralização da atividade de Distribuição Domiciliária. Favor adotar/apresentar as ações necessárias para o saneamento da Não Conformidade (NC) registrada.'& CHR(13) & CHR(13) &
                   'Situação: PENDENTE DA UNIDADE'& CHR(13) & CHR(13) &
                   'Data de Previsão da Solução: ' &  DateFormat('#arguments.DataPrevisaoSolucao#',"DD/MM/YYYY") & CHR(13) & CHR(13) &
                   'Responsável: ' & '#arguments.Responsavel#' & CHR(13) & 
				   RepeatString('-',119) >
	   </cfcase>
       <cfcase value="Centralizacao">
            <cfset pos_aux = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & 
			   'Opinião do Controle Interno' & CHR(13) & CHR(13) &
			   'À(O) ' &  Trim('#arguments.NomeUnidadeCentralizaDepois#') & CHR(13) & CHR(13) &
			   'Apontamento transferido para manifestação desse órgão em decorrência da centralização da atividade de Distribuição Domiciliária da unidade verificada: ' &  Trim('#arguments.NomeUnidadeInspecionada#')  & '. Favor adotar/apresentar as ações necessárias para o saneamento da Não Conformidade (NC) registrada.'& CHR(13) & CHR(13) &
			   'Situação: PENDENTE DA UNIDADE'& CHR(13) & CHR(13) &
			   'Data de Previsão da Solução: ' &  DateFormat('#arguments.DataPrevisaoSolucao#',"DD/MM/YYYY") & CHR(13) & CHR(13) &
			   'Responsável: ' & '#arguments.Responsavel#' & CHR(13) & 
				RepeatString('-',119) >
	   </cfcase>
	   <cfcase value="Mudanca">
            <cfset pos_aux = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & 
			   'Opinião do Controle Interno' & CHR(13) & CHR(13) &
			   'À(O) ' &  Trim('#arguments.NomeUnidadeCentralizaDepois#') & CHR(13) & CHR(13) &
			   'Apontamento transferido para manifestação desse órgão em decorrência da mudança da unidade de centralização da atividade de Distribuição Domiciliária da unidade verificada ' &  Trim('#arguments.NomeUnidadeInspecionada#') & ', mudando do ' & Trim('#arguments.NomeUnidadeCentralizaAntes#') & ' para ' & Trim('#arguments.NomeUnidadeCentralizaDepois#') & '. Favor adotar/apresentar as ações necessárias para o saneamento da Não Conformidade (NC) registrada.'& CHR(13) & CHR(13) &
			   'Situação: PENDENTE DA UNIDADE'& CHR(13) & CHR(13) &
			   'Data de Previsão da Solução: ' &  DateFormat('#arguments.DataPrevisaoSolucao#',"DD/MM/YYYY") & CHR(13) & CHR(13) &
			   'Responsável: ' & '#arguments.Responsavel#' & CHR(13) & 
				RepeatString('-',119) >
	   </cfcase>	
			
       <cfdefaultcase>'Ocorreu erro no argumento TipoDeAcao'</cfdefaultcase> 
</cfswitch>	   
		   	
  <cfset result = '#pos_aux#' />
  <cfreturn result />
</cffunction>
	
	
</cfcomponent>
